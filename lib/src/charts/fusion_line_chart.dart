import 'dart:math';

import 'package:flutter/material.dart';
import '../core/enums/axis_position.dart';
import '../rendering/painters/fusion_line_chart_painter.dart';
import '../series/fusion_line_series.dart';
import '../series/series_with_data_points.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_axis_configuration.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_render_cache.dart';
import 'fusion_interactive_chart.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';

class FusionLineChart extends StatefulWidget {
  const FusionLineChart({
    super.key,
    required this.series,
    this.config,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.onPointTap,
    this.onPointLongPress,
  }) : assert(series.length > 0, 'At least one series is required');

  final List<FusionLineSeries> series;
  final FusionChartConfiguration? config;
  final FusionAxisConfiguration? xAxis;
  final FusionAxisConfiguration? yAxis;
  final String? title;
  final String? subtitle;
  final void Function(FusionDataPoint point, String seriesName)? onPointTap;
  final void Function(FusionDataPoint point, String seriesName)? onPointLongPress;

  @override
  State<FusionLineChart> createState() => _FusionLineChartState();
}

class _FusionLineChartState extends State<FusionLineChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FusionInteractiveChartState _interactiveState;
  final FusionRenderCache _cache = FusionRenderCache();
  final FusionPaintPool _paintPool = FusionPaintPool();
  final FusionShaderCache _shaderCache = FusionShaderCache();

  FusionCoordinateSystem? _coordSystem;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initInteractiveState();
  }

  void _initAnimation() {
    final config = widget.config ?? const FusionChartConfiguration();

    _animationController = AnimationController(
      duration: config.enableAnimation ? config.effectiveAnimationDuration : Duration.zero,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: config.effectiveAnimationCurve,
    );

    if (config.enableAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  void _initInteractiveState() {
    // Create initial coord system from data bounds
    // This will be updated with proper chartArea in first build
    final allPoints = widget.series.where((s) => s.visible).expand((s) => s.dataPoints).toList();

    double minX = 0, maxX = 10, minY = 0, maxY = 100;

    if (allPoints.isNotEmpty) {
      final dataMinX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      final dataMaxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
      final dataMinY = allPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      final dataMaxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

      // Use "nice" bounds - start from 0 if data is positive
      minX = dataMinX >= 0 ? 0.0 : dataMinX;
      maxX = dataMaxX;
      minY = dataMinY >= 0 ? 0.0 : dataMinY;
      maxY = dataMaxY;
    }

    _coordSystem = FusionCoordinateSystem(
      chartArea: const Rect.fromLTWH(60, 10, 300, 200), // Placeholder area
      dataXMin: minX,
      dataXMax: maxX,
      dataYMin: minY,
      dataYMax: maxY,
    );

    final config = widget.config ?? const FusionChartConfiguration();

    _interactiveState = FusionInteractiveChartState(
      config: config,
      initialCoordSystem: _coordSystem!,
      series: widget.series.cast<SeriesWithDataPoints>(),
    );
    _interactiveState.initialize();
    _interactiveState.addListener(_onInteractionChanged);
  }

  void _onInteractionChanged() {
    setState(() {
      // Rebuild when interaction state changes (tooltip, crosshair, zoom, pan)
    });
  }

  @override
  void didUpdateWidget(FusionLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.series != oldWidget.series) {
      _cache.clear();

      _animationController.reset();
      _animationController.forward();

      // Update interactive state with new series
      _interactiveState.dispose();
      _initInteractiveState();
    }

    if (widget.config != oldWidget.config) {
      _initAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _interactiveState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config ?? const FusionChartConfiguration();
    final title = widget.title;
    final subtitle = widget.subtitle;

    return Padding(
      padding: config.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) _BuildTitle(title: title),
          if (subtitle != null) _BuildSubtitle(subtitle: subtitle),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    final dpr = MediaQuery.devicePixelRatioOf(context);
                    _updateCoordinateSystem(size, dpr);

                    return Listener(
                      onPointerDown: (event) {
                        _interactiveState.handlePointerDown(event);
                      },
                      onPointerMove: (event) {
                        _interactiveState.handlePointerMove(event);
                      },
                      onPointerUp: (event) {
                        _interactiveState.handlePointerUp(event);
                      },
                      onPointerCancel: (event) {
                        _interactiveState.handlePointerCancel(event);
                      },
                      onPointerHover: (event) {
                        _interactiveState.handlePointerHover(event);
                      },
                      onPointerSignal: (event) {
                        _interactiveState.handlePointerSignal(event);
                      },
                      child: RawGestureDetector(
                        gestures: _interactiveState.getGestureRecognizers(),
                        child: CustomPaint(
                          size: size,
                          painter: FusionLineChartPainter(
                            series: widget.series,
                            coordSystem: _interactiveState.coordSystem,
                            theme: config.theme,
                            xAxis: widget.xAxis,
                            yAxis: widget.yAxis,
                            animationProgress: _animation.value,
                            tooltipData: _interactiveState.tooltipData,
                            crosshairPosition: _interactiveState.crosshairPosition,
                            crosshairPoint: _interactiveState.crosshairPoint,
                            config: config,
                            paintPool: _paintPool,
                            shaderCache: _shaderCache,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateCoordinateSystem(Size size, double dpr) {
    // Skip if size is invalid
    if (size.width <= 0 || size.height <= 0) return;

    // Calculate data bounds from all series
    final allPoints = widget.series.where((s) => s.visible).expand((s) => s.dataPoints).toList();

    if (allPoints.isEmpty) return;

    final dataMinX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final dataMaxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final dataMinY = allPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final dataMaxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    // Use "nice" bounds for axes
    final minX = dataMinX >= 0 ? 0.0 : dataMinX;
    final maxX = dataMaxX;
    final minY = dataMinY >= 0 ? 0.0 : dataMinY;
    final maxY = dataMaxY;

    // Calculate chart area margins
    final config = widget.config ?? const FusionChartConfiguration();
    final margins = _calculateChartAreaMargins(
      config: config,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    );

    final chartArea = Rect.fromLTRB(
      margins.left,
      margins.top,
      size.width - margins.right,
      size.height - margins.bottom,
    );

    // Skip if chart area is invalid
    if (chartArea.width <= 0 || chartArea.height <= 0) return;

    // Create coordinate system with nice bounds
    _coordSystem = FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: minX,
      dataXMax: maxX,
      dataYMin: minY,
      dataYMax: maxY,
      devicePixelRatio: dpr,
    );

    // ALWAYS update interactive state - this is critical for responsiveness
    _interactiveState.updateCoordinateSystem(_coordSystem!);
  }

  /// Calculate chart area margins based on axis positions and label sizes.
  ///
  /// This method ensures:
  /// 1. Y-axis labels fit within left/right margin
  /// 2. X-axis labels fit within top/bottom margin
  /// 3. First/last X-axis labels don't overflow horizontally
  EdgeInsets _calculateChartAreaMargins({
    required FusionChartConfiguration config,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) {
    // If axes are disabled, use minimal margins
    if (!config.enableAxis) {
      return const EdgeInsets.all(4.0);
    }

    // Determine axis positions
    final yAxisPosition = widget.yAxis?.position ?? AxisPosition.left;
    final xAxisPosition = widget.xAxis?.position ?? AxisPosition.bottom;

    // Calculate Y-axis label width
    final yLabelMetrics = _calculateYAxisLabelMetrics(minY, maxY);
    // Margin = label width + tick length (5) + small gap (2)
    final yAxisMargin = yLabelMetrics.maxWidth + 7;

    // Calculate X-axis label metrics (height + first/last label overflow)
    final xLabelMetrics = _calculateXAxisLabelMetrics(minX, maxX);
    // Margin = label height + tick length (5) + gap (7)
    final xAxisMargin = xLabelMetrics.maxHeight + 12;

    // Build margins based on axis positions
    double left = 4.0;
    double right = 4.0;
    double top = 4.0;
    double bottom = 4.0;

    // Y-axis margin goes on the side where Y-axis is positioned
    if (yAxisPosition == AxisPosition.left) {
      left = yAxisMargin;
    } else if (yAxisPosition == AxisPosition.right) {
      right = yAxisMargin;
    }

    // X-axis margin goes on the side where X-axis is positioned
    if (xAxisPosition == AxisPosition.bottom) {
      bottom = xAxisMargin;
    } else if (xAxisPosition == AxisPosition.top) {
      top = xAxisMargin;
    }

    // Add X-axis label overflow to left/right margins
    // First label's left half may extend beyond chart area
    // Last label's right half may extend beyond chart area
    final firstLabelOverflow = xLabelMetrics.firstLabelWidth / 2;
    final lastLabelOverflow = xLabelMetrics.lastLabelWidth / 2;

    // Only add overflow if it's larger than existing margin
    left = max(left, firstLabelOverflow + 2);
    right = max(right, lastLabelOverflow + 2);

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  /// Calculate Y-axis label metrics.
  _AxisLabelMetrics _calculateYAxisLabelMetrics(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 0) {
      return const _AxisLabelMetrics(
        maxWidth: 30.0,
        maxHeight: 14.0,
        firstLabelWidth: 30.0,
        lastLabelWidth: 30.0,
      );
    }

    // Get actual text style from configuration or use default
    final yAxisConfig = widget.yAxis;
    final textStyle = yAxisConfig?.labelStyle ?? const TextStyle(fontSize: 12);
    final labelFormatter = yAxisConfig?.labelFormatter;
    final useAbbreviation = yAxisConfig?.useAbbreviation ?? true;

    // Calculate nice interval
    final interval = _calculateNiceInterval(range, yAxisConfig?.desiredTickCount ?? 5);
    final decimalPlaces = _getDecimalPlaces(interval);

    // Generate all possible label values
    final labelValues = <double>[];
    double current = (minY / interval).floor() * interval;
    while (current <= maxY + interval * 0.01) {
      if (current >= minY - interval * 0.01) {
        labelValues.add(current);
      }
      current += interval;
      if (labelValues.length > 20) break;
    }

    // Measure each label
    double maxWidth = 0;
    double maxHeight = 0;
    for (final value in labelValues) {
      final labelText = _formatLabelValue(value, decimalPlaces, labelFormatter, useAbbreviation);

      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.width > maxWidth) maxWidth = textPainter.width;
      if (textPainter.height > maxHeight) maxHeight = textPainter.height;
    }

    return _AxisLabelMetrics(
      maxWidth: maxWidth.clamp(20.0, 100.0),
      maxHeight: maxHeight.clamp(10.0, 30.0),
      firstLabelWidth: maxWidth, // Y-axis labels are vertically stacked, no overflow
      lastLabelWidth: maxWidth,
    );
  }

  /// Calculate X-axis label metrics including first/last label widths for overflow.
  _AxisLabelMetrics _calculateXAxisLabelMetrics(double minX, double maxX) {
    final range = maxX - minX;
    if (range <= 0) {
      return const _AxisLabelMetrics(
        maxWidth: 30.0,
        maxHeight: 14.0,
        firstLabelWidth: 30.0,
        lastLabelWidth: 30.0,
      );
    }

    // Get actual text style from configuration or use default
    final xAxisConfig = widget.xAxis;
    final textStyle = xAxisConfig?.labelStyle ?? const TextStyle(fontSize: 12);
    final labelFormatter = xAxisConfig?.labelFormatter;
    final useAbbreviation = xAxisConfig?.useAbbreviation ?? true;

    // Calculate nice interval
    final interval = _calculateNiceInterval(range, xAxisConfig?.desiredTickCount ?? 5);
    final decimalPlaces = _getDecimalPlaces(interval);

    // Generate all possible label values
    final labelValues = <double>[];
    double current = (minX / interval).floor() * interval;
    while (current <= maxX + interval * 0.01) {
      if (current >= minX - interval * 0.01) {
        labelValues.add(current);
      }
      current += interval;
      if (labelValues.length > 20) break;
    }

    if (labelValues.isEmpty) {
      return const _AxisLabelMetrics(
        maxWidth: 30.0,
        maxHeight: 14.0,
        firstLabelWidth: 30.0,
        lastLabelWidth: 30.0,
      );
    }

    // Measure each label
    double maxWidth = 0;
    double maxHeight = 0;
    double firstLabelWidth = 0;
    double lastLabelWidth = 0;

    for (int i = 0; i < labelValues.length; i++) {
      final value = labelValues[i];
      final labelText = _formatLabelValue(value, decimalPlaces, labelFormatter, useAbbreviation);

      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.width > maxWidth) maxWidth = textPainter.width;
      if (textPainter.height > maxHeight) maxHeight = textPainter.height;

      // Track first and last label widths
      if (i == 0) firstLabelWidth = textPainter.width;
      if (i == labelValues.length - 1) lastLabelWidth = textPainter.width;
    }

    return _AxisLabelMetrics(
      maxWidth: maxWidth.clamp(20.0, 150.0),
      maxHeight: maxHeight.clamp(10.0, 30.0),
      firstLabelWidth: firstLabelWidth,
      lastLabelWidth: lastLabelWidth,
    );
  }

  /// Calculate a nice interval for the given range.
  double _calculateNiceInterval(double range, int desiredTicks) {
    if (range <= 0) return 1.0;

    final roughInterval = range / desiredTicks;
    final magnitude = _calculateMagnitude(roughInterval);
    final normalized = roughInterval / magnitude;

    double niceFraction;
    if (normalized < 1.5) {
      niceFraction = 1.0;
    } else if (normalized < 3.0) {
      niceFraction = 2.0;
    } else if (normalized < 7.0) {
      niceFraction = 5.0;
    } else {
      niceFraction = 10.0;
    }

    return niceFraction * magnitude;
  }

  /// Calculate the magnitude (power of 10) for a value.
  double _calculateMagnitude(double value) {
    if (value == 0) return 1.0;
    final absValue = value.abs();
    final exp = (log(absValue) / ln10).floor();
    return pow(10.0, exp).toDouble();
  }

  /// Get appropriate decimal places for an interval.
  int _getDecimalPlaces(double interval) {
    if (interval >= 1) return 0;
    if (interval >= 0.1) return 1;
    if (interval >= 0.01) return 2;
    return 3;
  }

  /// Format a label value using formatter, abbreviation, or default formatting.
  String _formatLabelValue(
    double value,
    int decimalPlaces,
    String Function(double)? formatter,
    bool useAbbreviation,
  ) {
    // Custom formatter takes priority
    if (formatter != null) {
      return formatter(value);
    }

    // Use abbreviation for large numbers
    if (useAbbreviation) {
      final absValue = value.abs();
      if (absValue >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B';
      } else if (absValue >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (absValue >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
    }

    // Default formatting
    if (decimalPlaces == 0) {
      return value.round().toString();
    }
    return value.toStringAsFixed(decimalPlaces);
  }
}

class _BuildSubtitle extends StatelessWidget {
  const _BuildSubtitle({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BuildTitle extends StatelessWidget {
  const _BuildTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Helper class to hold axis label measurements.
class _AxisLabelMetrics {
  const _AxisLabelMetrics({
    required this.maxWidth,
    required this.maxHeight,
    required this.firstLabelWidth,
    required this.lastLabelWidth,
  });

  /// Maximum width of any label (used for Y-axis margin).
  final double maxWidth;

  /// Maximum height of any label (used for X-axis margin).
  final double maxHeight;

  /// Width of the first label (for left overflow calculation).
  final double firstLabelWidth;

  /// Width of the last label (for right overflow calculation).
  final double lastLabelWidth;
}

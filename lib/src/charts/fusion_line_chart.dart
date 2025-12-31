import 'package:flutter/material.dart';
import '../rendering/painters/fusion_line_chart_painter.dart';
import '../series/fusion_line_series.dart';
import '../series/series_with_data_points.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_axis_configuration.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../utils/fusion_margin_calculator.dart';
import '../utils/axis_calculator.dart';
import 'fusion_interactive_chart.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';
import 'base/fusion_chart_header.dart';

/// Helper class to hold calculated nice axis bounds.
class _NiceAxisBounds {
  const _NiceAxisBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
}

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

      // Use nice bounds - consistent with _updateCoordinateSystem
      final niceBounds = _calculateNiceAxisBounds(
        dataMinX: dataMinX,
        dataMaxX: dataMaxX,
        dataMinY: dataMinY,
        dataMaxY: dataMaxY,
      );
      
      minX = niceBounds.minX;
      maxX = niceBounds.maxX;
      minY = niceBounds.minY;
      maxY = niceBounds.maxY;
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
    final theme = config.theme;
    final title = widget.title;
    final subtitle = widget.subtitle;

    return Padding(
      padding: config.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) FusionChartTitle(title: title, theme: theme),
          if (subtitle != null) FusionChartSubtitle(subtitle: subtitle, theme: theme),
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
                            theme: theme,
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

    // Calculate nice axis bounds using AxisCalculator (single source of truth)
    final niceBounds = _calculateNiceAxisBounds(
      dataMinX: dataMinX,
      dataMaxX: dataMaxX,
      dataMinY: dataMinY,
      dataMaxY: dataMaxY,
    );

    // Calculate chart area margins using shared utility
    final config = widget.config ?? const FusionChartConfiguration();
    final margins = FusionMarginCalculator.calculate(
      enableAxis: config.enableAxis,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
      minX: niceBounds.minX,
      maxX: niceBounds.maxX,
      minY: niceBounds.minY,
      maxY: niceBounds.maxY,
    );

    final chartArea = Rect.fromLTRB(
      margins.left,
      margins.top,
      size.width - margins.right,
      size.height - margins.bottom,
    );

    // Skip if chart area is invalid
    if (chartArea.width <= 0 || chartArea.height <= 0) return;

    // Create coordinate system with NICE bounds (aligned with axis labels)
    _coordSystem = FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: niceBounds.minX,
      dataXMax: niceBounds.maxX,
      dataYMin: niceBounds.minY,
      dataYMax: niceBounds.maxY,
      devicePixelRatio: dpr,
    );

    // ALWAYS update interactive state - this is critical for responsiveness
    _interactiveState.updateCoordinateSystem(_coordSystem!);
  }

  /// Calculates nice axis bounds that align with axis labels.
  /// 
  /// This ensures the coordinate system uses the same bounds as the axis renderer,
  /// preventing misalignment between data rendering and axis labels.
  /// 
  /// **Y-Axis (value axis):** Uses nice round bounds with headroom for visual breathing room.
  /// **X-Axis (domain axis):** Uses exact data bounds - no extra padding.
  _NiceAxisBounds _calculateNiceAxisBounds({
    required double dataMinX,
    required double dataMaxX,
    required double dataMinY,
    required double dataMaxY,
  }) {
    final xAxisConfig = widget.xAxis ?? const FusionAxisConfiguration();
    final yAxisConfig = widget.yAxis ?? const FusionAxisConfiguration();

    // === X-AXIS BOUNDS (Domain Axis) ===
    // Use exact data bounds - no rounding, no headroom
    // Users expect data points to span the full horizontal width
    double minX, maxX;
    
    if (xAxisConfig.min != null && xAxisConfig.max != null) {
      // Use explicit bounds from configuration
      minX = xAxisConfig.min!;
      maxX = xAxisConfig.max!;
    } else {
      // Use exact data range
      minX = xAxisConfig.min ?? dataMinX;
      maxX = xAxisConfig.max ?? dataMaxX;
    }

    // === Y-AXIS BOUNDS (Value Axis) ===
    // Use nice round bounds with headroom for visual breathing room
    double minY, maxY;
    
    if (yAxisConfig.min != null && yAxisConfig.max != null) {
      // Use explicit bounds from configuration
      minY = yAxisConfig.min!;
      maxY = yAxisConfig.max!;
    } else {
      // Auto-calculate nice bounds
      // Start from 0 if all data is positive (common UX pattern)
      final effectiveMinY = dataMinY >= 0 ? 0.0 : dataMinY;
      final effectiveMaxY = dataMaxY;
      
      // Calculate nice interval
      final yInterval = yAxisConfig.interval ?? 
          AxisCalculator.calculateNiceInterval(
            effectiveMinY, 
            effectiveMaxY, 
            yAxisConfig.desiredIntervals,
          );
      
      // Round to nice bounds
      minY = yAxisConfig.min ?? _roundDownToInterval(effectiveMinY, yInterval);
      maxY = yAxisConfig.max ?? _roundUpToInterval(effectiveMaxY, yInterval);
      
      // Ensure adequate headroom: if data max is too close to axis max,
      // add one more interval to prevent cramped appearance
      final headroom = maxY - dataMaxY;
      if (headroom < yInterval * 0.15 && yAxisConfig.max == null) {
        maxY += yInterval;
      }
    }

    return _NiceAxisBounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY);
  }

  /// Rounds value down to nearest interval multiple.
  double _roundDownToInterval(double value, double interval) {
    if (interval <= 0) return value;
    return (value / interval).floor() * interval;
  }

  /// Rounds value up to nearest interval multiple.
  double _roundUpToInterval(double value, double interval) {
    if (interval <= 0) return value;
    return (value / interval).ceil() * interval;
  }
}

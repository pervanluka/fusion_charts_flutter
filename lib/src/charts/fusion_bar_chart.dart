import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/rendering/painters/fusion_bar_chart_painter.dart';
import '../series/fusion_bar_series.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_axis_configuration.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_render_cache.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';
import 'fusion_bar_interactive_state.dart';

/// A professional bar chart widget with Syncfusion-style features.
///
/// ## Features
///
/// - **Vertical bars** (column charts) - default
/// - **Horizontal bars** (bar charts) - set `isVertical: false` on series
/// - **Grouped bars** - multiple series displayed side-by-side
/// - **Overlapped bars** - set `enableSideBySideSeriesPlacement: false` in config
/// - **Track bars** - background bars for progress visualization
/// - **Rounded corners** - configurable via `borderRadius`
/// - **Gradients** - beautiful gradient fills
/// - **Shadows** - depth effects
/// - **Borders** - custom bar borders
/// - **Animations** - smooth entry animations
/// - **Interactivity** - tooltips, crosshair, selection
///
/// ## Example
///
/// ```dart
/// FusionBarChart(
///   series: [
///     FusionBarSeries(
///       name: 'Sales',
///       dataPoints: [
///         FusionDataPoint(0, 65, label: 'Q1'),
///         FusionDataPoint(1, 78, label: 'Q2'),
///         FusionDataPoint(2, 82, label: 'Q3'),
///         FusionDataPoint(3, 95, label: 'Q4'),
///       ],
///       color: Colors.blue,
///       barWidth: 0.6,
///       borderRadius: 8.0,
///     ),
///   ],
/// )
/// ```
class FusionBarChart extends StatefulWidget {
  const FusionBarChart({
    super.key,
    required this.series,
    this.config,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.onBarTap,
    this.onBarLongPress,
  }) : assert(series.length > 0, 'At least one series is required');

  /// All bar series to display.
  final List<FusionBarSeries> series;

  /// Chart configuration (animations, interactions, etc.).
  final FusionChartConfiguration? config;

  /// X-axis configuration.
  final FusionAxisConfiguration? xAxis;

  /// Y-axis configuration.
  final FusionAxisConfiguration? yAxis;

  /// Optional chart title.
  final String? title;

  /// Optional chart subtitle.
  final String? subtitle;

  /// Callback when a bar is tapped.
  final void Function(FusionDataPoint point, String seriesName)? onBarTap;

  /// Callback when a bar is long-pressed.
  final void Function(FusionDataPoint point, String seriesName)? onBarLongPress;

  @override
  State<FusionBarChart> createState() => _FusionBarChartState();
}

class _FusionBarChartState extends State<FusionBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FusionBarInteractiveState _interactiveState;
  final FusionRenderCache _cache = FusionRenderCache();
  final FusionPaintPool _paintPool = FusionPaintPool();
  final FusionShaderCache _shaderCache = FusionShaderCache();

  FusionCoordinateSystem? _coordSystem;

  Size? _cachedSize;
  int? _cachedSeriesHash;
  FusionCoordinateSystem? _cachedCoordSystem;

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
    _coordSystem = _createPlaceholderCoordSystem();
    final config = widget.config ?? const FusionChartConfiguration();

    _interactiveState = FusionBarInteractiveState(
      config: config,
      initialCoordSystem: _coordSystem!,
      series: widget.series,
      enableSideBySideSeriesPlacement: config.enableSideBySideSeriesPlacement,
    );
    _interactiveState.initialize();
    _interactiveState.addListener(_onInteractionChanged);
  }

  FusionCoordinateSystem _createPlaceholderCoordSystem() {
    return FusionCoordinateSystem(
      chartArea: const Rect.fromLTWH(60, 10, 300, 200),
      dataXMin: -0.5,
      dataXMax: _getMaxPointCount() - 0.5,
      dataYMin: 0,
      dataYMax: _getMaxYValue() * 1.1,
    );
  }

  int _getMaxPointCount() {
    int max = 0;
    for (final series in widget.series) {
      if (series.dataPoints.length > max) {
        max = series.dataPoints.length;
      }
    }
    return max > 0 ? max : 1;
  }

  double _getMaxYValue() {
    double max = 0;
    for (final series in widget.series) {
      for (final point in series.dataPoints) {
        if (point.y > max) max = point.y;
      }
    }
    return max > 0 ? max : 100;
  }

  void _onInteractionChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(FusionBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.series != oldWidget.series || widget.config != oldWidget.config) {
      _cache.clear();
      _cachedCoordSystem = null;
      _cachedSeriesHash = null;

      _animationController.reset();
      _animationController.forward();

      _interactiveState.dispose();
      _initInteractiveState();
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
                    _updateCoordinateSystem(size);

                    if (_coordSystem != null) {
                      _interactiveState.updateCoordinateSystem(_coordSystem!);
                    }

                    return Listener(
                      onPointerDown: _interactiveState.handlePointerDown,
                      onPointerMove: _interactiveState.handlePointerMove,
                      onPointerUp: _interactiveState.handlePointerUp,
                      onPointerCancel: _interactiveState.handlePointerCancel,
                      onPointerHover: _interactiveState.handlePointerHover,
                      child: RawGestureDetector(
                        gestures: _interactiveState.getGestureRecognizers(),
                        child: CustomPaint(
                          size: size,
                          painter: FusionBarChartPainter(
                            series: widget.series,
                            coordSystem: _coordSystem!,
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

  void _updateCoordinateSystem(Size size) {
    final seriesHash = _calculateSeriesHash(widget.series);

    if (_cachedSize == size && _cachedSeriesHash == seriesHash && _cachedCoordSystem != null) {
      _coordSystem = _cachedCoordSystem;
      return;
    }

    final config = widget.config ?? const FusionChartConfiguration();

    final leftMargin = config.enableAxis ? 60.0 : 10.0;
    final rightMargin = 10.0;
    final topMargin = 10.0;
    final bottomMargin = config.enableAxis ? 40.0 : 10.0;

    final chartArea = Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );

    final allPoints = widget.series.where((s) => s.visible).expand((s) => s.dataPoints).toList();

    if (allPoints.isEmpty) {
      _coordSystem = FusionCoordinateSystem(
        chartArea: chartArea,
        dataXMin: -0.5,
        dataXMax: 0.5,
        dataYMin: 0,
        dataYMax: 100,
      );
      return;
    }

    final useCategoryPositioning = _isCategoryData(allPoints);

    double minX, maxX, minY, maxY;

    if (useCategoryPositioning) {
      final pointCount = widget.series.first.dataPoints.length;
      minX = -0.5;
      maxX = pointCount - 0.5;
    } else {
      minX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      maxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
      final xPadding = (maxX - minX) * 0.1;
      minX -= xPadding;
      maxX += xPadding;
    }

    minY = 0.0;
    maxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final yPadding = maxY * 0.1;
    maxY += yPadding;

    _coordSystem = FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: minX,
      dataXMax: maxX,
      dataYMin: minY,
      dataYMax: maxY,
    );

    _cachedSize = size;
    _cachedSeriesHash = seriesHash;
    _cachedCoordSystem = _coordSystem;
  }

  bool _isCategoryData(List<FusionDataPoint> points) {
    final firstSeries = widget.series.first;
    for (int i = 0; i < firstSeries.dataPoints.length; i++) {
      if (firstSeries.dataPoints[i].x != i.toDouble()) {
        return false;
      }
    }
    return true;
  }

  int _calculateSeriesHash(List<FusionBarSeries> series) {
    int hash = 0;
    for (final s in series) {
      hash ^= s.visible.hashCode;
      hash ^= s.dataPoints.length.hashCode;
      if (s.dataPoints.isNotEmpty) {
        hash ^= s.dataPoints.first.hashCode;
        hash ^= s.dataPoints.last.hashCode;
      }
    }
    return hash;
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

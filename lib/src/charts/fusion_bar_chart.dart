import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/rendering/painters/fusion_bar_chart_painter.dart';
import '../series/fusion_bar_series.dart';
import '../series/series_with_data_points.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_axis_configuration.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_render_cache.dart';
import 'fusion_interactive_chart.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';

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

  final List<FusionBarSeries> series;
  final FusionChartConfiguration? config;
  final FusionAxisConfiguration? xAxis;
  final FusionAxisConfiguration? yAxis;
  final String? title;
  final String? subtitle;
  final void Function(FusionDataPoint point, String seriesName)? onBarTap;
  final void Function(FusionDataPoint point, String seriesName)? onBarLongPress;

  @override
  State<FusionBarChart> createState() => _FusionBarChartState();
}

class _FusionBarChartState extends State<FusionBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FusionInteractiveChartState _interactiveState;
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
    // Placeholder coordinate system (will be updated in build)
    _coordSystem = FusionCoordinateSystem(
      chartArea: Rect.fromLTWH(60, 10, 300, 200),
      dataXMin: 0,
      dataXMax: 10,
      dataYMin: 0,
      dataYMax: 100,
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
  void didUpdateWidget(FusionBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.series != oldWidget.series) {
      _cache.clear();
      // Clear coordinate cache when data changes
      _cachedCoordSystem = null;
      _cachedSeriesHash = null;

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

    return Padding(
      padding: config.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.title != null) _buildTitle(),
          if (widget.subtitle != null) _buildSubtitle(),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    _updateCoordinateSystem(size);

                    return RawGestureDetector(
                      gestures: _interactiveState.getGestureRecognizers(),
                      child: CustomPaint(
                        size: size,
                        painter: FusionBarChartPainter(
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
    // Calculate hash of current series data
    final seriesHash = _calculateSeriesHash(widget.series);

    // Check if we can reuse cached coordinate system
    if (_cachedSize == size && _cachedSeriesHash == seriesHash && _cachedCoordSystem != null) {
      _coordSystem = _cachedCoordSystem;
      return; // Use cached system - no recalculation!
    }

    // Calculate chart area (excluding margins for axes)
    final leftMargin = 60.0;
    final rightMargin = 10.0;
    final topMargin = 10.0;
    final bottomMargin = 40.0;

    final chartArea = Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );

    // Calculate data bounds from all series
    final allPoints = widget.series.where((s) => s.visible).expand((s) => s.dataPoints).toList();

    if (allPoints.isEmpty) return;

    final minX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final maxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final minY = 0.0; // Bars always start from 0
    final maxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    // Add padding
    final xPadding = (maxX - minX) * 0.1;
    final yPadding = maxY * 0.1;

    _coordSystem = FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: minX - xPadding,
      dataXMax: maxX + xPadding,
      dataYMin: minY,
      dataYMax: maxY + yPadding,
    );

    // Update cache
    _cachedSize = size;
    _cachedSeriesHash = seriesHash;
    _cachedCoordSystem = _coordSystem;
  }

  int _calculateSeriesHash(List<FusionBarSeries> series) {
    int hash = 0;
    for (final s in series) {
      hash ^= s.visible.hashCode;
      hash ^= s.dataPoints.length.hashCode;
      // Hash first and last point for quick change detection
      if (s.dataPoints.isNotEmpty) {
        hash ^= s.dataPoints.first.hashCode;
        hash ^= s.dataPoints.last.hashCode;
      }
    }
    return hash;
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        widget.title!,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        widget.subtitle!,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }
}

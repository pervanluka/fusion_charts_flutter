import 'package:flutter/material.dart';
import '../rendering/painters/fusion_line_chart_painter.dart';
import '../series/fusion_line_series.dart';
import '../series/series_with_data_points.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_axis_configuration.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../utils/fusion_margin_calculator.dart';
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

    // Calculate chart area margins using shared utility
    final config = widget.config ?? const FusionChartConfiguration();
    final margins = FusionMarginCalculator.calculate(
      enableAxis: config.enableAxis,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
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

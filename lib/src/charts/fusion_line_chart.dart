import 'package:flutter/material.dart';

import '../configuration/fusion_axis_configuration.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../controllers/fusion_chart_controller.dart';
import '../data/fusion_data_point.dart';
import '../live/fusion_live_chart_controller.dart';
import '../live/live_viewport_mode.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/layers/fusion_selection_rect_layer.dart';
import '../rendering/painters/fusion_line_chart_painter.dart';
import '../series/fusion_line_series.dart';
import '../series/series_with_data_points.dart';
import '../utils/chart_bounds_calculator.dart';
import '../utils/fusion_margin_calculator.dart';
import 'base/fusion_chart_header.dart';
import 'fusion_interactive_chart.dart';

class FusionLineChart extends StatefulWidget {
  const FusionLineChart({
    required this.series,
    super.key,
    this.config,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.controller,
    this.liveController,
    this.liveViewportMode,
    this.onPointTap,
    this.onPointLongPress,
  }) : assert(series.length > 0, 'At least one series is required');

  final List<FusionLineSeries> series;
  final FusionChartConfiguration? config;
  final FusionAxisConfiguration? xAxis;
  final FusionAxisConfiguration? yAxis;
  final String? title;
  final String? subtitle;

  /// Controller for programmatic zoom/pan control.
  final FusionChartController? controller;

  /// Controller for live/real-time data streaming.
  ///
  /// When provided, data points are pulled from this controller instead of
  /// the static [series] data. The series objects still define styling
  /// (color, line width, name), but data comes from the controller.
  ///
  /// Example:
  /// ```dart
  /// final liveController = FusionLiveChartController(
  ///   retentionPolicy: RetentionPolicy.rollingCount(500),
  /// );
  ///
  /// // Add data from any source
  /// websocket.onMessage((data) {
  ///   liveController.addPoint('price', FusionDataPoint(now, data.price));
  /// });
  ///
  /// FusionLineChart(
  ///   liveController: liveController,
  ///   series: [FusionLineSeries(name: 'price', color: Colors.blue)],
  /// )
  /// ```
  final FusionLiveChartController? liveController;

  /// Viewport behavior for live data mode.
  ///
  /// Defaults to [AutoScrollViewport] with 60 seconds visible duration.
  /// Only used when [liveController] is provided.
  final LiveViewportMode? liveViewportMode;

  final void Function(FusionDataPoint point, String seriesName)? onPointTap;
  final void Function(FusionDataPoint point, String seriesName)?
  onPointLongPress;

  /// Whether this chart is in live mode.
  bool get isLiveMode => liveController != null;

  @override
  State<FusionLineChart> createState() => _FusionLineChartState();
}

class _FusionLineChartState extends State<FusionLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FusionInteractiveChartState _interactiveState;
  final FusionPaintPool _paintPool = FusionPaintPool();
  final FusionShaderCache _shaderCache = FusionShaderCache();

  FusionCoordinateSystem? _coordSystem;

  /// Cached series with live data merged in.
  List<FusionLineSeries>? _liveSeries;

  /// Whether user has interacted (pausing auto-scroll).
  bool _userInteracted = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initInteractiveState();
    _attachController();
    _attachLiveController();
  }

  void _attachController() {
    widget.controller?.attach(_interactiveState);
  }

  void _detachController() {
    widget.controller?.detach();
  }

  void _attachLiveController() {
    widget.liveController?.addListener(_onLiveDataChanged);
  }

  void _detachLiveController() {
    widget.liveController?.removeListener(_onLiveDataChanged);
  }

  void _onLiveDataChanged() {
    // Invalidate cached series
    _liveSeries = null;

    // Update interactive state with new series data (critical for tooltip hit testing)
    final effectiveSeries = _effectiveSeries;
    _interactiveState.series = effectiveSeries.cast<SeriesWithDataPoints>();

    // Update coordinate system for auto-scroll
    if (widget.isLiveMode && !_userInteracted) {
      _updateLiveViewport();
    }

    // Update live tooltip AFTER viewport is updated (requires correct coordinate system)
    _interactiveState.updateLiveTooltip();

    setState(() {});
  }

  /// Get the effective series (with live data if in live mode).
  List<FusionLineSeries> get _effectiveSeries {
    if (!widget.isLiveMode) {
      return widget.series;
    }

    // Return cached if available
    if (_liveSeries != null) return _liveSeries!;

    // Build series with data from live controller
    final controller = widget.liveController!;
    _liveSeries = widget.series.map((series) {
      final livePoints = controller.getPoints(series.name);
      if (livePoints.isEmpty) {
        return series;
      }
      // Create a copy of the series with live data
      return series.copyWith(dataPoints: livePoints);
    }).toList();

    return _liveSeries!;
  }

  /// Update viewport for live data auto-scroll.
  void _updateLiveViewport() {
    if (!widget.isLiveMode || _coordSystem == null) return;

    final controller = widget.liveController!;
    final viewportMode =
        widget.liveViewportMode ??
        const LiveViewportMode.autoScroll(
          visibleDuration: Duration(seconds: 60),
        );

    // Get the latest data point across all series
    double? latestX;
    for (final series in widget.series) {
      final latest = controller.getLatestPoint(series.name);
      if (latest != null) {
        if (latestX == null || latest.x > latestX) {
          latestX = latest.x;
        }
      }
    }

    if (latestX == null) return;

    switch (viewportMode) {
      case AutoScrollViewport(
        visibleDuration: final duration,
        leadingPadding: final leading,
      ):
        // Calculate viewport range based on duration
        final visibleMs = duration.inMilliseconds.toDouble();
        final leadingMs = leading.inMilliseconds.toDouble();

        final maxX = latestX + leadingMs;
        final minX = maxX - visibleMs;

        _interactiveState.setViewportRange(minX: minX, maxX: maxX);

      case AutoScrollPointsViewport(
        visiblePoints: final count,
        leadingPoints: final leading,
      ):
        // Get all points to determine range
        final allPoints = _effectiveSeries
            .where((s) => s.visible)
            .expand((s) => s.dataPoints)
            .toList();

        if (allPoints.length < 2) return;

        // Sort by x and take last N points
        allPoints.sort((a, b) => a.x.compareTo(b.x));
        final startIndex = (allPoints.length - count - leading).clamp(
          0,
          allPoints.length - 1,
        );
        final minX = allPoints[startIndex].x;
        final maxX = latestX;

        _interactiveState.setViewportRange(minX: minX, maxX: maxX);

      case FixedViewport(initialRange: final range):
        if (range != null) {
          _interactiveState.setViewportRange(minX: range.$1, maxX: range.$2);
        }
      // Fixed viewport doesn't auto-scroll

      case AutoScrollUntilInteractionViewport(
        visibleDuration: final duration,
        leadingPadding: final leading,
      ):
        if (_userInteracted) return; // User has taken control

        final visibleMs = duration.inMilliseconds.toDouble();
        final leadingMs = leading.inMilliseconds.toDouble();

        final maxX = latestX + leadingMs;
        final minX = maxX - visibleMs;

        _interactiveState.setViewportRange(minX: minX, maxX: maxX);

      case FillThenScrollViewport(
        maxDuration: final maxDuration,
        leadingPadding: final leading,
      ):
        // Get oldest point
        double? oldestX;
        for (final series in widget.series) {
          final oldest = controller.getOldestPoint(series.name);
          if (oldest != null) {
            if (oldestX == null || oldest.x < oldestX) {
              oldestX = oldest.x;
            }
          }
        }

        if (oldestX == null) return;

        final dataSpan = latestX - oldestX;
        final maxMs = maxDuration.inMilliseconds.toDouble();
        final leadingMs = leading.inMilliseconds.toDouble();

        if (dataSpan < maxMs) {
          // Still filling - show all data with some padding
          _interactiveState.setViewportRange(
            minX: oldestX,
            maxX: latestX + leadingMs,
          );
        } else {
          // Filled - now scroll
          final maxX = latestX + leadingMs;
          final minX = maxX - maxMs;
          _interactiveState.setViewportRange(minX: minX, maxX: maxX);
        }
    }
  }

  void _initAnimation() {
    final config = widget.config ?? const FusionChartConfiguration();

    _animationController = AnimationController(
      duration: config.enableAnimation
          ? config.effectiveAnimationDuration
          : Duration.zero,
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
    final effectiveSeries = _effectiveSeries;
    final allPoints = effectiveSeries
        .where((s) => s.visible)
        .expand((s) => s.dataPoints)
        .toList();

    double minX = 0;
    double maxX = 10;
    double minY = 0;
    double maxY = 100;

    if (allPoints.isNotEmpty) {
      final dataMinX = allPoints
          .map((p) => p.x)
          .reduce((a, b) => a < b ? a : b);
      final dataMaxX = allPoints
          .map((p) => p.x)
          .reduce((a, b) => a > b ? a : b);
      final dataMinY = allPoints
          .map((p) => p.y)
          .reduce((a, b) => a < b ? a : b);
      final dataMaxY = allPoints
          .map((p) => p.y)
          .reduce((a, b) => a > b ? a : b);

      // Use ChartBoundsCalculator for consistent bounds calculation
      final xBounds = ChartBoundsCalculator.calculateNiceXBounds(
        dataMinX: dataMinX,
        dataMaxX: dataMaxX,
        xAxisConfig: widget.xAxis,
      );
      final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
        dataMinY: dataMinY,
        dataMaxY: dataMaxY,
        yAxisConfig: widget.yAxis,
      );

      minX = xBounds.minX;
      maxX = xBounds.maxX;
      minY = yBounds.minY;
      maxY = yBounds.maxY;
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
      series: effectiveSeries.cast<SeriesWithDataPoints>(),
      isLiveMode: widget.isLiveMode,
    );
    _interactiveState.initialize();
    _interactiveState.addListener(_onInteractionChanged);

    // Reset live viewport flag to ensure first setViewportRange() can properly
    // initialize the coordinate system (avoids stale placeholder bounds)
    if (widget.isLiveMode) {
      _interactiveState.resetLiveViewport();
    }
  }

  void _onInteractionChanged() {
    // Track user interaction for AutoScrollUntilInteraction mode
    // If user has zoomed or panned, mark as interacted
    if (widget.isLiveMode && !_userInteracted) {
      final viewportMode = widget.liveViewportMode;
      if (viewportMode is AutoScrollUntilInteractionViewport) {
        // Check if this is a zoom/pan interaction (not just tooltip/crosshair)
        if (_interactiveState.isInteracting) {
          _userInteracted = true;
        }
      }
    }

    setState(() {
      // Rebuild when interaction state changes (tooltip, crosshair, zoom, pan)
    });
  }

  @override
  void didUpdateWidget(FusionLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle live controller changes
    if (widget.liveController != oldWidget.liveController) {
      oldWidget.liveController?.removeListener(_onLiveDataChanged);
      widget.liveController?.addListener(_onLiveDataChanged);
      _liveSeries = null; // Invalidate cache
      _userInteracted = false; // Reset user interaction state

      // Reset live viewport so new controller can set proper bounds
      if (widget.isLiveMode) {
        _interactiveState.resetLiveViewport();
      }
    }

    if (widget.series != oldWidget.series) {
      _liveSeries = null; // Invalidate cache

      // Only animate for non-live mode or significant series changes
      if (!widget.isLiveMode) {
        _animationController.reset();
        _animationController.forward();
      }

      // Update interactive state with new series
      _detachController();
      _interactiveState.dispose();
      _initInteractiveState();
      _attachController();
    }

    if (widget.config != oldWidget.config) {
      _initAnimation();
    }

    // Handle controller changes
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(_interactiveState);
    }
  }

  @override
  void dispose() {
    _detachController();
    _detachLiveController();
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
          if (subtitle != null)
            FusionChartSubtitle(subtitle: subtitle, theme: theme),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final dpr = MediaQuery.devicePixelRatioOf(context);
                    _updateCoordinateSystem(size, dpr);

                    return MouseRegion(
                      onExit: (event) {
                        _interactiveState.handlePointerExit(event);
                      },
                      child: Listener(
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
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: size,
                                painter: FusionLineChartPainter(
                                  series: _effectiveSeries,
                                  coordSystem: _interactiveState.coordSystem,
                                  theme: theme,
                                  xAxis: widget.xAxis,
                                  yAxis: widget.yAxis,
                                  animationProgress: widget.isLiveMode
                                      ? 1.0
                                      : _animation.value,
                                  tooltipData: _interactiveState.tooltipData,
                                  crosshairPosition:
                                      _interactiveState.crosshairPosition,
                                  crosshairPoint:
                                      _interactiveState.crosshairPoint,
                                  config: config,
                                  paintPool: _paintPool,
                                  shaderCache: _shaderCache,
                                ),
                              ),
                              // Selection rectangle overlay
                              if (_interactiveState.selectionRect != null)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: FusionSelectionRectLayer(
                                      selectionRect:
                                          _interactiveState.selectionRect!,
                                      fillColor: theme.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderColor: theme.primaryColor,
                                    ),
                                  ),
                                ),
                            ],
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

    // Calculate data bounds from all series (use effective series for live mode)
    final effectiveSeries = _effectiveSeries;
    final allPoints = effectiveSeries
        .where((s) => s.visible)
        .expand((s) => s.dataPoints)
        .toList();

    if (allPoints.isEmpty) return;

    final dataMinX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final dataMaxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final dataMinY = allPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final dataMaxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    // Use ChartBoundsCalculator for consistent bounds calculation
    final xBounds = ChartBoundsCalculator.calculateNiceXBounds(
      dataMinX: dataMinX,
      dataMaxX: dataMaxX,
      xAxisConfig: widget.xAxis,
    );
    final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
      dataMinY: dataMinY,
      dataMaxY: dataMaxY,
      yAxisConfig: widget.yAxis,
    );

    // Calculate chart area margins using shared utility
    final config = widget.config ?? const FusionChartConfiguration();
    final margins = FusionMarginCalculator.calculate(
      enableAxis: config.enableAxis,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
      minX: xBounds.minX,
      maxX: xBounds.maxX,
      minY: yBounds.minY,
      maxY: yBounds.maxY,
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
      dataXMin: xBounds.minX,
      dataXMax: xBounds.maxX,
      dataYMin: yBounds.minY,
      dataYMax: yBounds.maxY,
      devicePixelRatio: dpr,
    );

    // ALWAYS update interactive state - this is critical for responsiveness
    _interactiveState.updateCoordinateSystem(_coordSystem!);
  }
}

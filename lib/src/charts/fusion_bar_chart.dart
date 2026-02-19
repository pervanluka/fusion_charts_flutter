import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/rendering/painters/fusion_bar_chart_painter.dart';

import '../configuration/fusion_axis_configuration.dart';
import '../configuration/fusion_bar_chart_configuration.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_crosshair_configuration.dart';
import '../configuration/fusion_pan_configuration.dart';
import '../configuration/fusion_tooltip_configuration.dart';
import '../configuration/fusion_zoom_configuration.dart';
import '../controllers/fusion_chart_controller.dart';
import '../data/fusion_data_point.dart';
import '../live/fusion_live_chart_controller.dart';
import '../live/live_viewport_mode.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/layers/fusion_selection_rect_layer.dart';
import '../series/fusion_bar_series.dart';
import '../utils/chart_bounds_calculator.dart';
import '../utils/fusion_margin_calculator.dart';
import 'base/fusion_chart_header.dart';
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
///   config: FusionBarChartConfiguration(
///     enableSideBySideSeriesPlacement: true,
///     barWidthRatio: 0.8,
///   ),
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
    this.onBarTap,
    this.onBarLongPress,
  }) : assert(series.length > 0, 'At least one series is required');

  /// All bar series to display.
  final List<FusionBarSeries> series;

  /// Chart configuration with bar-specific settings.
  ///
  /// Use [FusionBarChartConfiguration] for full type-safe access
  /// to bar-specific options like:
  /// - `enableSideBySideSeriesPlacement` - Grouped vs overlapped bars
  /// - `barWidthRatio` - Bar width relative to category space
  /// - `barSpacing` - Spacing between grouped bars
  /// - `borderRadius` - Rounded corners
  ///
  /// Also accepts base [FusionChartConfiguration] for shared settings only.
  final FusionChartConfiguration? config;

  /// X-axis configuration.
  final FusionAxisConfiguration? xAxis;

  /// Y-axis configuration.
  final FusionAxisConfiguration? yAxis;

  /// Optional chart title.
  final String? title;

  /// Optional chart subtitle.
  final String? subtitle;

  /// Controller for programmatic zoom/pan control.
  final FusionChartController? controller;

  /// Controller for live/real-time data streaming.
  ///
  /// When provided, data points are pulled from this controller instead of
  /// the static [series] data. The series objects still define styling
  /// (color, bar width, name), but data comes from the controller.
  ///
  /// Example:
  /// ```dart
  /// final liveController = FusionLiveChartController(
  ///   retentionPolicy: RetentionPolicy.rollingCount(100),
  /// );
  ///
  /// // Add data from any source
  /// timer = Timer.periodic(Duration(seconds: 1), (_) {
  ///   liveController.addPoint('sales', FusionDataPoint(index++, randomValue()));
  /// });
  ///
  /// FusionBarChart(
  ///   liveController: liveController,
  ///   series: [FusionBarSeries(name: 'sales', color: Colors.blue)],
  /// )
  /// ```
  final FusionLiveChartController? liveController;

  /// Viewport behavior for live data mode.
  ///
  /// Defaults to [AutoScrollPointsViewport] with 10 visible points.
  /// Only used when [liveController] is provided.
  final LiveViewportMode? liveViewportMode;

  /// Callback when a bar is tapped.
  final void Function(FusionDataPoint point, String seriesName)? onBarTap;

  /// Callback when a bar is long-pressed.
  final void Function(FusionDataPoint point, String seriesName)? onBarLongPress;

  /// Whether this chart is in live mode.
  bool get isLiveMode => liveController != null;

  @override
  State<FusionBarChart> createState() => _FusionBarChartState();
}

class _FusionBarChartState extends State<FusionBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FusionBarInteractiveState _interactiveState;
  final FusionPaintPool _paintPool = FusionPaintPool();
  final FusionShaderCache _shaderCache = FusionShaderCache();

  FusionCoordinateSystem? _coordSystem;

  Size? _cachedSize;
  int? _cachedSeriesHash;
  FusionCoordinateSystem? _cachedCoordSystem;

  /// Cached series with live data merged in.
  List<FusionBarSeries>? _liveSeries;

  /// Whether user has interacted (pausing auto-scroll).
  bool _userInteracted = false;

  /// Gets the bar-specific configuration or defaults.
  FusionBarChartConfiguration get _barConfig {
    final config = widget.config;
    if (config is FusionBarChartConfiguration) {
      return config;
    }
    // Wrap base config with bar defaults
    return FusionBarChartConfiguration(
      theme: config?.theme,
      tooltipBehavior: config?.tooltipBehavior ?? const FusionTooltipBehavior(),
      crosshairBehavior:
          config?.crosshairBehavior ?? const FusionCrosshairConfiguration(),
      zoomBehavior: config?.zoomBehavior ?? const FusionZoomConfiguration(),
      panBehavior: config?.panBehavior ?? const FusionPanConfiguration(),
      enableAnimation: config?.enableAnimation ?? true,
      enableTooltip: config?.enableTooltip ?? true,
      enableCrosshair: config?.enableCrosshair ?? true,
      enableZoom: config?.enableZoom ?? false,
      enablePanning: config?.enablePanning ?? false,
      enableSelection: config?.enableSelection ?? true,
      enableLegend: config?.enableLegend ?? true,
      enableDataLabels: config?.enableDataLabels ?? false,
      enableGrid: config?.enableGrid ?? true,
      enableAxis: config?.enableAxis ?? true,
      padding: config?.padding ?? const EdgeInsets.all(4),
      animationDuration: config?.animationDuration,
      animationCurve: config?.animationCurve,
    );
  }

  /// Get the effective series (with live data if in live mode).
  List<FusionBarSeries> get _effectiveSeries {
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

    // Invalidate coordinate system cache
    _cachedCoordSystem = null;
    _cachedSeriesHash = null;

    // Update coordinate system for auto-scroll
    if (widget.isLiveMode && !_userInteracted) {
      _updateLiveViewport();
    }

    setState(() {});
  }

  /// Update viewport for live data auto-scroll.
  void _updateLiveViewport() {
    if (!widget.isLiveMode || _coordSystem == null) return;

    final controller = widget.liveController!;
    // Bar charts default to point-based scrolling since they're typically category-based
    final viewportMode =
        widget.liveViewportMode ??
        const LiveViewportMode.autoScrollPoints(visiblePoints: 10);

    // For bar charts, we use index-based positioning
    final effectiveSeries = _effectiveSeries;
    if (effectiveSeries.isEmpty) return;

    // Get the number of points in the first series (all series should have same length)
    final pointCount = effectiveSeries.first.dataPoints.length;
    if (pointCount == 0) return;

    switch (viewportMode) {
      case AutoScrollViewport(
        visibleDuration: final duration,
        leadingPadding: final leading,
      ):
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
        // For bar charts, use index-based positioning
        final endIndex = pointCount - 1 + leading;
        final startIndex = (endIndex - count + 1).clamp(0, endIndex);

        final minX = startIndex - 0.5;
        final maxX = endIndex + 0.5;

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

        // Get the latest data point
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

        final visibleMs = duration.inMilliseconds.toDouble();
        final leadingMs = leading.inMilliseconds.toDouble();

        final maxX = latestX + leadingMs;
        final minX = maxX - visibleMs;

        _interactiveState.setViewportRange(minX: minX, maxX: maxX);

      case FillThenScrollViewport(
        maxDuration: final maxDuration,
        leadingPadding: final leading,
      ):
        // Get oldest and latest points
        double? oldestX;
        double? latestX;
        for (final series in widget.series) {
          final oldest = controller.getOldestPoint(series.name);
          final latest = controller.getLatestPoint(series.name);
          if (oldest != null) {
            if (oldestX == null || oldest.x < oldestX) {
              oldestX = oldest.x;
            }
          }
          if (latest != null) {
            if (latestX == null || latest.x > latestX) {
              latestX = latest.x;
            }
          }
        }

        if (oldestX == null || latestX == null) return;

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
    final config = _barConfig;

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
    _coordSystem = _createPlaceholderCoordSystem();
    final config = _barConfig;

    _interactiveState = FusionBarInteractiveState(
      config: config,
      initialCoordSystem: _coordSystem!,
      series: _effectiveSeries,
      enableSideBySideSeriesPlacement: config.enableSideBySideSeriesPlacement,
    );
    _interactiveState.initialize();
    _interactiveState.addListener(_onInteractionChanged);
  }

  FusionCoordinateSystem _createPlaceholderCoordSystem() {
    final maxY = _getMaxYValue();
    final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
      dataMinY: 0,
      dataMaxY: maxY,
      yAxisConfig: widget.yAxis,
      startFromZero: true,
    );

    return FusionCoordinateSystem(
      chartArea: const Rect.fromLTWH(60, 10, 300, 200),
      dataXMin: -0.5,
      dataXMax: _getMaxPointCount() - 0.5,
      dataYMin: yBounds.minY,
      dataYMax: yBounds.maxY,
    );
  }

  int _getMaxPointCount() {
    int max = 0;
    final effectiveSeries = _effectiveSeries;
    for (final series in effectiveSeries) {
      if (series.dataPoints.length > max) {
        max = series.dataPoints.length;
      }
    }
    return max > 0 ? max : 1;
  }

  double _getMaxYValue() {
    double max = 0;
    final effectiveSeries = _effectiveSeries;
    for (final series in effectiveSeries) {
      for (final point in series.dataPoints) {
        if (point.y > max) max = point.y;
      }
    }
    return max > 0 ? max : 100;
  }

  void _onInteractionChanged() {
    // Track user interaction for AutoScrollUntilInteraction mode
    if (widget.isLiveMode && !_userInteracted) {
      final viewportMode = widget.liveViewportMode;
      if (viewportMode is AutoScrollUntilInteractionViewport) {
        // Check if this is a zoom/pan interaction (not just tooltip/crosshair)
        if (_interactiveState.isInteracting) {
          _userInteracted = true;
        }
      }
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(FusionBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle live controller changes
    if (widget.liveController != oldWidget.liveController) {
      oldWidget.liveController?.removeListener(_onLiveDataChanged);
      widget.liveController?.addListener(_onLiveDataChanged);
      _liveSeries = null; // Invalidate cache
    }

    if (widget.series != oldWidget.series ||
        widget.config != oldWidget.config) {
      _cachedCoordSystem = null;
      _cachedSeriesHash = null;
      _liveSeries = null; // Invalidate cache

      // Only animate for non-live mode or significant series changes
      if (!widget.isLiveMode) {
        _animationController.reset();
        _animationController.forward();
      }

      _detachController();
      _interactiveState.dispose();
      _initInteractiveState();
      _attachController();
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
    final config = _barConfig;
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
                    _updateCoordinateSystem(size);

                    if (_coordSystem != null) {
                      _interactiveState.updateCoordinateSystem(_coordSystem!);
                    }

                    return MouseRegion(
                      onExit: _interactiveState.handlePointerExit,
                      child: Listener(
                        onPointerDown: _interactiveState.handlePointerDown,
                        onPointerMove: _interactiveState.handlePointerMove,
                        onPointerUp: _interactiveState.handlePointerUp,
                        onPointerCancel: _interactiveState.handlePointerCancel,
                        onPointerHover: _interactiveState.handlePointerHover,
                        onPointerSignal: _interactiveState.handlePointerSignal,
                        child: RawGestureDetector(
                          gestures: _interactiveState.getGestureRecognizers(),
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: size,
                                painter: FusionBarChartPainter(
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

  void _updateCoordinateSystem(Size size) {
    // Use effective series for live mode
    final effectiveSeries = _effectiveSeries;
    final seriesHash = _calculateSeriesHash(effectiveSeries);

    if (_cachedSize == size &&
        _cachedSeriesHash == seriesHash &&
        _cachedCoordSystem != null) {
      _coordSystem = _cachedCoordSystem;
      return;
    }

    final config = _barConfig;

    final allPoints = effectiveSeries
        .where((s) => s.visible)
        .expand((s) => s.dataPoints)
        .toList();

    if (allPoints.isEmpty) {
      _coordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(40, 10, size.width - 10, size.height - 30),
        dataXMin: -0.5,
        dataXMax: 0.5,
        dataYMin: 0,
        dataYMax: 100,
      );
      return;
    }

    // For bar charts, ALWAYS use index-based positioning (category axis)
    // X values are used for labels, not for positioning
    final pointCount = effectiveSeries.first.dataPoints.length;

    // Coordinate system: bars centered at 0, 1, 2, 3...
    const minX = -0.5;
    final maxX = pointCount - 0.5;

    // For margin calculation, use the actual label values (first and last x values)
    // This ensures proper overflow calculation for first/last labels
    final firstPoint = effectiveSeries.first.dataPoints.first;
    final lastPoint = effectiveSeries.first.dataPoints.last;
    final marginMinX = firstPoint.label != null ? 0.0 : firstPoint.x;
    final marginMaxX = lastPoint.label != null
        ? (pointCount - 1).toDouble()
        : lastPoint.x;

    // Calculate nice Y-axis bounds using shared utility
    final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
      dataMinY: 0,
      dataMaxY: allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b),
      yAxisConfig: widget.yAxis,
      startFromZero: true,
    );

    // Calculate dynamic margins based on axis labels
    final margins = FusionMarginCalculator.calculate(
      enableAxis: config.enableAxis,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
      minX: marginMinX,
      maxX: marginMaxX,
      minY: yBounds.minY,
      maxY: yBounds.maxY,
    );

    final chartArea = Rect.fromLTRB(
      margins.left,
      margins.top,
      size.width - margins.right,
      size.height - margins.bottom,
    );

    // Coordinate system uses index-based positioning
    _coordSystem = FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: minX,
      dataXMax: maxX,
      dataYMin: yBounds.minY,
      dataYMax: yBounds.maxY,
    );

    _cachedSize = size;
    _cachedSeriesHash = seriesHash;
    _cachedCoordSystem = _coordSystem;
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

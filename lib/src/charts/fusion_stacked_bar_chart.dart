import 'package:flutter/material.dart';

import '../configuration/fusion_axis_configuration.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_crosshair_configuration.dart';
import '../configuration/fusion_pan_configuration.dart';
import '../configuration/fusion_stacked_bar_chart_configuration.dart';
import '../configuration/fusion_stacked_tooltip_builder.dart';
import '../configuration/fusion_tooltip_configuration.dart';
import '../configuration/fusion_zoom_configuration.dart';
import '../controllers/fusion_chart_controller.dart';
import '../data/fusion_data_point.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/layers/fusion_selection_rect_layer.dart';
import '../rendering/painters/fusion_stacked_bar_chart_painter.dart';
import '../series/fusion_stacked_bar_series.dart';
import '../utils/chart_bounds_calculator.dart';
import '../utils/fusion_margin_calculator.dart';
import 'base/fusion_chart_header.dart';
import 'fusion_stacked_bar_interactive_state.dart';

/// A professional stacked bar chart widget.
///
/// Displays bars stacked on top of each other to show cumulative values
/// and individual contributions.
///
/// ## Features
///
/// - **Regular stacking**: Shows actual cumulative values
/// - **100% stacking**: Normalizes to 100% via config
/// - **Multiple groups**: Use `groupName` to create multiple stacks
/// - **Vertical/Horizontal**: Control via `isVertical` on series
/// - **Animations**: Smooth entry animations
/// - **Interactivity**: Multi-line tooltips showing all segments
/// - **Custom tooltips**: Full control over tooltip rendering
///
/// ## Example
///
/// ```dart
/// FusionStackedBarChart(
///   config: FusionStackedBarChartConfiguration(
///     isStacked100: false,
///     tooltipValueFormatter: (value, segment, info) {
///       return '\$${value.toStringAsFixed(0)}';
///     },
///   ),
///   series: [
///     FusionStackedBarSeries(
///       name: 'Product A',
///       dataPoints: [
///         FusionDataPoint(0, 30, label: 'Q1'),
///         FusionDataPoint(1, 40, label: 'Q2'),
///       ],
///       color: Colors.blue,
///     ),
///     FusionStackedBarSeries(
///       name: 'Product B',
///       dataPoints: [
///         FusionDataPoint(0, 20, label: 'Q1'),
///         FusionDataPoint(1, 25, label: 'Q2'),
///       ],
///       color: Colors.green,
///     ),
///   ],
/// )
/// ```
///
/// ## 100% Stacked Mode
///
/// ```dart
/// FusionStackedBarChart(
///   config: FusionStackedBarChartConfiguration(
///     isStacked100: true,
///   ),
///   series: [...],
/// )
/// ```
class FusionStackedBarChart extends StatefulWidget {
  const FusionStackedBarChart({
    required this.series,
    super.key,
    this.config,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.controller,
    this.onBarTap,
    this.onBarLongPress,
  }) : assert(series.length > 0, 'At least one series is required');

  /// All stacked bar series to display.
  final List<FusionStackedBarSeries> series;

  /// Chart configuration with stacked bar-specific settings.
  ///
  /// Use [FusionStackedBarChartConfiguration] for full type-safe access
  /// to stacked bar specific options like:
  /// - `isStacked100` - Enable 100% stacking mode
  /// - `tooltipBuilder` - Custom tooltip widget
  /// - `tooltipValueFormatter` - Custom value formatting
  /// - `tooltipTotalFormatter` - Custom total formatting
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

  /// Callback when a bar segment is tapped.
  final void Function(FusionDataPoint point, String seriesName)? onBarTap;

  /// Callback when a bar segment is long-pressed.
  final void Function(FusionDataPoint point, String seriesName)? onBarLongPress;

  @override
  State<FusionStackedBarChart> createState() => _FusionStackedBarChartState();
}

class _FusionStackedBarChartState extends State<FusionStackedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FusionStackedBarInteractiveState _interactiveState;
  final FusionPaintPool _paintPool = FusionPaintPool();
  final FusionShaderCache _shaderCache = FusionShaderCache();

  FusionCoordinateSystem? _coordSystem;
  Size? _cachedSize;
  int? _cachedSeriesHash;

  /// Gets the stacked bar specific configuration or defaults.
  FusionStackedBarChartConfiguration get _stackedConfig {
    final config = widget.config;
    if (config is FusionStackedBarChartConfiguration) {
      return config;
    }
    // Wrap base config with stacked defaults
    return FusionStackedBarChartConfiguration(
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

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initInteractiveState();
    _attachController();
  }

  void _attachController() {
    widget.controller?.attach(_interactiveState);
  }

  void _detachController() {
    widget.controller?.detach();
  }

  void _initAnimation() {
    final config = _stackedConfig;

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
    final config = _stackedConfig;
    _coordSystem = _createPlaceholderCoordSystem();

    _interactiveState = FusionStackedBarInteractiveState(
      config: config,
      initialCoordSystem: _coordSystem!,
      series: widget.series,
      isStacked100: config.isStacked100,
    );
    _interactiveState.initialize();
    _interactiveState.addListener(_onInteractionChanged);
  }

  FusionCoordinateSystem _createPlaceholderCoordSystem() {
    final config = _stackedConfig;
    final stackedMaxY = _getStackedMaxY();

    double niceMaxY;
    if (config.isStacked100) {
      niceMaxY = 100.0;
    } else {
      final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
        dataMinY: 0,
        dataMaxY: stackedMaxY,
        yAxisConfig: widget.yAxis,
        startFromZero: true,
      );
      niceMaxY = yBounds.maxY;
    }

    return FusionCoordinateSystem(
      chartArea: const Rect.fromLTWH(60, 10, 300, 200),
      dataXMin: -0.5,
      dataXMax: _getMaxPointCount() - 0.5,
      dataYMin: 0,
      dataYMax: niceMaxY,
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

  double _getStackedMaxY() {
    if (widget.series.isEmpty) return 100;

    final pointCount = widget.series.first.dataPoints.length;
    double maxSum = 0;

    for (int i = 0; i < pointCount; i++) {
      double sum = 0;
      for (final series in widget.series) {
        if (i < series.dataPoints.length) {
          sum += series.dataPoints[i].y;
        }
      }
      if (sum > maxSum) maxSum = sum;
    }

    return maxSum > 0 ? maxSum : 100;
  }

  void _onInteractionChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(FusionStackedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.series != oldWidget.series ||
        widget.config != oldWidget.config) {
      _cachedSize = null;
      _cachedSeriesHash = null;

      _animationController.reset();
      _animationController.forward();

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
    _animationController.dispose();
    _interactiveState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _stackedConfig;
    final theme = config.theme;
    final title = widget.title;
    final subtitle = widget.subtitle;
    final hasCustomBuilder = config.tooltipBuilder != null;

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

                    // Build the chart
                    Widget chartWidget = Listener(
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
                              painter: FusionStackedBarChartPainter(
                                series: widget.series,
                                coordSystem: _interactiveState.coordSystem,
                                theme: theme,
                                xAxis: widget.xAxis,
                                yAxis: widget.yAxis,
                                animationProgress: _animation.value,
                                // Only pass tooltip data if NOT using custom builder
                                stackedTooltipData: hasCustomBuilder
                                    ? null
                                    : _interactiveState.tooltipData,
                                crosshairPosition: null,
                                crosshairPoint: null,
                                config: config,
                                paintPool: _paintPool,
                                shaderCache: _shaderCache,
                                isStacked100: config.isStacked100,
                                tooltipValueFormatter: config.tooltipValueFormatter,
                                tooltipTotalFormatter: config.tooltipTotalFormatter,
                              ),
                            ),
                            // Selection rectangle overlay
                            if (_interactiveState.selectionRect != null)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: FusionSelectionRectLayer(
                                    selectionRect: _interactiveState.selectionRect!,
                                    fillColor: theme.primaryColor.withValues(alpha: 0.1),
                                    borderColor: theme.primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );

                    // If custom builder, wrap with Stack for overlay tooltip
                    if (hasCustomBuilder) {
                      chartWidget = Stack(
                        clipBehavior: Clip.none,
                        children: [
                          chartWidget,
                          if (_interactiveState.tooltipData != null)
                            _buildCustomTooltip(
                              context,
                              _interactiveState.tooltipData!,
                              config,
                            ),
                        ],
                      );
                    }

                    return chartWidget;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a custom tooltip widget using the builder.
  Widget _buildCustomTooltip(
    BuildContext context,
    StackedTooltipData data,
    FusionStackedBarChartConfiguration config,
  ) {
    final info = FusionStackedTooltipInfo(
      categoryIndex: 0,
      categoryLabel: data.categoryLabel,
      segments: data.segments
          .map(
            (s) => FusionStackedSegment(
              seriesName: s.seriesName,
              color: s.seriesColor,
              value: s.value,
              percentage: s.percentage,
            ),
          )
          .toList(),
      totalValue: data.totalValue,
      isStacked100: config.isStacked100,
      hitSegmentIndex: data.hitSegmentIndex,
    );

    final customWidget = config.tooltipBuilder!(context, info);
    if (customWidget == null) {
      return const SizedBox.shrink();
    }

    // Position the custom tooltip
    return Positioned(
      left: data.screenPosition.dx,
      top: data.screenPosition.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -1.1),
        child: customWidget,
      ),
    );
  }

  void _updateCoordinateSystem(Size size) {
    final seriesHash = _calculateSeriesHash();

    if (_cachedSize == size &&
        _cachedSeriesHash == seriesHash &&
        _coordSystem != null) {
      return;
    }

    final config = _stackedConfig;

    final pointCount = widget.series.isNotEmpty
        ? widget.series.first.dataPoints.length
        : 1;

    // Coordinate system uses -0.5 to pointCount-0.5 for bar centering
    const minX = -0.5;
    final maxX = pointCount - 0.5;
    const minY = 0.0;

    // Calculate nice Y-axis bounds using shared utility
    double maxY;
    if (config.isStacked100) {
      maxY = 100.0;
    } else {
      final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
        dataMinY: 0,
        dataMaxY: _getStackedMaxY(),
        yAxisConfig: widget.yAxis,
        startFromZero: true,
      );
      maxY = yBounds.maxY;
    }

    // For margin calculation, use actual label positions (0 to pointCount-1)
    // This ensures correct label width calculations
    const marginMinX = 0.0;
    final marginMaxX = (pointCount - 1).toDouble();

    // Calculate dynamic margins based on axis labels
    final margins = FusionMarginCalculator.calculate(
      enableAxis: config.enableAxis,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
      minX: marginMinX,
      maxX: marginMaxX,
      minY: minY,
      maxY: maxY,
    );

    final chartArea = Rect.fromLTRB(
      margins.left,
      margins.top,
      size.width - margins.right,
      size.height - margins.bottom,
    );

    _coordSystem = FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: minX,
      dataXMax: maxX,
      dataYMin: minY,
      dataYMax: maxY,
    );

    _cachedSize = size;
    _cachedSeriesHash = seriesHash;
  }

  int _calculateSeriesHash() {
    final config = _stackedConfig;
    int hash = config.isStacked100.hashCode;
    for (final s in widget.series) {
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

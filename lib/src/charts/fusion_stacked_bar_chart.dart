import 'package:flutter/material.dart';
import '../series/fusion_stacked_bar_series.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_axis_configuration.dart';
import '../configuration/fusion_stacked_tooltip_builder.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/painters/fusion_stacked_bar_chart_painter.dart';
import '../rendering/engine/fusion_paint_pool.dart';
import '../rendering/engine/fusion_shader_cache.dart';
import 'fusion_stacked_bar_interactive_state.dart';

/// A professional stacked bar chart widget.
///
/// Displays bars stacked on top of each other to show cumulative values
/// and individual contributions.
///
/// ## Features
///
/// - **Regular stacking**: Shows actual cumulative values
/// - **100% stacking**: Normalizes to 100% (set `isStacked100: true`)
/// - **Multiple groups**: Use `groupName` to create multiple stacks
/// - **Vertical/Horizontal**: Control via `isVertical` on series
/// - **Animations**: Smooth entry animations
/// - **Interactivity**: Multi-line tooltips showing all segments
///
/// ## Example
///
/// ```dart
/// FusionStackedBarChart(
///   series: [
///     FusionStackedBarSeries(
///       name: 'Product A',
///       dataPoints: [
///         FusionDataPoint(0, 30, label: 'Q1'),
///         FusionDataPoint(1, 40, label: 'Q2'),
///         FusionDataPoint(2, 35, label: 'Q3'),
///       ],
///       color: Colors.blue,
///     ),
///     FusionStackedBarSeries(
///       name: 'Product B',
///       dataPoints: [
///         FusionDataPoint(0, 20, label: 'Q1'),
///         FusionDataPoint(1, 25, label: 'Q2'),
///         FusionDataPoint(2, 30, label: 'Q3'),
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
///   isStacked100: true,  // Enable 100% mode
///   series: [...],
/// )
/// ```
class FusionStackedBarChart extends StatefulWidget {
  const FusionStackedBarChart({
    super.key,
    required this.series,
    this.config,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.isStacked100 = false,
    this.tooltipBuilder,
    this.tooltipValueFormatter,
    this.tooltipTotalFormatter,
    this.onBarTap,
    this.onBarLongPress,
  }) : assert(series.length > 0, 'At least one series is required');

  /// All stacked bar series to display.
  final List<FusionStackedBarSeries> series;

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

  /// Whether to use 100% stacking (normalize to 100%).
  final bool isStacked100;

  /// Custom builder for the tooltip widget.
  ///
  /// If provided, gives complete control over tooltip rendering.
  /// Return null from the builder to use default rendering.
  ///
  /// ## Example
  ///
  /// ```dart
  /// FusionStackedBarChart(
  ///   tooltipBuilder: (context, info) {
  ///     return Card(
  ///       child: Padding(
  ///         padding: EdgeInsets.all(8),
  ///         child: Column(
  ///           mainAxisSize: MainAxisSize.min,
  ///           children: info.segments.map((s) =>
  ///             Text('${s.seriesName}: ${s.value}')
  ///           ).toList(),
  ///         ),
  ///       ),
  ///     );
  ///   },
  /// )
  /// ```
  final FusionStackedTooltipBuilder? tooltipBuilder;

  /// Formatter for segment values in the default tooltip.
  ///
  /// Only used when [tooltipBuilder] is not provided.
  ///
  /// ## Example
  ///
  /// ```dart
  /// FusionStackedBarChart(
  ///   tooltipValueFormatter: (value, segment, info) {
  ///     return '\${value.toStringAsFixed(2)}';
  ///   },
  /// )
  /// ```
  final FusionStackedValueFormatter? tooltipValueFormatter;

  /// Formatter for the total line in the default tooltip.
  ///
  /// Only used when [tooltipBuilder] is not provided.
  /// Return null to hide the total line.
  ///
  /// ## Example
  ///
  /// ```dart
  /// FusionStackedBarChart(
  ///   tooltipTotalFormatter: (total, info) {
  ///     return 'Total: \${total.toStringAsFixed(0)}';
  ///   },
  /// )
  /// ```
  final FusionStackedTotalFormatter? tooltipTotalFormatter;

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

    _interactiveState = FusionStackedBarInteractiveState(
      config: config,
      initialCoordSystem: _coordSystem!,
      series: widget.series,
      isStacked100: widget.isStacked100,
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
      dataYMax: widget.isStacked100 ? 100 : _getStackedMaxY() * 1.1,
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
        widget.isStacked100 != oldWidget.isStacked100 ||
        widget.config != oldWidget.config) {
      _cachedSize = null;
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
    final hasCustomBuilder = widget.tooltipBuilder != null;

    return Padding(
      padding: config.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) _buildTitle(title),
          if (subtitle != null) _buildSubtitle(subtitle),
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

                    // Build the chart
                    Widget chartWidget = Listener(
                      onPointerDown: _interactiveState.handlePointerDown,
                      onPointerMove: _interactiveState.handlePointerMove,
                      onPointerUp: _interactiveState.handlePointerUp,
                      onPointerCancel: _interactiveState.handlePointerCancel,
                      onPointerHover: _interactiveState.handlePointerHover,
                      child: RawGestureDetector(
                        gestures: _interactiveState.getGestureRecognizers(),
                        child: CustomPaint(
                          size: size,
                          painter: FusionStackedBarChartPainter(
                            series: widget.series,
                            coordSystem: _coordSystem!,
                            theme: config.theme,
                            xAxis: widget.xAxis,
                            yAxis: widget.yAxis,
                            animationProgress: _animation.value,
                            // Only pass tooltip data if NOT using custom builder
                            stackedTooltipData: hasCustomBuilder ? null : _interactiveState.tooltipData,
                            crosshairPosition: null,
                            crosshairPoint: null,
                            config: config,
                            paintPool: _paintPool,
                            shaderCache: _shaderCache,
                            isStacked100: widget.isStacked100,
                            tooltipValueFormatter: widget.tooltipValueFormatter,
                            tooltipTotalFormatter: widget.tooltipTotalFormatter,
                          ),
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
                            _buildCustomTooltip(context, _interactiveState.tooltipData!),
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
  Widget _buildCustomTooltip(BuildContext context, StackedTooltipData data) {
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
      isStacked100: data.isStacked100,
      hitSegmentIndex: data.hitSegmentIndex,
    );

    final customWidget = widget.tooltipBuilder!(context, info);
    if (customWidget == null) {
      // Builder returned null, use default (but we already skipped it)
      return const SizedBox.shrink();
    }

    // Position the custom tooltip
    return Positioned(
      left: data.screenPosition.dx,
      top: data.screenPosition.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -1.1), // Center above the point
        child: customWidget,
      ),
    );
  }

  void _updateCoordinateSystem(Size size) {
    final seriesHash = _calculateSeriesHash();

    if (_cachedSize == size && _cachedSeriesHash == seriesHash && _coordSystem != null) {
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

    final pointCount = widget.series.isNotEmpty ? widget.series.first.dataPoints.length : 1;

    final minX = -0.5;
    final maxX = pointCount - 0.5;
    final minY = 0.0;
    final maxY = widget.isStacked100 ? 100.0 : _getStackedMaxY() * 1.1;

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
    int hash = widget.isStacked100.hashCode;
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

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../configuration/fusion_pie_chart_configuration.dart';
import '../../data/fusion_data_point.dart';
import '../../rendering/engine/fusion_paint_pool.dart';
import '../../rendering/layers/fusion_pie_tooltip_layer.dart';
import '../../series/fusion_pie_series.dart';
import '../../themes/fusion_chart_theme.dart';
import '../../utils/fusion_color_palette.dart';
import '../base/fusion_chart_header.dart';
import 'fusion_pie_chart_painter.dart';
import 'fusion_pie_interactive_state.dart';
import 'pie_tooltip_data.dart';

/// A professional pie and donut chart widget.
///
/// ## Features
///
/// - **Pie mode**: Solid filled wedges (default)
/// - **Donut mode**: Ring with configurable inner radius
/// - **Exploded segments**: Pull out individual slices
/// - **Rich tooltips**: Full [FusionTooltipBehavior] integration
/// - **Selection**: Single, multiple, or toggle modes
/// - **Hover effects**: Scale and elevation (desktop/web)
/// - **Labels**: Inside, outside with connectors, or legend only
/// - **Center widget**: Custom content in donut hole
/// - **Animations**: Sweep, scale, fade
/// - **Gradients**: Per-slice or radial
/// - **Shadows**: Configurable depth
/// - **Sorting**: None, ascending, descending
/// - **Grouping**: Merge small segments into "Other"
///
/// ## Tooltip Behavior
///
/// The pie chart fully integrates with [FusionTooltipBehavior]:
///
/// ```dart
/// FusionPieChart(
///   series: myPieSeries,
///   config: FusionPieChartConfiguration(
///     tooltipBehavior: FusionTooltipBehavior(
///       activationMode: FusionTooltipActivationMode.hover,
///       dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
///       dismissDelay: Duration(milliseconds: 500),
///       position: FusionTooltipPosition.floating,
///       hapticFeedback: true,
///       elevation: 4.0,
///       opacity: 0.95,
///     ),
///   ),
/// )
/// ```
///
/// ## Example
///
/// ```dart
/// FusionPieChart(
///   series: FusionPieSeries(
///     dataPoints: [
///       FusionPieDataPoint(35, label: 'Sales', color: Colors.blue),
///       FusionPieDataPoint(25, label: 'Marketing', color: Colors.green),
///       FusionPieDataPoint(20, label: 'Engineering', color: Colors.orange),
///       FusionPieDataPoint(20, label: 'Support', color: Colors.purple),
///     ],
///   ),
///   config: FusionPieChartConfiguration(
///     innerRadiusPercent: 0.5, // Donut mode
///     labelPosition: PieLabelPosition.outside,
///     enableSelection: true,
///   ),
/// )
/// ```
class FusionPieChart extends StatefulWidget {
  /// Creates a pie chart.
  const FusionPieChart({
    required this.series,
    super.key,
    this.config,
    this.title,
    this.subtitle,
    this.onSegmentTap,
    this.onSegmentLongPress,
    this.onSelectionChanged,
  });

  /// The pie series data.
  final FusionPieSeries series;

  /// Chart configuration.
  ///
  /// If null, uses default [FusionPieChartConfiguration].
  final FusionPieChartConfiguration? config;

  /// Optional chart title.
  final String? title;

  /// Optional chart subtitle.
  final String? subtitle;

  /// Callback when a segment is tapped.
  final void Function(int index, FusionPieSeries series)? onSegmentTap;

  /// Callback when a segment is long-pressed.
  final void Function(int index, FusionPieSeries series)? onSegmentLongPress;

  /// Callback when selection changes.
  final void Function(Set<int> selectedIndices)? onSelectionChanged;

  @override
  State<FusionPieChart> createState() => _FusionPieChartState();
}

class _FusionPieChartState extends State<FusionPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FusionPieInteractiveState _interactiveState;

  final FusionPaintPool _paintPool = FusionPaintPool();

  /// Gets the effective configuration.
  FusionPieChartConfiguration get _config =>
      widget.config ?? const FusionPieChartConfiguration();

  /// Gets the theme.
  FusionChartTheme get _theme => _config.theme;

  /// Gets the color palette.
  FusionColorPalette get _palette =>
      widget.series.colorPalette ?? FusionColorPalette.material;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initInteractiveState();
  }

  void _initAnimation() {
    final duration = _config.enableAnimation
        ? _config.effectiveAnimationDuration
        : Duration.zero;

    _animationController = AnimationController(duration: duration, vsync: this);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: _config.effectiveAnimationCurve,
    );

    if (_config.enableAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  void _initInteractiveState() {
    _interactiveState = FusionPieInteractiveState(
      config: _config,
      series: widget.series,
      palette: _palette,
      onSegmentTap: widget.onSegmentTap,
      onSegmentLongPress: widget.onSegmentLongPress,
      onSelectionChanged: widget.onSelectionChanged,
    );
    _interactiveState.initialize();
    _interactiveState.addListener(_onInteractionChanged);
  }

  void _onInteractionChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(FusionPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.series != oldWidget.series ||
        widget.config != oldWidget.config) {
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
    final title = widget.title;
    final subtitle = widget.subtitle;

    return Padding(
      padding: _config.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) FusionChartTitle(title: title, theme: _theme),
          if (subtitle != null)
            FusionChartSubtitle(subtitle: subtitle, theme: _theme),
          Expanded(child: _buildChartArea()),
        ],
      ),
    );
  }

  Widget _buildChartArea() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            // Calculate layout
            final layout = _calculateLayout(size);

            // Update interactive state with layout
            _interactiveState.updateLayout(
              center: layout.center,
              availableRadius: layout.availableRadius,
              size: size,
            );

            return _buildInteractiveChart(size, layout);
          },
        );
      },
    );
  }

  Widget _buildInteractiveChart(Size size, _PieLayout layout) {
    final segments = _interactiveState.segments;
    final tooltipData = _interactiveState.tooltipData as PieTooltipData?;

    // Chart area for tooltip positioning
    final chartArea = Rect.fromCenter(
      center: layout.center,
      width: layout.availableRadius * 2,
      height: layout.availableRadius * 2,
    );

    // Build all layers in correct z-order (bottom to top)
    final List<Widget> layers = [];

    // 1. Main chart painter (bottom)
    layers.add(
      CustomPaint(
        size: size,
        painter: FusionPieChartPainter(
          segments: segments,
          center: layout.center,
          innerRadius: layout.innerRadius,
          outerRadius: layout.outerRadius,
          series: widget.series,
          theme: _theme,
          config: _config,
          paintPool: _paintPool,
          animationProgress: _animation.value,
          selectedIndices: _interactiveState.selectedIndices,
          hoveredIndex: _interactiveState.hoveredIndex,
        ),
      ),
    );

    // 2. Center widget from series (for donut)
    if (widget.series.isDonut && widget.series.centerWidget != null) {
      layers.add(
        Positioned(
          left: layout.center.dx - layout.innerRadius,
          top: layout.center.dy - layout.innerRadius,
          width: layout.innerRadius * 2,
          height: layout.innerRadius * 2,
          child: Center(child: widget.series.centerWidget),
        ),
      );
    }

    // 3. Center widget from config (for donut)
    if (_config.isDonut && _config.centerWidget != null) {
      layers.add(
        Positioned(
          left: layout.center.dx - layout.innerRadius,
          top: layout.center.dy - layout.innerRadius,
          width: layout.innerRadius * 2,
          height: layout.innerRadius * 2,
          child: Center(child: _config.centerWidget),
        ),
      );
    }

    // 4. Center label for donut
    if (_config.isDonut && _config.showCenterLabel) {
      layers.add(
        Positioned(
          left: layout.center.dx - layout.innerRadius,
          top: layout.center.dy - layout.innerRadius,
          width: layout.innerRadius * 2,
          height: layout.innerRadius * 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_config.centerLabelText != null)
                      Text(
                        _config.centerLabelText!,
                        style: _config.centerLabelStyle ?? _theme.titleStyle,
                        textAlign: TextAlign.center,
                      ),
                    if (_config.centerSubLabelText != null)
                      Text(
                        _config.centerSubLabelText!,
                        style:
                            _config.centerSubLabelStyle ?? _theme.subtitleStyle,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 5. Tooltip layer (TOP - always visible over everything)
    if (_config.enableTooltip && tooltipData != null) {
      layers.add(
        CustomPaint(
          size: size,
          painter: FusionPieTooltipLayer(
            tooltipData: tooltipData,
            tooltipBehavior: _config.tooltipBehavior,
            pieConfig: _config,
            theme: _theme,
            tooltipOpacity: _interactiveState.tooltipOpacity,
            chartArea: chartArea,
          ),
        ),
      );
    }

    // 6. Custom tooltip builder (widget-based, topmost)
    if (_config.enableTooltip &&
        tooltipData != null &&
        _config.tooltipBehavior.builder != null) {
      layers.add(
        Positioned(
          left: tooltipData.screenPosition.dx,
          top: tooltipData.screenPosition.dy - 50,
          child: _config.tooltipBehavior.builder!(
            context,
            _createFakeDataPoint(tooltipData),
            tooltipData.label ?? 'Segment ${tooltipData.index}',
            tooltipData.color,
          ),
        ),
      );
    }

    // Wrap in gesture handlers
    Widget chart = Listener(
      onPointerDown: _interactiveState.handlePointerDown,
      onPointerMove: _interactiveState.handlePointerMove,
      onPointerUp: _interactiveState.handlePointerUp,
      onPointerCancel: _interactiveState.handlePointerCancel,
      onPointerHover: _interactiveState.handlePointerHover,
      child: RawGestureDetector(
        gestures: _interactiveState.getGestureRecognizers(),
        child: Stack(children: layers),
      ),
    );

    // Add legend if enabled
    if (_config.enableLegend && _config.legendPosition != LegendPosition.none) {
      chart = _buildWithLegend(chart, size);
    }

    return chart;
  }

  /// Creates a fake FusionDataPoint for the custom builder API compatibility.
  FusionDataPoint _createFakeDataPoint(PieTooltipData data) {
    return FusionDataPoint(
      data.index.toDouble(),
      data.value,
      label: data.label,
    );
  }

  _PieLayout _calculateLayout(Size size) {
    final padding = _config.chartPadding;

    // Minimum chart radius to be useful
    const minChartRadius = 40.0;

    // Calculate base available space first (without label space)
    double baseAvailableWidth = size.width - padding.horizontal;
    double baseAvailableHeight = size.height - padding.vertical;

    // Account for legend
    double legendSpace = 0;
    if (_config.enableLegend) {
      switch (_config.legendPosition) {
        case LegendPosition.left:
        case LegendPosition.right:
          legendSpace = _config.effectiveLegendWidth(_theme);
          baseAvailableWidth -= legendSpace + _config.legendSpacing;
        case LegendPosition.top:
        case LegendPosition.bottom:
          legendSpace = _config.effectiveLegendHeight(_theme);
          baseAvailableHeight -= legendSpace + _config.legendSpacing;
        case LegendPosition.none:
          break;
      }
    }

    // Calculate what label space WOULD be needed
    final hasOutsideLabels = _config.labelPosition == PieLabelPosition.outside;
    final idealLabelSpace = hasOutsideLabels
        ? _config.labelConnectorLength + 60
        : 0.0;

    // Check if we can afford full label space while maintaining minimum chart size
    final availableWithLabels = math.min(
      baseAvailableWidth - idealLabelSpace * 2,
      baseAvailableHeight - idealLabelSpace * 2,
    );

    // Adaptive label space: only reserve if chart would still be usable
    double labelSpace;
    if (availableWithLabels / 2 >= minChartRadius) {
      // Enough space for labels + decent chart
      labelSpace = idealLabelSpace;
    } else {
      // Not enough space - skip label reservation, painter will auto-hide them
      labelSpace = 0.0;
    }

    // Calculate final available space
    double availableWidth = baseAvailableWidth - labelSpace * 2;
    double availableHeight = baseAvailableHeight - labelSpace * 2;

    // Ensure non-negative
    availableWidth = math.max(availableWidth, 0);
    availableHeight = math.max(availableHeight, 0);

    // Calculate radius and center
    final maxRadius = math.min(availableWidth, availableHeight) / 2;
    final outerRadius = maxRadius * _config.outerRadiusPercent;
    final innerRadius = maxRadius * _config.innerRadiusPercent;

    // Calculate center position
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Adjust for legend
    switch (_config.legendPosition) {
      case LegendPosition.left:
        centerX += (legendSpace + _config.legendSpacing) / 2;
      case LegendPosition.right:
        centerX -= (legendSpace + _config.legendSpacing) / 2;
      case LegendPosition.top:
        centerY += (legendSpace + _config.legendSpacing) / 2;
      case LegendPosition.bottom:
        centerY -= (legendSpace + _config.legendSpacing) / 2;
      case LegendPosition.none:
        break;
    }

    return _PieLayout(
      center: Offset(centerX, centerY),
      availableRadius: maxRadius,
      outerRadius: outerRadius,
      innerRadius: innerRadius,
    );
  }

  Widget _buildWithLegend(Widget chart, Size size) {
    final legendWidget = _buildLegend();

    switch (_config.legendPosition) {
      case LegendPosition.right:
        return Row(
          children: [
            Expanded(child: chart),
            SizedBox(width: _config.legendSpacing),
            legendWidget,
          ],
        );
      case LegendPosition.left:
        return Row(
          children: [
            legendWidget,
            SizedBox(width: _config.legendSpacing),
            Expanded(child: chart),
          ],
        );
      case LegendPosition.top:
        return Column(
          children: [
            legendWidget,
            SizedBox(height: _config.legendSpacing),
            Expanded(child: chart),
          ],
        );
      case LegendPosition.bottom:
        return Column(
          children: [
            Expanded(child: chart),
            SizedBox(height: _config.legendSpacing),
            legendWidget,
          ],
        );
      case LegendPosition.none:
        return chart;
    }
  }

  Widget _buildLegend() {
    final segments = _interactiveState.segments;
    final isVertical =
        _config.legendPosition == LegendPosition.left ||
        _config.legendPosition == LegendPosition.right;

    final items = segments.map((segment) {
      return _LegendItem(
        color: segment.color,
        label: segment.label ?? 'Segment ${segment.index}',
        value: segment.value,
        percentage: segment.percentage,
        isSelected: _interactiveState.selectedIndices.contains(segment.index),
        iconSize: _config.legendIconSize,
        iconShape: _config.legendIconShape,
        textStyle: _config.legendTextStyle ?? _theme.legendStyle,
        valueTextStyle: _config.legendValueTextStyle ?? _theme.legendStyle,
        valueFontSizeRatio: _theme.legendValueFontSizeRatio,
        lineThickness: _theme.legendLineThickness,
        iconCornerRadius: _theme.legendIconCornerRadius,
        showValue: _config.showLegendValues,
        showPercentage: _config.showLegendPercentages,
        onTap: () {
          _interactiveState.selectSegment(segment.index);
        },
      );
    }).toList();

    if (isVertical) {
      return SizedBox(
        width: _config.effectiveLegendWidth(_theme),
        child: _config.legendScrollable
            ? ListView(
                shrinkWrap: true,
                children: items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(
                          bottom: _config.legendItemSpacing,
                        ),
                        child: item,
                      ),
                    )
                    .toList(),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(
                          bottom: _config.legendItemSpacing,
                        ),
                        child: item,
                      ),
                    )
                    .toList(),
              ),
      );
    } else {
      return SizedBox(
        height: _config.effectiveLegendHeight(_theme),
        child: _config.legendScrollable
            ? ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(
                          right: _config.legendItemSpacing,
                        ),
                        child: item,
                      ),
                    )
                    .toList(),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(
                          right: _config.legendItemSpacing,
                        ),
                        child: item,
                      ),
                    )
                    .toList(),
              ),
      );
    }
  }
}

// =============================================================================
// INTERNAL CLASSES
// =============================================================================

/// Layout information for pie chart.
class _PieLayout {
  const _PieLayout({
    required this.center,
    required this.availableRadius,
    required this.outerRadius,
    required this.innerRadius,
  });

  final Offset center;
  final double availableRadius;
  final double outerRadius;
  final double innerRadius;
}

/// Legend item widget.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
    required this.isSelected,
    required this.iconSize,
    required this.iconShape,
    required this.textStyle,
    required this.valueTextStyle,
    required this.valueFontSizeRatio,
    required this.lineThickness,
    required this.iconCornerRadius,
    required this.showValue,
    required this.showPercentage,
    required this.onTap,
  });

  final Color color;
  final String label;
  final double value;
  final double percentage;
  final bool isSelected;
  final double iconSize;
  final LegendIconShape iconShape;
  final TextStyle textStyle;
  final TextStyle valueTextStyle;
  final double valueFontSizeRatio;
  final double lineThickness;
  final double iconCornerRadius;
  final bool showValue;
  final bool showPercentage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 8 : 4,
          vertical: isSelected ? 4 : 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 1.0 : 0.5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.2 : 1.0,
                child: _buildIcon(),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: textStyle.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showPercentage || showValue)
                      Text(
                        _formatValueText(),
                        style: valueTextStyle.copyWith(
                          fontSize:
                              (valueTextStyle.fontSize ?? 12) *
                              valueFontSizeRatio,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (iconShape) {
      case LegendIconShape.circle:
        return Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      case LegendIconShape.square:
        return Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: color,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      case LegendIconShape.roundedSquare:
        return Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(iconCornerRadius),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      case LegendIconShape.diamond:
        return Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: iconSize * 0.8,
            height: iconSize * 0.8,
            decoration: BoxDecoration(
              color: color,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      case LegendIconShape.line:
        return Container(width: iconSize, height: lineThickness, color: color);
    }
  }

  String _formatValueText() {
    final parts = <String>[];
    if (showPercentage) {
      parts.add('${percentage.toStringAsFixed(1)}%');
    }
    if (showValue) {
      parts.add(value.toStringAsFixed(0));
    }
    return parts.join(' · ');
  }
}

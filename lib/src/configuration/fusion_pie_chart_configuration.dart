import 'package:flutter/material.dart';
import 'fusion_chart_configuration.dart';
import 'fusion_tooltip_configuration.dart';
import '../series/fusion_pie_series.dart';
import '../themes/fusion_chart_theme.dart';

/// Configuration for pie and donut charts.
///
/// ## Design Philosophy
///
/// Config fields override series defaults. Use `resolve*()` methods
/// to get the effective value considering both config and series.
///
/// ## Example
///
/// ```dart
/// FusionPieChart(
///   series: myPieSeries,
///   config: FusionPieChartConfiguration(
///     innerRadiusPercent: 0.5,  // Donut mode
///     labelPosition: PieLabelPosition.outside,
///     sortMode: PieSortMode.descending,
///     groupSmallSegments: true,
///     groupThreshold: 5.0,
///   ),
/// )
/// ```
@immutable
class FusionPieChartConfiguration extends FusionChartConfiguration {
  const FusionPieChartConfiguration({
    // === LAYOUT ===
    this.innerRadiusPercent = 0.0,
    this.outerRadiusPercent = 0.85,
    this.startAngle = -90.0,
    this.direction = PieDirection.clockwise,
    this.chartPadding = const EdgeInsets.all(4),

    // === LABELS ===
    this.labelPosition = PieLabelPosition.auto,
    this.showLabels = true,
    this.showPercentages = true,
    this.showValues = false,
    this.percentageThreshold = 3.0,
    this.labelConnectorLength = 20.0,
    this.labelConnectorWidth = 1.0,
    this.labelConnectorColor,
    this.labelStyle,
    this.labelFormatter,

    // === CENTER ===
    this.showCenterLabel = false,
    this.centerLabelText,
    this.centerLabelStyle,
    this.centerSubLabelText,
    this.centerSubLabelStyle,
    this.centerWidget,

    // === ANIMATION ===
    this.animationType = PieAnimationType.sweep,

    // === SELECTION ===
    this.selectionMode = PieSelectionMode.single,
    this.selectedOpacity = 1.0,
    this.unselectedOpacity = 0.4,
    this.selectedScale = 1.02,

    // === HOVER ===
    this.enableHover = true,
    this.hoverScale = 1.03,

    // === EXPLODE ===
    this.explodeOffset = 10.0,
    this.explodeOnSelection = false,
    this.explodeOnHover = false,

    // === LEGEND ===
    this.legendPosition = LegendPosition.right,
    this.legendSpacing = 16.0,
    this.legendItemSpacing = 8.0,
    this.legendIconSize = 12.0,
    this.legendIconShape = LegendIconShape.circle,
    this.legendTextStyle,
    this.legendValueTextStyle,
    this.showLegendValues = false,
    this.showLegendPercentages = true,
    this.legendScrollable = true,

    // === STROKE ===
    this.strokeWidth = 1.0,
    this.strokeColor,

    // === SHADOW ===
    this.enableShadow = false,
    this.shadowColor,
    this.shadowBlurRadius = 8.0,
    this.shadowOffset = const Offset(2, 2),

    // === CORNER RADIUS ===
    this.cornerRadius = 0.0,

    // === GAP ===
    this.gapBetweenSlices = 0.0,

    // === SORTING / GROUPING ===
    this.sortMode = PieSortMode.none,
    this.groupSmallSegments = false,
    this.groupThreshold = 3.0,
    this.groupLabel = 'Other',
    this.groupColor,

    // === BASE CONFIGURATION ===
    super.theme,
    super.tooltipBehavior = const FusionTooltipBehavior(),
    super.enableAnimation = true,
    super.enableTooltip = true,
    super.enableLegend = true,
    super.enableSelection = true,
    super.padding = const EdgeInsets.all(4),
    super.animationDuration,
    super.animationCurve,
  });

  // ===========================================================================
  // LAYOUT
  // ===========================================================================

  /// Inner radius as fraction of available radius (0.0 = pie, >0 = donut).
  final double innerRadiusPercent;

  /// Outer radius as fraction of available radius.
  final double outerRadiusPercent;

  /// Start angle in degrees (-90 = 12 o'clock).
  final double startAngle;

  /// Direction of segment layout.
  final PieDirection direction;

  /// Padding around the pie chart area.
  final EdgeInsets chartPadding;

  // ===========================================================================
  // LABELS
  // ===========================================================================

  /// Where to position labels (inside, outside, auto, none).
  final PieLabelPosition labelPosition;

  /// Whether to show labels on segments.
  final bool showLabels;

  /// Whether to include percentage in labels.
  final bool showPercentages;

  /// Whether to include raw values in labels.
  final bool showValues;

  /// Minimum percentage to show a label (avoids clutter on small segments).
  final double percentageThreshold;

  /// Length of connector line for outside labels.
  final double labelConnectorLength;

  /// Width of connector line for outside labels.
  final double labelConnectorWidth;

  /// Color of connector line (falls back to theme.axisColor).
  final Color? labelConnectorColor;

  /// Text style for labels (falls back to theme.dataLabelStyle).
  final TextStyle? labelStyle;

  /// Custom label formatter. Return empty string to hide label.
  final String Function(PieConfigLabelData data)? labelFormatter;

  // ===========================================================================
  // CENTER (Donut only)
  // ===========================================================================

  /// Whether to show center label text.
  final bool showCenterLabel;

  /// Primary center label text.
  final String? centerLabelText;

  /// Style for center label (falls back to theme.titleStyle).
  final TextStyle? centerLabelStyle;

  /// Secondary center label text.
  final String? centerSubLabelText;

  /// Style for center sub-label (falls back to theme.subtitleStyle).
  final TextStyle? centerSubLabelStyle;

  /// Custom widget to display in donut center (overrides text labels).
  final Widget? centerWidget;

  // ===========================================================================
  // ANIMATION
  // ===========================================================================

  /// Type of entrance animation.
  final PieAnimationType animationType;

  // ===========================================================================
  // SELECTION
  // ===========================================================================

  /// Selection behavior mode.
  final PieSelectionMode selectionMode;

  /// Opacity of selected segments.
  final double selectedOpacity;

  /// Opacity of unselected segments when selection is active.
  final double unselectedOpacity;

  /// Scale factor for selected segments.
  final double selectedScale;

  // ===========================================================================
  // HOVER
  // ===========================================================================

  /// Whether to enable hover effects (desktop/web).
  final bool enableHover;

  /// Scale factor for hovered segments.
  final double hoverScale;

  // ===========================================================================
  // EXPLODE
  // ===========================================================================

  /// Distance to explode segments outward.
  final double explodeOffset;

  /// Whether to explode segment when selected.
  final bool explodeOnSelection;

  /// Whether to explode segment when hovered.
  final bool explodeOnHover;

  // ===========================================================================
  // LEGEND
  // ===========================================================================

  /// Position of legend relative to chart.
  final LegendPosition legendPosition;

  /// Spacing between chart and legend.
  final double legendSpacing;

  /// Spacing between legend items.
  final double legendItemSpacing;

  /// Size of legend color indicator.
  final double legendIconSize;

  /// Shape of legend color indicator.
  final LegendIconShape legendIconShape;

  /// Text style for legend labels (falls back to theme.legendStyle).
  final TextStyle? legendTextStyle;

  /// Text style for legend values (falls back to theme.legendStyle).
  final TextStyle? legendValueTextStyle;

  /// Whether to show raw values in legend.
  final bool showLegendValues;

  /// Whether to show percentages in legend.
  final bool showLegendPercentages;

  /// Whether legend is scrollable (vs fixed layout).
  final bool legendScrollable;

  // ===========================================================================
  // STROKE
  // ===========================================================================

  /// Width of segment border stroke.
  final double strokeWidth;

  /// Stroke color (falls back to theme.pieStrokeColor).
  final Color? strokeColor;

  // ===========================================================================
  // SHADOW
  // ===========================================================================

  /// Whether to render shadows behind segments.
  final bool enableShadow;

  /// Shadow color (falls back to theme.pieShadowColor).
  final Color? shadowColor;

  /// Shadow blur radius.
  final double shadowBlurRadius;

  /// Shadow offset from segment.
  final Offset shadowOffset;

  // ===========================================================================
  // CORNER RADIUS
  // ===========================================================================

  /// Corner radius for segment edges.
  final double cornerRadius;

  // ===========================================================================
  // GAP
  // ===========================================================================

  /// Gap between segments in degrees.
  final double gapBetweenSlices;

  // ===========================================================================
  // SORTING / GROUPING
  // ===========================================================================

  /// How to sort segments before rendering.
  final PieSortMode sortMode;

  /// Whether to group small segments into "Other".
  final bool groupSmallSegments;

  /// Minimum percentage to avoid being grouped.
  final double groupThreshold;

  /// Label for grouped segments.
  final String groupLabel;

  /// Color for grouped segment (falls back to theme.gridColor).
  final Color? groupColor;

  // ===========================================================================
  // COMPUTED
  // ===========================================================================

  /// Whether this is a donut chart (has inner radius).
  bool get isDonut => innerRadiusPercent > 0;

  /// Effective stroke color (falls back to theme).
  Color effectiveStrokeColor(FusionChartTheme themeRef) => strokeColor ?? themeRef.pieStrokeColor;

  /// Effective shadow color (falls back to theme).
  Color effectiveShadowColor(FusionChartTheme themeRef) => shadowColor ?? themeRef.pieShadowColor;

  /// Effective legend width (from theme).
  double effectiveLegendWidth(FusionChartTheme themeRef) => themeRef.legendWidth;

  /// Effective legend height (from theme).
  double effectiveLegendHeight(FusionChartTheme themeRef) => themeRef.legendHeight;

  /// Effective group color (falls back to theme.gridColor).
  Color effectiveGroupColor(FusionChartTheme themeRef) => groupColor ?? themeRef.gridColor;

  // ===========================================================================
  // RESOLVED VALUES (Config overrides Series defaults)
  // ===========================================================================

  /// Gets effective inner radius percent.
  double resolveInnerRadius(FusionPieSeries series) =>
      innerRadiusPercent > 0 ? innerRadiusPercent : series.innerRadiusPercent;

  /// Gets effective outer radius percent.
  double resolveOuterRadius(FusionPieSeries series) =>
      outerRadiusPercent < 1.0 ? outerRadiusPercent : series.outerRadiusPercent;

  /// Gets effective start angle.
  double resolveStartAngle(FusionPieSeries series) =>
      startAngle != -90.0 ? startAngle : series.startAngle;

  /// Gets effective direction.
  PieDirection resolveDirection(FusionPieSeries series) =>
      direction != PieDirection.clockwise ? direction : series.direction;

  /// Gets effective corner radius.
  double resolveCornerRadius(FusionPieSeries series) =>
      cornerRadius > 0 ? cornerRadius : series.cornerRadius;

  /// Gets effective gap between slices.
  double resolveGapBetweenSlices(FusionPieSeries series) =>
      gapBetweenSlices > 0 ? gapBetweenSlices : series.gapBetweenSlices;

  /// Gets effective explode offset.
  double resolveExplodeOffset(FusionPieSeries series) =>
      explodeOffset != 10.0 ? explodeOffset : series.explodeOffset;

  /// Gets effective sort mode.
  PieSortMode resolveSortMode(FusionPieSeries series) =>
      sortMode != PieSortMode.none ? sortMode : series.sortMode;

  /// Gets effective group threshold.
  double resolveGroupThreshold(FusionPieSeries series) =>
      groupThreshold != 3.0 ? groupThreshold : series.groupThreshold;

  /// Whether to group small segments.
  bool resolveGroupSmallSegments(FusionPieSeries series) =>
      groupSmallSegments || series.groupSmallSegments;

  /// Gets effective group label.
  String resolveGroupLabel(FusionPieSeries series) =>
      groupLabel != 'Other' ? groupLabel : series.groupLabel;
}

// =============================================================================
// ENUMS
// =============================================================================

/// Animation type for pie chart entrance.
enum PieAnimationType {
  /// Segments sweep in from start angle.
  sweep,

  /// Segments scale up from center.
  scale,

  /// Segments fade in.
  fade,

  /// Segments scale and fade simultaneously.
  scaleFade,

  /// No animation.
  none,
}

/// Position of legend relative to chart.
enum LegendPosition {
  /// Legend above chart.
  top,

  /// Legend below chart.
  bottom,

  /// Legend to the left of chart.
  left,

  /// Legend to the right of chart.
  right,

  /// No legend displayed.
  none,
}

/// Shape of legend color indicator.
enum LegendIconShape {
  /// Circular indicator.
  circle,

  /// Square indicator.
  square,

  /// Rounded square indicator.
  roundedSquare,

  /// Diamond-shaped indicator.
  diamond,

  /// Horizontal line indicator.
  line,
}

// =============================================================================
// LABEL DATA
// =============================================================================

/// Data passed to custom label formatter.
@immutable
class PieConfigLabelData {
  const PieConfigLabelData({
    required this.index,
    required this.value,
    required this.percentage,
    required this.label,
    required this.color,
  });

  /// Segment index.
  final int index;

  /// Raw numeric value.
  final double value;

  /// Percentage of total (0-100).
  final double percentage;

  /// Original label from data point.
  final String? label;

  /// Segment color.
  final Color color;
}

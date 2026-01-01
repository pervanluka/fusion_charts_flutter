import 'package:flutter/material.dart';
import '../data/fusion_data_point.dart';
import 'fusion_series.dart';
import 'series_with_data_points.dart';

/// Stacked bar series for displaying cumulative data.
///
/// Stacked bar charts display bars stacked on top of each other,
/// showing both individual values and their sum.
///
/// ## Stacking Modes
///
/// - **Regular stacking** (`isStacked100: false`): Shows actual cumulative values
/// - **100% stacking** (`isStacked100: true`): Normalizes to 100%, showing percentages
///
/// ## Use Cases
///
/// - Revenue breakdown by product category
/// - Portfolio allocation over time
/// - Expense distribution
/// - Market share comparison (100% mode)
///
/// ## Example
///
/// ```dart
/// // Regular stacked bar
/// FusionStackedBarSeries(
///   name: 'Product A',
///   dataPoints: [
///     FusionDataPoint(0, 30, label: 'Q1'),
///     FusionDataPoint(1, 40, label: 'Q2'),
///   ],
///   color: Colors.blue,
/// )
///
/// // 100% stacked bar (percentage mode)
/// FusionStackedBarSeries(
///   name: 'Product A',
///   dataPoints: [...],
///   color: Colors.blue,
///   isStacked100: true,
/// )
/// ```
///
/// ## Grouping
///
/// Multiple stacked series with the same [groupName] are stacked together.
/// This allows multiple independent stacks in the same chart.
@immutable
class FusionStackedBarSeries extends FusionSeries
    with
        FusionGradientSupport,
        FusionShadowSupport,
        FusionDataLabelSupport,
        FusionAnimationSupport
    implements SeriesWithDataPoints {
  /// Creates a stacked bar series.
  const FusionStackedBarSeries({
    required this.dataPoints,
    required super.name,
    required super.color,
    super.visible,
    this.barWidth = 0.7,
    this.borderRadius = 0.0,
    this.spacing = 0.0,
    this.groupName = '',
    this.gradient,
    this.borderColor,
    this.borderWidth = 0.0,
    this.showShadow = false,
    this.shadow,
    this.showDataLabels = false,
    this.dataLabelStyle,
    this.dataLabelFormatter,
    this.animationDuration,
    this.animationCurve,
    this.isVertical = true,
    this.interaction = const FusionSeriesInteraction(),
  }) : assert(
         barWidth > 0 && barWidth <= 1.0,
         'Bar width must be between 0 and 1',
       ),
       assert(borderRadius >= 0, 'Border radius must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative');

  /// The data points to be displayed in this series.
  @override
  final List<FusionDataPoint> dataPoints;

  // ==========================================================================
  // BAR PROPERTIES
  // ==========================================================================

  /// Width of bars as a fraction of available space.
  ///
  /// - 1.0 = bars touch each other
  /// - 0.7 = bars use 70% of space (default)
  ///
  /// Range: 0.0-1.0
  /// Default: 0.7
  final double barWidth;

  /// Corner radius of the bars.
  ///
  /// Applied only to the topmost bar in the stack (for vertical bars)
  /// or the rightmost bar (for horizontal bars).
  ///
  /// Default: 0.0 (no rounding for stacked bars by default)
  final double borderRadius;

  /// Spacing between stacked bar groups.
  ///
  /// Range: 0.0-1.0
  /// Default: 0.0
  final double spacing;

  /// Group name for stacking.
  ///
  /// Series with the same [groupName] are stacked together.
  /// Leave empty to stack all series together.
  ///
  /// Example:
  /// ```dart
  /// // These two series will be stacked together
  /// FusionStackedBarSeries(name: 'A', groupName: 'group1', ...)
  /// FusionStackedBarSeries(name: 'B', groupName: 'group1', ...)
  ///
  /// // This will be a separate stack
  /// FusionStackedBarSeries(name: 'C', groupName: 'group2', ...)
  /// ```
  final String groupName;

  /// Whether bars are vertical or horizontal.
  ///
  /// - `true`: Vertical stacked bars (column chart)
  /// - `false`: Horizontal stacked bars (bar chart)
  ///
  /// Default: `true`
  final bool isVertical;

  // ==========================================================================
  // GRADIENT
  // ==========================================================================

  @override
  final LinearGradient? gradient;

  // ==========================================================================
  // BORDER
  // ==========================================================================

  /// Border color of the bars.
  final Color? borderColor;

  /// Width of the bar border.
  ///
  /// Default: 0.0 (no border)
  final double borderWidth;

  // ==========================================================================
  // SHADOW
  // ==========================================================================

  @override
  final bool showShadow;

  @override
  final BoxShadow? shadow;

  // ==========================================================================
  // DATA LABELS
  // ==========================================================================

  @override
  final bool showDataLabels;

  @override
  final TextStyle? dataLabelStyle;

  @override
  final String Function(double value)? dataLabelFormatter;

  // ==========================================================================
  // ANIMATION
  // ==========================================================================

  @override
  final Duration? animationDuration;

  @override
  final Curve? animationCurve;

  // ==========================================================================
  // INTERACTION
  // ==========================================================================

  /// Interaction configuration for this series.
  final FusionSeriesInteraction interaction;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Whether this series has any data points.
  bool get hasData => dataPoints.isNotEmpty;

  /// Number of data points in this series.
  int get pointCount => dataPoints.length;

  /// Minimum x value in this series.
  double? get minX => dataPoints.minX;

  /// Maximum x value in this series.
  double? get maxX => dataPoints.maxX;

  /// Minimum y value in this series.
  double? get minY => dataPoints.minY;

  /// Maximum y value in this series.
  double? get maxY => dataPoints.maxY;

  /// Total sum of y values.
  double get sum => dataPoints.sumY;

  // ==========================================================================
  // METHODS
  // ==========================================================================

  @override
  FusionStackedBarSeries copyWith({
    List<FusionDataPoint>? dataPoints,
    String? name,
    Color? color,
    bool? visible,
    double? barWidth,
    double? borderRadius,
    double? spacing,
    String? groupName,
    LinearGradient? gradient,
    Color? borderColor,
    double? borderWidth,
    bool? showShadow,
    BoxShadow? shadow,
    bool? showDataLabels,
    TextStyle? dataLabelStyle,
    String Function(double)? dataLabelFormatter,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? isVertical,
    FusionSeriesInteraction? interaction,
  }) {
    return FusionStackedBarSeries(
      dataPoints: dataPoints ?? this.dataPoints,
      name: name ?? this.name,
      color: color ?? this.color,
      visible: visible ?? this.visible,
      barWidth: barWidth ?? this.barWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      spacing: spacing ?? this.spacing,
      groupName: groupName ?? this.groupName,
      gradient: gradient ?? this.gradient,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showShadow: showShadow ?? this.showShadow,
      shadow: shadow ?? this.shadow,
      showDataLabels: showDataLabels ?? this.showDataLabels,
      dataLabelStyle: dataLabelStyle ?? this.dataLabelStyle,
      dataLabelFormatter: dataLabelFormatter ?? this.dataLabelFormatter,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      isVertical: isVertical ?? this.isVertical,
      interaction: interaction ?? this.interaction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionStackedBarSeries &&
        other.name == name &&
        other.color == color &&
        other.visible == visible &&
        other.barWidth == barWidth &&
        other.groupName == groupName &&
        other.isVertical == isVertical;
  }

  @override
  int get hashCode =>
      Object.hash(name, color, visible, barWidth, groupName, isVertical);

  @override
  String toString() {
    return 'FusionStackedBarSeries('
        'name: $name, '
        'points: ${dataPoints.length}, '
        'group: $groupName, '
        'visible: $visible'
        ')';
  }
}

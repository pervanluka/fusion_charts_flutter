import 'package:flutter/material.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../data/fusion_pie_data_point.dart';

/// Tooltip data for pie chart segments.
///
/// Extends [FusionTooltipDataBase] to work with the shared tooltip system
/// while providing pie-specific information.
///
/// ## Usage in Custom Tooltip Builder
///
/// ```dart
/// FusionPieChart(
///   config: FusionPieChartConfiguration(
///     tooltipBuilder: (context, data) {
///       final pieData = data as PieTooltipData;
///       return Card(
///         child: Padding(
///           padding: EdgeInsets.all(8),
///           child: Column(
///             mainAxisSize: MainAxisSize.min,
///             children: [
///               Text(pieData.label ?? 'Slice ${pieData.index}'),
///               Text('${pieData.percentage.toStringAsFixed(1)}%'),
///               Text('\$${pieData.value.toStringAsFixed(2)}'),
///             ],
///           ),
///         ),
///       );
///     },
///   ),
/// )
/// ```
@immutable
class PieTooltipData extends FusionTooltipDataBase {
  /// Creates pie tooltip data.
  const PieTooltipData({
    required this.index,
    required this.value,
    required this.percentage,
    required this.color,
    required this.screenPosition,
    required this.segmentCenter,
    this.label,
    this.dataPoint,
    this.isExploded = false,
    this.isSelected = false,
  }) : super();

  // ===========================================================================
  // SEGMENT IDENTIFICATION
  // ===========================================================================

  /// Index of the segment in the series.
  final int index;

  /// Reference to the original data point (if available).
  final FusionPieDataPoint? dataPoint;

  // ===========================================================================
  // VALUES
  // ===========================================================================

  /// Numeric value of this segment.
  final double value;

  /// Percentage of total (0-100).
  final double percentage;

  /// Label text (from data point).
  final String? label;

  // ===========================================================================
  // VISUAL
  // ===========================================================================

  /// Color of this segment.
  final Color color;

  // ===========================================================================
  // POSITIONS
  // ===========================================================================

  /// Screen position for tooltip placement.
  ///
  /// Typically the centroid of the segment or tap position.
  @override
  final Offset screenPosition;

  /// Center of the segment (for advanced positioning).
  final Offset segmentCenter;

  // ===========================================================================
  // STATE
  // ===========================================================================

  /// Whether this segment is currently exploded.
  final bool isExploded;

  /// Whether this segment is currently selected.
  final bool isSelected;

  // ===========================================================================
  // FORMATTING HELPERS
  // ===========================================================================

  /// Returns formatted percentage string.
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

  /// Returns formatted value string.
  String formattedValue([int decimals = 2]) => value.toStringAsFixed(decimals);

  /// Returns display label (falls back to index if no label).
  String get displayLabel => label ?? 'Segment $index';

  // ===========================================================================
  // COPY
  // ===========================================================================

  /// Creates a copy with modified properties.
  PieTooltipData copyWith({
    int? index,
    double? value,
    double? percentage,
    String? label,
    Color? color,
    Offset? screenPosition,
    Offset? segmentCenter,
    FusionPieDataPoint? dataPoint,
    bool? isExploded,
    bool? isSelected,
  }) {
    return PieTooltipData(
      index: index ?? this.index,
      value: value ?? this.value,
      percentage: percentage ?? this.percentage,
      label: label ?? this.label,
      color: color ?? this.color,
      screenPosition: screenPosition ?? this.screenPosition,
      segmentCenter: segmentCenter ?? this.segmentCenter,
      dataPoint: dataPoint ?? this.dataPoint,
      isExploded: isExploded ?? this.isExploded,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PieTooltipData &&
        other.index == index &&
        other.value == value &&
        other.percentage == percentage &&
        other.label == label &&
        other.color == color &&
        other.screenPosition == screenPosition;
  }

  @override
  int get hashCode => Object.hash(
        index,
        value,
        percentage,
        label,
        color,
        screenPosition,
      );

  @override
  String toString() => 'PieTooltipData('
      'index: $index, '
      'label: $label, '
      'percentage: ${percentage.toStringAsFixed(1)}%)';
}

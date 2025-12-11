import 'package:flutter/material.dart';

/// Information about a single segment in a stacked bar tooltip.
///
/// This class provides raw data without any formatting assumptions.
/// Developers can format values according to their needs.
@immutable
class FusionStackedSegment {
  const FusionStackedSegment({
    required this.seriesName,
    required this.color,
    required this.value,
    required this.percentage,
  });

  /// Name of the series this segment belongs to.
  final String seriesName;

  /// Color of this segment.
  final Color color;

  /// Raw value of this segment.
  final double value;

  /// Percentage this segment represents of the total (0-100).
  final double percentage;
}

/// Complete tooltip information for a stacked bar.
///
/// Contains all data needed to build a custom tooltip.
/// No formatting is applied - developers have full control.
@immutable
class FusionStackedTooltipInfo {
  const FusionStackedTooltipInfo({
    required this.categoryIndex,
    required this.categoryLabel,
    required this.segments,
    required this.totalValue,
    required this.isStacked100,
    this.hitSegmentIndex = -1,
  });

  /// Index of the category (X position).
  final int categoryIndex;

  /// Label for this category (e.g., "Q1", "January").
  /// May be null if no label was provided.
  final String? categoryLabel;

  /// All segments in this stack, from bottom to top.
  final List<FusionStackedSegment> segments;

  /// Sum of all segment values.
  final double totalValue;

  /// Whether this is a 100% stacked chart.
  final bool isStacked100;

  /// Index of the segment that was directly hit (-1 if none specific).
  final int hitSegmentIndex;

  /// Gets the segment that was directly hit, if any.
  FusionStackedSegment? get hitSegment =>
      hitSegmentIndex >= 0 && hitSegmentIndex < segments.length ? segments[hitSegmentIndex] : null;
}

/// Builder function type for custom stacked bar tooltips.
///
/// Return a Widget to completely customize the tooltip appearance.
/// Return null to use the default tooltip rendering.
///
/// ## Example
///
/// ```dart
/// FusionStackedBarChart(
///   tooltipBuilder: (context, info) {
///     return Container(
///       padding: EdgeInsets.all(8),
///       decoration: BoxDecoration(
///         color: Colors.white,
///         borderRadius: BorderRadius.circular(8),
///         boxShadow: [BoxShadow(blurRadius: 4)],
///       ),
///       child: Column(
///         mainAxisSize: MainAxisSize.min,
///         children: [
///           Text(info.categoryLabel ?? 'Category ${info.categoryIndex}'),
///           ...info.segments.map((s) => Row(
///             children: [
///               Container(width: 12, height: 12, color: s.color),
///               SizedBox(width: 8),
///               Text('${s.seriesName}: ${s.value.toStringAsFixed(2)}'),
///             ],
///           )),
///         ],
///       ),
///     );
///   },
/// )
/// ```
typedef FusionStackedTooltipBuilder =
    Widget? Function(BuildContext context, FusionStackedTooltipInfo info);

/// Formatter function for individual segment values.
///
/// ## Example
///
/// ```dart
/// FusionStackedBarChart(
///   tooltipValueFormatter: (value, segment, info) {
///     if (info.isStacked100) {
///       return '${segment.percentage.toStringAsFixed(1)}%';
///     }
///     return '\$${value.toStringAsFixed(0)}';
///   },
/// )
/// ```
typedef FusionStackedValueFormatter =
    String Function(double value, FusionStackedSegment segment, FusionStackedTooltipInfo info);

/// Formatter function for the total value line.
///
/// Return null to hide the total line.
///
/// ## Example
///
/// ```dart
/// FusionStackedBarChart(
///   tooltipTotalFormatter: (total, info) {
///     return 'Sum: \$${total.toStringAsFixed(0)}';
///   },
/// )
/// ```
typedef FusionStackedTotalFormatter = String? Function(double total, FusionStackedTooltipInfo info);

import 'package:flutter/material.dart';
import '../series/fusion_stacked_bar_series.dart';
import 'fusion_coordinate_system.dart';

/// Hit test result for a single segment in a stacked bar.
class StackedSegmentInfo {
  const StackedSegmentInfo({
    required this.seriesName,
    required this.seriesColor,
    required this.value,
    required this.percentage,
  });

  final String seriesName;
  final Color seriesColor;
  final double value;
  final double percentage;
}

/// Hit test result for stacked bar charts.
///
/// Contains information about ALL segments in the stack at a given position,
/// allowing for multi-line tooltips.
class StackedBarHitTestResult {
  const StackedBarHitTestResult({
    required this.categoryIndex,
    required this.categoryLabel,
    required this.segments,
    required this.totalValue,
    required this.stackRect,
    required this.hitSegmentIndex,
  });

  /// The category index (X position)
  final int categoryIndex;

  /// The label for this category (e.g., "Q1", "Jan")
  final String? categoryLabel;

  /// All segments in this stack (bottom to top)
  final List<StackedSegmentInfo> segments;

  /// Total value of the entire stack
  final double totalValue;

  /// The bounding rect of the entire stack
  final Rect stackRect;

  /// Which segment was directly hit (-1 if hit the stack but not a specific segment)
  final int hitSegmentIndex;
}

/// Specialized hit tester for stacked bar charts.
///
/// Unlike regular bar charts, stacked bars need to:
/// 1. Return ALL segments in a stack, not just one
/// 2. Calculate percentages for each segment
/// 3. Position tooltip at the top of the entire stack
class FusionStackedBarHitTester {
  const FusionStackedBarHitTester();

  /// Tests if a screen position hits any stacked bar.
  StackedBarHitTestResult? hitTest({
    required Offset screenPosition,
    required List<FusionStackedBarSeries> allSeries,
    required FusionCoordinateSystem coordSystem,
    required bool isStacked100,
  }) {
    final visibleSeries = allSeries.where((s) => s.visible).toList();
    if (visibleSeries.isEmpty) return null;

    final chartArea = coordSystem.chartArea;

    // Check if position is within chart area
    if (!chartArea.contains(screenPosition)) return null;

    final pointCount = visibleSeries.first.dataPoints.length;
    if (pointCount == 0) return null;

    // Calculate category width
    final categoryWidth = chartArea.width / pointCount;
    final categorySpacing = categoryWidth * 0.1;
    final barWidth = (categoryWidth - categorySpacing * 2) * (visibleSeries.first.barWidth);

    // Find which category (X index) was hit by checking each bar
    int? categoryIndex;
    double? barCenterX;
    
    for (int i = 0; i < pointCount; i++) {
      // CRITICAL FIX: Use coordinate system for positioning
      // This ensures hit testing aligns perfectly with rendered bars
      final centerX = coordSystem.dataXToScreenX(i.toDouble());
      final left = centerX - barWidth / 2;
      final right = centerX + barWidth / 2;
      
      // Check if X is within bar bounds (with small tolerance)
      if (screenPosition.dx >= left - 4 && screenPosition.dx <= right + 4) {
        categoryIndex = i;
        barCenterX = centerX;
        break;
      }
    }

    if (categoryIndex == null || barCenterX == null) return null;

    final barLeft = barCenterX - barWidth / 2;
    final barRight = barCenterX + barWidth / 2;

    // Calculate stacked data for this category
    final segments = <StackedSegmentInfo>[];
    double totalValue = 0;

    for (final series in visibleSeries) {
      if (categoryIndex < series.dataPoints.length) {
        totalValue += series.dataPoints[categoryIndex].y;
      }
    }

    // Build segment info
    double cumulativeBase = 0;
    int hitSegmentIndex = -1;

    for (int i = 0; i < visibleSeries.length; i++) {
      final series = visibleSeries[i];
      if (categoryIndex >= series.dataPoints.length) continue;

      final value = series.dataPoints[categoryIndex].y;
      final percentage = totalValue > 0 ? (value / totalValue) * 100 : 0.0;

      segments.add(
        StackedSegmentInfo(
          seriesName: series.name,
          seriesColor: series.color,
          value: value,
          percentage: percentage,
        ),
      );

      // Check if this segment was hit (for highlighting purposes)
      final segmentBase = cumulativeBase;
      final segmentTop = cumulativeBase + (isStacked100 ? percentage : value);

      final baseY = coordSystem.dataYToScreenY(segmentBase);
      final topY = coordSystem.dataYToScreenY(segmentTop);

      if (screenPosition.dy <= baseY && screenPosition.dy >= topY) {
        hitSegmentIndex = i;
      }

      cumulativeBase = segmentTop;
    }

    if (segments.isEmpty) return null;

    // Calculate stack rect (entire stack bounds)
    final stackTop = coordSystem.dataYToScreenY(isStacked100 ? 100 : totalValue);
    final stackBottom = coordSystem.dataYToScreenY(0);

    final stackRect = Rect.fromLTRB(barLeft, stackTop, barRight, stackBottom);

    // Get category label
    String? categoryLabel;
    if (visibleSeries.first.dataPoints[categoryIndex].label != null) {
      categoryLabel = visibleSeries.first.dataPoints[categoryIndex].label;
    }

    return StackedBarHitTestResult(
      categoryIndex: categoryIndex,
      categoryLabel: categoryLabel,
      segments: segments,
      totalValue: totalValue,
      stackRect: stackRect,
      hitSegmentIndex: hitSegmentIndex,
    );
  }
}

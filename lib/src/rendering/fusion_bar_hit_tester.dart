import 'package:flutter/material.dart';
import '../data/fusion_data_point.dart';
import '../series/fusion_bar_series.dart';
import 'fusion_coordinate_system.dart';

/// Hit test result for bar charts.
class BarHitTestResult {
  const BarHitTestResult({
    required this.point,
    required this.seriesIndex,
    required this.seriesName,
    required this.seriesColor,
    required this.barRect,
  });

  final FusionDataPoint point;
  final int seriesIndex;
  final String seriesName;
  final Color seriesColor;
  final Rect barRect;
}

/// Specialized hit tester for bar charts.
///
/// Unlike line charts where we find the nearest point by distance,
/// bar charts need to test if the pointer is actually INSIDE a bar rectangle.
///
/// This ensures accurate tooltip behavior for grouped/stacked bars.
class FusionBarHitTester {
  const FusionBarHitTester();

  /// Tests if a screen position hits any bar.
  ///
  /// Returns the hit result with series info, or null if no bar was hit.
  BarHitTestResult? hitTest({
    required Offset screenPosition,
    required List<FusionBarSeries> allSeries,
    required FusionCoordinateSystem coordSystem,
    required bool enableSideBySideSeriesPlacement,
  }) {
    final visibleSeries = allSeries.where((s) => s.visible).toList();
    if (visibleSeries.isEmpty) return null;

    final chartArea = coordSystem.chartArea;

    // Check if position is within chart area
    if (!chartArea.contains(screenPosition)) return null;

    // Calculate layout (same logic as renderer)
    final layout = _calculateBarLayout(
      chartArea: chartArea,
      visibleSeries: visibleSeries,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    // Test each bar in each series
    // Go in reverse order so topmost bars (rendered last) are tested first
    for (int seriesIndex = visibleSeries.length - 1; seriesIndex >= 0; seriesIndex--) {
      final series = visibleSeries[seriesIndex];

      for (int pointIndex = 0; pointIndex < series.dataPoints.length; pointIndex++) {
        final point = series.dataPoints[pointIndex];

        final barRect = _calculateBarRect(
          chartArea: chartArea,
          coordSystem: coordSystem,
          point: point,
          pointIndex: pointIndex,
          seriesIndex: seriesIndex,
          totalSeriesCount: visibleSeries.length,
          layout: layout,
          series: series,
          enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
        );

        // Expand rect slightly for easier hit testing
        final expandedRect = barRect.inflate(2.0);

        if (expandedRect.contains(screenPosition)) {
          return BarHitTestResult(
            point: point,
            seriesIndex: seriesIndex,
            seriesName: series.name,
            seriesColor: series.color,
            barRect: barRect,
          );
        }
      }
    }

    return null;
  }

  /// Finds all bars at a given X position (for trackball mode).
  List<BarHitTestResult> findBarsAtX({
    required double screenX,
    required List<FusionBarSeries> allSeries,
    required FusionCoordinateSystem coordSystem,
    required bool enableSideBySideSeriesPlacement,
  }) {
    final results = <BarHitTestResult>[];
    final visibleSeries = allSeries.where((s) => s.visible).toList();
    if (visibleSeries.isEmpty) return results;

    final chartArea = coordSystem.chartArea;

    final layout = _calculateBarLayout(
      chartArea: chartArea,
      visibleSeries: visibleSeries,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    for (int seriesIndex = 0; seriesIndex < visibleSeries.length; seriesIndex++) {
      final series = visibleSeries[seriesIndex];

      for (int pointIndex = 0; pointIndex < series.dataPoints.length; pointIndex++) {
        final point = series.dataPoints[pointIndex];

        final barRect = _calculateBarRect(
          chartArea: chartArea,
          coordSystem: coordSystem,
          point: point,
          pointIndex: pointIndex,
          seriesIndex: seriesIndex,
          totalSeriesCount: visibleSeries.length,
          layout: layout,
          series: series,
          enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
        );

        // Check if screenX is within bar's X range
        if (screenX >= barRect.left && screenX <= barRect.right) {
          results.add(
            BarHitTestResult(
              point: point,
              seriesIndex: seriesIndex,
              seriesName: series.name,
              seriesColor: series.color,
              barRect: barRect,
            ),
          );
        }
      }
    }

    return results;
  }

  // ============================================================
  // LAYOUT CALCULATION (mirrors renderer logic)
  // ============================================================

  _BarLayout _calculateBarLayout({
    required Rect chartArea,
    required List<FusionBarSeries> visibleSeries,
    required bool enableSideBySideSeriesPlacement,
  }) {
    final firstSeries = visibleSeries.first;
    final pointCount = firstSeries.dataPoints.length;

    if (pointCount == 0) {
      return _BarLayout(
        categoryWidth: 0,
        groupWidth: 0,
        barWidth: 0,
        categorySpacing: 0,
        barSpacing: 0,
      );
    }

    final useCategoryPositioning = _shouldUseCategoryPositioning(firstSeries);

    if (useCategoryPositioning) {
      return _calculateCategoryLayout(
        chartArea: chartArea,
        visibleSeries: visibleSeries,
        pointCount: pointCount,
        enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
      );
    } else {
      return _BarLayout(
        categoryWidth: chartArea.width / pointCount,
        groupWidth: chartArea.width / pointCount * 0.8,
        barWidth: chartArea.width / pointCount * 0.8 / visibleSeries.length,
        categorySpacing: chartArea.width / pointCount * 0.1,
        barSpacing: 0,
        useCategoryPositioning: false,
      );
    }
  }

  bool _shouldUseCategoryPositioning(FusionBarSeries series) {
    final points = series.dataPoints;
    if (points.isEmpty) return false;

    for (int i = 0; i < points.length; i++) {
      if (points[i].x != i.toDouble()) {
        return false;
      }
    }
    return true;
  }

  _BarLayout _calculateCategoryLayout({
    required Rect chartArea,
    required List<FusionBarSeries> visibleSeries,
    required int pointCount,
    required bool enableSideBySideSeriesPlacement,
  }) {
    final seriesCount = enableSideBySideSeriesPlacement ? visibleSeries.length : 1;
    final totalWidth = chartArea.width;
    final categoryWidth = totalWidth / pointCount;
    final categorySpacing = categoryWidth * 0.1;
    final groupWidth = categoryWidth - (categorySpacing * 2);
    final barWidthRatio = visibleSeries.first.barWidth;

    double barWidth;
    double barSpacing;

    if (!enableSideBySideSeriesPlacement) {
      barWidth = groupWidth * barWidthRatio;
      barSpacing = 0;
    } else if (seriesCount == 1) {
      barWidth = groupWidth * barWidthRatio;
      barSpacing = 0;
    } else {
      final spacing = visibleSeries.first.spacing;
      final totalSpacingSpace = groupWidth * spacing * (seriesCount - 1) / seriesCount;
      final availableBarSpace = groupWidth - totalSpacingSpace;
      barWidth = (availableBarSpace / seriesCount) * barWidthRatio;
      barSpacing = seriesCount > 1 ? totalSpacingSpace / (seriesCount - 1) : 0;
    }

    return _BarLayout(
      categoryWidth: categoryWidth,
      groupWidth: groupWidth,
      barWidth: barWidth,
      categorySpacing: categorySpacing,
      barSpacing: barSpacing,
      useCategoryPositioning: true,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );
  }

  Rect _calculateBarRect({
    required Rect chartArea,
    required FusionCoordinateSystem coordSystem,
    required FusionDataPoint point,
    required int pointIndex,
    required int seriesIndex,
    required int totalSeriesCount,
    required _BarLayout layout,
    required FusionBarSeries series,
    required bool enableSideBySideSeriesPlacement,
  }) {
    if (series.isVertical) {
      return _calculateVerticalBarRect(
        chartArea: chartArea,
        coordSystem: coordSystem,
        point: point,
        pointIndex: pointIndex,
        seriesIndex: seriesIndex,
        totalSeriesCount: totalSeriesCount,
        layout: layout,
        enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
      );
    } else {
      return _calculateHorizontalBarRect(
        chartArea: chartArea,
        coordSystem: coordSystem,
        point: point,
        pointIndex: pointIndex,
        seriesIndex: seriesIndex,
        totalSeriesCount: totalSeriesCount,
        layout: layout,
        enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
      );
    }
  }

  Rect _calculateVerticalBarRect({
    required Rect chartArea,
    required FusionCoordinateSystem coordSystem,
    required FusionDataPoint point,
    required int pointIndex,
    required int seriesIndex,
    required int totalSeriesCount,
    required _BarLayout layout,
    required bool enableSideBySideSeriesPlacement,
  }) {
    double barCenterX;

    if (layout.useCategoryPositioning) {
      barCenterX =
          chartArea.left +
          layout.categorySpacing +
          (pointIndex * layout.categoryWidth) +
          (layout.categoryWidth / 2);

      if (totalSeriesCount > 1 && enableSideBySideSeriesPlacement) {
        final groupStartX = barCenterX - (layout.groupWidth / 2);
        final barOffset = (seriesIndex * (layout.barWidth + layout.barSpacing));
        barCenterX = groupStartX + barOffset + (layout.barWidth / 2);
      }
    } else {
      barCenterX = coordSystem.dataXToScreenX(point.x);

      if (totalSeriesCount > 1 && enableSideBySideSeriesPlacement) {
        final totalGroupWidth =
            totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
        final groupStartX = barCenterX - (totalGroupWidth / 2);
        final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
        barCenterX = groupStartX + barOffset + (layout.barWidth / 2);
      }
    }

    final baselineY = coordSystem.dataYToScreenY(0);
    final topY = coordSystem.dataYToScreenY(point.y);

    final actualTop = topY < baselineY ? topY : baselineY;
    final actualBottom = topY < baselineY ? baselineY : topY;

    return Rect.fromLTRB(
      barCenterX - (layout.barWidth / 2),
      actualTop,
      barCenterX + (layout.barWidth / 2),
      actualBottom,
    );
  }

  Rect _calculateHorizontalBarRect({
    required Rect chartArea,
    required FusionCoordinateSystem coordSystem,
    required FusionDataPoint point,
    required int pointIndex,
    required int seriesIndex,
    required int totalSeriesCount,
    required _BarLayout layout,
    required bool enableSideBySideSeriesPlacement,
  }) {
    double barCenterY;

    if (layout.useCategoryPositioning) {
      barCenterY =
          chartArea.top +
          layout.categorySpacing +
          (pointIndex * layout.categoryWidth) +
          (layout.categoryWidth / 2);

      if (totalSeriesCount > 1 && enableSideBySideSeriesPlacement) {
        final groupStartY = barCenterY - (layout.groupWidth / 2);
        final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
        barCenterY = groupStartY + barOffset + (layout.barWidth / 2);
      }
    } else {
      barCenterY = coordSystem.dataYToScreenY(point.y);

      if (totalSeriesCount > 1 && enableSideBySideSeriesPlacement) {
        final totalGroupWidth =
            totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
        final groupStartY = barCenterY - (totalGroupWidth / 2);
        final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
        barCenterY = groupStartY + barOffset + (layout.barWidth / 2);
      }
    }

    final baselineX = coordSystem.dataXToScreenX(0);
    final rightX = coordSystem.dataXToScreenX(point.x);

    final actualLeft = rightX < baselineX ? rightX : baselineX;
    final actualRight = rightX < baselineX ? baselineX : rightX;

    return Rect.fromLTRB(
      actualLeft,
      barCenterY - (layout.barWidth / 2),
      actualRight,
      barCenterY + (layout.barWidth / 2),
    );
  }
}

/// Internal layout metrics for bar hit testing.
class _BarLayout {
  const _BarLayout({
    required this.categoryWidth,
    required this.groupWidth,
    required this.barWidth,
    required this.categorySpacing,
    required this.barSpacing,
    this.useCategoryPositioning = true,
    this.enableSideBySideSeriesPlacement = true,
  });

  final double categoryWidth;
  final double groupWidth;
  final double barWidth;
  final double categorySpacing;
  final double barSpacing;
  final bool useCategoryPositioning;
  final bool enableSideBySideSeriesPlacement;
}

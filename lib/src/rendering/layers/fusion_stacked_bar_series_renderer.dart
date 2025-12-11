import 'package:flutter/material.dart';
import '../engine/fusion_render_context.dart';
import '../../series/fusion_stacked_bar_series.dart';

/// Renderer for stacked bar series.
///
/// Handles the complexity of stacking multiple series on top of each other:
/// - Regular stacked bars (cumulative values)
/// - 100% stacked bars (normalized to 100%)
/// - Multiple stack groups
/// - Proper animation from baseline
///
/// ## Stacking Algorithm
///
/// For each category position, bars are stacked in series order.
/// Each bar's base is the cumulative sum of all previous bars.
///
/// Example with 3 series at category 0:
/// - Series 0 (value=30): base=0, top=30
/// - Series 1 (value=20): base=30, top=50
/// - Series 2 (value=25): base=50, top=75
class FusionStackedBarSeriesRenderer {
  const FusionStackedBarSeriesRenderer();

  /// Renders all stacked bar series to the canvas.
  void render(
    Canvas canvas,
    FusionRenderContext context,
    List<FusionStackedBarSeries> allSeries, {
    bool is100Percent = false,
  }) {
    final visibleSeries = allSeries.where((s) => s.visible).toList();
    if (visibleSeries.isEmpty) return;

    // Group series by their groupName
    final groupedSeries = _groupSeriesByName(visibleSeries);

    // Calculate cumulative values for each group
    final stackedData = _calculateStackedData(groupedSeries, is100Percent);

    // Calculate layout metrics
    final layout = _calculateStackedLayout(context, visibleSeries, groupedSeries.length);

    // Render each group
    int groupIndex = 0;
    for (final groupEntry in groupedSeries.entries) {
      final seriesInGroup = groupEntry.value;

      for (int seriesIndex = 0; seriesIndex < seriesInGroup.length; seriesIndex++) {
        final series = seriesInGroup[seriesIndex];
        final isTopOfStack = seriesIndex == seriesInGroup.length - 1;

        _renderStackedSeries(
          canvas,
          context,
          series,
          seriesIndex,
          groupIndex,
          groupedSeries.length,
          layout,
          stackedData[groupEntry.key]!,
          isTopOfStack,
        );
      }
      groupIndex++;
    }
  }

  /// Groups series by their groupName.
  Map<String, List<FusionStackedBarSeries>> _groupSeriesByName(
    List<FusionStackedBarSeries> series,
  ) {
    final groups = <String, List<FusionStackedBarSeries>>{};

    for (final s in series) {
      final key = s.groupName.isEmpty ? '_default' : s.groupName;
      groups.putIfAbsent(key, () => []).add(s);
    }

    return groups;
  }

  /// Calculates cumulative stacked values for each group.
  ///
  /// Returns a map of groupName -> list of (base, top) values per point.
  Map<String, List<List<_StackedValue>>> _calculateStackedData(
    Map<String, List<FusionStackedBarSeries>> groupedSeries,
    bool is100Percent,
  ) {
    final result = <String, List<List<_StackedValue>>>{};

    for (final entry in groupedSeries.entries) {
      final groupName = entry.key;
      final seriesInGroup = entry.value;

      if (seriesInGroup.isEmpty) continue;

      final pointCount = seriesInGroup.first.dataPoints.length;
      final stackedValues = <List<_StackedValue>>[];

      for (int pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        final valuesAtPoint = <_StackedValue>[];
        double cumulativeBase = 0;

        // Calculate total for 100% stacking
        double total = 0;
        if (is100Percent) {
          for (final series in seriesInGroup) {
            if (pointIndex < series.dataPoints.length) {
              total += series.dataPoints[pointIndex].y.abs();
            }
          }
        }

        // Calculate base and top for each series
        for (final series in seriesInGroup) {
          double value = 0;
          if (pointIndex < series.dataPoints.length) {
            value = series.dataPoints[pointIndex].y;
          }

          // Normalize for 100% stacking
          if (is100Percent && total > 0) {
            value = (value / total) * 100;
          }

          final top = cumulativeBase + value;
          valuesAtPoint.add(
            _StackedValue(
              base: cumulativeBase,
              top: top,
              originalValue: series.dataPoints[pointIndex].y,
            ),
          );
          cumulativeBase = top;
        }

        stackedValues.add(valuesAtPoint);
      }

      result[groupName] = stackedValues;
    }

    return result;
  }

  /// Calculates layout metrics for stacked bars.
  _StackedBarLayout _calculateStackedLayout(
    FusionRenderContext context,
    List<FusionStackedBarSeries> visibleSeries,
    int groupCount,
  ) {
    final chartArea = context.chartArea;
    final firstSeries = visibleSeries.first;
    final pointCount = firstSeries.dataPoints.length;

    if (pointCount == 0) {
      return _StackedBarLayout(categoryWidth: 0, groupWidth: 0, barWidth: 0);
    }

    // Total width divided by categories
    final categoryWidth = chartArea.width / pointCount;

    // Spacing between categories (10% on each side)
    final categorySpacing = categoryWidth * 0.1;

    // Width available for bar groups
    final groupWidth = categoryWidth - (categorySpacing * 2);

    // Bar width ratio from series
    final barWidthRatio = firstSeries.barWidth;

    // If multiple groups, divide space; otherwise use full width
    double barWidth;
    double groupSpacing;

    if (groupCount > 1) {
      // Multiple stack groups side by side
      groupSpacing = groupWidth * 0.1;
      barWidth = (groupWidth - (groupSpacing * (groupCount - 1))) / groupCount * barWidthRatio;
    } else {
      // Single stack group
      barWidth = groupWidth * barWidthRatio;
      groupSpacing = 0;
    }

    return _StackedBarLayout(
      categoryWidth: categoryWidth,
      groupWidth: groupWidth,
      barWidth: barWidth,
      categorySpacing: categorySpacing,
      groupSpacing: groupSpacing,
      groupCount: groupCount,
    );
  }

  /// Renders a single stacked series.
  void _renderStackedSeries(
    Canvas canvas,
    FusionRenderContext context,
    FusionStackedBarSeries series,
    int seriesIndex,
    int groupIndex,
    int totalGroups,
    _StackedBarLayout layout,
    List<List<_StackedValue>> stackedData,
    bool isTopOfStack,
  ) {
    final chartArea = context.chartArea;
    final animationProgress = context.animationProgress;

    for (int pointIndex = 0; pointIndex < series.dataPoints.length; pointIndex++) {
      if (pointIndex >= stackedData.length) continue;

      final stackValues = stackedData[pointIndex];
      if (seriesIndex >= stackValues.length) continue;

      final stackValue = stackValues[seriesIndex];

      // Calculate bar rectangle
      final barRect = _calculateStackedBarRect(
        chartArea: chartArea,
        context: context,
        pointIndex: pointIndex,
        groupIndex: groupIndex,
        totalGroups: totalGroups,
        layout: layout,
        series: series,
        stackValue: stackValue,
        animationProgress: animationProgress,
      );

      // Skip if bar is outside visible area or has no height
      if (barRect.height <= 0 || !chartArea.overlaps(barRect)) continue;

      // Render the bar segment
      _renderBar(
        canvas,
        context,
        barRect,
        series,
        isTopOfStack: isTopOfStack,
        seriesIndex: seriesIndex,
      );
    }
  }

  /// Calculates rectangle for a stacked bar segment.
  Rect _calculateStackedBarRect({
    required Rect chartArea,
    required FusionRenderContext context,
    required int pointIndex,
    required int groupIndex,
    required int totalGroups,
    required _StackedBarLayout layout,
    required FusionStackedBarSeries series,
    required _StackedValue stackValue,
    required double animationProgress,
  }) {
    if (series.isVertical) {
      return _calculateVerticalStackedRect(
        chartArea: chartArea,
        context: context,
        pointIndex: pointIndex,
        groupIndex: groupIndex,
        totalGroups: totalGroups,
        layout: layout,
        stackValue: stackValue,
        animationProgress: animationProgress,
      );
    } else {
      return _calculateHorizontalStackedRect(
        chartArea: chartArea,
        context: context,
        pointIndex: pointIndex,
        groupIndex: groupIndex,
        totalGroups: totalGroups,
        layout: layout,
        stackValue: stackValue,
        animationProgress: animationProgress,
      );
    }
  }

  Rect _calculateVerticalStackedRect({
    required Rect chartArea,
    required FusionRenderContext context,
    required int pointIndex,
    required int groupIndex,
    required int totalGroups,
    required _StackedBarLayout layout,
    required _StackedValue stackValue,
    required double animationProgress,
  }) {
    // Category center X - bar is centered within each category slot
    // categoryWidth includes spacing on both sides, so center is at:
    // chartArea.left + (pointIndex * categoryWidth) + (categoryWidth / 2)
    double barCenterX =
        chartArea.left + (pointIndex * layout.categoryWidth) + (layout.categoryWidth / 2);

    // Offset for multiple groups
    if (totalGroups > 1) {
      final totalGroupWidth =
          totalGroups * layout.barWidth + (totalGroups - 1) * layout.groupSpacing;
      final groupStartX = barCenterX - (totalGroupWidth / 2);
      final groupOffset = groupIndex * (layout.barWidth + layout.groupSpacing);
      barCenterX = groupStartX + groupOffset + (layout.barWidth / 2);
    }

    // Y positions (screen coordinates, Y is inverted)
    final baseY = context.dataYToScreenY(stackValue.base);
    final topY = context.dataYToScreenY(stackValue.top);

    // Apply animation (grow from base)
    final animatedTopY = baseY + (topY - baseY) * animationProgress;

    return Rect.fromLTRB(
      barCenterX - (layout.barWidth / 2),
      animatedTopY,
      barCenterX + (layout.barWidth / 2),
      baseY,
    );
  }

  Rect _calculateHorizontalStackedRect({
    required Rect chartArea,
    required FusionRenderContext context,
    required int pointIndex,
    required int groupIndex,
    required int totalGroups,
    required _StackedBarLayout layout,
    required _StackedValue stackValue,
    required double animationProgress,
  }) {
    // Category center Y (for horizontal bars, Y is the category axis)
    double barCenterY =
        chartArea.top +
        layout.categorySpacing +
        (pointIndex * layout.categoryWidth) +
        (layout.categoryWidth / 2);

    // Offset for multiple groups
    if (totalGroups > 1) {
      final totalGroupWidth =
          totalGroups * layout.barWidth + (totalGroups - 1) * layout.groupSpacing;
      final groupStartY = barCenterY - (totalGroupWidth / 2);
      final groupOffset = groupIndex * (layout.barWidth + layout.groupSpacing);
      barCenterY = groupStartY + groupOffset + (layout.barWidth / 2);
    }

    // X positions
    final baseX = context.dataXToScreenX(stackValue.base);
    final rightX = context.dataXToScreenX(stackValue.top);

    // Apply animation (grow from base)
    final animatedRightX = baseX + (rightX - baseX) * animationProgress;

    return Rect.fromLTRB(
      baseX,
      barCenterY - (layout.barWidth / 2),
      animatedRightX,
      barCenterY + (layout.barWidth / 2),
    );
  }

  /// Renders a single bar segment.
  void _renderBar(
    Canvas canvas,
    FusionRenderContext context,
    Rect barRect,
    FusionStackedBarSeries series, {
    required bool isTopOfStack,
    required int seriesIndex,
  }) {
    final paint = context.getPaint(color: series.color, style: PaintingStyle.fill);

    // Apply gradient if specified
    if (series.gradient != null) {
      paint.shader = context.shaderCache.getLinearGradient(series.gradient!, barRect);
    }

    // Draw shadow only for bottom segment
    if (series.showShadow && series.shadow != null && seriesIndex == 0) {
      _renderShadow(canvas, barRect, series.shadow!, series.borderRadius);
    }

    // Rounded corners only on top of stack
    final borderRadius = isTopOfStack ? series.borderRadius : 0.0;

    // For stacked bars, only round the top corners
    if (borderRadius > 0 && isTopOfStack) {
      final rRect = RRect.fromRectAndCorners(
        barRect,
        topLeft: series.isVertical ? Radius.circular(borderRadius) : Radius.zero,
        topRight: series.isVertical ? Radius.circular(borderRadius) : Radius.circular(borderRadius),
        bottomLeft: series.isVertical ? Radius.zero : Radius.circular(borderRadius),
        bottomRight: Radius.zero,
      );
      canvas.drawRRect(rRect, paint);
    } else {
      canvas.drawRect(barRect, paint);
    }

    context.returnPaint(paint);

    // Draw border
    if (series.borderColor != null && series.borderWidth > 0) {
      _renderBorder(canvas, context, barRect, series, borderRadius);
    }
  }

  void _renderShadow(Canvas canvas, Rect barRect, BoxShadow shadow, double borderRadius) {
    final shadowPaint = Paint()
      ..color = shadow.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

    final shadowRect = barRect.shift(shadow.offset);
    canvas.drawRect(shadowRect, shadowPaint);
  }

  void _renderBorder(
    Canvas canvas,
    FusionRenderContext context,
    Rect barRect,
    FusionStackedBarSeries series,
    double borderRadius,
  ) {
    final borderPaint = context.getPaint(
      color: series.borderColor!,
      strokeWidth: series.borderWidth,
      style: PaintingStyle.stroke,
    );

    if (borderRadius > 0) {
      final rRect = RRect.fromRectAndRadius(barRect, Radius.circular(borderRadius));
      canvas.drawRRect(rRect, borderPaint);
    } else {
      canvas.drawRect(barRect, borderPaint);
    }

    context.returnPaint(borderPaint);
  }
}

/// Stacked value with base and top positions.
class _StackedValue {
  const _StackedValue({required this.base, required this.top, required this.originalValue});

  final double base;
  final double top;
  final double originalValue;
}

/// Layout metrics for stacked bars.
class _StackedBarLayout {
  const _StackedBarLayout({
    required this.categoryWidth,
    required this.groupWidth,
    required this.barWidth,
    this.categorySpacing = 0,
    this.groupSpacing = 0,
    this.groupCount = 1,
  });

  final double categoryWidth;
  final double groupWidth;
  final double barWidth;
  final double categorySpacing;
  final double groupSpacing;
  final int groupCount;
}

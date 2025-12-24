import 'package:flutter/material.dart';
import '../engine/fusion_render_context.dart';
import '../../series/fusion_bar_series.dart';
import '../../data/fusion_data_point.dart';

/// Dedicated renderer for bar series with proper category positioning.
///
/// This renderer handles the complexity of bar chart layout:
/// - Category-based positioning (not continuous numeric)
/// - Grouped bars (multiple series side-by-side)
/// - Overlapped bars (when sideBySide is disabled)
/// - Track (background) bars
/// - Proper spacing between categories and bars
/// - Correct animation from baseline
class FusionBarSeriesRenderer {
  const FusionBarSeriesRenderer();

  /// Renders all bar series to the canvas.
  ///
  /// This is the main entry point for bar rendering. It handles:
  /// 1. Calculating layout metrics for all series
  /// 2. Rendering track bars (if enabled)
  /// 3. Rendering each bar with proper positioning
  /// 4. Applying styles (gradient, shadow, border)
  void render(
    Canvas canvas,
    FusionRenderContext context,
    List<FusionBarSeries> allBarSeries, {
    bool enableSideBySideSeriesPlacement = true,
  }) {
    final visibleSeries = allBarSeries.where((s) => s.visible).toList();
    if (visibleSeries.isEmpty) return;

    // Calculate layout metrics once for all series
    final layout = _calculateBarLayout(
      context,
      visibleSeries,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    // First pass: Render track bars (if any series has them enabled)
    final hasTrackBars = visibleSeries.any((s) => s.isTrackVisible);
    if (hasTrackBars) {
      for (int seriesIndex = 0; seriesIndex < visibleSeries.length; seriesIndex++) {
        final series = visibleSeries[seriesIndex];
        if (series.isTrackVisible) {
          _renderTrackBars(canvas, context, series, seriesIndex, visibleSeries.length, layout);
        }
      }
    }

    // Second pass: Render actual bars
    for (int seriesIndex = 0; seriesIndex < visibleSeries.length; seriesIndex++) {
      final series = visibleSeries[seriesIndex];
      _renderSeries(canvas, context, series, seriesIndex, visibleSeries.length, layout);
    }
  }

  /// Calculates layout metrics for bar positioning.
  _BarLayout _calculateBarLayout(
    FusionRenderContext context,
    List<FusionBarSeries> visibleSeries, {
    bool enableSideBySideSeriesPlacement = true,
  }) {
    final chartArea = context.chartArea;

    // Determine if this is a category or numeric X-axis
    // For bars, we typically use category positioning
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

    // Check if we should use category positioning
    // Category positioning: bars centered on integer indices (0, 1, 2, ...)
    // Numeric positioning: bars positioned at actual X values
    final useCategoryPositioning = _shouldUseCategoryPositioning(firstSeries);

    if (useCategoryPositioning) {
      return _calculateCategoryLayout(
        chartArea,
        visibleSeries,
        pointCount,
        enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
      );
    } else {
      return _calculateNumericLayout(
        context,
        visibleSeries,
        enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
      );
    }
  }

  /// Determines if category-based positioning should be used.
  ///
  /// For bar charts, this ALWAYS returns true because bar charts
  /// are inherently categorical - bars are positioned by index,
  /// not by their x value. The x value (or label) is only used
  /// for display purposes.
  bool _shouldUseCategoryPositioning(FusionBarSeries series) {
    // Bar charts ALWAYS use category positioning
    // X values are used for labels only, not for positioning
    return true;
  }

  /// Calculates layout for category-based bar positioning.
  _BarLayout _calculateCategoryLayout(
    Rect chartArea,
    List<FusionBarSeries> visibleSeries,
    int pointCount, {
    bool enableSideBySideSeriesPlacement = true,
  }) {
    final seriesCount = enableSideBySideSeriesPlacement ? visibleSeries.length : 1;

    // Total available width for all categories
    final totalWidth = chartArea.width;

    // Width allocated to each category (including spacing on edges)
    final categoryWidth = totalWidth / pointCount;

    // Spacing between category groups (10% of category width on each side)
    final categorySpacing = categoryWidth * 0.1;

    // Width available for the group of bars within a category
    final groupWidth = categoryWidth - (categorySpacing * 2);

    // Get the bar width ratio from the first series (all should be same)
    final barWidthRatio = visibleSeries.first.barWidth;

    // Calculate individual bar width within the group
    double barWidth;
    double barSpacing;

    if (!enableSideBySideSeriesPlacement) {
      // Overlapped mode: each bar takes barWidthRatio of group width
      barWidth = groupWidth * barWidthRatio;
      barSpacing = 0;
    } else if (seriesCount == 1) {
      // Single series: bar takes barWidthRatio of group width
      barWidth = groupWidth * barWidthRatio;
      barSpacing = 0;
    } else {
      // Multiple series: divide group width among bars with spacing
      final spacing = visibleSeries.first.spacing;

      // Total spacing between all bars
      final totalSpacingSpace = groupWidth * spacing * (seriesCount - 1) / seriesCount;

      // Remaining space for bars after removing spacing
      final availableBarSpace = groupWidth - totalSpacingSpace;

      // Each bar gets equal share of available space, then apply barWidthRatio
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

  /// Calculates layout for numeric X-axis bar positioning.
  ///
  /// Used when X values are actual numeric data, not categories.
  /// Bars are positioned at their X coordinate with fixed pixel width.
  _BarLayout _calculateNumericLayout(
    FusionRenderContext context,
    List<FusionBarSeries> visibleSeries, {
    bool enableSideBySideSeriesPlacement = true,
  }) {
    final chartArea = context.chartArea;
    final dataBounds = context.effectiveViewport;

    // Calculate bar width based on data density
    final firstSeries = visibleSeries.first;
    final pointCount = firstSeries.dataPoints.length;
    final seriesCount = enableSideBySideSeriesPlacement ? visibleSeries.length : 1;

    if (pointCount < 2) {
      // Single point: use fixed width
      return _BarLayout(
        categoryWidth: chartArea.width * 0.3,
        groupWidth: chartArea.width * 0.3,
        barWidth: chartArea.width * 0.3 / seriesCount,
        categorySpacing: 0,
        barSpacing: 0,
        useCategoryPositioning: false,
      );
    }

    // Calculate average gap between points
    final xRange = dataBounds.right - dataBounds.left;
    final avgGap = xRange / (pointCount - 1);

    // Convert to screen pixels
    final pixelGap = (avgGap / xRange) * chartArea.width;

    // Group width is 80% of the gap
    final groupWidth = pixelGap * 0.8;

    // Bar width divided among series
    final barWidthRatio = firstSeries.barWidth;
    final spacing = firstSeries.spacing;
    final barWidth = (groupWidth / seriesCount) * barWidthRatio;
    final barSpacing = (groupWidth / seriesCount) * spacing;

    return _BarLayout(
      categoryWidth: pixelGap,
      groupWidth: groupWidth,
      barWidth: barWidth,
      categorySpacing: pixelGap * 0.1,
      barSpacing: barSpacing,
      useCategoryPositioning: false,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );
  }

  /// Renders track (background) bars for a series.
  void _renderTrackBars(
    Canvas canvas,
    FusionRenderContext context,
    FusionBarSeries series,
    int seriesIndex,
    int totalSeriesCount,
    _BarLayout layout,
  ) {
    final chartArea = context.chartArea;
    final trackColor = series.trackColor ?? Colors.grey.withValues(alpha: 0.2);

    for (int pointIndex = 0; pointIndex < series.dataPoints.length; pointIndex++) {
      final point = series.dataPoints[pointIndex];

      // Calculate track rectangle (full height of chart area)
      final trackRect = _calculateTrackRect(
        chartArea: chartArea,
        context: context,
        point: point,
        pointIndex: pointIndex,
        seriesIndex: seriesIndex,
        totalSeriesCount: totalSeriesCount,
        layout: layout,
        series: series,
      );

      // Skip if track is outside visible area
      if (!chartArea.overlaps(trackRect)) continue;

      // Apply track padding
      final paddedRect = series.trackPadding > 0
          ? Rect.fromLTRB(
              trackRect.left + series.trackPadding,
              trackRect.top + series.trackPadding,
              trackRect.right - series.trackPadding,
              trackRect.bottom - series.trackPadding,
            )
          : trackRect;

      // Draw track fill
      final trackPaint = context.getPaint(color: trackColor, style: PaintingStyle.fill);

      if (series.borderRadius > 0) {
        final rRect = RRect.fromRectAndRadius(paddedRect, Radius.circular(series.borderRadius));
        canvas.drawRRect(rRect, trackPaint);
      } else {
        canvas.drawRect(paddedRect, trackPaint);
      }

      context.returnPaint(trackPaint);

      // Draw track border
      if (series.trackBorderWidth > 0 && series.trackBorderColor != null) {
        final borderPaint = context.getPaint(
          color: series.trackBorderColor!,
          strokeWidth: series.trackBorderWidth,
          style: PaintingStyle.stroke,
        );

        if (series.borderRadius > 0) {
          final rRect = RRect.fromRectAndRadius(paddedRect, Radius.circular(series.borderRadius));
          canvas.drawRRect(rRect, borderPaint);
        } else {
          canvas.drawRect(paddedRect, borderPaint);
        }

        context.returnPaint(borderPaint);
      }
    }
  }

  /// Calculates track rectangle (spans full Y range for vertical bars).
  Rect _calculateTrackRect({
    required Rect chartArea,
    required FusionRenderContext context,
    required FusionDataPoint point,
    required int pointIndex,
    required int seriesIndex,
    required int totalSeriesCount,
    required _BarLayout layout,
    required FusionBarSeries series,
  }) {
    if (series.isVertical) {
      // Vertical track: spans full height
      double barCenterX;

      if (layout.useCategoryPositioning) {
        // CRITICAL FIX: Use coordinate system for positioning
        barCenterX = context.dataXToScreenX(pointIndex.toDouble());

        if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
          final totalGroupWidth =
              totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
          final groupStartX = barCenterX - (totalGroupWidth / 2);
          final barOffset = (seriesIndex * (layout.barWidth + layout.barSpacing));
          barCenterX = groupStartX + barOffset + (layout.barWidth / 2);
        }
      } else {
        barCenterX = context.dataXToScreenX(point.x);

        if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
          final totalGroupWidth =
              totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
          final groupStartX = barCenterX - (totalGroupWidth / 2);
          final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
          barCenterX = groupStartX + barOffset + (layout.barWidth / 2);
        }
      }

      return Rect.fromLTRB(
        barCenterX - (layout.barWidth / 2),
        chartArea.top,
        barCenterX + (layout.barWidth / 2),
        chartArea.bottom,
      );
    } else {
      // Horizontal track: spans full width
      double barCenterY;

      if (layout.useCategoryPositioning) {
        // CRITICAL FIX: Use coordinate system for positioning
        barCenterY = context.dataYToScreenY(pointIndex.toDouble());

        if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
          final totalGroupWidth =
              totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
          final groupStartY = barCenterY - (totalGroupWidth / 2);
          final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
          barCenterY = groupStartY + barOffset + (layout.barWidth / 2);
        }
      } else {
        barCenterY = context.dataYToScreenY(point.y);

        if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
          final totalGroupWidth =
              totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
          final groupStartY = barCenterY - (totalGroupWidth / 2);
          final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
          barCenterY = groupStartY + barOffset + (layout.barWidth / 2);
        }
      }

      return Rect.fromLTRB(
        chartArea.left,
        barCenterY - (layout.barWidth / 2),
        chartArea.right,
        barCenterY + (layout.barWidth / 2),
      );
    }
  }

  /// Renders a single bar series.
  void _renderSeries(
    Canvas canvas,
    FusionRenderContext context,
    FusionBarSeries series,
    int seriesIndex,
    int totalSeriesCount,
    _BarLayout layout,
  ) {
    final chartArea = context.chartArea;
    final animationProgress = context.animationProgress;

    for (int pointIndex = 0; pointIndex < series.dataPoints.length; pointIndex++) {
      final point = series.dataPoints[pointIndex];

      // Calculate bar rectangle
      final barRect = _calculateBarRect(
        chartArea: chartArea,
        context: context,
        point: point,
        pointIndex: pointIndex,
        seriesIndex: seriesIndex,
        totalSeriesCount: totalSeriesCount,
        layout: layout,
        series: series,
        animationProgress: animationProgress,
      );

      // Skip if bar is outside visible area
      if (!chartArea.overlaps(barRect)) continue;

      // Render the bar
      _renderBar(canvas, context, barRect, series);
    }
  }

  /// Calculates the rectangle for a single bar.
  Rect _calculateBarRect({
    required Rect chartArea,
    required FusionRenderContext context,
    required FusionDataPoint point,
    required int pointIndex,
    required int seriesIndex,
    required int totalSeriesCount,
    required _BarLayout layout,
    required FusionBarSeries series,
    required double animationProgress,
  }) {
    if (series.isVertical) {
      return _calculateVerticalBarRect(
        chartArea: chartArea,
        context: context,
        point: point,
        pointIndex: pointIndex,
        seriesIndex: seriesIndex,
        totalSeriesCount: totalSeriesCount,
        layout: layout,
        animationProgress: animationProgress,
      );
    } else {
      return _calculateHorizontalBarRect(
        chartArea: chartArea,
        context: context,
        point: point,
        pointIndex: pointIndex,
        seriesIndex: seriesIndex,
        totalSeriesCount: totalSeriesCount,
        layout: layout,
        animationProgress: animationProgress,
      );
    }
  }

  /// Calculates vertical bar (column) rectangle.
  Rect _calculateVerticalBarRect({
    required Rect chartArea,
    required FusionRenderContext context,
    required FusionDataPoint point,
    required int pointIndex,
    required int seriesIndex,
    required int totalSeriesCount,
    required _BarLayout layout,
    required double animationProgress,
  }) {
    double barCenterX;

    if (layout.useCategoryPositioning) {
      // CRITICAL FIX: Use coordinate system for positioning
      // This ensures bars align perfectly with axis labels
      // The coordinate system has bounds -0.5 to N-0.5, so index i maps to center of category
      barCenterX = context.dataXToScreenX(pointIndex.toDouble());

      // Offset for grouped bars (only when side-by-side is enabled)
      if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
        final totalGroupWidth =
            totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
        final groupStartX = barCenterX - (totalGroupWidth / 2);
        final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
        barCenterX = groupStartX + barOffset + (layout.barWidth / 2);
      }
    } else {
      // Numeric positioning: use coordinate system
      barCenterX = context.dataXToScreenX(point.x);

      // Offset for grouped bars (only when side-by-side is enabled)
      if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
        final totalGroupWidth =
            totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
        final groupStartX = barCenterX - (totalGroupWidth / 2);
        final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
        barCenterX = groupStartX + barOffset + (layout.barWidth / 2);
      }
    }

    // Calculate Y positions
    final baselineY = context.dataYToScreenY(0);
    final topY = context.dataYToScreenY(point.y);

    // Apply animation (grow from baseline)
    final animatedTopY = baselineY + (topY - baselineY) * animationProgress;

    // Handle negative values
    final actualTop = animatedTopY < baselineY ? animatedTopY : baselineY;
    final actualBottom = animatedTopY < baselineY ? baselineY : animatedTopY;

    return Rect.fromLTRB(
      barCenterX - (layout.barWidth / 2),
      actualTop,
      barCenterX + (layout.barWidth / 2),
      actualBottom,
    );
  }

  /// Calculates horizontal bar rectangle.
  Rect _calculateHorizontalBarRect({
    required Rect chartArea,
    required FusionRenderContext context,
    required FusionDataPoint point,
    required int pointIndex,
    required int seriesIndex,
    required int totalSeriesCount,
    required _BarLayout layout,
    required double animationProgress,
  }) {
    double barCenterY;

    if (layout.useCategoryPositioning) {
      // CRITICAL FIX: Use coordinate system for positioning
      // This ensures bars align perfectly with axis labels
      barCenterY = context.dataYToScreenY(pointIndex.toDouble());

      // Offset for grouped bars (only when side-by-side is enabled)
      if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
        final totalGroupWidth =
            totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
        final groupStartY = barCenterY - (totalGroupWidth / 2);
        final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
        barCenterY = groupStartY + barOffset + (layout.barWidth / 2);
      }
    } else {
      // Numeric positioning: use coordinate system
      barCenterY = context.dataYToScreenY(point.y);

      // Offset for grouped bars (only when side-by-side is enabled)
      if (totalSeriesCount > 1 && layout.enableSideBySideSeriesPlacement) {
        final totalGroupWidth =
            totalSeriesCount * layout.barWidth + (totalSeriesCount - 1) * layout.barSpacing;
        final groupStartY = barCenterY - (totalGroupWidth / 2);
        final barOffset = seriesIndex * (layout.barWidth + layout.barSpacing);
        barCenterY = groupStartY + barOffset + (layout.barWidth / 2);
      }
    }

    // Calculate X positions
    final baselineX = context.dataXToScreenX(0);
    final rightX = context.dataXToScreenX(point.x);

    // Apply animation (grow from baseline)
    final animatedRightX = baselineX + (rightX - baselineX) * animationProgress;

    // Handle negative values
    final actualLeft = animatedRightX < baselineX ? animatedRightX : baselineX;
    final actualRight = animatedRightX < baselineX ? baselineX : animatedRightX;

    return Rect.fromLTRB(
      actualLeft,
      barCenterY - (layout.barWidth / 2),
      actualRight,
      barCenterY + (layout.barWidth / 2),
    );
  }

  /// Renders a single bar with all styling.
  void _renderBar(
    Canvas canvas,
    FusionRenderContext context,
    Rect barRect,
    FusionBarSeries series,
  ) {
    // Skip zero-height bars
    if (barRect.height <= 0 || barRect.width <= 0) return;

    final paint = context.getPaint(color: series.color, style: PaintingStyle.fill);

    // Apply gradient if specified
    if (series.gradient != null) {
      paint.shader = context.shaderCache.getLinearGradient(series.gradient!, barRect);
    }

    // Draw shadow first (underneath bar)
    if (series.showShadow && series.shadow != null) {
      _renderShadow(canvas, barRect, series.shadow!, series.borderRadius);
    }

    // Draw bar (with optional rounded corners)
    if (series.borderRadius > 0) {
      final rRect = RRect.fromRectAndRadius(barRect, Radius.circular(series.borderRadius));
      canvas.drawRRect(rRect, paint);
    } else {
      canvas.drawRect(barRect, paint);
    }

    context.returnPaint(paint);

    // Draw border
    if (series.borderColor != null && series.borderWidth > 0) {
      _renderBorder(canvas, context, barRect, series);
    }
  }

  /// Renders bar shadow.
  void _renderShadow(Canvas canvas, Rect barRect, BoxShadow shadow, double borderRadius) {
    final shadowPaint = Paint()
      ..color = shadow.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

    final shadowRect = barRect.shift(shadow.offset);

    if (borderRadius > 0) {
      final shadowRRect = RRect.fromRectAndRadius(shadowRect, Radius.circular(borderRadius));
      canvas.drawRRect(shadowRRect, shadowPaint);
    } else {
      canvas.drawRect(shadowRect, shadowPaint);
    }
  }

  /// Renders bar border.
  void _renderBorder(
    Canvas canvas,
    FusionRenderContext context,
    Rect barRect,
    FusionBarSeries series,
  ) {
    final borderPaint = context.getPaint(
      color: series.borderColor!,
      strokeWidth: series.borderWidth,
      style: PaintingStyle.stroke,
    );

    if (series.borderRadius > 0) {
      final rRect = RRect.fromRectAndRadius(barRect, Radius.circular(series.borderRadius));
      canvas.drawRRect(rRect, borderPaint);
    } else {
      canvas.drawRect(barRect, borderPaint);
    }

    context.returnPaint(borderPaint);
  }
}

/// Internal class holding bar layout metrics.
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

  /// Total width allocated to each category
  final double categoryWidth;

  /// Width of the bar group within a category
  final double groupWidth;

  /// Width of individual bars
  final double barWidth;

  /// Spacing on edges of each category
  final double categorySpacing;

  /// Spacing between bars in a group
  final double barSpacing;

  /// Whether to use category-based positioning
  final bool useCategoryPositioning;

  /// Whether bars are placed side-by-side or overlapped
  final bool enableSideBySideSeriesPlacement;
}

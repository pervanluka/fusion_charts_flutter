// lib/src/rendering/layers/fusion_series_layer.dart

import 'package:flutter/material.dart';
import 'fusion_render_layer.dart';
import '../engine/fusion_render_context.dart';
import '../../series/series_with_data_points.dart';
import '../../series/fusion_line_series.dart';
import '../../series/fusion_bar_series.dart';
import '../fusion_path_builder.dart';
import '../../data/fusion_data_point.dart';

/// Renders all chart series (lines, bars, areas, etc.).
///
/// This is the **CORE** rendering layer where actual data visualization happens.
/// All series types are rendered here based on their type.
///
/// ## Architecture
///
/// ```
/// FusionSeriesLayer
///   ├─> Line Series Renderer
///   ├─> Bar Series Renderer
///   ├─> Area Series Renderer
///   └─> Scatter Series Renderer
/// ```
///
/// ## Rendering Order
///
/// 1. Series are rendered in the order they appear in the list
/// 2. Each series is clipped to the chart area
/// 3. Animations are applied per series
/// 4. Gradients and effects are handled
///
/// ## Performance
///
/// - Uses Paint pooling from context
/// - Shader caching for gradients
/// - Path reuse when possible
/// - Efficient clipping
///
/// ## Example
///
/// ```dart
/// final seriesLayer = FusionSeriesLayer(
///   series: [
///     FusionLineSeries(...),
///     FusionBarSeries(...),
///   ],
/// );
///
/// pipeline.addLayer(seriesLayer);
/// ```
class FusionSeriesLayer extends FusionRenderLayer {
  /// Creates a series rendering layer.
  FusionSeriesLayer({
    required this.series,
    this.enableAntiAliasing = true,
    this.clipToChartArea = true,
  }) : super(
         name: 'series',
         zIndex: 50, // Middle layer (after grid, before markers)
         cacheable: false, // Series change frequently, don't cache
         clipRect: null, // We handle clipping internally
       );

  /// All series to render.
  final List<SeriesWithDataPoints> series;

  /// Whether to enable anti-aliasing for smooth rendering.
  final bool enableAntiAliasing;

  /// Whether to clip series rendering to chart area.
  final bool clipToChartArea;

  // ==========================================================================
  // MAIN PAINT METHOD
  // ==========================================================================

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    // Apply chart area clipping if enabled
    if (clipToChartArea) {
      canvas.save();
      canvas.clipRect(context.chartArea);
    }

    try {
      // Render each series based on its type
      for (final seriesData in series) {
        if (!seriesData.visible || seriesData.dataPoints.isEmpty) continue;

        // Type-based rendering dispatch
        if (seriesData is FusionLineSeries) {
          _renderLineSeries(canvas, context, seriesData);
        } else if (seriesData is FusionBarSeries) {
          _renderBarSeries(canvas, context, seriesData);
        }
        // Future: Add more series types here
        // else if (seriesData is FusionAreaSeries) { ... }
        // else if (seriesData is FusionScatterSeries) { ... }
      }
    } finally {
      if (clipToChartArea) {
        canvas.restore();
      }
    }
  }

  // ==========================================================================
  // LINE SERIES RENDERING
  // ==========================================================================

  /// Renders a line series.
  void _renderLineSeries(Canvas canvas, FusionRenderContext context, FusionLineSeries series) {
    final points = _getAnimatedPoints(series.dataPoints, context.animationProgress);
    if (points.isEmpty) return;

    // Build the path
    var path = series.isCurved
        ? FusionPathBuilder.createSmoothPath(
            points,
            context.coordSystem,
            smoothness: series.smoothness,
          )
        : FusionPathBuilder.createLinePath(points, context.coordSystem);

    if (series.lineDashArray != null && series.lineDashArray!.isNotEmpty) {
      path = FusionPathBuilder.createDashedPath(path, series.lineDashArray!);
    }

    final paint = context.getPaint(
      color: series.color,
      strokeWidth: series.lineWidth,
      style: PaintingStyle.stroke,
    );

    // Apply gradient if specified
    if (series.gradient != null) {
      paint.shader = context.shaderCache.getLinearGradient(series.gradient!, context.chartArea);
    }

    // Apply shadow if enabled
    if (series.showShadow && series.shadow != null) {
      _applyShadow(canvas, path, series.shadow!);
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Return paint to pool
    context.returnPaint(paint);
  }

  // ==========================================================================
  // BAR SERIES RENDERING
  // ==========================================================================

  /// Renders a bar series.
  void _renderBarSeries(Canvas canvas, FusionRenderContext context, FusionBarSeries series) {
    if (series.dataPoints.isEmpty) return;

    // Calculate bar width
    final barWidth = _calculateBarWidth(context, series);

    // Render each bar
    for (int i = 0; i < series.dataPoints.length; i++) {
      final point = series.dataPoints[i];
      final animatedPoint = _getAnimatedPoint(point, context.animationProgress);

      // Calculate bar rectangle
      final barRect = _calculateBarRect(context, animatedPoint, i, barWidth, series);

      // Render the bar
      _renderSingleBar(canvas, context, barRect, series);
    }
  }

  /// Renders a single bar with all styling.
  void _renderSingleBar(
    Canvas canvas,
    FusionRenderContext context,
    Rect barRect,
    FusionBarSeries series,
  ) {
    // Get paint from pool
    final paint = context.getPaint(color: series.color, style: PaintingStyle.fill);

    // Apply gradient if specified
    if (series.gradient != null) {
      paint.shader = context.shaderCache.getLinearGradient(series.gradient!, barRect);
    }

    // Draw bar with optional rounded corners
    if (series.borderRadius > 0) {
      final rRect = RRect.fromRectAndRadius(barRect, Radius.circular(series.borderRadius));

      // Apply shadow if enabled
      if (series.showShadow && series.shadow != null) {
        _applyShadowToRRect(canvas, rRect, series.shadow!);
      }

      canvas.drawRRect(rRect, paint);
    } else {
      // Apply shadow if enabled
      if (series.showShadow && series.shadow != null) {
        _applyShadowToRect(canvas, barRect, series.shadow!);
      }

      canvas.drawRect(barRect, paint);
    }

    // Return paint to pool
    context.returnPaint(paint);

    // Draw border if specified
    if (series.borderColor != null && series.borderWidth > 0) {
      _renderBarBorder(canvas, context, barRect, series);
    }
  }

  /// Renders bar border.
  void _renderBarBorder(
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

  // ==========================================================================
  // HELPER METHODS - BAR CALCULATIONS
  // ==========================================================================

  /// Calculates the width of each bar.
  double _calculateBarWidth(FusionRenderContext context, FusionBarSeries series) {
    final plotWidth = context.chartArea.width;
    final pointCount = series.dataPoints.length;

    if (pointCount == 0) return 0;

    // Available width per category
    final categoryWidth = plotWidth / pointCount;

    // Bar width as percentage of category width
    return categoryWidth * series.barWidth;
  }

  /// Calculates the rectangle for a single bar.
  Rect _calculateBarRect(
    FusionRenderContext context,
    FusionDataPoint point,
    int index,
    double barWidth,
    FusionBarSeries series,
  ) {
    if (series.isVertical) {
      return _calculateVerticalBarRect(context, point, barWidth);
    } else {
      return _calculateHorizontalBarRect(context, point, barWidth);
    }
  }

  /// Calculates vertical bar rectangle (column chart).
  Rect _calculateVerticalBarRect(
    FusionRenderContext context,
    FusionDataPoint point,
    double barWidth,
  ) {
    final screenPos = context.coordSystem.dataToScreen(point);
    final baselineY = context.coordSystem.dataToScreen(FusionDataPoint(point.x, 0)).dy;

    final centerX = screenPos.dx;
    final topY = screenPos.dy;
    final bottomY = baselineY;

    return Rect.fromLTRB(
      centerX - barWidth / 2,
      topY < bottomY ? topY : bottomY, // Handle negative values
      centerX + barWidth / 2,
      topY < bottomY ? bottomY : topY,
    );
  }

  /// Calculates horizontal bar rectangle (bar chart).
  Rect _calculateHorizontalBarRect(
    FusionRenderContext context,
    FusionDataPoint point,
    double barWidth,
  ) {
    final screenPos = context.coordSystem.dataToScreen(point);
    final baselineX = context.coordSystem.dataToScreen(FusionDataPoint(0, point.y)).dx;

    final centerY = screenPos.dy;
    final leftX = baselineX;
    final rightX = screenPos.dx;

    return Rect.fromLTRB(
      leftX < rightX ? leftX : rightX, // Handle negative values
      centerY - barWidth / 2,
      leftX < rightX ? rightX : leftX,
      centerY + barWidth / 2,
    );
  }

  // ==========================================================================
  // HELPER METHODS - ANIMATION
  // ==========================================================================

  /// Returns animated subset of points based on animation progress.
  List<FusionDataPoint> _getAnimatedPoints(List<FusionDataPoint> points, double animationProgress) {
    if (animationProgress >= 1.0) return points;
    if (points.isEmpty) return points;

    final visibleCount = (points.length * animationProgress).ceil();
    return points.sublist(0, visibleCount.clamp(1, points.length));
  }

  /// Returns animated point (scales Y value for bars).
  FusionDataPoint _getAnimatedPoint(FusionDataPoint point, double animationProgress) {
    if (animationProgress >= 1.0) return point;

    return FusionDataPoint(
      point.x,
      point.y * animationProgress,
      label: point.label,
      metadata: point.metadata,
    );
  }

  // ==========================================================================
  // HELPER METHODS - SHADOWS
  // ==========================================================================

  /// Applies shadow to a path (for lines).
  void _applyShadow(Canvas canvas, Path path, BoxShadow shadow) {
    final shadowPaint = Paint()
      ..color = shadow.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.save();
    canvas.translate(shadow.offset.dx, shadow.offset.dy);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();
  }

  /// Applies shadow to a rectangle.
  void _applyShadowToRect(Canvas canvas, Rect rect, BoxShadow shadow) {
    final shadowPaint = Paint()
      ..color = shadow.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

    final shadowRect = rect.shift(shadow.offset);
    canvas.drawRect(shadowRect, shadowPaint);
  }

  /// Applies shadow to a rounded rectangle.
  void _applyShadowToRRect(Canvas canvas, RRect rRect, BoxShadow shadow) {
    final shadowPaint = Paint()
      ..color = shadow.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

    final shadowRRect = rRect.shift(shadow.offset);
    canvas.drawRRect(shadowRRect, shadowPaint);
  }

  // ==========================================================================
  // LAYER LIFECYCLE
  // ==========================================================================

  @override
  bool shouldRepaint(covariant FusionSeriesLayer oldLayer) {
    // Repaint if series data changed
    if (oldLayer.series.length != series.length) return true;

    for (int i = 0; i < series.length; i++) {
      if (oldLayer.series[i] != series[i]) return true;
    }

    return false;
  }

  @override
  String toString() {
    return 'FusionSeriesLayer(series: ${series.length}, '
        'antiAliasing: $enableAntiAliasing, '
        'clipping: $clipToChartArea)';
  }
}

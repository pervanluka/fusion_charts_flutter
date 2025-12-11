import 'package:flutter/material.dart';
import 'fusion_render_layer.dart';
import 'fusion_bar_series_renderer.dart';
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
    this.enableSideBySideSeriesPlacement = true,
  }) : super(
         name: 'series',
         zIndex: 50, // Middle layer (after grid, before markers)
         cacheable: false, // Series change frequently, don't cache
         clipRect: null, // We handle clipping internally
       );

  /// Dedicated bar series renderer for proper category positioning.
  static const _barRenderer = FusionBarSeriesRenderer();

  /// All series to render.
  final List<SeriesWithDataPoints> series;

  /// Whether to enable anti-aliasing for smooth rendering.
  final bool enableAntiAliasing;

  /// Whether to clip series rendering to chart area.
  final bool clipToChartArea;

  /// Whether to place bar series side-by-side (grouped) or overlapped.
  ///
  /// When `true` (default), multiple bar series are rendered side-by-side.
  /// When `false`, bar series are rendered on top of each other.
  final bool enableSideBySideSeriesPlacement;

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

  /// Renders all bar series using the dedicated bar renderer.
  ///
  /// The bar renderer handles:
  /// - Category-based positioning
  /// - Grouped bars for multiple series
  /// - Overlapped bars (when sideBySide is disabled)
  /// - Track bars
  /// - Proper spacing and alignment
  /// - Animation from baseline
  void _renderBarSeries(Canvas canvas, FusionRenderContext context, FusionBarSeries series) {
    // Collect all visible bar series for grouped rendering
    final allBarSeries = this.series.whereType<FusionBarSeries>().where((s) => s.visible).toList();

    // Only render once (when processing the first bar series)
    // The renderer handles all series together for proper grouping
    if (allBarSeries.isNotEmpty && series == allBarSeries.first) {
      _barRenderer.render(
        canvas,
        context,
        allBarSeries,
        enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
      );
    }
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

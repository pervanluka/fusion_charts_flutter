import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

import '../../core/axis/base/fusion_axis_base.dart';
import '../../core/axis/category/fusion_category_axis.dart';
import '../../core/axis/numeric/fusion_numeric_axis.dart';
import '../engine/fusion_render_pipeline.dart';
import '../engine/fusion_render_context.dart';
import '../engine/fusion_paint_pool.dart';
import '../engine/fusion_shader_cache.dart';
import '../layers/fusion_render_layer.dart';
import '../layers/fusion_series_layer.dart';
import '../layers/fusion_data_label_layer.dart';
import '../layers/fusion_tooltip_layer.dart';
import '../layers/fusion_crosshair_layer.dart';

/// Professional painter for bar charts using modern render pipeline.
///
/// ## Features
///
/// - **Vertical bars** (column charts)
/// - **Horizontal bars** (bar charts)
/// - **Grouped bars** (multiple series)
/// - **Stacked bars** (coming soon)
/// - **Rounded corners**
/// - **Gradients**
/// - **Shadows**
/// - **Borders**
///
/// ## Architecture
///
/// Uses the same layer-based pipeline as FusionLineChartPainter for
/// consistency and maintainability.
///
/// ## Rendering Pipeline
///
/// ```
/// FusionBarChartPainter
///   └─> FusionRenderPipeline
///       ├─> BackgroundLayer
///       ├─> GridLayer
///       ├─> SeriesLayer ⭐ Bars rendered here
///       ├─> DataLabelLayer
///       ├─> AxisLayer
///       ├─> TooltipLayer
///       └─> CrosshairLayer
/// ```
///
/// ## Performance
///
/// - Efficient bar calculation
/// - Paint pooling
/// - Shader caching for gradients
/// - Optimized for 1000+ bars
///
/// ## Example
///
/// ```dart
/// CustomPaint(
///   painter: FusionBarChartPainter(
///     series: [
///       FusionBarSeries(
///         name: 'Sales',
///         dataPoints: data,
///         color: Colors.blue,
///         barWidth: 0.6,
///         borderRadius: 4.0,
///       ),
///     ],
///     coordSystem: coordSystem,
///     theme: FusionLightTheme(),
///   ),
/// )
/// ```
class FusionBarChartPainter extends CustomPainter {
  /// Creates a bar chart painter.
  FusionBarChartPainter({
    required this.series,
    required this.coordSystem,
    required this.theme,
    required this.paintPool,
    required this.shaderCache,
    this.xAxis,
    this.yAxis,
    this.config,
    this.animationProgress = 1.0,
    this.tooltipData,
    this.crosshairPosition,
    this.crosshairPoint,
  });

  /// All bar series to render.
  final List<FusionBarSeries> series;

  /// Coordinate transformation system.
  final FusionCoordinateSystem coordSystem;

  /// Chart theme.
  final FusionChartTheme theme;

  /// X-axis configuration.
  final FusionAxisConfiguration? xAxis;

  /// Y-axis configuration.
  final FusionAxisConfiguration? yAxis;

  /// Chart configuration.
  final FusionChartConfiguration? config;

  /// Animation progress (0.0 to 1.0).
  final double animationProgress;

  /// Paint object pool.
  final FusionPaintPool paintPool;

  /// Shader cache.
  final FusionShaderCache shaderCache;

  /// Current tooltip data (if showing).
  final TooltipRenderData? tooltipData;

  /// Current crosshair position (if showing).
  final Offset? crosshairPosition;

  /// Current crosshair point (if showing).
  final FusionDataPoint? crosshairPoint;

  /// Cached render pipeline.
  FusionRenderPipeline? _pipeline;

  // ==========================================================================
  // MAIN PAINT METHOD
  // ==========================================================================

  @override
  void paint(Canvas canvas, Size size) {
    // Build render pipeline if not cached
    _pipeline ??= _buildRenderPipeline(size);

    // Create render context
    final context = _createRenderContext(size);

    // Execute render pipeline
    _pipeline!.render(canvas, size, context);
  }

  // ==========================================================================
  // RENDER PIPELINE CONSTRUCTION
  // ==========================================================================

  /// Builds the complete render pipeline with all layers.
  FusionRenderPipeline _buildRenderPipeline(Size size) {
    final effectiveConfig = config ?? const FusionChartConfiguration();

    return FusionRenderPipeline(
      layers: [
        // Layer 0: Background
        FusionBackgroundLayer(color: theme.backgroundColor),

        // Layer 10: Grid (if enabled)
        if (effectiveConfig.enableGrid) FusionGridLayer(showHorizontal: true, showVertical: true),

        // Layer 50: Series (BARS)
        FusionSeriesLayer(
          series: series.cast<SeriesWithDataPoints>(),
          enableAntiAliasing: true,
          clipToChartArea: true,
        ),

        // Layer 70: Data Labels (if enabled)
        if (effectiveConfig.enableDataLabels)
          FusionDataLabelLayer(series: series.cast<SeriesWithDataPoints>()),

        // Layer 90: Axes (if enabled)
        if (effectiveConfig.enableAxis) FusionAxisLayer(showXAxis: true, showYAxis: true),

        // Layer 1000: Tooltip (if showing)
        if (tooltipData != null && effectiveConfig.enableTooltip)
          FusionTooltipLayer(
            tooltipData: tooltipData,
            tooltipBehavior: effectiveConfig.tooltipBehavior,
          ),

        // Layer 1001: Crosshair (if showing)
        if (crosshairPosition != null && effectiveConfig.enableCrosshair)
          FusionCrosshairLayer(
            position: crosshairPosition!,
            snappedPoint: crosshairPoint,
            crosshairConfig: FusionCrosshairConfiguration(),
          ),
      ],
      enableProfiling: false,
    );
  }

  // ==========================================================================
  // RENDER CONTEXT CREATION
  // ==========================================================================

  /// Creates render context with all necessary information.
  FusionRenderContext _createRenderContext(Size size) {
    // Calculate chart area (plot area excluding margins)
    final chartArea = _calculateChartArea(size);

    // Calculate data bounds from all visible series
    final dataBounds = _calculateDataBounds();

    // Determine axis types
    final xAxisDefinition = _determineXAxisType(series);
    final yAxisDefinition = _determineYAxisType(series);

    return FusionRenderContext(
      chartArea: chartArea,
      coordSystem: coordSystem,
      theme: theme,
      paintPool: paintPool,
      shaderCache: shaderCache,
      xAxis: xAxis,
      yAxis: yAxis,
      xAxisDefinition: xAxisDefinition,
      yAxisDefinition: yAxisDefinition,
      animationProgress: animationProgress,
      enableAntiAliasing: true,
      devicePixelRatio: 1.0,
      dataBounds: dataBounds,
      viewportBounds: null,
    );
  }

  // Determine X-axis type for bars
  FusionAxisBase _determineXAxisType(List<FusionBarSeries> series) {
    // For vertical bars, X-axis can be category
    // Check if all series have labels
    final hasLabels = series.every(
      (s) => s.dataPoints.every((p) => p.label != null && p.label!.isNotEmpty),
    );

    if (hasLabels) {
      // Extract categories from first series
      final categories = series.first.dataPoints.map((p) => p.label!).toList();

      return FusionCategoryAxis(categories: categories);
    }

    // Default to numeric
    return const FusionNumericAxis();
  }

  // Determine Y-axis type for bars
  FusionAxisBase _determineYAxisType(List<FusionBarSeries> series) {
    // Always numeric for bar values
    return const FusionNumericAxis();
  }

  /// Calculates chart area (plot area excluding margins for axes).
  Rect _calculateChartArea(Size size) {
    final effectiveConfig = config ?? const FusionChartConfiguration();

    // Margins depend on whether we're vertical or horizontal
    final isVertical = series.isEmpty || series.first.isVertical;

    final leftMargin = effectiveConfig.enableAxis
        ? (isVertical ? 60.0 : 80.0) // More space for value labels
        : 10.0;
    final rightMargin = 10.0;
    final topMargin = 10.0;
    final bottomMargin = effectiveConfig.enableAxis
        ? (isVertical ? 40.0 : 60.0) // More space for category labels
        : 10.0;

    return Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );
  }

  /// Calculates data bounds from all visible series.
  Rect _calculateDataBounds() {
    final allPoints = series.where((s) => s.visible).expand((s) => s.dataPoints).toList();

    if (allPoints.isEmpty) {
      return Rect.fromLTRB(0, 0, 10, 100);
    }

    final minX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final maxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);

    // For bars, we want to start at 0 (baseline)
    final minY = 0.0;
    final maxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // ==========================================================================
  // CUSTOM PAINTER OVERRIDES
  // ==========================================================================

  @override
  bool shouldRepaint(covariant FusionBarChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.theme != theme ||
        oldDelegate.tooltipData != tooltipData ||
        oldDelegate.crosshairPosition != crosshairPosition ||
        oldDelegate.coordSystem != coordSystem;
  }

  @override
  bool? hitTest(Offset position) => true;

  /// Invalidates cached pipeline.
  void invalidateCache() {
    _pipeline = null;
  }
}

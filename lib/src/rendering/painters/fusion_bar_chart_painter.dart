import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

import '../engine/fusion_paint_pool.dart';
import '../engine/fusion_render_context.dart';
import '../engine/fusion_render_pipeline.dart';
import '../engine/fusion_shader_cache.dart';
import '../layers/fusion_crosshair_layer.dart';
import '../layers/fusion_data_label_layer.dart';
import '../layers/fusion_render_layer.dart';
import '../layers/fusion_series_layer.dart';
import '../layers/fusion_tooltip_layer.dart';

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
    // Dispose previous pipeline to prevent memory leaks from cached Picture objects
    _pipeline?.dispose();

    // Always rebuild pipeline to ensure config changes are reflected
    _pipeline = _buildRenderPipeline(size);

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

    // Get bar-specific config, use defaults if base config provided
    final enableSideBySide =
        config is! FusionBarChartConfiguration ||
        (config! as FusionBarChartConfiguration)
            .enableSideBySideSeriesPlacement;

    return FusionRenderPipeline(
      layers: [
        // Layer 0: Background
        FusionBackgroundLayer(color: theme.backgroundColor),

        // Layer 10: Grid (if enabled)
        if (effectiveConfig.enableGrid)
          FusionGridLayer(showHorizontal: true, showVertical: true),

        // Layer 50: Series (BARS)
        FusionSeriesLayer(
          series: series.cast<SeriesWithDataPoints>(),
          enableAntiAliasing: true,
          clipToChartArea: true,
          enableSideBySideSeriesPlacement: enableSideBySide,
        ),

        // Layer 70: Data Labels (if enabled)
        if (effectiveConfig.enableDataLabels)
          FusionDataLabelLayer(series: series.cast<SeriesWithDataPoints>()),

        // Layer 90: Axes (if enabled)
        if (effectiveConfig.enableAxis)
          FusionAxisLayer(showXAxis: true, showYAxis: true),

        // Layer 95: Border (if enabled)
        if (effectiveConfig.enableBorder) FusionBorderLayer(),

        // Layer 1000: Tooltip (if showing)
        if (tooltipData != null && effectiveConfig.enableTooltip)
          FusionTooltipLayer(
            tooltipData: tooltipData,
            tooltipBehavior: effectiveConfig.tooltipBehavior,
          ),

        // Layer 1001: Crosshair (if showing)
        if (crosshairPosition != null && effectiveConfig.enableCrosshair)
          FusionCrosshairLayer(
            position: crosshairPosition,
            snappedPoint: crosshairPoint,
            crosshairConfig: effectiveConfig.crosshairBehavior,
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
      useDiscreteBucketGridX: true,
    );
  }

  /// Determine X-axis type from configuration or auto-detect for bars.
  FusionAxisBase _determineXAxisType(List<FusionBarSeries> series) {
    // 1. User-provided axis type takes priority
    if (xAxis?.axisType != null) {
      return xAxis!.axisType!;
    }

    // 2. Auto-detect for bar charts
    if (series.isEmpty) return const FusionNumericAxis();

    // For bar charts, X-axis is always category-based
    // Labels come from: point.label > point.x.toString()
    final categories = series.first.dataPoints.map((p) {
      if (p.label != null && p.label!.isNotEmpty) {
        return p.label!;
      }
      // Use x value as label (format nicely)
      return p.x == p.x.roundToDouble()
          ? p.x.round().toString()
          : p.x.toString();
    }).toList();

    return FusionCategoryAxis(categories: categories);
  }

  /// Determine Y-axis type from configuration or default to numeric.
  FusionAxisBase _determineYAxisType(List<FusionBarSeries> series) {
    // User-provided axis type takes priority
    if (yAxis?.axisType != null) {
      return yAxis!.axisType!;
    }

    // Default: numeric for bar values
    return const FusionNumericAxis();
  }

  /// Calculates chart area from the coordinate system.
  /// This ensures consistency between coordinate transformations and rendering.
  Rect _calculateChartArea(Size size) {
    // Use the chart area from the coordinate system for consistency
    return coordSystem.chartArea;
  }

  /// Calculates data bounds from all visible series.
  Rect _calculateDataBounds() {
    final allPoints = series
        .where((s) => s.visible)
        .expand((s) => s.dataPoints)
        .toList();

    if (allPoints.isEmpty) {
      return Rect.fromLTRB(0, 0, 10, 100);
    }

    // For bar charts, X bounds should include half-bar padding
    // This centers bars within their grid cells
    final pointCount = series.first.dataPoints.length;
    const minX = -0.5; // Half bar width before first bar
    final maxX = pointCount - 0.5; // Half bar width after last bar

    // For bars, we want to start at 0 (baseline)
    const minY = 0.0;
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

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_line_chart_configuration.dart';

import '../../configuration/fusion_axis_configuration.dart';
import '../../configuration/fusion_chart_configuration.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../core/axis/base/fusion_axis_base.dart';
import '../../core/axis/numeric/fusion_numeric_axis.dart';
import '../../data/fusion_data_point.dart';
import '../../series/fusion_line_series.dart';
import '../../series/series_with_data_points.dart';
import '../../themes/fusion_chart_theme.dart';
import '../engine/fusion_paint_pool.dart';
import '../engine/fusion_render_context.dart';
import '../engine/fusion_render_pipeline.dart';
import '../engine/fusion_shader_cache.dart';
import '../fusion_coordinate_system.dart';
import '../layers/fusion_crosshair_layer.dart';
import '../layers/fusion_data_label_layer.dart';
import '../layers/fusion_marker_layer.dart';
import '../layers/fusion_render_layer.dart';
import '../layers/fusion_series_layer.dart';
import '../layers/fusion_tooltip_layer.dart';

/// Professional painter for line charts using modern render pipeline.
///
/// ## Architecture
///
/// Instead of traditional monolithic painting, this uses a **layer-based
/// rendering pipeline** for:
/// - Better separation of concerns
/// - Independent layer caching
/// - Easier debugging and profiling
/// - Extensibility
///
/// ## Rendering Pipeline
///
/// ```
/// FusionLineChartPainter
///   └─> FusionRenderPipeline
///       ├─> BackgroundLayer (z: 0)
///       ├─> GridLayer (z: 10)
///       ├─> SeriesLayer (z: 50) ⭐ Main content
///       ├─> MarkerLayer (z: 60)
///       ├─> DataLabelLayer (z: 70)
///       ├─> AxisLayer (z: 90)
///       ├─> TooltipLayer (z: 1000)
///       └─> CrosshairLayer (z: 1001)
/// ```
///
/// ## Performance
///
/// - Object pooling for Paint instances
/// - Shader caching for gradients
/// - Layer-based selective repainting
/// - Efficient coordinate transformations
class FusionLineChartPainter extends CustomPainter {
  /// Creates a line chart painter.
  FusionLineChartPainter({
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

  /// All line series to render.
  final List<FusionLineSeries> series;

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

    // Build render pipeline
    _pipeline = _buildRenderPipeline(size);

    // Create render context using coordSystem.chartArea
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

    // Get line-specific config, use defaults if base config provided
    final enableMarkers =
        config is FusionLineChartConfiguration &&
        (config! as FusionLineChartConfiguration).enableMarkers;

    return FusionRenderPipeline(
      layers: [
        // Layer 0: Background
        FusionBackgroundLayer(color: theme.backgroundColor),

        // Layer 10: Grid (if enabled)
        if (effectiveConfig.enableGrid)
          FusionGridLayer(showHorizontal: true, showVertical: true),

        // Layer 50: Series (MAIN CONTENT)
        FusionSeriesLayer(
          series: series.cast<SeriesWithDataPoints>(),
          enableAntiAliasing: true,
          clipToChartArea: true,
        ),

        // Layer 60: Markers (if enabled)
        if (enableMarkers)
          FusionMarkerLayer(series: series.cast<SeriesWithDataPoints>()),

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

        // Layer 1001: Crosshair (if enabled and showing)
        if (crosshairPosition != null &&
            effectiveConfig.enableCrosshair &&
            effectiveConfig.crosshairBehavior.enabled)
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
    // CRITICAL: Use coordSystem.chartArea - it's already correctly calculated by the widget
    // Don't recalculate here as it would cause mismatches
    final chartArea = coordSystem.chartArea;

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

  /// Determine X-axis type from configuration or default to numeric.
  FusionAxisBase _determineXAxisType(List<FusionLineSeries> series) {
    return xAxis?.axisType ?? const FusionNumericAxis();
  }

  /// Determine Y-axis type from configuration or default to numeric.
  FusionAxisBase _determineYAxisType(List<FusionLineSeries> series) {
    return yAxis?.axisType ?? const FusionNumericAxis();
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

    final minX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final maxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final minY = allPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // ==========================================================================
  // CUSTOM PAINTER OVERRIDES
  // ==========================================================================

  @override
  bool shouldRepaint(covariant FusionLineChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.theme != theme ||
        oldDelegate.tooltipData != tooltipData ||
        oldDelegate.crosshairPosition != crosshairPosition ||
        oldDelegate.coordSystem != coordSystem;
  }

  @override
  bool? hitTest(Offset position) => true;

  /// Invalidates cached pipeline (call when configuration changes).
  void invalidateCache() {
    _pipeline = null;
  }
}

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

import '../../charts/fusion_stacked_bar_interactive_state.dart';
import '../../core/axis/base/fusion_axis_base.dart';
import '../../core/axis/category/fusion_category_axis.dart';
import '../../core/axis/numeric/fusion_numeric_axis.dart';
import '../engine/fusion_render_pipeline.dart';
import '../engine/fusion_render_context.dart';
import '../engine/fusion_paint_pool.dart';
import '../engine/fusion_shader_cache.dart';
import '../layers/fusion_render_layer.dart';
import '../layers/fusion_stacked_bar_series_renderer.dart';
import '../layers/fusion_stacked_tooltip_layer.dart';
import '../layers/fusion_crosshair_layer.dart';

/// Painter for stacked bar charts.
///
/// Renders stacked bars using the dedicated stacked bar renderer.
/// Supports both regular stacking and 100% stacking modes.
class FusionStackedBarChartPainter extends CustomPainter {
  FusionStackedBarChartPainter({
    required this.series,
    required this.coordSystem,
    required this.theme,
    required this.paintPool,
    required this.shaderCache,
    this.xAxis,
    this.yAxis,
    this.config,
    this.animationProgress = 1.0,
    this.stackedTooltipData,
    this.crosshairPosition,
    this.crosshairPoint,
    this.isStacked100 = false,
    this.tooltipValueFormatter,
    this.tooltipTotalFormatter,
  });

  final List<FusionStackedBarSeries> series;
  final FusionCoordinateSystem coordSystem;
  final FusionChartTheme theme;
  final FusionAxisConfiguration? xAxis;
  final FusionAxisConfiguration? yAxis;
  final FusionChartConfiguration? config;
  final double animationProgress;
  final FusionPaintPool paintPool;
  final FusionShaderCache shaderCache;
  final StackedTooltipData? stackedTooltipData;
  final Offset? crosshairPosition;
  final FusionDataPoint? crosshairPoint;
  final bool isStacked100;
  final FusionStackedValueFormatter? tooltipValueFormatter;
  final FusionStackedTotalFormatter? tooltipTotalFormatter;

  FusionRenderPipeline? _pipeline;

  @override
  void paint(Canvas canvas, Size size) {
    // Always rebuild pipeline to ensure config changes are reflected
    _pipeline = _buildRenderPipeline(size);

    final context = _createRenderContext(size);

    _pipeline!.render(canvas, size, context);

    // Render stacked tooltip directly (not through pipeline for simplicity)
    if (stackedTooltipData != null && (config?.enableTooltip ?? true)) {
      const tooltipLayer = FusionStackedTooltipLayer();
      tooltipLayer.render(
        canvas,
        context,
        stackedTooltipData!,
        config?.tooltipBehavior ?? const FusionTooltipBehavior(),
        valueFormatter: tooltipValueFormatter,
        totalFormatter: tooltipTotalFormatter,
      );
    }
  }

  FusionRenderPipeline _buildRenderPipeline(Size size) {
    final effectiveConfig = config ?? const FusionChartConfiguration();

    return FusionRenderPipeline(
      layers: [
        // Background
        FusionBackgroundLayer(color: theme.backgroundColor),

        // Grid
        if (effectiveConfig.enableGrid) FusionGridLayer(showHorizontal: true, showVertical: true),

        // Stacked bars
        _StackedBarSeriesLayer(series: series, isStacked100: isStacked100),

        // Axes
        if (effectiveConfig.enableAxis) FusionAxisLayer(showXAxis: true, showYAxis: true),

        // Crosshair
        if (crosshairPosition != null && effectiveConfig.enableCrosshair)
          FusionCrosshairLayer(
            position: crosshairPosition!,
            snappedPoint: crosshairPoint,
            crosshairConfig: effectiveConfig.crosshairBehavior,
          ),
      ],
      enableProfiling: false,
    );
  }

  FusionRenderContext _createRenderContext(Size size) {
    final chartArea = _calculateChartArea(size);
    final dataBounds = _calculateDataBounds();

    final xAxisDefinition = _determineXAxisType();
    final yAxisDefinition = _determineYAxisType();

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

  /// Determine X-axis type from configuration or auto-detect.
  FusionAxisBase _determineXAxisType() {
    // 1. User-provided axis type takes priority
    if (xAxis?.axisType != null) {
      return xAxis!.axisType!;
    }

    // 2. Auto-detect from data labels
    final hasLabels = series.every(
      (s) => s.dataPoints.every((p) => p.label != null && p.label!.isNotEmpty),
    );

    if (hasLabels && series.isNotEmpty) {
      final categories = series.first.dataPoints.map((p) => p.label!).toList();
      return FusionCategoryAxis(categories: categories);
    }

    return const FusionNumericAxis();
  }

  /// Determine Y-axis type from configuration or default to numeric.
  FusionAxisBase _determineYAxisType() {
    // User-provided axis type takes priority
    if (yAxis?.axisType != null) {
      return yAxis!.axisType!;
    }
    
    // Default: numeric for stacked values
    return const FusionNumericAxis();
  }

  Rect _calculateChartArea(Size size) {
    final effectiveConfig = config ?? const FusionChartConfiguration();

    final leftMargin = effectiveConfig.enableAxis ? 60.0 : 10.0;
    final rightMargin = 10.0;
    final topMargin = 10.0;
    final bottomMargin = effectiveConfig.enableAxis ? 40.0 : 10.0;

    return Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );
  }

  Rect _calculateDataBounds() {
    if (series.isEmpty) {
      return Rect.fromLTRB(0, 0, 10, 100);
    }

    final pointCount = series.first.dataPoints.length;
    final minX = -0.5;
    final maxX = pointCount - 0.5;
    final minY = 0.0;
    final maxY = isStacked100 ? 100.0 : _calculateStackedMaxY();

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _calculateStackedMaxY() {
    if (series.isEmpty) return 100;

    final pointCount = series.first.dataPoints.length;
    double maxSum = 0;

    for (int i = 0; i < pointCount; i++) {
      double sum = 0;
      for (final s in series) {
        if (i < s.dataPoints.length) {
          sum += s.dataPoints[i].y;
        }
      }
      if (sum > maxSum) maxSum = sum;
    }

    return maxSum > 0 ? maxSum * 1.1 : 100;
  }

  @override
  bool shouldRepaint(covariant FusionStackedBarChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.theme != theme ||
        oldDelegate.stackedTooltipData != stackedTooltipData ||
        oldDelegate.crosshairPosition != crosshairPosition ||
        oldDelegate.coordSystem != coordSystem ||
        oldDelegate.isStacked100 != isStacked100;
  }

  @override
  bool? hitTest(Offset position) => true;
}

/// Internal layer for rendering stacked bar series.
class _StackedBarSeriesLayer extends FusionRenderLayer {
  _StackedBarSeriesLayer({required this.series, required this.isStacked100})
    : super(name: 'stacked_bars', zIndex: 50, cacheable: false, clipRect: null);

  static const _renderer = FusionStackedBarSeriesRenderer();

  final List<FusionStackedBarSeries> series;
  final bool isStacked100;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    canvas.save();
    canvas.clipRect(context.chartArea);

    try {
      final visibleSeries = series.where((s) => s.visible).toList();
      if (visibleSeries.isNotEmpty) {
        _renderer.render(canvas, context, visibleSeries, is100Percent: isStacked100);
      }
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FusionRenderLayer oldLayer) {
    if (oldLayer is! _StackedBarSeriesLayer) return true;
    return oldLayer.series != series || oldLayer.isStacked100 != isStacked100;
  }
}

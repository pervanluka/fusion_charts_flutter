import 'dart:ui';

import 'package:flutter/material.dart';
import '../../configuration/fusion_axis_configuration.dart';
import '../../core/axis/base/fusion_axis_renderer.dart';
import '../../core/axis/fusion_axis_renderer_factory.dart';
import '../../core/enums/axis_position.dart';
import '../../core/models/axis_bounds.dart';
import '../../core/models/axis_label.dart';
import '../engine/fusion_render_context.dart';

/// Abstract base class for render layers.
///
/// Each layer is responsible for rendering a specific aspect of the chart:
/// - Background layer: solid color or gradient background
/// - Grid layer: horizontal and vertical grid lines
/// - Series layer: actual data visualization (lines, bars, etc.)
/// - Marker layer: data point markers
/// - Label layer: data labels
/// - Axis layer: axis lines and labels
/// - Overlay layer: tooltips, crosshair, selection
///
/// ## Layer System Benefits
///
/// 1. **Separation of Concerns**: Each layer handles one thing
/// 2. **Independent Caching**: Can cache layers separately
/// 3. **Conditional Rendering**: Enable/disable layers easily
/// 4. **Performance**: Only repaint changed layers
/// 5. **Debugging**: Can visualize individual layers
///
/// ## Example
///
/// ```dart
/// class MyCustomLayer extends FusionRenderLayer {
///   MyCustomLayer() : super(name: 'custom', zIndex: 100);
///
///   @override
///   void paint(Canvas canvas, Size size, FusionRenderContext context) {
///     // Custom rendering logic
///   }
///
///   @override
///   bool shouldRepaint(covariant FusionRenderLayer oldLayer) {
///     return true; // Always repaint
///   }
/// }
/// ```
abstract class FusionRenderLayer {
  FusionRenderLayer({
    required this.name,
    this.zIndex = 0,
    this.enabled = true,
    this.clipRect,
    this.transform,
    this.cacheable = false,
  });

  /// Unique name for this layer.
  final String name;

  /// Z-index for layer ordering (higher = rendered later).
  final int zIndex;

  /// Whether this layer is enabled.
  bool enabled;

  /// Optional clipping rectangle for this layer.
  final Rect? clipRect;

  /// Optional transform matrix for this layer.
  final Matrix4? transform;

  /// Whether this layer can be cached.
  final bool cacheable;

  /// Cached rendering (if cacheable is true).
  Picture? _cachedPicture;
  bool _cacheInvalid = true;

  // ==========================================================================
  // MAIN RENDER METHOD
  // ==========================================================================

  /// Paints this layer to the canvas.
  ///
  /// Subclasses must implement this method to perform actual rendering.
  void paint(Canvas canvas, Size size, FusionRenderContext context);

  /// Paints with caching support.
  void paintWithCache(Canvas canvas, Size size, FusionRenderContext context) {
    if (!cacheable || _cacheInvalid) {
      if (cacheable) {
        // Record to picture for caching
        final recorder = PictureRecorder();
        final cacheCanvas = Canvas(recorder);

        paint(cacheCanvas, size, context);

        _cachedPicture?.dispose();
        _cachedPicture = recorder.endRecording();
        _cacheInvalid = false;

        // Draw the recorded picture
        canvas.drawPicture(_cachedPicture!);
      } else {
        // Direct rendering (no cache)
        paint(canvas, size, context);
      }
    } else {
      // Use cached picture
      canvas.drawPicture(_cachedPicture!);
    }
  }

  // ==========================================================================
  // CACHE MANAGEMENT
  // ==========================================================================

  /// Invalidates the cache, forcing a repaint.
  void invalidateCache() {
    _cacheInvalid = true;
  }

  /// Checks if this layer needs repainting.
  bool shouldRepaint(covariant FusionRenderLayer oldLayer);

  /// Disposes resources.
  void dispose() {
    _cachedPicture?.dispose();
    _cachedPicture = null;
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  @override
  String toString() => 'FusionRenderLayer($name, z=$zIndex, enabled=$enabled)';
}

// ==========================================================================
// SPECIFIC LAYER IMPLEMENTATIONS
// ==========================================================================

/// Background layer - renders chart background.
class FusionBackgroundLayer extends FusionRenderLayer {
  FusionBackgroundLayer({this.color, this.gradient})
    : super(name: 'background', zIndex: 0, cacheable: true);

  final Color? color;
  final Gradient? gradient;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = color ?? context.theme.backgroundColor;
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant FusionBackgroundLayer oldLayer) {
    return oldLayer.color != color || oldLayer.gradient != gradient;
  }
}

/// Grid layer - renders grid lines.
class FusionGridLayer extends FusionRenderLayer {
  FusionGridLayer({
    required this.showHorizontal,
    required this.showVertical,
    this.horizontalInterval,
    this.verticalInterval,
  }) : super(
         name: 'grid',
         zIndex: 10,
         cacheable: false, // Grid depends on axis intervals
       );

  final bool showHorizontal;
  final bool showVertical;
  final double? horizontalInterval;
  final double? verticalInterval;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final paint = context.getPaint(
      color: context.theme.gridColor,
      strokeWidth: context.theme.gridLineWidth,
      strokeCap: StrokeCap.square,
    );

    final chartArea = context.chartArea;
    final dataBounds = context.effectiveViewport;

    // Vertical grid lines
    if (showVertical) {
      final xInterval =
          verticalInterval ??
          context.xAxis?.getEffectiveInterval(dataBounds.left, dataBounds.right) ??
          1.0;

      double currentX = dataBounds.left;
      while (currentX <= dataBounds.right) {
        final screenX = context.dataXToScreenX(currentX).roundToDouble();

        canvas.drawLine(Offset(screenX, chartArea.top), Offset(screenX, chartArea.bottom), paint);

        currentX += xInterval;
      }
    }

    // Horizontal grid lines
    if (showHorizontal) {
      final yInterval =
          horizontalInterval ??
          context.yAxis?.getEffectiveInterval(dataBounds.top, dataBounds.bottom) ??
          10.0;

      double currentY = dataBounds.top;
      while (currentY <= dataBounds.bottom) {
        final screenY = context.dataYToScreenY(currentY).roundToDouble();

        canvas.drawLine(Offset(chartArea.left, screenY), Offset(chartArea.right, screenY), paint);

        currentY += yInterval;
      }
    }

    context.returnPaint(paint);
  }

  @override
  bool shouldRepaint(covariant FusionGridLayer oldLayer) {
    return oldLayer.showHorizontal != showHorizontal ||
        oldLayer.showVertical != showVertical ||
        oldLayer.horizontalInterval != horizontalInterval ||
        oldLayer.verticalInterval != verticalInterval;
  }
}

/// Axis layer - renders axes and labels.
class FusionAxisLayer extends FusionRenderLayer {
  FusionAxisLayer({required this.showXAxis, required this.showYAxis})
    : super(name: 'axes', zIndex: 90);

  final bool showXAxis;
  final bool showYAxis;

  // Cache renderers for performance
  FusionAxisRenderer? _xAxisRenderer;
  FusionAxisRenderer? _yAxisRenderer;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final paint = context.getPaint(
      color: context.theme.axisColor,
      strokeWidth: context.theme.axisLineWidth,
      strokeCap: StrokeCap.square,
    );

    final chartArea = context.chartArea;

    // ===============================
    // X-AXIS RENDERING
    // ===============================
    if (showXAxis && context.xAxisDefinition != null) {
      // Draw X-axis line
      canvas.drawLine(
        Offset(chartArea.left, chartArea.bottom),
        Offset(chartArea.right, chartArea.bottom),
        paint,
      );

      // Create or reuse X-axis renderer
      _xAxisRenderer ??= FusionAxisRendererFactory.create(
        axis: context.xAxisDefinition,
        configuration: context.xAxis ?? FusionAxisConfiguration(),
        isVertical: false,
      );

      // Render X-axis labels and ticks
      _renderAxis(canvas, size, context, _xAxisRenderer!, isVertical: false);
    }

    // ===============================
    // Y-AXIS RENDERING
    // ===============================
    if (showYAxis && context.yAxisDefinition != null) {
      // Draw Y-axis line
      canvas.drawLine(
        Offset(chartArea.left, chartArea.top),
        Offset(chartArea.left, chartArea.bottom),
        paint,
      );

      // Create or reuse Y-axis renderer
      _yAxisRenderer ??= FusionAxisRendererFactory.create(
        axis: context.yAxisDefinition,
        configuration: context.yAxis ?? FusionAxisConfiguration(),
        isVertical: true,
      );

      // Render Y-axis labels and ticks
      _renderAxis(canvas, size, context, _yAxisRenderer!, isVertical: true);
    }

    context.returnPaint(paint);
  }

  /// Renders an axis using the professional renderer.
  void _renderAxis(
    Canvas canvas,
    Size size,
    FusionRenderContext context,
    FusionAxisRenderer renderer, {
    required bool isVertical,
  }) {
    final dataBounds = context.effectiveViewport;

    // Calculate axis bounds
    final dataValues = isVertical
        ? [dataBounds.top, dataBounds.bottom]
        : [dataBounds.left, dataBounds.right];

    final axisBounds = renderer.calculateBounds(dataValues);

    // Generate labels
    final labels = renderer.generateLabels(axisBounds);

    // Render each label
    for (final label in labels) {
      if (isVertical) {
        _renderYAxisLabel(canvas, context, label, axisBounds);
      } else {
        _renderXAxisLabel(canvas, context, label, axisBounds);
      }
    }
  }

  /// Renders an X-axis label.
  void _renderXAxisLabel(
    Canvas canvas,
    FusionRenderContext context,
    AxisLabel label,
    AxisBounds bounds,
  ) {
    final chartArea = context.chartArea;
    final position = context.xAxis?.getEffectivePosition(isVertical: false) ?? AxisPosition.bottom;

    // Convert data value to screen position
    final screenX =
        chartArea.left + ((label.value - bounds.min) / (bounds.max - bounds.min)) * chartArea.width;

    // Skip if outside chart area
    if (screenX < chartArea.left || screenX > chartArea.right) {
      return;
    }

    // Create text painter
    final textStyle = context.xAxis?.labelStyle ?? context.theme.axisLabelStyle;
    final textPainter = TextPainter(
      text: TextSpan(text: label.text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset labelOffset;
    final Offset tickStart;
    final Offset tickEnd;

    switch (position) {
      case AxisPosition.bottom:
        // Default: Labels below axis
        labelOffset = Offset(screenX - (textPainter.width / 2), chartArea.bottom + 8);
        tickStart = Offset(screenX, chartArea.bottom);
        tickEnd = Offset(screenX, chartArea.bottom + 5);
        break;

      case AxisPosition.top:
        // Reversed: Labels above axis
        labelOffset = Offset(
          screenX - (textPainter.width / 2),
          chartArea.top - textPainter.height - 8,
        );
        tickStart = Offset(screenX, chartArea.top);
        tickEnd = Offset(screenX, chartArea.top - 5);
        break;

      default:
        // Should not happen for X-axis
        labelOffset = Offset(screenX, chartArea.bottom);
        tickStart = Offset(screenX, chartArea.bottom);
        tickEnd = Offset(screenX, chartArea.bottom + 5);
    }

    // Draw label
    textPainter.paint(canvas, labelOffset);

    // Draw tick mark
    final tickPaint = context.getPaint(color: context.theme.axisColor, strokeWidth: 1.0);

    canvas.drawLine(tickStart, tickEnd, tickPaint);
    context.returnPaint(tickPaint);
  }

  /// Renders a Y-axis label.
  void _renderYAxisLabel(
    Canvas canvas,
    FusionRenderContext context,
    AxisLabel label,
    AxisBounds bounds,
  ) {
    final chartArea = context.chartArea;
    final position = context.yAxis?.getEffectivePosition(isVertical: true) ?? AxisPosition.left;

    // Convert data value to screen position
    final screenY =
        chartArea.bottom -
        ((label.value - bounds.min) / (bounds.max - bounds.min)) * chartArea.height;

    // Skip if outside chart area
    if (screenY < chartArea.top || screenY > chartArea.bottom) {
      return;
    }

    // Create text painter
    final textStyle = context.yAxis?.labelStyle ?? context.theme.axisLabelStyle;
    final textPainter = TextPainter(
      text: TextSpan(text: label.text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // 🆕 POSITION-AWARE RENDERING
    final Offset labelOffset;
    final Offset tickStart;
    final Offset tickEnd;

    switch (position) {
      case AxisPosition.left:
        // Default: Labels to the left of axis
        labelOffset = Offset(
          chartArea.left - textPainter.width - 8,
          screenY - (textPainter.height / 2),
        );
        tickStart = Offset(chartArea.left - 5, screenY);
        tickEnd = Offset(chartArea.left, screenY);
        break;

      case AxisPosition.right:
        // Secondary: Labels to the right of axis
        labelOffset = Offset(chartArea.right + 8, screenY - (textPainter.height / 2));
        tickStart = Offset(chartArea.right, screenY);
        tickEnd = Offset(chartArea.right + 5, screenY);
        break;

      default:
        // Should not happen for Y-axis
        labelOffset = Offset(
          chartArea.left - textPainter.width - 8,
          screenY - (textPainter.height / 2),
        );
        tickStart = Offset(chartArea.left - 5, screenY);
        tickEnd = Offset(chartArea.left, screenY);
    }

    // Draw label
    textPainter.paint(canvas, labelOffset);

    // Draw tick mark
    final tickPaint = context.getPaint(color: context.theme.axisColor, strokeWidth: 1.0);

    canvas.drawLine(tickStart, tickEnd, tickPaint);
    context.returnPaint(tickPaint);
  }

  @override
  bool shouldRepaint(covariant FusionAxisLayer oldLayer) {
    return oldLayer.showXAxis != showXAxis || oldLayer.showYAxis != showYAxis;
  }

  /// Invalidate cached renderers when axis definitions change.
  @override
  void invalidateCache() {
    _xAxisRenderer = null;
    _yAxisRenderer = null;
  }
}

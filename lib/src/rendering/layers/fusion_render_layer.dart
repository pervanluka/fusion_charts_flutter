import 'dart:ui';

import 'package:flutter/material.dart';
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

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final paint = context.getPaint(
      color: context.theme.axisColor,
      strokeWidth: context.theme.axisLineWidth,
      strokeCap: StrokeCap.square,
    );

    final chartArea = context.chartArea;

    // X-axis line
    if (showXAxis) {
      canvas.drawLine(
        Offset(chartArea.left, chartArea.bottom),
        Offset(chartArea.right, chartArea.bottom),
        paint,
      );

      _drawXAxisLabels(canvas, context);
    }

    // Y-axis line
    if (showYAxis) {
      canvas.drawLine(
        Offset(chartArea.left, chartArea.top),
        Offset(chartArea.left, chartArea.bottom),
        paint,
      );

      _drawYAxisLabels(canvas, context);
    }

    context.returnPaint(paint);
  }

  void _drawXAxisLabels(Canvas canvas, FusionRenderContext context) {
    if (context.xAxis == null) return;

    final labelStyle = context.xAxis!.labelStyle ?? context.theme.axisLabelStyle;
    final dataBounds = context.effectiveViewport;
    final xInterval = context.xAxis!.getEffectiveInterval(dataBounds.left, dataBounds.right);

    double currentX = dataBounds.left;
    while (currentX <= dataBounds.right) {
      final screenX = context.dataXToScreenX(currentX);
      final labelText =
          context.xAxis!.labelFormatter?.call(currentX) ?? currentX.toStringAsFixed(0);

      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(screenX - (textPainter.width / 2), context.chartArea.bottom + 8);

      textPainter.paint(canvas, offset);

      currentX += xInterval ?? 0;
    }
  }

  void _drawYAxisLabels(Canvas canvas, FusionRenderContext context) {
    if (context.yAxis == null) return;

    final labelStyle = context.yAxis!.labelStyle ?? context.theme.axisLabelStyle;
    final dataBounds = context.effectiveViewport;
    final yInterval = context.yAxis!.getEffectiveInterval(dataBounds.top, dataBounds.bottom);

    double currentY = dataBounds.top;
    while (currentY <= dataBounds.bottom) {
      final screenY = context.dataYToScreenY(currentY);
      final labelText =
          context.yAxis!.labelFormatter?.call(currentY) ?? currentY.toStringAsFixed(0);

      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        context.chartArea.left - textPainter.width - 8,
        screenY - (textPainter.height / 2),
      );

      textPainter.paint(canvas, offset);

      currentY += yInterval ?? 0;
    }
  }

  @override
  bool shouldRepaint(covariant FusionAxisLayer oldLayer) {
    return oldLayer.showXAxis != showXAxis || oldLayer.showYAxis != showYAxis;
  }
}

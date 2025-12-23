import 'dart:math';
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

  /// Maximum iterations to prevent infinite loops from floating-point errors.
  static const int _maxIterations = 100;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final paint = context.getPaint(
      color: context.theme.gridColor,
      strokeWidth: context.theme.gridLineWidth,
      strokeCap: StrokeCap.square,
    );

    final chartArea = context.chartArea;
    final dataBounds = context.effectiveViewport;
    final coordSystem = context.coordSystem;
    
    // Y-axis position (where x=dataXMin is rendered)
    final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);

    // Vertical grid lines
    if (showVertical) {
      final xInterval =
          verticalInterval ??
          context.xAxis?.getEffectiveInterval(dataBounds.left, dataBounds.right) ??
          1.0;

      // Safety: ensure positive interval
      if (xInterval > 0) {
        double currentX = dataBounds.left;
        int iterations = 0;
        
        while (currentX <= dataBounds.right && iterations < _maxIterations) {
          final screenX = context.dataXToScreenX(currentX).roundToDouble();
          canvas.drawLine(Offset(screenX, chartArea.top), Offset(screenX, chartArea.bottom), paint);
          currentX += xInterval;
          iterations++;
        }
      }
    }

    // Horizontal grid lines
    if (showHorizontal) {
      final yInterval =
          horizontalInterval ??
          context.yAxis?.getEffectiveInterval(dataBounds.top, dataBounds.bottom) ??
          10.0;

      // Safety: ensure positive interval
      if (yInterval > 0) {
        double currentY = dataBounds.top;
        int iterations = 0;
        
        while (currentY <= dataBounds.bottom && iterations < _maxIterations) {
          final screenY = context.dataYToScreenY(currentY).roundToDouble();
          // Grid lines start from Y-axis position
          canvas.drawLine(Offset(yAxisX, screenY), Offset(chartArea.right, screenY), paint);
          currentY += yInterval;
          iterations++;
        }
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
    final coordSystem = context.coordSystem;

    // ===============================
    // X-AXIS RENDERING
    // ===============================
    if (showXAxis && context.xAxisDefinition != null) {
      // Y-axis position for proper intersection
      final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);
      
      // Draw X-axis line starting from Y-axis
      final xAxisY = chartArea.bottom;
      
      canvas.drawLine(
        Offset(yAxisX, xAxisY),
        Offset(chartArea.right, xAxisY),
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
      // CRITICAL FIX: Draw Y-axis at x=dataXMin position
      // This ensures the axis passes through the first data point
      final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);
      
      canvas.drawLine(
        Offset(yAxisX, chartArea.top),
        Offset(yAxisX, chartArea.bottom),
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
    // CRITICAL: Use coordinate system's bounds directly
    // This ensures labels align EXACTLY with data points
    final coordBounds = context.coordSystem.dataBounds;
    
    // Get the exact min/max from coordinate system
    final dataMin = isVertical ? coordBounds.top : coordBounds.left;
    final dataMax = isVertical ? coordBounds.bottom : coordBounds.right;
    
    // Check if this is a category axis (for bar charts)
    final axisDef = isVertical ? context.yAxisDefinition : context.xAxisDefinition;
    final isCategoryAxis = axisDef?.runtimeType.toString().contains('Category') ?? false;
    
    List<AxisLabel> labels;
    double interval;
    
    if (isCategoryAxis) {
      // Use the renderer for category labels (Q1, Q2, etc.)
      final axisBounds = renderer.calculateBounds([dataMin, dataMax]);
      labels = renderer.generateLabels(axisBounds);
      interval = axisBounds.interval;
    } else {
      // Generate nice numeric labels aligned to coordinate system
      final range = dataMax - dataMin;
      interval = _calculateNiceInterval(range, 5);
      labels = _generateAlignedLabels(dataMin, dataMax, interval);
    }
    
    final axisBounds = AxisBounds(
      min: dataMin, 
      max: dataMax, 
      interval: interval, 
      decimalPlaces: _getDecimalPlaces(interval),
    );
    
    // Render each label
    for (final label in labels) {
      if (isVertical) {
        _renderYAxisLabel(canvas, context, label, axisBounds);
      } else {
        _renderXAxisLabel(canvas, context, label, axisBounds);
      }
    }
  }
  
  /// Calculates a nice interval for the given range.
  double _calculateNiceInterval(double range, int desiredIntervals) {
    if (range <= 0) return 1.0;
    
    final roughInterval = range / desiredIntervals;
    
    // Calculate magnitude using log10
    final exp = (roughInterval > 0) 
        ? (log(roughInterval) / ln10).floor() 
        : 0;
    final magnitude = pow(10.0, exp).toDouble();
    
    final normalized = roughInterval / magnitude;
    
    double niceFraction;
    if (normalized < 1.5) {
      niceFraction = 1.0;
    } else if (normalized < 3.0) {
      niceFraction = 2.0;
    } else if (normalized < 7.0) {
      niceFraction = 5.0;
    } else {
      niceFraction = 10.0;
    }
    
    return niceFraction * magnitude;
  }
  
  int _getDecimalPlaces(double interval) {
    if (interval >= 1) return 0;
    if (interval >= 0.1) return 1;
    if (interval >= 0.01) return 2;
    return 3;
  }
  
  /// Generates labels aligned to the coordinate system bounds.
  List<AxisLabel> _generateAlignedLabels(double min, double max, double interval) {
    final labels = <AxisLabel>[];
    
    // Start from a nice number at or before min
    double start = (min / interval).floor() * interval;
    if (start < min - interval * 0.01) start += interval;
    
    double current = start;
    while (current <= max + interval * 0.01) {
      // Clean floating point
      final cleanValue = (current * 1000000).round() / 1000000;
      
      // Only include if within bounds (with small tolerance)
      if (cleanValue >= min - interval * 0.01 && cleanValue <= max + interval * 0.01) {
        final position = (cleanValue - min) / (max - min);
        labels.add(AxisLabel(
          value: cleanValue,
          text: _formatValue(cleanValue, interval),
          position: position.clamp(0.0, 1.0),
        ));
      }
      
      current += interval;
      
      // Safety limit
      if (labels.length > 20) break;
    }
    
    return labels;
  }
  
  String _formatValue(double value, double interval) {
    final decimals = _getDecimalPlaces(interval);
    if (decimals == 0) {
      return value.round().toString();
    }
    return value.toStringAsFixed(decimals);
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

    // CRITICAL FIX: Use coordinate system for proper alignment with data points
    // The label.value is in data space, so use coordSystem to convert to screen space
    final screenX = context.coordSystem.dataXToScreenX(label.value);

    // Skip if outside chart area (with small tolerance)
    if (screenX < chartArea.left - 1 || screenX > chartArea.right + 1) {
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

    // CRITICAL FIX: Use coordinate system for proper alignment with data points
    // The label.value is in data space, so use coordSystem to convert to screen space
    final screenY = context.coordSystem.dataYToScreenY(label.value);
    
    // Y-axis is drawn at x=dataXMin, so ticks and labels should align with it
    final yAxisX = context.coordSystem.dataXToScreenX(context.coordSystem.dataXMin);

    // Skip if outside chart area (with small tolerance)
    if (screenY < chartArea.top - 1 || screenY > chartArea.bottom + 1) {
      return;
    }

    // Create text painter
    final textStyle = context.yAxis?.labelStyle ?? context.theme.axisLabelStyle;
    final textPainter = TextPainter(
      text: TextSpan(text: label.text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset labelOffset;
    final Offset tickStart;
    final Offset tickEnd;

    switch (position) {
      case AxisPosition.left:
        // Default: Labels to the left of axis (use yAxisX for alignment)
        labelOffset = Offset(
          yAxisX - textPainter.width - 8,
          screenY - (textPainter.height / 2),
        );
        tickStart = Offset(yAxisX - 5, screenY);
        tickEnd = Offset(yAxisX, screenY);
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
          yAxisX - textPainter.width - 8,
          screenY - (textPainter.height / 2),
        );
        tickStart = Offset(yAxisX - 5, screenY);
        tickEnd = Offset(yAxisX, screenY);
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

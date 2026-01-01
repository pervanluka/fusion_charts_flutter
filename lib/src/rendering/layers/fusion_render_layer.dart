import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../configuration/fusion_axis_configuration.dart';
import '../../core/axis/base/fusion_axis_renderer.dart';
import '../../core/axis/fusion_axis_renderer_factory.dart';
import '../../core/enums/axis_position.dart';
import '../../core/enums/label_alignment.dart';
import '../../core/models/axis_label.dart';
import '../engine/fusion_render_context.dart';

/// Abstract base class for render layers.
abstract class FusionRenderLayer {
  FusionRenderLayer({
    required this.name,
    this.zIndex = 0,
    this.enabled = true,
    this.clipRect,
    this.transform,
    this.cacheable = false,
  });

  final String name;
  final int zIndex;
  bool enabled;
  final Rect? clipRect;
  final Matrix4? transform;
  final bool cacheable;

  Picture? _cachedPicture;
  bool _cacheInvalid = true;

  void paint(Canvas canvas, Size size, FusionRenderContext context);

  void paintWithCache(Canvas canvas, Size size, FusionRenderContext context) {
    if (!cacheable || _cacheInvalid) {
      if (cacheable) {
        final recorder = PictureRecorder();
        final cacheCanvas = Canvas(recorder);
        paint(cacheCanvas, size, context);
        _cachedPicture?.dispose();
        _cachedPicture = recorder.endRecording();
        _cacheInvalid = false;
        canvas.drawPicture(_cachedPicture!);
      } else {
        paint(canvas, size, context);
      }
    } else {
      canvas.drawPicture(_cachedPicture!);
    }
  }

  void invalidateCache() {
    _cacheInvalid = true;
  }

  bool shouldRepaint(covariant FusionRenderLayer oldLayer);

  void dispose() {
    _cachedPicture?.dispose();
    _cachedPicture = null;
  }

  @override
  String toString() => 'FusionRenderLayer($name, z=$zIndex, enabled=$enabled)';
}

// ==========================================================================
// BACKGROUND LAYER
// ==========================================================================

class FusionBackgroundLayer extends FusionRenderLayer {
  FusionBackgroundLayer({this.color, this.gradient})
    : super(name: 'background', zIndex: 0, cacheable: true);

  final Color? color;
  final Gradient? gradient;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
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

// ==========================================================================
// BORDER LAYER - Draws a rectangle border around the chart area
// ==========================================================================

class FusionBorderLayer extends FusionRenderLayer {
  FusionBorderLayer() : super(name: 'border', zIndex: 95, cacheable: false);

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final chartArea = context.chartArea;

    final paint = Paint()
      ..color = context.theme.borderColor
      ..strokeWidth = context.theme.axisLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawRect(chartArea, paint);
  }

  @override
  bool shouldRepaint(covariant FusionBorderLayer oldLayer) {
    return false; // Border doesn't have internal state that changes
  }
}

// ==========================================================================
// GRID LAYER - Fixed to respect per-axis showGrid
// ==========================================================================

class FusionGridLayer extends FusionRenderLayer {
  FusionGridLayer({
    required this.showHorizontal,
    required this.showVertical,
    this.horizontalInterval,
    this.verticalInterval,
  }) : super(name: 'grid', zIndex: 10, cacheable: false);

  final bool showHorizontal;
  final bool showVertical;
  final double? horizontalInterval;
  final double? verticalInterval;

  static const int _maxIterations = 100;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final xAxisConfig = context.xAxis ?? const FusionAxisConfiguration();
    final yAxisConfig = context.yAxis ?? const FusionAxisConfiguration();

    final chartArea = context.chartArea;
    final dataBounds = context.effectiveViewport;
    final coordSystem = context.coordSystem;
    final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);

    // =========================================
    // VERTICAL GRID LINES (X-axis controls)
    // =========================================
    // Only show if: layer enabled AND x-axis config allows grid
    if (showVertical && xAxisConfig.showGrid) {
      final paint = context.getPaint(
        color: xAxisConfig.majorGridColor ?? context.theme.gridColor,
        strokeWidth: xAxisConfig.majorGridWidth ?? context.theme.gridLineWidth,
        strokeCap: StrokeCap.square,
      );

      // Check if we should use discrete bucket grid (for bar/column charts)
      // Discrete bucket grids draw lines at BOUNDARIES (between bars)
      // not at bar centers. This works for Category, DateTime, and Numeric axes.
      final useDiscreteBuckets = context.useDiscreteBucketGridX;

      if (useDiscreteBuckets) {
        // DISCRETE BUCKET MODE: Draw grid lines at boundaries (-0.5, 0.5, 1.5, ...)
        // This places lines BETWEEN bars, not through them
        // Works for any axis type (category, datetime, numeric)
        final bucketCount = (dataBounds.right - dataBounds.left).round() + 1;

        // Draw boundary lines from -0.5 to bucketCount - 0.5
        for (int i = 0; i <= bucketCount; i++) {
          final boundaryX = i - 0.5;
          // Only draw if within visible range
          if (boundaryX >= dataBounds.left && boundaryX <= dataBounds.right) {
            final screenX = context.dataXToScreenX(boundaryX).roundToDouble();
            canvas.drawLine(
              Offset(screenX, chartArea.top),
              Offset(screenX, chartArea.bottom),
              paint,
            );
          }
        }
      } else {
        // NUMERIC AXIS: Standard behavior - lines at regular intervals
        final xInterval =
            verticalInterval ??
            xAxisConfig.interval ??
            _calculateNiceInterval(
              dataBounds.right - dataBounds.left,
              xAxisConfig.desiredIntervals,
            );

        if (xInterval > 0) {
          // Start from nice number
          double startX = (dataBounds.left / xInterval).floor() * xInterval;
          if (startX < dataBounds.left) startX += xInterval;

          double currentX = startX;
          int iterations = 0;

          while (currentX <= dataBounds.right && iterations < _maxIterations) {
            final screenX = context.dataXToScreenX(currentX).roundToDouble();
            canvas.drawLine(
              Offset(screenX, chartArea.top),
              Offset(screenX, chartArea.bottom),
              paint,
            );
            currentX += xInterval;
            iterations++;
          }
        }

        // Minor grid lines for X-axis (only for numeric axis)
        if (xAxisConfig.showMinorGrid) {
          final xInterval =
              verticalInterval ??
              xAxisConfig.interval ??
              _calculateNiceInterval(
                dataBounds.right - dataBounds.left,
                xAxisConfig.desiredIntervals,
              );
          _renderMinorGridLines(
            canvas,
            context,
            xAxisConfig,
            dataBounds.left,
            dataBounds.right,
            xInterval,
            isVertical: true,
          );
        }
      }

      context.returnPaint(paint);
    }

    // =========================================
    // HORIZONTAL GRID LINES (Y-axis controls)
    // =========================================
    // Only show if: layer enabled AND y-axis config allows grid
    if (showHorizontal && yAxisConfig.showGrid) {
      final paint = context.getPaint(
        color: yAxisConfig.majorGridColor ?? context.theme.gridColor,
        strokeWidth: yAxisConfig.majorGridWidth ?? context.theme.gridLineWidth,
        strokeCap: StrokeCap.square,
      );

      final yInterval =
          horizontalInterval ??
          yAxisConfig.interval ??
          _calculateNiceInterval(
            dataBounds.bottom - dataBounds.top,
            yAxisConfig.desiredIntervals,
          );

      if (yInterval > 0) {
        // Start from nice number
        double startY = (dataBounds.top / yInterval).floor() * yInterval;
        if (startY < dataBounds.top) startY += yInterval;

        double currentY = startY;
        int iterations = 0;

        while (currentY <= dataBounds.bottom && iterations < _maxIterations) {
          final screenY = context.dataYToScreenY(currentY).roundToDouble();
          canvas.drawLine(
            Offset(yAxisX, screenY),
            Offset(chartArea.right, screenY),
            paint,
          );
          currentY += yInterval;
          iterations++;
        }
      }

      // Minor grid lines for Y-axis
      if (yAxisConfig.showMinorGrid) {
        _renderMinorGridLines(
          canvas,
          context,
          yAxisConfig,
          dataBounds.top,
          dataBounds.bottom,
          yInterval,
          isVertical: false,
        );
      }

      context.returnPaint(paint);
    }
  }

  /// Renders minor grid lines between major grid lines.
  void _renderMinorGridLines(
    Canvas canvas,
    FusionRenderContext context,
    FusionAxisConfiguration config,
    double dataMin,
    double dataMax,
    double majorInterval, {
    required bool isVertical,
  }) {
    final chartArea = context.chartArea;
    final coordSystem = context.coordSystem;

    final paint = context.getPaint(
      color:
          config.minorGridColor ??
          (config.majorGridColor ?? context.theme.gridColor).withValues(
            alpha: 0.15,
          ),
      strokeWidth: config.minorGridWidth ?? 0.5,
      strokeCap: StrokeCap.square,
    );

    // 4 minor divisions between each major
    final minorInterval = majorInterval / 5;
    double startVal = (dataMin / majorInterval).floor() * majorInterval;
    if (startVal < dataMin) startVal += minorInterval;

    double current = startVal;
    int iterations = 0;

    while (current <= dataMax && iterations < _maxIterations * 5) {
      // Skip if it's on a major line
      final isOnMajor =
          (current / majorInterval - (current / majorInterval).round()).abs() <
          0.01;

      if (!isOnMajor) {
        if (isVertical) {
          final screenX = context.dataXToScreenX(current).roundToDouble();
          canvas.drawLine(
            Offset(screenX, chartArea.top),
            Offset(screenX, chartArea.bottom),
            paint,
          );
        } else {
          final screenY = context.dataYToScreenY(current).roundToDouble();
          final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);
          canvas.drawLine(
            Offset(yAxisX, screenY),
            Offset(chartArea.right, screenY),
            paint,
          );
        }
      }

      current += minorInterval;
      iterations++;
    }

    context.returnPaint(paint);
  }

  double _calculateNiceInterval(double range, int desiredIntervals) {
    if (range <= 0 || desiredIntervals <= 0) return 1.0;

    final roughInterval = range / desiredIntervals;
    final exp = (roughInterval > 0) ? (log(roughInterval) / ln10).floor() : 0;
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

  @override
  bool shouldRepaint(covariant FusionGridLayer oldLayer) {
    return oldLayer.showHorizontal != showHorizontal ||
        oldLayer.showVertical != showVertical ||
        oldLayer.horizontalInterval != horizontalInterval ||
        oldLayer.verticalInterval != verticalInterval;
  }
}

// ==========================================================================
// AXIS LAYER - Fixed with labelAlignment, title, minorTicks support
// ==========================================================================

class FusionAxisLayer extends FusionRenderLayer {
  FusionAxisLayer({required this.showXAxis, required this.showYAxis})
    : super(name: 'axes', zIndex: 90);

  final bool showXAxis;
  final bool showYAxis;

  FusionAxisRenderer? _xAxisRenderer;
  FusionAxisRenderer? _yAxisRenderer;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final chartArea = context.chartArea;
    final coordSystem = context.coordSystem;

    final xAxisConfig = context.xAxis ?? const FusionAxisConfiguration();
    final yAxisConfig = context.yAxis ?? const FusionAxisConfiguration();

    // ===============================
    // X-AXIS RENDERING
    // ===============================
    if (showXAxis && xAxisConfig.visible && context.xAxisDefinition != null) {
      _xAxisRenderer ??= FusionAxisRendererFactory.create(
        axis: context.xAxisDefinition,
        configuration: xAxisConfig,
        isVertical: false,
      );

      if (xAxisConfig.showAxisLine) {
        final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);
        final xAxisY = chartArea.bottom;

        final paint = context.getPaint(
          color: xAxisConfig.axisLineColor ?? context.theme.axisColor,
          strokeWidth: xAxisConfig.axisLineWidth ?? context.theme.axisLineWidth,
          strokeCap: StrokeCap.square,
        );

        canvas.drawLine(
          Offset(yAxisX, xAxisY),
          Offset(chartArea.right, xAxisY),
          paint,
        );
        context.returnPaint(paint);
      }

      _renderAxisWithRenderer(
        canvas,
        context,
        _xAxisRenderer!,
        xAxisConfig,
        isVertical: false,
      );

      // Render axis title
      if (xAxisConfig.title != null && xAxisConfig.title!.isNotEmpty) {
        _renderAxisTitle(canvas, context, xAxisConfig, isVertical: false);
      }
    }

    // ===============================
    // Y-AXIS RENDERING
    // ===============================
    if (showYAxis && yAxisConfig.visible && context.yAxisDefinition != null) {
      _yAxisRenderer ??= FusionAxisRendererFactory.create(
        axis: context.yAxisDefinition,
        configuration: yAxisConfig,
        isVertical: true,
      );

      if (yAxisConfig.showAxisLine) {
        final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);

        final paint = context.getPaint(
          color: yAxisConfig.axisLineColor ?? context.theme.axisColor,
          strokeWidth: yAxisConfig.axisLineWidth ?? context.theme.axisLineWidth,
          strokeCap: StrokeCap.square,
        );

        canvas.drawLine(
          Offset(yAxisX, chartArea.top),
          Offset(yAxisX, chartArea.bottom),
          paint,
        );
        context.returnPaint(paint);
      }

      _renderAxisWithRenderer(
        canvas,
        context,
        _yAxisRenderer!,
        yAxisConfig,
        isVertical: true,
      );

      // Render axis title
      if (yAxisConfig.title != null && yAxisConfig.title!.isNotEmpty) {
        _renderAxisTitle(canvas, context, yAxisConfig, isVertical: true);
      }
    }
  }

  void _renderAxisWithRenderer(
    Canvas canvas,
    FusionRenderContext context,
    FusionAxisRenderer renderer,
    FusionAxisConfiguration config, {
    required bool isVertical,
  }) {
    final coordBounds = context.coordSystem.dataBounds;
    final dataMin = isVertical ? coordBounds.top : coordBounds.left;
    final dataMax = isVertical ? coordBounds.bottom : coordBounds.right;

    final axisBounds = renderer.calculateBounds([dataMin, dataMax]);
    final labels = renderer.generateLabels(axisBounds);

    if (config.showTicks) {
      _renderTicks(canvas, context, labels, config, isVertical: isVertical);
    }

    // Minor ticks
    if (config.showMinorTicks) {
      _renderMinorTicks(
        canvas,
        context,
        labels,
        config,
        axisBounds.interval,
        isVertical: isVertical,
      );
    }

    if (config.showLabels) {
      _renderLabels(canvas, context, labels, config, isVertical: isVertical);
    }
  }

  /// Renders axis title.
  void _renderAxisTitle(
    Canvas canvas,
    FusionRenderContext context,
    FusionAxisConfiguration config, {
    required bool isVertical,
  }) {
    final chartArea = context.chartArea;
    final title = config.title!;

    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: context.theme.axisColor,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: title, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    if (isVertical) {
      // Y-axis title - rotated 90 degrees, positioned to the left
      final position = config.getEffectivePosition(isVertical: true);
      final centerY = chartArea.top + chartArea.height / 2;

      canvas.save();

      if (position == AxisPosition.right) {
        canvas.translate(chartArea.right + 50, centerY);
        canvas.rotate(pi / 2);
      } else {
        // Default: left
        canvas.translate(chartArea.left - 50, centerY);
        canvas.rotate(-pi / 2);
      }

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    } else {
      // X-axis title - positioned below labels
      final position = config.getEffectivePosition(isVertical: false);
      final centerX = chartArea.left + chartArea.width / 2;

      final Offset offset;
      if (position == AxisPosition.top) {
        offset = Offset(centerX - textPainter.width / 2, chartArea.top - 40);
      } else {
        offset = Offset(centerX - textPainter.width / 2, chartArea.bottom + 35);
      }

      textPainter.paint(canvas, offset);
    }
  }

  void _renderTicks(
    Canvas canvas,
    FusionRenderContext context,
    List<AxisLabel> labels,
    FusionAxisConfiguration config, {
    required bool isVertical,
  }) {
    final chartArea = context.chartArea;
    final coordSystem = context.coordSystem;
    final position = config.getEffectivePosition(isVertical: isVertical);

    final paint = context.getPaint(
      color: config.majorTickColor ?? context.theme.axisColor,
      strokeWidth: config.majorTickWidth ?? 1.0,
      strokeCap: StrokeCap.square,
    );

    final tickLength = config.majorTickLength ?? 6.0;

    for (final label in labels) {
      if (isVertical) {
        final screenY = coordSystem.dataYToScreenY(label.value).roundToDouble();
        final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);

        if (screenY < chartArea.top - 1 || screenY > chartArea.bottom + 1)
          continue;

        if (position == AxisPosition.right) {
          canvas.drawLine(
            Offset(chartArea.right, screenY),
            Offset(chartArea.right + tickLength, screenY),
            paint,
          );
        } else {
          canvas.drawLine(
            Offset(yAxisX - tickLength, screenY),
            Offset(yAxisX, screenY),
            paint,
          );
        }
      } else {
        final screenX = coordSystem.dataXToScreenX(label.value).roundToDouble();

        if (screenX < chartArea.left - 1 || screenX > chartArea.right + 1)
          continue;

        if (position == AxisPosition.top) {
          canvas.drawLine(
            Offset(screenX, chartArea.top - tickLength),
            Offset(screenX, chartArea.top),
            paint,
          );
        } else {
          canvas.drawLine(
            Offset(screenX, chartArea.bottom),
            Offset(screenX, chartArea.bottom + tickLength),
            paint,
          );
        }
      }
    }

    context.returnPaint(paint);
  }

  /// Renders minor tick marks between major ticks.
  void _renderMinorTicks(
    Canvas canvas,
    FusionRenderContext context,
    List<AxisLabel> majorLabels,
    FusionAxisConfiguration config,
    double majorInterval, {
    required bool isVertical,
  }) {
    if (majorLabels.length < 2) return;

    final chartArea = context.chartArea;
    final coordSystem = context.coordSystem;
    final position = config.getEffectivePosition(isVertical: isVertical);

    final paint = context.getPaint(
      color:
          config.minorTickColor ??
          (config.majorTickColor ?? context.theme.axisColor),
      strokeWidth: config.minorTickWidth ?? 0.5,
      strokeCap: StrokeCap.square,
    );

    final minorTickLength = config.minorTickLength ?? 3.0;
    final minorInterval = majorInterval / 5; // 4 minor ticks between majors

    final dataMin = majorLabels.first.value;
    final dataMax = majorLabels.last.value;

    double current = dataMin;
    while (current <= dataMax) {
      // Skip if on major tick
      final isOnMajor = majorLabels.any(
        (l) => (l.value - current).abs() < majorInterval * 0.01,
      );

      if (!isOnMajor) {
        if (isVertical) {
          final screenY = coordSystem.dataYToScreenY(current).roundToDouble();
          final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);

          if (screenY >= chartArea.top && screenY <= chartArea.bottom) {
            if (position == AxisPosition.right) {
              canvas.drawLine(
                Offset(chartArea.right, screenY),
                Offset(chartArea.right + minorTickLength, screenY),
                paint,
              );
            } else {
              canvas.drawLine(
                Offset(yAxisX - minorTickLength, screenY),
                Offset(yAxisX, screenY),
                paint,
              );
            }
          }
        } else {
          final screenX = coordSystem.dataXToScreenX(current).roundToDouble();

          if (screenX >= chartArea.left && screenX <= chartArea.right) {
            if (position == AxisPosition.top) {
              canvas.drawLine(
                Offset(screenX, chartArea.top - minorTickLength),
                Offset(screenX, chartArea.top),
                paint,
              );
            } else {
              canvas.drawLine(
                Offset(screenX, chartArea.bottom),
                Offset(screenX, chartArea.bottom + minorTickLength),
                paint,
              );
            }
          }
        }
      }

      current += minorInterval;
    }

    context.returnPaint(paint);
  }

  /// Renders labels with proper labelAlignment support.
  void _renderLabels(
    Canvas canvas,
    FusionRenderContext context,
    List<AxisLabel> labels,
    FusionAxisConfiguration config, {
    required bool isVertical,
  }) {
    final chartArea = context.chartArea;
    final coordSystem = context.coordSystem;
    final position = config.getEffectivePosition(isVertical: isVertical);
    final alignment = config.labelAlignment;

    final textStyle = config.labelStyle ?? context.theme.axisLabelStyle;
    final rotation = config.labelRotation ?? 0.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: textStyle);
      textPainter.layout();

      if (isVertical) {
        final screenY = coordSystem.dataYToScreenY(label.value).roundToDouble();
        final yAxisX = coordSystem.dataXToScreenX(coordSystem.dataXMin);

        if (screenY < chartArea.top - 1 || screenY > chartArea.bottom + 1)
          continue;

        // Apply labelAlignment for vertical axis
        double yOffset;
        switch (alignment) {
          case LabelAlignment.start:
            yOffset = screenY - textPainter.height; // Top aligned
          case LabelAlignment.end:
            yOffset = screenY; // Bottom aligned
          case LabelAlignment.center:
            yOffset = screenY - (textPainter.height / 2); // Center aligned
        }

        final Offset labelOffset;
        if (position == AxisPosition.right) {
          labelOffset = Offset(chartArea.right + 8, yOffset);
        } else {
          labelOffset = Offset(yAxisX - textPainter.width - 8, yOffset);
        }

        textPainter.paint(canvas, labelOffset);
      } else {
        final screenX = coordSystem.dataXToScreenX(label.value).roundToDouble();

        if (screenX < chartArea.left - 1 || screenX > chartArea.right + 1)
          continue;

        // Apply labelAlignment for horizontal axis
        double xOffset;
        switch (alignment) {
          case LabelAlignment.start:
            xOffset = screenX; // Left aligned
          case LabelAlignment.end:
            xOffset = screenX - textPainter.width; // Right aligned
          case LabelAlignment.center:
            xOffset = screenX - (textPainter.width / 2); // Center aligned
        }

        if (rotation != 0.0) {
          canvas.save();

          if (position == AxisPosition.top) {
            canvas.translate(screenX, chartArea.top - 8);
          } else {
            canvas.translate(screenX, chartArea.bottom + 8);
          }

          canvas.rotate(rotation * (pi / 180));

          // Adjusted offset for rotation with alignment
          double rotatedXOffset;
          switch (alignment) {
            case LabelAlignment.start:
              rotatedXOffset = 0;
            case LabelAlignment.end:
              rotatedXOffset = -textPainter.width;
            case LabelAlignment.center:
              rotatedXOffset = -textPainter.width / 2;
          }

          textPainter.paint(canvas, Offset(rotatedXOffset, 0));
          canvas.restore();
        } else {
          final Offset labelOffset;

          if (position == AxisPosition.top) {
            labelOffset = Offset(
              xOffset,
              chartArea.top - textPainter.height - 8,
            );
          } else {
            labelOffset = Offset(xOffset, chartArea.bottom + 8);
          }

          textPainter.paint(canvas, labelOffset);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant FusionAxisLayer oldLayer) {
    return oldLayer.showXAxis != showXAxis || oldLayer.showYAxis != showYAxis;
  }

  @override
  void invalidateCache() {
    super.invalidateCache();
    _xAxisRenderer?.dispose();
    _yAxisRenderer?.dispose();
    _xAxisRenderer = null;
    _yAxisRenderer = null;
  }

  @override
  void dispose() {
    _xAxisRenderer?.dispose();
    _yAxisRenderer?.dispose();
    super.dispose();
  }
}

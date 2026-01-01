import 'package:flutter/material.dart';
import '../../configuration/fusion_crosshair_configuration.dart';
import '../../data/fusion_data_point.dart';
import '../engine/fusion_render_context.dart';
import 'fusion_render_layer.dart';

/// Renders crosshair indicator on charts.
class FusionCrosshairLayer extends FusionRenderLayer {
  FusionCrosshairLayer({required this.crosshairConfig, required this.position, this.snappedPoint})
    : super(name: 'crosshair', zIndex: 900);

  /// Crosshair configuration.
  final FusionCrosshairConfiguration crosshairConfig;

  /// Current crosshair position (screen coordinates).
  final Offset? position;

  /// Snapped data point (if snap is enabled).
  final FusionDataPoint? snappedPoint;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    if (!crosshairConfig.enabled || position == null) return;

    final actualPosition = snappedPoint != null && crosshairConfig.snapToDataPoint
        ? context.coordSystem.dataToScreen(snappedPoint!)
        : position!;

    // Get line color from config or theme
    final lineColor = crosshairConfig.lineColor ?? context.theme.crosshairColor;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = crosshairConfig.lineWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical line
    if (crosshairConfig.showVerticalLine) {
      _paintLine(
        canvas,
        Offset(actualPosition.dx, context.chartArea.top),
        Offset(actualPosition.dx, context.chartArea.bottom),
        linePaint,
        crosshairConfig.lineDashArray,
      );

      // Draw X-axis label
      if (crosshairConfig.showLabel && snappedPoint != null) {
        _paintAxisLabel(
          canvas,
          snappedPoint!.label ?? snappedPoint!.x.toStringAsFixed(1),
          Offset(actualPosition.dx, context.chartArea.bottom + 5),
          true,
          context,
        );
      }
    }

    // Draw horizontal line
    if (crosshairConfig.showHorizontalLine) {
      _paintLine(
        canvas,
        Offset(context.chartArea.left, actualPosition.dy),
        Offset(context.chartArea.right, actualPosition.dy),
        linePaint,
        crosshairConfig.lineDashArray,
      );

      // Draw Y-axis label
      if (crosshairConfig.showLabel && snappedPoint != null) {
        _paintAxisLabel(
          canvas,
          snappedPoint!.y.toStringAsFixed(1),
          Offset(context.chartArea.left - 5, actualPosition.dy),
          false,
          context,
        );
      }
    }
  }

  void _paintLine(Canvas canvas, Offset start, Offset end, Paint paint, List<double>? dashArray) {
    if (dashArray == null || dashArray.isEmpty) {
      // Solid line
      canvas.drawLine(start, end, paint);
    } else {
      // Dashed line
      _paintDashedLine(canvas, start, end, paint, dashArray);
    }
  }

  void _paintDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dashArray,
  ) {
    assert(dashArray.length >= 2);

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final lineLength = (end - start).distance;
    final dashCount = (lineLength / (dashArray[0] + dashArray[1])).ceil();

    double currentDistance = 0;
    bool drawDash = true;

    for (int i = 0; i < dashCount * 2; i++) {
      final dashLength = dashArray[i % 2];
      final nextDistance = (currentDistance + dashLength).clamp(0.0, lineLength);

      if (drawDash) {
        final t1 = currentDistance / lineLength;
        final t2 = nextDistance / lineLength;

        canvas.drawLine(
          Offset(start.dx + dx * t1, start.dy + dy * t1),
          Offset(start.dx + dx * t2, start.dy + dy * t2),
          paint,
        );
      }

      currentDistance = nextDistance;
      drawDash = !drawDash;

      if (currentDistance >= lineLength) break;
    }
  }

  void _paintAxisLabel(
    Canvas canvas,
    String text,
    Offset position,
    bool isVertical,
    FusionRenderContext context,
  ) {
    // Use config style, or fall back to theme's axis label style
    final textStyle = crosshairConfig.labelTextStyle ?? 
        context.theme.axisLabelStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final padding = crosshairConfig.labelPadding;
    final bgColor = crosshairConfig.labelBackgroundColor ?? context.theme.primaryColor;

    // Calculate label rect
    Rect labelRect;
    Offset textOffset;

    if (isVertical) {
      // Bottom X-axis label
      labelRect = Rect.fromLTWH(
        position.dx - (textPainter.width + padding.horizontal) / 2,
        position.dy,
        textPainter.width + padding.horizontal,
        textPainter.height + padding.vertical,
      );
      textOffset = Offset(labelRect.left + padding.left, labelRect.top + padding.top);
    } else {
      // Left Y-axis label
      labelRect = Rect.fromLTWH(
        position.dx - (textPainter.width + padding.horizontal),
        position.dy - (textPainter.height + padding.vertical) / 2,
        textPainter.width + padding.horizontal,
        textPainter.height + padding.vertical,
      );
      textOffset = Offset(labelRect.left + padding.left, labelRect.top + padding.top);
    }

    // Draw label background
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(crosshairConfig.labelBorderRadius)),
      Paint()..color = bgColor,
    );

    // Draw text
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant FusionCrosshairLayer oldLayer) {
    return position != oldLayer.position || snappedPoint != oldLayer.snappedPoint;
  }
}

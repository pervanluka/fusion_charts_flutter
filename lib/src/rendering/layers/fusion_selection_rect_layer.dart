import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Painter for rendering selection zoom rectangle overlay.
///
/// Displays a semi-transparent rectangle with a dashed border
/// when the user is performing selection zoom (Shift + drag).
class FusionSelectionRectLayer extends CustomPainter {
  FusionSelectionRectLayer({
    required this.selectionRect,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
  });

  /// The selection rectangle to draw.
  final Rect selectionRect;

  /// Fill color for the selection area.
  /// Defaults to primary color with 10% opacity.
  final Color? fillColor;

  /// Border color for the selection rectangle.
  /// Defaults to primary color.
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Dash segment width for the border.
  final double dashWidth;

  /// Gap between dash segments.
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveFillColor = fillColor ?? Colors.blue.withValues(alpha: 0.1);
    final effectiveBorderColor = borderColor ?? Colors.blue;

    // Draw fill
    final fillPaint = Paint()
      ..color = effectiveFillColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(selectionRect, fillPaint);

    // Draw dashed border
    final borderPaint = Paint()
      ..color = effectiveBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    _drawDashedRect(canvas, selectionRect, borderPaint);

    // Draw corner handles
    _drawCornerHandles(canvas, selectionRect, effectiveBorderColor);

    // Draw dimensions label
    _drawDimensionsLabel(canvas, selectionRect, effectiveBorderColor);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();

    // Top edge
    _addDashedLine(path, rect.topLeft, rect.topRight);
    // Right edge
    _addDashedLine(path, rect.topRight, rect.bottomRight);
    // Bottom edge
    _addDashedLine(path, rect.bottomRight, rect.bottomLeft);
    // Left edge
    _addDashedLine(path, rect.bottomLeft, rect.topLeft);

    canvas.drawPath(path, paint);
  }

  void _addDashedLine(Path path, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final unitX = dx / length;
    final unitY = dy / length;

    var currentX = start.dx;
    var currentY = start.dy;
    var remaining = length;
    var isDash = true;

    while (remaining > 0) {
      final segmentLength = isDash
          ? (dashWidth < remaining ? dashWidth : remaining)
          : (dashGap < remaining ? dashGap : remaining);

      if (isDash) {
        path.moveTo(currentX, currentY);
        path.lineTo(
          currentX + unitX * segmentLength,
          currentY + unitY * segmentLength,
        );
      }

      currentX += unitX * segmentLength;
      currentY += unitY * segmentLength;
      remaining -= segmentLength;
      isDash = !isDash;
    }
  }

  void _drawCornerHandles(Canvas canvas, Rect rect, Color color) {
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const handleSize = 8.0;

    // Draw corner squares
    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    for (final corner in corners) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: corner,
            width: handleSize,
            height: handleSize,
          ),
          const Radius.circular(2),
        ),
        handlePaint,
      );
    }
  }

  void _drawDimensionsLabel(Canvas canvas, Rect rect, Color color) {
    // Only show dimensions if rectangle is large enough
    if (rect.width < 60 || rect.height < 40) return;

    final width = rect.width.toStringAsFixed(0);
    final height = rect.height.toStringAsFixed(0);
    final text = '${width}x$height';

    final textStyle = TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
    );

    final textSpan = TextSpan(text: ' $text ', style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position at bottom center of rectangle
    final textX = rect.center.dx - textPainter.width / 2;
    final textY = rect.bottom + 4;

    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(FusionSelectionRectLayer oldDelegate) {
    return selectionRect != oldDelegate.selectionRect ||
        fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor;
  }
}

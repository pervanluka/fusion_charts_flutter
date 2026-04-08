import 'package:flutter/material.dart';
import '../../annotations/fusion_reference_line.dart';
import '../../core/enums/fusion_label_position.dart';
import '../../data/fusion_data_point.dart';
import '../../series/series_with_data_points.dart';
import '../engine/fusion_render_context.dart';
import 'fusion_render_layer.dart';

/// Renders the dashed/solid lines for reference line annotations.
///
/// zIndex 25 places lines between the grid (10) and series (50),
/// so lines appear behind the data but above the grid.
class FusionReferenceLineLayer extends FusionRenderLayer {
  FusionReferenceLineLayer({
    required this.annotations,
  }) : super(name: 'referenceLines', zIndex: 25);

  final List<FusionReferenceLine> annotations;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final progress = context.animationProgress;
    if (progress <= 0) return;

    final chartArea = context.chartArea;

    // Fade in with animation so lines don't appear before the series
    if (progress < 1.0) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, progress));
    }

    for (final annotation in annotations) {
      if (!annotation.visible) continue;

      final screenY = context.coordSystem.dataYToScreenY(annotation.value);
      if (screenY < chartArea.top || screenY > chartArea.bottom) continue;

      _paintLine(canvas, chartArea, screenY, annotation, context);
    }

    if (progress < 1.0) {
      canvas.restore();
    }
  }

  void _paintLine(
    Canvas canvas,
    Rect chartArea,
    double screenY,
    FusionReferenceLine annotation,
    FusionRenderContext context,
  ) {
    final color = annotation.getEffectiveLineColor(context.theme.gridColor);
    final paint = Paint()
      ..color = color
      ..strokeWidth = annotation.lineWidth
      ..style = PaintingStyle.stroke;

    final start = Offset(chartArea.left, screenY);
    final end = Offset(chartArea.right, screenY);

    if (annotation.lineDashPattern == null || annotation.lineDashPattern!.isEmpty) {
      canvas.drawLine(start, end, paint);
    } else {
      _paintDashedLine(canvas, start, end, paint, annotation.lineDashPattern!);
    }
  }

  void _paintDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dashArray,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final lineLength = (end - start).distance;

    if (lineLength == 0 || dashArray.length < 2) return;

    final dashSum = dashArray[0] + dashArray[1];
    final dashCount = (lineLength / dashSum).ceil();

    double currentDistance = 0;
    bool drawDash = true;

    for (int i = 0; i < dashCount * 2; i++) {
      final dashLength = dashArray[i % dashArray.length];
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

  @override
  bool shouldRepaint(covariant FusionReferenceLineLayer oldLayer) {
    return !identical(annotations, oldLayer.annotations);
  }
}

/// Renders the label badges and dot markers for reference line annotations.
///
/// zIndex 75 places labels above data labels (70) and series (50),
/// so badge containers are never covered by chart content.
class FusionReferenceLineLabelLayer extends FusionRenderLayer {
  FusionReferenceLineLabelLayer({
    required this.annotations,
    this.allSeries = const [],
  }) : super(name: 'referenceLineLabels', zIndex: 75);

  final List<FusionReferenceLine> annotations;
  final List<SeriesWithDataPoints> allSeries;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    final progress = context.animationProgress;
    if (progress <= 0) return;

    final chartArea = context.chartArea;

    // Fade in with animation so labels/dots don't appear before the series
    if (progress < 1.0) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, progress));
    }

    for (final annotation in annotations) {
      if (!annotation.visible) continue;

      final screenY = context.coordSystem.dataYToScreenY(annotation.value);
      if (screenY < chartArea.top || screenY > chartArea.bottom) continue;

      // Calculate badge rect first (needed for dot overlap avoidance)
      Rect? badgeRect;
      if (annotation.label != null && annotation.label!.isNotEmpty) {
        badgeRect = _paintLabelBadge(canvas, chartArea, screenY, annotation, context);
      }

      if (annotation.showDot) {
        _paintDot(canvas, chartArea, screenY, annotation, context, badgeRect);
      }
    }

    if (progress < 1.0) {
      canvas.restore();
    }
  }

  /// Paints a dot on data points that match the annotation value.
  void _paintDot(
    Canvas canvas,
    Rect chartArea,
    double screenY,
    FusionReferenceLine annotation,
    FusionRenderContext context,
    Rect? badgeRect,
  ) {
    final dotColor = annotation.dotColor ??
        annotation.lineColor ??
        context.theme.primaryColor;
    final radius = annotation.dotRadius;

    // Find the LAST data point that matches the annotation Y value
    FusionDataPoint? lastMatch;
    for (final series in allSeries) {
      if (!series.visible) continue;
      for (final point in series.dataPoints) {
        if (point.y == annotation.value) lastMatch = point;
      }
    }
    if (lastMatch == null) return;

    final screenX = context.coordSystem.dataXToScreenX(lastMatch.x);
    if (screenX < chartArea.left || screenX > chartArea.right) return;

    final dotCenter = Offset(screenX, screenY);

    // Skip if dot would overlap the badge
    if (badgeRect != null) {
      final dotBounds = Rect.fromCircle(center: dotCenter, radius: radius);
      if (badgeRect.overlaps(dotBounds)) return;
    }

    // Outer border
    canvas.drawCircle(
      dotCenter,
      radius + 1.5,
      Paint()
        ..color = context.theme.backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Filled dot
    canvas.drawCircle(
      dotCenter,
      radius,
      Paint()..color = dotColor,
    );
  }

  /// Paints the label badge and returns its rect for overlap detection.
  Rect _paintLabelBadge(
    Canvas canvas,
    Rect chartArea,
    double screenY,
    FusionReferenceLine annotation,
    FusionRenderContext context,
  ) {
    final textStyle = annotation.labelStyle ??
        context.theme.axisLabelStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        );

    final textPainter = TextPainter(
      text: TextSpan(text: annotation.label, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: annotation.labelMaxWidth ?? chartArea.width * 0.4);

    final padding = annotation.labelPadding;
    final badgeWidth = textPainter.width + padding.horizontal;
    final badgeHeight = textPainter.height + padding.vertical;

    double badgeX;
    double badgeY;

    switch (annotation.labelPosition) {
      case FusionLabelPosition.right:
        badgeX = chartArea.right - badgeWidth;
        badgeY = screenY - badgeHeight / 2;
      case FusionLabelPosition.left:
        badgeX = chartArea.left;
        badgeY = screenY - badgeHeight / 2;
      case FusionLabelPosition.topRight:
        badgeX = chartArea.right - badgeWidth;
        badgeY = screenY - badgeHeight - 4;
      case FusionLabelPosition.topLeft:
        badgeX = chartArea.left;
        badgeY = screenY - badgeHeight - 4;
    }

    badgeY = badgeY.clamp(chartArea.top, chartArea.bottom - badgeHeight);

    final badgeRect = Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight);
    final bgColor = annotation.getEffectiveLabelBackgroundColor(context.theme.primaryColor);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        badgeRect,
        Radius.circular(annotation.labelBorderRadius),
      ),
      Paint()..color = bgColor,
    );

    textPainter.paint(
      canvas,
      Offset(badgeRect.left + padding.left, badgeRect.top + padding.top),
    );

    return badgeRect;
  }

  @override
  bool shouldRepaint(covariant FusionReferenceLineLabelLayer oldLayer) {
    return !identical(annotations, oldLayer.annotations) ||
        !identical(allSeries, oldLayer.allSeries);
  }
}

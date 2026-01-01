import 'package:flutter/material.dart';
import '../../charts/pie/pie_tooltip_data.dart';
import '../../configuration/fusion_pie_chart_configuration.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../core/enums/fusion_tooltip_position.dart';
import '../../themes/fusion_chart_theme.dart';

/// Renders tooltip overlay for pie charts with full FusionTooltipBehavior support.
///
/// This layer respects all tooltip behavior settings:
/// - Position (floating, top, bottom)
/// - Styling (color, textStyle, borderColor, opacity)
/// - Animation settings
/// - Shared tooltip behavior (N/A for pie - each segment is independent)
class FusionPieTooltipLayer extends CustomPainter {
  FusionPieTooltipLayer({
    required this.tooltipData,
    required this.tooltipBehavior,
    required this.pieConfig,
    required this.theme,
    required this.tooltipOpacity,
    required this.chartArea,
  });

  final PieTooltipData? tooltipData;
  final FusionTooltipBehavior tooltipBehavior;
  final FusionPieChartConfiguration pieConfig;
  final FusionChartTheme theme;
  final double tooltipOpacity;
  final Rect chartArea;

  @override
  void paint(Canvas canvas, Size size) {
    if (!tooltipBehavior.enable || tooltipData == null) return;
    if (tooltipOpacity <= 0) return;

    // Skip tooltip in very small charts (preview cards)
    const minTooltipSize = 120.0;
    if (size.width < minTooltipSize || size.height < minTooltipSize) return;

    final data = tooltipData!;

    // Use custom builder if provided - handled at widget level
    if (tooltipBehavior.builder != null) return;

    // Determine rendering based on position mode
    switch (tooltipBehavior.position) {
      case FusionTooltipPosition.floating:
        _paintFloatingTooltip(canvas, size, data);
      case FusionTooltipPosition.top:
      case FusionTooltipPosition.bottom:
        _paintAnchoredTooltip(canvas, size, data);
    }
  }

  // ===========================================================================
  // FLOATING TOOLTIP (Default)
  // ===========================================================================

  void _paintFloatingTooltip(Canvas canvas, Size size, PieTooltipData data) {
    final bgColor = tooltipBehavior.color ?? theme.tooltipBackgroundColor;
    final effectiveTextColor = _getContrastingTextColor(bgColor);
    final baseStyle = tooltipBehavior.textStyle ?? theme.tooltipStyle;
    final textStyle = baseStyle.copyWith(color: effectiveTextColor);
    final borderRadius = theme.tooltipBorderRadius;

    // Build tooltip content
    final content = _buildTooltipContent(data);

    final textPainter = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final padding = theme.tooltipPadding;
    final tooltipWidth = textPainter.width + padding.horizontal + 16; // +16 for color indicator
    final tooltipHeight = textPainter.height + padding.vertical;
    final tooltipSize = Size(tooltipWidth, tooltipHeight);

    // Calculate optimal position
    final tooltipPosition = _calculateFloatingPosition(
      dataPointScreen: data.screenPosition,
      tooltipSize: tooltipSize,
      chartSize: size,
    );

    final tooltipRect = Rect.fromLTWH(
      tooltipPosition.dx,
      tooltipPosition.dy,
      tooltipWidth,
      tooltipHeight,
    );

    // Apply opacity
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: tooltipOpacity));

    // Draw shadow
    if (tooltipBehavior.elevation > 0) {
      _paintShadow(canvas, tooltipRect, borderRadius);
    }

    // Draw background
    _paintBackground(canvas, tooltipRect, bgColor, borderRadius);

    // Draw border
    if (tooltipBehavior.borderWidth > 0) {
      _paintBorder(canvas, tooltipRect, data.color, borderRadius);
    }

    // Draw color indicator
    final indicatorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        tooltipPosition.dx + padding.left,
        tooltipPosition.dy + padding.top,
        4,
        textPainter.height,
      ),
      Radius.circular(theme.tooltipIndicatorRadius),
    );
    canvas.drawRRect(indicatorRect, Paint()..color = data.color);

    // Draw text
    textPainter.paint(
      canvas,
      Offset(tooltipPosition.dx + padding.left + 12, tooltipPosition.dy + padding.top),
    );

    // Draw arrow pointing to segment
    _paintArrow(canvas, tooltipRect, data.screenPosition, bgColor);

    canvas.restore();

    // Note: Marker removed for pie charts - segment itself serves as the visual indicator
  }

  // ===========================================================================
  // ANCHORED TOOLTIP (Top/Bottom)
  // ===========================================================================

  void _paintAnchoredTooltip(Canvas canvas, Size size, PieTooltipData data) {
    final bgColor = tooltipBehavior.color ?? theme.tooltipBackgroundColor;
    final effectiveTextColor = _getContrastingTextColor(bgColor);
    final baseStyle = tooltipBehavior.textStyle ?? theme.tooltipStyle;
    final textStyle = baseStyle.copyWith(color: effectiveTextColor);
    final borderRadius = theme.tooltipBorderRadius;
    final isTop = tooltipBehavior.position == FusionTooltipPosition.top;

    // Build content
    final content = _buildTooltipContent(data);

    final textPainter = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final padding = theme.tooltipPadding;
    final tooltipWidth = textPainter.width + padding.horizontal + 16;
    final tooltipHeight = textPainter.height + padding.vertical;
    const boundaryPadding = 8.0;

    // Calculate anchored position
    final tooltipY = isTop
        ? chartArea.top + boundaryPadding
        : chartArea.bottom - tooltipHeight - boundaryPadding;

    // Calculate X bounds with safety for small charts
    final minX = chartArea.left + boundaryPadding;
    final maxX = chartArea.right - tooltipWidth - boundaryPadding;
    final effectiveMaxX = maxX < minX ? minX : maxX;

    var tooltipX = data.screenPosition.dx - tooltipWidth / 2;
    tooltipX = tooltipX.clamp(minX, effectiveMaxX);

    final tooltipRect = Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight);

    // Apply opacity
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: tooltipOpacity));

    // Draw trackball line
    if (tooltipBehavior.showTrackballLine) {
      _paintTrackballLine(
        canvas: canvas,
        tooltipRect: tooltipRect,
        dataPoint: data.segmentCenter,
        color: data.color,
        isTop: isTop,
      );
    }

    // Draw shadow
    if (tooltipBehavior.elevation > 0) {
      _paintShadow(canvas, tooltipRect, borderRadius);
    }

    // Draw background
    _paintBackground(canvas, tooltipRect, bgColor, borderRadius);

    // Draw border
    if (tooltipBehavior.borderWidth > 0) {
      _paintBorder(canvas, tooltipRect, data.color, borderRadius);
    }

    // Draw color indicator
    final indicatorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX + padding.left, tooltipY + padding.top, 4, textPainter.height),
      Radius.circular(theme.tooltipIndicatorRadius),
    );
    canvas.drawRRect(indicatorRect, Paint()..color = data.color);

    // Draw text
    textPainter.paint(canvas, Offset(tooltipX + padding.left + 12, tooltipY + padding.top));

    canvas.restore();

    // Note: Marker removed for pie charts - segment itself serves as the visual indicator
  }

  // ===========================================================================
  // CONTENT BUILDING
  // ===========================================================================

  String _buildTooltipContent(PieTooltipData data) {
    final parts = <String>[];

    // Label
    if (data.label != null && data.label!.isNotEmpty) {
      parts.add(data.label!);
    } else {
      parts.add('Segment ${data.index}');
    }

    // Percentage - always shown for pie charts (it's the key metric)
    parts.add(data.formattedPercentage);

    // Value - only show if explicitly configured via valueFormatter
    // Raw numbers without context (units, currency) are confusing
    // Users can add custom formatting: tooltipBehavior.valueFormatter
    // For now, skip raw value by default - percentage is sufficient

    return parts.join('\n');
  }

  // ===========================================================================
  // POSITIONING
  // ===========================================================================

  Offset _calculateFloatingPosition({
    required Offset dataPointScreen,
    required Size tooltipSize,
    required Size chartSize,
  }) {
    const verticalGap = 12.0;
    const horizontalPadding = 8.0;

    // Calculate bounds
    final minY = chartArea.top + horizontalPadding;
    final maxY = chartArea.bottom - tooltipSize.height - horizontalPadding;
    final minX = chartArea.left + horizontalPadding;
    final maxX = chartArea.right - tooltipSize.width - horizontalPadding;

    // Handle case where tooltip doesn't fit (small charts)
    // Use the best available position rather than crashing
    final effectiveMinY = minY;
    final effectiveMaxY = maxY < minY ? minY : maxY;
    final effectiveMinX = minX;
    final effectiveMaxX = maxX < minX ? minX : maxX;

    // Try above first
    double tooltipY = dataPointScreen.dy - tooltipSize.height - verticalGap;

    // If not enough space above, go below
    if (tooltipY < effectiveMinY) {
      tooltipY = dataPointScreen.dy + verticalGap;
    }

    // Clamp to bounds
    tooltipY = tooltipY.clamp(effectiveMinY, effectiveMaxY);

    // Center horizontally on point, then clamp
    double tooltipX = dataPointScreen.dx - tooltipSize.width / 2;
    tooltipX = tooltipX.clamp(effectiveMinX, effectiveMaxX);

    return Offset(tooltipX, tooltipY);
  }

  // ===========================================================================
  // RENDERING HELPERS
  // ===========================================================================

  void _paintShadow(Canvas canvas, Rect rect, double borderRadius) {
    final shadowColor = tooltipBehavior.shadowColor ?? Colors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      Paint()
        ..color = shadowColor.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, tooltipBehavior.elevation * 2),
    );
  }

  void _paintBackground(Canvas canvas, Rect rect, Color bgColor, double borderRadius) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      Paint()
        ..color = bgColor.withValues(alpha: tooltipBehavior.opacity)
        ..style = PaintingStyle.fill,
    );
  }

  void _paintBorder(Canvas canvas, Rect rect, Color color, double borderRadius) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      Paint()
        ..color = tooltipBehavior.borderColor ?? color
        ..strokeWidth = tooltipBehavior.borderWidth
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintArrow(Canvas canvas, Rect tooltipRect, Offset targetPoint, Color bgColor) {
    const arrowSize = 6.0;
    const overlapTolerance = 4.0;

    // Don't draw arrow if point is inside tooltip
    if (tooltipRect.inflate(overlapTolerance).contains(targetPoint)) {
      return;
    }

    // Calculate arrow X bounds with safety
    final minArrowX = tooltipRect.left + arrowSize + 4;
    final maxArrowX = tooltipRect.right - arrowSize - 4;

    // Skip arrow if tooltip is too small
    if (maxArrowX <= minArrowX) return;

    final path = Path();
    final paint = Paint()..color = bgColor.withValues(alpha: tooltipBehavior.opacity);

    final isAbove = targetPoint.dy < tooltipRect.top;
    final isBelow = targetPoint.dy > tooltipRect.bottom;

    if (isAbove) {
      final arrowX = targetPoint.dx.clamp(minArrowX, maxArrowX);
      path.moveTo(arrowX - arrowSize, tooltipRect.top);
      path.lineTo(arrowX, tooltipRect.top - arrowSize);
      path.lineTo(arrowX + arrowSize, tooltipRect.top);
    } else if (isBelow) {
      final arrowX = targetPoint.dx.clamp(minArrowX, maxArrowX);
      path.moveTo(arrowX - arrowSize, tooltipRect.bottom);
      path.lineTo(arrowX, tooltipRect.bottom + arrowSize);
      path.lineTo(arrowX + arrowSize, tooltipRect.bottom);
    }

    if (path.getBounds() != Rect.zero) {
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintTrackballLine({
    required Canvas canvas,
    required Rect tooltipRect,
    required Offset dataPoint,
    required Color color,
    required bool isTop,
  }) {
    final lineColor = tooltipBehavior.trackballLineColor ?? color.withValues(alpha: 0.5);
    final lineWidth = tooltipBehavior.trackballLineWidth;
    final dashPattern = tooltipBehavior.trackballLineDashPattern;

    const minLineDistance = 10.0;

    final lineStart = isTop
        ? Offset(dataPoint.dx, tooltipRect.bottom)
        : Offset(dataPoint.dx, tooltipRect.top);
    final lineEnd = dataPoint;

    final distance = (lineEnd.dy - lineStart.dy).abs();
    if (distance < minLineDistance) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    if (dashPattern != null && dashPattern.isNotEmpty) {
      _drawDashedLine(canvas, lineStart, lineEnd, paint, dashPattern);
    } else {
      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dashPattern,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    final dashedPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      int dashIndex = 0;

      while (distance < metric.length) {
        final dashLength = dashPattern[dashIndex % dashPattern.length];
        final nextDistance = distance + dashLength;

        if (draw) {
          final extractPath = metric.extractPath(distance, nextDistance.clamp(0, metric.length));
          dashedPath.addPath(extractPath, Offset.zero);
        }

        distance = nextDistance;
        draw = !draw;
        dashIndex++;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(covariant FusionPieTooltipLayer oldDelegate) {
    return tooltipData != oldDelegate.tooltipData || tooltipOpacity != oldDelegate.tooltipOpacity;
  }
}

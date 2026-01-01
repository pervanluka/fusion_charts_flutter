import 'package:flutter/material.dart';
import '../../charts/fusion_stacked_bar_interactive_state.dart';
import '../../configuration/fusion_tooltip_configuration.dart' show FusionTooltipBehavior;
import '../../configuration/fusion_stacked_tooltip_builder.dart';
import '../../themes/fusion_chart_theme.dart';
import '../engine/fusion_render_context.dart';

/// Renders tooltips specifically for stacked bar charts.
///
/// Shows a multi-line tooltip with all segments in the stack.
/// Supports custom formatters for values and totals.
class FusionStackedTooltipLayer {
  const FusionStackedTooltipLayer();

  void render(
    Canvas canvas,
    FusionRenderContext context,
    StackedTooltipData tooltipData,
    FusionTooltipBehavior tooltipConfig, {
    FusionStackedValueFormatter? valueFormatter,
    FusionStackedTotalFormatter? totalFormatter,
  }) {
    final segments = tooltipData.segments;
    if (segments.isEmpty) return;

    final theme = context.theme;

    // Convert to public API types
    final info = _convertToPublicInfo(tooltipData);

    // Get styling from theme with fallbacks
    final backgroundColor = tooltipConfig.color ?? _getTooltipBackgroundColor(theme);
    final textColor = tooltipConfig.textStyle?.color ?? _getTooltipTextColor(theme);
    final fontSize = tooltipConfig.textStyle?.fontSize ?? theme.tooltipStyle.fontSize ?? 12.0;
    final fontWeight =
        tooltipConfig.textStyle?.fontWeight ?? theme.tooltipStyle.fontWeight ?? FontWeight.w500;
    final borderRadius = theme.borderRadius;
    final borderColor = tooltipConfig.borderColor ?? theme.borderColor;
    final borderWidth = tooltipConfig.borderWidth;
    final shadowColor = tooltipConfig.shadowColor ?? Colors.black;

    // Calculate tooltip dimensions
    const horizontalPadding = 12.0;
    const verticalPadding = 10.0;
    const lineHeight = 20.0;
    const colorDotSize = 8.0;
    const colorDotSpacing = 8.0;

    // Text styles from theme
    final textStyle = TextStyle(color: textColor, fontSize: fontSize, fontWeight: fontWeight);
    final boldTextStyle = textStyle.copyWith(fontWeight: FontWeight.bold);

    // Get formatted total text (may be null to hide)
    final totalText = _formatTotal(info, totalFormatter);
    final showTotal = totalText != null;

    double maxTextWidth = 0;

    // Measure category label
    if (tooltipData.categoryLabel != null) {
      final labelPainter = TextPainter(
        text: TextSpan(text: tooltipData.categoryLabel, style: boldTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      maxTextWidth = labelPainter.width;
    }

    // Measure each segment line
    for (int i = 0; i < info.segments.length; i++) {
      final segment = info.segments[i];
      final valueText = _formatValue(segment, info, valueFormatter);

      final linePainter = TextPainter(
        text: TextSpan(text: '${segment.seriesName}: $valueText', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final lineWidth = colorDotSize + colorDotSpacing + linePainter.width;
      if (lineWidth > maxTextWidth) maxTextWidth = lineWidth;
    }

    // Measure total line
    if (showTotal) {
      final totalPainter = TextPainter(
        text: TextSpan(text: totalText, style: boldTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      if (totalPainter.width > maxTextWidth) maxTextWidth = totalPainter.width;
    }

    // Calculate tooltip size
    final hasLabel = tooltipData.categoryLabel != null;
    final lineCount = segments.length + (hasLabel ? 1 : 0) + (showTotal ? 1 : 0);
    final separatorHeight = showTotal ? 8.0 : 0.0;
    const arrowSize = 8.0;

    final tooltipWidth = maxTextWidth + (horizontalPadding * 2);
    final tooltipHeight = (lineCount * lineHeight) + (verticalPadding * 2) + separatorHeight;

    // Arrow position is at the horizontal center of the bar's top edge
    final arrowTargetX = tooltipData.screenPosition.dx;
    final arrowTargetY = tooltipData.screenPosition.dy;

    // Position tooltip centered above the arrow target point
    var tooltipX = arrowTargetX - (tooltipWidth / 2);
    var tooltipY = arrowTargetY - tooltipHeight - arrowSize - 4;

    // Constrain to chart area
    final chartArea = context.chartArea;
    bool showBelow = false;

    if (tooltipX < chartArea.left + 4) {
      tooltipX = chartArea.left + 4;
    }
    if (tooltipX + tooltipWidth > chartArea.right - 4) {
      tooltipX = chartArea.right - tooltipWidth - 4;
    }
    if (tooltipY < chartArea.top + 4) {
      tooltipY = arrowTargetY + arrowSize + 4;
      showBelow = true;
    }

    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
      Radius.circular(borderRadius),
    );

    // Draw shadow
    final shadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(tooltipRect.shift(const Offset(0, 2)), shadowPaint);

    // Draw background
    final bgPaint = Paint()..color = backgroundColor.withValues(alpha: tooltipConfig.opacity);
    canvas.drawRRect(tooltipRect, bgPaint);

    // Draw border
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRRect(tooltipRect, borderPaint);
    }

    // Draw arrow
    _drawArrow(
      canvas,
      tooltipRect,
      arrowTargetX,
      arrowTargetY,
      backgroundColor.withValues(alpha: tooltipConfig.opacity),
      arrowSize,
      showBelow,
    );

    // Draw content
    var currentY = tooltipY + verticalPadding;
    final contentX = tooltipX + horizontalPadding;

    // Draw category label (centered)
    if (tooltipData.categoryLabel != null) {
      final labelPainter = TextPainter(
        text: TextSpan(text: tooltipData.categoryLabel, style: boldTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(tooltipX + (tooltipWidth - labelPainter.width) / 2, currentY),
      );
      currentY += lineHeight;
    }

    // Draw each segment (reversed so top segment appears first in tooltip)
    for (final segment in info.segments.reversed) {
      // Draw color dot
      final dotPaint = Paint()..color = segment.color;
      canvas.drawCircle(
        Offset(contentX + colorDotSize / 2, currentY + lineHeight / 2),
        colorDotSize / 2,
        dotPaint,
      );

      // Draw segment text
      final valueText = _formatValue(segment, info, valueFormatter);

      final segmentPainter = TextPainter(
        text: TextSpan(text: '${segment.seriesName}: $valueText', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      segmentPainter.paint(canvas, Offset(contentX + colorDotSize + colorDotSpacing, currentY));
      currentY += lineHeight;
    }

    // Draw separator and total
    if (showTotal) {
      final separatorY = currentY + separatorHeight / 2;
      final separatorPaint = Paint()
        ..color = textColor.withValues(alpha: 0.2)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(contentX, separatorY),
        Offset(tooltipX + tooltipWidth - horizontalPadding, separatorY),
        separatorPaint,
      );
      currentY += separatorHeight;

      final totalPainterFinal = TextPainter(
        text: TextSpan(text: totalText, style: boldTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      totalPainterFinal.paint(canvas, Offset(contentX, currentY));
    }
  }

  /// Converts internal tooltip data to public API types.
  FusionStackedTooltipInfo _convertToPublicInfo(StackedTooltipData data) {
    return FusionStackedTooltipInfo(
      categoryIndex: 0, // Not tracked in current implementation
      categoryLabel: data.categoryLabel,
      segments: data.segments
          .map(
            (s) => FusionStackedSegment(
              seriesName: s.seriesName,
              color: s.seriesColor,
              value: s.value,
              percentage: s.percentage,
            ),
          )
          .toList(),
      totalValue: data.totalValue,
      isStacked100: data.isStacked100,
      hitSegmentIndex: data.hitSegmentIndex,
    );
  }

  /// Formats a segment value using custom formatter or default.
  String _formatValue(
    FusionStackedSegment segment,
    FusionStackedTooltipInfo info,
    FusionStackedValueFormatter? formatter,
  ) {
    if (formatter != null) {
      return formatter(segment.value, segment, info);
    }

    // Default: simple value with appropriate precision
    if (info.isStacked100) {
      return '${segment.percentage.toStringAsFixed(1)}%';
    }

    // Use reasonable precision based on value magnitude
    if (segment.value == segment.value.roundToDouble()) {
      return segment.value.toInt().toString();
    }
    return segment.value.toStringAsFixed(2);
  }

  /// Formats total using custom formatter or default.
  /// Returns null to hide the total line.
  String? _formatTotal(FusionStackedTooltipInfo info, FusionStackedTotalFormatter? formatter) {
    if (formatter != null) {
      return formatter(info.totalValue, info);
    }

    // Default: show "Total: value"
    if (info.isStacked100) {
      return 'Total: 100%';
    }

    final value = info.totalValue;
    if (value == value.roundToDouble()) {
      return 'Total: ${value.toInt()}';
    }
    return 'Total: ${value.toStringAsFixed(2)}';
  }

  Color _getTooltipBackgroundColor(FusionChartTheme theme) {
    final bgLuminance = theme.backgroundColor.computeLuminance();
    if (bgLuminance > 0.5) {
      return const Color(0xFF1F2937);
    } else {
      return const Color(0xFF374151);
    }
  }

  Color _getTooltipTextColor(FusionChartTheme theme) {
    return Colors.white;
  }

  void _drawArrow(
    Canvas canvas,
    RRect tooltipRect,
    double arrowTargetX,
    double arrowTargetY,
    Color backgroundColor,
    double arrowSize,
    bool showBelow,
  ) {
    final minArrowX = tooltipRect.left + arrowSize + 4;
    final maxArrowX = tooltipRect.right - arrowSize - 4;
    final clampedArrowX = arrowTargetX.clamp(minArrowX, maxArrowX);

    final arrowPath = Path();

    if (showBelow) {
      final arrowY = tooltipRect.top;
      arrowPath.moveTo(clampedArrowX - arrowSize, arrowY);
      arrowPath.lineTo(clampedArrowX, arrowY - arrowSize);
      arrowPath.lineTo(clampedArrowX + arrowSize, arrowY);
      arrowPath.close();
    } else {
      final arrowY = tooltipRect.bottom;
      arrowPath.moveTo(clampedArrowX - arrowSize, arrowY);
      arrowPath.lineTo(clampedArrowX, arrowY + arrowSize);
      arrowPath.lineTo(clampedArrowX + arrowSize, arrowY);
      arrowPath.close();
    }

    final paint = Paint()..color = backgroundColor;
    canvas.drawPath(arrowPath, paint);
  }
}

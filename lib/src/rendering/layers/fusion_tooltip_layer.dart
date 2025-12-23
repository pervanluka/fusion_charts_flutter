import 'package:flutter/material.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../data/fusion_data_point.dart';
import '../../utils/fusion_data_formatter.dart';
import '../../series/fusion_series.dart';
import '../../series/series_with_data_points.dart';
import '../engine/fusion_render_context.dart';
import 'fusion_render_layer.dart';

/// Renders tooltip overlay on charts with presision positioning.
class FusionTooltipLayer extends FusionRenderLayer {
  FusionTooltipLayer({
    required this.tooltipData,
    required this.tooltipBehavior,
    this.allSeries = const [],
  }) : super(name: 'tooltip', zIndex: 1000);

  final TooltipRenderData? tooltipData;
  final FusionTooltipBehavior tooltipBehavior;
  final List<SeriesWithDataPoints> allSeries;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    if (!tooltipBehavior.enable || tooltipData == null) return;

    final point = tooltipData!.point;
    final screenPos = tooltipData!.screenPosition;
    final seriesName = tooltipData!.seriesName;
    final seriesColor = tooltipData!.seriesColor;
    final sharedPoints = tooltipData!.sharedPoints;

    if (tooltipBehavior.builder != null) {
      return;
    }

    // Check if we have shared points to render
    if (tooltipBehavior.shared && sharedPoints != null && sharedPoints.isNotEmpty) {
      _paintSharedTooltip(canvas, size, context, point, screenPos, seriesName, seriesColor, sharedPoints);
    } else {
      _paintDefaultTooltip(canvas, size, context, point, screenPos, seriesName, seriesColor);
    }
  }

  void _paintDefaultTooltip(
    Canvas canvas,
    Size size,
    FusionRenderContext context,
    FusionDataPoint point,
    Offset screenPos,
    String seriesName,
    Color seriesColor,
  ) {
    final valueText = tooltipBehavior.format != null
        ? tooltipBehavior.format!(point, seriesName)
        : FusionDataFormatter.formatPrecise(point.y, maxDecimals: tooltipBehavior.decimalPlaces);

    final labelText = point.label != null ? '${point.label}\n' : '';
    final fullText = '$labelText$seriesName: $valueText';

    // Determine appropriate text color based on background
    final bgColor = tooltipBehavior.color ?? Colors.black87;
    final effectiveTextColor = _getContrastingTextColor(bgColor);
    
    // Use config style with proper text color, or create from theme
    final baseStyle = tooltipBehavior.textStyle ?? context.theme.tooltipStyle;
    final textStyle = baseStyle.copyWith(color: effectiveTextColor);

    final textPainter = TextPainter(
      text: TextSpan(text: fullText, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final dpiScale = context.devicePixelRatio;
    final padding = EdgeInsets.symmetric(horizontal: 12 * dpiScale, vertical: 8 * dpiScale);
    final tooltipWidth = textPainter.width + padding.horizontal;
    final tooltipHeight = textPainter.height + padding.vertical;
    final tooltipSize = Size(tooltipWidth, tooltipHeight);

    final tooltipPosition = _calculateOptimalTooltipPosition(
      dataPointScreen: screenPos,
      tooltipSize: tooltipSize,
      chartSize: size,
      chartArea: context.chartArea,
      markerRadius: _getMarkerRadius(seriesName, context),
      dpiScale: dpiScale,
    );

    final tooltipRect = Rect.fromLTWH(
      tooltipPosition.dx,
      tooltipPosition.dy,
      tooltipWidth,
      tooltipHeight,
    );

    if (tooltipBehavior.elevation > 0) {
      _paintShadow(canvas, tooltipRect, tooltipBehavior);
    }

    _paintBackground(canvas, tooltipRect, bgColor, tooltipBehavior);

    if (tooltipBehavior.borderWidth > 0) {
      _paintBorder(canvas, tooltipRect, seriesColor, tooltipBehavior);
    }

    textPainter.paint(
      canvas,
      Offset(tooltipPosition.dx + padding.left, tooltipPosition.dy + padding.top),
    );

    if (tooltipBehavior.canShowMarker) {
      _paintMarker(canvas, screenPos, seriesColor);
    }

    _paintPreciseArrow(canvas, tooltipRect, screenPos, bgColor, tooltipPosition);
  }

  /// Paints a shared tooltip showing all series values at the same X position.
  void _paintSharedTooltip(
    Canvas canvas,
    Size size,
    FusionRenderContext context,
    FusionDataPoint primaryPoint,
    Offset primaryScreenPos,
    String primarySeriesName,
    Color primarySeriesColor,
    List<SharedTooltipPoint> sharedPoints,
  ) {
    // Determine appropriate text color based on background
    final bgColor = tooltipBehavior.color ?? Colors.black87;
    final effectiveTextColor = _getContrastingTextColor(bgColor);
    
    // Use config style with proper text color, or create from theme
    final baseStyle = tooltipBehavior.textStyle ?? context.theme.tooltipStyle;
    final textStyle = baseStyle.copyWith(color: effectiveTextColor);
    
    final dpiScale = context.devicePixelRatio;
    final padding = EdgeInsets.symmetric(horizontal: 12 * dpiScale, vertical: 8 * dpiScale);
    final lineHeight = (textStyle.fontSize ?? 12.0) * 1.4; // Better line height
    final rowSpacing = 4.0 * dpiScale;
    
    // Build all entries (primary + shared)
    final entries = <_TooltipEntry>[
      _TooltipEntry(
        seriesName: primarySeriesName,
        color: primarySeriesColor,
        value: tooltipBehavior.format != null
            ? tooltipBehavior.format!(primaryPoint, primarySeriesName)
            : FusionDataFormatter.formatPrecise(primaryPoint.y, maxDecimals: tooltipBehavior.decimalPlaces),
        screenPosition: primaryScreenPos,
      ),
      ...sharedPoints.map((sp) => _TooltipEntry(
        seriesName: sp.seriesName,
        color: sp.seriesColor,
        value: tooltipBehavior.format != null
            ? tooltipBehavior.format!(sp.point, sp.seriesName)
            : FusionDataFormatter.formatPrecise(sp.point.y, maxDecimals: tooltipBehavior.decimalPlaces),
        screenPosition: sp.screenPosition,
      )),
    ];
    
    // Calculate max width needed
    double maxTextWidth = 0;
    for (final entry in entries) {
      final text = '${entry.seriesName}: ${entry.value}';
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      maxTextWidth = maxTextWidth > painter.width ? maxTextWidth : painter.width;
    }
    
    // Add space for color indicator
    const colorIndicatorSize = 8.0;
    const colorIndicatorMargin = 8.0;
    final contentWidth = maxTextWidth + colorIndicatorSize + colorIndicatorMargin;
    
    // Calculate tooltip dimensions
    final tooltipWidth = contentWidth + padding.horizontal;
    final tooltipHeight = (entries.length * (lineHeight + rowSpacing)) - rowSpacing + padding.vertical;
    final tooltipSize = Size(tooltipWidth, tooltipHeight);
    
    // Calculate center position (average X, topmost Y for positioning)
    double avgX = 0;
    double minY = double.infinity;
    for (final entry in entries) {
      avgX += entry.screenPosition.dx;
      if (entry.screenPosition.dy < minY) minY = entry.screenPosition.dy;
    }
    avgX /= entries.length;
    
    final centerPosition = Offset(avgX, minY);
    
    final tooltipPosition = _calculateOptimalTooltipPosition(
      dataPointScreen: centerPosition,
      tooltipSize: tooltipSize,
      chartSize: size,
      chartArea: context.chartArea,
      markerRadius: _getMarkerRadius(primarySeriesName, context),
      dpiScale: dpiScale,
    );
    
    final tooltipRect = Rect.fromLTWH(
      tooltipPosition.dx,
      tooltipPosition.dy,
      tooltipWidth,
      tooltipHeight,
    );
    
    // FIRST: Draw markers for all points (BEFORE tooltip so they don't overlap)
    if (tooltipBehavior.canShowMarker) {
      for (final entry in entries) {
        _paintMarker(canvas, entry.screenPosition, entry.color);
      }
    }
    
    // THEN: Draw tooltip background (on top of markers)
    if (tooltipBehavior.elevation > 0) {
      _paintShadow(canvas, tooltipRect, tooltipBehavior);
    }
    
    _paintBackground(canvas, tooltipRect, bgColor, tooltipBehavior);
    
    if (tooltipBehavior.borderWidth > 0) {
      _paintBorder(canvas, tooltipRect, primarySeriesColor, tooltipBehavior);
    }
    
    // Draw each entry
    double currentY = tooltipPosition.dy + padding.top;
    for (final entry in entries) {
      // Draw color indicator
      final indicatorPaint = Paint()
        ..color = entry.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(
          tooltipPosition.dx + padding.left + colorIndicatorSize / 2,
          currentY + lineHeight / 2,
        ),
        colorIndicatorSize / 2,
        indicatorPaint,
      );
      
      // Draw text
      final text = '${entry.seriesName}: ${entry.value}';
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      
      textPainter.paint(
        canvas,
        Offset(
          tooltipPosition.dx + padding.left + colorIndicatorSize + colorIndicatorMargin,
          currentY + (lineHeight - textPainter.height) / 2, // Center text vertically
        ),
      );
      
      currentY += lineHeight + rowSpacing;
    }
    
    // Draw arrow pointing to center
    _paintPreciseArrow(canvas, tooltipRect, centerPosition, bgColor, tooltipPosition);
  }
  
  /// Returns a contrasting text color for the given background.
  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Use white text for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // ==========================================================================
  // PRECISION POSITIONING ALGORITHM
  // ==========================================================================

  Offset _calculateOptimalTooltipPosition({
    required Offset dataPointScreen,
    required Size tooltipSize,
    required Size chartSize,
    required Rect chartArea,
    required double markerRadius,
    required double dpiScale,
  }) {
    final verticalGap = 8.0 * dpiScale;
    final horizontalPadding = 12.0 * dpiScale;
    final boundaryPadding = 8.0 * dpiScale;

    final spaceAbove = dataPointScreen.dy - chartArea.top;
    final spaceBelow = chartArea.bottom - dataPointScreen.dy;

    final requiredVerticalSpace = tooltipSize.height + markerRadius + verticalGap;

    // Determine vertical position
    double tooltipY;
    if (spaceAbove >= requiredVerticalSpace) {
      // Position above (preferred)
      tooltipY = dataPointScreen.dy - markerRadius - verticalGap - tooltipSize.height;
    } else if (spaceBelow >= requiredVerticalSpace) {
      // Position below
      tooltipY = dataPointScreen.dy + markerRadius + verticalGap;
    } else {
      // Not enough space above or below - center vertically
      final minY = chartArea.top + boundaryPadding;
      final maxY = chartArea.bottom - tooltipSize.height - boundaryPadding;
      // Handle case where tooltip is taller than chart area
      if (maxY < minY) {
        tooltipY = chartArea.top; // Just align to top
      } else {
        tooltipY = (dataPointScreen.dy - tooltipSize.height / 2).clamp(minY, maxY);
      }
    }

    // Determine horizontal position (centered on data point)
    double tooltipX = dataPointScreen.dx - tooltipSize.width / 2;

    // Apply boundary collision detection with safe clamp
    final minX = chartArea.left + horizontalPadding;
    final maxX = chartArea.right - tooltipSize.width - horizontalPadding;
    // Handle case where tooltip is wider than chart area
    if (maxX < minX) {
      // Center the tooltip as best we can
      tooltipX = chartArea.left + (chartArea.width - tooltipSize.width) / 2;
    } else {
      tooltipX = tooltipX.clamp(minX, maxX);
    }

    // Ensure tooltip stays within chart bounds vertically with safe clamp
    final minYFinal = chartArea.top + boundaryPadding;
    final maxYFinal = chartArea.bottom - tooltipSize.height - boundaryPadding;
    if (maxYFinal >= minYFinal) {
      tooltipY = tooltipY.clamp(minYFinal, maxYFinal);
    }

    return Offset(tooltipX, tooltipY);
  }

  double _getMarkerRadius(String seriesName, FusionRenderContext context) {
    for (final series in allSeries) {
      if (series.name == seriesName && series is FusionMarkerSupport) {
        final markerSeries = series as FusionMarkerSupport;
        if (markerSeries.showMarkers) {
          return (markerSeries.markerSize * context.animationProgress) / 2;
        }
      }
    }

    return 4.0 * context.devicePixelRatio;
  }

  // ==========================================================================
  // RENDERING HELPERS
  // ==========================================================================

  void _paintShadow(Canvas canvas, Rect tooltipRect, FusionTooltipBehavior behavior) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)),
      Paint()
        ..color = (behavior.shadowColor ?? Colors.black).withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, behavior.elevation * 2),
    );
  }

  void _paintBackground(
    Canvas canvas,
    Rect tooltipRect,
    Color bgColor,
    FusionTooltipBehavior behavior,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)),
      Paint()
        ..color = bgColor.withValues(alpha: behavior.opacity)
        ..style = PaintingStyle.fill,
    );
  }

  void _paintBorder(
    Canvas canvas,
    Rect tooltipRect,
    Color seriesColor,
    FusionTooltipBehavior behavior,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)),
      Paint()
        ..color = behavior.borderColor ?? seriesColor
        ..strokeWidth = behavior.borderWidth
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintMarker(Canvas canvas, Offset position, Color color) {
    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(position, 6, borderPaint);
    canvas.drawCircle(position, 4, markerPaint);
  }

  void _paintPreciseArrow(
    Canvas canvas,
    Rect tooltipRect,
    Offset dataPointScreen,
    Color bgColor,
    Offset tooltipPosition,
  ) {
    final path = Path();
    const arrowWidth = 6.0;
    const arrowHeight = 6.0;

    final isAbove = tooltipRect.bottom < dataPointScreen.dy;

    if (isAbove) {
      // Arrow pointing DOWN (tooltip is above point)
      final arrowX =
          (dataPointScreen.dx - tooltipPosition.dx).clamp(
            arrowWidth + 4.0,
            tooltipRect.width - arrowWidth - 4.0,
          ) +
          tooltipPosition.dx;

      final arrowTip = Offset(arrowX, tooltipRect.bottom);
      path.moveTo(arrowTip.dx - arrowWidth, arrowTip.dy);
      path.lineTo(arrowTip.dx, arrowTip.dy + arrowHeight);
      path.lineTo(arrowTip.dx + arrowWidth, arrowTip.dy);
    } else {
      // Arrow pointing UP (tooltip is below point)
      final arrowX =
          (dataPointScreen.dx - tooltipPosition.dx).clamp(
            arrowWidth + 4.0,
            tooltipRect.width - arrowWidth - 4.0,
          ) +
          tooltipPosition.dx;

      final arrowTip = Offset(arrowX, tooltipRect.top);
      path.moveTo(arrowTip.dx - arrowWidth, arrowTip.dy);
      path.lineTo(arrowTip.dx, arrowTip.dy - arrowHeight);
      path.lineTo(arrowTip.dx + arrowWidth, arrowTip.dy);
    }

    path.close();

    canvas.drawPath(path, Paint()..color = bgColor.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(covariant FusionTooltipLayer oldLayer) {
    return tooltipData != oldLayer.tooltipData;
  }
}

/// Helper class for shared tooltip entries.
class _TooltipEntry {
  const _TooltipEntry({
    required this.seriesName,
    required this.color,
    required this.value,
    required this.screenPosition,
  });

  final String seriesName;
  final Color color;
  final String value;
  final Offset screenPosition;
}

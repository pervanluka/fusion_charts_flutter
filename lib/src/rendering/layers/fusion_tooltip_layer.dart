import 'package:flutter/material.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../data/fusion_data_point.dart';
import '../../utils/fusion_data_formatter.dart';
import '../../series/fusion_series.dart';
import '../../series/series_with_data_points.dart';
import '../engine/fusion_render_context.dart';
import 'fusion_render_layer.dart';

/// Renders tooltip overlay on charts with PRECISION positioning.
///
/// ## FIX SUMMARY
/// ✅ Smart quadrant-aware positioning
/// ✅ Marker-size aware spacing
/// ✅ DPI-aware measurements
/// ✅ Boundary collision detection
/// ✅ Arrow points to exact data point
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

    if (tooltipBehavior.builder != null) {
      return;
    }

    _paintDefaultTooltip(canvas, size, context, point, screenPos, seriesName, seriesColor);
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

    final textStyle =
        tooltipBehavior.textStyle ??
        const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500);

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

    final bgColor = tooltipBehavior.color ?? Colors.black87;
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

  // ==========================================================================
  // ✅ PRECISION POSITIONING ALGORITHM
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
      tooltipY = (dataPointScreen.dy - tooltipSize.height / 2).clamp(
        chartArea.top + boundaryPadding,
        chartArea.bottom - tooltipSize.height - boundaryPadding,
      );
    }

    // Determine horizontal position (centered on data point)
    double tooltipX = dataPointScreen.dx - tooltipSize.width / 2;

    // Apply boundary collision detection
    tooltipX = tooltipX.clamp(
      chartArea.left + horizontalPadding,
      chartArea.right - tooltipSize.width - horizontalPadding,
    );

    // Ensure tooltip stays within chart bounds vertically
    tooltipY = tooltipY.clamp(
      chartArea.top + boundaryPadding,
      chartArea.bottom - tooltipSize.height - boundaryPadding,
    );

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

import 'package:flutter/material.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../core/enums/fusion_tooltip_position.dart';
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

    // Handle anchored positions (top/bottom)
    if (tooltipBehavior.position != FusionTooltipPosition.floating) {
      if (tooltipBehavior.shared && sharedPoints != null && sharedPoints.isNotEmpty) {
        _paintAnchoredSharedTooltip(
          canvas,
          size,
          context,
          point,
          screenPos,
          seriesName,
          seriesColor,
          sharedPoints,
        );
      } else {
        _paintAnchoredTooltip(canvas, size, context, point, screenPos, seriesName, seriesColor);
      }
      return;
    }

    // Floating tooltip (original behavior)
    if (tooltipBehavior.shared && sharedPoints != null && sharedPoints.isNotEmpty) {
      _paintSharedTooltip(
        canvas,
        size,
        context,
        point,
        screenPos,
        seriesName,
        seriesColor,
        sharedPoints,
      );
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

    _paintSmartArrow(canvas, tooltipRect, screenPos, bgColor);
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
            : FusionDataFormatter.formatPrecise(
                primaryPoint.y,
                maxDecimals: tooltipBehavior.decimalPlaces,
              ),
        screenPosition: primaryScreenPos,
      ),
      ...sharedPoints.map(
        (sp) => _TooltipEntry(
          seriesName: sp.seriesName,
          color: sp.seriesColor,
          value: tooltipBehavior.format != null
              ? tooltipBehavior.format!(sp.point, sp.seriesName)
              : FusionDataFormatter.formatPrecise(
                  sp.point.y,
                  maxDecimals: tooltipBehavior.decimalPlaces,
                ),
          screenPosition: sp.screenPosition,
        ),
      ),
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
    final tooltipHeight =
        (entries.length * (lineHeight + rowSpacing)) - rowSpacing + padding.vertical;
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
    _paintSmartArrow(canvas, tooltipRect, centerPosition, bgColor);
  }

  // ==========================================================================
  // ANCHORED TOOLTIP (Top/Bottom with Trackball Line)
  // ==========================================================================

  /// Paints a single-point tooltip anchored at top or bottom with trackball line.
  void _paintAnchoredTooltip(
    Canvas canvas,
    Size size,
    FusionRenderContext context,
    FusionDataPoint point,
    Offset screenPos,
    String seriesName,
    Color seriesColor,
  ) {
    final bgColor = tooltipBehavior.color ?? Colors.black87;
    final effectiveTextColor = _getContrastingTextColor(bgColor);
    final baseStyle = tooltipBehavior.textStyle ?? context.theme.tooltipStyle;
    final textStyle = baseStyle.copyWith(color: effectiveTextColor);

    final valueText = tooltipBehavior.format != null
        ? tooltipBehavior.format!(point, seriesName)
        : FusionDataFormatter.formatPrecise(point.y, maxDecimals: tooltipBehavior.decimalPlaces);

    final labelText = point.label != null ? '${point.label}\n' : '';
    final fullText = '$labelText$seriesName: $valueText';

    final textPainter = TextPainter(
      text: TextSpan(text: fullText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final dpiScale = context.devicePixelRatio;
    final padding = EdgeInsets.symmetric(horizontal: 12 * dpiScale, vertical: 8 * dpiScale);
    final tooltipWidth = textPainter.width + padding.horizontal;
    final tooltipHeight = textPainter.height + padding.vertical;
    final boundaryPadding = 8.0 * dpiScale;

    // Calculate anchored position
    final tooltipPosition = _calculateAnchoredPosition(
      dataPointScreenX: screenPos.dx,
      tooltipWidth: tooltipWidth,
      tooltipHeight: tooltipHeight,
      chartArea: context.chartArea,
      boundaryPadding: boundaryPadding,
    );

    final tooltipRect = Rect.fromLTWH(
      tooltipPosition.dx,
      tooltipPosition.dy,
      tooltipWidth,
      tooltipHeight,
    );

    // Draw trackball line FIRST (behind everything)
    if (tooltipBehavior.showTrackballLine) {
      _paintTrackballLine(
        canvas: canvas,
        tooltipRect: tooltipRect,
        dataPoints: [screenPos],
        seriesColors: [seriesColor],
        context: context,
      );
    }

    // Draw marker
    if (tooltipBehavior.canShowMarker) {
      _paintMarker(canvas, screenPos, seriesColor);
    }

    // Draw tooltip background
    if (tooltipBehavior.elevation > 0) {
      _paintShadow(canvas, tooltipRect, tooltipBehavior);
    }
    _paintBackground(canvas, tooltipRect, bgColor, tooltipBehavior);
    if (tooltipBehavior.borderWidth > 0) {
      _paintBorder(canvas, tooltipRect, seriesColor, tooltipBehavior);
    }

    // Draw text
    textPainter.paint(
      canvas,
      Offset(tooltipPosition.dx + padding.left, tooltipPosition.dy + padding.top),
    );
  }

  /// Paints a shared tooltip anchored at top or bottom with trackball lines to all points.
  void _paintAnchoredSharedTooltip(
    Canvas canvas,
    Size size,
    FusionRenderContext context,
    FusionDataPoint primaryPoint,
    Offset primaryScreenPos,
    String primarySeriesName,
    Color primarySeriesColor,
    List<SharedTooltipPoint> sharedPoints,
  ) {
    final bgColor = tooltipBehavior.color ?? Colors.black87;
    final effectiveTextColor = _getContrastingTextColor(bgColor);
    final baseStyle = tooltipBehavior.textStyle ?? context.theme.tooltipStyle;
    final textStyle = baseStyle.copyWith(color: effectiveTextColor);

    final dpiScale = context.devicePixelRatio;
    final padding = EdgeInsets.symmetric(horizontal: 12 * dpiScale, vertical: 8 * dpiScale);
    final lineHeight = (textStyle.fontSize ?? 12.0) * 1.4;
    final rowSpacing = 4.0 * dpiScale;
    final boundaryPadding = 8.0 * dpiScale;

    // Build all entries
    final entries = <_TooltipEntry>[
      _TooltipEntry(
        seriesName: primarySeriesName,
        color: primarySeriesColor,
        value: tooltipBehavior.format != null
            ? tooltipBehavior.format!(primaryPoint, primarySeriesName)
            : FusionDataFormatter.formatPrecise(
                primaryPoint.y,
                maxDecimals: tooltipBehavior.decimalPlaces,
              ),
        screenPosition: primaryScreenPos,
      ),
      ...sharedPoints.map(
        (sp) => _TooltipEntry(
          seriesName: sp.seriesName,
          color: sp.seriesColor,
          value: tooltipBehavior.format != null
              ? tooltipBehavior.format!(sp.point, sp.seriesName)
              : FusionDataFormatter.formatPrecise(
                  sp.point.y,
                  maxDecimals: tooltipBehavior.decimalPlaces,
                ),
          screenPosition: sp.screenPosition,
        ),
      ),
    ];

    // Calculate dimensions
    double maxTextWidth = 0;
    for (final entry in entries) {
      final text = '${entry.seriesName}: ${entry.value}';
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      maxTextWidth = maxTextWidth > painter.width ? maxTextWidth : painter.width;
    }

    const colorIndicatorSize = 8.0;
    const colorIndicatorMargin = 8.0;
    final contentWidth = maxTextWidth + colorIndicatorSize + colorIndicatorMargin;
    final tooltipWidth = contentWidth + padding.horizontal;
    final tooltipHeight =
        (entries.length * (lineHeight + rowSpacing)) - rowSpacing + padding.vertical;

    // Use average X position for tooltip placement
    double avgX = entries.map((e) => e.screenPosition.dx).reduce((a, b) => a + b) / entries.length;

    final tooltipPosition = _calculateAnchoredPosition(
      dataPointScreenX: avgX,
      tooltipWidth: tooltipWidth,
      tooltipHeight: tooltipHeight,
      chartArea: context.chartArea,
      boundaryPadding: boundaryPadding,
    );

    final tooltipRect = Rect.fromLTWH(
      tooltipPosition.dx,
      tooltipPosition.dy,
      tooltipWidth,
      tooltipHeight,
    );

    // Draw trackball lines to ALL points
    if (tooltipBehavior.showTrackballLine) {
      _paintTrackballLine(
        canvas: canvas,
        tooltipRect: tooltipRect,
        dataPoints: entries.map((e) => e.screenPosition).toList(),
        seriesColors: entries.map((e) => e.color).toList(),
        context: context,
      );
    }

    // Draw markers for all points
    if (tooltipBehavior.canShowMarker) {
      for (final entry in entries) {
        _paintMarker(canvas, entry.screenPosition, entry.color);
      }
    }

    // Draw tooltip background
    if (tooltipBehavior.elevation > 0) {
      _paintShadow(canvas, tooltipRect, tooltipBehavior);
    }
    _paintBackground(canvas, tooltipRect, bgColor, tooltipBehavior);
    if (tooltipBehavior.borderWidth > 0) {
      _paintBorder(canvas, tooltipRect, primarySeriesColor, tooltipBehavior);
    }

    // Draw entries
    double currentY = tooltipPosition.dy + padding.top;
    for (final entry in entries) {
      // Color indicator
      canvas.drawCircle(
        Offset(
          tooltipPosition.dx + padding.left + colorIndicatorSize / 2,
          currentY + lineHeight / 2,
        ),
        colorIndicatorSize / 2,
        Paint()..color = entry.color,
      );

      // Text
      final text = '${entry.seriesName}: ${entry.value}';
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          tooltipPosition.dx + padding.left + colorIndicatorSize + colorIndicatorMargin,
          currentY + (lineHeight - textPainter.height) / 2,
        ),
      );

      currentY += lineHeight + rowSpacing;
    }
  }

  /// Calculates tooltip position for anchored mode (top/bottom).
  Offset _calculateAnchoredPosition({
    required double dataPointScreenX,
    required double tooltipWidth,
    required double tooltipHeight,
    required Rect chartArea,
    required double boundaryPadding,
  }) {
    final isTop = tooltipBehavior.position == FusionTooltipPosition.top;

    // Vertical position: anchored to top or bottom of chart area
    final tooltipY = isTop
        ? chartArea.top + boundaryPadding
        : chartArea.bottom - tooltipHeight - boundaryPadding;

    // Horizontal position: centered on data point X
    // For anchored tooltips, we allow tooltip to extend to chart edges
    // so trackball line connects properly when point is at edge
    double tooltipX = dataPointScreenX - tooltipWidth / 2;
    
    // Only clamp to stay within chart bounds, no extra padding
    final minX = chartArea.left;
    final maxX = chartArea.right - tooltipWidth;

    if (maxX < minX) {
      tooltipX = chartArea.left + (chartArea.width - tooltipWidth) / 2;
    } else {
      tooltipX = tooltipX.clamp(minX, maxX);
    }

    return Offset(tooltipX, tooltipY);
  }

  /// Paints trackball line(s) connecting tooltip to data point(s).
  void _paintTrackballLine({
    required Canvas canvas,
    required Rect tooltipRect,
    required List<Offset> dataPoints,
    required List<Color> seriesColors,
    required FusionRenderContext context,
  }) {
    final isTop = tooltipBehavior.position == FusionTooltipPosition.top;
    final lineColor = tooltipBehavior.trackballLineColor;
    final lineWidth = tooltipBehavior.trackballLineWidth;
    final dashPattern = tooltipBehavior.trackballLineDashPattern;

    // Minimum distance to show line (avoid clutter when point is near tooltip)
    const minLineDistance = 10.0;

    for (int i = 0; i < dataPoints.length; i++) {
      final pointPos = dataPoints[i];
      final color = lineColor ?? seriesColors[i].withValues(alpha: 0.5);

      // Calculate line start (from tooltip) and end (to data point)
      final lineStart = isTop
          ? Offset(pointPos.dx, tooltipRect.bottom)
          : Offset(pointPos.dx, tooltipRect.top);
      final lineEnd = pointPos;

      // Skip line if point is too close to tooltip (overlapping)
      final distance = (lineEnd.dy - lineStart.dy).abs();
      if (distance < minLineDistance) {
        continue;
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke;

      if (dashPattern != null && dashPattern.isNotEmpty) {
        // Dashed line
        _drawDashedLine(canvas, lineStart, lineEnd, paint, dashPattern);
      } else {
        // Solid line
        canvas.drawLine(lineStart, lineEnd, paint);
      }
    }
  }

  /// Draws a dashed line between two points.
  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dashPattern,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

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

  /// Paints arrow pointing toward the data point, or no arrow if point is under tooltip.
  ///
  /// Smart positioning:
  /// - If point is under tooltip → no arrow (marker is visible)
  /// - If point is at corner → diagonal arrow (45°)
  /// - If point is above/below → vertical arrow
  /// - If point is to left/right → horizontal arrow
  void _paintSmartArrow(Canvas canvas, Rect tooltipRect, Offset dataPointScreen, Color bgColor) {
    const arrowSize = 6.0;
    const overlapTolerance = 4.0;

    // Expand tooltip rect slightly to check if point is "under" it
    final expandedRect = tooltipRect.inflate(overlapTolerance);

    // If point is inside/under the tooltip, don't draw arrow
    if (expandedRect.contains(dataPointScreen)) {
      return;
    }

    final path = Path();
    final paint = Paint()..color = bgColor.withValues(alpha: 0.9);

    // Determine relative position
    final isLeft = dataPointScreen.dx < tooltipRect.left;
    final isRight = dataPointScreen.dx > tooltipRect.right;
    final isAbove = dataPointScreen.dy < tooltipRect.top;
    final isBelow = dataPointScreen.dy > tooltipRect.bottom;

    // =========================================
    // CORNER CASES - Diagonal arrows (45°)
    // =========================================
    if (isLeft && isBelow) {
      // Point is BOTTOM-LEFT → diagonal arrow at bottom-left corner
      _drawCornerArrow(path, tooltipRect.bottomLeft, ArrowDirection.bottomLeft, arrowSize);
    } else if (isRight && isBelow) {
      // Point is BOTTOM-RIGHT → diagonal arrow at bottom-right corner
      _drawCornerArrow(path, tooltipRect.bottomRight, ArrowDirection.bottomRight, arrowSize);
    } else if (isLeft && isAbove) {
      // Point is TOP-LEFT → diagonal arrow at top-left corner
      _drawCornerArrow(path, tooltipRect.topLeft, ArrowDirection.topLeft, arrowSize);
    } else if (isRight && isAbove) {
      // Point is TOP-RIGHT → diagonal arrow at top-right corner
      _drawCornerArrow(path, tooltipRect.topRight, ArrowDirection.topRight, arrowSize);
    }
    // =========================================
    // EDGE CASES - Straight arrows
    // =========================================
    else if (isAbove) {
      // Point is ABOVE tooltip → arrow on top edge pointing up
      final arrowX = dataPointScreen.dx.clamp(
        tooltipRect.left + arrowSize + 4,
        tooltipRect.right - arrowSize - 4,
      );
      path.moveTo(arrowX - arrowSize, tooltipRect.top);
      path.lineTo(arrowX, tooltipRect.top - arrowSize);
      path.lineTo(arrowX + arrowSize, tooltipRect.top);
    } else if (isBelow) {
      // Point is BELOW tooltip → arrow on bottom edge pointing down
      final arrowX = dataPointScreen.dx.clamp(
        tooltipRect.left + arrowSize + 4,
        tooltipRect.right - arrowSize - 4,
      );
      path.moveTo(arrowX - arrowSize, tooltipRect.bottom);
      path.lineTo(arrowX, tooltipRect.bottom + arrowSize);
      path.lineTo(arrowX + arrowSize, tooltipRect.bottom);
    } else if (isLeft) {
      // Point is to the LEFT → arrow on left edge pointing left
      final arrowY = dataPointScreen.dy.clamp(
        tooltipRect.top + arrowSize + 4,
        tooltipRect.bottom - arrowSize - 4,
      );
      path.moveTo(tooltipRect.left, arrowY - arrowSize);
      path.lineTo(tooltipRect.left - arrowSize, arrowY);
      path.lineTo(tooltipRect.left, arrowY + arrowSize);
    } else if (isRight) {
      // Point is to the RIGHT → arrow on right edge pointing right
      final arrowY = dataPointScreen.dy.clamp(
        tooltipRect.top + arrowSize + 4,
        tooltipRect.bottom - arrowSize - 4,
      );
      path.moveTo(tooltipRect.right, arrowY - arrowSize);
      path.lineTo(tooltipRect.right + arrowSize, arrowY);
      path.lineTo(tooltipRect.right, arrowY + arrowSize);
    } else {
      // Fallback - no arrow
      return;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  /// Draws a diagonal corner arrow pointing at 45 degrees.
  void _drawCornerArrow(Path path, Offset corner, ArrowDirection direction, double size) {
    // Diagonal offset (45 degrees = size * 0.707, but we use size for visual consistency)
    final diagOffset = size * 0.85; // Slightly less than size for better visual

    switch (direction) {
      case ArrowDirection.bottomLeft:
        // Arrow at bottom-left corner pointing down-left
        path.moveTo(corner.dx, corner.dy - size); // Top of arrow (on left edge)
        path.lineTo(corner.dx - diagOffset, corner.dy + diagOffset); // Tip (diagonal)
        path.lineTo(corner.dx + size, corner.dy); // Right of arrow (on bottom edge)
        break;

      case ArrowDirection.bottomRight:
        // Arrow at bottom-right corner pointing down-right
        path.moveTo(corner.dx - size, corner.dy); // Left of arrow (on bottom edge)
        path.lineTo(corner.dx + diagOffset, corner.dy + diagOffset); // Tip (diagonal)
        path.lineTo(corner.dx, corner.dy - size); // Top of arrow (on right edge)
        break;

      case ArrowDirection.topLeft:
        // Arrow at top-left corner pointing up-left
        path.moveTo(corner.dx + size, corner.dy); // Right of arrow (on top edge)
        path.lineTo(corner.dx - diagOffset, corner.dy - diagOffset); // Tip (diagonal)
        path.lineTo(corner.dx, corner.dy + size); // Bottom of arrow (on left edge)
        break;

      case ArrowDirection.topRight:
        // Arrow at top-right corner pointing up-right
        path.moveTo(corner.dx, corner.dy + size); // Bottom of arrow (on right edge)
        path.lineTo(corner.dx + diagOffset, corner.dy - diagOffset); // Tip (diagonal)
        path.lineTo(corner.dx - size, corner.dy); // Left of arrow (on top edge)
        break;
    }
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

/// Arrow direction for corner arrows.
enum ArrowDirection { topLeft, topRight, bottomLeft, bottomRight }

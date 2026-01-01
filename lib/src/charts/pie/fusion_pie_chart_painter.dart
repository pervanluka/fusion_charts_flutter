import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../configuration/fusion_pie_chart_configuration.dart';
import '../../rendering/engine/fusion_paint_pool.dart';
import '../../rendering/polar/fusion_pie_segment.dart';
import '../../series/fusion_pie_series.dart';
import '../../themes/fusion_chart_theme.dart';

/// High-performance painter for pie and donut charts.
///
/// ## Design Philosophy
///
/// Simple, focused painting using flat data point properties.
/// No nested style resolution - reads directly from segment/dataPoint.
///
/// ## Rendering Order
///
/// 1. Shadows (if enabled)
/// 2. Segment fills (with gradient support)
/// 3. Segment strokes
/// 4. Labels (if enabled)
///
/// Note: Tooltips are handled separately by [FusionPieTooltipLayer]
/// to properly integrate with [FusionTooltipBehavior].
class FusionPieChartPainter extends CustomPainter {
  FusionPieChartPainter({
    required this.segments,
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
    required this.series,
    required this.theme,
    required this.config,
    required this.paintPool,
    this.animationProgress = 1.0,
    this.selectedIndices = const {},
    this.hoveredIndex,
  });

  final List<ComputedPieSegment> segments;
  final Offset center;
  final double innerRadius;
  final double outerRadius;
  final FusionPieSeries series;
  final FusionChartTheme theme;
  final FusionPieChartConfiguration config;
  final FusionPaintPool paintPool;
  final double animationProgress;
  final Set<int> selectedIndices;
  final int? hoveredIndex;

  /// Minimum outer radius to render outside labels (below this, labels are skipped)
  static const _minRadiusForOutsideLabels = 60.0;

  /// Minimum outer radius to render the chart at all
  static const _minRadiusForChart = 20.0;

  /// Minimum percentage for inside labels with full text (label + percentage)
  static const _minPercentageForFullInsideLabel = 12.0;

  /// Minimum percentage for inside labels with percentage only
  static const _minPercentageForShortInsideLabel = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    // Skip rendering entirely if chart is too small
    if (outerRadius < _minRadiusForChart) return;

    // 1. Draw shadows (if enabled globally or per-segment)
    _drawShadows(canvas);

    // 2. Draw segments
    _drawSegments(canvas);

    // 3. Draw labels (if enabled and enough space)
    if (config.showLabels && config.labelPosition != PieLabelPosition.none) {
      _drawLabels(canvas, size);
    }

    // Note: Tooltips are rendered by FusionPieTooltipLayer
  }

  // ===========================================================================
  // SHADOWS
  // ===========================================================================

  void _drawShadows(Canvas canvas) {
    // Check for global shadow setting first
    if (config.enableShadow) {
      final shadowPaint = Paint()
        ..color = config.effectiveShadowColor(theme)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          config.shadowBlurRadius,
        );

      for (final segment in segments) {
        canvas.save();
        canvas.translate(config.shadowOffset.dx, config.shadowOffset.dy);
        canvas.drawPath(segment.path, shadowPaint);
        canvas.restore();
      }
      return;
    }

    // Per-segment shadows (from dataPoint.shadow)
    for (final segment in segments) {
      final shadow = segment.dataPoint.shadow;
      if (shadow == null) continue;

      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

      canvas.save();
      canvas.translate(shadow.offset.dx, shadow.offset.dy);
      canvas.drawPath(segment.path, shadowPaint);
      canvas.restore();
    }
  }

  // ===========================================================================
  // SEGMENTS
  // ===========================================================================

  void _drawSegments(Canvas canvas) {
    final hasSelection = selectedIndices.isNotEmpty;

    // Apply global scale animation (whole pie scales from center)
    final hasScaleAnimation =
        config.animationType == PieAnimationType.scale ||
        config.animationType == PieAnimationType.scaleFade;

    if (hasScaleAnimation && animationProgress < 1.0) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(animationProgress);
      canvas.translate(-center.dx, -center.dy);
    }

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isSelected = selectedIndices.contains(i);
      final isHovered = hoveredIndex == i;

      // Calculate animated sweep angle
      final animatedSweep = _getAnimatedSweepAngle(segment);
      if (animatedSweep <= 0) continue;

      // Determine opacity (base + animation + selection)
      double opacity = config.selectedOpacity;

      // Apply fade animation
      if (config.animationType == PieAnimationType.fade ||
          config.animationType == PieAnimationType.scaleFade) {
        opacity *= animationProgress;
      }

      // Apply selection dimming
      if (hasSelection && !isSelected) {
        opacity *= config.unselectedOpacity;
      }

      // Determine selection/hover scale (individual segment)
      double selectionScale = 1.0;
      if (isSelected) {
        selectionScale = config.selectedScale;
      } else if (isHovered) {
        selectionScale = config.hoverScale;
      }

      // Apply selection scale transformation (around segment center)
      canvas.save();

      if (selectionScale != 1.0) {
        // Scale around the SEGMENT center for selection effect
        canvas.translate(segment.center.dx, segment.center.dy);
        canvas.scale(selectionScale);
        canvas.translate(-segment.center.dx, -segment.center.dy);
      }

      // Draw the segment
      _drawSingleSegment(canvas, segment, opacity);

      canvas.restore();
    }

    // Restore global scale animation
    if (hasScaleAnimation && animationProgress < 1.0) {
      canvas.restore();
    }
  }

  void _drawSingleSegment(
    Canvas canvas,
    ComputedPieSegment segment,
    double opacity,
  ) {
    final dataPoint = segment.dataPoint;
    final path = segment.path;

    // 1. Draw fill
    final fillPaint = paintPool.acquire()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Check for per-segment gradient
    if (dataPoint.gradient != null) {
      fillPaint.shader = dataPoint.gradient!.createShader(
        Rect.fromCircle(center: center, radius: outerRadius),
      );
      fillPaint.color = Colors.white.withValues(alpha: opacity);
    } else {
      fillPaint.color = segment.color.withValues(alpha: opacity);
    }

    canvas.drawPath(path, fillPaint);
    paintPool.release(fillPaint);

    // 2. Draw stroke
    // Priority: dataPoint.borderWidth > series.strokeWidth > config.strokeWidth
    final strokeWidth = dataPoint.borderWidth > 0
        ? dataPoint.borderWidth
        : (series.strokeWidth > 0 ? series.strokeWidth : config.strokeWidth);

    if (strokeWidth > 0) {
      final strokeColor =
          dataPoint.borderColor ??
          series.strokeColor ??
          config.effectiveStrokeColor(theme);

      final strokePaint = paintPool.acquire()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true
        ..color = strokeColor.withValues(alpha: opacity);

      canvas.drawPath(path, strokePaint);
      paintPool.release(strokePaint);
    }
  }

  // ===========================================================================
  // LABELS
  // ===========================================================================

  void _drawLabels(Canvas canvas, Size size) {
    // Skip outside labels entirely if chart is too small
    final canDrawOutsideLabels = outerRadius >= _minRadiusForOutsideLabels;

    for (final segment in segments) {
      // Skip labels for small segments
      if (segment.percentage < config.percentageThreshold) continue;

      final labelPos = _resolveLabelPosition(segment);

      if (labelPos == PieLabelPosition.inside) {
        _drawInsideLabel(canvas, segment);
      } else if (labelPos == PieLabelPosition.outside && canDrawOutsideLabels) {
        _drawOutsideLabel(canvas, segment);
      }
      // If outside labels requested but chart too small, skip gracefully
    }
  }

  PieLabelPosition _resolveLabelPosition(ComputedPieSegment segment) {
    if (config.labelPosition == PieLabelPosition.auto) {
      // Large segments get inside labels, small ones get outside
      return segment.percentage >= 15
          ? PieLabelPosition.inside
          : PieLabelPosition.outside;
    }
    return config.labelPosition;
  }

  void _drawInsideLabel(Canvas canvas, ComputedPieSegment segment) {
    // Skip labels for very small segments (< 6%)
    if (segment.percentage < _minPercentageForShortInsideLabel) {
      return;
    }

    final baseStyle =
        config.labelStyle ?? series.labelStyle ?? theme.dataLabelStyle;

    // Auto-contrast: pick text color based on segment background luminance
    final contrastColor = _getContrastingTextColor(segment.color);
    final style = baseStyle.copyWith(color: contrastColor);

    // Calculate available arc width at centroid
    final centroidRadius = (outerRadius + innerRadius) / 2;
    final arcWidth = (segment.percentage / 100) * 2 * math.pi * centroidRadius;
    final maxLabelWidth = arcWidth * 0.85;

    // Progressive label strategy:
    // 1. Try full label (name + percentage) for large segments
    // 2. Fall back to short label (percentage only) if full doesn't fit
    // 3. Skip if even short label doesn't fit

    String? labelToUse;

    // For segments >= 12%, try full label first
    if (segment.percentage >= _minPercentageForFullInsideLabel) {
      final fullLabel = _formatLabel(segment);
      final fullPainter = TextPainter(
        text: TextSpan(text: fullLabel, style: style),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      if (fullPainter.width <= maxLabelWidth) {
        labelToUse = fullLabel;
      }
    }

    // If full label didn't fit (or segment is 6-12%), try short label
    if (labelToUse == null) {
      final shortLabel = _formatShortLabel(segment);
      if (shortLabel.isEmpty) return;

      final shortPainter = TextPainter(
        text: TextSpan(text: shortLabel, style: style),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      if (shortPainter.width <= maxLabelWidth) {
        labelToUse = shortLabel;
      }
    }

    // If nothing fits, skip
    if (labelToUse == null || labelToUse.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(text: labelToUse, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final offset = Offset(
      segment.centroid.dx - textPainter.width / 2,
      segment.centroid.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  /// Returns a contrasting text color (dark or light) based on background luminance.
  ///
  /// Uses WCAG relative luminance formula for accurate contrast calculation.
  /// - Light backgrounds (luminance > 0.5) → dark text
  /// - Dark backgrounds (luminance <= 0.5) → light text
  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();

    // Use a slightly lower threshold (0.4) to bias toward white text
    // since white text with slight shadow is often more readable
    if (luminance > 0.4) {
      // Light background → dark text
      return const Color(0xFF1F2937); // Dark gray, softer than pure black
    } else {
      // Dark background → light text
      return Colors.white;
    }
  }

  /// Formats a short label (percentage only) for small segments
  String _formatShortLabel(ComputedPieSegment segment) {
    if (config.showPercentages) {
      return '${segment.percentage.toStringAsFixed(0)}%';
    }
    return '';
  }

  void _drawOutsideLabel(Canvas canvas, ComputedPieSegment segment) {
    final label = _formatLabel(segment);
    if (label.isEmpty) return;

    final arcPoint = segment.labelAnchor.arcPoint;
    final labelPoint = segment.labelAnchor.labelPoint;

    // Calculate segment mid-angle to determine if we need an elbow connector
    final midAngle = segment.startAngle + segment.sweepAngle / 2;

    // Draw connector line (possibly with elbow for top/bottom zones)
    final connectorColor = config.labelConnectorColor ?? theme.axisColor;
    final connectorPaint = Paint()
      ..color = connectorColor
      ..strokeWidth = config.labelConnectorWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calculate elbow connector for top/bottom zones
    final elbowPoint = _calculateElbowPoint(arcPoint, labelPoint, midAngle);

    if (elbowPoint != null) {
      // Draw L-shaped connector: arcPoint → elbowPoint → labelPoint
      final path = Path()
        ..moveTo(arcPoint.dx, arcPoint.dy)
        ..lineTo(elbowPoint.dx, elbowPoint.dy)
        ..lineTo(labelPoint.dx, labelPoint.dy);
      canvas.drawPath(path, connectorPaint);
    } else {
      // Draw straight connector (side zones)
      canvas.drawLine(arcPoint, labelPoint, connectorPaint);
    }

    // Draw label
    final style =
        config.labelStyle ?? series.labelStyle ?? theme.dataLabelStyle;

    final textPainter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      textAlign: segment.labelAnchor.alignment,
    )..layout();

    Offset labelOffset;
    if (segment.labelAnchor.alignment == TextAlign.left) {
      labelOffset = Offset(
        segment.labelAnchor.labelPoint.dx + 4,
        segment.labelAnchor.labelPoint.dy - textPainter.height / 2,
      );
    } else {
      labelOffset = Offset(
        segment.labelAnchor.labelPoint.dx - textPainter.width - 4,
        segment.labelAnchor.labelPoint.dy - textPainter.height / 2,
      );
    }

    textPainter.paint(canvas, labelOffset);
  }

  /// Calculates an elbow point for L-shaped connectors in top/bottom zones.
  ///
  /// Returns null if the segment is in a side zone (no elbow needed).
  ///
  /// The elbow creates an L-shape:
  /// - Top zone (11-1 o'clock): vertical down, then horizontal
  /// - Bottom zone (5-7 o'clock): vertical up, then horizontal
  ///
  /// The effect is graduated - segments closer to 12/6 o'clock get
  /// more pronounced elbows, while segments near 10/2 or 8/4 o'clock
  /// transition smoothly to straight lines.
  Offset? _calculateElbowPoint(
    Offset arcPoint,
    Offset labelPoint,
    double midAngle,
  ) {
    // Normalize angle to 0-2π range
    final normalizedAngle = midAngle % (2 * math.pi);

    // Use sine to detect top/bottom zones
    // In screen coordinates (Y down), with angles starting at 3 o'clock:
    // |sin| = 1 at 90° (6 o'clock/bottom) and 270° (12 o'clock/top)
    // |sin| = 0 at 0° (3 o'clock/right) and 180° (9 o'clock/left)
    final sinValue = math.sin(normalizedAngle).abs();

    // Only apply elbow effect when |sin| > 0.5 (roughly within 60° of top/bottom)
    // This covers approximately 11-1 o'clock and 5-7 o'clock zones
    const elbowThreshold = 0.5;
    if (sinValue < elbowThreshold) {
      return null; // Side zone (8-10, 2-4 o'clock) - use straight line
    }

    // Calculate elbow factor (0 at threshold, 1 at pure top/bottom)
    final elbowFactor = (sinValue - elbowThreshold) / (1.0 - elbowThreshold);

    // Calculate elbow point
    // The elbow X position: interpolate between straight line and pure vertical
    // At elbowFactor=1 (pure top/bottom): elbowX closer to arcPoint.x (more vertical)
    // At elbowFactor=0 (threshold): elbowX = labelPoint.x (diagonal)
    final elbowX =
        arcPoint.dx + (labelPoint.dx - arcPoint.dx) * (1 - elbowFactor * 0.7);

    // The elbow Y position: same as labelPoint.y (horizontal final segment)
    final elbowY = labelPoint.dy;

    return Offset(elbowX, elbowY);
  }

  String _formatLabel(ComputedPieSegment segment) {
    // Custom formatter from config
    if (config.labelFormatter != null) {
      return config.labelFormatter!(
        PieConfigLabelData(
          index: segment.index,
          value: segment.value,
          percentage: segment.percentage,
          label: segment.label,
          color: segment.color,
        ),
      );
    }

    // Default formatting
    final parts = <String>[];

    if (segment.label != null && segment.label!.isNotEmpty) {
      parts.add(segment.label!);
    }

    if (config.showPercentages) {
      parts.add('${segment.percentage.toStringAsFixed(1)}%');
    }

    if (config.showValues) {
      parts.add(segment.value.toStringAsFixed(0));
    }

    return parts.join('\n');
  }

  // ===========================================================================
  // ANIMATION
  // ===========================================================================

  double _getAnimatedSweepAngle(ComputedPieSegment segment) {
    switch (config.animationType) {
      case PieAnimationType.sweep:
        return segment.sweepAngle * animationProgress;
      case PieAnimationType.scale:
      case PieAnimationType.scaleFade:
      case PieAnimationType.fade:
      case PieAnimationType.none:
        return segment.sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant FusionPieChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndices != selectedIndices ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../configuration/fusion_axis_configuration.dart';
import '../../../themes/fusion_chart_theme.dart';
import '../../models/axis_bounds.dart';
import '../../models/axis_label.dart';
import '../base/fusion_axis_renderer.dart';

/// Renders category axes with string labels (for bar charts).
///
/// ## Configuration Priority (Option A Architecture)
///
/// `FusionAxisConfiguration` is the **single source of truth** for all axis properties.
/// The categories list is the only thing that must come from the axis definition.
///
/// ## Example
///
/// ```dart
/// final config = FusionAxisConfiguration(
///   visible: true,
///   showLabels: true,
///   showTicks: true,
///   showGrid: true,
///   labelRotation: 45,
/// );
/// ```
class CategoryAxisRenderer extends FusionAxisRenderer {
  CategoryAxisRenderer({
    required this.categories,
    required this.configuration,
    this.theme,
    this.isVertical = false,
  });

  /// Category labels to display.
  final List<String> categories;

  /// Axis configuration (PRIMARY source of truth).
  final FusionAxisConfiguration configuration;

  /// Theme for fallback styling.
  final FusionChartTheme? theme;

  /// Whether this is a vertical axis.
  final bool isVertical;

  // ==========================================================================
  // CACHING
  // ==========================================================================

  AxisBounds? _cachedBounds;
  List<AxisLabel>? _cachedLabels;

  /// OPTIMIZATION: Reusable TextPainter instance to avoid recreation per label.
  TextPainter? _cachedTextPainter;

  /// OPTIMIZATION: Cache measured label sizes keyed by label text.
  /// This avoids redundant TextPainter.layout() calls when labels don't change.
  Map<String, Size>? _cachedLabelSizes;
  TextStyle? _lastLabelStyle;

  // ==========================================================================
  // BOUNDS CALCULATION
  // ==========================================================================

  @override
  AxisBounds calculateBounds(List<double> dataValues) {
    // For categories, bounds are index-based
    _cachedBounds = AxisBounds(
      min: -0.5,
      max: categories.length - 0.5,
      interval: 1.0,
      decimalPlaces: 0,
    );

    return _cachedBounds!;
  }

  // ==========================================================================
  // LABEL GENERATION
  // ==========================================================================

  @override
  List<AxisLabel> generateLabels(AxisBounds bounds) {
    final labels = <AxisLabel>[];

    for (int i = 0; i < categories.length; i++) {
      final position = categories.length > 1
          ? i / (categories.length - 1)
          : 0.5;

      labels.add(
        AxisLabel(value: i.toDouble(), text: categories[i], position: position),
      );
    }

    _cachedLabels = labels;
    return labels;
  }

  // ==========================================================================
  // SIZE MEASUREMENT
  // ==========================================================================

  @override
  Size measureAxisLabels(List<AxisLabel> labels, Size availableSize) {
    // If axis is not visible, return zero size
    if (!configuration.visible) {
      return Size.zero;
    }

    if (labels.isEmpty) return Size.zero;

    final labelStyle =
        configuration.labelStyle ??
        theme?.axisLabelStyle ??
        const TextStyle(fontSize: 12);

    // OPTIMIZATION: Invalidate cache if style changed
    if (_lastLabelStyle != labelStyle) {
      _cachedLabelSizes = null;
      _lastLabelStyle = labelStyle;
    }

    // OPTIMIZATION: Reuse TextPainter instance
    _cachedTextPainter ??= TextPainter(textDirection: TextDirection.ltr);
    final textPainter = _cachedTextPainter!;

    // OPTIMIZATION: Initialize or reuse label size cache
    _cachedLabelSizes ??= {};
    final sizeCache = _cachedLabelSizes!;

    double maxWidth = 0;
    double maxHeight = 0;

    for (final label in labels) {
      Size labelSize;

      // OPTIMIZATION: Check cache before measuring
      if (sizeCache.containsKey(label.text)) {
        labelSize = sizeCache[label.text]!;
      } else {
        textPainter.text = TextSpan(text: label.text, style: labelStyle);
        textPainter.layout();
        labelSize = Size(textPainter.width, textPainter.height);
        sizeCache[label.text] = labelSize;
      }

      maxWidth = math.max(maxWidth, labelSize.width);
      maxHeight = math.max(maxHeight, labelSize.height);
    }

    // Check for collision (for horizontal axis)
    if (!isVertical && labels.length > 1) {
      final availableWidthPerLabel = availableSize.width / labels.length;
      if (maxWidth > availableWidthPerLabel * 0.9) {
        // Labels will collide - calculate rotated height
        if (configuration.labelRotation != null) {
          final rotation = configuration.labelRotation!.abs();
          final rotatedHeight =
              maxWidth * math.sin(rotation * math.pi / 180) +
              maxHeight * math.cos(rotation * math.pi / 180);
          maxHeight = rotatedHeight;
        } else {
          // Default 45 degree rotation
          maxHeight = maxWidth * 0.707 + maxHeight * 0.707;
        }
      }
    }

    const padding = 8.0;

    if (isVertical) {
      return Size(maxWidth + padding, availableSize.height);
    } else {
      return Size(availableSize.width, maxHeight + padding);
    }
  }

  // ==========================================================================
  // RENDERING
  // ==========================================================================

  @override
  void renderAxis(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    // CRITICAL: Check visibility first
    if (!configuration.visible) {
      return;
    }

    if (configuration.showAxisLine) {
      _drawAxisLine(canvas, axisArea);
    }

    if (configuration.showTicks) {
      _drawTicks(canvas, axisArea);
    }

    if (configuration.showLabels) {
      _drawLabels(canvas, axisArea);
    }
  }

  void _drawAxisLine(Canvas canvas, Rect axisArea) {
    final paint = Paint()
      ..color = configuration.axisLineColor ?? theme?.axisColor ?? Colors.grey
      ..strokeWidth = configuration.axisLineWidth ?? 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    if (isVertical) {
      canvas.drawLine(
        Offset(axisArea.right, axisArea.top),
        Offset(axisArea.right, axisArea.bottom),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(axisArea.left, axisArea.top),
        Offset(axisArea.right, axisArea.top),
        paint,
      );
    }
  }

  void _drawTicks(Canvas canvas, Rect axisArea) {
    final paint = Paint()
      ..color = configuration.majorTickColor ?? theme?.axisColor ?? Colors.grey
      ..strokeWidth = configuration.majorTickWidth ?? 1.0
      ..strokeCap = StrokeCap.square;

    final tickLength = configuration.majorTickLength ?? 6.0;

    // OPTIMIZATION: Batch all tick lines into a single Path for better performance
    final path = Path();

    for (int i = 0; i < categories.length; i++) {
      final position = _getCategoryPosition(i, categories.length);

      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        path.moveTo(axisArea.right, y);
        path.lineTo(axisArea.right + tickLength, y);
      } else {
        final x = axisArea.left + (position * axisArea.width);
        path.moveTo(x, axisArea.top);
        path.lineTo(x, axisArea.top + tickLength);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, Rect axisArea) {
    final labels = _cachedLabels ?? generateLabels(_cachedBounds!);

    final labelStyle =
        configuration.labelStyle ??
        theme?.axisLabelStyle ??
        const TextStyle(fontSize: 12);

    // OPTIMIZATION: Reuse TextPainter instance
    _cachedTextPainter ??= TextPainter(textDirection: TextDirection.ltr);
    final textPainter = _cachedTextPainter!;
    textPainter.textAlign = TextAlign.center;

    // OPTIMIZATION: Ensure size cache exists
    _cachedLabelSizes ??= {};
    final sizeCache = _cachedLabelSizes!;

    final needsRotation = _shouldRotateLabels(labels, axisArea, labelStyle);
    final rotation = needsRotation
        ? (configuration.labelRotation ?? 45.0)
        : 0.0;

    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];

      // OPTIMIZATION: Get cached size or measure and cache
      Size labelSize;
      if (sizeCache.containsKey(label.text)) {
        labelSize = sizeCache[label.text]!;
        // Still need to set text for painting
        textPainter.text = TextSpan(text: label.text, style: labelStyle);
        textPainter.layout();
      } else {
        textPainter.text = TextSpan(text: label.text, style: labelStyle);
        textPainter.layout();
        labelSize = Size(textPainter.width, textPainter.height);
        sizeCache[label.text] = labelSize;
      }

      final position = _getCategoryPosition(i, labels.length);

      Offset labelPosition;
      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        labelPosition = Offset(
          axisArea.left - labelSize.width - 8,
          y - (labelSize.height / 2),
        );
      } else {
        final x = axisArea.left + (position * axisArea.width);

        if (rotation != 0) {
          labelPosition = Offset(x, axisArea.top + 8);
        } else {
          labelPosition = Offset(x - (labelSize.width / 2), axisArea.top + 8);
        }
      }

      if (rotation != 0) {
        canvas.save();
        canvas.translate(labelPosition.dx, labelPosition.dy);
        canvas.rotate(rotation * (math.pi / 180));

        if (!isVertical) {
          textPainter.paint(canvas, Offset.zero);
        } else {
          textPainter.paint(
            canvas,
            Offset(-labelSize.width / 2, -labelSize.height / 2),
          );
        }

        canvas.restore();
      } else {
        textPainter.paint(canvas, labelPosition);
      }
    }
  }

  @override
  void renderGridLines(Canvas canvas, Rect plotArea, AxisBounds bounds) {
    if (!configuration.showGrid) return;

    final paint = Paint()
      ..color =
          configuration.majorGridColor ??
          theme?.gridColor ??
          Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = configuration.majorGridWidth ?? 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // OPTIMIZATION: Batch all grid lines into a single Path for better performance
    // This reduces N drawLine calls to a single drawPath call
    final path = Path();

    // Draw grid lines between categories
    for (int i = 0; i <= categories.length; i++) {
      final position = i / categories.length;

      if (isVertical) {
        final y = plotArea.bottom - (position * plotArea.height);
        final snappedY = y.roundToDouble();
        path.moveTo(plotArea.left, snappedY);
        path.lineTo(plotArea.right, snappedY);
      } else {
        final x = plotArea.left + (position * plotArea.width);
        final snappedX = x.roundToDouble();
        path.moveTo(snappedX, plotArea.top);
        path.lineTo(snappedX, plotArea.bottom);
      }
    }

    canvas.drawPath(path, paint);
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  double _getCategoryPosition(int index, int total) {
    if (total <= 1) return 0.5;
    return index / (total - 1);
  }

  bool _shouldRotateLabels(
    List<AxisLabel> labels,
    Rect axisArea,
    TextStyle style,
  ) {
    if (isVertical || labels.length <= 1) return false;

    // OPTIMIZATION: Reuse TextPainter and cached sizes
    _cachedTextPainter ??= TextPainter(textDirection: TextDirection.ltr);
    final textPainter = _cachedTextPainter!;
    _cachedLabelSizes ??= {};
    final sizeCache = _cachedLabelSizes!;

    double totalWidth = 0;
    for (final label in labels) {
      if (sizeCache.containsKey(label.text)) {
        totalWidth += sizeCache[label.text]!.width;
      } else {
        textPainter.text = TextSpan(text: label.text, style: style);
        textPainter.layout();
        final labelSize = Size(textPainter.width, textPainter.height);
        sizeCache[label.text] = labelSize;
        totalWidth += labelSize.width;
      }
    }

    totalWidth += (labels.length - 1) * 8;

    return totalWidth > axisArea.width * 0.9;
  }

  int? getCategoryIndex(String category) {
    final index = categories.indexOf(category);
    return index >= 0 ? index : null;
  }

  String? getCategoryName(int index) {
    if (index >= 0 && index < categories.length) {
      return categories[index];
    }
    return null;
  }

  // ==========================================================================
  // DISPOSAL
  // ==========================================================================

  @override
  void dispose() {
    _cachedBounds = null;
    _cachedLabels = null;
    _cachedTextPainter?.dispose();
    _cachedTextPainter = null;
    _cachedLabelSizes = null;
    _lastLabelStyle = null;
  }

  @override
  String toString() {
    return 'CategoryAxisRenderer('
        'categories: ${categories.length}, '
        'visible: ${configuration.visible}, '
        'isVertical: $isVertical'
        ')';
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../configuration/fusion_axis_configuration.dart';
import '../../../themes/fusion_chart_theme.dart';
import '../../../utils/axis_calculator.dart';
import '../../../utils/fusion_data_formatter.dart';
import '../../enums/axis_range_padding.dart';
import '../../models/axis_bounds.dart';
import '../../models/axis_label.dart';
import '../base/fusion_axis_renderer.dart';
import 'fusion_numeric_axis.dart';

/// Renders numeric axes with continuous numeric values.
class NumericAxisRenderer extends FusionAxisRenderer {
  NumericAxisRenderer({
    required this.axis,
    required this.configuration,
    this.theme,
    this.isVertical = true,
  });

  final FusionNumericAxis axis;
  final FusionAxisConfiguration configuration;
  final FusionChartTheme? theme;
  final bool isVertical;

  // ==========================================================================
  // PRECISION CONSTANTS
  // ==========================================================================

  /// Epsilon for floating-point comparisons
  static const double _epsilon = 1e-10;

  /// Maximum labels to prevent infinite loops
  static const int _maxLabels = 1000;

  // ==========================================================================
  // CACHING
  // ==========================================================================

  AxisBounds? _cachedBounds;
  List<AxisLabel>? _cachedLabels;

  // ==========================================================================
  // BOUNDS CALCULATION (unchanged - already good)
  // ==========================================================================

  @override
  AxisBounds calculateBounds(List<double> dataValues) {
    if (dataValues.isEmpty) {
      _cachedBounds = AxisBounds(min: 0, max: 10, interval: 1, decimalPlaces: 0);
      return _cachedBounds!;
    }

    double min = axis.min ?? dataValues.reduce((a, b) => a < b ? a : b);
    double max = axis.max ?? dataValues.reduce((a, b) => a > b ? a : b);

    if (min == max) {
      if (min == 0) {
        min = -1;
        max = 1;
      } else {
        final absValue = min.abs();
        min = min - absValue * 0.1;
        max = max + absValue * 0.1;
      }
    }

    final range = max - min;
    final paddingFraction = _getPaddingFraction();

    min -= range * paddingFraction;
    max += range * paddingFraction;

    final interval =
        axis.interval ?? AxisCalculator.calculateNiceInterval(min, max, axis.desiredIntervals);

    if (axis.rangePadding == AxisRangePadding.round) {
      min = (min / interval).floor() * interval;
      max = (max / interval).ceil() * interval;
    }

    final decimalPlaces = _calculateDecimalPlaces(interval);

    _cachedBounds = AxisBounds(
      min: min,
      max: max,
      interval: interval,
      decimalPlaces: decimalPlaces,
    );

    return _cachedBounds!;
  }

  double _getPaddingFraction() {
    switch (axis.rangePadding) {
      case AxisRangePadding.none:
        return 0.0;
      case AxisRangePadding.normal:
        return 0.05;
      case AxisRangePadding.additional:
        return 0.10;
      case AxisRangePadding.auto:
      case AxisRangePadding.round:
        return 0.05;
    }
  }

  int _calculateDecimalPlaces(double interval) {
    if (interval >= 1) {
      return 0;
    } else if (interval >= 0.1) {
      return 1;
    } else if (interval >= 0.01) {
      return 2;
    } else if (interval >= 0.001) {
      return 3;
    } else {
      return 4;
    }
  }

  // ==========================================================================
  // PRECISION LABEL GENERATION
  // ==========================================================================

  @override
  List<AxisLabel> generateLabels(AxisBounds bounds) {
    final labels = <AxisLabel>[];

    // Calculate label count FIRST to avoid accumulation
    final labelCount = _calculateLabelCount(bounds);

    // Generate labels using INDEX-BASED calculation
    for (int i = 0; i < labelCount; i++) {
      //  Calculate each value INDEPENDENTLY (no accumulation)
      final currentValue = bounds.min + (bounds.interval * i);

      // Precision check - don't exceed max
      if (currentValue > bounds.max + _epsilon) break;

      // Clean floating-point errors
      final cleanValue = _cleanFloatingPoint(currentValue, bounds.interval);

      final text = _formatValue(cleanValue);

      // Calculate normalized position with high precision
      final position = _calculatePrecisePosition(cleanValue, bounds);

      labels.add(AxisLabel(value: cleanValue, text: text, position: position.clamp(0.0, 1.0)));
    }

    _cachedLabels = labels;
    return labels;
  }

  /// Calculates the number of labels based on bounds.
  int _calculateLabelCount(AxisBounds bounds) {
    if (bounds.range <= 0 || bounds.interval <= 0) return 1;

    // Calculate theoretical count
    final theoreticalCount = (bounds.range / bounds.interval).round() + 1;

    // Clamp to reasonable limits
    return theoreticalCount.clamp(1, _maxLabels);
  }

  /// Calculates position with maximum precision.
  ///
  /// **Algorithm:**
  /// 1. Handle zero-range edge case
  /// 2. Calculate normalized position (0.0 to 1.0)
  /// 3. Apply epsilon-based boundary checks
  /// 4. Return clamped position
  double _calculatePrecisePosition(double value, AxisBounds bounds) {
    if (bounds.range <= _epsilon) return 0.5;

    // Use high-precision division
    final normalized = (value - bounds.min) / bounds.range;

    // Clean floating-point errors at boundaries
    if (normalized.abs() < _epsilon) return 0.0;
    if ((1.0 - normalized).abs() < _epsilon) return 1.0;

    return normalized.clamp(0.0, 1.0);
  }

  /// Cleans floating-point precision errors.
  ///
  /// **Example:**
  /// - Input: 0.30000000000000004
  /// - Output: 0.3
  ///
  /// This prevents labels like "0.30000000000000004" from appearing.
  double _cleanFloatingPoint(double value, double interval) {
    // Determine precision based on interval
    final decimalPlaces = _calculateDecimalPlaces(interval);

    // Round to appropriate precision
    final multiplier = math.pow(10, decimalPlaces);
    return (value * multiplier).roundToDouble() / multiplier;
  }

  // ==========================================================================
  // LABEL FORMATTING (unchanged - already good)
  // ==========================================================================

  String _formatValue(double value) {
    if (axis.labelFormatter != null) {
      return axis.labelFormatter!(value);
    }

    if (configuration.useAbbreviation) {
      return FusionDataFormatter.formatLargeNumber(value, decimals: axis.decimalPlaces);
    }

    if (axis.useScientificNotation) {
      if (value.abs() >= 1e6 || (value.abs() <= 1e-3 && value != 0)) {
        return value.toStringAsExponential(axis.decimalPlaces);
      }
    }

    return value.toStringAsFixed(axis.decimalPlaces);
  }

  // ==========================================================================
  // SIZE MEASUREMENT (unchanged - already good)
  // ==========================================================================

  @override
  Size measureAxisLabels(List<AxisLabel> labels, Size availableSize) {
    if (labels.isEmpty) return Size.zero;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double maxWidth = 0;
    double maxHeight = 0;

    final labelStyle =
        configuration.labelStyle ?? theme?.axisLabelStyle ?? const TextStyle(fontSize: 12);

    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: labelStyle);
      textPainter.layout();

      maxWidth = math.max(maxWidth, textPainter.width);
      maxHeight = math.max(maxHeight, textPainter.height);
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
    if (configuration.showAxisLine) {
      _drawAxisLine(canvas, axisArea);
    }

    if (configuration.showTicks) {
      _drawTicks(canvas, axisArea, bounds);
    }

    if (configuration.showLabels) {
      _drawLabels(canvas, axisArea, bounds);
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

  ///  Pixel-perfect tick positioning
  void _drawTicks(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    final paint = Paint()
      ..color = configuration.majorTickColor ?? theme?.axisColor ?? Colors.grey
      ..strokeWidth = configuration.majorTickWidth ?? 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final tickLength = configuration.majorTickLength ?? 6.0;
    final labels = _cachedLabels ?? generateLabels(bounds);

    for (final label in labels) {
      final position = label.position;

      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        // Snap to pixel boundary for crisp rendering
        final snappedY = y.roundToDouble();
        canvas.drawLine(
          Offset(axisArea.right, snappedY),
          Offset(axisArea.right + tickLength, snappedY),
          paint,
        );
      } else {
        final x = axisArea.left + (position * axisArea.width);
        // Snap to pixel boundary for crisp rendering
        final snappedX = x.roundToDouble();
        canvas.drawLine(
          Offset(snappedX, axisArea.top),
          Offset(snappedX, axisArea.top + tickLength),
          paint,
        );
      }
    }
  }

  /// Pixel-perfect label positioning
  void _drawLabels(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    final labels = _cachedLabels ?? generateLabels(bounds);

    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    final labelStyle =
        configuration.labelStyle ?? theme?.axisLabelStyle ?? const TextStyle(fontSize: 12);

    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: labelStyle);
      textPainter.layout();

      final position = label.position;

      final Offset offset;
      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        // Snap to pixel boundary
        final snappedY = y.roundToDouble();
        offset = Offset(axisArea.left - textPainter.width - 8, snappedY - (textPainter.height / 2));
      } else {
        final x = axisArea.left + (position * axisArea.width);
        //  Snap to pixel boundary
        final snappedX = x.roundToDouble();
        offset = Offset(snappedX - (textPainter.width / 2), axisArea.top + 8);
      }

      textPainter.paint(canvas, offset);
    }
  }

  /// Pixel-perfect grid line rendering
  @override
  void renderGridLines(Canvas canvas, Rect plotArea, AxisBounds bounds) {
    if (!configuration.showGrid) return;

    final paint = Paint()
      ..color =
          configuration.majorGridColor ?? theme?.gridColor ?? Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = configuration.majorGridWidth ?? 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final labels = _cachedLabels ?? generateLabels(bounds);

    for (final label in labels) {
      final position = label.position;

      if (isVertical) {
        final y = plotArea.bottom - (position * plotArea.height);
        // Snap to pixel boundary for crisp lines
        final snappedY = y.roundToDouble();
        canvas.drawLine(Offset(plotArea.left, snappedY), Offset(plotArea.right, snappedY), paint);
      } else {
        final x = plotArea.left + (position * plotArea.width);
        // Snap to pixel boundary for crisp lines
        final snappedX = x.roundToDouble();
        canvas.drawLine(Offset(snappedX, plotArea.top), Offset(snappedX, plotArea.bottom), paint);
      }
    }
  }

  // ==========================================================================
  // DISPOSAL
  // ==========================================================================

  @override
  void dispose() {
    _cachedBounds = null;
    _cachedLabels = null;
  }

  @override
  String toString() {
    return 'NumericAxisRenderer('
        'isVertical: $isVertical, '
        'bounds: $_cachedBounds, '
        'labelCount: ${_cachedLabels?.length ?? 0}'
        ')';
  }
}

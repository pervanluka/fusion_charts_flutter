import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../configuration/fusion_axis_configuration.dart';
import '../../../themes/fusion_chart_theme.dart';
import '../../../utils/axis_calculator.dart';
import '../../../utils/fusion_data_formatter.dart';
import '../../models/axis_bounds.dart';
import '../../models/axis_label.dart';
import '../../enums/axis_range_padding.dart';
import '../base/fusion_axis_renderer.dart';
import 'fusion_numeric_axis.dart';

/// Renders numeric axes with continuous numeric values.
///
/// ## Configuration Priority
///
/// `FusionAxisConfiguration` is the **single source of truth** for all axis properties.
/// The `FusionNumericAxis` only provides type-specific defaults and formatting hints.
///
/// Priority order for each property:
/// 1. `configuration.property` (if set)
/// 2. `axis.property` (type-specific fallback)
/// 3. Calculated/default value
///
/// ## Example
///
/// ```dart
/// // Configuration controls everything
/// FusionAxisConfiguration(
///   min: 0,
///   max: 100,
///   interval: 20,
///   desiredIntervals: 5,
///   visible: true,
///   showLabels: true,
/// )
/// ```
class NumericAxisRenderer extends FusionAxisRenderer {
  NumericAxisRenderer({
    required this.axis,
    required this.configuration,
    this.theme,
    this.isVertical = true,
  });

  /// The numeric axis type definition (provides type-specific defaults).
  final FusionNumericAxis axis;

  /// The axis configuration (PRIMARY source of truth).
  final FusionAxisConfiguration configuration;

  /// Theme for fallback styling.
  final FusionChartTheme? theme;

  /// Whether this is a vertical axis.
  final bool isVertical;

  // ==========================================================================
  // PRECISION CONSTANTS
  // ==========================================================================

  static const double _epsilon = 1e-10;
  static const int _maxLabels = 1000;

  // ==========================================================================
  // CACHING
  // ==========================================================================

  AxisBounds? _cachedBounds;
  List<AxisLabel>? _cachedLabels;

  // ==========================================================================
  // EFFECTIVE VALUE GETTERS (Configuration → Axis → Default)
  // ==========================================================================

  /// Gets the effective minimum value.
  /// Priority: configuration.min → axis.min → null (auto-calculate)
  double? get _effectiveMin => configuration.min ?? axis.min;

  /// Gets the effective maximum value.
  /// Priority: configuration.max → axis.max → null (auto-calculate)
  double? get _effectiveMax => configuration.max ?? axis.max;

  /// Gets the effective interval.
  /// Priority: configuration.interval → axis.interval → null (auto-calculate)
  double? get _effectiveInterval => configuration.interval ?? axis.interval;

  /// Gets the effective desired interval count.
  /// Priority: configuration.desiredIntervals → axis.desiredIntervals → 5
  int get _effectiveDesiredIntervals =>
      configuration.desiredIntervals != 5 ? configuration.desiredIntervals : axis.desiredIntervals;

  /// Gets whether to auto-calculate range.
  /// If min AND max are explicitly set, autoRange is effectively false.
  bool get _shouldAutoRange =>
      configuration.autoRange && (_effectiveMin == null || _effectiveMax == null);

  /// Gets whether to auto-calculate interval.
  bool get _shouldAutoInterval => configuration.autoInterval && _effectiveInterval == null;

  /// Gets whether to include zero in the range.
  /// Priority: configuration.includeZero → false
  bool get _shouldIncludeZero => configuration.includeZero ?? false;

  /// Gets the range padding fraction.
  /// Priority: configuration.rangePadding (double) → axis.rangePadding (enum) → 0.05
  double get _rangePaddingFraction {
    // Priority 1: Use configuration.rangePadding if set (it's a double 0.0-1.0)
    if (configuration.rangePadding != null) {
      return configuration.rangePadding!.clamp(0.0, 1.0);
    }

    // Priority 2: Convert axis.rangePadding enum to fraction
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

  /// Gets decimal places for formatting.
  int get _effectiveDecimalPlaces => axis.decimalPlaces;

  /// Gets label formatter.
  String Function(double)? get _effectiveLabelFormatter =>
      configuration.labelFormatter ?? axis.labelFormatter;

  /// Gets whether to use scientific notation.
  bool get _effectiveUseScientificNotation =>
      configuration.useScientificNotation || axis.useScientificNotation;

  // ==========================================================================
  // BOUNDS CALCULATION
  // ==========================================================================

  @override
  AxisBounds calculateBounds(List<double> dataValues) {
    if (dataValues.isEmpty && _effectiveMin == null && _effectiveMax == null) {
      // No data and no explicit bounds - use safe defaults
      _cachedBounds = AxisBounds(min: 0, max: 10, interval: 1, decimalPlaces: 0);
      return _cachedBounds!;
    }

    // Step 1: Determine min/max
    double min;
    double max;

    if (_shouldAutoRange || _effectiveMin == null || _effectiveMax == null) {
      // Auto-calculate from data
      final dataMin = dataValues.isNotEmpty ? dataValues.reduce((a, b) => a < b ? a : b) : 0.0;
      final dataMax = dataValues.isNotEmpty ? dataValues.reduce((a, b) => a > b ? a : b) : 10.0;

      min = _effectiveMin ?? dataMin;
      max = _effectiveMax ?? dataMax;
    } else {
      // Use explicit values
      min = _effectiveMin!;
      max = _effectiveMax!;
    }

    // Step 2: Handle edge case where min == max
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

    // Step 3: Include zero if requested
    if (_shouldIncludeZero) {
      if (min > 0) min = 0;
      if (max < 0) max = 0;
    }

    // Step 4: Apply range padding (only if auto-ranging)
    if (_shouldAutoRange) {
      final range = max - min;
      final padding = _rangePaddingFraction;
      min -= range * padding;
      max += range * padding;

      // Re-apply includeZero after padding (don't pad past zero)
      if (_shouldIncludeZero) {
        if (min > 0) min = 0;
        if (max < 0) max = 0;
      }
    }

    // Step 5: Calculate interval
    double interval;
    if (_shouldAutoInterval) {
      interval = AxisCalculator.calculateNiceInterval(min, max, _effectiveDesiredIntervals);
    } else {
      interval = _effectiveInterval ?? 1.0;
    }

    // Ensure interval is positive
    if (interval <= 0) {
      interval = (max - min) / _effectiveDesiredIntervals;
      if (interval <= 0) interval = 1.0;
    }

    // Step 6: Round bounds to nice numbers if auto-ranging
    if (_shouldAutoRange) {
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
  // LABEL GENERATION
  // ==========================================================================

  @override
  List<AxisLabel> generateLabels(AxisBounds bounds) {
    final labels = <AxisLabel>[];

    final labelCount = _calculateLabelCount(bounds);

    for (int i = 0; i < labelCount; i++) {
      final currentValue = bounds.min + (bounds.interval * i);

      if (currentValue > bounds.max + _epsilon) break;

      final cleanValue = _cleanFloatingPoint(currentValue, bounds.interval);
      final text = _formatValue(cleanValue);
      final position = _calculatePrecisePosition(cleanValue, bounds);

      labels.add(AxisLabel(value: cleanValue, text: text, position: position.clamp(0.0, 1.0)));
    }

    _cachedLabels = labels;
    return labels;
  }

  int _calculateLabelCount(AxisBounds bounds) {
    if (bounds.range <= 0 || bounds.interval <= 0) return 1;

    final theoreticalCount = (bounds.range / bounds.interval).round() + 1;
    return theoreticalCount.clamp(1, _maxLabels);
  }

  double _calculatePrecisePosition(double value, AxisBounds bounds) {
    if (bounds.range <= _epsilon) return 0.5;

    final normalized = (value - bounds.min) / bounds.range;

    if (normalized.abs() < _epsilon) return 0.0;
    if ((1.0 - normalized).abs() < _epsilon) return 1.0;

    return normalized.clamp(0.0, 1.0);
  }

  double _cleanFloatingPoint(double value, double interval) {
    final decimalPlaces = _calculateDecimalPlaces(interval);
    final multiplier = math.pow(10, decimalPlaces);
    return (value * multiplier).roundToDouble() / multiplier;
  }

  // ==========================================================================
  // LABEL FORMATTING
  // ==========================================================================

  String _formatValue(double value) {
    // Priority 1: Custom formatter from configuration or axis
    final formatter = _effectiveLabelFormatter;
    if (formatter != null) {
      return formatter(value);
    }

    // Priority 2: Abbreviation (K, M, B)
    if (configuration.useAbbreviation) {
      return FusionDataFormatter.formatLargeNumber(value, decimals: _effectiveDecimalPlaces);
    }

    // Priority 3: Scientific notation
    if (_effectiveUseScientificNotation) {
      if (value.abs() >= 1e6 || (value.abs() <= 1e-3 && value != 0)) {
        return value.toStringAsExponential(_effectiveDecimalPlaces);
      }
    }

    // Default: Fixed decimal places
    return value.toStringAsFixed(_effectiveDecimalPlaces);
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
    // CRITICAL: Check visibility first
    if (!configuration.visible) {
      return; // Don't render anything if axis is not visible
    }

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
        final snappedY = y.roundToDouble();
        canvas.drawLine(
          Offset(axisArea.right, snappedY),
          Offset(axisArea.right + tickLength, snappedY),
          paint,
        );
      } else {
        final x = axisArea.left + (position * axisArea.width);
        final snappedX = x.roundToDouble();
        canvas.drawLine(
          Offset(snappedX, axisArea.top),
          Offset(snappedX, axisArea.top + tickLength),
          paint,
        );
      }
    }
  }

  void _drawLabels(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    final labels = _cachedLabels ?? generateLabels(bounds);

    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    final labelStyle =
        configuration.labelStyle ?? theme?.axisLabelStyle ?? const TextStyle(fontSize: 12);

    final rotation = configuration.labelRotation ?? 0.0;

    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: labelStyle);
      textPainter.layout();

      final position = label.position;

      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        final snappedY = y.roundToDouble();
        final offset = Offset(
          axisArea.left - textPainter.width - 8,
          snappedY - (textPainter.height / 2),
        );
        textPainter.paint(canvas, offset);
      } else {
        final x = axisArea.left + (position * axisArea.width);
        final snappedX = x.roundToDouble();

        if (rotation != 0.0) {
          // Apply rotation
          canvas.save();
          canvas.translate(snappedX, axisArea.top + 8);
          canvas.rotate(rotation * (math.pi / 180));
          textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
          canvas.restore();
        } else {
          final offset = Offset(snappedX - (textPainter.width / 2), axisArea.top + 8);
          textPainter.paint(canvas, offset);
        }
      }
    }
  }

  // ==========================================================================
  // GRID LINES
  // ==========================================================================

  @override
  void renderGridLines(Canvas canvas, Rect plotArea, AxisBounds bounds) {
    // Check visibility - if axis is not visible, still show grid if showGrid is true
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
        final snappedY = y.roundToDouble();
        canvas.drawLine(Offset(plotArea.left, snappedY), Offset(plotArea.right, snappedY), paint);
      } else {
        final x = plotArea.left + (position * plotArea.width);
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
        'visible: ${configuration.visible}, '
        'bounds: $_cachedBounds, '
        'labelCount: ${_cachedLabels?.length ?? 0}'
        ')';
  }
}

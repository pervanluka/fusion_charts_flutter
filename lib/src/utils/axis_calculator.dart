// lib/src/utils/axis_calculator.dart

import 'dart:math' as math;
import '../core/enums/chart_range_padding.dart';
import '../core/models/axis_bounds.dart';

/// Enhanced axis calculator with robust edge case handling.
///
/// - Handles tiny ranges (< 0.001) with appropriate fractions
/// - Handles huge ranges (> 1e9) with round numbers
/// - Better zero-range handling with magnitude-aware scaling
/// - Improved floating-point cleaning
/// - More precise epsilon comparisons
///
/// - More robust edge case handling
/// - Cleaner floating-point arithmetic
/// - Better decimal place calculation
/// - Magnitude-aware interval selection
class AxisCalculator {
  /// Epsilon for floating-point comparisons.
  static const double _epsilon = 1e-10;

  /// Base 10 logarithm (helper since Dart only has ln).
  static double log10(double x) => math.log(x) / math.ln10;

  // ==========================================================================
  // ✅ ENHANCED NICE INTERVAL CALCULATION
  // ==========================================================================

  /// Calculates "nice" interval with robust edge case handling.
  ///
  /// ✅ ENHANCEMENT: Now handles tiny/huge ranges intelligently.
  static double calculateNiceInterval(double min, double max, int desiredIntervals) {
    assert(desiredIntervals > 0, 'Desired intervals must be positive');

    final range = (max - min).abs();

    // ✅ ENHANCED: Zero range handling
    if (range < _epsilon) {
      return _handleZeroRangeInterval(min, max);
    }

    // ✅ NEW: Tiny range handling (< 0.001)
    if (range < 0.001) {
      return _handleTinyInterval(range, desiredIntervals);
    }

    // ✅ NEW: Huge range handling (> 1e9)
    if (range > 1e9) {
      return _handleLargeInterval(range, desiredIntervals);
    }

    // Standard Wilkinson's algorithm (already good)
    final roughInterval = range / desiredIntervals;
    final magnitude = math.pow(10, (log10(roughInterval)).floor()).toDouble();
    final normalized = roughInterval / magnitude;
    final niceFraction = _getNiceFraction(normalized);

    return niceFraction * magnitude;
  }

  /// ✅ ENHANCED: Handles zero or near-zero range intelligently.
  static double _handleZeroRangeInterval(double min, double max) {
    // Both values are zero or very close
    if (min.abs() < _epsilon && max.abs() < _epsilon) {
      return 0.2; // Better than 1.0 for zero-centered data
    }

    // Values are equal but non-zero - use magnitude-based interval
    final avgValue = ((min + max) / 2).abs();
    if (avgValue < _epsilon) {
      return 0.1;
    }

    // Create interval based on the magnitude of the value
    final magnitude = math.pow(10, (log10(avgValue)).floor() - 1).toDouble();
    return magnitude;
  }

  /// ✅ NEW: Handles very small ranges (< 0.001).
  static double _handleTinyInterval(double range, int desiredIntervals) {
    final roughInterval = range / desiredIntervals;

    // Find magnitude (will be very small, like 1e-5)
    final magnitude = math.pow(10, (log10(roughInterval)).floor()).toDouble();
    final normalized = roughInterval / magnitude;

    // Use finer fractions for tiny ranges
    double niceFraction;
    if (normalized < 1.5) {
      niceFraction = 1.0;
    } else if (normalized < 3.0) {
      niceFraction = 2.0;
    } else if (normalized < 7.0) {
      niceFraction = 5.0;
    } else {
      niceFraction = 10.0;
    }

    return niceFraction * magnitude;
  }

  /// ✅ NEW: Handles very large ranges (> 1e9).
  static double _handleLargeInterval(double range, int desiredIntervals) {
    final roughInterval = range / desiredIntervals;

    // Find magnitude (will be very large, like 1e11)
    final magnitude = math.pow(10, (log10(roughInterval)).floor()).toDouble();
    final normalized = roughInterval / magnitude;

    // Prefer round numbers for large ranges
    double niceFraction;
    if (normalized < 1.5) {
      niceFraction = 1.0;
    } else if (normalized < 3.0) {
      niceFraction = 2.0;
    } else if (normalized < 7.5) {
      niceFraction = 5.0;
    } else {
      niceFraction = 10.0;
    }

    return niceFraction * magnitude;
  }

  /// Gets nice fraction from normalized value (unchanged - already good).
  static double _getNiceFraction(double normalized) {
    if (normalized < 1.5) {
      return 1.0;
    } else if (normalized < 3.0) {
      return 2.0;
    } else if (normalized < 7.0) {
      return 5.0;
    } else {
      return 10.0;
    }
  }

  // ==========================================================================
  // ✅ ENHANCED NICE BOUNDS CALCULATION
  // ==========================================================================

  static AxisBounds calculateNiceBounds(
    double dataMin,
    double dataMax, {
    int desiredIntervals = 5,
    ChartRangePadding padding = ChartRangePadding.auto,
    double? interval,
  }) {
    assert(desiredIntervals > 0, 'Desired intervals must be positive');
    assert(dataMin <= dataMax, 'Min must be <= Max');

    // ✅ ENHANCED: Better zero-range handling
    if ((dataMax - dataMin).abs() < _epsilon) {
      return _handleZeroRange(dataMin, dataMax, padding);
    }

    // Calculate or use provided interval
    final effectiveInterval = interval ?? calculateNiceInterval(dataMin, dataMax, desiredIntervals);

    // Apply padding strategy
    return _applyPadding(dataMin, dataMax, effectiveInterval, padding);
  }

  /// ✅ ENHANCED: Better zero-range handling with magnitude awareness.
  static AxisBounds _handleZeroRange(double value, double value2, ChartRangePadding padding) {
    // Check if both values are truly zero
    if (value.abs() < _epsilon && value2.abs() < _epsilon) {
      return AxisBounds(min: -1.0, max: 1.0, interval: 0.5, decimalPlaces: 1);
    }

    // Values are equal but non-zero - choose scale based on magnitude
    final absValue = value.abs();

    double scale;
    if (absValue < 1.0) {
      // Small numbers: use 50% of value
      scale = absValue * 0.5;
    } else if (absValue < 100) {
      // Medium numbers: fixed scale
      scale = 10.0;
    } else {
      // Large numbers: magnitude-based scale
      final magnitude = math.pow(10, (log10(absValue)).floor()).toDouble();
      scale = magnitude * 0.5;
    }

    final interval = scale / 2;

    return AxisBounds(
      min: value - scale,
      max: value + scale,
      interval: interval,
      decimalPlaces: _calculateDecimalPlaces(interval),
    );
  }

  /// Applies padding strategy to bounds (unchanged - already good).
  static AxisBounds _applyPadding(
    double dataMin,
    double dataMax,
    double interval,
    ChartRangePadding padding,
  ) {
    double min;
    double max;

    switch (padding) {
      case ChartRangePadding.none:
        min = dataMin;
        max = dataMax;
        break;

      case ChartRangePadding.normal:
        min = _roundDown(dataMin, interval);
        max = _roundUp(dataMax, interval);
        break;

      case ChartRangePadding.round:
        min = _roundToNiceNumber(dataMin, interval, roundDown: true);
        max = _roundToNiceNumber(dataMax, interval, roundDown: false);
        break;

      case ChartRangePadding.additional:
        min = _roundDown(dataMin, interval) - interval;
        max = _roundUp(dataMax, interval) + interval;
        break;

      case ChartRangePadding.auto:
        final range = dataMax - dataMin;

        if (range > 1000) {
          min = _roundToNiceNumber(dataMin, interval, roundDown: true);
          max = _roundToNiceNumber(dataMax, interval, roundDown: false);
        } else if (dataMin >= 0 && dataMax > 0) {
          min = 0.0;
          max = _roundUp(dataMax, interval);
        } else {
          min = _roundDown(dataMin, interval);
          max = _roundUp(dataMax, interval);
        }
        break;
    }

    return AxisBounds(
      min: min,
      max: max,
      interval: interval,
      decimalPlaces: _calculateDecimalPlaces(interval),
    );
  }

  // ==========================================================================
  // ROUNDING UTILITIES (unchanged - already good)
  // ==========================================================================

  static double _roundDown(double value, double interval) {
    return (value / interval).floor() * interval;
  }

  static double _roundUp(double value, double interval) {
    return (value / interval).ceil() * interval;
  }

  static double _roundToNiceNumber(double value, double interval, {required bool roundDown}) {
    final magnitude = math.pow(10, (log10(interval)).floor()).toDouble();
    final normalized = value / magnitude;

    final rounded = roundDown
        ? (normalized / _getNiceFraction(normalized)).floor() * _getNiceFraction(normalized)
        : (normalized / _getNiceFraction(normalized)).ceil() * _getNiceFraction(normalized);

    return rounded * magnitude;
  }

  // ==========================================================================
  // ✅ ENHANCED LABEL GENERATION
  // ==========================================================================

  /// Generates axis label values with clean floating-point handling.
  ///
  /// ✅ ENHANCEMENT: Now uses improved floating-point cleaning.
  static List<double> generateLabelValues(double min, double max, double interval) {
    assert(interval > 0, 'Interval must be positive');
    assert(min <= max, 'Min must be <= Max');

    final values = <double>[];
    final steps = ((max - min) / interval).round() + 1;

    // ✅ ENHANCED: Index-based generation (no accumulation)
    for (int i = 0; i < steps; i++) {
      final value = min + (interval * i);

      if (value <= max + _epsilon) {
        values.add(_cleanFloatingPoint(value, interval));
      }
    }

    // Ensure max is included
    if (values.isEmpty || (values.last - max).abs() > _epsilon) {
      values.add(max);
    }

    return values;
  }

  // ==========================================================================
  // MINOR TICK CALCULATION (unchanged - already good)
  // ==========================================================================

  static List<double> generateMinorTicks(
    double min,
    double max,
    double interval,
    int minorTicksPerInterval,
  ) {
    assert(minorTicksPerInterval > 0, 'Minor ticks count must be positive');

    if (minorTicksPerInterval == 0) {
      return [];
    }

    final minorInterval = interval / (minorTicksPerInterval + 1);
    final minorTicks = <double>[];

    double current = min + minorInterval;

    while (current < max - _epsilon) {
      final distanceToNearestMajor = (current % interval).abs();

      if (distanceToNearestMajor > _epsilon && (interval - distanceToNearestMajor) > _epsilon) {
        minorTicks.add(_cleanFloatingPoint(current, minorInterval));
      }

      current += minorInterval;
    }

    return minorTicks;
  }

  // ==========================================================================
  // SPECIAL CASES (unchanged - already good)
  // ==========================================================================

  static double getNextNiceNumber(double value) {
    if (value.abs() < _epsilon) {
      return 1.0;
    }

    final magnitude = math.pow(10, (log10(value.abs())).floor()).toDouble();
    final normalized = value / magnitude;

    return _getNextNiceNumber(normalized) * magnitude;
  }

  static double _getNextNiceNumber(double normalized) {
    if (normalized < 1.0) {
      return 1.0;
    } else if (normalized < 2.0) {
      return 2.0;
    } else if (normalized < 5.0) {
      return 5.0;
    } else {
      return 10.0;
    }
  }

  static double getPreviousNiceNumber(double value) {
    if (value.abs() < _epsilon) {
      return -1.0;
    }

    final magnitude = math.pow(10, (log10(value.abs())).floor()).toDouble();
    final normalized = value / magnitude;

    final previous = _getPreviousNiceNumber(normalized);

    return previous * magnitude;
  }

  static double _getPreviousNiceNumber(double normalized) {
    if (normalized <= 1.0) {
      return 0.5;
    } else if (normalized <= 2.0) {
      return 1.0;
    } else if (normalized <= 5.0) {
      return 2.0;
    } else if (normalized <= 10.0) {
      return 5.0;
    } else {
      return 10.0;
    }
  }

  // ==========================================================================
  // ✅ ENHANCED FLOATING POINT UTILITIES
  // ==========================================================================

  /// Cleans floating point precision errors intelligently.
  ///
  /// ✅ ENHANCEMENT: Now uses interval-aware rounding instead of fixed 10 decimals.
  static double _cleanFloatingPoint(double value, [double? interval]) {
    if (value.abs() < _epsilon) return 0.0;

    // If interval provided, use appropriate decimal places
    if (interval != null) {
      final decimalPlaces = _calculateDecimalPlaces(interval);
      final multiplier = math.pow(10, decimalPlaces);
      return (value * multiplier).roundToDouble() / multiplier;
    }

    // Fallback: round to 10 decimal places
    return double.parse(value.toStringAsFixed(10));
  }

  /// ✅ ENHANCED: Better decimal place calculation.
  static int _calculateDecimalPlaces(double interval) {
    if (interval >= 1) return 0;

    // Find the number of decimal places needed
    final str = interval.toStringAsFixed(12); // Use more precision initially
    final parts = str.split('.');
    if (parts.length < 2) return 0;

    // Count non-zero decimals
    final decimals = parts[1].replaceAll(RegExp(r'0+$'), '');

    // Clamp to reasonable range
    return decimals.length.clamp(0, 6);
  }
}

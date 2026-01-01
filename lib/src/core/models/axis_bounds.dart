import 'dart:math' as math;

/// Represents the calculated bounds and intervals for a chart axis.
///
/// This is the core data structure that stores axis range information
/// after applying nice number algorithms (Wilkinson's Extended).
///
/// Used by all axis types (numeric, category, datetime) to define
/// their data range and tick intervals.
///
/// ## Example
///
/// ```dart
/// final bounds = AxisBounds(
///   min: 0,
///   max: 100,
///   interval: 20,
///   decimalPlaces: 0,
/// );
/// // Creates axis from 0 to 100 with ticks at 0, 20, 40, 60, 80, 100
/// ```
class AxisBounds {
  /// Creates axis bounds with calculated values.
  const AxisBounds({
    required this.min,
    required this.max,
    required this.interval,
    this.decimalPlaces = 2,
    this.minorTickInterval,
    this.padding = 0.0,
  }) : assert(min <= max, 'min must be <= max'),
       assert(interval > 0, 'interval must be positive'),
       assert(decimalPlaces >= 0, 'decimalPlaces must be non-negative'),
       assert(padding >= 0 && padding <= 1, 'padding must be between 0 and 1');

  // ==========================================================================
  // FACTORY CONSTRUCTORS
  // ==========================================================================

  /// Creates bounds from raw data range.
  ///
  /// Applies nice number algorithm to create human-friendly intervals.
  factory AxisBounds.fromDataRange({
    required double dataMin,
    required double dataMax,
    int? desiredTickCount,
    double padding = 0.05,
    bool includeZero = false,
  }) {
    // Apply padding
    var range = dataMax - dataMin;
    if (range == 0) {
      // Handle single value
      range = dataMin.abs() * 0.1;
      if (range == 0) range = 1;
    }

    final paddedMin = dataMin - (range * padding);
    final paddedMax = dataMax + (range * padding);

    // Include zero if requested
    final adjustedMin = includeZero && paddedMin > 0 ? 0 : paddedMin;
    final adjustedMax = includeZero && paddedMax < 0 ? 0 : paddedMax;

    // Calculate nice bounds (simplified - full implementation in calculator)
    final niceRange = adjustedMax - adjustedMin;
    final interval = _calculateNiceInterval(niceRange, desiredTickCount ?? 5);

    final niceMin = (adjustedMin / interval).floor() * interval;
    final niceMax = (adjustedMax / interval).ceil() * interval;

    return AxisBounds(
      min: niceMin,
      max: niceMax,
      interval: interval,
      decimalPlaces: _calculateDecimalPlaces(interval),
      padding: padding,
    );
  }

  /// Minimum value of the axis.
  ///
  /// This is the "nice" minimum after applying rounding algorithms.
  /// For example, if data min is 3.2, this might be rounded to 0.
  final double min;

  /// Maximum value of the axis.
  ///
  /// This is the "nice" maximum after applying rounding algorithms.
  /// For example, if data max is 97.8, this might be rounded to 100.
  final double max;

  /// Major tick interval.
  ///
  /// The distance between major tick marks and grid lines.
  /// Calculated using Wilkinson's Extended algorithm for "nice" numbers.
  final double interval;

  /// Number of decimal places for label formatting.
  ///
  /// Automatically calculated based on the interval.
  /// For example:
  /// - interval = 1.0 → decimalPlaces = 0
  /// - interval = 0.5 → decimalPlaces = 1
  /// - interval = 0.25 → decimalPlaces = 2
  final int decimalPlaces;

  /// Minor tick interval (optional).
  ///
  /// If specified, minor ticks/grid lines appear between major ones.
  /// Typically interval / 2 or interval / 5.
  final double? minorTickInterval;

  /// Padding as a fraction of the range.
  ///
  /// Adds extra space at the edges of the axis.
  /// 0.0 = no padding, 0.1 = 10% padding on each side.
  final double padding;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// The data range (max - min).
  double get range => max - min;

  /// Number of major ticks on the axis.
  ///
  /// Includes both min and max ticks.
  int get majorTickCount {
    if (range == 0) return 1;
    return (range / interval).round() + 1;
  }

  /// Number of minor ticks between each major tick pair.
  int get minorTicksPerInterval {
    if (minorTickInterval == null || minorTickInterval! <= 0) return 0;
    return (interval / minorTickInterval!).round() - 1;
  }

  /// Gets all major tick values.
  ///
  /// Returns a list of tick positions from min to max at intervals.
  List<double> get majorTicks {
    final ticks = <double>[];

    // Start from a nice round number
    var current = (min / interval).floor() * interval;

    // Generate ticks
    while (current <= max * 1.0001) {
      // Small epsilon for floating point
      if (current >= min) {
        ticks.add(current);
      }
      current += interval;
    }

    return ticks;
  }

  /// Gets all minor tick values.
  List<double> get minorTicks {
    if (minorTickInterval == null) return [];

    final ticks = <double>[];
    final majorTickValues = majorTicks;

    for (int i = 0; i < majorTickValues.length - 1; i++) {
      var current = majorTickValues[i] + minorTickInterval!;
      while (current < majorTickValues[i + 1]) {
        ticks.add(current);
        current += minorTickInterval!;
      }
    }

    return ticks;
  }

  /// Simple nice interval calculation (full version in calculator).
  static double _calculateNiceInterval(num range, int targetTicks) {
    final roughInterval = range / targetTicks;

    // Find magnitude
    final magnitude = math.pow(10, (math.log(roughInterval) / math.ln10).floor());
    final normalized = roughInterval / magnitude;

    // Nice numbers: 1, 2, 5, 10
    num niceInterval;
    if (normalized <= 1) {
      niceInterval = 1 * magnitude;
    } else if (normalized <= 2) {
      niceInterval = 2 * magnitude;
    } else if (normalized <= 5) {
      niceInterval = 5 * magnitude;
    } else {
      niceInterval = 10 * magnitude;
    }

    return niceInterval.toDouble();
  }

  /// Calculate decimal places based on interval.
  static int _calculateDecimalPlaces(double interval) {
    if (interval >= 1) {
      return 0;
    }

    // Count decimal places
    final str = interval.toString();
    final parts = str.split('.');
    if (parts.length < 2) return 0;

    // Remove trailing zeros
    final decimals = parts[1].replaceAll(RegExp(r'0+$'), '');
    return decimals.length;
  }

  // ==========================================================================
  // METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  AxisBounds copyWith({
    double? min,
    double? max,
    double? interval,
    int? decimalPlaces,
    double? minorTickInterval,
    double? padding,
  }) {
    return AxisBounds(
      min: min ?? this.min,
      max: max ?? this.max,
      interval: interval ?? this.interval,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      minorTickInterval: minorTickInterval ?? this.minorTickInterval,
      padding: padding ?? this.padding,
    );
  }

  /// Checks if a value is within bounds.
  bool contains(double value) {
    return value >= min && value <= max;
  }

  /// Normalizes a value to 0-1 range.
  double normalize(double value) {
    if (range == 0) return 0.5;
    return (value - min) / range;
  }

  /// Denormalizes from 0-1 range to actual value.
  double denormalize(double normalized) {
    return min + (normalized * range);
  }

  @override
  String toString() {
    return 'AxisBounds(min: $min, max: $max, interval: $interval, '
        'ticks: $majorTickCount, decimals: $decimalPlaces)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AxisBounds &&
        other.min == min &&
        other.max == max &&
        other.interval == interval &&
        other.decimalPlaces == decimalPlaces &&
        other.minorTickInterval == minorTickInterval &&
        other.padding == padding;
  }

  @override
  int get hashCode {
    return Object.hash(min, max, interval, decimalPlaces, minorTickInterval, padding);
  }
}

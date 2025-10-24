import 'package:flutter/material.dart';
import '../../enums/axis_range_padding.dart';
import '../../enums/label_alignment.dart';
import '../base/fusion_axis_base.dart';

/// Numeric axis for displaying continuous numeric data.
///
/// This axis type handles continuous numeric values with smart interval
/// calculation using Wilkinson's Extended Algorithm.
///
/// ## Features
///
/// - Automatic interval calculation
/// - Range padding strategies
/// - Scientific notation for large/small numbers
/// - Custom label formatters
/// - Logarithmic scale support (future)
///
/// ## Example
///
/// ```dart
/// final axis = FusionNumericAxis(
///   min: 0,
///   max: 100,
///   interval: 20,
///   title: 'Revenue (\$)',
///   decimalPlaces: 2,
/// );
/// ```
///
/// ## Architecture
///
/// - [FusionNumericAxis] - Defines the axis properties (min, max, interval)
/// - [FusionAxisConfiguration] - Defines styling (colors, visibility, etc.)
/// - [NumericAxisRenderer] - Renders the axis using both
class FusionNumericAxis extends FusionAxisBase {
  /// Creates a numeric axis.
  const FusionNumericAxis({
    // Base properties
    super.name,
    super.title,
    super.titleStyle,
    super.opposedPosition,
    bool isInversed = false,

    // Range properties
    this.min,
    this.max,
    this.interval,
    this.desiredIntervals = 5,

    // Formatting properties
    this.labelFormatter,
    this.labelAlignment = LabelAlignment.center,
    this.decimalPlaces = 2,
    this.useScientificNotation = false,

    // Padding
    this.rangePadding = AxisRangePadding.auto,
  }) : _isInversed = isInversed;

  // ==========================================================================
  // RANGE PROPERTIES
  // ==========================================================================

  /// Minimum value for the axis.
  ///
  /// If null, the minimum will be calculated automatically from data.
  ///
  /// Example:
  /// ```dart
  /// min: 0  // Start axis at 0
  /// ```
  final double? min;

  /// Maximum value for the axis.
  ///
  /// If null, the maximum will be calculated automatically from data.
  ///
  /// Example:
  /// ```dart
  /// max: 100  // End axis at 100
  /// ```
  final double? max;

  /// Interval between axis labels.
  ///
  /// If null, the interval will be calculated automatically using
  /// Wilkinson's Extended Algorithm to create "nice" numbers.
  ///
  /// Example:
  /// ```dart
  /// interval: 10  // Labels at 0, 10, 20, 30, etc.
  /// ```
  final double? interval;

  /// Desired number of intervals when auto-calculating.
  ///
  /// Used as a hint for the automatic interval calculation.
  /// The actual number may differ slightly to achieve "nice" numbers.
  ///
  /// Default: 5
  ///
  /// Example:
  /// ```dart
  /// desiredIntervals: 10  // Try to create ~10 intervals
  /// ```
  final int desiredIntervals;

  // ==========================================================================
  // FORMATTING PROPERTIES
  // ==========================================================================

  /// Custom label formatter function.
  ///
  /// If provided, this function will be called for each label value
  /// to format it as a string. This allows you to add prefixes, suffixes,
  /// or custom formatting logic.
  ///
  /// Example:
  /// ```dart
  /// labelFormatter: (value) => '\$${value.toStringAsFixed(2)}'
  /// // Output: $0.00, $10.00, $20.00
  ///
  /// labelFormatter: (value) => '${value.toInt()}K'
  /// // Output: 0K, 10K, 20K
  /// ```
  final String Function(double value)? labelFormatter;

  /// Label alignment relative to tick position.
  ///
  /// - [LabelAlignment.start] - Align to start of tick
  /// - [LabelAlignment.center] - Center on tick (default)
  /// - [LabelAlignment.end] - Align to end of tick
  ///
  /// Default: [LabelAlignment.center]
  final LabelAlignment labelAlignment;

  /// Number of decimal places to show in labels.
  ///
  /// Only applies if no custom [labelFormatter] is provided.
  ///
  /// Default: 2
  ///
  /// Example:
  /// ```dart
  /// decimalPlaces: 0  // 10, 20, 30
  /// decimalPlaces: 2  // 10.00, 20.00, 30.00
  /// ```
  final int decimalPlaces;

  /// Whether to use scientific notation for very large or small numbers.
  ///
  /// When true, numbers like 1,000,000 become 1e6 and 0.000001 becomes 1e-6.
  ///
  /// Default: false
  ///
  /// Example:
  /// ```dart
  /// useScientificNotation: true
  /// // 1000000 â†' 1e6
  /// // 0.000001 â†' 1e-6
  /// ```
  final bool useScientificNotation;

  // ==========================================================================
  // RANGE PADDING
  // ==========================================================================

  /// Range padding strategy.
  ///
  /// Controls how much extra space is added around the data range:
  ///
  /// - [AxisRangePadding.none] - No padding, use exact data range
  /// - [AxisRangePadding.normal] - Add 5% padding on each side
  /// - [AxisRangePadding.round] - Round to nice numbers
  /// - [AxisRangePadding.additional] - Add 10% padding on each side
  /// - [AxisRangePadding.auto] - Automatically choose best padding
  ///
  /// Default: [AxisRangePadding.auto]
  final AxisRangePadding rangePadding;

  // ==========================================================================
  // INVERSION (Override from base)
  // ==========================================================================

  final bool _isInversed;

  @override
  bool get isInversed => _isInversed;

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  @override
  FusionNumericAxis copyWith({
    String? name,
    String? title,
    TextStyle? titleStyle,
    bool? opposedPosition,
    bool? isInversed,
    double? min,
    double? max,
    double? interval,
    int? desiredIntervals,
    String Function(double)? labelFormatter,
    LabelAlignment? labelAlignment,
    int? decimalPlaces,
    bool? useScientificNotation,
    AxisRangePadding? rangePadding,
  }) {
    return FusionNumericAxis(
      name: name ?? this.name,
      title: title ?? this.title,
      titleStyle: titleStyle ?? this.titleStyle,
      opposedPosition: opposedPosition ?? this.opposedPosition,
      isInversed: isInversed ?? this.isInversed,
      min: min ?? this.min,
      max: max ?? this.max,
      interval: interval ?? this.interval,
      desiredIntervals: desiredIntervals ?? this.desiredIntervals,
      labelFormatter: labelFormatter ?? this.labelFormatter,
      labelAlignment: labelAlignment ?? this.labelAlignment,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      useScientificNotation: useScientificNotation ?? this.useScientificNotation,
      rangePadding: rangePadding ?? this.rangePadding,
    );
  }

  // ==========================================================================
  // EQUALITY & HASH
  // ==========================================================================

  @override
  String toString() {
    return 'FusionNumericAxis('
        'min: $min, '
        'max: $max, '
        'interval: $interval, '
        'desiredIntervals: $desiredIntervals, '
        'rangePadding: $rangePadding'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionNumericAxis &&
        other.name == name &&
        other.title == title &&
        other.opposedPosition == opposedPosition &&
        other.isInversed == isInversed &&
        other.min == min &&
        other.max == max &&
        other.interval == interval &&
        other.desiredIntervals == desiredIntervals &&
        other.decimalPlaces == decimalPlaces &&
        other.useScientificNotation == useScientificNotation &&
        other.rangePadding == rangePadding;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      title,
      opposedPosition,
      isInversed,
      min,
      max,
      interval,
      desiredIntervals,
      decimalPlaces,
      useScientificNotation,
      rangePadding,
    );
  }
}

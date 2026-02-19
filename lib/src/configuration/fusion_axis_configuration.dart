import 'package:flutter/material.dart';

import '../core/axis/base/fusion_axis_base.dart';
import '../core/enums/axis_position.dart';
import '../core/enums/label_alignment.dart';
import '../core/models/axis_bounds.dart';

/// Configuration for a chart axis.
///
/// This class contains all configuration options for customizing
/// an axis in Fusion Charts, including labels, ticks, grid lines, and more.
///
/// ## Example
///
/// ```dart
/// // Auto-calculated axis (most common)
/// FusionAxisConfiguration(
///   autoRange: true,
///   autoInterval: true,
///   desiredTickCount: 5,
/// )
///
/// // Manual axis
/// FusionAxisConfiguration(
///   min: 0,
///   max: 100,
///   interval: 20,
/// )
/// ```
class FusionAxisConfiguration {
  const FusionAxisConfiguration({
    this.axisType,
    this.min,
    this.max,
    this.interval,
    this.title,
    this.labelFormatter,
    this.labelStyle,
    this.labelRotation,
    this.labelAlignment = LabelAlignment.center,
    this.visible = true,
    this.autoRange = true,
    this.autoInterval = true,
    this.includeZero,
    this.desiredTickCount = 5,
    this.desiredIntervals = 5,
    this.useAbbreviation = true,
    this.useScientificNotation = false,
    this.showGrid = true,
    this.showMinorGrid = false,
    this.showMinorTicks = false,
    this.showTicks = false,
    this.showLabels = true,
    this.showAxisLine = true,
    this.position,
    this.majorTickColor,
    this.majorTickWidth,
    this.majorTickLength,
    this.minorTickColor,
    this.minorTickWidth,
    this.minorTickLength,
    this.majorGridColor,
    this.majorGridWidth,
    this.minorGridColor,
    this.minorGridWidth,
    this.axisLineColor,
    this.axisLineWidth,
    this.rangePadding,
    this.labelGenerator,
  });

  // ==========================================================================
  // AXIS TYPE
  // ==========================================================================

  /// The axis type definition.
  ///
  /// Determines how data is interpreted and displayed on this axis:
  /// - [FusionNumericAxis] - Continuous numeric values (default)
  /// - [FusionCategoryAxis] - Discrete string categories
  /// - [FusionDateTimeAxis] - Time-series data with smart date formatting
  ///
  /// If null, defaults to [FusionNumericAxis].
  ///
  /// ## Example
  ///
  /// ```dart
  /// // DateTime axis for time series
  /// FusionAxisConfiguration(
  ///   axisType: FusionDateTimeAxis(
  ///     min: DateTime(2024, 1, 1),
  ///     max: DateTime(2024, 12, 31),
  ///     dateFormat: DateFormat('MMM yyyy'),
  ///   ),
  /// )
  ///
  /// // Category axis for bar charts
  /// FusionAxisConfiguration(
  ///   axisType: FusionCategoryAxis(
  ///     categories: ['Q1', 'Q2', 'Q3', 'Q4'],
  ///   ),
  /// )
  /// ```
  final FusionAxisBase? axisType;

  // ==========================================================================
  // RANGE PROPERTIES
  // ==========================================================================

  /// Minimum value of the axis.
  ///
  /// If null and [autoRange] is true, will be calculated from data.
  final double? min;

  /// Maximum value of the axis.
  ///
  /// If null and [autoRange] is true, will be calculated from data.
  final double? max;

  /// Interval between axis labels.
  ///
  /// If null and [autoInterval] is true, will be calculated automatically.
  final double? interval;

  /// Whether to automatically calculate axis range from data.
  ///
  /// When true, [min] and [max] are calculated from data values.
  /// When false, you should provide explicit [min] and [max].
  final bool autoRange;

  /// Whether to automatically calculate axis interval.
  ///
  /// When true, [interval] is calculated to create nice, readable labels.
  /// When false, you should provide explicit [interval].
  final bool autoInterval;

  /// Whether to include zero in the range.
  ///
  /// Useful for bar charts where you want to show the baseline.
  /// Ignored if [min] is explicitly set.
  final bool? includeZero;

  /// Desired number of ticks on the axis.
  ///
  /// Used when [autoInterval] is true to calculate optimal interval.
  /// Actual tick count may differ slightly to achieve "nice" numbers.
  final int desiredTickCount;

  /// Desired number of intervals (same as desiredTickCount).
  ///
  /// This is an alias for [desiredTickCount] for consistency with
  /// other chart libraries. Both properties do the same thing.
  final int desiredIntervals;

  /// Range padding as a fraction (0.0 to 1.0).
  ///
  /// Adds extra space at the edges of the axis.
  /// For example, 0.05 = 5% padding on each side.
  ///
  /// If null, padding is determined automatically based on data.
  final double? rangePadding;

  // ==========================================================================
  // LABEL GENERATION
  // ==========================================================================

  /// Custom label position generator.
  ///
  /// When provided, this callback completely overrides the automatic label
  /// generation. The callback receives axis bounds and sizing information,
  /// and should return a list of values where labels should appear.
  ///
  /// This is the "escape hatch" for complete control over label positioning.
  /// For common patterns, consider using [labelStrategy] instead (v1.1+).
  ///
  /// ## Parameters
  ///
  /// - [bounds]: The calculated axis bounds (min, max, interval)
  /// - [availableSize]: Pixels available for the axis (width or height)
  /// - [isVertical]: Whether this is a vertical (Y) or horizontal (X) axis
  ///
  /// ## Returns
  ///
  /// List of numeric values where labels should be placed.
  /// Values outside the axis range will be ignored.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Fibonacci-spaced labels
  /// FusionAxisConfiguration(
  ///   labelGenerator: (bounds, availableSize, isVertical) {
  ///     final fibs = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89];
  ///     return fibs
  ///         .where((f) => f >= bounds.min && f <= bounds.max)
  ///         .map((f) => f.toDouble())
  ///         .toList();
  ///   },
  /// )
  ///
  /// // Powers of 10 (log-scale style)
  /// FusionAxisConfiguration(
  ///   labelGenerator: (bounds, availableSize, isVertical) {
  ///     final labels = <double>[];
  ///     var value = 1.0;
  ///     while (value <= bounds.max) {
  ///       if (value >= bounds.min) labels.add(value);
  ///       value *= 10;
  ///     }
  ///     return labels;
  ///   },
  /// )
  ///
  /// // Edge-inclusive (first and last data points)
  /// FusionAxisConfiguration(
  ///   labelGenerator: (bounds, availableSize, isVertical) {
  ///     return [
  ///       bounds.min,
  ///       bounds.min + bounds.range * 0.25,
  ///       bounds.min + bounds.range * 0.5,
  ///       bounds.min + bounds.range * 0.75,
  ///       bounds.max,
  ///     ];
  ///   },
  /// )
  /// ```
  ///
  /// ## Note
  ///
  /// When [labelGenerator] is provided:
  /// - [interval] is ignored for label positioning (but still used for grid lines)
  /// - [desiredIntervals] is ignored
  /// - [labelFormatter] is still applied to format the label text
  final List<double> Function(
    AxisBounds bounds,
    double availableSize,
    bool isVertical,
  )?
  labelGenerator;

  // ==========================================================================
  // LABEL PROPERTIES
  // ==========================================================================

  /// Axis title text.
  final String? title;

  /// Custom formatter for axis labels.
  ///
  /// If provided, this function will be called for each label value
  /// to format it as a string.
  ///
  /// Example:
  /// ```dart
  /// labelFormatter: (value) => '\$${value.toStringAsFixed(2)}'
  /// ```
  final String Function(double value)? labelFormatter;

  /// Style for axis labels.
  final TextStyle? labelStyle;

  /// Label rotation angle in degrees.
  ///
  /// Positive values rotate clockwise.
  /// Useful for long labels that might overlap.
  final double? labelRotation;

  /// Label alignment relative to tick position.
  final LabelAlignment labelAlignment;

  /// Whether to use abbreviations for large numbers (K, M, B).
  ///
  /// When true:
  /// - 1,000 → 1K
  /// - 1,000,000 → 1M
  /// - 1,000,000,000 → 1B
  final bool useAbbreviation;

  /// Whether to use scientific notation for very large/small numbers.
  ///
  /// When true, numbers like 0.00001 become 1e-5.
  final bool useScientificNotation;

  // ==========================================================================
  // VISIBILITY PROPERTIES
  // ==========================================================================

  /// Whether to show axis.
  final bool visible;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Whether to show minor grid lines.
  final bool showMinorGrid;

  /// Whether to show minor tick marks.
  final bool showMinorTicks;

  /// Whether to show major tick marks.
  final bool showTicks;

  /// Wheater to show axis labels;
  final bool showLabels;

  /// Whether to show axis line
  final bool showAxisLine;

  /// Position of the axis.
  final AxisPosition? position;

  // ==========================================================================
  // STYLING PROPERTIES
  // ==========================================================================

  /// Major tick color.
  final Color? majorTickColor;

  /// Major tick width.
  final double? majorTickWidth;

  /// Major tick length.
  final double? majorTickLength;

  /// Minor tick color.
  final Color? minorTickColor;

  /// Minor tick width.
  final double? minorTickWidth;

  /// Minor tick length.
  final double? minorTickLength;

  /// Major grid color.
  final Color? majorGridColor;

  /// Major grid width.
  final double? majorGridWidth;

  /// Minor grid color.
  final Color? minorGridColor;

  /// Minor grid width.
  final double? minorGridWidth;

  /// Axis line color.
  final Color? axisLineColor;

  /// Axis line width.
  final double? axisLineWidth;

  // ==========================================================================
  // COMPUTED PROPERTIES (NEW - FIXES ANALYZER ERRORS)
  // ==========================================================================

  /// Gets the effective position for this axis.
  ///
  /// Returns [position] if set, otherwise returns default based on orientation.
  AxisPosition getEffectivePosition({required bool isVertical}) {
    if (position != null) {
      return position!;
    }
    return isVertical
        ? AxisPosition.defaultVertical
        : AxisPosition.defaultHorizontal;
  }

  /// Gets the effective minimum value for the axis.
  ///
  /// Returns:
  /// - [min] if explicitly set by user
  /// - 0.0 if [autoRange] is true and no data provided (safe default)
  /// - 0.0 as fallback
  ///
  /// Used by chart painters to initialize data bounds.
  double get effectiveMin {
    if (min != null) {
      return min!;
    }

    // Safe default for auto-range mode
    // (actual value will be calculated from data)
    return 0.0;
  }

  /// Gets the effective maximum value for the axis.
  ///
  /// Returns:
  /// - [max] if explicitly set by user
  /// - 10.0 if [autoRange] is true and no data provided (safe default)
  /// - 10.0 as fallback
  ///
  /// Used by chart painters to initialize data bounds.
  double get effectiveMax {
    if (max != null) {
      return max!;
    }

    // Safe default for auto-range mode
    // (actual value will be calculated from data)
    return 10.0;
  }

  /// Gets the effective interval for the axis.
  ///
  /// Returns:
  /// - [interval] if explicitly set by user
  /// - 1.0 as safe default (will be recalculated by axis renderer)
  ///
  /// This is a temporary default; the axis renderer will calculate
  /// the optimal interval based on the actual data range.
  double get effectiveInterval {
    if (interval != null) {
      return interval!;
    }

    // Default interval (will be recalculated)
    return 1.0;
  }

  /// Checks if the axis has explicit bounds set by user.
  ///
  /// Returns true only if BOTH [min] and [max] are explicitly set.
  /// Used to determine if axis renderer needs to calculate bounds from data.
  bool get hasExplicitBounds => min != null && max != null;

  /// Checks if the axis has explicit interval set by user.
  ///
  /// Returns true if [interval] is explicitly set.
  /// Used to determine if axis renderer needs to calculate optimal interval.
  bool get hasExplicitInterval => interval != null;

  /// Checks if the axis should auto-calculate everything.
  ///
  /// Returns true if both range and interval should be calculated automatically.
  /// This is the most common configuration for flexible charts.
  bool get isFullyAutomatic => autoRange && autoInterval;

  /// Checks if the axis has any auto-calculation enabled.
  bool get hasAnyAutomatic => autoRange || autoInterval;

  // ==========================================================================
  // VALIDATION METHODS
  // ==========================================================================

  /// Validates that the axis configuration is valid.
  ///
  /// Returns true if configuration is valid, false otherwise.
  /// Checks for common configuration errors.
  bool validate() {
    // Check min < max
    if (min != null && max != null && min! >= max!) {
      return false; // Invalid: min must be less than max
    }

    // Check interval is positive
    if (interval != null && interval! <= 0) {
      return false; // Invalid: interval must be positive
    }

    // Check desired intervals is positive
    if (desiredIntervals <= 0) {
      return false; // Invalid: desiredIntervals must be positive
    }

    // Check desired tick count is positive
    if (desiredTickCount <= 0) {
      return false; // Invalid: desiredTickCount must be positive
    }

    // Check range padding is valid
    if (rangePadding != null && (rangePadding! < 0 || rangePadding! > 1)) {
      return false; // Invalid: rangePadding must be between 0 and 1
    }

    return true;
  }

  /// Gets a descriptive error message if configuration is invalid.
  ///
  /// Returns null if configuration is valid.
  String? getValidationError() {
    if (min != null && max != null && min! >= max!) {
      return 'Axis min ($min) must be less than max ($max)';
    }

    if (interval != null && interval! <= 0) {
      return 'Axis interval ($interval) must be positive';
    }

    if (desiredIntervals <= 0) {
      return 'desiredIntervals ($desiredIntervals) must be positive';
    }

    if (desiredTickCount <= 0) {
      return 'desiredTickCount ($desiredTickCount) must be positive';
    }

    if (rangePadding != null && (rangePadding! < 0 || rangePadding! > 1)) {
      return 'rangePadding ($rangePadding) must be between 0 and 1';
    }

    return null;
  }

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  /// Creates a copy of this configuration with modified values.
  FusionAxisConfiguration copyWith({
    FusionAxisBase? axisType,
    double? min,
    double? max,
    double? interval,
    String? title,
    String Function(double value)? labelFormatter,
    TextStyle? labelStyle,
    double? labelRotation,
    LabelAlignment? labelAlignment,
    bool? visible,
    bool? autoRange,
    bool? autoInterval,
    bool? includeZero,
    int? desiredTickCount,
    int? desiredIntervals,
    bool? useAbbreviation,
    bool? useScientificNotation,
    bool? showGrid,
    bool? showMinorGrid,
    bool? showMinorTicks,
    bool? showTicks,
    bool? showLabels,
    bool? showAxisLine,
    AxisPosition? position,
    Color? majorTickColor,
    double? majorTickWidth,
    double? majorTickLength,
    Color? minorTickColor,
    double? minorTickWidth,
    double? minorTickLength,
    Color? majorGridColor,
    double? majorGridWidth,
    Color? minorGridColor,
    double? minorGridWidth,
    Color? axisLineColor,
    double? axisLineWidth,
    double? rangePadding,
    List<double> Function(AxisBounds, double, bool)? labelGenerator,
  }) {
    return FusionAxisConfiguration(
      axisType: axisType ?? this.axisType,
      min: min ?? this.min,
      max: max ?? this.max,
      interval: interval ?? this.interval,
      title: title ?? this.title,
      labelFormatter: labelFormatter ?? this.labelFormatter,
      labelStyle: labelStyle ?? this.labelStyle,
      labelRotation: labelRotation ?? this.labelRotation,
      labelAlignment: labelAlignment ?? this.labelAlignment,
      visible: visible ?? this.visible,
      autoRange: autoRange ?? this.autoRange,
      autoInterval: autoInterval ?? this.autoInterval,
      includeZero: includeZero ?? this.includeZero,
      desiredTickCount: desiredTickCount ?? this.desiredTickCount,
      desiredIntervals: desiredIntervals ?? this.desiredIntervals,
      useAbbreviation: useAbbreviation ?? this.useAbbreviation,
      useScientificNotation:
          useScientificNotation ?? this.useScientificNotation,
      showGrid: showGrid ?? this.showGrid,
      showMinorGrid: showMinorGrid ?? this.showMinorGrid,
      showMinorTicks: showMinorTicks ?? this.showMinorTicks,
      showTicks: showTicks ?? this.showTicks,
      showLabels: showLabels ?? this.showLabels,
      showAxisLine: showAxisLine ?? this.showAxisLine,
      position: position ?? this.position,
      majorTickColor: majorTickColor ?? this.majorTickColor,
      majorTickWidth: majorTickWidth ?? this.majorTickWidth,
      majorTickLength: majorTickLength ?? this.majorTickLength,
      minorTickColor: minorTickColor ?? this.minorTickColor,
      minorTickWidth: minorTickWidth ?? this.minorTickWidth,
      minorTickLength: minorTickLength ?? this.minorTickLength,
      majorGridColor: majorGridColor ?? this.majorGridColor,
      majorGridWidth: majorGridWidth ?? this.majorGridWidth,
      minorGridColor: minorGridColor ?? this.minorGridColor,
      minorGridWidth: minorGridWidth ?? this.minorGridWidth,
      axisLineColor: axisLineColor ?? this.axisLineColor,
      axisLineWidth: axisLineWidth ?? this.axisLineWidth,
      rangePadding: rangePadding ?? this.rangePadding,
      labelGenerator: labelGenerator ?? this.labelGenerator,
    );
  }

  // ==========================================================================
  // TO STRING
  // ==========================================================================

  @override
  String toString() {
    return 'FusionAxisConfiguration('
        'axisType: ${axisType?.runtimeType ?? "auto"}, '
        'min: $min, '
        'max: $max, '
        'interval: $interval, '
        'autoRange: $autoRange, '
        'autoInterval: $autoInterval, '
        'desiredIntervals: $desiredIntervals'
        ')';
  }

  /// Checks if a custom label generator is configured.
  bool get hasLabelGenerator => labelGenerator != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionAxisConfiguration &&
        other.axisType == axisType &&
        other.min == min &&
        other.max == max &&
        other.interval == interval &&
        other.title == title &&
        other.visible == visible &&
        other.autoRange == autoRange &&
        other.autoInterval == autoInterval &&
        other.position == position &&
        other.desiredIntervals == desiredIntervals &&
        other.labelGenerator == labelGenerator;
  }

  @override
  int get hashCode {
    return Object.hash(
      axisType,
      min,
      max,
      interval,
      title,
      visible,
      autoRange,
      autoInterval,
      position,
      desiredIntervals,
      labelGenerator,
    );
  }
}

// =============================================================================
// BUILDER (Optional - for fluent API)
// =============================================================================

/// Builder for creating [FusionAxisConfiguration] with a fluent API.
///
/// Example:
/// ```dart
/// final config = FusionAxisConfigurationBuilder()
///   .withRange(0, 100)
///   .withInterval(20)
///   .withTitle('Revenue')
///   .build();
/// ```
class FusionAxisConfigurationBuilder {
  double? _min;
  double? _max;
  double? _interval;
  String? _title;
  bool _autoRange = true;
  bool _autoInterval = true;
  int _desiredIntervals = 5;

  /// Sets the axis range.
  FusionAxisConfigurationBuilder withRange(double min, double max) {
    _min = min;
    _max = max;
    _autoRange = false;
    return this;
  }

  /// Sets the axis interval.
  FusionAxisConfigurationBuilder withInterval(double interval) {
    _interval = interval;
    _autoInterval = false;
    return this;
  }

  /// Sets the axis title.
  FusionAxisConfigurationBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  /// Enables auto-range calculation.
  FusionAxisConfigurationBuilder withAutoRange([int desiredIntervals = 5]) {
    _autoRange = true;
    _autoInterval = true;
    _desiredIntervals = desiredIntervals;
    return this;
  }

  /// Builds the configuration.
  FusionAxisConfiguration build() {
    return FusionAxisConfiguration(
      min: _min,
      max: _max,
      interval: _interval,
      title: _title,
      autoRange: _autoRange,
      autoInterval: _autoInterval,
      desiredIntervals: _desiredIntervals,
    );
  }
}

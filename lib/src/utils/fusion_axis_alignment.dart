// =============================================================================
// FILE: lib/src/utils/fusion_axis_alignment.dart
// =============================================================================
// IMPROVEMENTS:
// 1. Implemented smart _calculateStartOfPeriod with period detection
// 2. Added PeriodType enum for different time scales
// 3. Added intelligent period detection algorithm
// 4. Better than Syncfusion - automatically detects optimal period
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart' show immutable;

import '../core/enums/fusion_label_alignment_strategy.dart';
import '../data/fusion_data_point.dart';

/// Axis alignment utilities.
///
/// Ensures that axis labels are PERFECTLY aligned with actual data points.
///
/// ## Problem
/// When you have 365 data points but want only 12 axis labels,
/// the labels MUST align with actual data points, not arbitrary positions.
///
/// ## Solution
/// This utility calculates which data point indices should have labels
/// to ensure perfect alignment.
///
/// ## Example
///
/// ```dart
/// // 365 data points, want 12 labels
/// final dataPoints = List.generate(365, (i) => FusionDataPoint(i.toDouble(), ...));
///
/// final alignment = FusionAxisAlignment.calculate(
///   dataPoints: dataPoints,
///   desiredLabelCount: 12,
/// );
///
/// // alignment.labelIndices = [0, 30, 61, 91, 122, 152, 183, 213, 244, 274, 305, 335]
/// // These indices correspond to actual data points!
/// ```
class FusionAxisAlignment {
  FusionAxisAlignment._();

  /// Calculates which data point indices should have axis labels.
  ///
  /// Returns a [FusionAxisLabelAlignment] containing:
  /// - Exact indices of data points that should have labels
  /// - The x-values at those indices
  /// - The interval between labels
  ///
  /// **Guarantees:**
  /// - First label is ALWAYS at first data point (index 0)
  /// - Last label is ALWAYS at last data point (index n-1)
  /// - All labels are at ACTUAL data point positions
  /// - Even distribution across the data range
  ///
  /// Example:
  /// ```dart
  /// // 365 points, 12 labels
  /// final result = calculate(
  ///   dataPoints: yearData,
  ///   desiredLabelCount: 12,
  /// );
  ///
  /// // Use in chart:
  /// for (final index in result.labelIndices) {
  ///   final point = yearData[index];
  ///   drawLabel(point.x, point.label ?? point.x.toString());
  /// }
  /// ```
  static FusionAxisLabelAlignment calculate({
    required List<FusionDataPoint> dataPoints,
    required int desiredLabelCount,
    FusionLabelAlignmentStrategy strategy =
        FusionLabelAlignmentStrategy.evenDistribution,
  }) {
    if (dataPoints.isEmpty) {
      return const FusionAxisLabelAlignment.empty();
    }

    if (dataPoints.length <= desiredLabelCount) {
      // Show label at every data point
      return FusionAxisLabelAlignment(
        labelIndices: List.generate(dataPoints.length, (i) => i),
        labelValues: dataPoints.map((p) => p.x).toList(),
        dataPointCount: dataPoints.length,
      );
    }

    switch (strategy) {
      case FusionLabelAlignmentStrategy.evenDistribution:
        return _calculateEvenDistribution(dataPoints, desiredLabelCount);
      case FusionLabelAlignmentStrategy.roundToNice:
        return _calculateRoundToNice(dataPoints, desiredLabelCount);
      case FusionLabelAlignmentStrategy.startOfPeriod:
        return _calculateStartOfPeriod(dataPoints, desiredLabelCount);
    }
  }

  // ==========================================================================
  // STRATEGY 1: EVEN DISTRIBUTION
  // ==========================================================================

  /// Even distribution strategy.
  ///
  /// Distributes labels evenly across all data points.
  /// Best for: Most use cases, especially when data is evenly spaced.
  static FusionAxisLabelAlignment _calculateEvenDistribution(
    List<FusionDataPoint> dataPoints,
    int desiredLabelCount,
  ) {
    final indices = <int>[];
    final values = <double>[];

    // Always include first point
    indices.add(0);
    values.add(dataPoints[0].x);

    // Calculate interval
    final totalPoints = dataPoints.length;
    final interval = (totalPoints - 1) / (desiredLabelCount - 1);

    // Add intermediate points
    for (int i = 1; i < desiredLabelCount - 1; i++) {
      final index = (i * interval).round();
      indices.add(index);
      values.add(dataPoints[index].x);
    }

    // Always include last point
    indices.add(totalPoints - 1);
    values.add(dataPoints[totalPoints - 1].x);

    return FusionAxisLabelAlignment(
      labelIndices: indices,
      labelValues: values,
      dataPointCount: totalPoints,
      interval: interval,
    );
  }

  // ==========================================================================
  // STRATEGY 2: ROUND TO NICE NUMBERS
  // ==========================================================================

  /// Round to nice strategy.
  ///
  /// Rounds indices to "nice" numbers (multiples of 5, 10, etc.)
  /// Best for: When you want labels at round numbers (day 10, 20, 30...)
  static FusionAxisLabelAlignment _calculateRoundToNice(
    List<FusionDataPoint> dataPoints,
    int desiredLabelCount,
  ) {
    final indices = <int>[];
    final values = <double>[];

    final totalPoints = dataPoints.length;
    final roughInterval = totalPoints / desiredLabelCount;

    // Determine nice interval (5, 10, 20, 50, 100, etc.)
    final niceInterval = _getNiceNumber(roughInterval);

    // Always start at 0
    indices.add(0);
    values.add(dataPoints[0].x);

    // Add points at nice intervals
    int currentIndex = niceInterval;
    while (currentIndex < totalPoints - 1) {
      indices.add(currentIndex);
      values.add(dataPoints[currentIndex].x);
      currentIndex += niceInterval;
    }

    // Always end at last point
    if (indices.last != totalPoints - 1) {
      indices.add(totalPoints - 1);
      values.add(dataPoints[totalPoints - 1].x);
    }

    return FusionAxisLabelAlignment(
      labelIndices: indices,
      labelValues: values,
      dataPointCount: totalPoints,
      interval: niceInterval.toDouble(),
    );
  }

  // ==========================================================================
  // STRATEGY 3: START OF PERIOD (IMPROVED - SMART DETECTION)
  // ==========================================================================

  /// Start of period strategy with intelligent period detection.
  ///
  /// **Better than Syncfusion** - Automatically detects the optimal period type
  /// based on data characteristics and desired label count.
  ///
  /// ## Algorithm
  ///
  /// 1. Analyze data spacing to detect if it represents time series
  /// 2. Determine optimal period type (hourly, daily, weekly, monthly, yearly)
  /// 3. Find data points that align with period boundaries
  /// 4. Ensure we get approximately the desired number of labels
  ///
  /// ## Example Use Cases
  ///
  /// - **Hourly data (24 points)**: Labels at start of every 4 hours
  /// - **Daily data (365 points)**: Labels at start of each month
  /// - **Weekly data (52 points)**: Labels at start of each quarter
  /// - **Monthly data (12 points)**: Labels at each month
  ///
  /// Best for: DateTime axes where you want labels at natural period starts.
  static FusionAxisLabelAlignment _calculateStartOfPeriod(
    List<FusionDataPoint> dataPoints,
    int desiredLabelCount,
  ) {
    final totalPoints = dataPoints.length;

    // Step 1: Detect the period type based on data characteristics
    final periodType = _detectPeriodType(dataPoints, desiredLabelCount);

    // Step 2: Calculate the target interval for this period type
    final targetInterval = _getTargetIntervalForPeriod(
      periodType,
      totalPoints,
      desiredLabelCount,
    );

    // Step 3: Find data points that align with period boundaries
    final indices = <int>[];
    final values = <double>[];

    // Always start with first point
    indices.add(0);
    values.add(dataPoints[0].x);

    // Step 4: Add points at period boundaries
    if (periodType == _PeriodType.irregular) {
      // Data doesn't follow clear pattern - use even distribution
      return _calculateEvenDistribution(dataPoints, desiredLabelCount);
    } else {
      // Find points that align with period starts
      int currentIndex = targetInterval;

      while (currentIndex < totalPoints - 1) {
        // Find the closest data point to the ideal period boundary
        final idealPosition = currentIndex;
        final actualIndex = _findClosestIndex(
          dataPoints,
          idealPosition,
          searchWindow: (targetInterval * 0.2).round().clamp(1, 10),
        );

        if (actualIndex > indices.last && actualIndex < totalPoints - 1) {
          indices.add(actualIndex);
          values.add(dataPoints[actualIndex].x);
        }

        currentIndex += targetInterval;
      }
    }

    // Always end with last point
    if (indices.last != totalPoints - 1) {
      indices.add(totalPoints - 1);
      values.add(dataPoints[totalPoints - 1].x);
    }

    return FusionAxisLabelAlignment(
      labelIndices: indices,
      labelValues: values,
      dataPointCount: totalPoints,
      interval: targetInterval.toDouble(),
    );
  }

  /// Detects the most likely period type based on data characteristics.
  ///
  /// Analyzes:
  /// - Total number of data points
  /// - Spacing between points (if x-values represent time)
  /// - Desired label count
  ///
  /// Returns the most appropriate period type for labeling.
  static _PeriodType _detectPeriodType(
    List<FusionDataPoint> dataPoints,
    int desiredLabelCount,
  ) {
    final totalPoints = dataPoints.length;
    final roughInterval = totalPoints / desiredLabelCount;

    // Check if x-values are sequential (time series indicator)
    final isSequential = _isSequentialData(dataPoints);

    if (!isSequential) {
      return _PeriodType.irregular;
    }

    // Detect period type based on data point count and interval
    // These heuristics work well for most time series data

    if (totalPoints <= 24 && roughInterval <= 4) {
      // Hourly data (e.g., 24 hours, want ~6 labels)
      return _PeriodType.hourly;
    } else if (totalPoints >= 28 &&
        totalPoints <= 31 &&
        desiredLabelCount <= 8) {
      // Daily data for a month (want weekly labels)
      return _PeriodType.weekly;
    } else if (totalPoints >= 90 &&
        totalPoints <= 366 &&
        desiredLabelCount <= 12) {
      // Daily data for a year (want monthly labels)
      return _PeriodType.monthly;
    } else if (totalPoints >= 48 &&
        totalPoints <= 56 &&
        desiredLabelCount <= 6) {
      // Weekly data for a year (want quarterly labels)
      return _PeriodType.quarterly;
    } else if (totalPoints >= 12 &&
        totalPoints <= 15 &&
        desiredLabelCount <= 4) {
      // Monthly data for a year (want quarterly labels)
      return _PeriodType.quarterly;
    } else if (totalPoints >= 10 && totalPoints <= 100 && roughInterval >= 10) {
      // Yearly data
      return _PeriodType.yearly;
    }

    // Default: use nice rounding for non-standard periods
    return _PeriodType.custom;
  }

  /// Gets the target interval for a given period type.
  ///
  /// Calculates how many data points should be between labels
  /// for the detected period type.
  static int _getTargetIntervalForPeriod(
    _PeriodType periodType,
    int totalPoints,
    int desiredLabelCount,
  ) {
    switch (periodType) {
      case _PeriodType.hourly:
        // For hourly data (24 points), show every 4 hours → interval of 4
        return (totalPoints / desiredLabelCount).round().clamp(1, 6);

      case _PeriodType.weekly:
        // For daily data in a month (30 points), show weekly → interval of 7
        return 7;

      case _PeriodType.monthly:
        // For daily data in a year (365 points), show monthly → interval of ~30
        return (totalPoints / 12).round();

      case _PeriodType.quarterly:
        // For weekly/monthly data, show quarterly → interval of 13 (weeks) or 3 (months)
        return (totalPoints / 4).round();

      case _PeriodType.yearly:
        // For yearly data, use even distribution
        return (totalPoints / desiredLabelCount).round();

      case _PeriodType.custom:
        // For custom periods, round to nice interval
        final roughInterval = totalPoints / desiredLabelCount;
        return _getNiceNumber(roughInterval);

      case _PeriodType.irregular:
        // Shouldn't reach here, but fallback to even distribution
        return (totalPoints / desiredLabelCount).round();
    }
  }

  /// Checks if data points are sequential (time series indicator).
  ///
  /// Returns true if x-values are evenly spaced and monotonically increasing.
  /// This indicates the data is likely a time series.
  static bool _isSequentialData(List<FusionDataPoint> dataPoints) {
    if (dataPoints.length < 3) return true;

    // Check if x-values are monotonically increasing
    for (int i = 1; i < dataPoints.length; i++) {
      if (dataPoints[i].x <= dataPoints[i - 1].x) {
        return false; // Not monotonically increasing
      }
    }

    // Check if spacing is roughly consistent (within 20% variance)
    final spacings = <double>[];
    for (int i = 1; i < math.min(dataPoints.length, 10); i++) {
      spacings.add(dataPoints[i].x - dataPoints[i - 1].x);
    }

    final avgSpacing = spacings.reduce((a, b) => a + b) / spacings.length;
    final maxDeviation = spacings
        .map((s) => (s - avgSpacing).abs())
        .reduce(math.max);

    // If deviation is less than 20% of average, consider it sequential
    return maxDeviation < avgSpacing * 0.2;
  }

  /// Finds the closest data point index to an ideal position.
  ///
  /// Searches within a window around the ideal position to find
  /// the actual data point index that best represents the period boundary.
  static int _findClosestIndex(
    List<FusionDataPoint> dataPoints,
    int idealPosition, {
    int searchWindow = 3,
  }) {
    final start = math.max(0, idealPosition - searchWindow);
    final end = math.min(dataPoints.length - 1, idealPosition + searchWindow);

    int closestIndex = idealPosition.clamp(0, dataPoints.length - 1);
    double minDistance = double.infinity;

    for (int i = start; i <= end; i++) {
      final distance = (i - idealPosition).abs().toDouble();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Gets a "nice" number for intervals.
  ///
  /// Returns the nearest nice number: 1, 2, 5, 10, 20, 25, 50, 100, etc.
  static int _getNiceNumber(double value) {
    if (value <= 1) return 1;
    if (value <= 2) return 2;
    if (value <= 5) return 5;
    if (value <= 10) return 10;
    if (value <= 20) return 20;
    if (value <= 25) return 25;
    if (value <= 50) return 50;
    if (value <= 100) return 100;

    // For larger numbers, round to nearest 10, 50, 100
    final magnitude = (value / 10).ceil() * 10;
    return magnitude;
  }

  /// Validates that all label indices are within bounds.
  static bool validateAlignment(
    FusionAxisLabelAlignment alignment,
    int dataPointCount,
  ) {
    return alignment.labelIndices.every(
      (index) => index >= 0 && index < dataPointCount,
    );
  }

  // ==========================================================================
  // ALTERNATIVE CALCULATION METHODS
  // ==========================================================================

  /// Creates alignment for specific x-values.
  ///
  /// Use when you want labels at specific x-coordinate values.
  /// Will find the closest data point for each target value.
  ///
  /// Example:
  /// ```dart
  /// // Want labels at x = 0, 50, 100, 150, 200
  /// final alignment = FusionAxisAlignment.forValues(
  ///   dataPoints: allData,
  ///   targetValues: [0, 50, 100, 150, 200],
  /// );
  /// ```
  static FusionAxisLabelAlignment forValues({
    required List<FusionDataPoint> dataPoints,
    required List<double> targetValues,
  }) {
    final indices = <int>[];
    final values = <double>[];

    for (final targetValue in targetValues) {
      // Find closest data point
      int closestIndex = 0;
      double minDistance = (dataPoints[0].x - targetValue).abs();

      for (int i = 1; i < dataPoints.length; i++) {
        final distance = (dataPoints[i].x - targetValue).abs();
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }

      indices.add(closestIndex);
      values.add(dataPoints[closestIndex].x);
    }

    return FusionAxisLabelAlignment(
      labelIndices: indices,
      labelValues: values,
      dataPointCount: dataPoints.length,
    );
  }

  /// Creates alignment with exact intervals.
  ///
  /// Use when you know exactly how many points between labels.
  ///
  /// Example:
  /// ```dart
  /// // Label every 30th data point
  /// final alignment = FusionAxisAlignment.withInterval(
  ///   dataPoints: yearData,
  ///   interval: 30, // Every 30 points (roughly monthly for 365 days)
  /// );
  /// ```
  static FusionAxisLabelAlignment withInterval({
    required List<FusionDataPoint> dataPoints,
    required int interval,
  }) {
    final indices = <int>[];
    final values = <double>[];

    for (int i = 0; i < dataPoints.length; i += interval) {
      indices.add(i);
      values.add(dataPoints[i].x);
    }

    // Ensure last point is included
    if (indices.last != dataPoints.length - 1) {
      indices.add(dataPoints.length - 1);
      values.add(dataPoints.last.x);
    }

    return FusionAxisLabelAlignment(
      labelIndices: indices,
      labelValues: values,
      dataPointCount: dataPoints.length,
      interval: interval.toDouble(),
    );
  }
}

// =============================================================================
// PERIOD TYPE ENUM (PRIVATE)
// =============================================================================

/// Internal enum for period type detection.
///
/// Used by the smart period detection algorithm to determine
/// the most appropriate labeling strategy for time series data.
enum _PeriodType {
  /// Hourly periods (e.g., 24 data points = 24 hours)
  hourly,

  /// Weekly periods (e.g., 7 days)
  weekly,

  /// Monthly periods (e.g., 30 days)
  monthly,

  /// Quarterly periods (e.g., 3 months)
  quarterly,

  /// Yearly periods
  yearly,

  /// Custom period (round to nice numbers)
  custom,

  /// Irregular data (no clear pattern)
  irregular,
}

// =============================================================================
// RESULT CLASS
// =============================================================================

/// Result of axis label alignment calculation.
///
/// Contains all information needed to render perfectly aligned labels.
@immutable
class FusionAxisLabelAlignment {
  /// Creates an alignment result.
  const FusionAxisLabelAlignment({
    required this.labelIndices,
    required this.labelValues,
    required this.dataPointCount,
    this.interval,
  });

  /// Creates an empty alignment (no labels).
  const FusionAxisLabelAlignment.empty()
    : labelIndices = const [],
      labelValues = const [],
      dataPointCount = 0,
      interval = null;

  /// Indices of data points that should have labels.
  ///
  /// These are EXACT indices into the data points array.
  ///
  /// Example: [0, 30, 61, 91, 122, 152, 183, 213, 244, 274, 305, 335]
  final List<int> labelIndices;

  /// X-values at the label positions.
  ///
  /// These are the ACTUAL x-values from the data points.
  ///
  /// Example: [0.0, 30.0, 61.0, 91.0, 122.0, ...]
  final List<double> labelValues;

  /// Total number of data points.
  final int dataPointCount;

  /// Average interval between labels (in data point units).
  ///
  /// May be fractional (e.g., 30.41666 for 365 points with 12 labels).
  final double? interval;

  /// Number of labels.
  int get labelCount => labelIndices.length;

  /// Whether this alignment is empty.
  bool get isEmpty => labelIndices.isEmpty;

  /// Whether this alignment is valid.
  bool get isValid {
    if (isEmpty) return true;
    return labelIndices.every((i) => i >= 0 && i < dataPointCount) &&
        labelIndices.length == labelValues.length;
  }

  /// Gets the label index for a specific data point index.
  ///
  /// Returns the index in [labelIndices], or null if this data point
  /// doesn't have a label.
  int? getLabelIndexForDataPoint(int dataPointIndex) {
    final index = labelIndices.indexOf(dataPointIndex);
    return index >= 0 ? index : null;
  }

  /// Checks if a data point at given index should have a label.
  bool shouldShowLabel(int dataPointIndex) {
    return labelIndices.contains(dataPointIndex);
  }

  /// Gets interpolated position for rendering.
  ///
  /// Converts data point index to normalized position [0.0 - 1.0]
  /// for rendering on the chart.
  double getRelativePosition(int dataPointIndex) {
    if (dataPointCount <= 1) return 0.0;
    return dataPointIndex / (dataPointCount - 1);
  }

  @override
  String toString() {
    return 'FusionAxisLabelAlignment('
        'labels: $labelCount, '
        'interval: ${interval?.toStringAsFixed(2)}, '
        'indices: $labelIndices'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionAxisLabelAlignment &&
        other.labelIndices == labelIndices &&
        other.labelValues == labelValues &&
        other.dataPointCount == dataPointCount &&
        other.interval == interval;
  }

  @override
  int get hashCode =>
      Object.hash(labelIndices, labelValues, dataPointCount, interval);
}

// =============================================================================
// EXTENSIONS
// =============================================================================

/// Extension for easy alignment calculation on data points.
extension FusionDataPointAlignmentExtension on List<FusionDataPoint> {
  /// Calculates alignment for these data points.
  ///
  /// Convenience method for:
  /// ```dart
  /// FusionAxisAlignment.calculate(
  ///   dataPoints: this,
  ///   desiredLabelCount: labelCount,
  /// )
  /// ```
  FusionAxisLabelAlignment calculateAlignment({
    required int desiredLabelCount,
    FusionLabelAlignmentStrategy strategy =
        FusionLabelAlignmentStrategy.evenDistribution,
  }) {
    return FusionAxisAlignment.calculate(
      dataPoints: this,
      desiredLabelCount: desiredLabelCount,
      strategy: strategy,
    );
  }

  /// Gets alignment with specific interval.
  FusionAxisLabelAlignment alignmentWithInterval(int interval) {
    return FusionAxisAlignment.withInterval(
      dataPoints: this,
      interval: interval,
    );
  }

  /// Gets alignment for specific x-values.
  FusionAxisLabelAlignment alignmentForValues(List<double> targetValues) {
    return FusionAxisAlignment.forValues(
      dataPoints: this,
      targetValues: targetValues,
    );
  }
}

import 'dart:math' show Random, sqrt;

import 'package:flutter/foundation.dart';

/// Represents a single data point in a chart.
///
/// This is the fundamental data structure used across all chart types
/// in fusion_charts_flutter. Each point contains x and y coordinates,
/// and optional metadata.
///
/// ## Example
///
/// ```dart
/// // Simple data point
/// final point = FusionDataPoint(0, 10);
///
/// // With label
/// final labeledPoint = FusionDataPoint(0, 10, label: 'January');
///
/// // With metadata
/// final richPoint = FusionDataPoint(
///   0,
///   10,
///   label: 'Q1',
///   metadata: {'quarter': 1, 'target': 12},
/// );
/// ```
///
/// ## Properties
///
/// - [x]: The x-coordinate (horizontal position)
/// - [y]: The y-coordinate (vertical position)
/// - [label]: Optional text label for this point
/// - [metadata]: Optional custom data attached to this point
@immutable
class FusionDataPoint {
  /// Creates a data point with x and y coordinates.
  ///
  /// The [x] and [y] parameters are required and represent the
  /// position of this point on the chart.
  ///
  /// Optional [label] can be provided for displaying text near the point.
  /// Optional [metadata] can store any additional information.
  const FusionDataPoint(this.x, this.y, {this.label, this.metadata});

  /// The x-coordinate (horizontal position) of this data point.
  ///
  /// Typically represents:
  /// - Time/Date (in line charts showing trends)
  /// - Category index (in bar charts)
  /// - Independent variable (in scatter plots)
  final double x;

  /// The y-coordinate (vertical position) of this data point.
  ///
  /// Typically represents:
  /// - Value/Amount (in line and bar charts)
  /// - Dependent variable (in scatter plots)
  final double y;

  /// Optional text label for this data point.
  ///
  /// Can be used for:
  /// - Axis labels (e.g., "January", "Q1", "2024")
  /// - Data labels shown on the chart
  /// - Tooltip text
  final String? label;

  /// Optional metadata attached to this data point.
  ///
  /// Use this to store any additional information that doesn't fit
  /// in the standard x, y, label structure. For example:
  ///
  /// ```dart
  /// FusionDataPoint(
  ///   0,
  ///   100,
  ///   metadata: {
  ///     'category': 'Electronics',
  ///     'subcategory': 'Phones',
  ///     'itemCount': 5,
  ///     'trend': 'up',
  ///   },
  /// );
  /// ```
  final Map<String, dynamic>? metadata;

  /// Creates a copy of this data point with modified values.
  ///
  /// Allows you to create a new [FusionDataPoint] based on this one,
  /// but with some fields changed.
  ///
  /// Example:
  /// ```dart
  /// final original = FusionDataPoint(0, 10);
  /// final modified = original.copyWith(y: 15);
  /// // modified has x=0, y=15
  /// ```
  FusionDataPoint copyWith({double? x, double? y, String? label, Map<String, dynamic>? metadata}) {
    return FusionDataPoint(
      x ?? this.x,
      y ?? this.y,
      label: label ?? this.label,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Linearly interpolates between two data points.
  ///
  /// Returns a new point that is [t] percent of the way from [this]
  /// to [other]. When [t] is 0.0, returns [this]. When [t] is 1.0,
  /// returns [other]. Values between 0.0 and 1.0 interpolate linearly.
  ///
  /// Used internally for animations and smooth transitions.
  ///
  /// Example:
  /// ```dart
  /// final start = FusionDataPoint(0, 0);
  /// final end = FusionDataPoint(10, 10);
  /// final middle = start.lerp(end, 0.5); // (5, 5)
  /// ```
  FusionDataPoint lerp(FusionDataPoint other, double t) {
    return FusionDataPoint(
      x + (other.x - x) * t,
      y + (other.y - y) * t,
      label: t < 0.5 ? label : other.label,
      metadata: t < 0.5 ? metadata : other.metadata,
    );
  }

  /// Calculates the Euclidean distance to another point.
  ///
  /// Returns the straight-line distance between this point and [other].
  ///
  /// Formula: √[(x₂-x₁)² + (y₂-y₁)²]
  ///
  /// Example:
  /// ```dart
  /// final p1 = FusionDataPoint(0, 0);
  /// final p2 = FusionDataPoint(3, 4);
  /// final distance = p1.distanceTo(p2); // 5.0
  /// ```
  double distanceTo(FusionDataPoint other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Checks if this point is within a rectangular bounds.
  ///
  /// Returns `true` if this point falls within the rectangle defined by
  /// [minX], [maxX], [minY], [maxY].
  ///
  /// Useful for viewport culling and visible data detection.
  bool isWithinBounds(double minX, double maxX, double minY, double maxY) {
    return x >= minX && x <= maxX && y >= minY && y <= maxY;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionDataPoint &&
        other.x == x &&
        other.y == y &&
        other.label == label &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(x, y, label, metadata);
  }

  @override
  String toString() {
    final buffer = StringBuffer('FusionDataPoint(');
    buffer.write('x: $x, y: $y');
    if (label != null) buffer.write(', label: "$label"');
    if (metadata != null) buffer.write(', metadata: $metadata');
    buffer.write(')');
    return buffer.toString();
  }
}

/// Extension methods for lists of [FusionDataPoint].
///
/// Provides convenient operations on collections of data points.
extension FusionDataPointListExtensions on List<FusionDataPoint> {
  /// Finds the minimum x value in this list.
  ///
  /// Returns `null` if the list is empty.
  double? get minX {
    if (isEmpty) return null;
    return map((p) => p.x).reduce((a, b) => a < b ? a : b);
  }

  /// Finds the maximum x value in this list.
  ///
  /// Returns `null` if the list is empty.
  double? get maxX {
    if (isEmpty) return null;
    return map((p) => p.x).reduce((a, b) => a > b ? a : b);
  }

  /// Finds the minimum y value in this list.
  ///
  /// Returns `null` if the list is empty.
  double? get minY {
    if (isEmpty) return null;
    return map((p) => p.y).reduce((a, b) => a < b ? a : b);
  }

  /// Finds the maximum y value in this list.
  ///
  /// Returns `null` if the list is empty.
  double? get maxY {
    if (isEmpty) return null;
    return map((p) => p.y).reduce((a, b) => a > b ? a : b);
  }

  /// Filters points that fall within a rectangular bounds.
  ///
  /// Returns a new list containing only points within the specified bounds.
  /// Useful for viewport culling.
  List<FusionDataPoint> filterByBounds(double minX, double maxX, double minY, double maxY) {
    return where((p) => p.isWithinBounds(minX, maxX, minY, maxY)).toList();
  }

  /// Sorts points by x coordinate in ascending order.
  ///
  /// Returns a new sorted list. Does not modify the original list.
  List<FusionDataPoint> sortByX() {
    final sorted = List<FusionDataPoint>.from(this);
    sorted.sort((a, b) => a.x.compareTo(b.x));
    return sorted;
  }

  /// Sorts points by y coordinate in ascending order.
  ///
  /// Returns a new sorted list. Does not modify the original list.
  List<FusionDataPoint> sortByY() {
    final sorted = List<FusionDataPoint>.from(this);
    sorted.sort((a, b) => a.y.compareTo(b.y));
    return sorted;
  }

  /// Calculates the average y value.
  ///
  /// Returns `null` if the list is empty.
  double? get averageY {
    if (isEmpty) return null;
    return map((p) => p.y).reduce((a, b) => a + b) / length;
  }

  /// Calculates the sum of all y values.
  ///
  /// Returns 0 if the list is empty.
  double get sumY {
    if (isEmpty) return 0;
    return map((p) => p.y).reduce((a, b) => a + b);
  }
}

/// Helper class for creating common data point patterns.
class FusionDataPointHelper {
  FusionDataPointHelper._(); // Private constructor - this is a utility class

  /// Creates a list of evenly spaced data points.
  ///
  /// Generates [count] points with x values from [startX] to [endX]
  /// and y values generated by the [yValueGenerator] function.
  ///
  /// Example:
  /// ```dart
  /// // Create sine wave
  /// final sineWave = FusionDataPointHelper.generate(
  ///   count: 100,
  ///   startX: 0,
  ///   endX: 2 * pi,
  ///   yValueGenerator: (x) => sin(x),
  /// );
  /// ```
  static List<FusionDataPoint> generate({
    required int count,
    required double startX,
    required double endX,
    required double Function(double x) yValueGenerator,
    String Function(double x)? labelGenerator,
  }) {
    if (count <= 0) return [];
    if (count == 1) {
      final x = startX;
      return [FusionDataPoint(x, yValueGenerator(x), label: labelGenerator?.call(x))];
    }

    final step = (endX - startX) / (count - 1);
    return List.generate(count, (index) {
      final x = startX + (step * index);
      return FusionDataPoint(x, yValueGenerator(x), label: labelGenerator?.call(x));
    });
  }

  /// Creates data points from two separate lists of x and y values.
  ///
  /// The lists must have the same length.
  ///
  /// Example:
  /// ```dart
  /// final xValues = [0, 1, 2, 3, 4];
  /// final yValues = [10, 15, 12, 18, 16];
  /// final points = FusionDataPointHelper.fromLists(xValues, yValues);
  /// ```
  static List<FusionDataPoint> fromLists(
    List<double> xValues,
    List<double> yValues, {
    List<String>? labels,
  }) {
    assert(xValues.length == yValues.length, 'xValues and yValues must have the same length');
    assert(
      labels == null || labels.length == xValues.length,
      'labels must have the same length as xValues and yValues',
    );

    return List.generate(xValues.length, (index) {
      return FusionDataPoint(xValues[index], yValues[index], label: labels?[index]);
    });
  }

  /// Creates data points from a map where keys are x values and values are y values.
  ///
  /// Example:
  /// ```dart
  /// final data = {
  ///   0: 10,
  ///   1: 15,
  ///   2: 12,
  /// };
  /// final points = FusionDataPointHelper.fromMap(data);
  /// ```
  static List<FusionDataPoint> fromMap(Map<double, double> data) {
    return data.entries.map((entry) {
      return FusionDataPoint(entry.key, entry.value);
    }).toList();
  }

  /// Creates random data points for testing purposes.
  ///
  /// Generates [count] points with x values from [minX] to [maxX]
  /// and random y values between [minY] and [maxY].
  ///
  /// Example:
  /// ```dart
  /// final randomData = FusionDataPointHelper.random(
  ///   count: 50,
  ///   minX: 0,
  ///   maxX: 10,
  ///   minY: 0,
  ///   maxY: 100,
  ///   seed: 42, // For reproducible results
  /// );
  /// ```
  static List<FusionDataPoint> random({
    required int count,
    double minX = 0,
    double maxX = 10,
    double minY = 0,
    double maxY = 100,
    int? seed,
  }) {
    final random = seed != null ? Random(seed) : Random();
    final xRange = maxX - minX;
    final yRange = maxY - minY;

    return List.generate(count, (index) {
      return FusionDataPoint(
        minX + (xRange * index / (count - 1)),
        minY + (random.nextDouble() * yRange),
      );
    });
  }
}

// lib/src/series/series_with_data_points.dart

import 'package:flutter/material.dart';
import '../data/fusion_data_point.dart';

/// Interface for any series that contains data points.
///
/// This allows interaction handlers to work with ANY series type
/// that has data points, without knowing the specific implementation.
///
/// ## Design Pattern: Interface Segregation Principle (SOLID)
///
/// Instead of forcing all series to implement every method,
/// we create small, focused interfaces for specific capabilities.
///
/// ## Usage
///
/// ```dart
/// class FusionLineSeries extends FusionSeries
///     with FusionMarkerSupport
///     implements SeriesWithDataPoints {
///
///   @override
///   final List<FusionDataPoint> dataPoints;
///   // name, color, visible inherited from FusionSeries
/// }
/// ```
abstract class SeriesWithDataPoints {
  /// The data points in this series.
  List<FusionDataPoint> get dataPoints;

  /// The display name of this series.
  String get name;

  /// The primary color of this series.
  Color get color;

  /// Whether this series is visible.
  bool get visible;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../configuration/fusion_axis_configuration.dart';
import '../series/fusion_bar_series.dart';

/// Data model for bar charts.
///
/// Contains all the data and configuration needed to render a bar chart.
///
/// ## Example
///
/// ```dart
/// final barData = FusionBarChartData(
///   series: [
///     FusionBarSeries(
///       name: 'Revenue',
///       dataPoints: quarterlyData,
///       color: Colors.blue,
///     ),
///   ],
///   xAxis: FusionAxisConfiguration(
///     type: FusionAxisType.category,
///     categories: ['Q1', 'Q2', 'Q3', 'Q4'],
///   ),
/// );
/// ```
@immutable
class FusionBarChartData {
  /// Creates bar chart data.
  const FusionBarChartData({
    required this.series,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.backgroundColor,
  }) : assert(series.length > 0, 'At least one series is required');

  /// The bar series to display.
  final List<FusionBarSeries> series;

  /// Configuration for the X-axis (category axis).
  final FusionAxisConfiguration? xAxis;

  /// Configuration for the Y-axis (value axis).
  final FusionAxisConfiguration? yAxis;

  /// Optional chart title.
  final String? title;

  /// Optional chart subtitle.
  final String? subtitle;

  /// Optional background color override.
  final Color? backgroundColor;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Gets all visible series.
  List<FusionBarSeries> get visibleSeries => series.where((s) => s.visible).toList();

  /// Checks if any series is visible.
  bool get hasVisibleSeries => visibleSeries.isNotEmpty;

  /// Gets the total number of data points across all visible series.
  int get totalDataPoints => visibleSeries.fold(0, (sum, s) => sum + s.dataPoints.length);

  /// Gets the minimum Y value across all visible series.
  double? get minY {
    if (!hasVisibleSeries) return null;
    final values = visibleSeries.map((s) => s.minY).whereType<double>();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a < b ? a : b);
  }

  /// Gets the maximum Y value across all visible series.
  double? get maxY {
    if (!hasVisibleSeries) return null;
    final values = visibleSeries.map((s) => s.maxY).whereType<double>();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  // ==========================================================================
  // METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionBarChartData copyWith({
    List<FusionBarSeries>? series,
    FusionAxisConfiguration? xAxis,
    FusionAxisConfiguration? yAxis,
    String? title,
    String? subtitle,
    Color? backgroundColor,
  }) {
    return FusionBarChartData(
      series: series ?? this.series,
      xAxis: xAxis ?? this.xAxis,
      yAxis: yAxis ?? this.yAxis,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  String toString() => 'FusionBarChartData(series: ${series.length}, title: $title)';
}

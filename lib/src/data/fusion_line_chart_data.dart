import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../configuration/fusion_axis_configuration.dart';
import '../series/fusion_line_series.dart';

/// Data model for line charts.
///
/// Contains all the data and configuration needed to render a line chart.
///
/// ## Example
///
/// ```dart
/// final lineData = FusionLineChartData(
///   series: [
///     FusionLineSeries(
///       name: 'Revenue',
///       dataPoints: monthlyData,
///       color: Colors.blue,
///       isCurved: true,
///     ),
///   ],
///   xAxis: FusionAxisConfiguration(
///     type: FusionAxisType.numeric,
///     min: 0,
///     max: 12,
///   ),
/// );
/// ```
@immutable
class FusionLineChartData {
  /// Creates line chart data.
  const FusionLineChartData({
    required this.series,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.backgroundColor,
  }) : assert(series.length > 0, 'At least one series is required');

  /// The line series to display.
  final List<FusionLineSeries> series;

  /// Configuration for the X-axis.
  final FusionAxisConfiguration? xAxis;

  /// Configuration for the Y-axis.
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
  List<FusionLineSeries> get visibleSeries =>
      series.where((s) => s.visible).toList();

  /// Checks if any series is visible.
  bool get hasVisibleSeries => visibleSeries.isNotEmpty;

  /// Gets the total number of data points across all visible series.
  int get totalDataPoints =>
      visibleSeries.fold(0, (sum, s) => sum + s.dataPoints.length);

  /// Gets the minimum X value across all visible series.
  double? get minX {
    if (!hasVisibleSeries) return null;
    final values = visibleSeries.map((s) => s.minX).whereType<double>();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a < b ? a : b);
  }

  /// Gets the maximum X value across all visible series.
  double? get maxX {
    if (!hasVisibleSeries) return null;
    final values = visibleSeries.map((s) => s.maxX).whereType<double>();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

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
  FusionLineChartData copyWith({
    List<FusionLineSeries>? series,
    FusionAxisConfiguration? xAxis,
    FusionAxisConfiguration? yAxis,
    String? title,
    String? subtitle,
    Color? backgroundColor,
  }) {
    return FusionLineChartData(
      series: series ?? this.series,
      xAxis: xAxis ?? this.xAxis,
      yAxis: yAxis ?? this.yAxis,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  String toString() =>
      'FusionLineChartData(series: ${series.length}, title: $title)';
}

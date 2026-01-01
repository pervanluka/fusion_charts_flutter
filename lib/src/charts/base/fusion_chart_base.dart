import 'package:flutter/material.dart';
import '../../configuration/fusion_axis_configuration.dart';
import '../../configuration/fusion_chart_configuration.dart';
import '../../data/fusion_data_point.dart';
import '../../series/series_with_data_points.dart';

/// Callback type for data point interactions.
typedef FusionPointCallback = void Function(FusionDataPoint point, String seriesName);

/// Abstract base class for all Fusion Chart widgets.
///
/// Provides the common widget interface shared by all chart types:
/// - Series data
/// - Configuration
/// - Axis settings
/// - Title/subtitle
/// - Interaction callbacks
///
/// ## Type Parameters
///
/// - `S` - The series type (must extend [SeriesWithDataPoints])
///
/// ## Subclasses
///
/// - [FusionLineChart] - Line and area charts
/// - [FusionBarChart] - Bar/column charts
/// - [FusionStackedBarChart] - Stacked bar charts
///
/// ## Example Implementation
///
/// ```dart
/// class FusionLineChart extends FusionChartBase<FusionLineSeries> {
///   const FusionLineChart({
///     super.key,
///     required super.series,
///     super.config,
///     // ... other params use super
///   });
///
///   @override
///   State<FusionLineChart> createState() => _FusionLineChartState();
/// }
/// ```
abstract class FusionChartBase<S extends SeriesWithDataPoints> extends StatefulWidget {
  const FusionChartBase({
    super.key,
    required this.series,
    this.config,
    this.xAxis,
    this.yAxis,
    this.title,
    this.subtitle,
    this.onDataPointTap,
    this.onDataPointLongPress,
  }) : assert(series.length > 0, 'At least one series is required');

  /// All series to display in the chart.
  ///
  /// Must contain at least one series.
  final List<S> series;

  /// Chart configuration controlling appearance and behavior.
  ///
  /// If null, default configuration is used.
  /// Subclasses may use more specific configuration types
  /// (e.g., [FusionBarChartConfiguration]).
  final FusionChartConfiguration? config;

  /// X-axis configuration.
  ///
  /// Controls axis visibility, labels, formatting, and styling.
  final FusionAxisConfiguration? xAxis;

  /// Y-axis configuration.
  ///
  /// Controls axis visibility, labels, formatting, and styling.
  final FusionAxisConfiguration? yAxis;

  /// Optional chart title displayed at the top.
  final String? title;

  /// Optional chart subtitle displayed below the title.
  final String? subtitle;

  /// Callback when a data point is tapped.
  final FusionPointCallback? onDataPointTap;

  /// Callback when a data point is long-pressed.
  final FusionPointCallback? onDataPointLongPress;
}

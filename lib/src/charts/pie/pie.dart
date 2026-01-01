/// Pie and donut chart components.
///
/// This module provides everything needed for pie/donut charts:
///
/// - [FusionPieChart] - The main widget
/// - [FusionPieSeries] - Series data model
/// - [FusionPieDataPoint] - Individual slice data
/// - [FusionPieChartConfiguration] - Chart configuration
/// - [PieTooltipData] - Tooltip data for custom builders
///
/// ## Quick Start
///
/// ```dart
/// FusionPieChart(
///   series: FusionPieSeries(
///     dataPoints: [
///       FusionPieDataPoint(35, label: 'Sales'),
///       FusionPieDataPoint(25, label: 'Marketing'),
///       FusionPieDataPoint(20, label: 'Engineering'),
///       FusionPieDataPoint(20, label: 'Support'),
///     ],
///   ),
/// )
/// ```
library;

export 'fusion_pie_chart.dart';
export 'fusion_pie_chart_painter.dart';
export 'fusion_pie_interactive_state.dart';
export 'pie_tooltip_data.dart';

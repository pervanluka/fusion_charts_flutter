/// Fusion Charts Flutter - Professional Flutter Charting Library
///
/// A powerful, customizable charting library that combines stunning visuals
/// with enterprise-grade functionality. Built with SOLID principles.
///
/// ## Features
///
/// * 🎨 Professional Themes: Light, Dark, and Enterprise themes
/// * 📊 Chart Types: Line, Bar, and Stacked Bar charts
/// * ⚡ High Performance: Optimized for 10K+ data points
/// * 🎭 Smooth Animations: Configurable animations with cubic easing
/// * 📱 Fully Responsive: Adapts to all screen sizes
/// * 🏗️ SOLID Architecture: Clean, maintainable code
/// * 🎨 Highly Customizable: Every aspect can be customized
///
/// ## Quick Start
///
/// ```dart
/// import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
///
/// FusionLineChart(
///   series: [
///     FusionLineSeries(
///       name: 'Revenue',
///       dataPoints: [
///         FusionDataPoint(0, 30),
///         FusionDataPoint(1, 50),
///         FusionDataPoint(2, 40),
///       ],
///       color: Colors.blue,
///     ),
///   ],
/// )
/// ```
///
/// ## Chart Types
///
/// * [FusionLineChart] - Line chart for trends over time
/// * [FusionBarChart] - Bar chart for comparing categories
/// * [FusionStackedBarChart] - Stacked bar chart for cumulative data
///
/// ## Themes
///
/// * [FusionLightTheme] - Light theme (default)
/// * [FusionDarkTheme] - Dark theme for dark mode apps
///
/// ## Configuration
///
/// Use [FusionChartConfiguration] to customize charts:
///
/// ```dart
/// FusionLineChart(
///   series: [...],
///   config: FusionChartConfiguration(
///     theme: FusionDarkTheme(),
///     enableAnimation: true,
///     enableTooltip: true,
///     enableCrosshair: true,
///   ),
/// )
/// ```
library;

import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

// ============================================================================
// FLUTTER CORE EXPORTS (for convenience)
// ============================================================================

export 'package:flutter/material.dart'
    show
        Alignment,
        BlurStyle,
        BoxShadow,
        Color,
        Colors,
        Curve,
        Curves,
        FontStyle,
        FontWeight,
        Gradient,
        LinearGradient,
        Offset,
        Rect,
        TextStyle;

/// Bar chart widget.
export 'src/charts/fusion_bar_chart.dart';

/// Line chart widget.
export 'src/charts/fusion_line_chart.dart';

/// Stacked bar chart widget.
export 'src/charts/fusion_stacked_bar_chart.dart';

/// Pie chart widget.
export 'src/charts/pie/fusion_pie_chart.dart';

/// Axis configuration.
export 'src/configuration/fusion_axis_configuration.dart';

/// Bar chart specific configuration.
export 'src/configuration/fusion_bar_chart_configuration.dart';

/// Base chart configuration (shared settings).
export 'src/configuration/fusion_chart_configuration.dart';

/// Crosshair configuration.
export 'src/configuration/fusion_crosshair_configuration.dart';

/// Legend configuration.
export 'src/configuration/fusion_legend_configuration.dart';

/// Line chart specific configuration.
export 'src/configuration/fusion_line_chart_configuration.dart';

/// Pan configuration.
export 'src/configuration/fusion_pan_configuration.dart';

/// Pie chart configuration.
export 'src/configuration/fusion_pie_chart_configuration.dart';

/// Stacked bar chart specific configuration.
export 'src/configuration/fusion_stacked_bar_chart_configuration.dart';

/// Stacked tooltip builder types.
export 'src/configuration/fusion_stacked_tooltip_builder.dart';

/// Tooltip configuration.
export 'src/configuration/fusion_tooltip_configuration.dart';

/// Zoom configuration.
export 'src/configuration/fusion_zoom_configuration.dart';

/// Chart controller for programmatic zoom/pan control.
export 'src/controllers/fusion_chart_controller.dart';

/// Base axis class (for type checking and extension).
export 'src/core/axis/base/fusion_axis_base.dart';

/// Category axis for discrete labeled data (bar charts, etc.).
export 'src/core/axis/category/fusion_category_axis.dart';

/// DateTime axis for time-series data with smart formatting.
export 'src/core/axis/datetime/fusion_datetime_axis.dart';

/// Numeric axis for continuous numerical data.
export 'src/core/axis/numeric/fusion_numeric_axis.dart';

/// Axis label intersect actions (hide, wrap, rotate, etc.).
export 'src/core/enums/axis_label_intersect_action.dart';

/// Axis positions (left, right, top, bottom).
export 'src/core/enums/axis_position.dart';

/// Axis range padding types.
export 'src/core/enums/axis_range_padding.dart';

/// Axis types (numeric, category, datetime).
export 'src/core/enums/axis_type.dart';

/// Range padding strategies.
export 'src/core/enums/chart_range_padding.dart';

/// Data label display modes (all, maxOnly, minOnly, maxAndMin, etc.).
export 'src/core/enums/fusion_data_label_display.dart';

/// Tooltip dismiss strategies (onRelease, onTimer, etc.).
export 'src/core/enums/fusion_dismiss_strategy.dart';

/// Label alignment strategies.
export 'src/core/enums/fusion_label_alignment_strategy.dart';

/// Pan edge behavior (stop, bounce, continuous).
export 'src/core/enums/fusion_pan_edge_behavior.dart';

/// Pan modes (horizontal, vertical, both).
export 'src/core/enums/fusion_pan_mode.dart';

/// Tooltip activation modes (tap, hover, longPress, etc.).
export 'src/core/enums/fusion_tooltip_activation_mode.dart';

/// Tooltip position modes (floating, top, bottom).
export 'src/core/enums/fusion_tooltip_position.dart';

/// Tooltip trackball modes (none, follow, snap, magnetic).
export 'src/core/enums/fusion_tooltip_trackball_mode.dart';

/// Zoom modes (horizontal, vertical, both).
export 'src/core/enums/fusion_zoom_mode.dart';

/// Interaction anchor modes for crosshair, tooltip, and data labels.
export 'src/core/enums/interaction_anchor_mode.dart';

/// Label alignment options.
export 'src/core/enums/label_alignment.dart';

/// Marker shapes for data points.
export 'src/core/enums/marker_shape.dart';

/// Text anchor positions for labels.
export 'src/core/enums/text_anchor.dart';

/// Plot bands for highlighting regions.
export 'src/core/features/plot_band/plot_band.dart';

/// Axis bounds calculation.
export 'src/core/models/axis_bounds.dart';

/// Axis label model.
export 'src/core/models/axis_label.dart';

/// Minor grid lines configuration.
export 'src/core/models/minor_grid_lines.dart';

/// Minor tick lines configuration.
export 'src/core/models/minor_tick_lines.dart';

/// Axis line styling.
export 'src/core/styling/axis_line.dart';

/// Major tick lines styling.
export 'src/core/styling/major_tick_lines.dart';

/// Data validation utilities.
export 'src/core/validation/data_validator.dart';

/// Bar chart data model.
export 'src/data/fusion_bar_chart_data.dart';

/// Core data point for all charts.
export 'src/data/fusion_data_point.dart';

/// Line chart data model.
export 'src/data/fusion_line_chart_data.dart';

/// Pie data point.
export 'src/data/fusion_pie_data_point.dart';

/// Coordinate transformation system.
export 'src/rendering/fusion_coordinate_system.dart';

/// Pie segment computation.
export 'src/rendering/polar/fusion_pie_segment.dart';

/// Polar coordinate math for pie/donut charts.
export 'src/rendering/polar/fusion_polar_math.dart';

/// Area series for area charts.
export 'src/series/fusion_area_series.dart';

/// Bar series for bar charts.
export 'src/series/fusion_bar_series.dart';

/// Line series for line charts.
export 'src/series/fusion_line_series.dart';

/// Pie series.
export 'src/series/fusion_pie_series.dart';

/// Base series class.
export 'src/series/fusion_series.dart';

/// Stacked bar series for cumulative data visualization.
export 'src/series/fusion_stacked_bar_series.dart';

/// Series interface with data points.
export 'src/series/series_with_data_points.dart';

/// Base theme interface.
export 'src/themes/fusion_chart_theme.dart';

/// Dark theme.
export 'src/themes/fusion_dark_theme.dart';

/// Light theme (default).
export 'src/themes/fusion_light_theme.dart';

/// Chart bounds calculator for consistent axis bounds across all chart types.
export 'src/utils/chart_bounds_calculator.dart';

/// Color palettes for charts.
export 'src/utils/fusion_color_palette.dart';

/// Data formatters for labels and tooltips.
export 'src/utils/fusion_data_formatter.dart';

/// DateTime utilities for time-based charts.
export 'src/utils/fusion_datetime_utils.dart';

/// Mathematical utilities for calculations.
export 'src/utils/fusion_mathematics.dart';

/// Responsive sizing utilities.
export 'src/utils/fusion_responsive_size.dart';

/// LTTB Downsampler for large datasets.
export 'src/utils/lttb_downsampler.dart';

/// Error boundary widget for graceful error handling.
export 'src/widgets/error/fusion_chart_error_boundary.dart';

/// Zoom controls widget (+/- buttons overlay).
export 'src/widgets/fusion_zoom_controls.dart';

// ============================================================================
// VERSION & METADATA
// ============================================================================

/// Current version of fusion_charts_flutter.
const String fusionChartsVersion = '1.0.1';

/// Library name.
const String fusionChartsName = 'fusion_charts_flutter';

/// Library description.
const String fusionChartsDescription =
    'Professional Flutter charting library with stunning visuals and enterprise-grade features';

/// Repository URL.
const String fusionChartsRepository =
    'https://github.com/pervanluka/fusion_charts_flutter';

/// License.
const String fusionChartsLicense = 'MIT';

/// Author.
const String fusionChartsAuthor = 'Luka Pervan';

/// Homepage.
const String fusionChartsHomepage =
    'https://github.com/pervanluka/fusion_charts_flutter';

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
        Color,
        Colors,
        TextStyle,
        FontWeight,
        FontStyle,
        Curves,
        Curve,
        LinearGradient,
        Gradient,
        Alignment,
        BoxShadow,
        BlurStyle,
        Offset,
        Rect;

// ============================================================================
// DATA MODELS
// ============================================================================

/// Core data point for all charts.
export 'src/data/fusion_data_point.dart';

/// Line chart data model.
export 'src/data/fusion_line_chart_data.dart';

/// Bar chart data model.
export 'src/data/fusion_bar_chart_data.dart';

// ============================================================================
// SERIES
// ============================================================================

/// Base series class.
export 'src/series/fusion_series.dart';

/// Line series for line charts.
export 'src/series/fusion_line_series.dart';

/// Bar series for bar charts.
export 'src/series/fusion_bar_series.dart';

/// Stacked bar series for cumulative data visualization.
export 'src/series/fusion_stacked_bar_series.dart';

/// Area series for area charts.
export 'src/series/fusion_area_series.dart';

/// Series interface with data points.
export 'src/series/series_with_data_points.dart';

// ============================================================================
// CHARTS (Main Widgets)
// ============================================================================

/// Line chart widget.
export 'src/charts/fusion_line_chart.dart';

/// Bar chart widget.
export 'src/charts/fusion_bar_chart.dart';

/// Stacked bar chart widget.
export 'src/charts/fusion_stacked_bar_chart.dart';

// ============================================================================
// THEMES
// ============================================================================

/// Base theme interface.
export 'src/themes/fusion_chart_theme.dart';

/// Light theme (default).
export 'src/themes/fusion_light_theme.dart';

/// Dark theme.
export 'src/themes/fusion_dark_theme.dart';

// ============================================================================
// CONFIGURATION
// ============================================================================

/// Base chart configuration (shared settings).
export 'src/configuration/fusion_chart_configuration.dart';

/// Line chart specific configuration.
export 'src/configuration/fusion_line_chart_configuration.dart';

/// Bar chart specific configuration.
export 'src/configuration/fusion_bar_chart_configuration.dart';

/// Stacked bar chart specific configuration.
export 'src/configuration/fusion_stacked_bar_chart_configuration.dart';

/// Axis configuration.
export 'src/configuration/fusion_axis_configuration.dart';

/// Tooltip configuration.
export 'src/configuration/fusion_tooltip_configuration.dart';

/// Legend configuration.
export 'src/configuration/fusion_legend_configuration.dart';

/// Crosshair configuration.
export 'src/configuration/fusion_crosshair_configuration.dart';

/// Stacked tooltip builder types.
export 'src/configuration/fusion_stacked_tooltip_builder.dart';

/// Zoom configuration.
export 'src/configuration/fusion_zoom_configuration.dart';

/// Pan configuration.
export 'src/configuration/fusion_pan_configuration.dart';

// ============================================================================
// ENUMS - Tooltip
// ============================================================================

/// Tooltip activation modes (tap, hover, longPress, etc.).
export 'src/core/enums/fusion_tooltip_activation_mode.dart';

/// Tooltip trackball modes (none, follow, snap, magnetic).
export 'src/core/enums/fusion_tooltip_trackball_mode.dart';

/// Tooltip dismiss strategies (onRelease, onTimer, etc.).
export 'src/core/enums/fusion_dismiss_strategy.dart';

// ============================================================================
// ENUMS - Zoom & Pan
// ============================================================================

/// Zoom modes (horizontal, vertical, both).
export 'src/core/enums/fusion_zoom_mode.dart';

/// Pan modes (horizontal, vertical, both).
export 'src/core/enums/fusion_pan_mode.dart';

/// Pan edge behavior (stop, bounce, continuous).
export 'src/core/enums/fusion_pan_edge_behavior.dart';

// ============================================================================
// ENUMS - Axis & Labels
// ============================================================================

/// Marker shapes for data points.
export 'src/core/enums/marker_shape.dart';

/// Range padding strategies.
export 'src/core/enums/chart_range_padding.dart';

/// Label alignment options.
export 'src/core/enums/label_alignment.dart';

/// Axis range padding types.
export 'src/core/enums/axis_range_padding.dart';

/// Axis types (numeric, category, datetime).
export 'src/core/enums/axis_type.dart';

/// Axis positions (left, right, top, bottom).
export 'src/core/enums/axis_position.dart';

/// Axis label intersect actions (hide, wrap, rotate, etc.).
export 'src/core/enums/axis_label_intersect_action.dart';

/// Text anchor positions for labels.
export 'src/core/enums/text_anchor.dart';

/// Label alignment strategies.
export 'src/core/enums/fusion_label_alignment_strategy.dart';

// ============================================================================
// AXIS TYPES
// ============================================================================

/// Base axis class (for type checking and extension).
export 'src/core/axis/base/fusion_axis_base.dart';

/// Numeric axis for continuous numerical data.
export 'src/core/axis/numeric/fusion_numeric_axis.dart';

/// Category axis for discrete labeled data (bar charts, etc.).
export 'src/core/axis/category/fusion_category_axis.dart';

/// DateTime axis for time-series data with smart formatting.
export 'src/core/axis/datetime/fusion_datetime_axis.dart';

// ============================================================================
// CORE MODELS - Axis
// ============================================================================

/// Axis bounds calculation.
export 'src/core/models/axis_bounds.dart';

/// Axis label model.
export 'src/core/models/axis_label.dart';

/// Minor grid lines configuration.
export 'src/core/models/minor_grid_lines.dart';

/// Minor tick lines configuration.
export 'src/core/models/minor_tick_lines.dart';

// ============================================================================
// CORE STYLING
// ============================================================================

/// Axis line styling.
export 'src/core/styling/axis_line.dart';

/// Major tick lines styling.
export 'src/core/styling/major_tick_lines.dart';

// ============================================================================
// CORE FEATURES
// ============================================================================

/// Plot bands for highlighting regions.
export 'src/core/features/plot_band/plot_band.dart';

// ============================================================================
// UTILITIES
// ============================================================================

/// Color palettes for charts.
export 'src/utils/fusion_color_palette.dart';

/// Data formatters for labels and tooltips.
export 'src/utils/fusion_data_formatter.dart';

/// Data validation utilities.
export 'src/core/validation/data_validator.dart';

/// Responsive sizing utilities.
export 'src/utils/fusion_responsive_size.dart';

/// Mathematical utilities for calculations.
export 'src/utils/fusion_mathematics.dart';

/// LTTB Downsampler for large datasets.
export 'src/utils/lttb_downsampler.dart';

/// DateTime utilities for time-based charts.
export 'src/utils/fusion_datetime_utils.dart';

// ============================================================================
// RENDERING (Advanced Usage)
// ============================================================================

/// Coordinate transformation system.
export 'src/rendering/fusion_coordinate_system.dart';

// ============================================================================
// WIDGETS
// ============================================================================

/// Error boundary widget for graceful error handling.
export 'src/widgets/error/fusion_chart_error_boundary.dart';

// ============================================================================
// VERSION & METADATA
// ============================================================================

/// Current version of fusion_charts_flutter.
const String fusionChartsVersion = '1.0.0';

/// Library name.
const String fusionChartsName = 'fusion_charts_flutter';

/// Library description.
const String fusionChartsDescription =
    'Professional Flutter charting library with stunning visuals and enterprise-grade features';

/// Repository URL.
const String fusionChartsRepository = 'https://github.com/pervanluka/fusion_charts_flutter';

/// License.
const String fusionChartsLicense = 'MIT';

/// Author.
const String fusionChartsAuthor = 'Luka Pervan';

/// Homepage.
const String fusionChartsHomepage = 'https://github.com/pervanluka/fusion_charts_flutter';

// ============================================================================
// EXTENSIONS (for convenience)
// ============================================================================

/// Extension methods for data point lists.
extension FusionDataPointListExtension on List<FusionDataPoint> {
  /// Gets minimum X value.
  double? get minX {
    if (isEmpty) return null;
    return map((p) => p.x).reduce((a, b) => a < b ? a : b);
  }

  /// Gets maximum X value.
  double? get maxX {
    if (isEmpty) return null;
    return map((p) => p.x).reduce((a, b) => a > b ? a : b);
  }

  /// Gets minimum Y value.
  double? get minY {
    if (isEmpty) return null;
    return map((p) => p.y).reduce((a, b) => a < b ? a : b);
  }

  /// Gets maximum Y value.
  double? get maxY {
    if (isEmpty) return null;
    return map((p) => p.y).reduce((a, b) => a > b ? a : b);
  }

  /// Gets average Y value.
  double? get averageY {
    if (isEmpty) return null;
    return map((p) => p.y).reduce((a, b) => a + b) / length;
  }

  /// Gets sum of Y values.
  double get sumY {
    if (isEmpty) return 0;
    return map((p) => p.y).reduce((a, b) => a + b);
  }

  /// Sorts by X coordinate.
  List<FusionDataPoint> sortByX() {
    final sorted = List<FusionDataPoint>.from(this);
    sorted.sort((a, b) => a.x.compareTo(b.x));
    return sorted;
  }

  /// Sorts by Y coordinate.
  List<FusionDataPoint> sortByY() {
    final sorted = List<FusionDataPoint>.from(this);
    sorted.sort((a, b) => a.y.compareTo(b.y));
    return sorted;
  }
}

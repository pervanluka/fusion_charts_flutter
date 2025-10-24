// lib/fusion_charts_flutter.dart

/// Fusion Charts Flutter - Professional Flutter Charting Library
///
/// A powerful, customizable charting library that combines stunning visuals
/// with enterprise-grade functionality. Built with SOLID principles.
///
/// ## Features
///
/// * 🎨 Professional Themes: Light, Dark, and Enterprise themes
/// * 📊 Chart Types: Line and Bar charts (more coming soon)
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

/// Main chart configuration.
export 'src/configuration/fusion_chart_configuration.dart';

/// Axis configuration.
export 'src/configuration/fusion_axis_configuration.dart';

/// Tooltip configuration.
export 'src/configuration/fusion_tooltip_configuration.dart';

/// Legend configuration.
export 'src/configuration/fusion_legend_configuration.dart';

/// Crosshair configuration.
export 'src/configuration/fusion_crosshair_configuration.dart';

// ============================================================================
// ENUMS & CONSTANTS
// ============================================================================

/// Marker shapes for data points.
export 'src/core/enums/marker_shape.dart';

/// Range padding strategies.
export 'src/core/enums/chart_range_padding.dart';

/// Label alignment options.
export 'src/core/enums/label_alignment.dart';

/// Axis range padding types.
export 'src/core/enums/axis_range_padding.dart';

// ============================================================================
// CORE MODELS
// ============================================================================

/// Axis bounds calculation.
export 'src/core/models/axis_bounds.dart';

/// Axis label model.
export 'src/core/models/axis_label.dart';

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

// ============================================================================
// RENDERING (Advanced Usage)
// ============================================================================

/// Coordinate transformation system.
export 'src/rendering/fusion_coordinate_system.dart';

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
const String fusionChartsRepository = 'https://github.com/your-org/fusion_charts_flutter';

/// License.
const String fusionChartsLicense = 'MIT';

/// Author.
const String fusionChartsAuthor = 'Fusion Charts Team';

/// Homepage.
const String fusionChartsHomepage = 'https://fusioncharts.dev';

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

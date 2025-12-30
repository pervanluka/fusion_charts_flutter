import 'package:flutter/material.dart';

/// Abstract base class for chart themes.
///
/// Defines the visual style and appearance of all charts.
/// Implement this interface to create custom themes.
///
/// Follows the **Open/Closed Principle** (SOLID):
/// - Open for extension (create new themes)
/// - Closed for modification (don't change this interface)
///
/// ## Built-in Themes
///
/// - [FusionLightTheme] - Light color scheme (default)
/// - [FusionDarkTheme] - Dark color scheme
/// - [FusionEnterpriseTheme] - Professional business theme
///
/// ## Creating Custom Themes
///
/// ```dart
/// class MyCompanyTheme implements FusionChartTheme {
///   @override
///   Color get primaryColor => Color(0xFF1A73E8);
///
///   @override
///   Color get secondaryColor => Color(0xFF34A853);
///
///   @override
///   Color get backgroundColor => Colors.white;
///
///   // ... implement all other properties
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// final config = FusionChartConfigurationBuilder()
///   .withTheme(FusionDarkTheme())
///   .build();
///
/// FusionLineChart(
///   configuration: config,
///   series: [...],
/// )
/// ```
abstract class FusionChartTheme {
  /// Creates a chart theme.
  const FusionChartTheme();
  // ==========================================================================
  // COLORS
  // ==========================================================================

  /// Primary color used for the main chart elements.
  ///
  /// Used for:
  /// - Primary series line/bar color
  /// - Active interaction elements
  /// - Focus indicators
  Color get primaryColor;

  /// Secondary color used for accent elements.
  ///
  /// Used for:
  /// - Secondary series color
  /// - Gradient end points
  /// - Accent UI elements
  Color get secondaryColor;

  /// Background color of the chart container.
  ///
  /// Used for:
  /// - Chart card background
  /// - Tooltip background (can be overridden)
  Color get backgroundColor;

  /// Color of the grid lines.
  ///
  /// Should be subtle and not distract from the data.
  /// Typical opacity: 0.6-0.8
  Color get gridColor;

  /// Color for all text elements (titles, labels, legend).
  ///
  /// Should have good contrast with [backgroundColor].
  /// Minimum contrast ratio: 4.5:1 (WCAG AA)
  Color get textColor;

  /// Color for borders and separators.
  ///
  /// Used for:
  /// - Chart border
  /// - Tooltip border
  /// - Legend item separators
  Color get borderColor;

  /// Color for axis lines.
  ///
  /// Can be the same as [gridColor] or slightly darker.
  Color get axisColor => gridColor;

  /// Color for error or negative values.
  ///
  /// Used in financial charts or when showing negative trends.
  Color get errorColor => const Color(0xFFF44336);

  /// Color for success or positive values.
  ///
  /// Used when showing positive trends or achievements.
  Color get successColor => const Color(0xFF4CAF50);

  /// Color for warning or caution states.
  Color get warningColor => const Color(0xFFFF9800);

  // ==========================================================================
  // TYPOGRAPHY
  // ==========================================================================

  /// Text style for chart titles.
  ///
  /// Should be prominent and easy to read.
  /// Recommended: 18-20px, weight 600-700
  TextStyle get titleStyle;

  /// Text style for axis labels.
  ///
  /// Should be readable but not dominating.
  /// Recommended: 10-12px, weight 500
  TextStyle get axisLabelStyle;

  /// Text style for legend text.
  ///
  /// Recommended: 11-13px, weight 400-500
  TextStyle get legendStyle;

  /// Text style for tooltip content.
  ///
  /// Should be clear and readable.
  /// Recommended: 12-13px, weight 600
  TextStyle get tooltipStyle;

  /// Border radius for tooltips.
  double get tooltipBorderRadius => 8.0;

  /// Padding inside tooltips.
  EdgeInsets get tooltipPadding => const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  /// Default tooltip background color.
  Color get tooltipBackgroundColor => const Color(0xDD000000); // Colors.black87 equivalent

  /// Marker border color (usually white for contrast).
  Color get markerBorderColor => const Color(0xFFFFFFFF);

  /// Text style for data labels on the chart.
  ///
  /// Should be small enough not to clutter but readable.
  /// Recommended: 10-11px, weight 500
  TextStyle get dataLabelStyle => axisLabelStyle.copyWith(fontWeight: FontWeight.w600);

  /// Padding inside data label backgrounds.
  EdgeInsets get dataLabelPadding => const EdgeInsets.symmetric(horizontal: 4, vertical: 2);

  /// Background opacity for data labels.
  double get dataLabelBackgroundOpacity => 0.9;

  /// Border radius for data labels (uses borderRadius by default).
  double get dataLabelBorderRadius => 3.0;

  /// Text style for subtitle or secondary text.
  TextStyle get subtitleStyle => titleStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  // ==========================================================================
  // DIMENSIONS
  // ==========================================================================

  /// Border radius for chart containers and tooltips.
  ///
  /// Range: 8-16px
  double get borderRadius;

  /// Elevation (shadow depth) for the chart card.
  ///
  /// Range: 0-16dp
  double get elevation;

  /// Width of axis lines.
  ///
  /// Recommended: 1.0-1.5px
  double get axisLineWidth;

  /// Width of grid lines.
  ///
  /// Should be thinner than axis lines.
  /// Recommended: 0.5-1.0px
  double get gridLineWidth;

  /// Default line width for series.
  ///
  /// Range: 2-4px
  double get seriesLineWidth => 3.0;

  /// Default size for data point markers.
  ///
  /// Range: 4-8px
  double get markerSize => 6.0;

  /// Padding inside the chart container.
  EdgeInsets get chartPadding => const EdgeInsets.all(16.0);

  /// Spacing between legend items.
  double get legendSpacing => 8.0;

  /// Spacing between axis and labels.
  double get axisLabelPadding => 8.0;

  // ==========================================================================
  // GRADIENTS
  // ==========================================================================

  /// List of colors for chart gradients.
  ///
  /// Used for:
  /// - Multi-color gradients in area charts
  /// - Color transitions in series
  /// - Background gradients
  ///
  /// Typically 2-3 colors work best.
  List<Color> get chartGradientColors;

  /// Opacity for area fill under line charts.
  ///
  /// Range: 0.1-0.5
  double get areaFillOpacity => 0.3;

  // ==========================================================================
  // ANIMATIONS
  // ==========================================================================

  /// Duration for chart animations.
  ///
  /// Range: 500-2000ms
  Duration get animationDuration;

  /// Curve for chart animations.
  ///
  /// Popular choices:
  /// - Curves.easeInOutCubic
  /// - Curves.easeOut
  /// - Curves.fastOutSlowIn (Material Design)
  Curve get animationCurve;

  // ==========================================================================
  // SHADOWS
  // ==========================================================================

  /// Shadow for chart series lines/bars.
  ///
  /// Adds depth to the chart.
  BoxShadow get seriesShadow => BoxShadow(
    color: primaryColor.withValues(alpha: 0.2),
    offset: const Offset(0, 2),
    blurRadius: 4,
  );

  /// Shadow for the chart container.
  List<BoxShadow> get chartShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      offset: Offset(0, elevation / 2),
      blurRadius: elevation,
    ),
  ];

  // ==========================================================================
  // INTERACTION COLORS
  // ==========================================================================

  /// Color for crosshair line.
  Color get crosshairColor => primaryColor;

  /// Color for selected/highlighted elements.
  Color get highlightColor => primaryColor.withValues(alpha: 0.2);

  /// Color for hover state.
  Color get hoverColor => primaryColor.withValues(alpha: 0.1);

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Gets contrasting text color for a background.
  ///
  /// Returns white for dark backgrounds, black for light backgrounds.
  Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  // ==========================================================================
  // PIE CHART SPECIFIC
  // ==========================================================================

  /// Default stroke color for pie segments.
  Color get pieStrokeColor => Colors.white;

  /// Default shadow color for pie charts.
  Color get pieShadowColor => Colors.black26;

  /// Tooltip border width.
  double get tooltipBorderWidth => 2.0;

  /// Legend width for vertical legend layouts.
  double get legendWidth => 120.0;

  /// Legend height for horizontal legend layouts.
  double get legendHeight => 40.0;

  /// Legend item icon size.
  double get legendIconSize => 12.0;

  /// Legend item text spacing.
  double get legendItemSpacing => 8.0;

  /// Legend value text size ratio (relative to legend text).
  double get legendValueFontSizeRatio => 0.85;

  /// Legend line indicator thickness.
  double get legendLineThickness => 3.0;

  /// Legend icon corner radius.
  double get legendIconCornerRadius => 2.0;

  /// Color indicator corner radius in tooltips.
  double get tooltipIndicatorRadius => 2.0;

  /// Creates a lighter version of a color.
  ///
  /// Useful for hover states and disabled elements.
  Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Creates a darker version of a color.
  ///
  /// Useful for borders and shadows.
  Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Adjusts color opacity.
  Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}

/// Mixin for common theme utilities.
///
/// Provides helper methods that can be used by theme implementations.
mixin FusionThemeUtils {
  /// Creates a text style with given parameters.
  TextStyle createTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFamily: fontFamily,
    );
  }

  /// Creates a gradient from a list of colors.
  LinearGradient createGradient(
    List<Color> colors, {
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(colors: colors, begin: begin, end: end);
  }

  /// Checks if a color is light or dark.
  ///
  /// Returns `true` if the color is considered light.
  /// Useful for determining text color on colored backgrounds.
  bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Gets contrasting text color for a background.
  ///
  /// Returns white for dark backgrounds, black for light backgrounds.
  Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black : Colors.white;
  }
}

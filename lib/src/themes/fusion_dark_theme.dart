import 'package:flutter/material.dart';
import 'fusion_chart_theme.dart';

/// Dark theme for Fusion Charts.
///
/// Professional dark color scheme perfect for dark mode applications.
///
/// ## Color Scheme
///
/// - Primary: Light Purple (#8B7EFF) - Softer for dark backgrounds
/// - Secondary: Light Green (#66BB6A) - Easier on the eyes
/// - Background: Dark Gray (#1E1E1E) - True dark mode
/// - Grid: Medium Gray (#404040) - Visible but not harsh
/// - Text: Light Gray (#E0E0E0) - Excellent readability
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
///
/// ## Accessibility
///
/// - WCAG 2.1 Level AA compliant
/// - Reduced eye strain for dark environments
/// - High contrast ratios (>7:1)
class FusionDarkTheme extends FusionChartTheme with FusionThemeUtils {
  /// Creates a dark theme with default colors.
  const FusionDarkTheme();

  // ==========================================================================
  // COLORS
  // ==========================================================================

  @override
  Color get primaryColor => const Color(0xFF8B7EFF);

  @override
  Color get secondaryColor => const Color(0xFF66BB6A);

  @override
  Color get backgroundColor => const Color(0xFF1E1E1E);

  @override
  Color get gridColor => const Color(0xFF404040);

  @override
  Color get textColor => const Color(0xFFE0E0E0);

  @override
  Color get borderColor => const Color(0xFF505050);

  @override
  Color get axisColor => const Color(0xFF505050);

  @override
  Color get errorColor => const Color(0xFFFF5252);

  @override
  Color get successColor => const Color(0xFF69F0AE);

  @override
  Color get warningColor => const Color(0xFFFFD740);

  // ==========================================================================
  // TYPOGRAPHY
  // ==========================================================================

  @override
  TextStyle get titleStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.5,
    height: 1.4,
  );

  @override
  TextStyle get axisLabelStyle => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFFB0B0B0),
    letterSpacing: 0.3,
    height: 1.5,
  );

  @override
  TextStyle get legendStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB0B0B0),
    letterSpacing: 0.3,
    height: 1.5,
  );

  @override
  TextStyle get tooltipStyle => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.3,
    height: 1.4,
  );

  @override
  double get tooltipBorderRadius => 8.0;

  @override
  EdgeInsets get tooltipPadding => const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  @override
  Color get tooltipBackgroundColor => const Color(0xEE2A2A2A); // Slightly lighter for dark theme

  @override
  Color get markerBorderColor => const Color(0xFF1E1E1E); // Match background for dark theme

  @override
  TextStyle get dataLabelStyle => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Color(0xFFB0B0B0),
    letterSpacing: 0.3,
  );

  @override
  EdgeInsets get dataLabelPadding => const EdgeInsets.symmetric(horizontal: 4, vertical: 2);

  @override
  double get dataLabelBackgroundOpacity => 0.85; // Slightly lower for dark theme

  @override
  double get dataLabelBorderRadius => 3.0;

  @override
  TextStyle get subtitleStyle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textColor.withValues(alpha: 0.7),
    letterSpacing: 0.4,
    height: 1.4,
  );

  // ==========================================================================
  // DIMENSIONS
  // ==========================================================================

  @override
  double get borderRadius => 12.0;

  @override
  double get elevation => 8.0; // Higher elevation for dark theme

  @override
  double get axisLineWidth => 1.0;

  @override
  double get gridLineWidth => 0.8;

  @override
  double get seriesLineWidth => 3.0;

  @override
  double get markerSize => 6.0;

  @override
  EdgeInsets get chartPadding => const EdgeInsets.all(4);

  @override
  double get legendSpacing => 8.0;

  @override
  double get axisLabelPadding => 8.0;

  // ==========================================================================
  // GRADIENTS
  // ==========================================================================

  @override
  List<Color> get chartGradientColors => [primaryColor, secondaryColor];

  @override
  double get areaFillOpacity => 0.25; // Slightly lower for dark theme

  // ==========================================================================
  // ANIMATIONS
  // ==========================================================================

  @override
  Duration get animationDuration => const Duration(milliseconds: 1500);

  @override
  Curve get animationCurve => Curves.easeInOutCubic;

  // ==========================================================================
  // SHADOWS
  // ==========================================================================

  @override
  BoxShadow get seriesShadow => BoxShadow(
    color: primaryColor.withValues(alpha: 0.3),
    offset: const Offset(0, 2),
    blurRadius: 6,
    spreadRadius: 0,
  );

  @override
  List<BoxShadow> get chartShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // ==========================================================================
  // INTERACTION COLORS
  // ==========================================================================

  @override
  Color get crosshairColor => primaryColor;

  @override
  Color get highlightColor => primaryColor.withValues(alpha: 0.2);

  @override
  Color get hoverColor => primaryColor.withValues(alpha: 0.12);

  // ==========================================================================
  // THEME METADATA
  // ==========================================================================

  /// Returns the theme name.
  String get name => 'Fusion Dark Theme';

  /// Returns a description of this theme.
  String get description => 'Professional dark color scheme for charts';

  /// Indicates if this is a dark theme.
  bool get isDark => true;

  @override
  String toString() => name;

  @override
  Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  @override
  Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  @override
  Color withOpacity(Color color, double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return color.withValues(alpha: opacity);
  }
}

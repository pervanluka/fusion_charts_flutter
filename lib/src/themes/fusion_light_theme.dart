import 'package:flutter/material.dart';
import 'fusion_chart_theme.dart';

/// Light theme for Fusion Charts.
///
/// Professional light color scheme suitable for most applications.
///
/// ## Color Scheme
///
/// - Primary: Purple (#6C63FF) - Modern, professional
/// - Secondary: Green (#4CAF50) - Positive, growth
/// - Background: White (#FFFFFF) - Clean, bright
/// - Grid: Light Gray (#E0E0E0) - Subtle, non-distracting
/// - Text: Dark Gray (#2C2C2C) - Good contrast (13.5:1)
///
/// ## Usage
///
/// ```dart
/// // Use as default theme
/// FusionLineChart(
///   series: [...],
/// )
///
/// // Or explicitly set
/// final config = FusionChartConfigurationBuilder()
///   .withTheme(FusionLightTheme())
///   .build();
/// ```
///
/// ## Accessibility
///
/// - WCAG 2.1 Level AA compliant
/// - Minimum contrast ratio: 4.5:1
/// - Color-blind friendly palette
class FusionLightTheme extends FusionChartTheme with FusionThemeUtils {
  /// Creates a light theme with default colors.
  const FusionLightTheme();

  // ==========================================================================
  // COLORS
  // ==========================================================================

  @override
  Color get primaryColor => const Color(0xFF6C63FF);

  @override
  Color get secondaryColor => const Color(0xFF4CAF50);

  @override
  Color get backgroundColor => Colors.white;

  @override
  Color get gridColor => const Color(0xFFE0E0E0);

  @override
  Color get textColor => const Color(0xFF2C2C2C);

  @override
  Color get borderColor => const Color(0xFFD0D0D0);

  @override
  Color get axisColor => const Color(0xFFD0D0D0);

  @override
  Color get errorColor => const Color(0xFFF44336);

  @override
  Color get successColor => const Color(0xFF4CAF50);

  @override
  Color get warningColor => const Color(0xFFFF9800);

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
    color: Color(0xFF666666),
    letterSpacing: 0.3,
    height: 1.5,
  );

  @override
  TextStyle get legendStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF666666),
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
  Color get tooltipBackgroundColor => const Color(0xDD000000);

  @override
  Color get markerBorderColor => Colors.white;

  @override
  TextStyle get dataLabelStyle => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Color(0xFF666666),
    letterSpacing: 0.3,
  );

  @override
  EdgeInsets get dataLabelPadding => const EdgeInsets.symmetric(horizontal: 4, vertical: 2);

  @override
  double get dataLabelBackgroundOpacity => 0.9;

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
  double get elevation => 4.0;

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
  double get areaFillOpacity => 0.3;

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
    color: primaryColor.withValues(alpha: 0.2),
    offset: const Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );

  @override
  List<BoxShadow> get chartShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // ==========================================================================
  // INTERACTION COLORS
  // ==========================================================================

  @override
  Color get crosshairColor => primaryColor;

  @override
  Color get highlightColor => primaryColor.withValues(alpha: 0.15);

  @override
  Color get hoverColor => primaryColor.withValues(alpha: 0.08);

  // ==========================================================================
  // THEME METADATA
  // ==========================================================================

  /// Returns the theme name.
  String get name => 'Fusion Light Theme';

  /// Returns a description of this theme.
  String get description => 'Professional light color scheme for charts';

  /// Indicates if this is a dark theme.
  bool get isDark => false;

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

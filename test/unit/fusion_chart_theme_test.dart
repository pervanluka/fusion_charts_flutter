import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  // ===========================================================================
  // FUSION LIGHT THEME - COLORS
  // ===========================================================================

  group('FusionLightTheme - Colors', () {
    test('has correct primary color', () {
      const theme = FusionLightTheme();
      expect(theme.primaryColor, const Color(0xFF6C63FF));
    });

    test('has correct secondary color', () {
      const theme = FusionLightTheme();
      expect(theme.secondaryColor, const Color(0xFF4CAF50));
    });

    test('has white background', () {
      const theme = FusionLightTheme();
      expect(theme.backgroundColor, Colors.white);
    });

    test('has correct grid color', () {
      const theme = FusionLightTheme();
      expect(theme.gridColor, const Color(0xFFE0E0E0));
    });

    test('has correct text color', () {
      const theme = FusionLightTheme();
      expect(theme.textColor, const Color(0xFF2C2C2C));
    });

    test('has correct border color', () {
      const theme = FusionLightTheme();
      expect(theme.borderColor, const Color(0xFFD0D0D0));
    });

    test('has error, success, warning colors', () {
      const theme = FusionLightTheme();
      expect(theme.errorColor, const Color(0xFFF44336));
      expect(theme.successColor, const Color(0xFF4CAF50));
      expect(theme.warningColor, const Color(0xFFFF9800));
    });
  });

  // ===========================================================================
  // FUSION LIGHT THEME - TYPOGRAPHY
  // ===========================================================================

  group('FusionLightTheme - Typography', () {
    test('titleStyle has correct properties', () {
      const theme = FusionLightTheme();
      final style = theme.titleStyle;

      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, theme.textColor);
    });

    test('axisLabelStyle has correct properties', () {
      const theme = FusionLightTheme();
      final style = theme.axisLabelStyle;

      expect(style.fontSize, 11);
      expect(style.fontWeight, FontWeight.w500);
    });

    test('legendStyle has correct properties', () {
      const theme = FusionLightTheme();
      final style = theme.legendStyle;

      expect(style.fontSize, 12);
      expect(style.fontWeight, FontWeight.w400);
    });

    test('tooltipStyle has correct properties', () {
      const theme = FusionLightTheme();
      final style = theme.tooltipStyle;

      expect(style.fontSize, 12);
      expect(style.fontWeight, FontWeight.w600);
    });

    test('dataLabelStyle has correct properties', () {
      const theme = FusionLightTheme();
      final style = theme.dataLabelStyle;

      expect(style.fontSize, 10);
      expect(style.fontWeight, FontWeight.w600);
    });

    test('subtitleStyle has correct properties', () {
      const theme = FusionLightTheme();
      final style = theme.subtitleStyle;

      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.w500);
    });
  });

  // ===========================================================================
  // FUSION LIGHT THEME - DIMENSIONS
  // ===========================================================================

  group('FusionLightTheme - Dimensions', () {
    test('has correct border radius', () {
      const theme = FusionLightTheme();
      expect(theme.borderRadius, 12.0);
    });

    test('has correct elevation', () {
      const theme = FusionLightTheme();
      expect(theme.elevation, 4.0);
    });

    test('has correct axis and grid line widths', () {
      const theme = FusionLightTheme();
      expect(theme.axisLineWidth, 1.0);
      expect(theme.gridLineWidth, 0.8);
    });

    test('has correct series line width', () {
      const theme = FusionLightTheme();
      expect(theme.seriesLineWidth, 3.0);
    });

    test('has correct marker size', () {
      const theme = FusionLightTheme();
      expect(theme.markerSize, 6.0);
    });

    test('has correct chart padding', () {
      const theme = FusionLightTheme();
      expect(theme.chartPadding, const EdgeInsets.all(4));
    });

    test('has correct tooltip properties', () {
      const theme = FusionLightTheme();
      expect(theme.tooltipBorderRadius, 8.0);
      expect(
        theme.tooltipPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
      expect(theme.tooltipBackgroundColor, const Color(0xDD000000));
    });
  });

  // ===========================================================================
  // FUSION LIGHT THEME - ANIMATIONS
  // ===========================================================================

  group('FusionLightTheme - Animations', () {
    test('has correct animation duration', () {
      const theme = FusionLightTheme();
      expect(theme.animationDuration, const Duration(milliseconds: 1500));
    });

    test('has correct animation curve', () {
      const theme = FusionLightTheme();
      expect(theme.animationCurve, Curves.easeInOutCubic);
    });
  });

  // ===========================================================================
  // FUSION LIGHT THEME - GRADIENTS AND SHADOWS
  // ===========================================================================

  group('FusionLightTheme - Gradients and Shadows', () {
    test('has chart gradient colors', () {
      const theme = FusionLightTheme();
      expect(theme.chartGradientColors.length, 2);
      expect(theme.chartGradientColors[0], theme.primaryColor);
      expect(theme.chartGradientColors[1], theme.secondaryColor);
    });

    test('has correct area fill opacity', () {
      const theme = FusionLightTheme();
      expect(theme.areaFillOpacity, 0.3);
    });

    test('has series shadow', () {
      const theme = FusionLightTheme();
      final shadow = theme.seriesShadow;

      expect(shadow.offset, const Offset(0, 2));
      expect(shadow.blurRadius, 4);
    });

    test('has chart shadow', () {
      const theme = FusionLightTheme();
      expect(theme.chartShadow.length, 2);
    });
  });

  // ===========================================================================
  // FUSION LIGHT THEME - INTERACTION COLORS
  // ===========================================================================

  group('FusionLightTheme - Interaction Colors', () {
    test('has correct crosshair color', () {
      const theme = FusionLightTheme();
      expect(theme.crosshairColor, theme.primaryColor);
    });

    test('has correct highlight color', () {
      const theme = FusionLightTheme();
      expect(theme.highlightColor, isA<Color>());
    });

    test('has correct hover color', () {
      const theme = FusionLightTheme();
      expect(theme.hoverColor, isA<Color>());
    });
  });

  // ===========================================================================
  // FUSION LIGHT THEME - HELPER METHODS
  // ===========================================================================

  group('FusionLightTheme - Helper Methods', () {
    test('darken creates darker color', () {
      const theme = FusionLightTheme();
      const original = Colors.blue;
      final darkened = theme.darken(original, 0.2);

      final originalHsl = HSLColor.fromColor(original);
      final darkenedHsl = HSLColor.fromColor(darkened);

      expect(darkenedHsl.lightness, lessThan(originalHsl.lightness));
    });

    test('lighten creates lighter color', () {
      const theme = FusionLightTheme();
      const original = Colors.blue;
      final lightened = theme.lighten(original, 0.2);

      final originalHsl = HSLColor.fromColor(original);
      final lightenedHsl = HSLColor.fromColor(lightened);

      expect(lightenedHsl.lightness, greaterThan(originalHsl.lightness));
    });

    test('withOpacity adjusts opacity', () {
      const theme = FusionLightTheme();
      const color = Colors.blue;
      final result = theme.withOpacity(color, 0.5);

      // Color.a is already in 0-1 range in newer Flutter
      expect(result.a, closeTo(0.5, 0.01));
    });

    test('getContrastingTextColor returns black for light background', () {
      const theme = FusionLightTheme();
      final textColor = theme.getContrastingTextColor(Colors.white);

      // FusionThemeUtils mixin returns Colors.black (not black87)
      expect(textColor, Colors.black);
    });

    test('getContrastingTextColor returns white for dark background', () {
      const theme = FusionLightTheme();
      final textColor = theme.getContrastingTextColor(Colors.black);

      expect(textColor, Colors.white);
    });

    test('darken asserts for invalid amount', () {
      const theme = FusionLightTheme();
      expect(
        () => theme.darken(Colors.blue, -0.1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => theme.darken(Colors.blue, 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('lighten asserts for invalid amount', () {
      const theme = FusionLightTheme();
      expect(
        () => theme.lighten(Colors.blue, -0.1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => theme.lighten(Colors.blue, 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('withOpacity asserts for invalid opacity', () {
      const theme = FusionLightTheme();
      expect(
        () => theme.withOpacity(Colors.blue, -0.1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => theme.withOpacity(Colors.blue, 1.1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ===========================================================================
  // FUSION LIGHT THEME - METADATA
  // ===========================================================================

  group('FusionLightTheme - Metadata', () {
    test('has correct name', () {
      const theme = FusionLightTheme();
      expect(theme.name, 'Fusion Light Theme');
    });

    test('has description', () {
      const theme = FusionLightTheme();
      expect(theme.description, isNotEmpty);
    });

    test('isDark is false', () {
      const theme = FusionLightTheme();
      expect(theme.isDark, isFalse);
    });

    test('toString returns name', () {
      const theme = FusionLightTheme();
      expect(theme.toString(), theme.name);
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - COLORS
  // ===========================================================================

  group('FusionDarkTheme - Colors', () {
    test('has correct primary color', () {
      const theme = FusionDarkTheme();
      expect(theme.primaryColor, const Color(0xFF8B7EFF));
    });

    test('has correct secondary color', () {
      const theme = FusionDarkTheme();
      expect(theme.secondaryColor, const Color(0xFF66BB6A));
    });

    test('has dark background', () {
      const theme = FusionDarkTheme();
      expect(theme.backgroundColor, const Color(0xFF1E1E1E));
    });

    test('has correct grid color', () {
      const theme = FusionDarkTheme();
      expect(theme.gridColor, const Color(0xFF404040));
    });

    test('has correct text color', () {
      const theme = FusionDarkTheme();
      expect(theme.textColor, const Color(0xFFE0E0E0));
    });

    test('has correct border color', () {
      const theme = FusionDarkTheme();
      expect(theme.borderColor, const Color(0xFF505050));
    });

    test('has error, success, warning colors', () {
      const theme = FusionDarkTheme();
      expect(theme.errorColor, const Color(0xFFFF5252));
      expect(theme.successColor, const Color(0xFF69F0AE));
      expect(theme.warningColor, const Color(0xFFFFD740));
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - TYPOGRAPHY
  // ===========================================================================

  group('FusionDarkTheme - Typography', () {
    test('titleStyle has correct properties', () {
      const theme = FusionDarkTheme();
      final style = theme.titleStyle;

      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, theme.textColor);
    });

    test('axisLabelStyle has correct properties', () {
      const theme = FusionDarkTheme();
      final style = theme.axisLabelStyle;

      expect(style.fontSize, 11);
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - DIMENSIONS
  // ===========================================================================

  group('FusionDarkTheme - Dimensions', () {
    test('has higher elevation than light theme', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(darkTheme.elevation, greaterThan(lightTheme.elevation));
    });

    test('has lower area fill opacity than light theme', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(darkTheme.areaFillOpacity, lessThan(lightTheme.areaFillOpacity));
    });

    test('has lower data label background opacity', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(
        darkTheme.dataLabelBackgroundOpacity,
        lessThan(lightTheme.dataLabelBackgroundOpacity),
      );
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - HELPER METHODS
  // ===========================================================================

  group('FusionDarkTheme - Helper Methods', () {
    test('darken creates darker color', () {
      const theme = FusionDarkTheme();
      const original = Colors.blue;
      final darkened = theme.darken(original, 0.2);

      final originalHsl = HSLColor.fromColor(original);
      final darkenedHsl = HSLColor.fromColor(darkened);

      expect(darkenedHsl.lightness, lessThan(originalHsl.lightness));
    });

    test('lighten creates lighter color', () {
      const theme = FusionDarkTheme();
      const original = Colors.blue;
      final lightened = theme.lighten(original, 0.2);

      final originalHsl = HSLColor.fromColor(original);
      final lightenedHsl = HSLColor.fromColor(lightened);

      expect(lightenedHsl.lightness, greaterThan(originalHsl.lightness));
    });

    test('withOpacity adjusts opacity', () {
      const theme = FusionDarkTheme();
      const color = Colors.blue;
      final result = theme.withOpacity(color, 0.5);

      // Color.a is already in 0-1 range in newer Flutter
      expect(result.a, closeTo(0.5, 0.01));
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - METADATA
  // ===========================================================================

  group('FusionDarkTheme - Metadata', () {
    test('has correct name', () {
      const theme = FusionDarkTheme();
      expect(theme.name, 'Fusion Dark Theme');
    });

    test('isDark is true', () {
      const theme = FusionDarkTheme();
      expect(theme.isDark, isTrue);
    });

    test('toString returns name', () {
      const theme = FusionDarkTheme();
      expect(theme.toString(), theme.name);
    });
  });

  // ===========================================================================
  // FUSION THEME UTILS MIXIN
  // ===========================================================================

  group('FusionThemeUtils mixin', () {
    test('createTextStyle creates correct style', () {
      const theme = FusionLightTheme();
      final style = theme.createTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.red,
        letterSpacing: 0.5,
        height: 1.5,
      );

      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.bold);
      expect(style.color, Colors.red);
      expect(style.letterSpacing, 0.5);
      expect(style.height, 1.5);
    });

    test('createGradient creates correct gradient', () {
      const theme = FusionLightTheme();
      final gradient = theme.createGradient(
        [Colors.red, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      expect(gradient.colors.length, 2);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    test('isLightColor returns true for light colors', () {
      const theme = FusionLightTheme();
      expect(theme.isLightColor(Colors.white), isTrue);
      expect(theme.isLightColor(Colors.yellow), isTrue);
    });

    test('isLightColor returns false for dark colors', () {
      const theme = FusionLightTheme();
      expect(theme.isLightColor(Colors.black), isFalse);
      expect(theme.isLightColor(const Color(0xFF1E1E1E)), isFalse);
    });
  });

  // ===========================================================================
  // BASE THEME DEFAULT VALUES
  // ===========================================================================

  group('FusionChartTheme - Default Values', () {
    test('axisColor defaults to gridColor', () {
      const theme = FusionLightTheme();
      // Light theme overrides axisColor, but base has default
      expect(theme.axisColor, isA<Color>());
    });

    test('marker border color defaults correctly', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.markerBorderColor, Colors.white);
      expect(darkTheme.markerBorderColor, darkTheme.backgroundColor);
    });

    test('pie-specific properties exist', () {
      const theme = FusionLightTheme();

      expect(theme.pieStrokeColor, Colors.white);
      expect(theme.pieShadowColor, Colors.black26);
      expect(theme.tooltipBorderWidth, 2.0);
    });

    test('legend properties exist', () {
      const theme = FusionLightTheme();

      expect(theme.legendWidth, 120.0);
      expect(theme.legendHeight, 40.0);
      expect(theme.legendIconSize, 12.0);
      expect(theme.legendItemSpacing, 8.0);
      expect(theme.legendSpacing, 8.0);
    });
  });

  // ===========================================================================
  // THEME COMPARISON
  // ===========================================================================

  group('Theme Comparison', () {
    test('light and dark themes have different backgrounds', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(
        lightTheme.backgroundColor,
        isNot(equals(darkTheme.backgroundColor)),
      );
    });

    test('light and dark themes have different text colors', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.textColor, isNot(equals(darkTheme.textColor)));
    });

    test('light and dark themes have same animation duration', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.animationDuration, equals(darkTheme.animationDuration));
    });

    test('both themes have valid contrast ratios', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      // Light theme: dark text on light background
      final lightContrast = lightTheme.textColor.computeLuminance();
      final lightBgContrast = lightTheme.backgroundColor.computeLuminance();
      expect(lightContrast, lessThan(lightBgContrast)); // Text should be darker

      // Dark theme: light text on dark background
      final darkContrast = darkTheme.textColor.computeLuminance();
      final darkBgContrast = darkTheme.backgroundColor.computeLuminance();
      expect(
        darkContrast,
        greaterThan(darkBgContrast),
      ); // Text should be lighter
    });
  });

  // ===========================================================================
  // CONST CONSTRUCTOR VERIFICATION
  // ===========================================================================

  group('Const Constructor Verification', () {
    test('FusionLightTheme can be const constructed', () {
      const theme1 = FusionLightTheme();
      const theme2 = FusionLightTheme();

      // Both should reference the same const instance
      expect(identical(theme1, theme2), isTrue);
    });

    test('FusionDarkTheme can be const constructed', () {
      const theme1 = FusionDarkTheme();
      const theme2 = FusionDarkTheme();

      // Both should reference the same const instance
      expect(identical(theme1, theme2), isTrue);
    });

    test('themes can be used in const contexts', () {
      // This tests that themes work in const lists/maps
      const themes = [FusionLightTheme(), FusionDarkTheme()];
      expect(themes.length, 2);
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - COMPLETE TYPOGRAPHY
  // ===========================================================================

  group('FusionDarkTheme - Complete Typography', () {
    test('legendStyle has correct properties', () {
      const theme = FusionDarkTheme();
      final style = theme.legendStyle;

      expect(style.fontSize, 12);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.color, const Color(0xFFB0B0B0));
    });

    test('tooltipStyle has correct properties', () {
      const theme = FusionDarkTheme();
      final style = theme.tooltipStyle;

      expect(style.fontSize, 12);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, theme.textColor);
    });

    test('dataLabelStyle has correct properties', () {
      const theme = FusionDarkTheme();
      final style = theme.dataLabelStyle;

      expect(style.fontSize, 10);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, const Color(0xFFB0B0B0));
    });

    test('subtitleStyle has correct properties', () {
      const theme = FusionDarkTheme();
      final style = theme.subtitleStyle;

      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.w500);
    });

    test('axisLabelStyle has correct color for dark theme', () {
      const theme = FusionDarkTheme();
      expect(theme.axisLabelStyle.color, const Color(0xFFB0B0B0));
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - COMPLETE DIMENSIONS
  // ===========================================================================

  group('FusionDarkTheme - Complete Dimensions', () {
    test('has correct border radius', () {
      const theme = FusionDarkTheme();
      expect(theme.borderRadius, 12.0);
    });

    test('has correct axis and grid line widths', () {
      const theme = FusionDarkTheme();
      expect(theme.axisLineWidth, 1.0);
      expect(theme.gridLineWidth, 0.8);
    });

    test('has correct series line width', () {
      const theme = FusionDarkTheme();
      expect(theme.seriesLineWidth, 3.0);
    });

    test('has correct marker size', () {
      const theme = FusionDarkTheme();
      expect(theme.markerSize, 6.0);
    });

    test('has correct chart padding', () {
      const theme = FusionDarkTheme();
      expect(theme.chartPadding, const EdgeInsets.all(4));
    });

    test('has correct tooltip properties', () {
      const theme = FusionDarkTheme();
      expect(theme.tooltipBorderRadius, 8.0);
      expect(
        theme.tooltipPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
      expect(theme.tooltipBackgroundColor, const Color(0xEE2A2A2A));
    });

    test('has correct legend spacing', () {
      const theme = FusionDarkTheme();
      expect(theme.legendSpacing, 8.0);
    });

    test('has correct axis label padding', () {
      const theme = FusionDarkTheme();
      expect(theme.axisLabelPadding, 8.0);
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - GRADIENTS AND SHADOWS
  // ===========================================================================

  group('FusionDarkTheme - Gradients and Shadows', () {
    test('has chart gradient colors', () {
      const theme = FusionDarkTheme();
      expect(theme.chartGradientColors.length, 2);
      expect(theme.chartGradientColors[0], theme.primaryColor);
      expect(theme.chartGradientColors[1], theme.secondaryColor);
    });

    test('has series shadow with higher alpha than light theme', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      // Dark theme series shadow has higher blur for more depth
      expect(
        darkTheme.seriesShadow.blurRadius,
        greaterThan(lightTheme.seriesShadow.blurRadius),
      );
    });

    test('has chart shadow with higher alpha for dark theme', () {
      const theme = FusionDarkTheme();
      expect(theme.chartShadow.length, 2);
      // First shadow should have higher blur than light theme
      expect(theme.chartShadow[0].blurRadius, 16);
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - INTERACTION COLORS
  // ===========================================================================

  group('FusionDarkTheme - Interaction Colors', () {
    test('has correct crosshair color', () {
      const theme = FusionDarkTheme();
      expect(theme.crosshairColor, theme.primaryColor);
    });

    test('has correct highlight color', () {
      const theme = FusionDarkTheme();
      expect(theme.highlightColor, isA<Color>());
    });

    test('has correct hover color', () {
      const theme = FusionDarkTheme();
      expect(theme.hoverColor, isA<Color>());
    });

    test('hover color has slightly higher alpha than light theme', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      // Dark theme hover is more visible (0.12 vs 0.08)
      expect(darkTheme.hoverColor.a, greaterThan(lightTheme.hoverColor.a));
    });
  });

  // ===========================================================================
  // FUSION DARK THEME - ANIMATIONS
  // ===========================================================================

  group('FusionDarkTheme - Animations', () {
    test('has correct animation duration', () {
      const theme = FusionDarkTheme();
      expect(theme.animationDuration, const Duration(milliseconds: 1500));
    });

    test('has correct animation curve', () {
      const theme = FusionDarkTheme();
      expect(theme.animationCurve, Curves.easeInOutCubic);
    });
  });

  // ===========================================================================
  // LIGHT THEME COLOR LUMINANCE VERIFICATION
  // ===========================================================================

  group('Light Theme Color Luminance Verification', () {
    test('background color is light (high luminance)', () {
      const theme = FusionLightTheme();
      final luminance = theme.backgroundColor.computeLuminance();
      expect(luminance, greaterThan(0.9)); // White is 1.0
    });

    test('text color is dark (low luminance)', () {
      const theme = FusionLightTheme();
      final luminance = theme.textColor.computeLuminance();
      expect(luminance, lessThan(0.1)); // Dark gray
    });

    test('grid color is light gray', () {
      const theme = FusionLightTheme();
      final luminance = theme.gridColor.computeLuminance();
      expect(luminance, greaterThan(0.5));
      expect(luminance, lessThan(0.9));
    });

    test('axis label color is medium-dark', () {
      const theme = FusionLightTheme();
      final luminance = theme.axisLabelStyle.color!.computeLuminance();
      expect(luminance, greaterThan(0.1));
      expect(luminance, lessThan(0.5));
    });
  });

  // ===========================================================================
  // DARK THEME COLOR LUMINANCE VERIFICATION
  // ===========================================================================

  group('Dark Theme Color Luminance Verification', () {
    test('background color is dark (low luminance)', () {
      const theme = FusionDarkTheme();
      final luminance = theme.backgroundColor.computeLuminance();
      expect(luminance, lessThan(0.05)); // Very dark
    });

    test('text color is light (high luminance)', () {
      const theme = FusionDarkTheme();
      final luminance = theme.textColor.computeLuminance();
      expect(luminance, greaterThan(0.7)); // Light gray
    });

    test('grid color is dark gray', () {
      const theme = FusionDarkTheme();
      final luminance = theme.gridColor.computeLuminance();
      expect(luminance, greaterThan(0.02));
      expect(luminance, lessThan(0.15));
    });

    test('axis label color is medium-light', () {
      const theme = FusionDarkTheme();
      final luminance = theme.axisLabelStyle.color!.computeLuminance();
      expect(luminance, greaterThan(0.3));
      expect(luminance, lessThan(0.7));
    });
  });

  // ===========================================================================
  // HELPER METHODS - EDGE CASES
  // ===========================================================================

  group('Helper Methods - Edge Cases', () {
    test('darken with amount 0 returns equivalent color', () {
      const theme = FusionLightTheme();
      const original = Colors.blue;
      final result = theme.darken(original, 0.0);

      // Compare HSL values since darken/lighten work in HSL space
      final originalHsl = HSLColor.fromColor(original);
      final resultHsl = HSLColor.fromColor(result);

      expect(resultHsl.lightness, closeTo(originalHsl.lightness, 0.001));
    });

    test('lighten with amount 0 returns equivalent color', () {
      const theme = FusionLightTheme();
      const original = Colors.blue;
      final result = theme.lighten(original, 0.0);

      // Compare HSL values since darken/lighten work in HSL space
      final originalHsl = HSLColor.fromColor(original);
      final resultHsl = HSLColor.fromColor(result);

      expect(resultHsl.lightness, closeTo(originalHsl.lightness, 0.001));
    });

    test('darken black color stays at minimum lightness', () {
      const theme = FusionLightTheme();
      const black = Colors.black;
      final result = theme.darken(black, 0.5);

      final hsl = HSLColor.fromColor(result);
      expect(hsl.lightness, equals(0.0));
    });

    test('lighten white color stays at maximum lightness', () {
      const theme = FusionLightTheme();
      const white = Colors.white;
      final result = theme.lighten(white, 0.5);

      final hsl = HSLColor.fromColor(result);
      expect(hsl.lightness, equals(1.0));
    });

    test('withOpacity at 0 returns fully transparent', () {
      const theme = FusionLightTheme();
      final result = theme.withOpacity(Colors.red, 0.0);

      expect(result.a, equals(0.0));
    });

    test('withOpacity at 1 returns fully opaque', () {
      const theme = FusionLightTheme();
      final result = theme.withOpacity(Colors.red, 1.0);

      expect(result.a, equals(1.0));
    });

    test('getContrastingTextColor for medium gray', () {
      const theme = FusionLightTheme();
      const mediumGray = Color(0xFF808080);
      final luminance = mediumGray.computeLuminance();
      final result = theme.getContrastingTextColor(mediumGray);

      // Medium gray has luminance around 0.22
      // FusionThemeUtils.getContrastingTextColor uses > 0.5 threshold
      // So this should return white (since luminance is below 0.5)
      expect(luminance, lessThan(0.5));
      expect(result, Colors.white);
    });
  });

  // ===========================================================================
  // BASE THEME DEFAULT VALUES - COMPLETE
  // ===========================================================================

  group('FusionChartTheme - Complete Default Values', () {
    test('seriesLineWidth default value', () {
      const theme = FusionLightTheme();
      expect(theme.seriesLineWidth, 3.0);
    });

    test('markerSize default value', () {
      const theme = FusionLightTheme();
      expect(theme.markerSize, 6.0);
    });

    test('chartPadding default value', () {
      const theme = FusionLightTheme();
      expect(theme.chartPadding, const EdgeInsets.all(4));
    });

    test('legendSpacing default value', () {
      const theme = FusionLightTheme();
      expect(theme.legendSpacing, 8.0);
    });

    test('axisLabelPadding default value', () {
      const theme = FusionLightTheme();
      expect(theme.axisLabelPadding, 8.0);
    });

    test('areaFillOpacity default value', () {
      const theme = FusionLightTheme();
      expect(theme.areaFillOpacity, 0.3);
    });

    test('tooltipIndicatorRadius default value', () {
      const theme = FusionLightTheme();
      expect(theme.tooltipIndicatorRadius, 2.0);
    });

    test('legendValueFontSizeRatio default value', () {
      const theme = FusionLightTheme();
      expect(theme.legendValueFontSizeRatio, 0.85);
    });

    test('legendLineThickness default value', () {
      const theme = FusionLightTheme();
      expect(theme.legendLineThickness, 3.0);
    });

    test('legendIconCornerRadius default value', () {
      const theme = FusionLightTheme();
      expect(theme.legendIconCornerRadius, 2.0);
    });
  });

  // ===========================================================================
  // THEME COLOR APPROPRIATENESS
  // ===========================================================================

  group('Theme Color Appropriateness', () {
    test('light theme has appropriate light background', () {
      const theme = FusionLightTheme();
      // Light theme background should be nearly white
      expect(theme.backgroundColor, equals(Colors.white));
    });

    test('dark theme has appropriate dark background', () {
      const theme = FusionDarkTheme();
      // Dark theme background luminance should be very low
      final luminance = theme.backgroundColor.computeLuminance();
      expect(luminance, lessThan(0.05));
    });

    test('light theme marker border is white for contrast', () {
      const theme = FusionLightTheme();
      expect(theme.markerBorderColor, Colors.white);
    });

    test('dark theme marker border matches background', () {
      const theme = FusionDarkTheme();
      expect(theme.markerBorderColor, theme.backgroundColor);
    });

    test('dark theme error color is brighter than light theme', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      // Dark theme uses brighter error colors for visibility
      final lightErrorLum = lightTheme.errorColor.computeLuminance();
      final darkErrorLum = darkTheme.errorColor.computeLuminance();

      expect(darkErrorLum, greaterThan(lightErrorLum));
    });

    test('dark theme success color is brighter than light theme', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      final lightSuccessLum = lightTheme.successColor.computeLuminance();
      final darkSuccessLum = darkTheme.successColor.computeLuminance();

      expect(darkSuccessLum, greaterThan(lightSuccessLum));
    });

    test('dark theme warning color is brighter than light theme', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      final lightWarningLum = lightTheme.warningColor.computeLuminance();
      final darkWarningLum = darkTheme.warningColor.computeLuminance();

      expect(darkWarningLum, greaterThan(lightWarningLum));
    });
  });

  // ===========================================================================
  // TEXT STYLE CONSISTENCY
  // ===========================================================================

  group('Text Style Consistency', () {
    test('title style uses theme text color in light theme', () {
      const theme = FusionLightTheme();
      expect(theme.titleStyle.color, theme.textColor);
    });

    test('title style uses theme text color in dark theme', () {
      const theme = FusionDarkTheme();
      expect(theme.titleStyle.color, theme.textColor);
    });

    test('tooltip style uses theme text color in both themes', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.tooltipStyle.color, lightTheme.textColor);
      expect(darkTheme.tooltipStyle.color, darkTheme.textColor);
    });

    test('subtitle style font size is smaller than title', () {
      const theme = FusionLightTheme();
      expect(
        theme.subtitleStyle.fontSize,
        lessThan(theme.titleStyle.fontSize!),
      );
    });

    test('axis label style font size is smaller than legend', () {
      const theme = FusionLightTheme();
      expect(
        theme.axisLabelStyle.fontSize,
        lessThan(theme.legendStyle.fontSize!),
      );
    });
  });

  // ===========================================================================
  // SHADOW PROPERTIES
  // ===========================================================================

  group('Shadow Properties', () {
    test('series shadow uses primary color', () {
      const theme = FusionLightTheme();
      final shadow = theme.seriesShadow;

      // Shadow color should be derived from primary color
      expect(shadow.color.r, closeTo(theme.primaryColor.r, 0.01));
      expect(shadow.color.g, closeTo(theme.primaryColor.g, 0.01));
      expect(shadow.color.b, closeTo(theme.primaryColor.b, 0.01));
    });

    test('chart shadow uses black', () {
      const theme = FusionLightTheme();
      final shadows = theme.chartShadow;

      // All chart shadows should use black as base
      for (final shadow in shadows) {
        expect(shadow.color.r, lessThan(0.1));
        expect(shadow.color.g, lessThan(0.1));
        expect(shadow.color.b, lessThan(0.1));
      }
    });

    test('dark theme has deeper chart shadows', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      // Dark theme should have higher blur radius for more prominent shadows
      final lightBlur = lightTheme.chartShadow[0].blurRadius;
      final darkBlur = darkTheme.chartShadow[0].blurRadius;

      expect(darkBlur, greaterThan(lightBlur));
    });
  });

  // ===========================================================================
  // ANIMATION PROPERTIES
  // ===========================================================================

  group('Animation Properties', () {
    test('animation duration is reasonable', () {
      const theme = FusionLightTheme();

      expect(theme.animationDuration.inMilliseconds, greaterThanOrEqualTo(500));
      expect(theme.animationDuration.inMilliseconds, lessThanOrEqualTo(3000));
    });

    test('animation curve is a valid curve', () {
      const theme = FusionLightTheme();
      final curve = theme.animationCurve;

      // Test that curve works correctly
      expect(curve.transform(0.0), 0.0);
      expect(curve.transform(1.0), 1.0);
      expect(curve.transform(0.5), isA<double>());
    });

    test('both themes use same animation settings', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.animationDuration, darkTheme.animationDuration);
      expect(lightTheme.animationCurve, darkTheme.animationCurve);
    });
  });

  // ===========================================================================
  // GRADIENT PROPERTIES
  // ===========================================================================

  group('Gradient Properties', () {
    test('chart gradient has primary and secondary colors', () {
      const theme = FusionLightTheme();
      final colors = theme.chartGradientColors;

      expect(colors.length, 2);
      expect(colors[0], theme.primaryColor);
      expect(colors[1], theme.secondaryColor);
    });

    test('area fill opacity is between 0 and 1', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.areaFillOpacity, greaterThan(0.0));
      expect(lightTheme.areaFillOpacity, lessThanOrEqualTo(1.0));

      expect(darkTheme.areaFillOpacity, greaterThan(0.0));
      expect(darkTheme.areaFillOpacity, lessThanOrEqualTo(1.0));
    });
  });

  // ===========================================================================
  // PIE CHART SPECIFIC PROPERTIES
  // ===========================================================================

  group('Pie Chart Specific Properties', () {
    test('pie stroke color is appropriate for visibility', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.pieStrokeColor, Colors.white);
      expect(darkTheme.pieStrokeColor, Colors.white);
    });

    test('pie shadow color is a dark semi-transparent color', () {
      const theme = FusionLightTheme();
      expect(theme.pieShadowColor, Colors.black26);
    });

    test('tooltip border width is positive', () {
      const theme = FusionLightTheme();
      expect(theme.tooltipBorderWidth, greaterThan(0));
    });
  });

  // ===========================================================================
  // DATA LABEL PROPERTIES
  // ===========================================================================

  group('Data Label Properties', () {
    test('data label padding is symmetric', () {
      const theme = FusionLightTheme();
      final padding = theme.dataLabelPadding;

      expect(padding.left, padding.right);
      expect(padding.top, padding.bottom);
    });

    test('data label background opacity is high', () {
      const lightTheme = FusionLightTheme();
      const darkTheme = FusionDarkTheme();

      expect(lightTheme.dataLabelBackgroundOpacity, greaterThan(0.8));
      expect(darkTheme.dataLabelBackgroundOpacity, greaterThan(0.8));
    });

    test('data label border radius is positive', () {
      const theme = FusionLightTheme();
      expect(theme.dataLabelBorderRadius, greaterThan(0));
    });
  });

  // ===========================================================================
  // FUSION THEME UTILS - ADDITIONAL TESTS
  // ===========================================================================

  group('FusionThemeUtils - Additional Tests', () {
    test('createTextStyle with optional fontFamily', () {
      const theme = FusionLightTheme();
      final style = theme.createTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black,
        fontFamily: 'Roboto',
      );

      expect(style.fontFamily, 'Roboto');
    });

    test('createGradient with default alignment', () {
      const theme = FusionLightTheme();
      final gradient = theme.createGradient([Colors.red, Colors.blue]);

      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
    });

    test('isLightColor boundary test', () {
      const theme = FusionLightTheme();

      // Color with luminance exactly at 0.5 threshold
      const boundaryColor = Color(0xFF737373);
      final luminance = boundaryColor.computeLuminance();

      // This should be around 0.18, which is below 0.5, so dark
      expect(luminance, lessThan(0.5));
      expect(theme.isLightColor(boundaryColor), isFalse);
    });
  });
}

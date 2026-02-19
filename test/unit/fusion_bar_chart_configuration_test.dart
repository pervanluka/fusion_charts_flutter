import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_bar_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_dark_theme.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_light_theme.dart';

void main() {
  // ===========================================================================
  // FUSION BAR CHART CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionBarChartConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionBarChartConfiguration();

      expect(config.enableSideBySideSeriesPlacement, isTrue);
      expect(config.barWidthRatio, 0.8);
      expect(config.barSpacing, 0.2);
      expect(config.borderRadius, 0.0);
      expect(config.enableBarShadow, isFalse);
      expect(config.theme, isA<FusionLightTheme>());
      expect(config.enableAnimation, isTrue);
    });

    test('creates with custom values', () {
      const config = FusionBarChartConfiguration(
        theme: FusionDarkTheme(),
        enableSideBySideSeriesPlacement: false,
        barWidthRatio: 0.6,
        barSpacing: 0.1,
        borderRadius: 8.0,
        enableBarShadow: true,
        enableAnimation: false,
        enableTooltip: false,
      );

      expect(config.theme, isA<FusionDarkTheme>());
      expect(config.enableSideBySideSeriesPlacement, isFalse);
      expect(config.barWidthRatio, 0.6);
      expect(config.barSpacing, 0.1);
      expect(config.borderRadius, 8.0);
      expect(config.enableBarShadow, isTrue);
      expect(config.enableAnimation, isFalse);
      expect(config.enableTooltip, isFalse);
    });
  });

  // ===========================================================================
  // FUSION BAR CHART CONFIGURATION - ASSERTIONS
  // ===========================================================================
  group('FusionBarChartConfiguration - Assertions', () {
    test('throws assertion error for invalid barWidthRatio (zero)', () {
      expect(
        () => FusionBarChartConfiguration(barWidthRatio: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid barWidthRatio (> 1)', () {
      expect(
        () => FusionBarChartConfiguration(barWidthRatio: 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid barSpacing (negative)', () {
      expect(
        () => FusionBarChartConfiguration(barSpacing: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid barSpacing (> 1)', () {
      expect(
        () => FusionBarChartConfiguration(barSpacing: 1.5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for negative borderRadius', () {
      expect(
        () => FusionBarChartConfiguration(borderRadius: -1.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts boundary values', () {
      expect(
        () => const FusionBarChartConfiguration(
          barWidthRatio: 0.01,
          barSpacing: 0.0,
          borderRadius: 0.0,
        ),
        returnsNormally,
      );

      expect(
        () => const FusionBarChartConfiguration(
          barWidthRatio: 1.0,
          barSpacing: 1.0,
        ),
        returnsNormally,
      );
    });
  });

  // ===========================================================================
  // FUSION BAR CHART CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionBarChartConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionBarChartConfiguration(
        enableSideBySideSeriesPlacement: true,
        barWidthRatio: 0.8,
      );

      final copy = original.copyWith(
        enableSideBySideSeriesPlacement: false,
        barWidthRatio: 0.5,
      );

      expect(copy.enableSideBySideSeriesPlacement, isFalse);
      expect(copy.barWidthRatio, 0.5);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionBarChartConfiguration(
        enableSideBySideSeriesPlacement: true,
        barWidthRatio: 0.7,
        barSpacing: 0.15,
        borderRadius: 4.0,
        enableBarShadow: true,
      );

      final copy = original.copyWith(enableBarShadow: false);

      expect(copy.enableSideBySideSeriesPlacement, isTrue);
      expect(copy.barWidthRatio, 0.7);
      expect(copy.barSpacing, 0.15);
      expect(copy.borderRadius, 4.0);
      expect(copy.enableBarShadow, isFalse);
    });

    test('copyWith handles all parameters', () {
      const original = FusionBarChartConfiguration();

      final copy = original.copyWith(
        theme: const FusionDarkTheme(),
        enableAnimation: false,
        enableTooltip: false,
        enableCrosshair: true,
        enableZoom: true,
        enablePanning: true,
        enableSideBySideSeriesPlacement: false,
        barWidthRatio: 0.9,
        barSpacing: 0.3,
        borderRadius: 10.0,
        enableBarShadow: true,
      );

      expect(copy.theme, isA<FusionDarkTheme>());
      expect(copy.enableAnimation, isFalse);
      expect(copy.enableTooltip, isFalse);
      expect(copy.enableCrosshair, isTrue);
      expect(copy.enableZoom, isTrue);
      expect(copy.enablePanning, isTrue);
      expect(copy.enableSideBySideSeriesPlacement, isFalse);
      expect(copy.barWidthRatio, 0.9);
      expect(copy.barSpacing, 0.3);
      expect(copy.borderRadius, 10.0);
      expect(copy.enableBarShadow, isTrue);
    });
  });

  // ===========================================================================
  // FUSION BAR CHART CONFIGURATION - EQUALITY
  // ===========================================================================
  group('FusionBarChartConfiguration - Equality', () {
    test('equal configs are equal', () {
      const config1 = FusionBarChartConfiguration(
        enableSideBySideSeriesPlacement: true,
        barWidthRatio: 0.8,
        barSpacing: 0.2,
      );

      const config2 = FusionBarChartConfiguration(
        enableSideBySideSeriesPlacement: true,
        barWidthRatio: 0.8,
        barSpacing: 0.2,
      );

      expect(config1, equals(config2));
    });

    test('different configs are not equal', () {
      const config1 = FusionBarChartConfiguration(barWidthRatio: 0.8);

      const config2 = FusionBarChartConfiguration(barWidthRatio: 0.6);

      expect(config1, isNot(equals(config2)));
    });

    test('hashCode is consistent', () {
      const config1 = FusionBarChartConfiguration(
        enableSideBySideSeriesPlacement: true,
        barWidthRatio: 0.8,
      );

      const config2 = FusionBarChartConfiguration(
        enableSideBySideSeriesPlacement: true,
        barWidthRatio: 0.8,
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('identical configs are equal', () {
      const config = FusionBarChartConfiguration();
      expect(config == config, isTrue);
    });
  });

  // ===========================================================================
  // FUSION BAR CHART CONFIGURATION - TOSTRING
  // ===========================================================================
  group('FusionBarChartConfiguration - toString', () {
    test('toString returns descriptive string', () {
      const config = FusionBarChartConfiguration(
        enableSideBySideSeriesPlacement: false,
        barWidthRatio: 0.6,
      );

      final str = config.toString();

      expect(str, contains('FusionBarChartConfiguration'));
      expect(str, contains('enableSideBySideSeriesPlacement: false'));
      expect(str, contains('barWidthRatio: 0.6'));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_crosshair_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_pan_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_zoom_configuration.dart';
import 'package:fusion_charts_flutter/src/core/enums/interaction_anchor_mode.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_dark_theme.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_light_theme.dart';

void main() {
  // ===========================================================================
  // FUSION CHART CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionChartConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionChartConfiguration();

      expect(config.theme, isA<FusionLightTheme>());
      expect(config.tooltipBehavior, isA<FusionTooltipBehavior>());
      expect(config.crosshairBehavior, isA<FusionCrosshairConfiguration>());
      expect(config.zoomBehavior, isA<FusionZoomConfiguration>());
      expect(config.panBehavior, isA<FusionPanConfiguration>());
      expect(
        config.interactionAnchorMode,
        InteractionAnchorMode.screenPosition,
      );
      expect(config.enableAnimation, isTrue);
      expect(config.enableTooltip, isTrue);
      expect(config.enableCrosshair, isFalse);
      expect(config.enableZoom, isFalse);
      expect(config.enablePanning, isFalse);
      expect(config.enableSelection, isTrue);
      expect(config.enableLegend, isTrue);
      expect(config.enableDataLabels, isFalse);
      expect(config.enableBorder, isFalse);
      expect(config.enableGrid, isTrue);
      expect(config.enableAxis, isTrue);
      expect(config.padding, const EdgeInsets.all(4));
      expect(config.animationDuration, isNull);
      expect(config.animationCurve, isNull);
    });

    test('creates with custom theme', () {
      const config = FusionChartConfiguration(theme: FusionDarkTheme());

      expect(config.theme, isA<FusionDarkTheme>());
    });

    test('creates with custom values', () {
      final config = FusionChartConfiguration(
        theme: const FusionDarkTheme(),
        tooltipBehavior: const FusionTooltipBehavior(shared: true),
        crosshairBehavior: const FusionCrosshairConfiguration(),
        zoomBehavior: const FusionZoomConfiguration(maxZoomLevel: 20.0),
        panBehavior: const FusionPanConfiguration(),
        interactionAnchorMode: InteractionAnchorMode.dataPoint,
        enableAnimation: false,
        enableTooltip: false,
        enableCrosshair: true,
        enableZoom: true,
        enablePanning: true,
        enableSelection: false,
        enableLegend: false,
        enableDataLabels: true,
        enableBorder: true,
        enableGrid: false,
        enableAxis: false,
        padding: const EdgeInsets.all(16),
        animationDuration: const Duration(milliseconds: 500),
        animationCurve: Curves.easeInOut,
      );

      expect(config.theme, isA<FusionDarkTheme>());
      expect(config.tooltipBehavior.shared, isTrue);
      expect(config.zoomBehavior.maxZoomLevel, 20.0);
      expect(config.interactionAnchorMode, InteractionAnchorMode.dataPoint);
      expect(config.enableAnimation, isFalse);
      expect(config.enableTooltip, isFalse);
      expect(config.enableCrosshair, isTrue);
      expect(config.enableZoom, isTrue);
      expect(config.enablePanning, isTrue);
      expect(config.enableSelection, isFalse);
      expect(config.enableLegend, isFalse);
      expect(config.enableDataLabels, isTrue);
      expect(config.enableBorder, isTrue);
      expect(config.enableGrid, isFalse);
      expect(config.enableAxis, isFalse);
      expect(config.padding, const EdgeInsets.all(16));
      expect(config.animationDuration, const Duration(milliseconds: 500));
      expect(config.animationCurve, Curves.easeInOut);
    });
  });

  // ===========================================================================
  // FUSION CHART CONFIGURATION - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionChartConfiguration - Computed Properties', () {
    test('effectiveAnimationDuration returns custom duration when set', () {
      const config = FusionChartConfiguration(
        animationDuration: Duration(milliseconds: 1000),
      );

      expect(
        config.effectiveAnimationDuration,
        const Duration(milliseconds: 1000),
      );
    });

    test('effectiveAnimationDuration returns theme duration when not set', () {
      const config = FusionChartConfiguration();

      expect(config.effectiveAnimationDuration, config.theme.animationDuration);
    });

    test('effectiveAnimationCurve returns custom curve when set', () {
      const config = FusionChartConfiguration(animationCurve: Curves.bounceOut);

      expect(config.effectiveAnimationCurve, Curves.bounceOut);
    });

    test('effectiveAnimationCurve returns theme curve when not set', () {
      const config = FusionChartConfiguration();

      expect(config.effectiveAnimationCurve, config.theme.animationCurve);
    });

    test('hasAnyInteraction returns true when any interaction enabled', () {
      expect(
        const FusionChartConfiguration(enableTooltip: true).hasAnyInteraction,
        isTrue,
      );
      expect(
        const FusionChartConfiguration(
          enableTooltip: false,
          enableCrosshair: true,
        ).hasAnyInteraction,
        isTrue,
      );
      expect(
        const FusionChartConfiguration(
          enableTooltip: false,
          enableZoom: true,
        ).hasAnyInteraction,
        isTrue,
      );
      expect(
        const FusionChartConfiguration(
          enableTooltip: false,
          enablePanning: true,
        ).hasAnyInteraction,
        isTrue,
      );
      expect(
        const FusionChartConfiguration(
          enableTooltip: false,
          enableSelection: true,
        ).hasAnyInteraction,
        isTrue,
      );
    });

    test('hasAnyInteraction returns false when all interactions disabled', () {
      const config = FusionChartConfiguration(
        enableTooltip: false,
        enableCrosshair: false,
        enableZoom: false,
        enablePanning: false,
        enableSelection: false,
      );

      expect(config.hasAnyInteraction, isFalse);
    });
  });

  // ===========================================================================
  // FUSION CHART CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionChartConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionChartConfiguration(
        enableAnimation: true,
        enableZoom: false,
      );

      final copy = original.copyWith(enableAnimation: false, enableZoom: true);

      expect(copy.enableAnimation, isFalse);
      expect(copy.enableZoom, isTrue);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionChartConfiguration(
        enableAnimation: true,
        enableTooltip: true,
        enableCrosshair: true,
        padding: EdgeInsets.all(20),
      );

      final copy = original.copyWith(enableAnimation: false);

      expect(copy.enableAnimation, isFalse);
      expect(copy.enableTooltip, isTrue);
      expect(copy.enableCrosshair, isTrue);
      expect(copy.padding, const EdgeInsets.all(20));
    });

    test('copyWith handles all parameters', () {
      const original = FusionChartConfiguration();

      final copy = original.copyWith(
        theme: const FusionDarkTheme(),
        tooltipBehavior: const FusionTooltipBehavior(shared: true),
        crosshairBehavior: const FusionCrosshairConfiguration(),
        zoomBehavior: const FusionZoomConfiguration(maxZoomLevel: 15.0),
        panBehavior: const FusionPanConfiguration(),
        interactionAnchorMode: InteractionAnchorMode.dataPoint,
        enableAnimation: false,
        enableTooltip: false,
        enableCrosshair: true,
        enableZoom: true,
        enablePanning: true,
        enableSelection: false,
        enableLegend: false,
        enableDataLabels: true,
        enableBorder: true,
        enableGrid: false,
        enableAxis: false,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        animationDuration: const Duration(milliseconds: 250),
        animationCurve: Curves.fastOutSlowIn,
      );

      expect(copy.theme, isA<FusionDarkTheme>());
      expect(copy.tooltipBehavior.shared, isTrue);
      expect(copy.zoomBehavior.maxZoomLevel, 15.0);
      expect(copy.interactionAnchorMode, InteractionAnchorMode.dataPoint);
      expect(copy.enableAnimation, isFalse);
      expect(copy.enableTooltip, isFalse);
      expect(copy.enableCrosshair, isTrue);
      expect(copy.enableZoom, isTrue);
      expect(copy.enablePanning, isTrue);
      expect(copy.enableSelection, isFalse);
      expect(copy.enableLegend, isFalse);
      expect(copy.enableDataLabels, isTrue);
      expect(copy.enableBorder, isTrue);
      expect(copy.enableGrid, isFalse);
      expect(copy.enableAxis, isFalse);
      expect(copy.padding, const EdgeInsets.symmetric(horizontal: 8));
      expect(copy.animationDuration, const Duration(milliseconds: 250));
      expect(copy.animationCurve, Curves.fastOutSlowIn);
    });
  });

  // ===========================================================================
  // FUSION CHART CONFIGURATION - EQUALITY
  // ===========================================================================
  group('FusionChartConfiguration - Equality', () {
    test('equal configs are equal', () {
      const config1 = FusionChartConfiguration(
        enableAnimation: true,
        enableZoom: true,
        padding: EdgeInsets.all(8),
      );

      const config2 = FusionChartConfiguration(
        enableAnimation: true,
        enableZoom: true,
        padding: EdgeInsets.all(8),
      );

      expect(config1, equals(config2));
    });

    test('different configs are not equal', () {
      const config1 = FusionChartConfiguration(enableAnimation: true);

      const config2 = FusionChartConfiguration(enableAnimation: false);

      expect(config1, isNot(equals(config2)));
    });

    test('hashCode is consistent', () {
      const config1 = FusionChartConfiguration(
        enableAnimation: true,
        enableZoom: true,
      );

      const config2 = FusionChartConfiguration(
        enableAnimation: true,
        enableZoom: true,
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('identical configs are equal', () {
      const config = FusionChartConfiguration();

      expect(config == config, isTrue);
    });
  });

  // ===========================================================================
  // FUSION CHART CONFIGURATION - TOSTRING
  // ===========================================================================
  group('FusionChartConfiguration - toString', () {
    test('toString returns descriptive string', () {
      const config = FusionChartConfiguration(
        enableAnimation: true,
        enableZoom: true,
        enablePanning: false,
      );

      final str = config.toString();

      expect(str, contains('FusionChartConfiguration'));
      expect(str, contains('enableAnimation: true'));
      expect(str, contains('enableZoom: true'));
      expect(str, contains('enablePanning: false'));
    });
  });

  // ===========================================================================
  // INTERACTION ANCHOR MODE ENUM
  // ===========================================================================
  group('InteractionAnchorMode - Enum', () {
    test('has all expected values', () {
      expect(InteractionAnchorMode.values, hasLength(2));
      expect(
        InteractionAnchorMode.values,
        contains(InteractionAnchorMode.screenPosition),
      );
      expect(
        InteractionAnchorMode.values,
        contains(InteractionAnchorMode.dataPoint),
      );
    });
  });
}

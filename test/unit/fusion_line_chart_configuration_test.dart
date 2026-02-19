import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_line_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_position.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_chart_theme.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================

  group('FusionLineChartConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionLineChartConfiguration();

      // Line-specific defaults
      expect(config.lineWidth, 2.0);
      expect(config.enableMarkers, isFalse);
      expect(config.markerSize, 6.0);
      expect(config.enableAreaFill, isFalse);
      expect(config.areaFillOpacity, 0.3);
      expect(config.enableCurveSmoothing, isFalse);
      expect(config.curveTension, 0.4);

      // Base configuration defaults
      expect(config.enableAnimation, isTrue);
      expect(config.enableTooltip, isTrue);
      expect(config.enableCrosshair, isFalse);
      expect(config.enableZoom, isFalse);
      expect(config.enablePanning, isFalse);
      expect(config.enableSelection, isTrue);
      expect(config.enableLegend, isTrue); // Default is true
      expect(config.enableDataLabels, isFalse);
      expect(config.enableBorder, isFalse);
      expect(config.enableGrid, isTrue);
      expect(config.enableAxis, isTrue);
    });

    test('creates with custom line-specific values', () {
      const config = FusionLineChartConfiguration(
        lineWidth: 3.0,
        enableMarkers: true,
        markerSize: 8.0,
        enableAreaFill: true,
        areaFillOpacity: 0.5,
        enableCurveSmoothing: true,
        curveTension: 0.6,
      );

      expect(config.lineWidth, 3.0);
      expect(config.enableMarkers, isTrue);
      expect(config.markerSize, 8.0);
      expect(config.enableAreaFill, isTrue);
      expect(config.areaFillOpacity, 0.5);
      expect(config.enableCurveSmoothing, isTrue);
      expect(config.curveTension, 0.6);
    });

    test('creates with custom base configuration values', () {
      const config = FusionLineChartConfiguration(
        enableAnimation: false,
        enableTooltip: false,
        enableCrosshair: true,
        enableZoom: true,
        enablePanning: true,
        enableSelection: false,
        enableLegend: true,
        enableDataLabels: true,
        padding: EdgeInsets.all(16),
        animationDuration: Duration(milliseconds: 500),
        animationCurve: Curves.easeInOut,
      );

      expect(config.enableAnimation, isFalse);
      expect(config.enableTooltip, isFalse);
      expect(config.enableCrosshair, isTrue);
      expect(config.enableZoom, isTrue);
      expect(config.enablePanning, isTrue);
      expect(config.enableSelection, isFalse);
      expect(config.enableLegend, isTrue);
      expect(config.enableDataLabels, isTrue);
      expect(config.padding, const EdgeInsets.all(16));
      expect(config.animationDuration, const Duration(milliseconds: 500));
      expect(config.animationCurve, Curves.easeInOut);
    });

    test('creates with tooltip behavior', () {
      const tooltipBehavior = FusionTooltipBehavior(
        position: FusionTooltipPosition.top,
        shared: true,
      );
      const config = FusionLineChartConfiguration(
        tooltipBehavior: tooltipBehavior,
      );

      expect(config.tooltipBehavior.position, FusionTooltipPosition.top);
      expect(config.tooltipBehavior.shared, isTrue);
    });
  });

  // ===========================================================================
  // ASSERTIONS
  // ===========================================================================

  group('FusionLineChartConfiguration - Assertions', () {
    test('throws for lineWidth <= 0', () {
      expect(
        () => FusionLineChartConfiguration(lineWidth: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for lineWidth > 10', () {
      expect(
        () => FusionLineChartConfiguration(lineWidth: 11),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for markerSize <= 0', () {
      expect(
        () => FusionLineChartConfiguration(markerSize: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for markerSize > 20', () {
      expect(
        () => FusionLineChartConfiguration(markerSize: 21),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for areaFillOpacity < 0', () {
      expect(
        () => FusionLineChartConfiguration(areaFillOpacity: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for areaFillOpacity > 1', () {
      expect(
        () => FusionLineChartConfiguration(areaFillOpacity: 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for curveTension < 0', () {
      expect(
        () => FusionLineChartConfiguration(curveTension: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for curveTension > 1', () {
      expect(
        () => FusionLineChartConfiguration(curveTension: 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows valid boundary values', () {
      const config1 = FusionLineChartConfiguration(
        lineWidth: 0.1,
        markerSize: 0.1,
        areaFillOpacity: 0.0,
        curveTension: 0.0,
      );
      expect(config1.lineWidth, 0.1);

      const config2 = FusionLineChartConfiguration(
        lineWidth: 10,
        markerSize: 20,
        areaFillOpacity: 1.0,
        curveTension: 1.0,
      );
      expect(config2.lineWidth, 10);
    });
  });

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  group('FusionLineChartConfiguration - copyWith', () {
    test('creates copy with modified lineWidth', () {
      const original = FusionLineChartConfiguration(lineWidth: 2.0);
      final copy = original.copyWith(lineWidth: 4.0);

      expect(copy.lineWidth, 4.0);
      expect(original.lineWidth, 2.0);
    });

    test('creates copy with modified markers', () {
      const original = FusionLineChartConfiguration(
        enableMarkers: false,
        markerSize: 6.0,
      );
      final copy = original.copyWith(enableMarkers: true, markerSize: 10.0);

      expect(copy.enableMarkers, isTrue);
      expect(copy.markerSize, 10.0);
      expect(original.enableMarkers, isFalse);
    });

    test('creates copy with modified area fill', () {
      const original = FusionLineChartConfiguration(
        enableAreaFill: false,
        areaFillOpacity: 0.3,
      );
      final copy = original.copyWith(
        enableAreaFill: true,
        areaFillOpacity: 0.6,
      );

      expect(copy.enableAreaFill, isTrue);
      expect(copy.areaFillOpacity, 0.6);
    });

    test('creates copy with modified curve settings', () {
      const original = FusionLineChartConfiguration(
        enableCurveSmoothing: false,
        curveTension: 0.4,
      );
      final copy = original.copyWith(
        enableCurveSmoothing: true,
        curveTension: 0.8,
      );

      expect(copy.enableCurveSmoothing, isTrue);
      expect(copy.curveTension, 0.8);
    });

    test('creates copy with modified base configuration', () {
      const original = FusionLineChartConfiguration(
        enableAnimation: true,
        enableTooltip: true,
      );
      final copy = original.copyWith(enableAnimation: false, enableZoom: true);

      expect(copy.enableAnimation, isFalse);
      expect(copy.enableZoom, isTrue);
      expect(copy.enableTooltip, isTrue); // Unchanged
    });

    test('creates unchanged copy when no parameters', () {
      const original = FusionLineChartConfiguration(
        lineWidth: 3.0,
        enableMarkers: true,
      );
      final copy = original.copyWith();

      expect(copy.lineWidth, original.lineWidth);
      expect(copy.enableMarkers, original.enableMarkers);
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================

  group('FusionLineChartConfiguration - Equality', () {
    test('equal configurations are equal', () {
      const config1 = FusionLineChartConfiguration(
        lineWidth: 3.0,
        enableMarkers: true,
      );
      const config2 = FusionLineChartConfiguration(
        lineWidth: 3.0,
        enableMarkers: true,
      );

      expect(config1, equals(config2));
    });

    test('configurations with different lineWidth are not equal', () {
      const config1 = FusionLineChartConfiguration(lineWidth: 2.0);
      const config2 = FusionLineChartConfiguration(lineWidth: 3.0);

      expect(config1, isNot(equals(config2)));
    });

    test('configurations with different enableMarkers are not equal', () {
      const config1 = FusionLineChartConfiguration(enableMarkers: false);
      const config2 = FusionLineChartConfiguration(enableMarkers: true);

      expect(config1, isNot(equals(config2)));
    });

    test('configurations with different markerSize are not equal', () {
      const config1 = FusionLineChartConfiguration(markerSize: 6.0);
      const config2 = FusionLineChartConfiguration(markerSize: 8.0);

      expect(config1, isNot(equals(config2)));
    });

    test('configurations with different enableAreaFill are not equal', () {
      const config1 = FusionLineChartConfiguration(enableAreaFill: false);
      const config2 = FusionLineChartConfiguration(enableAreaFill: true);

      expect(config1, isNot(equals(config2)));
    });

    test('configurations with different areaFillOpacity are not equal', () {
      const config1 = FusionLineChartConfiguration(areaFillOpacity: 0.3);
      const config2 = FusionLineChartConfiguration(areaFillOpacity: 0.5);

      expect(config1, isNot(equals(config2)));
    });

    test('configurations with different curveTension are not equal', () {
      const config1 = FusionLineChartConfiguration(curveTension: 0.4);
      const config2 = FusionLineChartConfiguration(curveTension: 0.6);

      expect(config1, isNot(equals(config2)));
    });

    test('identical configurations are equal', () {
      const config = FusionLineChartConfiguration();
      expect(config == config, isTrue);
    });
  });

  // ===========================================================================
  // HASH CODE
  // ===========================================================================

  group('FusionLineChartConfiguration - hashCode', () {
    test('equal configurations have equal hash codes', () {
      const config1 = FusionLineChartConfiguration(
        lineWidth: 3.0,
        enableMarkers: true,
        markerSize: 8.0,
      );
      const config2 = FusionLineChartConfiguration(
        lineWidth: 3.0,
        enableMarkers: true,
        markerSize: 8.0,
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('different configurations likely have different hash codes', () {
      const config1 = FusionLineChartConfiguration(lineWidth: 2.0);
      const config2 = FusionLineChartConfiguration(lineWidth: 3.0);

      // Hash codes may collide, so we just verify they're computed
      expect(config1.hashCode, isA<int>());
      expect(config2.hashCode, isA<int>());
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('FusionLineChartConfiguration - toString', () {
    test('includes type name', () {
      const config = FusionLineChartConfiguration();
      final str = config.toString();

      expect(str, contains('FusionLineChartConfiguration'));
    });

    test('includes lineWidth', () {
      const config = FusionLineChartConfiguration(lineWidth: 3.5);
      final str = config.toString();

      expect(str, contains('lineWidth'));
      expect(str, contains('3.5'));
    });

    test('includes enableMarkers', () {
      const config = FusionLineChartConfiguration(enableMarkers: true);
      final str = config.toString();

      expect(str, contains('enableMarkers'));
      expect(str, contains('true'));
    });

    test('includes enableAreaFill', () {
      const config = FusionLineChartConfiguration(enableAreaFill: true);
      final str = config.toString();

      expect(str, contains('enableAreaFill'));
      expect(str, contains('true'));
    });
  });

  // ===========================================================================
  // INHERITANCE
  // ===========================================================================

  group('FusionLineChartConfiguration - Inheritance', () {
    test('is immutable (decorated with @immutable)', () {
      // This is a compile-time guarantee, but we can verify
      // by checking that copyWith returns a new instance
      const original = FusionLineChartConfiguration();
      final copy = original.copyWith(lineWidth: 5.0);

      expect(identical(original, copy), isFalse);
    });

    test('inherits theme from base configuration', () {
      const config = FusionLineChartConfiguration();

      expect(config.theme, isA<FusionChartTheme>());
    });
  });
}

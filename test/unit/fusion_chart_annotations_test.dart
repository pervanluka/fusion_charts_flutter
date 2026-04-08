import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/annotations/fusion_reference_line.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_bar_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_line_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_stacked_bar_chart_configuration.dart';

void main() {
  // ===========================================================================
  // BASE CONFIGURATION - ANNOTATIONS
  // ===========================================================================
  group('FusionChartConfiguration - annotations', () {
    test('defaults to empty list', () {
      const config = FusionChartConfiguration();
      expect(config.annotations, isEmpty);
    });

    test('accepts a list of annotations', () {
      const config = FusionChartConfiguration(
        annotations: [
          FusionReferenceLine(value: 100, label: 'Target'),
          FusionReferenceLine(value: 50, label: 'Baseline'),
        ],
      );
      expect(config.annotations, hasLength(2));
      expect(config.annotations[0].value, 100);
      expect(config.annotations[1].value, 50);
    });

    test('copyWith preserves annotations when not overridden', () {
      const config = FusionChartConfiguration(
        annotations: [FusionReferenceLine(value: 100)],
      );
      final copy = config.copyWith(enableGrid: false);
      expect(copy.annotations, hasLength(1));
      expect(copy.annotations[0].value, 100);
    });

    test('copyWith replaces annotations', () {
      const config = FusionChartConfiguration(
        annotations: [FusionReferenceLine(value: 100)],
      );
      final copy = config.copyWith(
        annotations: [FusionReferenceLine(value: 200)],
      );
      expect(copy.annotations, hasLength(1));
      expect(copy.annotations[0].value, 200);
    });
  });

  // ===========================================================================
  // LINE CHART CONFIGURATION - ANNOTATIONS
  // ===========================================================================
  group('FusionLineChartConfiguration - annotations', () {
    test('supports annotations through super', () {
      const config = FusionLineChartConfiguration(
        annotations: [FusionReferenceLine(value: 42)],
      );
      expect(config.annotations, hasLength(1));
    });

    test('copyWith preserves annotations', () {
      const config = FusionLineChartConfiguration(
        annotations: [FusionReferenceLine(value: 42)],
      );
      final copy = config.copyWith(enableMarkers: true);
      expect(copy.annotations, hasLength(1));
      expect(copy.annotations[0].value, 42);
    });
  });

  // ===========================================================================
  // BAR CHART CONFIGURATION - ANNOTATIONS
  // ===========================================================================
  group('FusionBarChartConfiguration - annotations', () {
    test('supports annotations through super', () {
      const config = FusionBarChartConfiguration(
        annotations: [FusionReferenceLine(value: 75)],
      );
      expect(config.annotations, hasLength(1));
    });

    test('copyWith preserves annotations', () {
      const config = FusionBarChartConfiguration(
        annotations: [FusionReferenceLine(value: 75)],
      );
      final copy = config.copyWith(barWidthRatio: 0.5);
      expect(copy.annotations, hasLength(1));
      expect(copy.annotations[0].value, 75);
    });
  });

  // ===========================================================================
  // STACKED BAR CHART CONFIGURATION - ANNOTATIONS
  // ===========================================================================
  group('FusionStackedBarChartConfiguration - annotations', () {
    test('supports annotations through super', () {
      const config = FusionStackedBarChartConfiguration(
        annotations: [FusionReferenceLine(value: 90)],
      );
      expect(config.annotations, hasLength(1));
    });

    test('copyWith preserves annotations', () {
      const config = FusionStackedBarChartConfiguration(
        annotations: [FusionReferenceLine(value: 90)],
      );
      final copy = config.copyWith(enableGrid: false);
      expect(copy.annotations, hasLength(1));
      expect(copy.annotations[0].value, 90);
    });
  });

  // ===========================================================================
  // ANNOTATIONS EMPTY - NO LAYER ADDED
  // ===========================================================================
  group('Annotations - empty list behavior', () {
    test('isNotEmpty returns false for default config', () {
      const config = FusionChartConfiguration();
      expect(config.annotations.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true when annotations present', () {
      const config = FusionChartConfiguration(
        annotations: [FusionReferenceLine(value: 100)],
      );
      expect(config.annotations.isNotEmpty, isTrue);
    });
  });
}

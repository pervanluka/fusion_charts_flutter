import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_stacked_bar_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/series/fusion_stacked_bar_series.dart';

void main() {
  // ===========================================================================
  // FUSION STACKED BAR SERIES - CONSTRUCTION
  // ===========================================================================
  group('FusionStackedBarSeries - Construction', () {
    test('creates with required parameters', () {
      final series = FusionStackedBarSeries(
        name: 'Product A',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(0, 30),
          const FusionDataPoint(1, 40),
        ],
      );

      expect(series.name, 'Product A');
      expect(series.color, Colors.blue);
      expect(series.dataPoints.length, 2);
    });

    test('creates with all optional parameters', () {
      final series = FusionStackedBarSeries(
        name: 'Product A',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 30)],
        visible: false,
        barWidth: 0.5,
        borderRadius: 4.0,
        spacing: 0.1,
        groupName: 'group1',
        gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
        borderColor: Colors.black,
        borderWidth: 2.0,
        showShadow: true,
        showDataLabels: true,
        isVertical: false,
      );

      expect(series.visible, isFalse);
      expect(series.barWidth, 0.5);
      expect(series.borderRadius, 4.0);
      expect(series.spacing, 0.1);
      expect(series.groupName, 'group1');
      expect(series.gradient, isNotNull);
      expect(series.borderColor, Colors.black);
      expect(series.borderWidth, 2.0);
      expect(series.showShadow, isTrue);
      expect(series.showDataLabels, isTrue);
      expect(series.isVertical, isFalse);
    });

    test('has correct default values', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
      );

      expect(series.visible, isTrue);
      expect(series.barWidth, 0.7);
      expect(series.borderRadius, 0.0);
      expect(series.spacing, 0.0);
      expect(series.groupName, '');
      expect(series.gradient, isNull);
      expect(series.borderColor, isNull);
      expect(series.borderWidth, 0.0);
      expect(series.showShadow, isFalse);
      expect(series.showDataLabels, isFalse);
      expect(series.isVertical, isTrue);
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR SERIES - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionStackedBarSeries - Computed Properties', () {
    test('hasData returns true when has data', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
      );

      expect(series.hasData, isTrue);
    });

    test('hasData returns false when empty', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: const [],
      );

      expect(series.hasData, isFalse);
    });

    test('pointCount returns correct count', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
        ],
      );

      expect(series.pointCount, 3);
    });

    test('minX returns minimum X value', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(5, 10),
          const FusionDataPoint(10, 20),
          const FusionDataPoint(2, 30),
        ],
      );

      expect(series.minX, 2);
    });

    test('maxX returns maximum X value', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(5, 10),
          const FusionDataPoint(10, 20),
          const FusionDataPoint(2, 30),
        ],
      );

      expect(series.maxX, 10);
    });

    test('minY returns minimum Y value', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(1, 10),
          const FusionDataPoint(2, 30),
        ],
      );

      expect(series.minY, 10);
    });

    test('maxY returns maximum Y value', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(1, 10),
          const FusionDataPoint(2, 30),
        ],
      );

      expect(series.maxY, 50);
    });

    test('sum returns sum of Y values', () {
      final series = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
        ],
      );

      expect(series.sum, 60);
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR SERIES - COPYWITH
  // ===========================================================================
  group('FusionStackedBarSeries - copyWith', () {
    test('copyWith creates copy with modified values', () {
      final original = FusionStackedBarSeries(
        name: 'original',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
      );

      final copy = original.copyWith(name: 'copy', color: Colors.red);

      expect(copy.name, 'copy');
      expect(copy.color, Colors.red);
      expect(copy.dataPoints, original.dataPoints);
    });

    test('copyWith preserves unchanged values', () {
      final original = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
        barWidth: 0.5,
        groupName: 'group1',
      );

      final copy = original.copyWith(name: 'new name');

      expect(copy.barWidth, 0.5);
      expect(copy.groupName, 'group1');
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR SERIES - EQUALITY
  // ===========================================================================
  group('FusionStackedBarSeries - Equality', () {
    test('equal series are equal', () {
      final series1 = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
        barWidth: 0.7,
        groupName: 'group1',
      );

      final series2 = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
        barWidth: 0.7,
        groupName: 'group1',
      );

      expect(series1, equals(series2));
    });

    test('different name makes unequal', () {
      final series1 = FusionStackedBarSeries(
        name: 'test1',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
      );

      final series2 = FusionStackedBarSeries(
        name: 'test2',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
      );

      expect(series1, isNot(equals(series2)));
    });

    test('hashCode is consistent', () {
      final series1 = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
      );

      final series2 = FusionStackedBarSeries(
        name: 'test',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
      );

      expect(series1.hashCode, equals(series2.hashCode));
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR SERIES - TOSTRING
  // ===========================================================================
  group('FusionStackedBarSeries - toString', () {
    test('toString returns descriptive string', () {
      final series = FusionStackedBarSeries(
        name: 'Product A',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(0, 10)],
        groupName: 'group1',
      );

      final str = series.toString();

      expect(str, contains('FusionStackedBarSeries'));
      expect(str, contains('Product A'));
      expect(str, contains('group1'));
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR CHART CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionStackedBarChartConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionStackedBarChartConfiguration();

      expect(config.isStacked100, isFalse);
      expect(config.barWidthRatio, 0.8);
      expect(config.borderRadius, 0.0);
      expect(config.tooltipBuilder, isNull);
      expect(config.tooltipValueFormatter, isNull);
      expect(config.tooltipTotalFormatter, isNull);
    });

    test('creates with custom values', () {
      const config = FusionStackedBarChartConfiguration(
        isStacked100: true,
        barWidthRatio: 0.5,
        borderRadius: 8.0,
        enableAnimation: false,
        enableTooltip: false,
      );

      expect(config.isStacked100, isTrue);
      expect(config.barWidthRatio, 0.5);
      expect(config.borderRadius, 8.0);
      expect(config.enableAnimation, isFalse);
      expect(config.enableTooltip, isFalse);
    });

    test('creates with tooltip formatters', () {
      String valueFormatter(double value, dynamic segment, dynamic info) =>
          '\$$value';
      String totalFormatter(double total, dynamic info) => 'Total: $total';

      final config = FusionStackedBarChartConfiguration(
        tooltipValueFormatter: valueFormatter,
        tooltipTotalFormatter: totalFormatter,
      );

      expect(config.tooltipValueFormatter, isNotNull);
      expect(config.tooltipTotalFormatter, isNotNull);
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR CHART CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionStackedBarChartConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionStackedBarChartConfiguration(
        isStacked100: false,
        barWidthRatio: 0.8,
      );

      final copy = original.copyWith(isStacked100: true, barWidthRatio: 0.6);

      expect(copy.isStacked100, isTrue);
      expect(copy.barWidthRatio, 0.6);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionStackedBarChartConfiguration(
        isStacked100: true,
        barWidthRatio: 0.5,
        borderRadius: 4.0,
      );

      final copy = original.copyWith(isStacked100: false);

      expect(copy.barWidthRatio, 0.5);
      expect(copy.borderRadius, 4.0);
    });

    test('copyWith handles base configuration values', () {
      const original = FusionStackedBarChartConfiguration(
        enableAnimation: true,
        enableTooltip: true,
      );

      final copy = original.copyWith(
        enableAnimation: false,
        isStacked100: true,
      );

      expect(copy.enableAnimation, isFalse);
      expect(copy.enableTooltip, isTrue);
      expect(copy.isStacked100, isTrue);
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR CHART CONFIGURATION - EQUALITY
  // ===========================================================================
  group('FusionStackedBarChartConfiguration - Equality', () {
    test('equal configs are equal', () {
      const config1 = FusionStackedBarChartConfiguration(
        isStacked100: true,
        barWidthRatio: 0.5,
        borderRadius: 4.0,
      );

      const config2 = FusionStackedBarChartConfiguration(
        isStacked100: true,
        barWidthRatio: 0.5,
        borderRadius: 4.0,
      );

      expect(config1, equals(config2));
    });

    test('different isStacked100 makes unequal', () {
      const config1 = FusionStackedBarChartConfiguration(isStacked100: true);

      const config2 = FusionStackedBarChartConfiguration(isStacked100: false);

      expect(config1, isNot(equals(config2)));
    });

    test('hashCode is consistent', () {
      const config1 = FusionStackedBarChartConfiguration(
        isStacked100: true,
        barWidthRatio: 0.5,
      );

      const config2 = FusionStackedBarChartConfiguration(
        isStacked100: true,
        barWidthRatio: 0.5,
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });
  });

  // ===========================================================================
  // FUSION STACKED BAR CHART CONFIGURATION - TOSTRING
  // ===========================================================================
  group('FusionStackedBarChartConfiguration - toString', () {
    test('toString returns descriptive string', () {
      const config = FusionStackedBarChartConfiguration(
        isStacked100: true,
        barWidthRatio: 0.6,
      );

      final str = config.toString();

      expect(str, contains('FusionStackedBarChartConfiguration'));
      expect(str, contains('isStacked100: true'));
      expect(str, contains('barWidthRatio: 0.6'));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('Stacked Bar - Edge Cases', () {
    test('handles empty data points', () {
      final series = FusionStackedBarSeries(
        name: 'empty',
        color: Colors.blue,
        dataPoints: const [],
      );

      expect(series.hasData, isFalse);
      expect(series.pointCount, 0);
      expect(series.minX, isNull);
      expect(series.maxX, isNull);
      expect(series.minY, isNull);
      expect(series.maxY, isNull);
      expect(series.sum, 0);
    });

    test('handles single data point', () {
      final series = FusionStackedBarSeries(
        name: 'single',
        color: Colors.blue,
        dataPoints: [const FusionDataPoint(5, 50)],
      );

      expect(series.hasData, isTrue);
      expect(series.pointCount, 1);
      expect(series.minX, 5);
      expect(series.maxX, 5);
      expect(series.minY, 50);
      expect(series.maxY, 50);
      expect(series.sum, 50);
    });

    test('handles negative values', () {
      final series = FusionStackedBarSeries(
        name: 'negative',
        color: Colors.blue,
        dataPoints: [
          const FusionDataPoint(0, -10),
          const FusionDataPoint(1, -20),
          const FusionDataPoint(2, 30),
        ],
      );

      expect(series.minY, -20);
      expect(series.maxY, 30);
      expect(series.sum, 0);
    });
  });
}

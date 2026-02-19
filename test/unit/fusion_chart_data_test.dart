import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_axis_configuration.dart';
import 'package:fusion_charts_flutter/src/data/fusion_bar_chart_data.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/data/fusion_line_chart_data.dart';
import 'package:fusion_charts_flutter/src/series/fusion_bar_series.dart';
import 'package:fusion_charts_flutter/src/series/fusion_line_series.dart';

void main() {
  // ===========================================================================
  // FUSION BAR CHART DATA - CONSTRUCTION
  // ===========================================================================
  group('FusionBarChartData - Construction', () {
    test('creates with required series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
      );

      expect(data.series.length, 1);
      expect(data.series.first.name, 'test');
    });

    test('creates with all optional parameters', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        xAxis: const FusionAxisConfiguration(),
        yAxis: const FusionAxisConfiguration(),
        title: 'Chart Title',
        subtitle: 'Chart Subtitle',
        backgroundColor: Colors.white,
      );

      expect(data.title, 'Chart Title');
      expect(data.subtitle, 'Chart Subtitle');
      expect(data.backgroundColor, Colors.white);
      expect(data.xAxis, isNotNull);
      expect(data.yAxis, isNotNull);
    });
  });

  // ===========================================================================
  // FUSION BAR CHART DATA - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionBarChartData - Computed Properties', () {
    test('visibleSeries returns only visible series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'visible',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: true,
          ),
          FusionBarSeries(
            name: 'hidden',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(2, 20)],
            visible: false,
          ),
        ],
      );

      expect(data.visibleSeries.length, 1);
      expect(data.visibleSeries.first.name, 'visible');
    });

    test('hasVisibleSeries returns true when has visible series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
      );

      expect(data.hasVisibleSeries, isTrue);
    });

    test('hasVisibleSeries returns false when all hidden', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: false,
          ),
        ],
      );

      expect(data.hasVisibleSeries, isFalse);
    });

    test('totalDataPoints sums all visible series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [
              const FusionDataPoint(1, 10),
              const FusionDataPoint(2, 20),
            ],
          ),
          FusionBarSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(3, 30)],
          ),
        ],
      );

      expect(data.totalDataPoints, 3);
    });

    test('minY returns minimum Y across visible series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 50)],
          ),
          FusionBarSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(2, 10)],
          ),
        ],
      );

      expect(data.minY, 10);
    });

    test('maxY returns maximum Y across visible series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 50)],
          ),
          FusionBarSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(2, 100)],
          ),
        ],
      );

      expect(data.maxY, 100);
    });

    test('minY returns null when no visible series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: false,
          ),
        ],
      );

      expect(data.minY, isNull);
    });

    test('maxY returns null when no visible series', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: false,
          ),
        ],
      );

      expect(data.maxY, isNull);
    });
  });

  // ===========================================================================
  // FUSION BAR CHART DATA - METHODS
  // ===========================================================================
  group('FusionBarChartData - Methods', () {
    test('copyWith creates new instance with updated values', () {
      final original = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'original',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        title: 'Original Title',
      );

      final copy = original.copyWith(title: 'New Title');

      expect(copy.title, 'New Title');
      expect(copy.series.first.name, 'original');
      expect(original.title, 'Original Title');
    });

    test('copyWith preserves unchanged values', () {
      final original = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        title: 'Title',
        subtitle: 'Subtitle',
      );

      final copy = original.copyWith(title: 'New Title');

      expect(copy.subtitle, 'Subtitle');
    });

    test('toString returns descriptive string', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        title: 'My Chart',
      );

      final str = data.toString();

      expect(str, contains('FusionBarChartData'));
      expect(str, contains('1'));
      expect(str, contains('My Chart'));
    });
  });

  // ===========================================================================
  // FUSION LINE CHART DATA - CONSTRUCTION
  // ===========================================================================
  group('FusionLineChartData - Construction', () {
    test('creates with required series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
      );

      expect(data.series.length, 1);
      expect(data.series.first.name, 'test');
    });

    test('creates with all optional parameters', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        xAxis: const FusionAxisConfiguration(),
        yAxis: const FusionAxisConfiguration(),
        title: 'Chart Title',
        subtitle: 'Chart Subtitle',
        backgroundColor: Colors.white,
      );

      expect(data.title, 'Chart Title');
      expect(data.subtitle, 'Chart Subtitle');
      expect(data.backgroundColor, Colors.white);
      expect(data.xAxis, isNotNull);
      expect(data.yAxis, isNotNull);
    });
  });

  // ===========================================================================
  // FUSION LINE CHART DATA - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionLineChartData - Computed Properties', () {
    test('visibleSeries returns only visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'visible',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: true,
          ),
          FusionLineSeries(
            name: 'hidden',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(2, 20)],
            visible: false,
          ),
        ],
      );

      expect(data.visibleSeries.length, 1);
      expect(data.visibleSeries.first.name, 'visible');
    });

    test('hasVisibleSeries returns true when has visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
      );

      expect(data.hasVisibleSeries, isTrue);
    });

    test('totalDataPoints sums all visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [
              const FusionDataPoint(1, 10),
              const FusionDataPoint(2, 20),
            ],
          ),
          FusionLineSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(3, 30)],
          ),
        ],
      );

      expect(data.totalDataPoints, 3);
    });

    test('minX returns minimum X across visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(5, 50)],
          ),
          FusionLineSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
      );

      expect(data.minX, 1);
    });

    test('maxX returns maximum X across visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(5, 50)],
          ),
          FusionLineSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(10, 10)],
          ),
        ],
      );

      expect(data.maxX, 10);
    });

    test('minY returns minimum Y across visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 50)],
          ),
          FusionLineSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(2, 10)],
          ),
        ],
      );

      expect(data.minY, 10);
    });

    test('maxY returns maximum Y across visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'series1',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 50)],
          ),
          FusionLineSeries(
            name: 'series2',
            color: Colors.red,
            dataPoints: [const FusionDataPoint(2, 100)],
          ),
        ],
      );

      expect(data.maxY, 100);
    });

    test('minX returns null when no visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: false,
          ),
        ],
      );

      expect(data.minX, isNull);
    });

    test('maxX returns null when no visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: false,
          ),
        ],
      );

      expect(data.maxX, isNull);
    });

    test('minY returns null when no visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: false,
          ),
        ],
      );

      expect(data.minY, isNull);
    });

    test('maxY returns null when no visible series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
            visible: false,
          ),
        ],
      );

      expect(data.maxY, isNull);
    });
  });

  // ===========================================================================
  // FUSION LINE CHART DATA - METHODS
  // ===========================================================================
  group('FusionLineChartData - Methods', () {
    test('copyWith creates new instance with updated values', () {
      final original = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'original',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        title: 'Original Title',
      );

      final copy = original.copyWith(title: 'New Title');

      expect(copy.title, 'New Title');
      expect(copy.series.first.name, 'original');
      expect(original.title, 'Original Title');
    });

    test('copyWith preserves unchanged values', () {
      final original = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        title: 'Title',
        subtitle: 'Subtitle',
      );

      final copy = original.copyWith(title: 'New Title');

      expect(copy.subtitle, 'Subtitle');
    });

    test('toString returns descriptive string', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(1, 10)],
          ),
        ],
        title: 'My Chart',
      );

      final str = data.toString();

      expect(str, contains('FusionLineChartData'));
      expect(str, contains('1'));
      expect(str, contains('My Chart'));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('Chart Data - Edge Cases', () {
    test('handles empty data points in series', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'empty',
            color: Colors.blue,
            dataPoints: const [],
          ),
        ],
      );

      expect(data.totalDataPoints, 0);
      expect(data.minX, isNull);
      expect(data.maxX, isNull);
      expect(data.minY, isNull);
      expect(data.maxY, isNull);
    });

    test('handles negative values', () {
      final data = FusionLineChartData(
        series: [
          FusionLineSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [
              const FusionDataPoint(-10, -50),
              const FusionDataPoint(-5, -25),
              const FusionDataPoint(0, 0),
            ],
          ),
        ],
      );

      expect(data.minX, -10);
      expect(data.maxX, 0);
      expect(data.minY, -50);
      expect(data.maxY, 0);
    });

    test('handles single data point', () {
      final data = FusionBarChartData(
        series: [
          FusionBarSeries(
            name: 'test',
            color: Colors.blue,
            dataPoints: [const FusionDataPoint(5, 50)],
          ),
        ],
      );

      expect(data.minY, 50);
      expect(data.maxY, 50);
    });
  });
}

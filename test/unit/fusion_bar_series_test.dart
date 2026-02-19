import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/series/fusion_bar_series.dart';
import 'package:fusion_charts_flutter/src/series/fusion_series.dart';

void main() {
  // ===========================================================================
  // FUSION BAR SERIES - CONSTRUCTION
  // ===========================================================================
  group('FusionBarSeries - Construction', () {
    test('creates with required parameters', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
        ],
        color: Colors.blue,
      );

      expect(series.dataPoints.length, 2);
      expect(series.color, Colors.blue);
    });

    test('creates with all optional parameters', () {
      final series = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'Sales',
        visible: false,
        barWidth: 0.8,
        borderRadius: 8.0,
        spacing: 0.3,
        gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
        borderColor: Colors.black,
        borderWidth: 2.0,
        showShadow: false,
        shadow: const BoxShadow(color: Colors.black, blurRadius: 4),
        showDataLabels: true,
        dataLabelStyle: const TextStyle(fontSize: 12),
        dataLabelFormatter: (v) => '\$$v',
        animationDuration: const Duration(milliseconds: 500),
        animationCurve: Curves.easeInOut,
        isVertical: false,
        isTrackVisible: true,
        trackColor: Colors.grey,
        trackBorderWidth: 1.0,
        trackBorderColor: Colors.black,
        trackPadding: 2.0,
        interaction: const FusionSeriesInteraction(selectable: false),
      );

      expect(series.name, 'Sales');
      expect(series.visible, isFalse);
      expect(series.barWidth, 0.8);
      expect(series.borderRadius, 8.0);
      expect(series.spacing, 0.3);
      expect(series.gradient, isNotNull);
      expect(series.borderColor, Colors.black);
      expect(series.borderWidth, 2.0);
      expect(series.showShadow, isFalse);
      expect(series.shadow, isNotNull);
      expect(series.showDataLabels, isTrue);
      expect(series.dataLabelStyle, isNotNull);
      expect(series.dataLabelFormatter, isNotNull);
      expect(series.animationDuration, const Duration(milliseconds: 500));
      expect(series.animationCurve, Curves.easeInOut);
      expect(series.isVertical, isFalse);
      expect(series.isTrackVisible, isTrue);
      expect(series.trackColor, Colors.grey);
      expect(series.trackBorderWidth, 1.0);
      expect(series.trackBorderColor, Colors.black);
      expect(series.trackPadding, 2.0);
      expect(series.interaction.selectable, isFalse);
    });

    test('has correct default values', () {
      final series = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect(series.name, '');
      expect(series.visible, isTrue);
      expect(series.barWidth, 0.6);
      expect(series.borderRadius, 4.0);
      expect(series.spacing, 0.2);
      expect(series.gradient, isNull);
      expect(series.borderColor, isNull);
      expect(series.borderWidth, 0.0);
      expect(series.showShadow, isTrue);
      expect(series.shadow, isNull);
      expect(series.showDataLabels, isFalse);
      expect(series.dataLabelStyle, isNull);
      expect(series.dataLabelFormatter, isNull);
      expect(series.animationDuration, isNull);
      expect(series.animationCurve, isNull);
      expect(series.isVertical, isTrue);
      expect(series.isTrackVisible, isFalse);
      expect(series.trackColor, isNull);
      expect(series.trackBorderWidth, 0.0);
      expect(series.trackBorderColor, isNull);
      expect(series.trackPadding, 0.0);
      expect(series.interaction, isA<FusionSeriesInteraction>());
    });
  });

  // ===========================================================================
  // FUSION BAR SERIES - ASSERTIONS
  // ===========================================================================
  group('FusionBarSeries - Assertions', () {
    test('throws assertion error for invalid bar width (zero)', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          barWidth: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid bar width (> 1)', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          barWidth: 1.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid spacing (negative)', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          spacing: -0.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid spacing (>= 1)', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          spacing: 1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for negative border radius', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          borderRadius: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for negative border width', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          borderWidth: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for negative track border width', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          trackBorderWidth: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for negative track padding', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          trackPadding: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts boundary values', () {
      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          barWidth: 0.01,
          spacing: 0.0,
          borderRadius: 0.0,
          borderWidth: 0.0,
          trackBorderWidth: 0.0,
          trackPadding: 0.0,
        ),
        returnsNormally,
      );

      expect(
        () => FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          barWidth: 1.0,
          spacing: 0.99,
        ),
        returnsNormally,
      );
    });
  });

  // ===========================================================================
  // FUSION BAR SERIES - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionBarSeries - Computed Properties', () {
    test('hasData returns true when has data', () {
      final series = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect(series.hasData, isTrue);
    });

    test('hasData returns false when empty', () {
      final series = FusionBarSeries(dataPoints: const [], color: Colors.blue);

      expect(series.hasData, isFalse);
    });

    test('pointCount returns correct count', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
        ],
        color: Colors.blue,
      );

      expect(series.pointCount, 3);
    });

    test('minX returns minimum X value', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(5, 10),
          const FusionDataPoint(2, 20),
          const FusionDataPoint(8, 30),
        ],
        color: Colors.blue,
      );

      expect(series.minX, 2);
    });

    test('maxX returns maximum X value', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(5, 10),
          const FusionDataPoint(2, 20),
          const FusionDataPoint(8, 30),
        ],
        color: Colors.blue,
      );

      expect(series.maxX, 8);
    });

    test('minY returns minimum Y value', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(1, 10),
          const FusionDataPoint(2, 30),
        ],
        color: Colors.blue,
      );

      expect(series.minY, 10);
    });

    test('maxY returns maximum Y value', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(1, 10),
          const FusionDataPoint(2, 30),
        ],
        color: Colors.blue,
      );

      expect(series.maxY, 50);
    });

    test('averageY returns average Y value', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
        ],
        color: Colors.blue,
      );

      expect(series.averageY, 20);
    });

    test('sum returns sum of Y values', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
        ],
        color: Colors.blue,
      );

      expect(series.sum, 60);
    });

    test('computed properties return null for empty data', () {
      final series = FusionBarSeries(dataPoints: const [], color: Colors.blue);

      expect(series.minX, isNull);
      expect(series.maxX, isNull);
      expect(series.minY, isNull);
      expect(series.maxY, isNull);
      expect(series.averageY, isNull);
    });
  });

  // ===========================================================================
  // FUSION BAR SERIES - METHODS
  // ===========================================================================
  group('FusionBarSeries - Methods', () {
    test('filterByRange filters data points correctly', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(5, 20),
          const FusionDataPoint(10, 30),
          const FusionDataPoint(15, 40),
        ],
        color: Colors.blue,
      );

      final filtered = series.filterByRange(3, 12);

      expect(filtered.dataPoints.length, 2);
      expect(filtered.dataPoints[0].x, 5);
      expect(filtered.dataPoints[1].x, 10);
    });

    test('sortByX sorts data points by X coordinate', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(10, 30),
          const FusionDataPoint(0, 10),
          const FusionDataPoint(5, 20),
        ],
        color: Colors.blue,
      );

      final sorted = series.sortByX();

      expect(sorted.dataPoints[0].x, 0);
      expect(sorted.dataPoints[1].x, 5);
      expect(sorted.dataPoints[2].x, 10);
    });

    test('sortByY sorts data points by Y coordinate ascending', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 30),
          const FusionDataPoint(1, 10),
          const FusionDataPoint(2, 20),
        ],
        color: Colors.blue,
      );

      final sorted = series.sortByY();

      expect(sorted.dataPoints[0].y, 10);
      expect(sorted.dataPoints[1].y, 20);
      expect(sorted.dataPoints[2].y, 30);
    });

    test('sortByY sorts data points by Y coordinate descending', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 30),
          const FusionDataPoint(1, 10),
          const FusionDataPoint(2, 20),
        ],
        color: Colors.blue,
      );

      final sorted = series.sortByY(descending: true);

      expect(sorted.dataPoints[0].y, 30);
      expect(sorted.dataPoints[1].y, 20);
      expect(sorted.dataPoints[2].y, 10);
    });
  });

  // ===========================================================================
  // FUSION BAR SERIES - COPYWITH
  // ===========================================================================
  group('FusionBarSeries - copyWith', () {
    test('copyWith creates copy with modified values', () {
      final original = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'original',
      );

      final copy = original.copyWith(name: 'copy', color: Colors.red);

      expect(copy.name, 'copy');
      expect(copy.color, Colors.red);
      expect(copy.dataPoints, original.dataPoints);
    });

    test('copyWith preserves unchanged values', () {
      final original = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        barWidth: 0.8,
        borderRadius: 8.0,
        isVertical: false,
      );

      final copy = original.copyWith(name: 'new name');

      expect(copy.barWidth, 0.8);
      expect(copy.borderRadius, 8.0);
      expect(copy.isVertical, isFalse);
    });

    test('copyWith handles all parameters', () {
      final original = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      final copy = original.copyWith(
        dataPoints: [const FusionDataPoint(1, 20)],
        name: 'new',
        color: Colors.red,
        visible: false,
        barWidth: 0.9,
        borderRadius: 10.0,
        spacing: 0.15,
        gradient: const LinearGradient(colors: [Colors.red, Colors.green]),
        borderColor: Colors.white,
        borderWidth: 2.0,
        showShadow: false,
        shadow: const BoxShadow(color: Colors.black),
        showDataLabels: true,
        dataLabelStyle: const TextStyle(color: Colors.white),
        animationDuration: const Duration(seconds: 1),
        animationCurve: Curves.bounceIn,
        isVertical: false,
        isTrackVisible: true,
        trackColor: Colors.grey,
        trackBorderWidth: 1.0,
        trackBorderColor: Colors.black,
        trackPadding: 2.0,
        interaction: const FusionSeriesInteraction(selectable: false),
      );

      expect(copy.dataPoints.length, 1);
      expect(copy.dataPoints[0].x, 1);
      expect(copy.name, 'new');
      expect(copy.color, Colors.red);
      expect(copy.visible, isFalse);
      expect(copy.barWidth, 0.9);
      expect(copy.borderRadius, 10.0);
      expect(copy.spacing, 0.15);
      expect(copy.gradient, isNotNull);
      expect(copy.borderColor, Colors.white);
      expect(copy.borderWidth, 2.0);
      expect(copy.showShadow, isFalse);
      expect(copy.shadow, isNotNull);
      expect(copy.showDataLabels, isTrue);
      expect(copy.dataLabelStyle?.color, Colors.white);
      expect(copy.animationDuration, const Duration(seconds: 1));
      expect(copy.animationCurve, Curves.bounceIn);
      expect(copy.isVertical, isFalse);
      expect(copy.isTrackVisible, isTrue);
      expect(copy.trackColor, Colors.grey);
      expect(copy.trackBorderWidth, 1.0);
      expect(copy.trackBorderColor, Colors.black);
      expect(copy.trackPadding, 2.0);
      expect(copy.interaction.selectable, isFalse);
    });
  });

  // ===========================================================================
  // FUSION BAR SERIES - EQUALITY
  // ===========================================================================
  group('FusionBarSeries - Equality', () {
    test('equal series are equal', () {
      final series1 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
        barWidth: 0.6,
      );

      final series2 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
        barWidth: 0.6,
      );

      expect(series1, equals(series2));
    });

    test('different name makes unequal', () {
      final series1 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'series1',
      );

      final series2 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'series2',
      );

      expect(series1, isNot(equals(series2)));
    });

    test('different barWidth makes unequal', () {
      final series1 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        barWidth: 0.5,
      );

      final series2 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        barWidth: 0.7,
      );

      expect(series1, isNot(equals(series2)));
    });

    test('hashCode is consistent', () {
      final series1 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
      );

      final series2 = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
      );

      expect(series1.hashCode, equals(series2.hashCode));
    });

    test('identical series are equal', () {
      final series = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect(series == series, isTrue);
    });
  });

  // ===========================================================================
  // FUSION BAR SERIES - TOSTRING
  // ===========================================================================
  group('FusionBarSeries - toString', () {
    test('toString returns descriptive string', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
        ],
        color: Colors.blue,
        name: 'Sales',
        isVertical: true,
        visible: true,
      );

      final str = series.toString();

      expect(str, contains('FusionBarSeries'));
      expect(str, contains('Sales'));
      expect(str, contains('points: 2'));
      expect(str, contains('vertical: true'));
      expect(str, contains('visible: true'));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionBarSeries - Edge Cases', () {
    test('handles empty data points', () {
      final series = FusionBarSeries(dataPoints: const [], color: Colors.blue);

      expect(series.hasData, isFalse);
      expect(series.pointCount, 0);
      expect(series.sum, 0);
    });

    test('handles single data point', () {
      final series = FusionBarSeries(
        dataPoints: [const FusionDataPoint(5, 50)],
        color: Colors.blue,
      );

      expect(series.hasData, isTrue);
      expect(series.pointCount, 1);
      expect(series.minX, 5);
      expect(series.maxX, 5);
      expect(series.minY, 50);
      expect(series.maxY, 50);
      expect(series.averageY, 50);
      expect(series.sum, 50);
    });

    test('handles negative values', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, -10),
          const FusionDataPoint(1, -20),
          const FusionDataPoint(2, 30),
        ],
        color: Colors.blue,
      );

      expect(series.minY, -20);
      expect(series.maxY, 30);
      expect(series.sum, 0);
    });

    test('handles horizontal bars', () {
      final series = FusionBarSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
        ],
        color: Colors.blue,
        isVertical: false,
      );

      expect(series.isVertical, isFalse);
    });

    test('handles track configuration', () {
      final series = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        isTrackVisible: true,
        trackColor: Colors.grey.shade200,
        trackBorderWidth: 1.0,
        trackBorderColor: Colors.grey,
        trackPadding: 4.0,
      );

      expect(series.isTrackVisible, isTrue);
      expect(series.trackColor, Colors.grey.shade200);
      expect(series.trackBorderWidth, 1.0);
      expect(series.trackBorderColor, Colors.grey);
      expect(series.trackPadding, 4.0);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_data_label_display.dart';
import 'package:fusion_charts_flutter/src/core/enums/marker_shape.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/series/fusion_line_series.dart';
import 'package:fusion_charts_flutter/src/series/fusion_series.dart';

void main() {
  // ===========================================================================
  // FUSION LINE SERIES - CONSTRUCTION
  // ===========================================================================
  group('FusionLineSeries - Construction', () {
    test('creates with required parameters', () {
      final series = FusionLineSeries(
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
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'Revenue',
        visible: false,
        lineWidth: 5.0,
        isCurved: false,
        smoothness: 0.5,
        lineDashArray: [10, 5],
        gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
        showMarkers: true,
        markerSize: 10.0,
        markerShape: MarkerShape.square,
        showShadow: false,
        shadow: const BoxShadow(color: Colors.black, blurRadius: 4),
        showArea: true,
        areaOpacity: 0.5,
        showDataLabels: true,
        dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
        dataLabelStyle: const TextStyle(fontSize: 12),
        dataLabelFormatter: (v) => '\$$v',
        animationDuration: const Duration(milliseconds: 500),
        animationCurve: Curves.easeInOut,
        interaction: const FusionSeriesInteraction(selectable: false),
      );

      expect(series.name, 'Revenue');
      expect(series.visible, isFalse);
      expect(series.lineWidth, 5.0);
      expect(series.isCurved, isFalse);
      expect(series.smoothness, 0.5);
      expect(series.lineDashArray, [10, 5]);
      expect(series.gradient, isNotNull);
      expect(series.showMarkers, isTrue);
      expect(series.markerSize, 10.0);
      expect(series.markerShape, MarkerShape.square);
      expect(series.showShadow, isFalse);
      expect(series.shadow, isNotNull);
      expect(series.showArea, isTrue);
      expect(series.areaOpacity, 0.5);
      expect(series.showDataLabels, isTrue);
      expect(series.dataLabelDisplay, FusionDataLabelDisplay.maxAndMin);
      expect(series.dataLabelStyle, isNotNull);
      expect(series.dataLabelFormatter, isNotNull);
      expect(series.animationDuration, const Duration(milliseconds: 500));
      expect(series.animationCurve, Curves.easeInOut);
      expect(series.interaction.selectable, isFalse);
    });

    test('has correct default values', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect(series.name, '');
      expect(series.visible, isTrue);
      expect(series.lineWidth, 3.0);
      expect(series.isCurved, isTrue);
      expect(series.smoothness, 0.35);
      expect(series.lineDashArray, isNull);
      expect(series.gradient, isNull);
      expect(series.showMarkers, isFalse);
      expect(series.markerSize, 6.0);
      expect(series.markerShape, MarkerShape.circle);
      expect(series.showShadow, isTrue);
      expect(series.shadow, isNull);
      expect(series.showArea, isFalse);
      expect(series.areaOpacity, 0.3);
      expect(series.showDataLabels, isFalse);
      expect(series.dataLabelDisplay, FusionDataLabelDisplay.all);
      expect(series.dataLabelStyle, isNull);
      expect(series.dataLabelFormatter, isNull);
      expect(series.animationDuration, isNull);
      expect(series.animationCurve, isNull);
      expect(series.interaction, isA<FusionSeriesInteraction>());
    });
  });

  // ===========================================================================
  // FUSION LINE SERIES - ASSERTIONS
  // ===========================================================================
  group('FusionLineSeries - Assertions', () {
    test('throws assertion error for invalid line width (zero)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          lineWidth: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid line width (> 10)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          lineWidth: 11,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid smoothness (negative)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          smoothness: -0.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid smoothness (> 1)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          smoothness: 1.5,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid marker size (zero)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          markerSize: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid marker size (> 20)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          markerSize: 21,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid area opacity (negative)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          areaOpacity: -0.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid area opacity (> 1)', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          areaOpacity: 1.5,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts boundary values', () {
      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          lineWidth: 0.1,
          smoothness: 0.0,
          markerSize: 0.1,
          areaOpacity: 0.0,
        ),
        returnsNormally,
      );

      expect(
        () => FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          lineWidth: 10.0,
          smoothness: 1.0,
          markerSize: 20.0,
          areaOpacity: 1.0,
        ),
        returnsNormally,
      );
    });
  });

  // ===========================================================================
  // FUSION LINE SERIES - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionLineSeries - Computed Properties', () {
    test('hasData returns true when has data', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect(series.hasData, isTrue);
    });

    test('hasData returns false when empty', () {
      final series = FusionLineSeries(dataPoints: const [], color: Colors.blue);

      expect(series.hasData, isFalse);
    });

    test('pointCount returns correct count', () {
      final series = FusionLineSeries(
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
      final series = FusionLineSeries(
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
      final series = FusionLineSeries(
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
      final series = FusionLineSeries(
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
      final series = FusionLineSeries(
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
      final series = FusionLineSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
        ],
        color: Colors.blue,
      );

      expect(series.averageY, 20);
    });

    test('computed properties return null for empty data', () {
      final series = FusionLineSeries(dataPoints: const [], color: Colors.blue);

      expect(series.minX, isNull);
      expect(series.maxX, isNull);
      expect(series.minY, isNull);
      expect(series.maxY, isNull);
      expect(series.averageY, isNull);
    });
  });

  // ===========================================================================
  // FUSION LINE SERIES - METHODS
  // ===========================================================================
  group('FusionLineSeries - Methods', () {
    test('filterByRange filters data points correctly', () {
      final series = FusionLineSeries(
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
      final series = FusionLineSeries(
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
  });

  // ===========================================================================
  // FUSION LINE SERIES - COPYWITH
  // ===========================================================================
  group('FusionLineSeries - copyWith', () {
    test('copyWith creates copy with modified values', () {
      final original = FusionLineSeries(
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
      final original = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        lineWidth: 5.0,
        isCurved: false,
        showArea: true,
      );

      final copy = original.copyWith(name: 'new name');

      expect(copy.lineWidth, 5.0);
      expect(copy.isCurved, isFalse);
      expect(copy.showArea, isTrue);
    });

    test('copyWith handles all parameters', () {
      final original = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      final copy = original.copyWith(
        dataPoints: [const FusionDataPoint(1, 20)],
        name: 'new',
        color: Colors.red,
        visible: false,
        lineWidth: 5.0,
        isCurved: false,
        smoothness: 0.5,
        lineDashArray: [5, 5],
        gradient: const LinearGradient(colors: [Colors.red, Colors.green]),
        showMarkers: true,
        markerSize: 8.0,
        markerShape: MarkerShape.triangle,
        showShadow: false,
        shadow: const BoxShadow(color: Colors.black),
        showArea: true,
        areaOpacity: 0.6,
        showDataLabels: true,
        dataLabelDisplay: FusionDataLabelDisplay.maxOnly,
        dataLabelStyle: const TextStyle(color: Colors.white),
        animationDuration: const Duration(seconds: 1),
        animationCurve: Curves.bounceIn,
        interaction: const FusionSeriesInteraction(selectable: false),
      );

      expect(copy.dataPoints.length, 1);
      expect(copy.dataPoints[0].x, 1);
      expect(copy.name, 'new');
      expect(copy.color, Colors.red);
      expect(copy.visible, isFalse);
      expect(copy.lineWidth, 5.0);
      expect(copy.isCurved, isFalse);
      expect(copy.smoothness, 0.5);
      expect(copy.lineDashArray, [5, 5]);
      expect(copy.gradient, isNotNull);
      expect(copy.showMarkers, isTrue);
      expect(copy.markerSize, 8.0);
      expect(copy.markerShape, MarkerShape.triangle);
      expect(copy.showShadow, isFalse);
      expect(copy.shadow, isNotNull);
      expect(copy.showArea, isTrue);
      expect(copy.areaOpacity, 0.6);
      expect(copy.showDataLabels, isTrue);
      expect(copy.dataLabelDisplay, FusionDataLabelDisplay.maxOnly);
      expect(copy.dataLabelStyle?.color, Colors.white);
      expect(copy.animationDuration, const Duration(seconds: 1));
      expect(copy.animationCurve, Curves.bounceIn);
      expect(copy.interaction.selectable, isFalse);
    });
  });

  // ===========================================================================
  // FUSION LINE SERIES - EQUALITY
  // ===========================================================================
  group('FusionLineSeries - Equality', () {
    test('equal series are equal', () {
      final series1 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
        lineWidth: 3.0,
      );

      final series2 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
        lineWidth: 3.0,
      );

      expect(series1, equals(series2));
    });

    test('different data points makes unequal', () {
      final series1 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      final series2 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 20)],
        color: Colors.blue,
      );

      expect(series1, isNot(equals(series2)));
    });

    test('different name makes unequal', () {
      final series1 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'series1',
      );

      final series2 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'series2',
      );

      expect(series1, isNot(equals(series2)));
    });

    test('hashCode is consistent', () {
      final series1 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
      );

      final series2 = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
      );

      expect(series1.hashCode, equals(series2.hashCode));
    });

    test('identical series are equal', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect(series == series, isTrue);
    });
  });

  // ===========================================================================
  // FUSION LINE SERIES - TOSTRING
  // ===========================================================================
  group('FusionLineSeries - toString', () {
    test('toString returns descriptive string', () {
      final series = FusionLineSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
        ],
        color: Colors.blue,
        name: 'Revenue',
        isCurved: true,
        visible: true,
      );

      final str = series.toString();

      expect(str, contains('FusionLineSeries'));
      expect(str, contains('Revenue'));
      expect(str, contains('points: 2'));
      expect(str, contains('curved: true'));
      expect(str, contains('visible: true'));
    });
  });

  // ===========================================================================
  // MARKER SHAPE ENUM
  // ===========================================================================
  group('MarkerShape - Enum', () {
    test('has all expected values', () {
      expect(MarkerShape.values, hasLength(6));
      expect(MarkerShape.values, contains(MarkerShape.circle));
      expect(MarkerShape.values, contains(MarkerShape.square));
      expect(MarkerShape.values, contains(MarkerShape.triangle));
      expect(MarkerShape.values, contains(MarkerShape.diamond));
      expect(MarkerShape.values, contains(MarkerShape.cross));
      expect(MarkerShape.values, contains(MarkerShape.x));
    });
  });

  // ===========================================================================
  // FUSION DATA LABEL DISPLAY ENUM
  // ===========================================================================
  group('FusionDataLabelDisplay - Enum', () {
    test('has all expected values', () {
      expect(FusionDataLabelDisplay.values, hasLength(6));
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.all),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.maxOnly),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.minOnly),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.maxAndMin),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.firstAndLast),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.none),
      );
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionLineSeries - Edge Cases', () {
    test('handles empty data points', () {
      final series = FusionLineSeries(dataPoints: const [], color: Colors.blue);

      expect(series.hasData, isFalse);
      expect(series.pointCount, 0);
    });

    test('handles single data point', () {
      final series = FusionLineSeries(
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
    });

    test('handles negative values', () {
      final series = FusionLineSeries(
        dataPoints: [
          const FusionDataPoint(-5, -10),
          const FusionDataPoint(0, 0),
          const FusionDataPoint(5, 10),
        ],
        color: Colors.blue,
      );

      expect(series.minX, -5);
      expect(series.maxX, 5);
      expect(series.minY, -10);
      expect(series.maxY, 10);
      expect(series.averageY, 0);
    });

    test('handles very large values', () {
      final series = FusionLineSeries(
        dataPoints: [
          const FusionDataPoint(0, 1e15),
          const FusionDataPoint(1, 2e15),
        ],
        color: Colors.blue,
      );

      expect(series.minY, 1e15);
      expect(series.maxY, 2e15);
    });

    test('handles very small values', () {
      final series = FusionLineSeries(
        dataPoints: [
          const FusionDataPoint(0, 1e-15),
          const FusionDataPoint(1, 2e-15),
        ],
        color: Colors.blue,
      );

      expect(series.minY, 1e-15);
      expect(series.maxY, 2e-15);
    });
  });
}

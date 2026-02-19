import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_pie_data_point.dart';
import 'package:fusion_charts_flutter/src/series/fusion_pie_series.dart';
import 'package:fusion_charts_flutter/src/utils/fusion_color_palette.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================

  group('FusionPieSeries - Construction', () {
    test('creates with required dataPoints', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35, label: 'Sales'),
          const FusionPieDataPoint(25, label: 'Marketing'),
        ],
      );

      expect(series.dataPoints.length, 2);
      expect(series.name, 'Series');
    });

    test('creates with all default values', () {
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
      );

      expect(series.name, 'Series');
      expect(series.innerRadiusPercent, 0.0);
      expect(series.outerRadiusPercent, 0.85);
      expect(series.startAngle, -90.0);
      expect(series.direction, PieDirection.clockwise);
      expect(series.gapBetweenSlices, 0.0);
      expect(series.cornerRadius, 0.0);
      expect(series.colors, isNull);
      expect(series.colorPalette, isNull);
      expect(series.strokeWidth, 0.0);
      expect(series.strokeColor, isNull);
      expect(series.explodeAll, isFalse);
      expect(series.explodeOffset, 10.0);
      expect(series.sortMode, PieSortMode.none);
      expect(series.groupSmallSegments, isFalse);
      expect(series.groupThreshold, 3.0);
      expect(series.groupLabel, 'Other');
      expect(series.groupColor, isNull);
      expect(series.selectionMode, PieSelectionMode.single);
      expect(series.showLabels, isTrue);
      expect(series.labelPosition, PieLabelPosition.auto);
      expect(series.visible, isTrue);
    });

    test('creates with custom values', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35),
          const FusionPieDataPoint(25),
        ],
        name: 'Revenue',
        innerRadiusPercent: 0.5,
        outerRadiusPercent: 0.9,
        startAngle: 0,
        direction: PieDirection.counterClockwise,
        gapBetweenSlices: 2.0,
        cornerRadius: 4.0,
        colors: [Colors.blue, Colors.green],
        strokeWidth: 2.0,
        strokeColor: Colors.white,
        explodeAll: true,
        explodeOffset: 15.0,
        sortMode: PieSortMode.descending,
        groupSmallSegments: true,
        groupThreshold: 5.0,
        groupLabel: 'Rest',
        groupColor: Colors.grey,
        selectionMode: PieSelectionMode.multiple,
        showLabels: false,
        labelPosition: PieLabelPosition.outside,
        visible: false,
      );

      expect(series.name, 'Revenue');
      expect(series.innerRadiusPercent, 0.5);
      expect(series.outerRadiusPercent, 0.9);
      expect(series.startAngle, 0);
      expect(series.direction, PieDirection.counterClockwise);
      expect(series.gapBetweenSlices, 2.0);
      expect(series.cornerRadius, 4.0);
      expect(series.colors, [Colors.blue, Colors.green]);
      expect(series.strokeWidth, 2.0);
      expect(series.strokeColor, Colors.white);
      expect(series.explodeAll, isTrue);
      expect(series.explodeOffset, 15.0);
      expect(series.sortMode, PieSortMode.descending);
      expect(series.groupSmallSegments, isTrue);
      expect(series.groupThreshold, 5.0);
      expect(series.groupLabel, 'Rest');
      expect(series.groupColor, Colors.grey);
      expect(series.selectionMode, PieSelectionMode.multiple);
      expect(series.showLabels, isFalse);
      expect(series.labelPosition, PieLabelPosition.outside);
      expect(series.visible, isFalse);
    });
  });

  // ===========================================================================
  // ASSERTIONS
  // ===========================================================================

  group('FusionPieSeries - Assertions', () {
    test('throws for empty dataPoints', () {
      expect(
        () => FusionPieSeries(dataPoints: []),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for negative innerRadiusPercent', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          innerRadiusPercent: -0.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for innerRadiusPercent >= 1', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          innerRadiusPercent: 1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for non-positive outerRadiusPercent', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          outerRadiusPercent: 0.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for outerRadiusPercent > 1', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          outerRadiusPercent: 1.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws when innerRadiusPercent >= outerRadiusPercent', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          innerRadiusPercent: 0.9,
          outerRadiusPercent: 0.5,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for negative gapBetweenSlices', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          gapBetweenSlices: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for negative cornerRadius', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          cornerRadius: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for negative explodeOffset', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          explodeOffset: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for groupThreshold <= 0', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          groupThreshold: 0.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for groupThreshold > 100', () {
      expect(
        () => FusionPieSeries(
          dataPoints: [const FusionPieDataPoint(100)],
          groupThreshold: 101.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows valid boundary values', () {
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        innerRadiusPercent: 0.0,
        outerRadiusPercent: 1.0,
        gapBetweenSlices: 0.0,
        cornerRadius: 0.0,
        explodeOffset: 0.0,
        groupThreshold: 100.0,
      );

      expect(series.innerRadiusPercent, 0.0);
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  group('FusionPieSeries - Computed Properties', () {
    test('isDonut returns true when innerRadiusPercent > 0', () {
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        innerRadiusPercent: 0.5,
      );

      expect(series.isDonut, isTrue);
    });

    test('isDonut returns false for pie chart', () {
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        innerRadiusPercent: 0.0,
      );

      expect(series.isDonut, isFalse);
    });

    test('total calculates sum of all values', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35),
          const FusionPieDataPoint(25),
          const FusionPieDataPoint(20),
          const FusionPieDataPoint(20),
        ],
      );

      expect(series.total, 100.0);
    });

    test('sliceCount returns number of data points', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35),
          const FusionPieDataPoint(25),
          const FusionPieDataPoint(20),
        ],
      );

      expect(series.sliceCount, 3);
    });
  });

  // ===========================================================================
  // GET COLOR FOR INDEX
  // ===========================================================================

  group('FusionPieSeries - getColorForIndex', () {
    test('returns dataPoint color when set', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35, color: Colors.red),
          const FusionPieDataPoint(25),
        ],
        colors: [Colors.blue, Colors.green],
      );

      expect(series.getColorForIndex(0), Colors.red);
    });

    test('returns explicit colors list when dataPoint has no color', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35),
          const FusionPieDataPoint(25),
        ],
        colors: [Colors.blue, Colors.green],
      );

      expect(series.getColorForIndex(0), Colors.blue);
      expect(series.getColorForIndex(1), Colors.green);
    });

    test('wraps colors list when more slices than colors', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35),
          const FusionPieDataPoint(25),
          const FusionPieDataPoint(20),
        ],
        colors: [Colors.blue, Colors.green],
      );

      expect(
        series.getColorForIndex(2),
        Colors.blue,
      ); // Wraps back to first color
    });

    test('returns colorPalette color when no explicit colors', () {
      final palette = FusionColorPalette([Colors.purple, Colors.orange]);
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35),
          const FusionPieDataPoint(25),
        ],
        colorPalette: palette,
      );

      expect(series.getColorForIndex(0), Colors.purple);
      expect(series.getColorForIndex(1), Colors.orange);
    });

    test('returns default palette color when no other colors set', () {
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(35)],
      );

      // Uses material palette
      expect(series.getColorForIndex(0), isA<Color>());
    });

    test('accepts defaultPalette parameter', () {
      final defaultPalette = FusionColorPalette([Colors.cyan, Colors.pink]);
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(35)],
      );

      expect(series.getColorForIndex(0, defaultPalette), Colors.cyan);
    });
  });

  // ===========================================================================
  // GET SORTED DATA POINTS
  // ===========================================================================

  group('FusionPieSeries - getSortedDataPoints', () {
    test('returns original order when sortMode is none', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(20, label: 'A'),
          const FusionPieDataPoint(50, label: 'B'),
          const FusionPieDataPoint(30, label: 'C'),
        ],
        sortMode: PieSortMode.none,
      );

      final sorted = series.getSortedDataPoints();

      expect(sorted[0].label, 'A');
      expect(sorted[1].label, 'B');
      expect(sorted[2].label, 'C');
    });

    test('sorts ascending', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(50, label: 'B'),
          const FusionPieDataPoint(20, label: 'A'),
          const FusionPieDataPoint(30, label: 'C'),
        ],
        sortMode: PieSortMode.ascending,
      );

      final sorted = series.getSortedDataPoints();

      expect(sorted[0].value, 20);
      expect(sorted[1].value, 30);
      expect(sorted[2].value, 50);
    });

    test('sorts descending', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(20, label: 'A'),
          const FusionPieDataPoint(50, label: 'B'),
          const FusionPieDataPoint(30, label: 'C'),
        ],
        sortMode: PieSortMode.descending,
      );

      final sorted = series.getSortedDataPoints();

      expect(sorted[0].value, 50);
      expect(sorted[1].value, 30);
      expect(sorted[2].value, 20);
    });

    test('does not modify original dataPoints', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(50, label: 'B'),
          const FusionPieDataPoint(20, label: 'A'),
        ],
        sortMode: PieSortMode.ascending,
      );

      series.getSortedDataPoints();

      expect(series.dataPoints[0].label, 'B'); // Original unchanged
    });
  });

  // ===========================================================================
  // GET GROUPED DATA POINTS
  // ===========================================================================

  group('FusionPieSeries - getGroupedDataPoints', () {
    test('returns sorted points when groupSmallSegments is false', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(50),
          const FusionPieDataPoint(30),
          const FusionPieDataPoint(20),
        ],
        groupSmallSegments: false,
      );

      final grouped = series.getGroupedDataPoints();

      expect(grouped.length, 3);
    });

    test('groups small segments into Other', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(50, label: 'A'),
          const FusionPieDataPoint(30, label: 'B'),
          const FusionPieDataPoint(10, label: 'C'),
          const FusionPieDataPoint(5, label: 'D'),
          const FusionPieDataPoint(5, label: 'E'),
        ],
        groupSmallSegments: true,
        groupThreshold: 10.0, // 10%
      );

      final grouped = series.getGroupedDataPoints();

      // A=50%, B=30%, C=10% should remain, D=5% and E=5% should be grouped
      expect(grouped.length, 4);
      expect(grouped.last.label, 'Other');
      expect(grouped.last.value, 10); // 5 + 5
    });

    test('uses custom group label', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(90),
          const FusionPieDataPoint(5),
          const FusionPieDataPoint(5),
        ],
        groupSmallSegments: true,
        groupThreshold: 10.0,
        groupLabel: 'Rest',
      );

      final grouped = series.getGroupedDataPoints();

      expect(grouped.last.label, 'Rest');
    });

    test('handles empty total gracefully', () {
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(0)],
        groupSmallSegments: true,
      );

      final grouped = series.getGroupedDataPoints();

      expect(grouped.length, 1);
    });
  });

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  group('FusionPieSeries - copyWith', () {
    test('creates copy with modified dataPoints', () {
      final original = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(35)],
      );
      final copy = original.copyWith(
        dataPoints: [
          const FusionPieDataPoint(50),
          const FusionPieDataPoint(50),
        ],
      );

      expect(copy.dataPoints.length, 2);
      expect(original.dataPoints.length, 1);
    });

    test('creates copy with modified geometry', () {
      final original = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
      );
      final copy = original.copyWith(
        innerRadiusPercent: 0.5,
        outerRadiusPercent: 0.9,
        startAngle: 0,
        direction: PieDirection.counterClockwise,
      );

      expect(copy.innerRadiusPercent, 0.5);
      expect(copy.outerRadiusPercent, 0.9);
      expect(copy.startAngle, 0);
      expect(copy.direction, PieDirection.counterClockwise);
    });

    test('creates copy with modified explode settings', () {
      final original = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
      );
      final copy = original.copyWith(explodeAll: true, explodeOffset: 20.0);

      expect(copy.explodeAll, isTrue);
      expect(copy.explodeOffset, 20.0);
    });

    test('creates copy with modified sorting', () {
      final original = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
      );
      final copy = original.copyWith(
        sortMode: PieSortMode.descending,
        groupSmallSegments: true,
        groupThreshold: 5.0,
      );

      expect(copy.sortMode, PieSortMode.descending);
      expect(copy.groupSmallSegments, isTrue);
      expect(copy.groupThreshold, 5.0);
    });

    test('creates unchanged copy when no parameters', () {
      final original = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        name: 'Test',
      );
      final copy = original.copyWith();

      expect(copy.name, original.name);
      expect(copy.dataPoints.length, original.dataPoints.length);
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================

  group('FusionPieSeries - Equality', () {
    test('equal series are equal', () {
      final series1 = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        name: 'Test',
        innerRadiusPercent: 0.5,
      );
      final series2 = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        name: 'Test',
        innerRadiusPercent: 0.5,
      );

      expect(series1, equals(series2));
    });

    test('series with different names are not equal', () {
      final series1 = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        name: 'Series1',
      );
      final series2 = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        name: 'Series2',
      );

      expect(series1, isNot(equals(series2)));
    });

    test('series with different dataPoints count are not equal', () {
      final series1 = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
      );
      final series2 = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(50),
          const FusionPieDataPoint(50),
        ],
      );

      expect(series1, isNot(equals(series2)));
    });

    test('identical series are equal', () {
      final series = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
      );
      expect(series == series, isTrue);
    });
  });

  // ===========================================================================
  // HASH CODE
  // ===========================================================================

  group('FusionPieSeries - hashCode', () {
    test('equal series have equal hash codes', () {
      final series1 = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        name: 'Test',
      );
      final series2 = FusionPieSeries(
        dataPoints: [const FusionPieDataPoint(100)],
        name: 'Test',
      );

      expect(series1.hashCode, equals(series2.hashCode));
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('FusionPieSeries - toString', () {
    test('includes name and slice count', () {
      final series = FusionPieSeries(
        dataPoints: [
          const FusionPieDataPoint(35),
          const FusionPieDataPoint(25),
          const FusionPieDataPoint(20),
        ],
        name: 'Revenue',
      );

      final str = series.toString();

      expect(str, contains('Revenue'));
      expect(str, contains('3'));
    });
  });

  // ===========================================================================
  // ENUMS
  // ===========================================================================

  group('PieDirection', () {
    test('has all expected values', () {
      expect(PieDirection.values, contains(PieDirection.clockwise));
      expect(PieDirection.values, contains(PieDirection.counterClockwise));
      expect(PieDirection.values.length, 2);
    });
  });

  group('PieSortMode', () {
    test('has all expected values', () {
      expect(PieSortMode.values, contains(PieSortMode.none));
      expect(PieSortMode.values, contains(PieSortMode.ascending));
      expect(PieSortMode.values, contains(PieSortMode.descending));
      expect(PieSortMode.values.length, 3);
    });
  });

  group('PieSelectionMode', () {
    test('has all expected values', () {
      expect(PieSelectionMode.values, contains(PieSelectionMode.none));
      expect(PieSelectionMode.values, contains(PieSelectionMode.single));
      expect(PieSelectionMode.values, contains(PieSelectionMode.multiple));
      expect(PieSelectionMode.values.length, 3);
    });
  });

  group('PieLabelPosition', () {
    test('has all expected values', () {
      expect(PieLabelPosition.values, contains(PieLabelPosition.auto));
      expect(PieLabelPosition.values, contains(PieLabelPosition.inside));
      expect(PieLabelPosition.values, contains(PieLabelPosition.outside));
      expect(PieLabelPosition.values, contains(PieLabelPosition.none));
      expect(PieLabelPosition.values.length, 4);
    });
  });

  // ===========================================================================
  // STATE CLASSES
  // ===========================================================================

  group('PieCenterState', () {
    test('creates with required values', () {
      const state = PieCenterState(total: 100, selectedIndices: {});

      expect(state.total, 100);
      expect(state.selectedIndices, isEmpty);
      expect(state.selectedSegment, isNull);
      expect(state.hoveredSegment, isNull);
    });

    test('hasSelection returns true when indices not empty', () {
      const state = PieCenterState(total: 100, selectedIndices: {0, 1});

      expect(state.hasSelection, isTrue);
    });

    test('hasSelection returns false when indices empty', () {
      const state = PieCenterState(total: 100, selectedIndices: {});

      expect(state.hasSelection, isFalse);
    });

    test('hasHover returns true when hoveredSegment set', () {
      const state = PieCenterState(
        total: 100,
        selectedIndices: {},
        hoveredSegment: PieSegmentData(
          index: 0,
          value: 50,
          percentage: 50,
          color: Colors.blue,
        ),
      );

      expect(state.hasHover, isTrue);
    });

    test('hasHover returns false when hoveredSegment null', () {
      const state = PieCenterState(total: 100, selectedIndices: {});

      expect(state.hasHover, isFalse);
    });
  });

  group('PieSegmentData', () {
    test('creates with required values', () {
      const segment = PieSegmentData(
        index: 0,
        value: 50,
        percentage: 50,
        color: Colors.blue,
      );

      expect(segment.index, 0);
      expect(segment.value, 50);
      expect(segment.percentage, 50);
      expect(segment.color, Colors.blue);
      expect(segment.label, isNull);
      expect(segment.dataPoint, isNull);
    });

    test('creates with optional values', () {
      const point = FusionPieDataPoint(50, label: 'Test');
      const segment = PieSegmentData(
        index: 0,
        value: 50,
        percentage: 50,
        color: Colors.blue,
        label: 'Test',
        dataPoint: point,
      );

      expect(segment.label, 'Test');
      expect(segment.dataPoint, point);
    });
  });

  group('PieLabelData', () {
    test('creates with all required values', () {
      const labelData = PieLabelData(
        index: 0,
        value: 50,
        percentage: 50,
        label: 'Sales',
        color: Colors.blue,
        position: Offset(100, 100),
        isSelected: false,
        isHovered: false,
      );

      expect(labelData.index, 0);
      expect(labelData.value, 50);
      expect(labelData.percentage, 50);
      expect(labelData.label, 'Sales');
      expect(labelData.color, Colors.blue);
      expect(labelData.position, const Offset(100, 100));
      expect(labelData.isSelected, isFalse);
      expect(labelData.isHovered, isFalse);
    });
  });
}

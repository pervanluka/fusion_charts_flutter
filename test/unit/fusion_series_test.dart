import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/series/fusion_bar_series.dart';
import 'package:fusion_charts_flutter/src/series/fusion_line_series.dart';
import 'package:fusion_charts_flutter/src/series/fusion_series.dart';

void main() {
  // ===========================================================================
  // FUSION SERIES INTERACTION - CONSTRUCTION
  // ===========================================================================
  group('FusionSeriesInteraction - Construction', () {
    test('creates with default values', () {
      const interaction = FusionSeriesInteraction();

      expect(interaction.selectable, isTrue);
      expect(interaction.highlightOnHover, isTrue);
      expect(interaction.showTooltip, isTrue);
      expect(interaction.enableSelection, isTrue);
    });

    test('creates with custom values', () {
      const interaction = FusionSeriesInteraction(
        selectable: false,
        highlightOnHover: false,
        showTooltip: false,
        enableSelection: false,
      );

      expect(interaction.selectable, isFalse);
      expect(interaction.highlightOnHover, isFalse);
      expect(interaction.showTooltip, isFalse);
      expect(interaction.enableSelection, isFalse);
    });
  });

  // ===========================================================================
  // FUSION SERIES INTERACTION - COPYWITH
  // ===========================================================================
  group('FusionSeriesInteraction - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionSeriesInteraction(
        selectable: true,
        highlightOnHover: true,
      );

      final copy = original.copyWith(
        selectable: false,
        highlightOnHover: false,
      );

      expect(copy.selectable, isFalse);
      expect(copy.highlightOnHover, isFalse);
      expect(copy.showTooltip, isTrue);
      expect(copy.enableSelection, isTrue);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionSeriesInteraction(
        selectable: false,
        highlightOnHover: false,
        showTooltip: false,
        enableSelection: false,
      );

      final copy = original.copyWith(selectable: true);

      expect(copy.selectable, isTrue);
      expect(copy.highlightOnHover, isFalse);
      expect(copy.showTooltip, isFalse);
      expect(copy.enableSelection, isFalse);
    });

    test('copyWith handles all parameters', () {
      const original = FusionSeriesInteraction();

      final copy = original.copyWith(
        selectable: false,
        highlightOnHover: false,
        showTooltip: false,
        enableSelection: false,
      );

      expect(copy.selectable, isFalse);
      expect(copy.highlightOnHover, isFalse);
      expect(copy.showTooltip, isFalse);
      expect(copy.enableSelection, isFalse);
    });
  });

  // ===========================================================================
  // FUSION SERIES INTERACTION - EQUALITY
  // ===========================================================================
  group('FusionSeriesInteraction - Equality', () {
    test('equal interactions are equal', () {
      const interaction1 = FusionSeriesInteraction(
        selectable: true,
        highlightOnHover: false,
      );

      const interaction2 = FusionSeriesInteraction(
        selectable: true,
        highlightOnHover: false,
      );

      expect(interaction1, equals(interaction2));
    });

    test('different interactions are not equal', () {
      const interaction1 = FusionSeriesInteraction(selectable: true);

      const interaction2 = FusionSeriesInteraction(selectable: false);

      expect(interaction1, isNot(equals(interaction2)));
    });

    test('hashCode is consistent', () {
      const interaction1 = FusionSeriesInteraction(
        selectable: true,
        highlightOnHover: true,
      );

      const interaction2 = FusionSeriesInteraction(
        selectable: true,
        highlightOnHover: true,
      );

      expect(interaction1.hashCode, equals(interaction2.hashCode));
    });

    test('identical interactions are equal', () {
      const interaction = FusionSeriesInteraction();

      expect(interaction == interaction, isTrue);
    });
  });

  // ===========================================================================
  // FUSION SERIES LIST EXTENSIONS
  // ===========================================================================
  group('FusionSeriesListExtensions', () {
    test('visibleOnly returns only visible series', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          name: 'visible1',
          visible: true,
        ),
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.red,
          name: 'hidden',
          visible: false,
        ),
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.green,
          name: 'visible2',
          visible: true,
        ),
      ];

      final visible = series.visibleOnly;

      expect(visible.length, 2);
      expect(visible[0].name, 'visible1');
      expect(visible[1].name, 'visible2');
    });

    test('findByName returns series with matching name', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          name: 'Revenue',
        ),
        FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 20)],
          color: Colors.red,
          name: 'Costs',
        ),
      ];

      final found = series.findByName('Revenue');

      expect(found, isNotNull);
      expect(found!.name, 'Revenue');
      expect(found, isA<FusionLineSeries>());
    });

    test('findByName returns null for non-existent name', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          name: 'Revenue',
        ),
      ];

      final found = series.findByName('NonExistent');

      expect(found, isNull);
    });

    test('allVisible returns true when all series visible', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          visible: true,
        ),
        FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 20)],
          color: Colors.red,
          visible: true,
        ),
      ];

      expect(series.allVisible, isTrue);
    });

    test('allVisible returns false when any series hidden', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          visible: true,
        ),
        FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 20)],
          color: Colors.red,
          visible: false,
        ),
      ];

      expect(series.allVisible, isFalse);
    });

    test('anyVisible returns true when at least one series visible', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          visible: false,
        ),
        FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 20)],
          color: Colors.red,
          visible: true,
        ),
      ];

      expect(series.anyVisible, isTrue);
    });

    test('anyVisible returns false when all series hidden', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          visible: false,
        ),
        FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 20)],
          color: Colors.red,
          visible: false,
        ),
      ];

      expect(series.anyVisible, isFalse);
    });

    test('visibleCount returns correct count', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          visible: true,
        ),
        FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 20)],
          color: Colors.red,
          visible: false,
        ),
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 30)],
          color: Colors.green,
          visible: true,
        ),
      ];

      expect(series.visibleCount, 2);
    });

    test('toggleVisibility toggles visibility of matching series', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          name: 'Revenue',
          visible: true,
        ),
        FusionBarSeries(
          dataPoints: [const FusionDataPoint(0, 20)],
          color: Colors.red,
          name: 'Costs',
          visible: true,
        ),
      ];

      final toggled = series.toggleVisibility('Revenue');

      expect(toggled[0].visible, isFalse);
      expect(toggled[1].visible, isTrue);
    });

    test('toggleVisibility does not modify non-matching series', () {
      final series = <FusionSeries>[
        FusionLineSeries(
          dataPoints: [const FusionDataPoint(0, 10)],
          color: Colors.blue,
          name: 'Revenue',
          visible: true,
        ),
      ];

      final toggled = series.toggleVisibility('NonExistent');

      expect(toggled[0].visible, isTrue);
    });

    test('empty list returns correct values', () {
      final series = <FusionSeries>[];

      expect(series.visibleOnly, isEmpty);
      expect(series.findByName('test'), isNull);
      expect(series.allVisible, isTrue);
      expect(series.anyVisible, isFalse);
      expect(series.visibleCount, 0);
    });
  });

  // ===========================================================================
  // FUSION GRADIENT SUPPORT MIXIN
  // ===========================================================================
  group('FusionGradientSupport - Mixin', () {
    test('createDefaultGradient creates vertical gradient', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      final gradient = (series as FusionGradientSupport).createDefaultGradient(
        Colors.blue,
        opacity: 0.2,
      );

      expect(gradient.colors.length, 2);
      expect(gradient.colors[0], Colors.blue);
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
    });

    test('createDefaultGradient with custom alignment', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      final gradient = (series as FusionGradientSupport).createDefaultGradient(
        Colors.red,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

      expect(gradient.begin, Alignment.centerLeft);
      expect(gradient.end, Alignment.centerRight);
    });
  });

  // ===========================================================================
  // FUSION MARKER SUPPORT MIXIN DEFAULTS
  // ===========================================================================
  group('FusionMarkerSupport - Mixin Defaults', () {
    test('has correct default marker values', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect((series as FusionMarkerSupport).markerColor, isNull);
      expect(series.markerBorderColor, isNull);
      expect(series.markerBorderWidth, 1.0);
    });
  });

  // ===========================================================================
  // FUSION ANIMATION SUPPORT MIXIN DEFAULTS
  // ===========================================================================
  group('FusionAnimationSupport - Mixin Defaults', () {
    test('has correct default animation delay', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
      );

      expect((series as FusionAnimationSupport).animationDelay, Duration.zero);
    });
  });

  // ===========================================================================
  // FUSION SERIES BASE CLASS
  // ===========================================================================
  group('FusionSeries - Base Class', () {
    test('line series extends FusionSeries', () {
      final series = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
      );

      expect(series, isA<FusionSeries>());
      expect(series.name, 'test');
      expect(series.color, Colors.blue);
      expect(series.visible, isTrue);
    });

    test('bar series extends FusionSeries', () {
      final series = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.red,
        name: 'test',
      );

      expect(series, isA<FusionSeries>());
      expect(series.name, 'test');
      expect(series.color, Colors.red);
      expect(series.visible, isTrue);
    });

    test('different series types are not equal', () {
      final lineSeries = FusionLineSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
      );

      final barSeries = FusionBarSeries(
        dataPoints: [const FusionDataPoint(0, 10)],
        color: Colors.blue,
        name: 'test',
      );

      expect(lineSeries, isNot(equals(barSeries)));
    });
  });
}

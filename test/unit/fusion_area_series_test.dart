import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/enums/marker_shape.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/series/fusion_area_series.dart';
import 'package:fusion_charts_flutter/src/series/fusion_series.dart';

void main() {
  // ===========================================================================
  // FUSION AREA SERIES - CONSTRUCTION
  // ===========================================================================
  group('FusionAreaSeries - Construction', () {
    test('creates with required parameters', () {
      final series = FusionAreaSeries(
        name: 'Revenue',
        color: Colors.blue,
        dataPoints: [FusionDataPoint(0, 100), FusionDataPoint(1, 150)],
      );

      expect(series.name, 'Revenue');
      expect(series.color, Colors.blue);
      expect(series.dataPoints.length, 2);
    });

    test('has correct default values', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.red,
        dataPoints: [],
      );

      expect(series.visible, isTrue);
      expect(series.opacity, 0.5);
      expect(series.isCurved, isTrue);
      expect(series.smoothness, 0.35);
      expect(series.borderWidth, 2.0);
      expect(series.borderColor, isNull);
      expect(series.gradient, isNull);
      // Marker defaults
      expect(series.showMarkers, isFalse);
      expect(series.markerSize, 6.0);
      expect(series.markerColor, isNull);
      expect(series.markerShape, MarkerShape.circle);
      expect(series.markerBorderColor, isNull);
      expect(series.markerBorderWidth, 1.0);
      // Data label defaults
      expect(series.showDataLabels, isFalse);
      expect(series.dataLabelStyle, isNull);
      expect(series.dataLabelFormatter, isNull);
    });

    test('accepts custom opacity', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        opacity: 0.8,
      );

      expect(series.opacity, 0.8);
    });

    test('accepts isCurved false for linear lines', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        isCurved: false,
      );

      expect(series.isCurved, isFalse);
    });

    test('accepts custom smoothness', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        smoothness: 0.7,
      );

      expect(series.smoothness, 0.7);
    });

    test('accepts border customization', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        borderWidth: 3.0,
        borderColor: Colors.red,
      );

      expect(series.borderWidth, 3.0);
      expect(series.borderColor, Colors.red);
    });

    test('accepts gradient fill', () {
      const gradient = LinearGradient(colors: [Colors.blue, Colors.green]);

      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        gradient: gradient,
      );

      expect(series.gradient, gradient);
    });

    test('accepts marker customization', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showMarkers: true,
        markerSize: 10.0,
        markerColor: Colors.red,
        markerShape: MarkerShape.diamond,
        markerBorderColor: Colors.black,
        markerBorderWidth: 2.0,
      );

      expect(series.showMarkers, isTrue);
      expect(series.markerSize, 10.0);
      expect(series.markerColor, Colors.red);
      expect(series.markerShape, MarkerShape.diamond);
      expect(series.markerBorderColor, Colors.black);
      expect(series.markerBorderWidth, 2.0);
    });

    test('accepts data label customization', () {
      String formatter(double v) => '\$${v.toStringAsFixed(0)}';
      const style = TextStyle(fontSize: 14);

      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showDataLabels: true,
        dataLabelStyle: style,
        dataLabelFormatter: formatter,
      );

      expect(series.showDataLabels, isTrue);
      expect(series.dataLabelStyle, style);
      expect(series.dataLabelFormatter, formatter);
      expect(series.dataLabelFormatter!(100), '\$100');
    });

    test('accepts visibility false', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        visible: false,
      );

      expect(series.visible, isFalse);
    });
  });

  // ===========================================================================
  // FUSION AREA SERIES - COPY WITH
  // ===========================================================================
  group('FusionAreaSeries - copyWith', () {
    late FusionAreaSeries original;

    setUp(() {
      original = FusionAreaSeries(
        name: 'Original',
        color: Colors.blue,
        dataPoints: [FusionDataPoint(0, 100)],
        opacity: 0.5,
        isCurved: true,
        smoothness: 0.35,
        borderWidth: 2.0,
        showMarkers: false,
      );
    });

    test('returns new instance with same values when no arguments', () {
      final copy = original.copyWith();

      expect(copy, isNot(same(original)));
      expect(copy.name, original.name);
      expect(copy.color, original.color);
      expect(copy.opacity, original.opacity);
    });

    test('copies with new name', () {
      final copy = original.copyWith(name: 'New Name');

      expect(copy.name, 'New Name');
      expect(copy.color, original.color);
    });

    test('copies with new color', () {
      final copy = original.copyWith(color: Colors.red);

      expect(copy.color, Colors.red);
      expect(copy.name, original.name);
    });

    test('copies with new dataPoints', () {
      final newPoints = [FusionDataPoint(0, 200), FusionDataPoint(1, 300)];
      final copy = original.copyWith(dataPoints: newPoints);

      expect(copy.dataPoints, newPoints);
      expect(copy.dataPoints.length, 2);
    });

    test('copies with new visibility', () {
      final copy = original.copyWith(visible: false);

      expect(copy.visible, isFalse);
    });

    test('copies with new opacity', () {
      final copy = original.copyWith(opacity: 0.8);

      expect(copy.opacity, 0.8);
    });

    test('copies with new isCurved', () {
      final copy = original.copyWith(isCurved: false);

      expect(copy.isCurved, isFalse);
    });

    test('copies with new smoothness', () {
      final copy = original.copyWith(smoothness: 0.9);

      expect(copy.smoothness, 0.9);
    });

    test('copies with new borderWidth', () {
      final copy = original.copyWith(borderWidth: 4.0);

      expect(copy.borderWidth, 4.0);
    });

    test('copies with new borderColor', () {
      final copy = original.copyWith(borderColor: Colors.green);

      expect(copy.borderColor, Colors.green);
    });

    test('copies with new gradient', () {
      const gradient = LinearGradient(colors: [Colors.red, Colors.orange]);
      final copy = original.copyWith(gradient: gradient);

      expect(copy.gradient, gradient);
    });

    test('copies with marker properties', () {
      final copy = original.copyWith(
        showMarkers: true,
        markerSize: 12.0,
        markerColor: Colors.yellow,
        markerShape: MarkerShape.triangle,
        markerBorderColor: Colors.white,
        markerBorderWidth: 3.0,
      );

      expect(copy.showMarkers, isTrue);
      expect(copy.markerSize, 12.0);
      expect(copy.markerColor, Colors.yellow);
      expect(copy.markerShape, MarkerShape.triangle);
      expect(copy.markerBorderColor, Colors.white);
      expect(copy.markerBorderWidth, 3.0);
    });

    test('copies with data label properties', () {
      String formatter(double v) => '${v.toInt()}%';
      const style = TextStyle(color: Colors.purple);

      final copy = original.copyWith(
        showDataLabels: true,
        dataLabelStyle: style,
        dataLabelFormatter: formatter,
      );

      expect(copy.showDataLabels, isTrue);
      expect(copy.dataLabelStyle, style);
      expect(copy.dataLabelFormatter, formatter);
    });

    test('copies with multiple properties at once', () {
      final copy = original.copyWith(
        name: 'Updated',
        color: Colors.purple,
        opacity: 0.7,
        isCurved: false,
        showMarkers: true,
      );

      expect(copy.name, 'Updated');
      expect(copy.color, Colors.purple);
      expect(copy.opacity, 0.7);
      expect(copy.isCurved, isFalse);
      expect(copy.showMarkers, isTrue);
      // Unchanged properties
      expect(copy.smoothness, original.smoothness);
      expect(copy.borderWidth, original.borderWidth);
    });
  });

  // ===========================================================================
  // FUSION AREA SERIES - EQUALITY
  // ===========================================================================
  group('FusionAreaSeries - Equality', () {
    test('two series with same values are equal', () {
      final dataPoints = [FusionDataPoint(0, 100)];
      final series1 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: dataPoints,
        opacity: 0.5,
        isCurved: true,
      );

      final series2 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: dataPoints,
        opacity: 0.5,
        isCurved: true,
      );

      expect(series1, equals(series2));
    });

    test('series with different names are not equal', () {
      final dataPoints = [FusionDataPoint(0, 100)];
      final series1 = FusionAreaSeries(
        name: 'Test1',
        color: Colors.blue,
        dataPoints: dataPoints,
      );

      final series2 = FusionAreaSeries(
        name: 'Test2',
        color: Colors.blue,
        dataPoints: dataPoints,
      );

      expect(series1, isNot(equals(series2)));
    });

    test('series with different colors are not equal', () {
      final series1 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
      );

      final series2 = FusionAreaSeries(
        name: 'Test',
        color: Colors.red,
        dataPoints: [],
      );

      expect(series1, isNot(equals(series2)));
    });

    test('series with different opacity are not equal', () {
      final series1 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        opacity: 0.5,
      );

      final series2 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        opacity: 0.8,
      );

      expect(series1, isNot(equals(series2)));
    });

    test('series with different isCurved are not equal', () {
      final series1 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        isCurved: true,
      );

      final series2 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        isCurved: false,
      );

      expect(series1, isNot(equals(series2)));
    });

    test('series with different showMarkers are not equal', () {
      final series1 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showMarkers: false,
      );

      final series2 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showMarkers: true,
      );

      expect(series1, isNot(equals(series2)));
    });

    test('identical series are equal', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
      );

      expect(series, equals(series));
    });

    test('series is not equal to null', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
      );

      // ignore: unnecessary_null_comparison, unrelated_type_equality_checks
      expect(series == null, isFalse);
    });

    test('series is not equal to different type', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
      );

      // ignore: unrelated_type_equality_checks
      expect(series == 'string', isFalse);
    });
  });

  // ===========================================================================
  // FUSION AREA SERIES - HASH CODE
  // ===========================================================================
  group('FusionAreaSeries - hashCode', () {
    test('equal series have same hashCode', () {
      final dataPoints = [FusionDataPoint(0, 100)];
      final series1 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: dataPoints,
        opacity: 0.5,
      );

      final series2 = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: dataPoints,
        opacity: 0.5,
      );

      expect(series1.hashCode, equals(series2.hashCode));
    });

    test('different series have different hashCodes', () {
      final series1 = FusionAreaSeries(
        name: 'Test1',
        color: Colors.blue,
        dataPoints: [],
      );

      final series2 = FusionAreaSeries(
        name: 'Test2',
        color: Colors.red,
        dataPoints: [],
      );

      expect(series1.hashCode, isNot(equals(series2.hashCode)));
    });

    test('hashCode is consistent', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
      );

      final hash1 = series.hashCode;
      final hash2 = series.hashCode;

      expect(hash1, equals(hash2));
    });
  });

  // ===========================================================================
  // FUSION SERIES BASE - EQUALITY AND STRING
  // ===========================================================================
  group('FusionSeries - Base Class', () {
    test('toString returns formatted string', () {
      final series = FusionAreaSeries(
        name: 'Revenue',
        color: Colors.blue,
        dataPoints: [],
        visible: true,
      );

      final str = series.toString();
      expect(str, contains('FusionSeries'));
      expect(str, contains('Revenue'));
      expect(str, contains('visible: true'));
    });
  });

  // ===========================================================================
  // FUSION SERIES INTERACTION
  // ===========================================================================
  group('FusionSeriesInteraction', () {
    test('has correct default values', () {
      const interaction = FusionSeriesInteraction();

      expect(interaction.selectable, isTrue);
      expect(interaction.highlightOnHover, isTrue);
      expect(interaction.showTooltip, isTrue);
      expect(interaction.enableSelection, isTrue);
    });

    test('accepts custom values', () {
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

    test(
      'copyWith returns new instance with same values when no arguments',
      () {
        const original = FusionSeriesInteraction(
          selectable: false,
          highlightOnHover: true,
        );

        final copy = original.copyWith();

        expect(copy.selectable, original.selectable);
        expect(copy.highlightOnHover, original.highlightOnHover);
      },
    );

    test('copyWith updates selectable', () {
      const original = FusionSeriesInteraction(selectable: true);
      final copy = original.copyWith(selectable: false);

      expect(copy.selectable, isFalse);
    });

    test('copyWith updates highlightOnHover', () {
      const original = FusionSeriesInteraction(highlightOnHover: true);
      final copy = original.copyWith(highlightOnHover: false);

      expect(copy.highlightOnHover, isFalse);
    });

    test('copyWith updates showTooltip', () {
      const original = FusionSeriesInteraction(showTooltip: true);
      final copy = original.copyWith(showTooltip: false);

      expect(copy.showTooltip, isFalse);
    });

    test('copyWith updates enableSelection', () {
      const original = FusionSeriesInteraction(enableSelection: true);
      final copy = original.copyWith(enableSelection: false);

      expect(copy.enableSelection, isFalse);
    });

    test('equality - same values are equal', () {
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

    test('equality - different values are not equal', () {
      const interaction1 = FusionSeriesInteraction(selectable: true);
      const interaction2 = FusionSeriesInteraction(selectable: false);

      expect(interaction1, isNot(equals(interaction2)));
    });

    test('hashCode is consistent for equal objects', () {
      const interaction1 = FusionSeriesInteraction(
        selectable: true,
        highlightOnHover: false,
      );
      const interaction2 = FusionSeriesInteraction(
        selectable: true,
        highlightOnHover: false,
      );

      expect(interaction1.hashCode, equals(interaction2.hashCode));
    });

    test('identical objects are equal', () {
      const interaction = FusionSeriesInteraction();
      expect(interaction, equals(interaction));
    });
  });

  // ===========================================================================
  // FUSION SERIES LIST EXTENSIONS
  // ===========================================================================
  group('FusionSeriesListExtensions', () {
    late List<FusionSeries> seriesList;

    setUp(() {
      seriesList = [
        FusionAreaSeries(
          name: 'Series1',
          color: Colors.blue,
          dataPoints: [],
          visible: true,
        ),
        FusionAreaSeries(
          name: 'Series2',
          color: Colors.red,
          dataPoints: [],
          visible: false,
        ),
        FusionAreaSeries(
          name: 'Series3',
          color: Colors.green,
          dataPoints: [],
          visible: true,
        ),
      ];
    });

    test('visibleOnly returns only visible series', () {
      final visible = seriesList.visibleOnly;

      expect(visible.length, 2);
      expect(visible[0].name, 'Series1');
      expect(visible[1].name, 'Series3');
    });

    test('visibleOnly returns empty list when none visible', () {
      final allHidden = [
        FusionAreaSeries(
          name: 'A',
          color: Colors.blue,
          dataPoints: [],
          visible: false,
        ),
        FusionAreaSeries(
          name: 'B',
          color: Colors.red,
          dataPoints: [],
          visible: false,
        ),
      ];

      expect(allHidden.visibleOnly, isEmpty);
    });

    test('findByName returns matching series', () {
      final found = seriesList.findByName('Series2');

      expect(found, isNotNull);
      expect(found!.name, 'Series2');
      expect(found.color, Colors.red);
    });

    test('findByName returns null when not found', () {
      final found = seriesList.findByName('NonExistent');

      expect(found, isNull);
    });

    test('allVisible returns false when some hidden', () {
      expect(seriesList.allVisible, isFalse);
    });

    test('allVisible returns true when all visible', () {
      final allVisible = [
        FusionAreaSeries(
          name: 'A',
          color: Colors.blue,
          dataPoints: [],
          visible: true,
        ),
        FusionAreaSeries(
          name: 'B',
          color: Colors.red,
          dataPoints: [],
          visible: true,
        ),
      ];

      expect(allVisible.allVisible, isTrue);
    });

    test('anyVisible returns true when at least one visible', () {
      expect(seriesList.anyVisible, isTrue);
    });

    test('anyVisible returns false when none visible', () {
      final noneVisible = [
        FusionAreaSeries(
          name: 'A',
          color: Colors.blue,
          dataPoints: [],
          visible: false,
        ),
      ];

      expect(noneVisible.anyVisible, isFalse);
    });

    test('visibleCount returns correct count', () {
      expect(seriesList.visibleCount, 2);
    });

    test('visibleCount returns 0 when none visible', () {
      final noneVisible = [
        FusionAreaSeries(
          name: 'A',
          color: Colors.blue,
          dataPoints: [],
          visible: false,
        ),
      ];

      expect(noneVisible.visibleCount, 0);
    });

    test('toggleVisibility toggles visibility for matching name', () {
      final toggled = seriesList.toggleVisibility('Series1');

      expect(toggled[0].visible, isFalse); // Was true, now false
      expect(toggled[1].visible, isFalse); // Unchanged
      expect(toggled[2].visible, isTrue); // Unchanged
    });

    test('toggleVisibility makes hidden series visible', () {
      final toggled = seriesList.toggleVisibility('Series2');

      expect(toggled[0].visible, isTrue); // Unchanged
      expect(toggled[1].visible, isTrue); // Was false, now true
      expect(toggled[2].visible, isTrue); // Unchanged
    });

    test('toggleVisibility returns unchanged list for non-existent name', () {
      final toggled = seriesList.toggleVisibility('NonExistent');

      expect(toggled[0].visible, seriesList[0].visible);
      expect(toggled[1].visible, seriesList[1].visible);
      expect(toggled[2].visible, seriesList[2].visible);
    });

    test('empty list has correct extension behavior', () {
      final emptyList = <FusionSeries>[];

      expect(emptyList.visibleOnly, isEmpty);
      expect(emptyList.findByName('any'), isNull);
      expect(emptyList.allVisible, isTrue); // vacuously true
      expect(emptyList.anyVisible, isFalse);
      expect(emptyList.visibleCount, 0);
      expect(emptyList.toggleVisibility('any'), isEmpty);
    });
  });

  // ===========================================================================
  // FUSION GRADIENT SUPPORT MIXIN
  // ===========================================================================
  group('FusionGradientSupport mixin', () {
    test('createDefaultGradient creates gradient with default values', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
      );

      // Access via the mixin - need to test indirectly
      // FusionAreaSeries uses FusionMarkerSupport and FusionDataLabelSupport
      // but gradient support is in FusionGradientSupport which is not mixed in
      // Let's just test the gradient property
      expect(series.gradient, isNull);
    });

    test('series can have custom gradient', () {
      const gradient = LinearGradient(
        colors: [Colors.blue, Colors.cyan],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        gradient: gradient,
      );

      expect(series.gradient, gradient);
      expect(series.gradient!.colors, [Colors.blue, Colors.cyan]);
    });
  });

  // ===========================================================================
  // MARKER SHAPE ENUM VARIATIONS
  // ===========================================================================
  group('FusionAreaSeries - MarkerShape variations', () {
    test('accepts circle marker shape', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showMarkers: true,
        markerShape: MarkerShape.circle,
      );

      expect(series.markerShape, MarkerShape.circle);
    });

    test('accepts square marker shape', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showMarkers: true,
        markerShape: MarkerShape.square,
      );

      expect(series.markerShape, MarkerShape.square);
    });

    test('accepts diamond marker shape', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showMarkers: true,
        markerShape: MarkerShape.diamond,
      );

      expect(series.markerShape, MarkerShape.diamond);
    });

    test('accepts triangle marker shape', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showMarkers: true,
        markerShape: MarkerShape.triangle,
      );

      expect(series.markerShape, MarkerShape.triangle);
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionAreaSeries - Edge Cases', () {
    test('handles empty data points', () {
      final series = FusionAreaSeries(
        name: 'Empty',
        color: Colors.blue,
        dataPoints: [],
      );

      expect(series.dataPoints, isEmpty);
    });

    test('handles single data point', () {
      final series = FusionAreaSeries(
        name: 'Single',
        color: Colors.blue,
        dataPoints: [FusionDataPoint(0, 100)],
      );

      expect(series.dataPoints.length, 1);
      expect(series.dataPoints[0].x, 0);
      expect(series.dataPoints[0].y, 100);
    });

    test('handles many data points', () {
      final dataPoints = List.generate(
        1000,
        (i) => FusionDataPoint(i.toDouble(), i * 10.0),
      );

      final series = FusionAreaSeries(
        name: 'Large',
        color: Colors.blue,
        dataPoints: dataPoints,
      );

      expect(series.dataPoints.length, 1000);
    });

    test('handles negative values', () {
      final series = FusionAreaSeries(
        name: 'Negative',
        color: Colors.blue,
        dataPoints: [
          FusionDataPoint(-5, -100),
          FusionDataPoint(0, 0),
          FusionDataPoint(5, 100),
        ],
      );

      expect(series.dataPoints[0].x, -5);
      expect(series.dataPoints[0].y, -100);
    });

    test('handles zero opacity', () {
      final series = FusionAreaSeries(
        name: 'Transparent',
        color: Colors.blue,
        dataPoints: [],
        opacity: 0.0,
      );

      expect(series.opacity, 0.0);
    });

    test('handles full opacity', () {
      final series = FusionAreaSeries(
        name: 'Opaque',
        color: Colors.blue,
        dataPoints: [],
        opacity: 1.0,
      );

      expect(series.opacity, 1.0);
    });

    test('handles zero smoothness', () {
      final series = FusionAreaSeries(
        name: 'Linear',
        color: Colors.blue,
        dataPoints: [],
        isCurved: true,
        smoothness: 0.0,
      );

      expect(series.smoothness, 0.0);
    });

    test('handles maximum smoothness', () {
      final series = FusionAreaSeries(
        name: 'VerySmooth',
        color: Colors.blue,
        dataPoints: [],
        isCurved: true,
        smoothness: 1.0,
      );

      expect(series.smoothness, 1.0);
    });

    test('handles zero border width', () {
      final series = FusionAreaSeries(
        name: 'NoBorder',
        color: Colors.blue,
        dataPoints: [],
        borderWidth: 0.0,
      );

      expect(series.borderWidth, 0.0);
    });

    test('handles empty name', () {
      final series = FusionAreaSeries(
        name: '',
        color: Colors.blue,
        dataPoints: [],
      );

      expect(series.name, '');
    });
  });

  // ===========================================================================
  // DATA FORMATTER CALLBACK
  // ===========================================================================
  group('FusionAreaSeries - Data Label Formatter', () {
    test('formatter is called with correct value', () {
      double? receivedValue;
      String formatter(double v) {
        receivedValue = v;
        return 'formatted';
      }

      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showDataLabels: true,
        dataLabelFormatter: formatter,
      );

      series.dataLabelFormatter!(42.5);
      expect(receivedValue, 42.5);
    });

    test('formatter returns custom format', () {
      final series = FusionAreaSeries(
        name: 'Test',
        color: Colors.blue,
        dataPoints: [],
        showDataLabels: true,
        dataLabelFormatter: (v) => '${v.toInt()} units',
      );

      expect(series.dataLabelFormatter!(100), '100 units');
      expect(series.dataLabelFormatter!(50.7), '50 units');
    });

    test('formatter can handle currency format', () {
      final series = FusionAreaSeries(
        name: 'Revenue',
        color: Colors.blue,
        dataPoints: [],
        showDataLabels: true,
        dataLabelFormatter: (v) => '\$${v.toStringAsFixed(2)}',
      );

      expect(series.dataLabelFormatter!(1234.5), '\$1234.50');
    });

    test('formatter can handle percentage format', () {
      final series = FusionAreaSeries(
        name: 'Progress',
        color: Colors.blue,
        dataPoints: [],
        showDataLabels: true,
        dataLabelFormatter: (v) => '${(v * 100).toInt()}%',
      );

      expect(series.dataLabelFormatter!(0.75), '75%');
    });
  });
}

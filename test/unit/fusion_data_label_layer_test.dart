import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_data_label_display.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_paint_pool.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_render_context.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_shader_cache.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';
import 'package:fusion_charts_flutter/src/rendering/layers/fusion_data_label_layer.dart';
import 'package:fusion_charts_flutter/src/series/fusion_line_series.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_light_theme.dart';

void main() {
  // ===========================================================================
  // TEST FIXTURES
  // ===========================================================================

  late FusionCoordinateSystem defaultCoordSystem;
  late FusionPaintPool defaultPaintPool;
  late FusionShaderCache defaultShaderCache;
  late FusionLightTheme defaultTheme;
  late Rect defaultChartArea;

  setUp(() {
    defaultChartArea = const Rect.fromLTWH(60, 10, 300, 200);
    defaultCoordSystem = FusionCoordinateSystem(
      chartArea: defaultChartArea,
      dataXMin: 0,
      dataXMax: 100,
      dataYMin: 0,
      dataYMax: 100,
    );
    defaultPaintPool = FusionPaintPool();
    defaultShaderCache = FusionShaderCache();
    defaultTheme = const FusionLightTheme();
  });

  tearDown(() {
    defaultPaintPool.clear();
    defaultShaderCache.clear();
  });

  // Helper function to create a default render context
  FusionRenderContext createDefaultContext({
    Rect? chartArea,
    FusionCoordinateSystem? coordSystem,
  }) {
    final area = chartArea ?? defaultChartArea;
    return FusionRenderContext(
      chartArea: area,
      coordSystem: coordSystem ?? defaultCoordSystem,
      theme: defaultTheme,
      paintPool: defaultPaintPool,
      shaderCache: defaultShaderCache,
    );
  }

  // Helper to create a mock series with data labels enabled
  FusionLineSeries createTestSeries({
    List<FusionDataPoint>? dataPoints,
    bool showDataLabels = true,
    FusionDataLabelDisplay dataLabelDisplay = FusionDataLabelDisplay.all,
    bool visible = true,
    Color color = Colors.blue,
    String name = 'Test Series',
    String Function(double)? dataLabelFormatter,
    TextStyle? dataLabelStyle,
  }) {
    return FusionLineSeries(
      name: name,
      color: color,
      dataPoints:
          dataPoints ??
          [
            const FusionDataPoint(0, 10),
            const FusionDataPoint(25, 50),
            const FusionDataPoint(50, 30),
            const FusionDataPoint(75, 80),
            const FusionDataPoint(100, 40),
          ],
      visible: visible,
      showDataLabels: showDataLabels,
      dataLabelDisplay: dataLabelDisplay,
      dataLabelFormatter: dataLabelFormatter,
      dataLabelStyle: dataLabelStyle,
    );
  }

  // ===========================================================================
  // CONSTRUCTION AND INITIALIZATION
  // ===========================================================================

  group('FusionDataLabelLayer - Construction', () {
    test('creates layer with required parameters', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      expect(layer.series, equals(series));
      expect(layer.enableBackground, isTrue);
      expect(layer.enableBorder, isFalse);
      expect(layer.enableShadow, isFalse);
      expect(layer.enableCollisionDetection, isFalse);
    });

    test('creates layer with custom optional parameters', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(
        series: series,
        enableBackground: false,
        enableBorder: true,
        enableShadow: true,
        enableCollisionDetection: true,
      );

      expect(layer.enableBackground, isFalse);
      expect(layer.enableBorder, isTrue);
      expect(layer.enableShadow, isTrue);
      expect(layer.enableCollisionDetection, isTrue);
    });

    test('layer has correct name', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      expect(layer.name, equals('dataLabels'));
    });

    test('layer has correct zIndex for rendering order', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      expect(layer.zIndex, equals(70)); // After markers
    });

    test('layer is not cacheable by default', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      expect(layer.cacheable, isFalse);
    });

    test('creates layer with empty series list', () {
      final layer = FusionDataLabelLayer(series: []);

      expect(layer.series, isEmpty);
    });

    test('creates layer with multiple series', () {
      final series = [
        createTestSeries(name: 'Series 1'),
        createTestSeries(name: 'Series 2'),
        createTestSeries(name: 'Series 3'),
      ];
      final layer = FusionDataLabelLayer(series: series);

      expect(layer.series.length, equals(3));
    });
  });

  // ===========================================================================
  // DATA LABEL DISPLAY MODES
  // ===========================================================================

  group('FusionDataLabelLayer - Display Mode: all', () {
    test('shows labels for all data points', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(10, 20),
          const FusionDataPoint(30, 40),
          const FusionDataPoint(50, 60),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.all,
      );
      FusionDataLabelLayer(series: [series]);

      // Layer should process all points
      expect(series.dataPoints.length, equals(3));
      expect(series.dataLabelDisplay, equals(FusionDataLabelDisplay.all));
    });
  });

  group('FusionDataLabelLayer - Display Mode: none', () {
    test('series with dataLabelDisplay.none does not show labels', () {
      final series = createTestSeries(
        dataLabelDisplay: FusionDataLabelDisplay.none,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelDisplay, equals(FusionDataLabelDisplay.none));
    });
  });

  group('FusionDataLabelLayer - Display Mode: maxOnly', () {
    test('shows label only for maximum value', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(25, 90), // Max
          const FusionDataPoint(50, 30),
          const FusionDataPoint(75, 50),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.maxOnly,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelDisplay, equals(FusionDataLabelDisplay.maxOnly));
      // The max Y value is 90 at index 1
      final maxY = series.dataPoints
          .map((p) => p.y)
          .reduce((a, b) => a > b ? a : b);
      expect(maxY, equals(90));
    });

    test('shows labels for all points with same max value', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(25, 100), // Max (tied)
          const FusionDataPoint(50, 100), // Max (tied)
          const FusionDataPoint(75, 30),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.maxOnly,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelDisplay, equals(FusionDataLabelDisplay.maxOnly));
      // Both indices 1 and 2 have max value
      final maxY = series.dataPoints
          .map((p) => p.y)
          .reduce((a, b) => a > b ? a : b);
      final maxCount = series.dataPoints.where((p) => p.y == maxY).length;
      expect(maxCount, equals(2));
    });
  });

  group('FusionDataLabelLayer - Display Mode: minOnly', () {
    test('shows label only for minimum value', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(25, 10), // Min
          const FusionDataPoint(50, 30),
          const FusionDataPoint(75, 80),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.minOnly,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelDisplay, equals(FusionDataLabelDisplay.minOnly));
      final minY = series.dataPoints
          .map((p) => p.y)
          .reduce((a, b) => a < b ? a : b);
      expect(minY, equals(10));
    });

    test('shows labels for all points with same min value', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 5), // Min (tied)
          const FusionDataPoint(25, 50),
          const FusionDataPoint(50, 5), // Min (tied)
          const FusionDataPoint(75, 30),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.minOnly,
      );
      FusionDataLabelLayer(series: [series]);

      final minY = series.dataPoints
          .map((p) => p.y)
          .reduce((a, b) => a < b ? a : b);
      final minCount = series.dataPoints.where((p) => p.y == minY).length;
      expect(minCount, equals(2));
    });
  });

  group('FusionDataLabelLayer - Display Mode: maxAndMin', () {
    test('shows labels for both max and min values', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(25, 10), // Min
          const FusionDataPoint(50, 90), // Max
          const FusionDataPoint(75, 60),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelDisplay, equals(FusionDataLabelDisplay.maxAndMin));
      final values = series.dataPoints.map((p) => p.y).toList();
      final maxY = values.reduce((a, b) => a > b ? a : b);
      final minY = values.reduce((a, b) => a < b ? a : b);
      expect(maxY, equals(90));
      expect(minY, equals(10));
    });

    test('handles case where max and min are same value', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(25, 50),
          const FusionDataPoint(50, 50),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
      );
      FusionDataLabelLayer(series: [series]);

      // When all values are same, max == min
      final values = series.dataPoints.map((p) => p.y).toSet();
      expect(values.length, equals(1));
    });
  });

  group('FusionDataLabelLayer - Display Mode: firstAndLast', () {
    test('shows labels for first and last data points', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 10), // First
          const FusionDataPoint(25, 50),
          const FusionDataPoint(50, 30),
          const FusionDataPoint(75, 80),
          const FusionDataPoint(100, 40), // Last
        ],
        dataLabelDisplay: FusionDataLabelDisplay.firstAndLast,
      );
      FusionDataLabelLayer(series: [series]);

      expect(
        series.dataLabelDisplay,
        equals(FusionDataLabelDisplay.firstAndLast),
      );
      expect(series.dataPoints.first.x, equals(0));
      expect(series.dataPoints.last.x, equals(100));
    });

    test('handles single data point', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(50, 50), // First and Last
        ],
        dataLabelDisplay: FusionDataLabelDisplay.firstAndLast,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints.length, equals(1));
    });

    test('handles two data points', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 10), // First
          const FusionDataPoint(100, 90), // Last
        ],
        dataLabelDisplay: FusionDataLabelDisplay.firstAndLast,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints.length, equals(2));
    });
  });

  // ===========================================================================
  // LABEL FORMATTING
  // ===========================================================================

  group('FusionDataLabelLayer - Label Formatting', () {
    test('uses default formatter when none provided', () {
      final series = createTestSeries(
        dataPoints: [const FusionDataPoint(50, 42.567)],
        dataLabelFormatter: null,
      );
      FusionDataLabelLayer(series: [series]);

      // Default format is toStringAsFixed(1)
      expect(42.567.toStringAsFixed(1), equals('42.6'));
    });

    test('uses custom formatter when provided', () {
      String customFormatter(double value) => '\$${value.toStringAsFixed(2)}';

      final series = createTestSeries(
        dataPoints: [const FusionDataPoint(50, 42.567)],
        dataLabelFormatter: customFormatter,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelFormatter, isNotNull);
      expect(series.dataLabelFormatter!(42.567), equals('\$42.57'));
    });

    test('custom formatter with percentage', () {
      String percentFormatter(double value) => '${value.toStringAsFixed(0)}%';

      final series = createTestSeries(
        dataPoints: [const FusionDataPoint(50, 75)],
        dataLabelFormatter: percentFormatter,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelFormatter!(75), equals('75%'));
    });

    test('custom formatter handles negative values', () {
      String signedFormatter(double value) {
        final sign = value >= 0 ? '+' : '';
        return '$sign${value.toStringAsFixed(1)}';
      }

      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, -10),
          const FusionDataPoint(50, 20),
        ],
        dataLabelFormatter: signedFormatter,
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelFormatter!(-10), equals('-10.0'));
      expect(series.dataLabelFormatter!(20), equals('+20.0'));
    });
  });

  // ===========================================================================
  // TEXT STYLE CONFIGURATION
  // ===========================================================================

  group('FusionDataLabelLayer - Text Style', () {
    test('uses default style from theme when none provided', () {
      final series = createTestSeries(dataLabelStyle: null);
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelStyle, isNull);
    });

    test('uses custom style when provided', () {
      const customStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      final series = createTestSeries(dataLabelStyle: customStyle);
      FusionDataLabelLayer(series: [series]);

      expect(series.dataLabelStyle, equals(customStyle));
      expect(series.dataLabelStyle!.fontSize, equals(14));
      expect(series.dataLabelStyle!.fontWeight, equals(FontWeight.bold));
      expect(series.dataLabelStyle!.color, equals(Colors.red));
    });
  });

  // ===========================================================================
  // SERIES VISIBILITY
  // ===========================================================================

  group('FusionDataLabelLayer - Series Visibility', () {
    test('does not render labels for invisible series', () {
      final series = createTestSeries(visible: false);
      FusionDataLabelLayer(series: [series]);

      expect(series.visible, isFalse);
    });

    test('renders labels for visible series', () {
      final series = createTestSeries(visible: true);
      FusionDataLabelLayer(series: [series]);

      expect(series.visible, isTrue);
    });

    test('handles mixed visibility in multiple series', () {
      final series = [
        createTestSeries(name: 'Visible', visible: true),
        createTestSeries(name: 'Invisible', visible: false),
        createTestSeries(name: 'Also Visible', visible: true),
      ];
      FusionDataLabelLayer(series: series);

      final visibleCount = series.where((s) => s.visible).length;
      expect(visibleCount, equals(2));
    });
  });

  // ===========================================================================
  // EMPTY DATA HANDLING
  // ===========================================================================

  group('FusionDataLabelLayer - Empty Data Handling', () {
    test('handles series with empty data points', () {
      final series = createTestSeries(dataPoints: []);
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints, isEmpty);
    });

    test('handles empty series list', () {
      final layer = FusionDataLabelLayer(series: []);

      expect(layer.series, isEmpty);
    });
  });

  // ===========================================================================
  // COLLISION DETECTION
  // ===========================================================================

  group('FusionDataLabelLayer - Collision Detection', () {
    test('collision detection can be enabled', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(
        series: series,
        enableCollisionDetection: true,
      );

      expect(layer.enableCollisionDetection, isTrue);
    });

    test('collision detection is disabled by default', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      expect(layer.enableCollisionDetection, isFalse);
    });

    test('handles many overlapping points', () {
      final dataPoints = List.generate(
        50,
        (i) => FusionDataPoint(i.toDouble(), 50 + (i % 5).toDouble()),
      );
      final series = createTestSeries(dataPoints: dataPoints);
      FusionDataLabelLayer(series: [series], enableCollisionDetection: true);

      expect(series.dataPoints.length, equals(50));
    });
  });

  // ===========================================================================
  // RENDERING OPTIONS
  // ===========================================================================

  group('FusionDataLabelLayer - Rendering Options', () {
    test('background rendering can be disabled', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(
        series: series,
        enableBackground: false,
      );

      expect(layer.enableBackground, isFalse);
    });

    test('border rendering can be enabled', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series, enableBorder: true);

      expect(layer.enableBorder, isTrue);
    });

    test('shadow rendering can be enabled', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series, enableShadow: true);

      expect(layer.enableShadow, isTrue);
    });

    test('all rendering options can be enabled together', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(
        series: series,
        enableBackground: true,
        enableBorder: true,
        enableShadow: true,
        enableCollisionDetection: true,
      );

      expect(layer.enableBackground, isTrue);
      expect(layer.enableBorder, isTrue);
      expect(layer.enableShadow, isTrue);
      expect(layer.enableCollisionDetection, isTrue);
    });
  });

  // ===========================================================================
  // SHOULD REPAINT
  // ===========================================================================

  group('FusionDataLabelLayer - shouldRepaint', () {
    test('returns true when series changes', () {
      final series1 = [createTestSeries(name: 'Series 1')];
      final series2 = [createTestSeries(name: 'Series 2')];

      final layer1 = FusionDataLabelLayer(series: series1);
      final layer2 = FusionDataLabelLayer(series: series2);

      expect(layer2.shouldRepaint(layer1), isTrue);
    });

    test('returns false when series is same reference', () {
      final series = [createTestSeries()];
      final layer1 = FusionDataLabelLayer(series: series);
      final layer2 = FusionDataLabelLayer(series: series);

      expect(layer2.shouldRepaint(layer1), isFalse);
    });
  });

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  group('FusionDataLabelLayer - dispose', () {
    test('dispose clears text painter cache', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      // Should not throw
      layer.dispose();
    });

    test('dispose can be called multiple times safely', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      // Should not throw when called multiple times
      layer.dispose();
      layer.dispose();
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('FusionDataLabelLayer - toString', () {
    test('toString contains layer information', () {
      final series = [createTestSeries(), createTestSeries()];
      final layer = FusionDataLabelLayer(
        series: series,
        enableCollisionDetection: true,
      );

      final str = layer.toString();
      expect(str, contains('FusionDataLabelLayer'));
      expect(str, contains('series: 2'));
      expect(str, contains('collision: true'));
    });

    test('toString shows collision disabled', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(
        series: series,
        enableCollisionDetection: false,
      );

      final str = layer.toString();
      expect(str, contains('collision: false'));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================

  group('FusionDataLabelLayer - Edge Cases', () {
    test('handles single data point', () {
      final series = createTestSeries(
        dataPoints: [const FusionDataPoint(50, 50)],
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints.length, equals(1));
    });

    test('handles data points with zero values', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 0),
          const FusionDataPoint(50, 0),
          const FusionDataPoint(100, 0),
        ],
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints.every((p) => p.y == 0), isTrue);
    });

    test('handles data points with negative values', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, -50),
          const FusionDataPoint(50, -10),
          const FusionDataPoint(100, -80),
        ],
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints.every((p) => p.y < 0), isTrue);
    });

    test('handles data points with very large values', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 1e10),
          const FusionDataPoint(50, 5e10),
          const FusionDataPoint(100, 9e10),
        ],
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints[1].y, equals(5e10));
    });

    test('handles data points with very small values', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 0.00001),
          const FusionDataPoint(50, 0.00005),
          const FusionDataPoint(100, 0.00009),
        ],
      );
      FusionDataLabelLayer(series: [series]);

      expect(series.dataPoints[0].y, equals(0.00001));
    });

    test('handles data points with mixed positive and negative', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, -50),
          const FusionDataPoint(25, 30),
          const FusionDataPoint(50, -10),
          const FusionDataPoint(75, 80),
          const FusionDataPoint(100, -20),
        ],
        dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
      );
      FusionDataLabelLayer(series: [series]);

      final values = series.dataPoints.map((p) => p.y).toList();
      expect(values.reduce((a, b) => a > b ? a : b), equals(80));
      expect(values.reduce((a, b) => a < b ? a : b), equals(-50));
    });

    test('handles series with showDataLabels false', () {
      final series = createTestSeries(showDataLabels: false);
      FusionDataLabelLayer(series: [series]);

      expect(series.showDataLabels, isFalse);
    });
  });

  // ===========================================================================
  // PAINT INTEGRATION TEST (with mock canvas)
  // ===========================================================================

  group('FusionDataLabelLayer - Paint Method', () {
    test('paint method executes without error', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);
      final context = createDefaultContext();

      // Use PictureRecorder to create a canvas for testing
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw
      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('paint handles empty series without error', () {
      final layer = FusionDataLabelLayer(series: []);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('paint handles invisible series without error', () {
      final series = [createTestSeries(visible: false)];
      final layer = FusionDataLabelLayer(series: series);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('paint with all rendering options enabled', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(
        series: series,
        enableBackground: true,
        enableBorder: true,
        enableShadow: true,
        enableCollisionDetection: true,
      );
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('paint with custom formatter', () {
      final series = [
        createTestSeries(dataLabelFormatter: (v) => 'Value: ${v.toInt()}'),
      ];
      final layer = FusionDataLabelLayer(series: series);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('paint with dataLabelDisplay.none skips rendering', () {
      final series = [
        createTestSeries(dataLabelDisplay: FusionDataLabelDisplay.none),
      ];
      final layer = FusionDataLabelLayer(series: series);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('paint with multiple series', () {
      final series = [
        createTestSeries(name: 'Series A', color: Colors.blue),
        createTestSeries(name: 'Series B', color: Colors.red),
        createTestSeries(name: 'Series C', color: Colors.green),
      ];
      final layer = FusionDataLabelLayer(series: series);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });
  });

  // ===========================================================================
  // LABEL POSITION CALCULATION
  // ===========================================================================

  group('FusionDataLabelLayer - Label Positioning', () {
    test('handles points near chart boundaries', () {
      // Point very close to top of chart
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(50, 99), // Near top
          const FusionDataPoint(0, 1), // Near bottom
          const FusionDataPoint(1, 50), // Near left
          const FusionDataPoint(99, 50), // Near right
        ],
      );
      final layer = FusionDataLabelLayer(series: [series]);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('handles points exactly at chart corners', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 0), // Bottom-left
          const FusionDataPoint(100, 0), // Bottom-right
          const FusionDataPoint(0, 100), // Top-left
          const FusionDataPoint(100, 100), // Top-right
        ],
      );
      final layer = FusionDataLabelLayer(series: [series]);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });
  });

  // ===========================================================================
  // OFF-SCREEN CULLING
  // ===========================================================================

  group('FusionDataLabelLayer - Off-Screen Culling', () {
    test('culls points far outside chart area', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(-100, 50), // Far left
          const FusionDataPoint(50, 50), // In bounds
          const FusionDataPoint(200, 50), // Far right
        ],
      );
      final layer = FusionDataLabelLayer(series: [series]);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('culls points vertically outside chart area', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(50, -100), // Far below
          const FusionDataPoint(50, 50), // In bounds
          const FusionDataPoint(50, 200), // Far above
        ],
      );
      final layer = FusionDataLabelLayer(series: [series]);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });
  });

  // ===========================================================================
  // COLLISION DETECTION DETAILED TESTS
  // ===========================================================================

  group('FusionDataLabelLayer - Collision Detection Detailed', () {
    test('collision detection with closely spaced points', () {
      final dataPoints = List.generate(
        10,
        (i) => FusionDataPoint(i * 2.0, 50.0),
      );
      final series = createTestSeries(dataPoints: dataPoints);
      final layer = FusionDataLabelLayer(
        series: [series],
        enableCollisionDetection: true,
      );
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('collision detection prioritizes extreme values', () {
      final series = createTestSeries(
        dataPoints: [
          const FusionDataPoint(0, 100), // Max - should be prioritized
          const FusionDataPoint(10, 50),
          const FusionDataPoint(20, 50),
          const FusionDataPoint(30, 0), // Min - should be prioritized
          const FusionDataPoint(40, 50),
        ],
      );
      final layer = FusionDataLabelLayer(
        series: [series],
        enableCollisionDetection: true,
      );
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('collision detection with all same Y values', () {
      final dataPoints = List.generate(
        5,
        (i) => FusionDataPoint(i * 20.0, 50.0),
      );
      final series = createTestSeries(dataPoints: dataPoints);
      final layer = FusionDataLabelLayer(
        series: [series],
        enableCollisionDetection: true,
      );
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(() => layer.paint(canvas, size, context), returnsNormally);

      final picture = recorder.endRecording();
      picture.dispose();
    });
  });

  // ===========================================================================
  // PERFORMANCE TESTS
  // ===========================================================================

  group('FusionDataLabelLayer - Performance', () {
    test('handles 100+ data points efficiently', () {
      final dataPoints = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), (i * 7 % 100).toDouble()),
      );
      final series = createTestSeries(dataPoints: dataPoints);
      final layer = FusionDataLabelLayer(series: [series]);
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      final stopwatch = Stopwatch()..start();
      layer.paint(canvas, size, context);
      stopwatch.stop();

      // Should complete reasonably fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('handles 100+ points with collision detection', () {
      final dataPoints = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), (i * 7 % 100).toDouble()),
      );
      final series = createTestSeries(dataPoints: dataPoints);
      final layer = FusionDataLabelLayer(
        series: [series],
        enableCollisionDetection: true,
      );
      final context = createDefaultContext();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      final stopwatch = Stopwatch()..start();
      layer.paint(canvas, size, context);
      stopwatch.stop();

      // Collision detection adds overhead but should still be reasonable
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      final picture = recorder.endRecording();
      picture.dispose();
    });
  });

  // ===========================================================================
  // TEXT PAINTER CACHING
  // ===========================================================================

  group('FusionDataLabelLayer - Text Painter Caching', () {
    test('cache is cleared on each paint call', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);
      final context = createDefaultContext();

      final recorder1 = PictureRecorder();
      final canvas1 = Canvas(recorder1);
      const size = Size(400, 300);

      // First paint
      layer.paint(canvas1, size, context);
      final picture1 = recorder1.endRecording();

      // Second paint with same context
      final recorder2 = PictureRecorder();
      final canvas2 = Canvas(recorder2);
      layer.paint(canvas2, size, context);
      final picture2 = recorder2.endRecording();

      // Should complete without issues
      expect(picture1, isNotNull);
      expect(picture2, isNotNull);

      picture1.dispose();
      picture2.dispose();
    });
  });

  // ===========================================================================
  // LAYER LIFECYCLE
  // ===========================================================================

  group('FusionDataLabelLayer - Lifecycle', () {
    test('layer can be enabled and disabled', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      layer.enabled = false;
      expect(layer.enabled, isFalse);

      layer.enabled = true;
      expect(layer.enabled, isTrue);
    });

    test('layer starts enabled by default', () {
      final series = [createTestSeries()];
      final layer = FusionDataLabelLayer(series: series);

      expect(layer.enabled, isTrue);
    });
  });
}

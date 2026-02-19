import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_position.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_paint_pool.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_render_context.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_shader_cache.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';
import 'package:fusion_charts_flutter/src/rendering/layers/fusion_tooltip_layer.dart';
import 'package:fusion_charts_flutter/src/series/fusion_line_series.dart';
import 'package:fusion_charts_flutter/src/series/series_with_data_points.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_light_theme.dart';

void main() {
  // ===========================================================================
  // TEST FIXTURES
  // ===========================================================================

  late FusionPaintPool defaultPaintPool;
  late FusionShaderCache defaultShaderCache;
  late FusionLightTheme defaultTheme;
  late Rect defaultChartArea;

  setUp(() {
    defaultChartArea = const Rect.fromLTWH(60, 10, 300, 200);
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
    double animationProgress = 1.0,
    double devicePixelRatio = 1.0,
  }) {
    final effectiveChartArea = chartArea ?? defaultChartArea;
    final effectiveCoordSystem =
        coordSystem ??
        FusionCoordinateSystem(
          chartArea: effectiveChartArea,
          dataXMin: 0,
          dataXMax: 100,
          dataYMin: 0,
          dataYMax: 100,
        );

    return FusionRenderContext(
      chartArea: effectiveChartArea,
      coordSystem: effectiveCoordSystem,
      theme: defaultTheme,
      paintPool: defaultPaintPool,
      shaderCache: defaultShaderCache,
      animationProgress: animationProgress,
      devicePixelRatio: devicePixelRatio,
    );
  }

  // Helper to create a basic tooltip render data
  TooltipRenderData createTooltipRenderData({
    FusionDataPoint? point,
    String seriesName = 'Series A',
    Color seriesColor = Colors.blue,
    Offset? screenPosition,
    bool wasLongPress = false,
    List<SharedTooltipPoint>? sharedPoints,
  }) {
    return TooltipRenderData(
      point: point ?? const FusionDataPoint(50, 75),
      seriesName: seriesName,
      seriesColor: seriesColor,
      screenPosition: screenPosition ?? const Offset(200, 100),
      wasLongPress: wasLongPress,
      sharedPoints: sharedPoints,
    );
  }

  // Helper to create a mock series
  List<SeriesWithDataPoints> createMockSeries() {
    return [
      FusionLineSeries(
        name: 'Series A',
        color: Colors.blue,
        dataPoints: const [
          FusionDataPoint(0, 10),
          FusionDataPoint(50, 75),
          FusionDataPoint(100, 50),
        ],
        showMarkers: true,
        markerSize: 8.0,
      ),
      FusionLineSeries(
        name: 'Series B',
        color: Colors.red,
        dataPoints: const [
          FusionDataPoint(0, 20),
          FusionDataPoint(50, 60),
          FusionDataPoint(100, 80),
        ],
      ),
    ];
  }

  // ===========================================================================
  // CONSTRUCTION AND INITIALIZATION
  // ===========================================================================

  group('FusionTooltipLayer - Construction', () {
    test('creates layer with required parameters', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(layer.tooltipData, isNotNull);
      expect(layer.tooltipBehavior, isNotNull);
      expect(layer.allSeries, isEmpty);
    });

    test('creates layer with null tooltipData', () {
      final layer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(layer.tooltipData, isNull);
    });

    test('creates layer with allSeries', () {
      final series = createMockSeries();
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(),
        allSeries: series,
      );

      expect(layer.allSeries, equals(series));
      expect(layer.allSeries.length, 2);
    });

    test('layer has correct name', () {
      final layer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(layer.name, 'tooltip');
    });

    test('layer has correct zIndex', () {
      final layer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(layer.zIndex, 1000);
    });
  });

  // ===========================================================================
  // PAINT METHOD - NULL TOOLTIP DATA
  // ===========================================================================

  group('FusionTooltipLayer - Paint with Null Data', () {
    test('paint does nothing when tooltipData is null', () {
      final layer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      // Should not throw and should complete without errors
      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // PAINT METHOD - CUSTOM BUILDER
  // ===========================================================================

  group('FusionTooltipLayer - Paint with Custom Builder', () {
    test('paint returns early when custom builder is set', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: FusionTooltipBehavior(
          builder: (context, point, seriesName, color) => const SizedBox(),
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      // Should return early and not throw
      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // PAINT METHOD - DEFAULT FLOATING TOOLTIP
  // ===========================================================================

  group('FusionTooltipLayer - Paint Default Floating Tooltip', () {
    test('paints default floating tooltip successfully', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with elevation', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          elevation: 5.0,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip without elevation', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          elevation: 0.0,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with border', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          borderWidth: 2.0,
          borderColor: Colors.red,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip without border', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          borderWidth: 0.0,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with marker', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          canShowMarker: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip without marker', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          canShowMarker: false,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with custom color', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          color: Colors.deepPurple,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with custom text style', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with custom format function', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          format: (point, name) => 'Custom: ${point.y}',
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with empty series name', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(seriesName: ''),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with point label', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 75, label: 'Point Label'),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints floating tooltip with point label and empty series name', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 75, label: 'Point Label'),
          seriesName: '',
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // PAINT METHOD - SHARED TOOLTIP
  // ===========================================================================

  group('FusionTooltipLayer - Paint Shared Tooltip', () {
    test('paints shared floating tooltip', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 40),
          seriesName: 'Series C',
          seriesColor: Colors.green,
          screenPosition: Offset(200, 150),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          shared: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints shared tooltip with markers', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          shared: true,
          canShowMarker: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints shared tooltip with custom format', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          shared: true,
          format: (point, name) => '$name: \$${point.y.toStringAsFixed(2)}',
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test(
      'falls back to default when shared is true but sharedPoints is empty',
      () {
        final layer = FusionTooltipLayer(
          tooltipData: createTooltipRenderData(sharedPoints: []),
          tooltipBehavior: const FusionTooltipBehavior(
            position: FusionTooltipPosition.floating,
            shared: true,
          ),
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final context = createDefaultContext();

        expect(
          () => layer.paint(canvas, const Size(400, 300), context),
          returnsNormally,
        );

        recorder.endRecording();
      },
    );

    test(
      'falls back to default when shared is true but sharedPoints is null',
      () {
        final layer = FusionTooltipLayer(
          tooltipData: createTooltipRenderData(sharedPoints: null),
          tooltipBehavior: const FusionTooltipBehavior(
            position: FusionTooltipPosition.floating,
            shared: true,
          ),
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final context = createDefaultContext();

        expect(
          () => layer.paint(canvas, const Size(400, 300), context),
          returnsNormally,
        );

        recorder.endRecording();
      },
    );
  });

  // ===========================================================================
  // PAINT METHOD - ANCHORED TOOLTIP (TOP)
  // ===========================================================================

  group('FusionTooltipLayer - Paint Anchored Tooltip (Top)', () {
    test('paints anchored top tooltip successfully', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored top tooltip with trackball line', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          showTrackballLine: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored top tooltip without trackball line', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          showTrackballLine: false,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored top tooltip with dashed trackball line', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          showTrackballLine: true,
          trackballLineDashPattern: [4, 4],
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored top tooltip with custom trackball color', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          showTrackballLine: true,
          trackballLineColor: Colors.orange,
          trackballLineWidth: 2.0,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored top tooltip with marker', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          canShowMarker: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored top tooltip with empty series name', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(seriesName: ''),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // PAINT METHOD - ANCHORED TOOLTIP (BOTTOM)
  // ===========================================================================

  group('FusionTooltipLayer - Paint Anchored Tooltip (Bottom)', () {
    test('paints anchored bottom tooltip successfully', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.bottom,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored bottom tooltip with trackball line', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.bottom,
          showTrackballLine: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored bottom tooltip with dashed trackball line', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.bottom,
          showTrackballLine: true,
          trackballLineDashPattern: [8, 4, 2, 4],
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // PAINT METHOD - ANCHORED SHARED TOOLTIP
  // ===========================================================================

  group('FusionTooltipLayer - Paint Anchored Shared Tooltip', () {
    test('paints anchored shared tooltip at top', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          shared: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored shared tooltip at bottom', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.bottom,
          shared: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored shared tooltip with trackball lines', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 40),
          seriesName: 'Series C',
          seriesColor: Colors.green,
          screenPosition: Offset(200, 150),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          shared: true,
          showTrackballLine: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored shared tooltip with markers', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          shared: true,
          canShowMarker: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints anchored shared tooltip with custom format', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          shared: true,
          format: (point, name) => '\$$name: ${point.y}',
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test(
      'anchored shared tooltip falls back when shared is true but sharedPoints is empty',
      () {
        final layer = FusionTooltipLayer(
          tooltipData: createTooltipRenderData(sharedPoints: []),
          tooltipBehavior: const FusionTooltipBehavior(
            position: FusionTooltipPosition.top,
            shared: true,
          ),
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final context = createDefaultContext();

        expect(
          () => layer.paint(canvas, const Size(400, 300), context),
          returnsNormally,
        );

        recorder.endRecording();
      },
    );
  });

  // ===========================================================================
  // POSITION CALCULATION - EDGE CASES
  // ===========================================================================

  group('FusionTooltipLayer - Position Calculation Edge Cases', () {
    test('handles tooltip at left edge of chart', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(60, 100), // At left edge
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles tooltip at right edge of chart', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(360, 100), // At right edge
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles tooltip at top edge of chart', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(200, 10), // At top edge
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles tooltip at bottom edge of chart', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(200, 210), // At bottom edge
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles tooltip in corner of chart', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(60, 10), // Top-left corner
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles very small chart area', () {
      const smallChartArea = Rect.fromLTWH(10, 10, 50, 50);
      final coordSystem = FusionCoordinateSystem(
        chartArea: smallChartArea,
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(35, 35),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext(
        chartArea: smallChartArea,
        coordSystem: coordSystem,
      );

      expect(
        () => layer.paint(canvas, const Size(100, 100), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles anchored tooltip with narrow chart area', () {
      const narrowChartArea = Rect.fromLTWH(10, 10, 30, 200);
      final coordSystem = FusionCoordinateSystem(
        chartArea: narrowChartArea,
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(25, 100),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext(
        chartArea: narrowChartArea,
        coordSystem: coordSystem,
      );

      expect(
        () => layer.paint(canvas, const Size(100, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // ARROW POSITIONING
  // ===========================================================================

  group('FusionTooltipLayer - Arrow Positioning', () {
    test('paints arrow when point is above tooltip', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(200, 50), // Near top
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints arrow when point is below tooltip', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(200, 180), // Near bottom
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints arrow when point is to the left of tooltip', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(80, 100),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints arrow when point is to the right of tooltip', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(340, 100),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints corner arrow when point is diagonally positioned', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(350, 180), // Bottom right area
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // DPI SCALING
  // ===========================================================================

  group('FusionTooltipLayer - DPI Scaling', () {
    test('handles high DPI (2x)', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext(devicePixelRatio: 2.0);

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles very high DPI (3x)', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext(devicePixelRatio: 3.0);

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles low DPI (0.75x)', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext(devicePixelRatio: 0.75);

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // MARKER RADIUS CALCULATION
  // ===========================================================================

  group('FusionTooltipLayer - Marker Radius Calculation', () {
    test('gets marker radius from series when showMarkers is true', () {
      final series = createMockSeries();

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(seriesName: 'Series A'),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
        allSeries: series,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('uses default marker radius when series not found', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(seriesName: 'Unknown Series'),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
        allSeries: createMockSeries(),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles animation progress in marker radius', () {
      final series = createMockSeries();

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(seriesName: 'Series A'),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
        allSeries: series,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext(animationProgress: 0.5);

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // SHOULD REPAINT
  // ===========================================================================

  group('FusionTooltipLayer - shouldRepaint', () {
    test('returns true when tooltipData changes', () {
      final oldLayer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 75),
        ),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      final newLayer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(60, 85),
        ),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(newLayer.shouldRepaint(oldLayer), isTrue);
    });

    test('returns true when tooltipData becomes null', () {
      final oldLayer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      final newLayer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(newLayer.shouldRepaint(oldLayer), isTrue);
    });

    test('returns true when tooltipData becomes non-null', () {
      final oldLayer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      final newLayer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(newLayer.shouldRepaint(oldLayer), isTrue);
    });

    test('returns false when tooltipData is same reference', () {
      final tooltipData = createTooltipRenderData();

      final oldLayer = FusionTooltipLayer(
        tooltipData: tooltipData,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      final newLayer = FusionTooltipLayer(
        tooltipData: tooltipData,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(newLayer.shouldRepaint(oldLayer), isFalse);
    });

    test('returns false when both tooltipData are null', () {
      final oldLayer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      final newLayer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(newLayer.shouldRepaint(oldLayer), isFalse);
    });
  });

  // ===========================================================================
  // TRACKBALL LINE - MINIMUM DISTANCE
  // ===========================================================================

  group('FusionTooltipLayer - Trackball Line Minimum Distance', () {
    test('does not draw trackball line when point is too close to tooltip', () {
      // Position the point very close to where tooltip would be
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          screenPosition: const Offset(200, 20), // Very close to top
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          showTrackballLine: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // DATA VALUE FORMATTING
  // ===========================================================================

  group('FusionTooltipLayer - Data Value Formatting', () {
    test('formats with default decimal places', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 75.12345),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          decimalPlaces: 2,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('formats with custom decimal places', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 75.12345),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          decimalPlaces: 4,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles large numbers', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 1234567890.123),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles negative numbers', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, -123.456),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles zero value', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 0),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles very small numbers', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          point: const FusionDataPoint(50, 0.00000123),
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          decimalPlaces: 8,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // COLOR CONTRAST
  // ===========================================================================

  group('FusionTooltipLayer - Color Contrast', () {
    test('handles light background color', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          color: Colors.white,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles dark background color', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          color: Colors.black,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles transparent background color', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          color: Colors.blue.withValues(alpha: 0.5),
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // OPACITY
  // ===========================================================================

  group('FusionTooltipLayer - Opacity', () {
    test('handles full opacity', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          opacity: 1.0,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles partial opacity', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          opacity: 0.5,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles very low opacity', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          opacity: 0.1,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // SHADOW CONFIGURATION
  // ===========================================================================

  group('FusionTooltipLayer - Shadow Configuration', () {
    test('handles custom shadow color', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          elevation: 4.0,
          shadowColor: Colors.red,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles high elevation', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          elevation: 16.0,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // MULTIPLE SHARED POINTS
  // ===========================================================================

  group('FusionTooltipLayer - Multiple Shared Points', () {
    test('handles many shared points', () {
      final sharedPoints = List.generate(
        10,
        (index) => SharedTooltipPoint(
          point: FusionDataPoint(50, 10.0 + index * 10),
          seriesName: 'Series ${String.fromCharCode(65 + index)}',
          seriesColor: Colors.primaries[index % Colors.primaries.length],
          screenPosition: Offset(200, 50.0 + index * 15),
        ),
      );

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          shared: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles single shared point', () {
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(50, 60),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(200, 120),
        ),
      ];

      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(sharedPoints: sharedPoints),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          shared: true,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // SERIES NAME VARIATIONS
  // ===========================================================================

  group('FusionTooltipLayer - Series Name Variations', () {
    test('handles very long series name', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          seriesName:
              'This is a very long series name that might cause text overflow issues',
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles special characters in series name', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(seriesName: 'Series @#\$%^&*()'),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles unicode characters in series name', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(
          seriesName: 'Series with emoji \u{1F600}',
        ),
        tooltipBehavior: const FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final context = createDefaultContext();

      expect(
        () => layer.paint(canvas, const Size(400, 300), context),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  // ===========================================================================
  // LAYER PROPERTIES
  // ===========================================================================

  group('FusionTooltipLayer - Layer Properties', () {
    test('layer is enabled by default', () {
      final layer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(layer.enabled, isTrue);
    });

    test('layer can be disabled', () {
      final layer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      layer.enabled = false;
      expect(layer.enabled, isFalse);
    });

    test('toString contains layer info', () {
      final layer = FusionTooltipLayer(
        tooltipData: null,
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      final str = layer.toString();
      expect(str, contains('tooltip'));
      expect(str, contains('1000'));
    });
  });

  // ===========================================================================
  // CACHE INVALIDATION
  // ===========================================================================

  group('FusionTooltipLayer - Cache', () {
    test('invalidateCache does not throw', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(layer.invalidateCache, returnsNormally);
    });

    test('dispose does not throw', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(layer.dispose, returnsNormally);
    });

    test('dispose can be called multiple times', () {
      final layer = FusionTooltipLayer(
        tooltipData: createTooltipRenderData(),
        tooltipBehavior: const FusionTooltipBehavior(),
      );

      expect(() {
        layer.dispose();
        layer.dispose();
      }, returnsNormally);
    });
  });
}

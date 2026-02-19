import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_paint_pool.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_render_context.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_render_pipeline.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_shader_cache.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';
import 'package:fusion_charts_flutter/src/rendering/layers/fusion_render_layer.dart';
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
  late FusionRenderContext defaultContext;

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
    defaultContext = FusionRenderContext(
      chartArea: defaultChartArea,
      coordSystem: defaultCoordSystem,
      theme: defaultTheme,
      paintPool: defaultPaintPool,
      shaderCache: defaultShaderCache,
    );
  });

  tearDown(() {
    defaultPaintPool.clear();
    defaultShaderCache.clear();
  });

  // ===========================================================================
  // MOCK RENDER LAYER
  // ===========================================================================

  /// A simple mock render layer for testing the pipeline.
  MockRenderLayer createMockLayer({
    String name = 'mock',
    int zIndex = 0,
    bool enabled = true,
    Rect? clipRect,
    Matrix4? transform,
    bool cacheable = false,
    bool Function(FusionRenderLayer)? shouldRepaintFn,
  }) {
    return MockRenderLayer(
      name: name,
      zIndex: zIndex,
      enabled: enabled,
      clipRect: clipRect,
      transform: transform,
      cacheable: cacheable,
      shouldRepaintFn: shouldRepaintFn,
    );
  }

  // ===========================================================================
  // FUSIONRENDERPIPELINE - CONSTRUCTION
  // ===========================================================================

  group('FusionRenderPipeline - Construction', () {
    test('creates pipeline with empty layers list', () {
      final pipeline = FusionRenderPipeline(layers: []);

      expect(pipeline.layers, isEmpty);
      expect(pipeline.enableProfiling, isFalse);
      expect(pipeline.lastFrameStats, isNull);
    });

    test('creates pipeline with layers', () {
      final layer1 = createMockLayer(name: 'layer1');
      final layer2 = createMockLayer(name: 'layer2');
      final pipeline = FusionRenderPipeline(layers: [layer1, layer2]);

      expect(pipeline.layers.length, 2);
      expect(pipeline.layers[0].name, 'layer1');
      expect(pipeline.layers[1].name, 'layer2');
    });

    test('creates pipeline with profiling enabled', () {
      final pipeline = FusionRenderPipeline(layers: [], enableProfiling: true);

      expect(pipeline.enableProfiling, isTrue);
    });

    test('creates pipeline with profiling disabled by default', () {
      final pipeline = FusionRenderPipeline(layers: []);

      expect(pipeline.enableProfiling, isFalse);
    });

    test('layers list is mutable', () {
      final pipeline = FusionRenderPipeline(layers: []);

      pipeline.layers.add(createMockLayer(name: 'added'));

      expect(pipeline.layers.length, 1);
    });
  });

  // ===========================================================================
  // FUSIONRENDERPIPELINE - LAYER MANAGEMENT
  // ===========================================================================

  group('FusionRenderPipeline - Layer Management', () {
    test('addLayer adds layer to the end', () {
      final pipeline = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer1')],
      );

      pipeline.addLayer(createMockLayer(name: 'layer2'));

      expect(pipeline.layers.length, 2);
      expect(pipeline.layers.last.name, 'layer2');
    });

    test('addLayer adds to empty pipeline', () {
      final pipeline = FusionRenderPipeline(layers: []);

      pipeline.addLayer(createMockLayer(name: 'first'));

      expect(pipeline.layers.length, 1);
      expect(pipeline.layers.first.name, 'first');
    });

    test('removeLayer removes layer by name', () {
      final pipeline = FusionRenderPipeline(
        layers: [
          createMockLayer(name: 'layer1'),
          createMockLayer(name: 'layer2'),
          createMockLayer(name: 'layer3'),
        ],
      );

      pipeline.removeLayer('layer2');

      expect(pipeline.layers.length, 2);
      expect(pipeline.layers.any((l) => l.name == 'layer2'), isFalse);
    });

    test('removeLayer does nothing if layer not found', () {
      final pipeline = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer1')],
      );

      pipeline.removeLayer('nonexistent');

      expect(pipeline.layers.length, 1);
    });

    test('removeLayer removes all layers with same name', () {
      final pipeline = FusionRenderPipeline(
        layers: [
          createMockLayer(name: 'duplicate'),
          createMockLayer(name: 'other'),
          createMockLayer(name: 'duplicate'),
        ],
      );

      pipeline.removeLayer('duplicate');

      expect(pipeline.layers.length, 1);
      expect(pipeline.layers.first.name, 'other');
    });

    test('getLayer returns layer by name', () {
      final layer = createMockLayer(name: 'target');
      final pipeline = FusionRenderPipeline(
        layers: [
          createMockLayer(name: 'other'),
          layer,
        ],
      );

      final result = pipeline.getLayer('target');

      expect(result, same(layer));
    });

    test('getLayer returns null if layer not found', () {
      final pipeline = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer1')],
      );

      final result = pipeline.getLayer('nonexistent');

      expect(result, isNull);
    });

    test('getLayer returns first layer if multiple have same name', () {
      final first = createMockLayer(name: 'duplicate', zIndex: 1);
      final second = createMockLayer(name: 'duplicate', zIndex: 2);
      final pipeline = FusionRenderPipeline(layers: [first, second]);

      final result = pipeline.getLayer('duplicate');

      expect(result, same(first));
    });

    test('setLayerEnabled enables layer by name', () {
      final layer = createMockLayer(name: 'target', enabled: false);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      pipeline.setLayerEnabled('target', true);

      expect(layer.enabled, isTrue);
    });

    test('setLayerEnabled disables layer by name', () {
      final layer = createMockLayer(name: 'target', enabled: true);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      pipeline.setLayerEnabled('target', false);

      expect(layer.enabled, isFalse);
    });

    test('setLayerEnabled does nothing if layer not found', () {
      final pipeline = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer1')],
      );

      // Should not throw
      pipeline.setLayerEnabled('nonexistent', true);

      expect(pipeline.layers.length, 1);
    });
  });

  // ===========================================================================
  // FUSIONRENDERPIPELINE - RENDER METHOD
  // ===========================================================================

  group('FusionRenderPipeline - Render Method', () {
    test('render calls paint on enabled layers', () {
      final layer = createMockLayer(name: 'layer', enabled: true);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('render skips disabled layers', () {
      final enabledLayer = createMockLayer(name: 'enabled', enabled: true);
      final disabledLayer = createMockLayer(name: 'disabled', enabled: false);
      final pipeline = FusionRenderPipeline(
        layers: [enabledLayer, disabledLayer],
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(enabledLayer.paintCallCount, 1);
      expect(disabledLayer.paintCallCount, 0);

      recorder.endRecording().dispose();
    });

    test('render respects layer order', () {
      final callOrder = <String>[];
      final layer1 = createMockLayer(name: 'layer1')
        ..onPaint = () => callOrder.add('layer1');
      final layer2 = createMockLayer(name: 'layer2')
        ..onPaint = () => callOrder.add('layer2');
      final layer3 = createMockLayer(name: 'layer3')
        ..onPaint = () => callOrder.add('layer3');
      final pipeline = FusionRenderPipeline(layers: [layer1, layer2, layer3]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(callOrder, ['layer1', 'layer2', 'layer3']);

      recorder.endRecording().dispose();
    });

    test('render passes correct canvas and size to layers', () {
      Canvas? receivedCanvas;
      Size? receivedSize;
      final layer = createMockLayer(name: 'layer')
        ..onPaintWithParams = (canvas, size, context) {
          receivedCanvas = canvas;
          receivedSize = size;
        };
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(receivedCanvas, isNotNull);
      expect(receivedSize, size);

      recorder.endRecording().dispose();
    });

    test('render passes correct context to layers', () {
      FusionRenderContext? receivedContext;
      final layer = createMockLayer(name: 'layer')
        ..onPaintWithParams = (canvas, size, context) {
          receivedContext = context;
        };
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(receivedContext, same(defaultContext));

      recorder.endRecording().dispose();
    });

    test('render handles empty layers list', () {
      final pipeline = FusionRenderPipeline(layers: []);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw
      pipeline.render(canvas, size, defaultContext);

      recorder.endRecording().dispose();
    });

    test('render continues after layer paint even if layer throws', () {
      final layer1 = createMockLayer(name: 'layer1');
      final throwingLayer = createMockLayer(name: 'throwing')
        ..onPaint = () => throw Exception('Test error');
      final layer3 = createMockLayer(name: 'layer3');
      final pipeline = FusionRenderPipeline(
        layers: [layer1, throwingLayer, layer3],
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      expect(
        () => pipeline.render(canvas, size, defaultContext),
        throwsException,
      );

      recorder.endRecording().dispose();
    });
  });

  // ===========================================================================
  // FUSIONRENDERPIPELINE - LAYER CLIPPING AND TRANSFORM
  // ===========================================================================

  group('FusionRenderPipeline - Layer Clipping and Transform', () {
    test('render applies clipRect to layer', () {
      const clipRect = Rect.fromLTWH(10, 10, 100, 100);
      final layer = createMockLayer(name: 'clipped', clipRect: clipRect);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw when applying clip
      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('render applies transform to layer', () {
      final transform = Matrix4.identity()..setTranslationRaw(50.0, 50.0, 0.0);
      final layer = createMockLayer(name: 'transformed', transform: transform);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw when applying transform
      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('render applies both clipRect and transform', () {
      const clipRect = Rect.fromLTWH(10, 10, 100, 100);
      final transform = Matrix4.diagonal3Values(2.0, 2.0, 1.0);
      final layer = createMockLayer(
        name: 'both',
        clipRect: clipRect,
        transform: transform,
      );
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw
      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('render handles layer with null clipRect', () {
      final layer = createMockLayer(name: 'no-clip', clipRect: null);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('render handles layer with null transform', () {
      final layer = createMockLayer(name: 'no-transform', transform: null);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });
  });

  // ===========================================================================
  // FUSIONRENDERPIPELINE - PROFILING
  // ===========================================================================

  group('FusionRenderPipeline - Profiling', () {
    test('records lastFrameStats when profiling enabled', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(
        layers: [layer],
        enableProfiling: true,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(pipeline.lastFrameStats, isNotNull);

      recorder.endRecording().dispose();
    });

    test('lastFrameStats contains totalTime', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(
        layers: [layer],
        enableProfiling: true,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(pipeline.lastFrameStats!.totalTime, greaterThanOrEqualTo(0));

      recorder.endRecording().dispose();
    });

    test('lastFrameStats contains layerCount', () {
      final pipeline = FusionRenderPipeline(
        layers: [
          createMockLayer(name: 'layer1'),
          createMockLayer(name: 'layer2'),
        ],
        enableProfiling: true,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(pipeline.lastFrameStats!.layerCount, 2);

      recorder.endRecording().dispose();
    });

    test('lastFrameStats contains layerTimes', () {
      final pipeline = FusionRenderPipeline(
        layers: [
          createMockLayer(name: 'layer1'),
          createMockLayer(name: 'layer2'),
        ],
        enableProfiling: true,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(pipeline.lastFrameStats!.layerTimes, isNotEmpty);
      expect(pipeline.lastFrameStats!.layerTimes.containsKey('layer1'), isTrue);
      expect(pipeline.lastFrameStats!.layerTimes.containsKey('layer2'), isTrue);

      recorder.endRecording().dispose();
    });

    test('does not record stats when profiling disabled', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(
        layers: [layer],
        enableProfiling: false,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      expect(pipeline.lastFrameStats, isNull);

      recorder.endRecording().dispose();
    });

    test('getPerformanceReport returns message when no stats', () {
      final pipeline = FusionRenderPipeline(layers: []);

      final report = pipeline.getPerformanceReport();

      expect(report, 'No statistics available');
    });

    test('getPerformanceReport returns formatted report', () {
      final pipeline = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer1')],
        enableProfiling: true,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      final report = pipeline.getPerformanceReport();

      expect(report, contains('=== Render Performance ==='));
      expect(report, contains('Total:'));
      expect(report, contains('Layers:'));
      expect(report, contains('Layer Breakdown:'));
      expect(report, contains('layer1'));

      recorder.endRecording().dispose();
    });

    test('isRunningAt60FPS returns true when no stats', () {
      final pipeline = FusionRenderPipeline(layers: []);

      expect(pipeline.isRunningAt60FPS, isTrue);
    });

    test('isRunningAt60FPS returns true for fast render', () {
      final pipeline = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer')],
        enableProfiling: true,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      // A simple layer should render in less than 16.67ms
      expect(pipeline.isRunningAt60FPS, isTrue);

      recorder.endRecording().dispose();
    });
  });

  // ===========================================================================
  // FUSIONRENDERPIPELINE - OPTIMIZATION
  // ===========================================================================

  group('FusionRenderPipeline - Optimization', () {
    test('shouldRepaint returns true when layer counts differ', () {
      final pipeline1 = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer1')],
      );
      final pipeline2 = FusionRenderPipeline(
        layers: [
          createMockLayer(name: 'layer1'),
          createMockLayer(name: 'layer2'),
        ],
      );

      expect(pipeline2.shouldRepaint(pipeline1), isTrue);
    });

    test('shouldRepaint returns false when layers match', () {
      final layer1 = createMockLayer(
        name: 'layer1',
        shouldRepaintFn: (_) => false,
      );
      final layer2 = createMockLayer(
        name: 'layer1',
        shouldRepaintFn: (_) => false,
      );
      final pipeline1 = FusionRenderPipeline(layers: [layer1]);
      final pipeline2 = FusionRenderPipeline(layers: [layer2]);

      expect(pipeline2.shouldRepaint(pipeline1), isFalse);
    });

    test('shouldRepaint returns true when any layer needs repaint', () {
      final layer1 = createMockLayer(
        name: 'layer1',
        shouldRepaintFn: (_) => false,
      );
      final layer2 = createMockLayer(
        name: 'layer2',
        shouldRepaintFn: (_) => true,
      );
      final oldPipeline = FusionRenderPipeline(
        layers: [
          createMockLayer(name: 'layer1', shouldRepaintFn: (_) => false),
          createMockLayer(name: 'layer2', shouldRepaintFn: (_) => false),
        ],
      );
      final newPipeline = FusionRenderPipeline(layers: [layer1, layer2]);

      expect(newPipeline.shouldRepaint(oldPipeline), isTrue);
    });

    test('invalidateCache calls invalidateCache on all layers', () {
      final layer1 = createMockLayer(name: 'layer1');
      final layer2 = createMockLayer(name: 'layer2');
      final pipeline = FusionRenderPipeline(layers: [layer1, layer2]);

      pipeline.invalidateCache();

      expect(layer1.invalidateCacheCallCount, 1);
      expect(layer2.invalidateCacheCallCount, 1);
    });

    test('invalidateCache handles empty layers', () {
      final pipeline = FusionRenderPipeline(layers: []);

      // Should not throw
      pipeline.invalidateCache();
    });

    test('invalidateLayerCache invalidates specific layer', () {
      final layer1 = createMockLayer(name: 'layer1');
      final layer2 = createMockLayer(name: 'layer2');
      final pipeline = FusionRenderPipeline(layers: [layer1, layer2]);

      pipeline.invalidateLayerCache('layer2');

      expect(layer1.invalidateCacheCallCount, 0);
      expect(layer2.invalidateCacheCallCount, 1);
    });

    test('invalidateLayerCache handles nonexistent layer', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(layers: [layer]);

      // Should not throw
      pipeline.invalidateLayerCache('nonexistent');

      expect(layer.invalidateCacheCallCount, 0);
    });
  });

  // ===========================================================================
  // FUSIONRENDERPIPELINE - LIFECYCLE
  // ===========================================================================

  group('FusionRenderPipeline - Lifecycle', () {
    test('dispose calls dispose on all layers', () {
      final layer1 = createMockLayer(name: 'layer1');
      final layer2 = createMockLayer(name: 'layer2');
      final pipeline = FusionRenderPipeline(layers: [layer1, layer2]);

      pipeline.dispose();

      expect(layer1.disposeCallCount, 1);
      expect(layer2.disposeCallCount, 1);
    });

    test('dispose handles empty layers', () {
      final pipeline = FusionRenderPipeline(layers: []);

      // Should not throw
      pipeline.dispose();
    });

    test('dispose can be called multiple times', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(layers: [layer]);

      pipeline.dispose();
      pipeline.dispose();

      expect(layer.disposeCallCount, 2);
    });
  });

  // ===========================================================================
  // RENDERSTATISTICS
  // ===========================================================================

  group('RenderStatistics - Construction', () {
    test('creates with all required fields', () {
      final stats = RenderStatistics(
        totalTime: 1000,
        layerTimes: {'layer1': 500, 'layer2': 500},
        layerCount: 2,
      );

      expect(stats.totalTime, 1000);
      expect(stats.layerTimes.length, 2);
      expect(stats.layerCount, 2);
    });

    test('creates with empty layerTimes', () {
      final stats = RenderStatistics(
        totalTime: 0,
        layerTimes: {},
        layerCount: 0,
      );

      expect(stats.layerTimes, isEmpty);
    });
  });

  group('RenderStatistics - Computed Properties', () {
    test('fps calculates correctly', () {
      final stats = RenderStatistics(
        totalTime: 16667, // ~60 FPS
        layerTimes: {},
        layerCount: 0,
      );

      expect(stats.fps, closeTo(60.0, 1.0));
    });

    test('fps for 1 microsecond', () {
      final stats = RenderStatistics(
        totalTime: 1,
        layerTimes: {},
        layerCount: 0,
      );

      expect(stats.fps, 1000000.0);
    });

    test('totalTimeMs calculates correctly', () {
      final stats = RenderStatistics(
        totalTime: 16667,
        layerTimes: {},
        layerCount: 0,
      );

      expect(stats.totalTimeMs, closeTo(16.667, 0.001));
    });

    test('totalTimeMs for 0 microseconds', () {
      final stats = RenderStatistics(
        totalTime: 0,
        layerTimes: {},
        layerCount: 0,
      );

      expect(stats.totalTimeMs, 0.0);
    });
  });

  group('RenderStatistics - toString', () {
    test('toString contains RenderStatistics', () {
      final stats = RenderStatistics(
        totalTime: 1000,
        layerTimes: {},
        layerCount: 2,
      );

      expect(stats.toString(), contains('RenderStatistics'));
    });

    test('toString contains timing and FPS info', () {
      final stats = RenderStatistics(
        totalTime: 16667,
        layerTimes: {},
        layerCount: 3,
      );

      final str = stats.toString();
      expect(str, contains('ms'));
      expect(str, contains('FPS'));
      expect(str, contains('3 layers'));
    });
  });

  // ===========================================================================
  // FUSIONRENDERPIPELINEBUILDER
  // ===========================================================================

  group('FusionRenderPipelineBuilder - Construction', () {
    test('build creates pipeline with added layers', () {
      final layer1 = createMockLayer(name: 'layer1');
      final layer2 = createMockLayer(name: 'layer2');

      final pipeline = FusionRenderPipelineBuilder()
          .addLayer(layer1)
          .addLayer(layer2)
          .build();

      expect(pipeline.layers.length, 2);
      expect(pipeline.layers[0], same(layer1));
      expect(pipeline.layers[1], same(layer2));
    });

    test('build creates pipeline with profiling disabled by default', () {
      final pipeline = FusionRenderPipelineBuilder().build();

      expect(pipeline.enableProfiling, isFalse);
    });

    test('build creates pipeline with profiling enabled', () {
      final pipeline = FusionRenderPipelineBuilder()
          .withProfiling(true)
          .build();

      expect(pipeline.enableProfiling, isTrue);
    });

    test('build creates pipeline with profiling explicitly disabled', () {
      final pipeline = FusionRenderPipelineBuilder()
          .withProfiling(false)
          .build();

      expect(pipeline.enableProfiling, isFalse);
    });

    test('addLayer returns self for chaining', () {
      final builder = FusionRenderPipelineBuilder();
      final layer = createMockLayer(name: 'layer');

      expect(builder.addLayer(layer), same(builder));
    });

    test('withProfiling returns self for chaining', () {
      final builder = FusionRenderPipelineBuilder();

      expect(builder.withProfiling(true), same(builder));
    });

    test('build creates empty pipeline when no layers added', () {
      final pipeline = FusionRenderPipelineBuilder().build();

      expect(pipeline.layers, isEmpty);
    });

    test('full builder chain creates correct pipeline', () {
      final layer1 = createMockLayer(name: 'background', zIndex: 0);
      final layer2 = createMockLayer(name: 'grid', zIndex: 10);
      final layer3 = createMockLayer(name: 'series', zIndex: 20);

      final pipeline = FusionRenderPipelineBuilder()
          .addLayer(layer1)
          .addLayer(layer2)
          .addLayer(layer3)
          .withProfiling(true)
          .build();

      expect(pipeline.layers.length, 3);
      expect(pipeline.enableProfiling, isTrue);
      expect(pipeline.layers[0].name, 'background');
      expect(pipeline.layers[1].name, 'grid');
      expect(pipeline.layers[2].name, 'series');
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================

  group('FusionRenderPipeline - Edge Cases', () {
    test('handles many layers', () {
      final layers = List.generate(
        100,
        (i) => createMockLayer(name: 'layer$i'),
      );
      final pipeline = FusionRenderPipeline(layers: layers);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      for (final layer in layers) {
        expect(layer.paintCallCount, 1);
      }

      recorder.endRecording().dispose();
    });

    test('handles very small canvas size', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(1, 1);

      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('handles zero canvas size', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size.zero;

      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('handles very large canvas size', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(10000, 10000);

      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 1);

      recorder.endRecording().dispose();
    });

    test('multiple renders update layer paint count', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);
      pipeline.render(canvas, size, defaultContext);
      pipeline.render(canvas, size, defaultContext);

      expect(layer.paintCallCount, 3);

      recorder.endRecording().dispose();
    });

    test('profiling stats update on each render', () {
      final pipeline = FusionRenderPipeline(
        layers: [createMockLayer(name: 'layer')],
        enableProfiling: true,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);
      final firstStats = pipeline.lastFrameStats;

      pipeline.render(canvas, size, defaultContext);
      final secondStats = pipeline.lastFrameStats;

      // Stats object should be replaced (not the same instance)
      expect(identical(firstStats, secondStats), isFalse);

      recorder.endRecording().dispose();
    });

    test('render with all layers disabled', () {
      final layers = [
        createMockLayer(name: 'layer1', enabled: false),
        createMockLayer(name: 'layer2', enabled: false),
      ];
      final pipeline = FusionRenderPipeline(layers: layers);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      pipeline.render(canvas, size, defaultContext);

      for (final layer in layers) {
        expect(layer.paintCallCount, 0);
      }

      recorder.endRecording().dispose();
    });

    test('addLayer followed by removeLayer', () {
      final pipeline = FusionRenderPipeline(layers: []);
      final layer = createMockLayer(name: 'temp');

      pipeline.addLayer(layer);
      expect(pipeline.layers.length, 1);

      pipeline.removeLayer('temp');
      expect(pipeline.layers, isEmpty);
    });

    test('setLayerEnabled toggle back and forth', () {
      final layer = createMockLayer(name: 'layer', enabled: true);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      pipeline.setLayerEnabled('layer', false);
      expect(layer.enabled, isFalse);

      pipeline.setLayerEnabled('layer', true);
      expect(layer.enabled, isTrue);

      pipeline.setLayerEnabled('layer', false);
      expect(layer.enabled, isFalse);
    });

    test('getLayer after removeLayer returns null', () {
      final layer = createMockLayer(name: 'layer');
      final pipeline = FusionRenderPipeline(layers: [layer]);

      expect(pipeline.getLayer('layer'), same(layer));

      pipeline.removeLayer('layer');

      expect(pipeline.getLayer('layer'), isNull);
    });
  });

  // ===========================================================================
  // INTEGRATION WITH BUILT-IN LAYERS
  // ===========================================================================

  group('FusionRenderPipeline - Integration with Built-in Layers', () {
    test('renders FusionBackgroundLayer', () {
      final layer = FusionBackgroundLayer(color: Colors.white);
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw
      pipeline.render(canvas, size, defaultContext);

      recorder.endRecording().dispose();
    });

    test('renders FusionBackgroundLayer with gradient', () {
      final layer = FusionBackgroundLayer(
        gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
      );
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw
      pipeline.render(canvas, size, defaultContext);

      recorder.endRecording().dispose();
    });

    test('renders FusionBorderLayer', () {
      final layer = FusionBorderLayer();
      final pipeline = FusionRenderPipeline(layers: [layer]);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw
      pipeline.render(canvas, size, defaultContext);

      recorder.endRecording().dispose();
    });

    test('renders multiple built-in layers in order', () {
      final backgroundLayer = FusionBackgroundLayer(color: Colors.white);
      final borderLayer = FusionBorderLayer();
      final pipeline = FusionRenderPipeline(
        layers: [backgroundLayer, borderLayer],
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 300);

      // Should not throw and render both layers
      pipeline.render(canvas, size, defaultContext);

      recorder.endRecording().dispose();
    });

    test('dispose cleans up built-in layers', () {
      final backgroundLayer = FusionBackgroundLayer(color: Colors.white);
      final borderLayer = FusionBorderLayer();
      final pipeline = FusionRenderPipeline(
        layers: [backgroundLayer, borderLayer],
      );

      // Should not throw
      pipeline.dispose();
    });

    test('invalidateCache works with built-in layers', () {
      final backgroundLayer = FusionBackgroundLayer(color: Colors.white);
      final pipeline = FusionRenderPipeline(layers: [backgroundLayer]);

      // Should not throw
      pipeline.invalidateCache();
    });

    test('shouldRepaint works with FusionBackgroundLayer', () {
      final layer1 = FusionBackgroundLayer(color: Colors.white);
      final layer2 = FusionBackgroundLayer(color: Colors.black);
      final pipeline1 = FusionRenderPipeline(layers: [layer1]);
      final pipeline2 = FusionRenderPipeline(layers: [layer2]);

      // Different colors should trigger repaint
      expect(pipeline2.shouldRepaint(pipeline1), isTrue);
    });

    test('shouldRepaint returns false for identical FusionBackgroundLayer', () {
      final layer1 = FusionBackgroundLayer(color: Colors.white);
      final layer2 = FusionBackgroundLayer(color: Colors.white);
      final pipeline1 = FusionRenderPipeline(layers: [layer1]);
      final pipeline2 = FusionRenderPipeline(layers: [layer2]);

      expect(pipeline2.shouldRepaint(pipeline1), isFalse);
    });
  });
}

// =============================================================================
// MOCK RENDER LAYER
// =============================================================================

/// A mock render layer for testing purposes.
class MockRenderLayer extends FusionRenderLayer {
  MockRenderLayer({
    required super.name,
    super.zIndex = 0,
    super.enabled = true,
    super.clipRect,
    super.transform,
    super.cacheable = false,
    this.shouldRepaintFn,
  });

  int paintCallCount = 0;
  int invalidateCacheCallCount = 0;
  int disposeCallCount = 0;

  bool Function(FusionRenderLayer)? shouldRepaintFn;
  void Function()? onPaint;
  void Function(Canvas, Size, FusionRenderContext)? onPaintWithParams;

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    paintCallCount++;
    onPaint?.call();
    onPaintWithParams?.call(canvas, size, context);
  }

  @override
  bool shouldRepaint(covariant FusionRenderLayer oldLayer) {
    return shouldRepaintFn?.call(oldLayer) ?? false;
  }

  @override
  void invalidateCache() {
    super.invalidateCache();
    invalidateCacheCallCount++;
  }

  @override
  void dispose() {
    super.dispose();
    disposeCallCount++;
  }
}

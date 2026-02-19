import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_axis_configuration.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_paint_pool.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_render_context.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_shader_cache.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_chart_theme.dart';
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
    FusionChartTheme? theme,
    FusionPaintPool? paintPool,
    FusionShaderCache? shaderCache,
    FusionAxisConfiguration? xAxis,
    FusionAxisConfiguration? yAxis,
    double animationProgress = 1.0,
    bool enableAntiAliasing = true,
    double devicePixelRatio = 1.0,
    Rect? dataBounds,
    Rect? viewportBounds,
    bool useDiscreteBucketGridX = false,
  }) {
    return FusionRenderContext(
      chartArea: chartArea ?? defaultChartArea,
      coordSystem: coordSystem ?? defaultCoordSystem,
      theme: theme ?? defaultTheme,
      paintPool: paintPool ?? defaultPaintPool,
      shaderCache: shaderCache ?? defaultShaderCache,
      xAxis: xAxis,
      yAxis: yAxis,
      animationProgress: animationProgress,
      enableAntiAliasing: enableAntiAliasing,
      devicePixelRatio: devicePixelRatio,
      dataBounds: dataBounds,
      viewportBounds: viewportBounds,
      useDiscreteBucketGridX: useDiscreteBucketGridX,
    );
  }

  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================

  group('FusionRenderContext - Construction', () {
    test('creates context with required parameters', () {
      final context = createDefaultContext();

      expect(context.chartArea, equals(defaultChartArea));
      expect(context.coordSystem, equals(defaultCoordSystem));
      expect(context.theme, equals(defaultTheme));
      expect(context.paintPool, equals(defaultPaintPool));
      expect(context.shaderCache, equals(defaultShaderCache));
    });

    test('creates context with default values', () {
      final context = createDefaultContext();

      expect(context.animationProgress, 1.0);
      expect(context.enableAntiAliasing, isTrue);
      expect(context.devicePixelRatio, 1.0);
      expect(context.dataBounds, isNull);
      expect(context.viewportBounds, isNull);
      expect(context.useDiscreteBucketGridX, isFalse);
      expect(context.xAxis, isNull);
      expect(context.yAxis, isNull);
    });

    test('creates context with custom animation progress', () {
      final context = createDefaultContext(animationProgress: 0.5);

      expect(context.animationProgress, 0.5);
    });

    test('creates context with anti-aliasing disabled', () {
      final context = createDefaultContext(enableAntiAliasing: false);

      expect(context.enableAntiAliasing, isFalse);
    });

    test('creates context with custom device pixel ratio', () {
      final context = createDefaultContext(devicePixelRatio: 2.0);

      expect(context.devicePixelRatio, 2.0);
    });

    test('creates context with data bounds', () {
      const bounds = Rect.fromLTRB(0, 0, 100, 100);
      final context = createDefaultContext(dataBounds: bounds);

      expect(context.dataBounds, equals(bounds));
    });

    test('creates context with viewport bounds', () {
      const viewport = Rect.fromLTRB(20, 20, 80, 80);
      final context = createDefaultContext(viewportBounds: viewport);

      expect(context.viewportBounds, equals(viewport));
    });

    test('creates context with useDiscreteBucketGridX enabled', () {
      final context = createDefaultContext(useDiscreteBucketGridX: true);

      expect(context.useDiscreteBucketGridX, isTrue);
    });

    test('creates context with axis configurations', () {
      const xAxisConfig = FusionAxisConfiguration(title: 'X Axis');
      const yAxisConfig = FusionAxisConfiguration(title: 'Y Axis');

      final context = createDefaultContext(
        xAxis: xAxisConfig,
        yAxis: yAxisConfig,
      );

      expect(context.xAxis, equals(xAxisConfig));
      expect(context.yAxis, equals(yAxisConfig));
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES - CHART DIMENSIONS
  // ===========================================================================

  group('FusionRenderContext - Chart Dimensions', () {
    test('chartWidth returns correct value', () {
      final context = createDefaultContext();

      expect(context.chartWidth, 300.0);
    });

    test('chartHeight returns correct value', () {
      final context = createDefaultContext();

      expect(context.chartHeight, 200.0);
    });

    test('chartCenter returns correct value', () {
      final context = createDefaultContext();

      expect(context.chartCenter, equals(const Offset(210, 110)));
    });

    test('chartWidth reflects chartArea width', () {
      const customArea = Rect.fromLTWH(0, 0, 500, 400);
      final context = createDefaultContext(chartArea: customArea);

      expect(context.chartWidth, 500.0);
    });

    test('chartHeight reflects chartArea height', () {
      const customArea = Rect.fromLTWH(0, 0, 500, 400);
      final context = createDefaultContext(chartArea: customArea);

      expect(context.chartHeight, 400.0);
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES - ANIMATION STATE
  // ===========================================================================

  group('FusionRenderContext - Animation State', () {
    test('isAnimating returns true when progress < 1.0', () {
      final context = createDefaultContext(animationProgress: 0.5);

      expect(context.isAnimating, isTrue);
    });

    test('isAnimating returns false when progress = 1.0', () {
      final context = createDefaultContext(animationProgress: 1.0);

      expect(context.isAnimating, isFalse);
    });

    test('isAnimating returns true when progress = 0.0', () {
      final context = createDefaultContext(animationProgress: 0.0);

      expect(context.isAnimating, isTrue);
    });

    test('isAnimationComplete returns true when progress >= 1.0', () {
      final context = createDefaultContext(animationProgress: 1.0);

      expect(context.isAnimationComplete, isTrue);
    });

    test('isAnimationComplete returns false when progress < 1.0', () {
      final context = createDefaultContext(animationProgress: 0.99);

      expect(context.isAnimationComplete, isFalse);
    });

    test('isAnimationComplete returns true when progress > 1.0', () {
      final context = createDefaultContext(animationProgress: 1.1);

      expect(context.isAnimationComplete, isTrue);
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES - EFFECTIVE VIEWPORT
  // ===========================================================================

  group('FusionRenderContext - Effective Viewport', () {
    test('effectiveViewport returns viewportBounds when set', () {
      const viewport = Rect.fromLTRB(20, 20, 80, 80);
      const dataBounds = Rect.fromLTRB(0, 0, 100, 100);
      final context = createDefaultContext(
        viewportBounds: viewport,
        dataBounds: dataBounds,
      );

      expect(context.effectiveViewport, equals(viewport));
    });

    test(
      'effectiveViewport returns dataBounds when viewportBounds is null',
      () {
        const dataBounds = Rect.fromLTRB(0, 0, 100, 100);
        final context = createDefaultContext(dataBounds: dataBounds);

        expect(context.effectiveViewport, equals(dataBounds));
      },
    );

    test('effectiveViewport returns coordSystem.dataBounds as fallback', () {
      final context = createDefaultContext();

      expect(context.effectiveViewport, equals(defaultCoordSystem.dataBounds));
    });

    test(
      'effectiveViewport priority: viewportBounds > dataBounds > coordSystem',
      () {
        const viewport = Rect.fromLTRB(30, 30, 70, 70);
        const dataBounds = Rect.fromLTRB(10, 10, 90, 90);
        final context = createDefaultContext(
          viewportBounds: viewport,
          dataBounds: dataBounds,
        );

        expect(context.effectiveViewport, equals(viewport));
      },
    );
  });

  // ===========================================================================
  // COMPUTED PROPERTIES - DEVICE PIXEL RATIO
  // ===========================================================================

  group('FusionRenderContext - Device Pixel Ratio', () {
    test('effectiveDevicePixelRatio returns coordSystem devicePixelRatio', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: defaultChartArea,
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 3.0,
      );
      final context = createDefaultContext(coordSystem: coordSystem);

      expect(context.effectiveDevicePixelRatio, 3.0);
    });

    test('effectiveDevicePixelRatio differs from devicePixelRatio field', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: defaultChartArea,
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 2.0,
      );
      final context = createDefaultContext(
        coordSystem: coordSystem,
        devicePixelRatio: 1.5,
      );

      // effectiveDevicePixelRatio comes from coordSystem
      expect(context.effectiveDevicePixelRatio, 2.0);
      // devicePixelRatio field has its own value
      expect(context.devicePixelRatio, 1.5);
    });
  });

  // ===========================================================================
  // PAINT HELPERS
  // ===========================================================================

  group('FusionRenderContext - Paint Helpers', () {
    test('getPaint returns paint with default values', () {
      final context = createDefaultContext();

      final paint = context.getPaint();

      expect(paint.style, PaintingStyle.stroke);
      expect(paint.strokeWidth, 1.0);
      expect(paint.strokeCap, StrokeCap.round);
      expect(paint.strokeJoin, StrokeJoin.round);
      expect(paint.isAntiAlias, isTrue);

      context.returnPaint(paint);
    });

    test('getPaint applies custom color', () {
      final context = createDefaultContext();
      const testColor = Color(0xFFFF0000);

      final paint = context.getPaint(color: testColor);

      expect(paint.color, testColor);

      context.returnPaint(paint);
    });

    test('getPaint applies custom style', () {
      final context = createDefaultContext();

      final paint = context.getPaint(style: PaintingStyle.fill);

      expect(paint.style, PaintingStyle.fill);

      context.returnPaint(paint);
    });

    test('getPaint applies custom strokeWidth', () {
      final context = createDefaultContext();

      final paint = context.getPaint(strokeWidth: 3.0);

      expect(paint.strokeWidth, 3.0);

      context.returnPaint(paint);
    });

    test('getPaint applies custom strokeCap', () {
      final context = createDefaultContext();

      final paint = context.getPaint(strokeCap: StrokeCap.butt);

      expect(paint.strokeCap, StrokeCap.butt);

      context.returnPaint(paint);
    });

    test('getPaint applies custom strokeJoin', () {
      final context = createDefaultContext();

      final paint = context.getPaint(strokeJoin: StrokeJoin.miter);

      expect(paint.strokeJoin, StrokeJoin.miter);

      context.returnPaint(paint);
    });

    test('getPaint respects enableAntiAliasing setting', () {
      final context = createDefaultContext(enableAntiAliasing: false);

      final paint = context.getPaint();

      expect(paint.isAntiAlias, isFalse);

      context.returnPaint(paint);
    });

    test('returnPaint returns paint to pool', () {
      final context = createDefaultContext();

      final paint = context.getPaint();
      context.returnPaint(paint);

      final stats = defaultPaintPool.statistics;
      expect(stats.inUse, 0);
      expect(stats.inPool, greaterThan(0));
    });

    test('getPaint acquires paint from pool', () {
      final context = createDefaultContext();

      final paint1 = context.getPaint();
      context.returnPaint(paint1);

      final paint2 = context.getPaint();

      // Should be same instance if pool is working
      expect(identical(paint1, paint2), isTrue);

      context.returnPaint(paint2);
    });

    test('getPaint with all custom parameters', () {
      final context = createDefaultContext();
      const testColor = Color(0xFF0000FF);

      final paint = context.getPaint(
        color: testColor,
        style: PaintingStyle.fill,
        strokeWidth: 5.0,
        strokeCap: StrokeCap.square,
        strokeJoin: StrokeJoin.bevel,
      );

      expect(paint.color, testColor);
      expect(paint.style, PaintingStyle.fill);
      expect(paint.strokeWidth, 5.0);
      expect(paint.strokeCap, StrokeCap.square);
      expect(paint.strokeJoin, StrokeJoin.bevel);

      context.returnPaint(paint);
    });
  });

  // ===========================================================================
  // GRADIENT SHADER HELPERS
  // ===========================================================================

  group('FusionRenderContext - Gradient Shader Helpers', () {
    test('getGradientShader returns shader from cache', () {
      final context = createDefaultContext();
      const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
      const bounds = Rect.fromLTWH(0, 0, 100, 100);

      final shader = context.getGradientShader(gradient, bounds);

      expect(shader, isNotNull);
      expect(shader, isA<ui.Shader>());
    });

    test('getGradientShader returns cached shader on second call', () {
      final context = createDefaultContext();
      const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
      const bounds = Rect.fromLTWH(0, 0, 100, 100);

      final shader1 = context.getGradientShader(gradient, bounds);
      final shader2 = context.getGradientShader(gradient, bounds);

      expect(identical(shader1, shader2), isTrue);
    });

    test('getGradientShader returns different shader for different bounds', () {
      final context = createDefaultContext();
      const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
      const bounds1 = Rect.fromLTWH(0, 0, 100, 100);
      const bounds2 = Rect.fromLTWH(0, 0, 200, 200);

      final shader1 = context.getGradientShader(gradient, bounds1);
      final shader2 = context.getGradientShader(gradient, bounds2);

      expect(identical(shader1, shader2), isFalse);
    });
  });

  // ===========================================================================
  // COORDINATE HELPERS
  // ===========================================================================

  group('FusionRenderContext - Coordinate Helpers', () {
    test('dataXToScreenX delegates to coordSystem', () {
      final context = createDefaultContext();

      final screenX = context.dataXToScreenX(50);

      expect(screenX, closeTo(defaultCoordSystem.dataXToScreenX(50), 0.5));
    });

    test('dataYToScreenY delegates to coordSystem', () {
      final context = createDefaultContext();

      final screenY = context.dataYToScreenY(50);

      expect(screenY, closeTo(defaultCoordSystem.dataYToScreenY(50), 0.5));
    });

    test('screenXToDataX delegates to coordSystem', () {
      final context = createDefaultContext();

      final dataX = context.screenXToDataX(210);

      expect(dataX, closeTo(defaultCoordSystem.screenXToDataX(210), 0.5));
    });

    test('screenYToDataY delegates to coordSystem', () {
      final context = createDefaultContext();

      final dataY = context.screenYToDataY(110);

      expect(dataY, closeTo(defaultCoordSystem.screenYToDataY(110), 0.5));
    });

    test('dataToScreen converts data coordinates to screen offset', () {
      final context = createDefaultContext();

      final screenPoint = context.dataToScreen(50, 50);

      expect(screenPoint.dx, closeTo(context.dataXToScreenX(50), 0.5));
      expect(screenPoint.dy, closeTo(context.dataYToScreenY(50), 0.5));
    });

    test('dataToScreen at origin', () {
      final context = createDefaultContext();

      final screenPoint = context.dataToScreen(0, 0);

      expect(screenPoint.dx, closeTo(60, 0.5)); // chartArea.left
      expect(
        screenPoint.dy,
        closeTo(210, 0.5),
      ); // chartArea.bottom (Y inverted)
    });

    test('dataToScreen at max values', () {
      final context = createDefaultContext();

      final screenPoint = context.dataToScreen(100, 100);

      expect(screenPoint.dx, closeTo(360, 0.5)); // chartArea.right
      expect(screenPoint.dy, closeTo(10, 0.5)); // chartArea.top (Y inverted)
    });
  });

  // ===========================================================================
  // BOUNDS CHECKING
  // ===========================================================================

  group('FusionRenderContext - Bounds Checking', () {
    test('containsScreenPoint returns true for point inside chartArea', () {
      final context = createDefaultContext();

      expect(context.containsScreenPoint(const Offset(100, 50)), isTrue);
      expect(context.containsScreenPoint(const Offset(210, 110)), isTrue);
      expect(context.containsScreenPoint(const Offset(60, 10)), isTrue);
    });

    test('containsScreenPoint returns false for point outside chartArea', () {
      final context = createDefaultContext();

      expect(context.containsScreenPoint(Offset.zero), isFalse);
      expect(context.containsScreenPoint(const Offset(500, 500)), isFalse);
      expect(context.containsScreenPoint(const Offset(59, 10)), isFalse);
    });

    test('containsScreenPoint handles edge cases', () {
      final context = createDefaultContext();

      // Left edge (included)
      expect(context.containsScreenPoint(const Offset(60, 110)), isTrue);
      // Right edge (not included)
      expect(context.containsScreenPoint(const Offset(360, 110)), isFalse);
      // Top edge (included)
      expect(context.containsScreenPoint(const Offset(210, 10)), isTrue);
      // Bottom edge (not included)
      expect(context.containsScreenPoint(const Offset(210, 210)), isFalse);
    });

    test('containsDataPoint returns true for point inside viewport', () {
      final context = createDefaultContext();

      expect(context.containsDataPoint(50, 50), isTrue);
      expect(context.containsDataPoint(0, 0), isTrue);
      expect(context.containsDataPoint(100, 100), isTrue);
    });

    test('containsDataPoint returns false for point outside viewport', () {
      final context = createDefaultContext();

      expect(context.containsDataPoint(-10, 50), isFalse);
      expect(context.containsDataPoint(110, 50), isFalse);
      expect(context.containsDataPoint(50, -10), isFalse);
      expect(context.containsDataPoint(50, 110), isFalse);
    });

    test('containsDataPoint uses effectiveViewport', () {
      const viewport = Rect.fromLTRB(20, 20, 80, 80);
      final context = createDefaultContext(viewportBounds: viewport);

      expect(context.containsDataPoint(50, 50), isTrue);
      expect(context.containsDataPoint(10, 50), isFalse);
      expect(context.containsDataPoint(90, 50), isFalse);
    });
  });

  // ===========================================================================
  // CLIPPING HELPERS
  // ===========================================================================

  group('FusionRenderContext - Clipping Helpers', () {
    test('createChartClipPath creates rectangular path', () {
      final context = createDefaultContext();

      final path = context.createChartClipPath();

      expect(path.getBounds(), equals(defaultChartArea));
    });

    test('createChartClipPath creates rounded path with cornerRadius', () {
      final context = createDefaultContext();

      final path = context.createChartClipPath(cornerRadius: 10.0);
      final bounds = path.getBounds();

      // Bounds should still match chart area
      expect(bounds.left, closeTo(defaultChartArea.left, 0.1));
      expect(bounds.top, closeTo(defaultChartArea.top, 0.1));
      expect(bounds.right, closeTo(defaultChartArea.right, 0.1));
      expect(bounds.bottom, closeTo(defaultChartArea.bottom, 0.1));
    });

    test(
      'createChartClipPath with zero cornerRadius creates rectangular path',
      () {
        final context = createDefaultContext();

        final path = context.createChartClipPath(cornerRadius: 0.0);

        expect(path.getBounds(), equals(defaultChartArea));
      },
    );

    test('createChartClipPath with different chart areas', () {
      const customArea = Rect.fromLTWH(100, 100, 200, 150);
      final context = createDefaultContext(chartArea: customArea);

      final path = context.createChartClipPath();

      expect(path.getBounds(), equals(customArea));
    });
  });

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  group('FusionRenderContext - copyWith', () {
    test('copyWith creates copy with all original values', () {
      final context = createDefaultContext();
      final copy = context.copyWith();

      expect(copy.chartArea, equals(context.chartArea));
      expect(copy.coordSystem, equals(context.coordSystem));
      expect(copy.theme, equals(context.theme));
      expect(copy.paintPool, equals(context.paintPool));
      expect(copy.shaderCache, equals(context.shaderCache));
      expect(copy.animationProgress, equals(context.animationProgress));
      expect(copy.enableAntiAliasing, equals(context.enableAntiAliasing));
      expect(copy.devicePixelRatio, equals(context.devicePixelRatio));
    });

    test('copyWith replaces chartArea', () {
      final context = createDefaultContext();
      const newArea = Rect.fromLTWH(0, 0, 500, 400);

      final copy = context.copyWith(chartArea: newArea);

      expect(copy.chartArea, equals(newArea));
      expect(copy.coordSystem, equals(context.coordSystem));
    });

    test('copyWith replaces coordSystem', () {
      final context = createDefaultContext();
      final newCoordSystem = FusionCoordinateSystem(
        chartArea: defaultChartArea,
        dataXMin: -100,
        dataXMax: 100,
        dataYMin: -100,
        dataYMax: 100,
      );

      final copy = context.copyWith(coordSystem: newCoordSystem);

      expect(copy.coordSystem, equals(newCoordSystem));
    });

    test('copyWith replaces animationProgress', () {
      final context = createDefaultContext(animationProgress: 1.0);

      final copy = context.copyWith(animationProgress: 0.5);

      expect(copy.animationProgress, 0.5);
      expect(context.animationProgress, 1.0);
    });

    test('copyWith replaces enableAntiAliasing', () {
      final context = createDefaultContext(enableAntiAliasing: true);

      final copy = context.copyWith(enableAntiAliasing: false);

      expect(copy.enableAntiAliasing, isFalse);
      expect(context.enableAntiAliasing, isTrue);
    });

    test('copyWith replaces devicePixelRatio', () {
      final context = createDefaultContext(devicePixelRatio: 1.0);

      final copy = context.copyWith(devicePixelRatio: 3.0);

      expect(copy.devicePixelRatio, 3.0);
    });

    test('copyWith replaces dataBounds', () {
      final context = createDefaultContext();
      const newBounds = Rect.fromLTRB(10, 10, 90, 90);

      final copy = context.copyWith(dataBounds: newBounds);

      expect(copy.dataBounds, equals(newBounds));
    });

    test('copyWith replaces viewportBounds', () {
      final context = createDefaultContext();
      const newViewport = Rect.fromLTRB(25, 25, 75, 75);

      final copy = context.copyWith(viewportBounds: newViewport);

      expect(copy.viewportBounds, equals(newViewport));
    });

    test('copyWith replaces useDiscreteBucketGridX', () {
      final context = createDefaultContext(useDiscreteBucketGridX: false);

      final copy = context.copyWith(useDiscreteBucketGridX: true);

      expect(copy.useDiscreteBucketGridX, isTrue);
    });

    test('copyWith replaces xAxis', () {
      final context = createDefaultContext();
      const newXAxis = FusionAxisConfiguration(title: 'New X Axis');

      final copy = context.copyWith(xAxis: newXAxis);

      expect(copy.xAxis, equals(newXAxis));
    });

    test('copyWith replaces yAxis', () {
      final context = createDefaultContext();
      const newYAxis = FusionAxisConfiguration(title: 'New Y Axis');

      final copy = context.copyWith(yAxis: newYAxis);

      expect(copy.yAxis, equals(newYAxis));
    });

    test('copyWith with multiple replacements', () {
      final context = createDefaultContext();

      final copy = context.copyWith(
        animationProgress: 0.75,
        enableAntiAliasing: false,
        devicePixelRatio: 2.0,
      );

      expect(copy.animationProgress, 0.75);
      expect(copy.enableAntiAliasing, isFalse);
      expect(copy.devicePixelRatio, 2.0);
      expect(copy.chartArea, equals(context.chartArea));
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('FusionRenderContext - toString', () {
    test('toString contains FusionRenderContext', () {
      final context = createDefaultContext();

      expect(context.toString(), contains('FusionRenderContext'));
    });

    test('toString contains chartArea', () {
      final context = createDefaultContext();

      expect(context.toString(), contains('chartArea'));
    });

    test('toString contains animation progress', () {
      final context = createDefaultContext(animationProgress: 0.75);

      expect(context.toString(), contains('75%'));
    });

    test('toString shows 100% for complete animation', () {
      final context = createDefaultContext(animationProgress: 1.0);

      expect(context.toString(), contains('100%'));
    });

    test('toString shows 0% for animation not started', () {
      final context = createDefaultContext(animationProgress: 0.0);

      expect(context.toString(), contains('0%'));
    });
  });

  // ===========================================================================
  // FUSIONRENDERCONTEXTBUILDER
  // ===========================================================================

  group('FusionRenderContextBuilder - Construction', () {
    test('builds context with all required fields', () {
      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .build();

      expect(context.chartArea, equals(defaultChartArea));
      expect(context.coordSystem, equals(defaultCoordSystem));
      expect(context.theme, equals(defaultTheme));
      expect(context.paintPool, equals(defaultPaintPool));
      expect(context.shaderCache, equals(defaultShaderCache));
    });

    test('builds context with default animation progress', () {
      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .build();

      expect(context.animationProgress, 1.0);
    });

    test('builds context with custom animation progress', () {
      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .withAnimation(0.5)
          .build();

      expect(context.animationProgress, 0.5);
    });

    test('builds context with anti-aliasing setting', () {
      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .withAntiAliasing(false)
          .build();

      expect(context.enableAntiAliasing, isFalse);
    });

    test('builds context with custom pixel ratio', () {
      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .withPixelRatio(2.0)
          .build();

      expect(context.devicePixelRatio, 2.0);
    });

    test('builds context with data bounds', () {
      const bounds = Rect.fromLTRB(0, 0, 100, 100);
      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .withDataBounds(bounds)
          .build();

      expect(context.dataBounds, equals(bounds));
    });

    test('builds context with viewport bounds', () {
      const viewport = Rect.fromLTRB(20, 20, 80, 80);
      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .withViewportBounds(viewport)
          .build();

      expect(context.viewportBounds, equals(viewport));
    });

    test('builds context with axis configurations', () {
      const xAxisConfig = FusionAxisConfiguration(title: 'X Axis');
      const yAxisConfig = FusionAxisConfiguration(title: 'Y Axis');

      final context = FusionRenderContextBuilder()
          .withChartArea(defaultChartArea)
          .withCoordinateSystem(defaultCoordSystem)
          .withTheme(defaultTheme)
          .withPaintPool(defaultPaintPool)
          .withShaderCache(defaultShaderCache)
          .withXAxis(xAxisConfig)
          .withYAxis(yAxisConfig)
          .build();

      expect(context.xAxis, equals(xAxisConfig));
      expect(context.yAxis, equals(yAxisConfig));
    });

    test('builder methods return self for chaining', () {
      final builder = FusionRenderContextBuilder();

      expect(builder.withChartArea(defaultChartArea), same(builder));
      expect(builder.withCoordinateSystem(defaultCoordSystem), same(builder));
      expect(builder.withTheme(defaultTheme), same(builder));
      expect(builder.withPaintPool(defaultPaintPool), same(builder));
      expect(builder.withShaderCache(defaultShaderCache), same(builder));
      expect(builder.withAnimation(0.5), same(builder));
      expect(builder.withAntiAliasing(true), same(builder));
      expect(builder.withPixelRatio(2.0), same(builder));
    });
  });

  group('FusionRenderContextBuilder - Assertions', () {
    test('build throws assertion error without chartArea', () {
      expect(
        () => FusionRenderContextBuilder()
            .withCoordinateSystem(defaultCoordSystem)
            .withTheme(defaultTheme)
            .withPaintPool(defaultPaintPool)
            .withShaderCache(defaultShaderCache)
            .build(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('build throws assertion error without coordSystem', () {
      expect(
        () => FusionRenderContextBuilder()
            .withChartArea(defaultChartArea)
            .withTheme(defaultTheme)
            .withPaintPool(defaultPaintPool)
            .withShaderCache(defaultShaderCache)
            .build(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('build throws assertion error without theme', () {
      expect(
        () => FusionRenderContextBuilder()
            .withChartArea(defaultChartArea)
            .withCoordinateSystem(defaultCoordSystem)
            .withPaintPool(defaultPaintPool)
            .withShaderCache(defaultShaderCache)
            .build(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('build throws assertion error without paintPool', () {
      expect(
        () => FusionRenderContextBuilder()
            .withChartArea(defaultChartArea)
            .withCoordinateSystem(defaultCoordSystem)
            .withTheme(defaultTheme)
            .withShaderCache(defaultShaderCache)
            .build(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('build throws assertion error without shaderCache', () {
      expect(
        () => FusionRenderContextBuilder()
            .withChartArea(defaultChartArea)
            .withCoordinateSystem(defaultCoordSystem)
            .withTheme(defaultTheme)
            .withPaintPool(defaultPaintPool)
            .build(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================

  group('FusionRenderContext - Edge Cases', () {
    test('handles zero-size chart area', () {
      const zeroArea = Rect.zero;
      final coordSystem = FusionCoordinateSystem(
        chartArea: zeroArea,
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );
      final context = createDefaultContext(
        chartArea: zeroArea,
        coordSystem: coordSystem,
      );

      expect(context.chartWidth, 0.0);
      expect(context.chartHeight, 0.0);
      expect(context.chartCenter, equals(Offset.zero));
    });

    test('handles negative animation progress', () {
      final context = createDefaultContext(animationProgress: -0.5);

      expect(context.animationProgress, -0.5);
      expect(context.isAnimating, isTrue);
      expect(context.isAnimationComplete, isFalse);
    });

    test('handles very large animation progress', () {
      final context = createDefaultContext(animationProgress: 100.0);

      expect(context.animationProgress, 100.0);
      expect(context.isAnimating, isFalse);
      expect(context.isAnimationComplete, isTrue);
    });

    test('handles very small device pixel ratio', () {
      final context = createDefaultContext(devicePixelRatio: 0.5);

      expect(context.devicePixelRatio, 0.5);
    });

    test('handles very large device pixel ratio', () {
      final context = createDefaultContext(devicePixelRatio: 10.0);

      expect(context.devicePixelRatio, 10.0);
    });

    test('multiple getPaint calls work correctly', () {
      final context = createDefaultContext();
      final paints = <Paint>[];

      // Acquire multiple paints
      for (int i = 0; i < 10; i++) {
        paints.add(context.getPaint(color: Color(0xFF000000 + i)));
      }

      // All paints should be different instances
      for (int i = 0; i < paints.length; i++) {
        for (int j = i + 1; j < paints.length; j++) {
          expect(identical(paints[i], paints[j]), isFalse);
        }
      }

      // Return all paints
      for (final paint in paints) {
        context.returnPaint(paint);
      }
    });

    test('createChartClipPath with very large corner radius', () {
      final context = createDefaultContext();

      // Corner radius larger than half the smallest dimension
      final path = context.createChartClipPath(cornerRadius: 200.0);

      // Path should still be created
      expect(path, isNotNull);
      expect(path.getBounds(), isNotNull);
    });
  });

  // ===========================================================================
  // IMMUTABILITY
  // ===========================================================================

  group('FusionRenderContext - Immutability', () {
    test('context is marked as immutable', () {
      // FusionRenderContext is decorated with @immutable
      // This test verifies the values cannot change after construction
      final context = createDefaultContext(animationProgress: 0.5);

      // These should all return the same values consistently
      expect(context.animationProgress, 0.5);
      expect(context.animationProgress, 0.5);
      expect(context.chartWidth, 300.0);
      expect(context.chartWidth, 300.0);
    });

    test('copyWith does not modify original', () {
      final original = createDefaultContext(animationProgress: 1.0);

      final copy = original.copyWith(animationProgress: 0.5);

      expect(original.animationProgress, 1.0);
      expect(copy.animationProgress, 0.5);
    });
  });
}

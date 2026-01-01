import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_axis_configuration.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_paint_pool.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_shader_cache.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_chart_theme.dart';

import '../../core/axis/base/fusion_axis_base.dart';

/// Context object that holds all rendering state and resources.
///
/// This is passed to every render layer and contains:
/// - Chart dimensions and bounds
/// - Coordinate transformation system
/// - Theme and styling
/// - Object pools for performance
/// - Animation state
///
/// ## Design Pattern: Context Object
///
/// Instead of passing 10+ parameters to each render method,
/// we pass a single context object that contains everything.
///
/// ## Example
///
/// ```dart
/// final context = FusionRenderContext(
///   chartArea: Rect.fromLTWH(60, 10, 300, 200),
///   coordSystem: coordSystem,
///   theme: FusionLightTheme(),
///   animationProgress: 0.75,
/// );
///
/// // Pass to layers
/// layer.paint(canvas, size, context);
/// ```
@immutable
class FusionRenderContext {
  /// Creates a render context.
  const FusionRenderContext({
    required this.chartArea,
    required this.coordSystem,
    required this.theme,
    required this.paintPool,
    required this.shaderCache,
    this.xAxis,
    this.yAxis,
    this.xAxisDefinition,
    this.yAxisDefinition,
    this.animationProgress = 1.0,
    this.enableAntiAliasing = true,
    this.devicePixelRatio = 1.0,
    this.dataBounds,
    this.viewportBounds,
    this.useDiscreteBucketGridX = false,
  });

  // ==========================================================================
  // CHART DIMENSIONS
  // ==========================================================================

  /// The drawable area for chart content (excludes axes, labels).
  final Rect chartArea;

  /// Data coordinate bounds (min/max x and y values).
  final Rect? dataBounds;

  /// Current viewport bounds (for zoomed/panned charts).
  final Rect? viewportBounds;

  /// Device pixel ratio for high-DPI rendering.
  final double devicePixelRatio;

  // ==========================================================================
  // COORDINATE SYSTEM
  // ==========================================================================

  /// The coordinate transformation system.
  final FusionCoordinateSystem coordSystem;

  // ==========================================================================
  // THEME & STYLING
  // ==========================================================================

  /// The chart theme.
  final FusionChartTheme theme;

  /// X-axis configuration.
  final FusionAxisConfiguration? xAxis;

  /// Y-axis configuration.
  final FusionAxisConfiguration? yAxis;

  /// X-axis definition (type: numeric, category, or datetime).
  final FusionAxisBase? xAxisDefinition;

  /// Y-axis definition (type: numeric, category, or datetime).
  final FusionAxisBase? yAxisDefinition;

  /// Whether to draw X-axis grid lines at bucket boundaries (for bar charts).
  ///
  /// When `true`, vertical grid lines are drawn BETWEEN data points
  /// (at -0.5, 0.5, 1.5, etc.) creating lanes for bars.
  ///
  /// When `false` (default), vertical grid lines are drawn AT data points
  /// (at 0, 1, 2, etc.) which is correct for line charts.
  ///
  /// This applies to Category, DateTime, and Numeric axes when used
  /// with bar/column chart types.
  final bool useDiscreteBucketGridX;

  // ==========================================================================
  // PERFORMANCE RESOURCES
  // ==========================================================================

  /// Paint object pool for reusing Paint instances.
  final FusionPaintPool paintPool;

  /// Shader cache for gradient shaders.
  final FusionShaderCache shaderCache;

  // ==========================================================================
  // ANIMATION STATE
  // ==========================================================================

  /// Current animation progress (0.0 - 1.0).
  final double animationProgress;

  // ==========================================================================
  // RENDERING OPTIONS
  // ==========================================================================

  /// Whether to enable anti-aliasing.
  final bool enableAntiAliasing;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Gets the effective viewport (zoomed or full data bounds).
  Rect get effectiveViewport => viewportBounds ?? dataBounds ?? coordSystem.dataBounds;

  /// Chart width in pixels.
  double get chartWidth => chartArea.width;

  /// Chart height in pixels.
  double get chartHeight => chartArea.height;

  /// Chart center point.
  Offset get chartCenter => chartArea.center;

  /// Is animation in progress?
  bool get isAnimating => animationProgress < 1.0;

  /// Is animation complete?
  bool get isAnimationComplete => animationProgress >= 1.0;

  /// Get DPI from coordinate system
  double get effectiveDevicePixelRatio => coordSystem.devicePixelRatio;

  // ==========================================================================
  // PAINT HELPERS
  // ==========================================================================

  /// Gets a paint object from the pool.
  ///
  /// **IMPORTANT:** Must call `returnPaint()` after use!
  Paint getPaint({
    Color? color,
    PaintingStyle style = PaintingStyle.stroke,
    double strokeWidth = 1.0,
    StrokeCap strokeCap = StrokeCap.round,
    StrokeJoin strokeJoin = StrokeJoin.round,
  }) {
    final paint = paintPool.acquire();

    if (color != null) paint.color = color;
    paint.style = style;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = strokeCap;
    paint.strokeJoin = strokeJoin;
    paint.isAntiAlias = enableAntiAliasing;

    return paint;
  }

  /// Returns a paint object to the pool.
  void returnPaint(Paint paint) {
    paintPool.release(paint);
  }

  /// Gets a gradient shader (cached).
  Shader? getGradientShader(LinearGradient gradient, Rect bounds) {
    return shaderCache.getShader(gradient, bounds);
  }

  // ==========================================================================
  // COORDINATE HELPERS
  // ==========================================================================

  /// Converts data X to screen X.
  double dataXToScreenX(double dataX) => coordSystem.dataXToScreenX(dataX);

  /// Converts data Y to screen Y.
  double dataYToScreenY(double dataY) => coordSystem.dataYToScreenY(dataY);

  /// Converts screen X to data X.
  double screenXToDataX(double screenX) => coordSystem.screenXToDataX(screenX);

  /// Converts screen Y to data Y.
  double screenYToDataY(double screenY) => coordSystem.screenYToDataY(screenY);

  /// Converts data point to screen offset.
  Offset dataToScreen(double dataX, double dataY) {
    return Offset(dataXToScreenX(dataX), dataYToScreenY(dataY));
  }

  // ==========================================================================
  // BOUNDS CHECKING
  // ==========================================================================

  /// Checks if a screen point is within chart area.
  bool containsScreenPoint(Offset point) {
    return chartArea.contains(point);
  }

  /// Checks if a data point is within viewport.
  bool containsDataPoint(double dataX, double dataY) {
    final viewport = effectiveViewport;
    return dataX >= viewport.left &&
        dataX <= viewport.right &&
        dataY >= viewport.top &&
        dataY <= viewport.bottom;
  }

  // ==========================================================================
  // CLIPPING HELPERS
  // ==========================================================================

  /// Creates a clipping path for the chart area.
  Path createChartClipPath({double cornerRadius = 0.0}) {
    if (cornerRadius > 0) {
      return Path()..addRRect(RRect.fromRectAndRadius(chartArea, Radius.circular(cornerRadius)));
    }
    return Path()..addRect(chartArea);
  }

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionRenderContext copyWith({
    Rect? chartArea,
    FusionCoordinateSystem? coordSystem,
    FusionChartTheme? theme,
    FusionPaintPool? paintPool,
    FusionShaderCache? shaderCache,
    FusionAxisConfiguration? xAxis,
    FusionAxisConfiguration? yAxis,
    double? animationProgress,
    bool? enableAntiAliasing,
    double? devicePixelRatio,
    Rect? dataBounds,
    Rect? viewportBounds,
    bool? useDiscreteBucketGridX,
  }) {
    return FusionRenderContext(
      chartArea: chartArea ?? this.chartArea,
      coordSystem: coordSystem ?? this.coordSystem,
      theme: theme ?? this.theme,
      paintPool: paintPool ?? this.paintPool,
      shaderCache: shaderCache ?? this.shaderCache,
      xAxis: xAxis ?? this.xAxis,
      yAxis: yAxis ?? this.yAxis,
      animationProgress: animationProgress ?? this.animationProgress,
      enableAntiAliasing: enableAntiAliasing ?? this.enableAntiAliasing,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      dataBounds: dataBounds ?? this.dataBounds,
      viewportBounds: viewportBounds ?? this.viewportBounds,
      useDiscreteBucketGridX: useDiscreteBucketGridX ?? this.useDiscreteBucketGridX,
    );
  }

  @override
  String toString() {
    return 'FusionRenderContext('
        'chartArea: $chartArea, '
        'animation: ${(animationProgress * 100).toStringAsFixed(0)}%'
        ')';
  }
}

// ==========================================================================
// RENDER CONTEXT BUILDER
// ==========================================================================

/// Builder for creating render contexts.
class FusionRenderContextBuilder {
  Rect? _chartArea;
  FusionCoordinateSystem? _coordSystem;
  FusionChartTheme? _theme;
  FusionPaintPool? _paintPool;
  FusionShaderCache? _shaderCache;
  FusionAxisConfiguration? _xAxis;
  FusionAxisConfiguration? _yAxis;
  double _animationProgress = 1.0;
  bool _enableAntiAliasing = true;
  double _devicePixelRatio = 1.0;
  Rect? _dataBounds;
  Rect? _viewportBounds;

  FusionRenderContextBuilder withChartArea(Rect area) {
    _chartArea = area;
    return this;
  }

  FusionRenderContextBuilder withCoordinateSystem(FusionCoordinateSystem system) {
    _coordSystem = system;
    return this;
  }

  FusionRenderContextBuilder withTheme(FusionChartTheme theme) {
    _theme = theme;
    return this;
  }

  FusionRenderContextBuilder withPaintPool(FusionPaintPool pool) {
    _paintPool = pool;
    return this;
  }

  FusionRenderContextBuilder withShaderCache(FusionShaderCache cache) {
    _shaderCache = cache;
    return this;
  }

  FusionRenderContextBuilder withXAxis(FusionAxisConfiguration axis) {
    _xAxis = axis;
    return this;
  }

  FusionRenderContextBuilder withYAxis(FusionAxisConfiguration axis) {
    _yAxis = axis;
    return this;
  }

  FusionRenderContextBuilder withAnimation(double progress) {
    _animationProgress = progress;
    return this;
  }

  FusionRenderContextBuilder withAntiAliasing(bool enable) {
    _enableAntiAliasing = enable;
    return this;
  }

  FusionRenderContextBuilder withPixelRatio(double ratio) {
    _devicePixelRatio = ratio;
    return this;
  }

  FusionRenderContextBuilder withDataBounds(Rect bounds) {
    _dataBounds = bounds;
    return this;
  }

  FusionRenderContextBuilder withViewportBounds(Rect bounds) {
    _viewportBounds = bounds;
    return this;
  }

  FusionRenderContext build() {
    assert(_chartArea != null, 'Chart area is required');
    assert(_coordSystem != null, 'Coordinate system is required');
    assert(_theme != null, 'Theme is required');
    assert(_paintPool != null, 'Paint pool is required');
    assert(_shaderCache != null, 'Shader cache is required');

    return FusionRenderContext(
      chartArea: _chartArea!,
      coordSystem: _coordSystem!,
      theme: _theme!,
      paintPool: _paintPool!,
      shaderCache: _shaderCache!,
      xAxis: _xAxis,
      yAxis: _yAxis,
      animationProgress: _animationProgress,
      enableAntiAliasing: _enableAntiAliasing,
      devicePixelRatio: _devicePixelRatio,
      dataBounds: _dataBounds,
      viewportBounds: _viewportBounds,
    );
  }
}

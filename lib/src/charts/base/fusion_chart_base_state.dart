import 'package:flutter/material.dart';

import '../../configuration/fusion_chart_configuration.dart';
import '../../rendering/engine/fusion_paint_pool.dart';
import '../../rendering/engine/fusion_shader_cache.dart';
import '../../rendering/fusion_coordinate_system.dart';
import '../../series/series_with_data_points.dart';
import '../../utils/fusion_margin_calculator.dart';
import 'fusion_chart_base.dart';
import 'fusion_chart_header.dart';
import 'fusion_data_bounds.dart';
import 'fusion_interactive_state_base.dart';

/// Abstract base state for all Fusion Chart widgets.
///
/// Handles all shared functionality:
/// - Animation controller lifecycle
/// - Coordinate system management
/// - Interactive state management
/// - Layout and rendering pipeline
/// - Resource pooling (paints, shaders)
///
/// ## Type Parameters
///
/// - `W` - Widget type (must extend [FusionChartBase<S>])
/// - `S` - Series type (must extend [SeriesWithDataPoints])
/// - `I` - Interactive state type (must extend [FusionInteractiveStateBase])
///
/// ## Abstract Members (Subclass Must Implement)
///
/// - [effectiveConfig] - Returns configuration with proper defaults
/// - [createInteractiveState] - Creates chart-specific interactive state
/// - [createPainter] - Creates chart-specific painter
/// - [calculateDataBounds] - Calculates data bounds from series
/// - [calculateSeriesHash] - Hash for change detection
///
/// ## Example Implementation
///
/// ```dart
/// class _FusionLineChartState extends FusionChartBaseState<
///     FusionLineChart,
///     FusionLineSeries,
///     FusionInteractiveChartState
///   > {
///   @override
///   FusionChartConfiguration get effectiveConfig =>
///       widget.config ?? const FusionChartConfiguration();
///
///   @override
///   FusionInteractiveChartState createInteractiveState(
///     FusionCoordinateSystem coordSystem,
///   ) {
///     return FusionInteractiveChartState(
///       config: effectiveConfig,
///       initialCoordSystem: coordSystem,
///       series: widget.series.cast<SeriesWithDataPoints>(),
///     );
///   }
///
///   @override
///   CustomPainter createPainter({
///     required FusionCoordinateSystem coordSystem,
///     required double animationProgress,
///   }) {
///     return FusionLineChartPainter(/* ... */);
///   }
///
///   // ... implement other abstract members
/// }
/// ```
abstract class FusionChartBaseState<
  W extends FusionChartBase<S>,
  S extends SeriesWithDataPoints,
  I extends FusionInteractiveStateBase
>
    extends State<W>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // SHARED RESOURCES
  // ===========================================================================

  late AnimationController _animationController;
  late Animation<double> _animation;
  late I _interactiveState;

  /// Paint object pool for efficient rendering.
  final FusionPaintPool _paintPool = FusionPaintPool();

  /// Shader cache for gradient caching.
  final FusionShaderCache _shaderCache = FusionShaderCache();

  /// Current coordinate system.
  FusionCoordinateSystem? _coordSystem;

  /// Cached layout size for change detection.
  Size? _cachedSize;

  /// Cached series hash for change detection.
  int? _cachedSeriesHash;

  /// Cached coordinate system for reuse.
  FusionCoordinateSystem? _cachedCoordSystem;

  // ===========================================================================
  // ABSTRACT MEMBERS - SUBCLASS MUST IMPLEMENT
  // ===========================================================================

  /// Returns the effective configuration with proper defaults.
  ///
  /// Subclasses should return their specific configuration type
  /// with sensible defaults applied.
  ///
  /// ```dart
  /// @override
  /// FusionChartConfiguration get effectiveConfig =>
  ///     widget.config ?? const FusionChartConfiguration();
  /// ```
  FusionChartConfiguration get effectiveConfig;

  /// Creates the chart-specific interactive state.
  ///
  /// Called during initialization and when series/config changes.
  ///
  /// ```dart
  /// @override
  /// FusionInteractiveChartState createInteractiveState(
  ///   FusionCoordinateSystem coordSystem,
  /// ) {
  ///   return FusionInteractiveChartState(
  ///     config: effectiveConfig,
  ///     initialCoordSystem: coordSystem,
  ///     series: widget.series.cast<SeriesWithDataPoints>(),
  ///   );
  /// }
  /// ```
  I createInteractiveState(FusionCoordinateSystem coordSystem);

  /// Creates the chart-specific painter.
  ///
  /// Called every frame during animation and interaction.
  ///
  /// ```dart
  /// @override
  /// CustomPainter createPainter({
  ///   required FusionCoordinateSystem coordSystem,
  ///   required double animationProgress,
  /// }) {
  ///   return FusionLineChartPainter(
  ///     series: widget.series,
  ///     coordSystem: coordSystem,
  ///     animationProgress: animationProgress,
  ///     // ... other parameters
  ///   );
  /// }
  /// ```
  CustomPainter createPainter({
    required FusionCoordinateSystem coordSystem,
    required double animationProgress,
  });

  /// Calculates data bounds from the current series.
  ///
  /// Called during coordinate system creation/update.
  ///
  /// ```dart
  /// @override
  /// FusionDataBounds calculateDataBounds() {
  ///   final allPoints = widget.series
  ///       .where((s) => s.visible)
  ///       .expand((s) => s.dataPoints)
  ///       .toList();
  ///   return FusionDataBounds.fromPoints(allPoints);
  /// }
  /// ```
  FusionDataBounds calculateDataBounds();

  /// Calculates a hash representing the current series state.
  ///
  /// Used for change detection to avoid unnecessary recalculations.
  ///
  /// ```dart
  /// @override
  /// int calculateSeriesHash() {
  ///   int hash = 0;
  ///   for (final s in widget.series) {
  ///     hash ^= s.visible.hashCode;
  ///     hash ^= s.dataPoints.length.hashCode;
  ///   }
  ///   return hash;
  /// }
  /// ```
  int calculateSeriesHash();

  // ===========================================================================
  // PROTECTED ACCESSORS
  // ===========================================================================

  /// The current interactive state.
  @protected
  I get interactiveState => _interactiveState;

  /// Paint pool for efficient paint object reuse.
  @protected
  FusionPaintPool get paintPool => _paintPool;

  /// Shader cache for gradient caching.
  @protected
  FusionShaderCache get shaderCache => _shaderCache;

  /// Current coordinate system (may be null during initial build).
  @protected
  FusionCoordinateSystem? get coordSystem => _coordSystem;

  /// Current animation progress (0.0 to 1.0).
  @protected
  double get animationProgress => _animation.value;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initInteractiveState();
  }

  void _initAnimation() {
    final config = effectiveConfig;

    _animationController = AnimationController(
      duration: config.enableAnimation ? config.effectiveAnimationDuration : Duration.zero,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: config.effectiveAnimationCurve,
    );

    if (config.enableAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  void _initInteractiveState() {
    final bounds = calculateDataBounds();
    _coordSystem = _createCoordinateSystem(
      chartArea: const Rect.fromLTWH(60, 10, 300, 200), // Placeholder
      bounds: bounds,
    );

    _interactiveState = createInteractiveState(_coordSystem!);
    _interactiveState.initialize();
    _interactiveState.addListener(_onInteractionChanged);
  }

  void _onInteractionChanged() {
    setState(() {
      // Rebuild when interaction state changes (tooltip, crosshair, zoom, pan)
    });
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldReinitialize(oldWidget)) {
      _invalidateCache();

      _animationController.reset();
      _animationController.forward();

      _interactiveState.dispose();
      _initInteractiveState();
    }
  }

  /// Determines if the chart should reinitialize.
  ///
  /// Override in subclass if custom change detection is needed.
  @protected
  bool _shouldReinitialize(W oldWidget) {
    return widget.series != oldWidget.series || widget.config != oldWidget.config;
  }

  /// Invalidates the coordinate system cache.
  @protected
  void _invalidateCache() {
    _cachedSize = null;
    _cachedSeriesHash = null;
    _cachedCoordSystem = null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _interactiveState.dispose();
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final config = effectiveConfig;
    final theme = config.theme;

    return Padding(
      padding: config.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.title != null) FusionChartTitle(title: widget.title!, theme: theme),
          if (widget.subtitle != null)
            FusionChartSubtitle(subtitle: widget.subtitle!, theme: theme),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final dpr = MediaQuery.devicePixelRatioOf(context);

                  _updateCoordinateSystem(size, dpr);

                  return buildChartArea(size);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the interactive chart area with gesture handling.
  ///
  /// Override in subclass if custom wrapping is needed
  /// (e.g., for custom tooltip overlay).
  @protected
  Widget buildChartArea(Size size) {
    return buildInteractiveChart(size);
  }

  /// Builds the core interactive chart with gesture handling.
  ///
  /// Called by [buildChartArea]. Subclasses can call this directly
  /// when overriding [buildChartArea] to wrap the chart.
  @protected
  Widget buildInteractiveChart(Size size) {
    return Listener(
      onPointerDown: _interactiveState.handlePointerDown,
      onPointerMove: _interactiveState.handlePointerMove,
      onPointerUp: _interactiveState.handlePointerUp,
      onPointerCancel: _interactiveState.handlePointerCancel,
      onPointerHover: _interactiveState.handlePointerHover,
      onPointerSignal: _interactiveState.handlePointerSignal,
      child: RawGestureDetector(
        gestures: _interactiveState.getGestureRecognizers(),
        child: CustomPaint(
          size: size,
          painter: createPainter(
            coordSystem: _interactiveState.coordSystem,
            animationProgress: _animation.value,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // COORDINATE SYSTEM MANAGEMENT
  // ===========================================================================

  void _updateCoordinateSystem(Size size, double dpr) {
    // Skip if size is invalid
    if (size.width <= 0 || size.height <= 0) return;

    // Check cache
    final seriesHash = calculateSeriesHash();
    if (_cachedSize == size && _cachedSeriesHash == seriesHash && _cachedCoordSystem != null) {
      _coordSystem = _cachedCoordSystem;
      return;
    }

    // Calculate new bounds and margins
    final bounds = calculateDataBounds();
    final config = effectiveConfig;

    final margins = FusionMarginCalculator.calculate(
      enableAxis: config.enableAxis,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
      minX: bounds.effectiveMarginMinX,
      maxX: bounds.effectiveMarginMaxX,
      minY: bounds.minY,
      maxY: bounds.maxY,
    );

    final chartArea = Rect.fromLTRB(
      margins.left,
      margins.top,
      size.width - margins.right,
      size.height - margins.bottom,
    );

    // Skip if chart area is invalid
    if (chartArea.width <= 0 || chartArea.height <= 0) return;

    // Create new coordinate system
    _coordSystem = _createCoordinateSystem(
      chartArea: chartArea,
      bounds: bounds,
      devicePixelRatio: dpr,
    );

    // Update interactive state
    _interactiveState.updateCoordinateSystem(_coordSystem!);

    // Update cache
    _cachedSize = size;
    _cachedSeriesHash = seriesHash;
    _cachedCoordSystem = _coordSystem;
  }

  FusionCoordinateSystem _createCoordinateSystem({
    required Rect chartArea,
    required FusionDataBounds bounds,
    double devicePixelRatio = 1.0,
  }) {
    return FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: bounds.minX,
      dataXMax: bounds.maxX,
      dataYMin: bounds.minY,
      dataYMax: bounds.maxY,
      devicePixelRatio: devicePixelRatio,
    );
  }
}

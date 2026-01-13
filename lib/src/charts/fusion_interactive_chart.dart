import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_tooltip_configuration.dart';
import '../configuration/fusion_zoom_configuration.dart';
import '../core/enums/fusion_dismiss_strategy.dart';
import '../core/enums/fusion_tooltip_trackball_mode.dart';
import '../core/enums/fusion_zoom_mode.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_interaction_handler.dart';
import '../series/series_with_data_points.dart';
import '../utils/fusion_desktop_helper.dart';
import 'base/fusion_interactive_state_base.dart';
import 'mixins/fusion_zoom_animation_mixin.dart';

/// State manager for interactive chart features.
///
/// Works with ANY series type that implements SeriesWithDataPoints.
/// Scales to infinite chart types without modification.
///
/// Implements [FusionInteractiveStateBase] for compatibility with
/// [FusionChartBaseState].
class FusionInteractiveChartState extends ChangeNotifier
    with FusionZoomAnimationMixin
    implements FusionInteractiveStateBase {
  FusionInteractiveChartState({
    required this.config,
    required FusionCoordinateSystem initialCoordSystem,
    required this.series,
  }) : _currentCoordSystem = initialCoordSystem,
       _originalCoordSystem = initialCoordSystem;

  final FusionChartConfiguration config;
  final List<SeriesWithDataPoints> series;

  final FusionCoordinateSystem _originalCoordSystem;
  FusionCoordinateSystem _currentCoordSystem;
  FusionInteractionHandler? _interactionHandler;

  // Tooltip state
  TooltipRenderData? _tooltipData;
  bool _isPointerDown = false;
  DateTime? _pointerDownTime;
  Offset? _lastPointerPosition;

  // Timer management
  Timer? _tooltipShowTimer;
  Timer? _tooltipHideTimer;
  Timer? _debounceTimer;

  // Animation state
  double _tooltipOpacity = 0.0;

  // Crosshair state
  Offset? _crosshairPosition;
  FusionDataPoint? _crosshairPoint;
  Timer? _crosshairHideTimer;

  // Zoom/Pan state
  bool _isPanning = false;
  bool _isZooming = false;
  bool _hasActiveZoom = false;  // Tracks if user has zoomed (persists after gesture ends)
  double _lastScale = 1.0;  // For converting cumulative scale to delta
  Offset? _lastScaleFocalPoint;  // Separate tracking for ScaleGestureRecognizer pan

  // Cached gesture recognizers - prevents recreation on rebuild which kills in-progress gestures
  Map<Type, GestureRecognizerFactory>? _cachedGestureRecognizers;
  int? _lastGestureConfigHash;

  // Getters
  @override
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;
  @override
  TooltipRenderData? get tooltipData => _tooltipData;
  @override
  Offset? get crosshairPosition => _crosshairPosition;
  @override
  FusionDataPoint? get crosshairPoint => _crosshairPoint;
  @override
  bool get isInteracting => _isPanning || _isZooming || isAnimatingZoom || isSelectionZoomActive;
  @override
  double get tooltipOpacity => _tooltipOpacity;
  @override
  bool get isPointerDown => _isPointerDown;
  
  // ===========================================================================
  // ZOOM ANIMATION MIXIN IMPLEMENTATION
  // ===========================================================================
  
  @override
  FusionZoomConfiguration get zoomConfig => config.zoomBehavior;
  
  @override
  FusionCoordinateSystem get currentCoordSystem => _currentCoordSystem;
  
  @override
  FusionCoordinateSystem get originalCoordSystem => _originalCoordSystem;
  
  @override
  set currentCoordSystemValue(FusionCoordinateSystem value) {
    _currentCoordSystem = value;
  }
  
  @override
  void onZoomAnimationUpdate() {
    notifyListeners();
  }
  
  @override
  void onZoomComplete() {
    // Check if we're back to original bounds
    final isAtOriginal = 
        (_currentCoordSystem.dataXMin - _originalCoordSystem.dataXMin).abs() < 0.001 &&
        (_currentCoordSystem.dataXMax - _originalCoordSystem.dataXMax).abs() < 0.001 &&
        (_currentCoordSystem.dataYMin - _originalCoordSystem.dataYMin).abs() < 0.001 &&
        (_currentCoordSystem.dataYMax - _originalCoordSystem.dataYMax).abs() < 0.001;
    
    _hasActiveZoom = !isAtOriginal;
    _rebuildInteractionHandler();
  }
  
  /// Public methods for zoom controls
  @override
  void zoomIn() => zoomInByControl();
  
  @override
  void zoomOut() => zoomOutByControl();

  @override
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {
    if (isInteracting || _hasActiveZoom) {
      _currentCoordSystem = FusionCoordinateSystem(
        chartArea: newCoordSystem.chartArea,
        dataXMin: _currentCoordSystem.dataXMin,
        dataXMax: _currentCoordSystem.dataXMax,
        dataYMin: _currentCoordSystem.dataYMin,
        dataYMax: _currentCoordSystem.dataYMax,
        devicePixelRatio: newCoordSystem.devicePixelRatio,
      );
      if (!isInteracting) {
        _rebuildInteractionHandler();
      }
    } else {
      _currentCoordSystem = newCoordSystem;
      _rebuildInteractionHandler();
    }
  }

  List<FusionDataPoint> get _allDataPoints {
    return series.where((s) => s.visible).expand((s) => s.dataPoints).toList();
  }

  @override
  void initialize() {
    _rebuildInteractionHandler();
  }

  void _rebuildInteractionHandler() {
    _interactionHandler = FusionInteractionHandler(
      coordSystem: _currentCoordSystem,
      zoomConfig: config.zoomBehavior,
      panConfig: config.panBehavior,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onHover: _handleHover,
    );
  }

  // ==========================================================================
  // TAP & HOVER HANDLING
  // ==========================================================================

  void _handleTap(FusionDataPoint point, Offset position) {
    if (config.enableTooltip) {
      _showTooltip(point, position);
    }
  }

  void _handleLongPress(FusionDataPoint point, Offset position) {
    if (config.enableCrosshair) {
      _showCrosshair(position, point);
    }
  }

  void _handleHover(Offset position) {
    if (!config.enableTooltip && !config.enableCrosshair) return;

    final nearestPoint = _interactionHandler?.findNearestPoint(
      _allDataPoints,
      position,
    );

    if (nearestPoint != null) {
      if (config.enableTooltip) {
        _showTooltip(nearestPoint, position);
      }
      if (config.enableCrosshair) {
        _showCrosshair(position, nearestPoint);
      }
    } else {
      _hideTooltip();
      _hideCrosshair();
    }
  }

  // ==========================================================================
  // POINTER EVENT HANDLERS
  // ==========================================================================

  @override
  void handlePointerDown(PointerDownEvent event) {
    _isPointerDown = true;
    _pointerDownTime = DateTime.now();
    _lastPointerPosition = event.localPosition;

    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();
    
    // Check for selection zoom (desktop only: Shift + mouse drag)
    if (config.enableZoom && 
        config.zoomBehavior.enableSelectionZoom &&
        FusionDesktopHelper.shouldStartSelectionZoom(event)) {
      startSelectionZoom(event.localPosition);  // Use mixin method
      return;  // Don't process other interactions during selection
    }

    if (!config.enableTooltip) return;

    final point = _interactionHandler?.findNearestPoint(
      _allDataPoints,
      event.localPosition,
    );

    if (point != null) {
      _showTooltipWithDelay(point, event.localPosition, false);
    }
  }

  @override
  void handlePointerMove(PointerMoveEvent event) {
    if (!_isPointerDown) return;

    final currentPosition = event.localPosition;
    _lastPointerPosition = currentPosition;
    
    // Update selection rectangle if selection zoom is active
    if (isSelectionZoomActive) {
      updateSelectionZoom(currentPosition);  // Use mixin method
      return;  // Don't process other interactions during selection
    }

    // Update crosshair if active (during long press drag)
    if (config.enableCrosshair && _crosshairPosition != null) {
      _updateCrosshairPosition(currentPosition);
    }

    // Update tooltip trackball if enabled
    if (config.enableTooltip) {
      final trackballMode = config.tooltipBehavior.trackballMode;
      if (trackballMode == FusionTooltipTrackballMode.none) return;

      // Check if pointer moved enough from LAST trackball update position
      // (not from tooltip position - that was the bug!)
      if (_lastTrackballPosition != null) {
        final distance = (currentPosition - _lastTrackballPosition!).distance;
        if (distance < config.tooltipBehavior.trackballUpdateThreshold) {
          return; // Pointer hasn't moved enough, skip update
        }
      }

      // Debounce for smooth performance (60fps = 16ms)
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(milliseconds: 16),
        () => _updateTrackball(currentPosition, trackballMode),
      );
    }
  }

  /// Updates crosshair position and finds nearest data point.
  void _updateCrosshairPosition(Offset position) {
    // Cancel any pending hide timer while dragging
    _crosshairHideTimer?.cancel();

    final dataX = _currentCoordSystem.screenXToDataX(position.dx);
    final dataY = _currentCoordSystem.screenYToDataY(position.dy);

    final clampedDataX = dataX.clamp(
      _currentCoordSystem.dataXMin,
      _currentCoordSystem.dataXMax,
    );
    final clampedDataY = dataY.clamp(
      _currentCoordSystem.dataYMin,
      _currentCoordSystem.dataYMax,
    );

    final clampedPosition = Offset(
      _currentCoordSystem.dataXToScreenX(clampedDataX),
      _currentCoordSystem.dataYToScreenY(clampedDataY),
    );

    // Find nearest point at clamped position
    final nearestPoint = _interactionHandler?.findNearestPoint(
      _allDataPoints,
      clampedPosition,
    );

    if (nearestPoint != null && config.crosshairBehavior.snapToDataPoint) {
      // Snap crosshair to nearest point
      final snappedPosition = _currentCoordSystem.dataToScreen(nearestPoint);
      _crosshairPosition = snappedPosition;
      _crosshairPoint = nearestPoint;
    } else {
      // Follow finger position (clamped to coordinate system bounds)
      _crosshairPosition = clampedPosition;
      _crosshairPoint = nearestPoint;
    }

    notifyListeners();
  }

  @override
  void handlePointerUp(PointerUpEvent event) {
    _isPointerDown = false;
    _lastTrackballPosition = null; // Reset trackball position tracking
    
    // Complete selection zoom if active
    if (isSelectionZoomActive && selectionStart != null && selectionCurrent != null) {
      completeSelectionZoom();  // Use mixin method
      return;  // Don't process other interactions
    }

    final pressDuration = _pointerDownTime != null
        ? DateTime.now().difference(_pointerDownTime!)
        : Duration.zero;

    final wasLongPress = pressDuration.inMilliseconds > 500;

    if (config.enableTooltip && _tooltipData != null) {
      final tooltipBehavior = config.tooltipBehavior;

      if (tooltipBehavior.shouldDismissOnRelease()) {
        final delay = tooltipBehavior.getDismissDelay(wasLongPress);
        if (delay == Duration.zero) {
          _hideTooltipAnimated();
        } else {
          _startHideTimer(delay);
        }
      } else if (tooltipBehavior.shouldUseTimer()) {
        _startHideTimer(tooltipBehavior.duration);
      }
    }

    if (config.enableCrosshair && _crosshairPosition != null) {
      final crosshairBehavior = config.crosshairBehavior;

      if (crosshairBehavior.shouldDismissOnRelease()) {
        final delay = crosshairBehavior.getDismissDelay(wasLongPress);

        if (delay == Duration.zero) {
          _hideCrosshairAnimated();
        } else {
          _startCrosshairHideTimer(delay);
        }
      } else if (crosshairBehavior.shouldUseTimer()) {
        _startCrosshairHideTimer(crosshairBehavior.duration);
      }
    }

    _pointerDownTime = null;
  }

  @override
  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _lastPointerPosition = null;
    _lastTrackballPosition = null;
    
    // Cancel selection zoom if active
    if (isSelectionZoomActive) {
      cancelSelectionZoom();  // Use mixin method
    }

    _hideTooltipAnimated();
    _hideCrosshair();
  }

  @override
  void handlePointerHover(PointerHoverEvent event) {
    if (!config.enableTooltip) return;

    final point = _interactionHandler?.findNearestPoint(
      _allDataPoints,
      event.localPosition,
    );

    if (point != null) {
      _showTooltipWithDelay(point, event.localPosition, false);
    } else {
      _hideTooltipAnimated();
    }
  }

  // ==========================================================================
  // MOUSE WHEEL ZOOM (Desktop Support)
  // ==========================================================================

  /// Handles mouse wheel scroll for zoom on desktop.
  ///
  /// When [FusionZoomConfiguration.requireModifierForWheelZoom] is `true`,
  /// users must hold Ctrl (Windows/Linux) or Cmd (macOS) while scrolling
  /// to zoom. This prevents interference with page scrolling on web.
  @override
  void handlePointerSignal(PointerSignalEvent event) {
    if (!config.enableZoom) return;
    if (!config.zoomBehavior.enableMouseWheelZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    if (event is PointerScrollEvent) {
      // Check if pointer is within chart area
      if (!_currentCoordSystem.chartArea.contains(event.localPosition)) {
        return;
      }

      // Check for modifier key requirement (Ctrl/Cmd + scroll to zoom)
      if (config.zoomBehavior.requireModifierForWheelZoom) {
        final hasModifier = FusionDesktopHelper.isControlPressed ||
            FusionDesktopHelper.isMetaPressed;
        if (!hasModifier) {
          // No modifier held - allow normal page scroll
          return;
        }
      }

      // Register with pointer signal resolver to consume the event.
      // This prevents the scroll from propagating to parent scrollables.
      GestureBinding.instance.pointerSignalResolver.register(
        event,
        (PointerSignalEvent resolvedEvent) {
          if (resolvedEvent is PointerScrollEvent) {
            final scaleFactor = _interactionHandler!.calculateMouseWheelZoom(
              resolvedEvent.scrollDelta.dy,
            );
            _applyZoom(scaleFactor, resolvedEvent.localPosition);
          }
        },
      );
    }
  }

  void _applyZoom(double scaleFactor, Offset focalPoint) {
    applyZoom(
      scaleFactor,
      focalPoint,
      _interactionHandler!,
      (value) => _hasActiveZoom = value,
    );
  }

  // ==========================================================================
  // TRACKBALL IMPLEMENTATION
  // ==========================================================================

  /// Last position used for trackball update threshold check.
  Offset? _lastTrackballPosition;

  void _updateTrackball(Offset position, FusionTooltipTrackballMode mode) {
    FusionDataPoint? targetPoint;
    Offset? magneticOffset; // For smooth magnetic effect

    switch (mode) {
      case FusionTooltipTrackballMode.none:
        return;

      case FusionTooltipTrackballMode.follow:
        // Follow mode: always show nearest point by Euclidean distance
        targetPoint = _interactionHandler?.findNearestPoint(
          _allDataPoints,
          position,
        );

      case FusionTooltipTrackballMode.snapToX:
        // Snap to X: find point with closest X coordinate (ideal for line charts)
        targetPoint = _interactionHandler?.findNearestPointByX(
          _allDataPoints,
          position,
        );

      case FusionTooltipTrackballMode.snapToY:
        // Snap to Y: find point with closest Y coordinate
        targetPoint = _interactionHandler?.findNearestPointByY(
          _allDataPoints,
          position,
        );

      case FusionTooltipTrackballMode.snap:
        // Snap mode: only update if within snap radius, otherwise keep last point
        final nearest = _interactionHandler?.findNearestPoint(
          _allDataPoints,
          position,
        );
        if (nearest != null) {
          final screenPos = _currentCoordSystem.dataToScreen(nearest);
          final distance = (screenPos - position).distance;
          if (distance < config.tooltipBehavior.trackballSnapRadius) {
            targetPoint = nearest;
          } else {
            // Keep current tooltip point if we have one
            if (_tooltipData != null) {
              return; // Don't update - keep showing current point
            }
            // If no current tooltip, show nearest anyway
            targetPoint = nearest;
          }
        }

      case FusionTooltipTrackballMode.magnetic:
        // Magnetic mode: smooth interpolation toward nearest point
        final result = _findMagneticTarget(position);
        targetPoint = result.point;
        magneticOffset = result.magneticOffset;
    }

    if (targetPoint != null) {
      _lastTrackballPosition = position;
      _updateTooltipPosition(
        targetPoint,
        position,
        magneticOffset: magneticOffset,
      );
    }
  }

  /// Finds magnetic target with smooth interpolation.
  ///
  /// Returns both the target point and an optional magnetic offset
  /// for smooth visual interpolation.
  ({FusionDataPoint? point, Offset? magneticOffset}) _findMagneticTarget(
    Offset position,
  ) {
    final nearest = _interactionHandler?.findNearestPoint(
      _allDataPoints,
      position,
    );

    if (nearest == null) return (point: null, magneticOffset: null);

    final screenPos = _currentCoordSystem.dataToScreen(nearest);
    final distance = (screenPos - position).distance;
    final snapRadius = config.tooltipBehavior.trackballSnapRadius;

    if (distance < snapRadius) {
      // Calculate magnetic pull strength (0.0 at edge, 1.0 at center)
      final magnetStrength = 1.0 - (distance / snapRadius);

      // Apply easing for smoother feel
      final easedStrength = magnetStrength * magnetStrength; // Quadratic easing

      // Interpolate position toward the point
      final magneticOffset = Offset(
        position.dx + (screenPos.dx - position.dx) * easedStrength,
        position.dy + (screenPos.dy - position.dy) * easedStrength,
      );

      return (point: nearest, magneticOffset: magneticOffset);
    }

    // Outside snap radius - no magnetic effect
    return (point: nearest, magneticOffset: null);
  }

  void _updateTooltipPosition(
    FusionDataPoint point,
    Offset position, {
    Offset? magneticOffset,
  }) {
    final seriesInfo = _findSeriesForPoint(point);

    // Use magnetic offset for marker position if provided,
    // otherwise snap to exact data point position
    final effectiveScreenPosition =
        magneticOffset ?? _currentCoordSystem.dataToScreen(point);

    // Find shared points if shared tooltip is enabled
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: effectiveScreenPosition,
      wasLongPress: _tooltipData?.wasLongPress ?? false,
      activationTime: _tooltipData?.activationTime,
      sharedPoints: sharedPoints,
    );

    notifyListeners();
  }

  // ==========================================================================
  // TOOLTIP SHOW/HIDE
  // ==========================================================================

  void _showTooltipWithDelay(
    FusionDataPoint point,
    Offset position,
    bool wasLongPress,
  ) {
    final delay = config.tooltipBehavior.activationDelay;

    if (delay == Duration.zero) {
      _showTooltipEnhanced(point, position, wasLongPress);
    } else {
      _tooltipShowTimer?.cancel();
      _tooltipShowTimer = Timer(delay, () {
        if (_isPointerDown) {
          _showTooltipEnhanced(point, position, wasLongPress);
        }
      });
    }
  }

  void _showTooltipEnhanced(
    FusionDataPoint point,
    Offset position,
    bool wasLongPress,
  ) {
    _tooltipHideTimer?.cancel();

    if (config.tooltipBehavior.hapticFeedback) {
      HapticFeedback.selectionClick();
    }

    final seriesInfo = _findSeriesForPoint(point);

    // Find shared points if shared tooltip is enabled
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: _currentCoordSystem.dataToScreen(point),
      wasLongPress: wasLongPress,
      activationTime: DateTime.now(),
      sharedPoints: sharedPoints,
    );

    _tooltipOpacity = 1.0;
    notifyListeners();

    if (!_isPointerDown && config.tooltipBehavior.shouldUseTimer()) {
      _startHideTimer(config.tooltipBehavior.getDismissDelay(wasLongPress));
    }
  }

  void _hideTooltipAnimated() {
    if (_tooltipData == null) return;

    _tooltipHideTimer?.cancel();
    _tooltipShowTimer?.cancel();

    _tooltipData = null;
    _tooltipOpacity = 0.0;
    notifyListeners();
  }

  void _startHideTimer(Duration delay) {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = Timer(delay, () {
      if (!_isPointerDown) {
        _hideTooltipAnimated();
      }
    });
  }

  void _showTooltip(FusionDataPoint point, Offset position) {
    final seriesInfo = _findSeriesForPoint(point);

    // Find shared points if shared tooltip is enabled
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: _currentCoordSystem.dataToScreen(point),
      sharedPoints: sharedPoints,
    );
    notifyListeners();

    // Auto-hide based on dismiss strategy
    if (config.tooltipBehavior.dismissStrategy != FusionDismissStrategy.never) {
      Future.delayed(config.tooltipBehavior.duration, _hideTooltip);
    }
  }

  SeriesWithDataPoints _findSeriesForPoint(FusionDataPoint point) {
    for (final s in series) {
      final exists = s.dataPoints.any((p) => p.x == point.x && p.y == point.y);
      if (exists) {
        return s;
      }
    }
    return series.first;
  }

  /// Finds all points at the same X coordinate across all series.
  /// Used for shared tooltip display.
  List<SharedTooltipPoint> _findPointsAtSameX(FusionDataPoint point) {
    final sharedPoints = <SharedTooltipPoint>[];
    const xTolerance = 0.001; // Small tolerance for floating point comparison

    for (final s in series) {
      if (!s.visible) continue;

      for (final p in s.dataPoints) {
        // Check if X coordinate matches (with tolerance)
        if ((p.x - point.x).abs() < xTolerance) {
          // Don't include the primary point
          if (p.x == point.x && p.y == point.y) continue;

          sharedPoints.add(
            SharedTooltipPoint(
              point: p,
              seriesName: s.name,
              seriesColor: s.color,
              screenPosition: _currentCoordSystem.dataToScreen(p),
            ),
          );
        }
      }
    }

    return sharedPoints;
  }

  void _hideTooltip() {
    if (_tooltipData != null) {
      _tooltipData = null;
      notifyListeners();
    }
  }

  void _showCrosshair(Offset position, FusionDataPoint? snappedPoint) {
    _crosshairHideTimer?.cancel();

    _crosshairPosition = position;
    _crosshairPoint = snappedPoint;
    notifyListeners();

    final behavior = config.crosshairBehavior;
    if (behavior.dismissStrategy != FusionDismissStrategy.never) {
      if (behavior.shouldUseTimer()) {
        _startCrosshairHideTimer(behavior.duration);
      }
    }
  }

  void _hideCrosshair() {
    if (_crosshairPosition != null) {
      _crosshairPosition = null;
      _crosshairPoint = null;
      notifyListeners();
    }
  }

  void _startCrosshairHideTimer(Duration delay) {
    _crosshairHideTimer?.cancel();
    _crosshairHideTimer = Timer(delay, _hideCrosshairAnimated);
  }

  void _hideCrosshairAnimated() {
    _crosshairHideTimer?.cancel();

    if (_crosshairPosition != null) {
      _crosshairPosition = null;
      _crosshairPoint = null;
      notifyListeners();
    }
  }

  // ==========================================================================
  // PAN HANDLING
  // ==========================================================================

  void _handlePanStart(Offset position) {
    if (!config.enablePanning) return;
    _isPanning = true;

    if (_tooltipData != null) {
      _tooltipData = null;
      _tooltipOpacity = 0.0;
      notifyListeners();
    }
  }

  void _handlePanUpdate(Offset delta) {
    if (!config.enablePanning || !_isPanning) return;

    final currentXMin = _currentCoordSystem.dataXMin;
    final currentXMax = _currentCoordSystem.dataXMax;
    final currentYMin = _currentCoordSystem.dataYMin;
    final currentYMax = _currentCoordSystem.dataYMax;

    final newBounds = _interactionHandler!.calculatePannedBounds(
      delta,
      currentXMin,
      currentXMax,
      currentYMin,
      currentYMax,
    );

    final originalXMin = _originalCoordSystem.dataXMin;
    final originalXMax = _originalCoordSystem.dataXMax;
    final originalYMin = _originalCoordSystem.dataYMin;
    final originalYMax = _originalCoordSystem.dataYMax;

    final constrainedBounds = _interactionHandler!.constrainBounds(
      newBounds.xMin,
      newBounds.xMax,
      newBounds.yMin,
      newBounds.yMax,
      originalXMin,
      originalXMax,
      originalYMin,
      originalYMax,
    );

    _currentCoordSystem = FusionCoordinateSystem(
      chartArea: _currentCoordSystem.chartArea,
      dataXMin: constrainedBounds.xMin,
      dataXMax: constrainedBounds.xMax,
      dataYMin: constrainedBounds.yMin,
      dataYMax: constrainedBounds.yMax,
      devicePixelRatio: _currentCoordSystem.devicePixelRatio,
    );

    notifyListeners();
  }

  void _handlePanEnd() {
    _isPanning = false;
    _rebuildInteractionHandler();
    notifyListeners();
  }

  // ==========================================================================
  // ZOOM HANDLING
  // ==========================================================================

  void _handleScaleStart(Offset focalPoint) {
    if (!config.enableZoom) return;
    if (!config.zoomBehavior.enablePinchZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    _isZooming = true;
    _lastScale = 1.0;

    if (_tooltipData != null) {
      _tooltipData = null;
      _tooltipOpacity = 0.0;
      notifyListeners();
    }
  }

  void _handleScaleUpdate(double scaleFactor, Offset focalPoint) {
    if (!config.enableZoom || !_isZooming) return;
    if (!config.zoomBehavior.enablePinchZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    _applyZoom(scaleFactor, focalPoint);
  }

  void _handleScaleEnd() {
    _isZooming = false;
    _rebuildInteractionHandler();
    notifyListeners();
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  @override
  void reset() {
    _currentCoordSystem = _originalCoordSystem;
    _hasActiveZoom = false;
    _hideTooltip();
    _hideCrosshair();
    notifyListeners();
  }

  // ==========================================================================
  // GESTURE RECOGNIZERS
  // ==========================================================================

  /// Computes a hash of configuration options that affect gesture behavior.
  /// Used to determine when gesture recognizers need to be recreated.
  int _computeGestureConfigHash() {
    return Object.hash(
      config.enableTooltip,
      config.enableSelection,
      config.enableCrosshair,
      config.enableZoom,
      config.enablePanning,
      config.zoomBehavior.enablePinchZoom,
      config.zoomBehavior.enableDoubleTapZoom,
      config.zoomBehavior.enableSelectionZoom,
      config.zoomBehavior.zoomMode,
    );
  }

  @override
  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    final currentHash = _computeGestureConfigHash();
    
    if (_cachedGestureRecognizers != null && _lastGestureConfigHash == currentHash) {
      return _cachedGestureRecognizers!;
    }

    final recognizers = <Type, GestureRecognizerFactory>{};

    if (config.enableTooltip || config.enableSelection) {
      recognizers[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            TapGestureRecognizer.new,
            (recognizer) {
              recognizer.onTapDown = (details) {
                _interactionHandler?.handleTapDown(
                  details.localPosition,
                  _allDataPoints,
                );
              };
            },
          );
    }
    
    // Double-tap to zoom in/reset
    if (config.enableZoom && config.zoomBehavior.enableDoubleTapZoom) {
      recognizers[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
            DoubleTapGestureRecognizer.new,
            (recognizer) {
              recognizer.onDoubleTapDown = (details) {
                _lastPointerPosition = details.localPosition;
              };
              recognizer.onDoubleTap = () {
                if (_lastPointerPosition != null) {
                  handleDoubleTapZoom(
                    _lastPointerPosition!,
                    hasActiveZoom: _hasActiveZoom,
                  );
                }
              };
            },
          );
    }

    if (config.enableCrosshair) {
      recognizers[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            LongPressGestureRecognizer.new,
            (recognizer) {
              recognizer
                ..onLongPressStart = (details) {
                  _interactionHandler?.handleLongPress(
                    details.localPosition,
                    _allDataPoints,
                  );
                }
                ..onLongPressMoveUpdate = (details) {
                  if (_crosshairPosition != null) {
                    _updateCrosshairPosition(details.localPosition);
                  }
                }
                ..onLongPressEnd = (details) {
                  final crosshairBehavior = config.crosshairBehavior;
                  if (crosshairBehavior.shouldDismissOnRelease()) {
                    final delay = crosshairBehavior.getDismissDelay(true);
                    if (delay == Duration.zero) {
                      _hideCrosshairAnimated();
                    } else {
                      _startCrosshairHideTimer(delay);
                    }
                  } else if (crosshairBehavior.shouldUseTimer()) {
                    _startCrosshairHideTimer(crosshairBehavior.duration);
                  }
                };
            },
          );
    }

    if (config.enableZoom && config.enablePanning) {
      recognizers[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            ScaleGestureRecognizer.new,
            (recognizer) {
              recognizer
                ..onStart = (details) {
                  _lastScaleFocalPoint = details.localFocalPoint;
                  _handleScaleStart(details.localFocalPoint);
                }
                ..onUpdate = (details) {
                  const scaleTolerance = 0.01;
                  final scaleChange = (details.scale - 1.0).abs();
                  if (scaleChange < scaleTolerance) {
                    if (!_isPanning) {
                      _handlePanStart(details.localFocalPoint);
                    }
                    if (_lastScaleFocalPoint != null) {
                      final delta =
                          details.localFocalPoint - _lastScaleFocalPoint!;
                      _handlePanUpdate(delta);
                    }
                    _lastScaleFocalPoint = details.localFocalPoint;
                  } else {
                    final scaleDelta = details.scale / _lastScale;
                    _lastScale = details.scale;
                    _handleScaleUpdate(scaleDelta, details.localFocalPoint);
                  }
                }
                ..onEnd = (details) {
                  if (_isPanning) {
                    _handlePanEnd();
                  }
                  if (_isZooming) {
                    _handleScaleEnd();
                  }
                  _lastScaleFocalPoint = null;
                  _lastScale = 1.0;
                };
            },
          );
    } else if (config.enablePanning) {
      // Pan only - use PanGestureRecognizer
      recognizers[PanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
            PanGestureRecognizer.new,
            (recognizer) {
              recognizer
                ..onStart = (details) {
                  _interactionHandler?.handlePanStart(details.localPosition);
                }
                ..onUpdate = (details) {
                  _interactionHandler?.handlePanUpdate(details.delta);
                }
                ..onEnd = (details) {
                  _interactionHandler?.handlePanEnd();
                };
            },
          );
    } else if (config.enableZoom) {
      // Zoom only - use ScaleGestureRecognizer for pinch
      recognizers[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            ScaleGestureRecognizer.new,
            (recognizer) {
              recognizer
                ..onStart = (details) {
                  _handleScaleStart(details.localFocalPoint);
                }
                ..onUpdate = (details) {
                  if (details.scale != 1.0) {
                    final scaleDelta = details.scale / _lastScale;
                    _lastScale = details.scale;
                    _handleScaleUpdate(scaleDelta, details.localFocalPoint);
                  }
                }
                ..onEnd = (details) {
                  _handleScaleEnd();
                  _lastScale = 1.0;
                };
            },
          );
    }

    _cachedGestureRecognizers = recognizers;
    _lastGestureConfigHash = currentHash;

    return recognizers;
  }

  @override
  void dispose() {
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();
    _debounceTimer?.cancel();
    _crosshairHideTimer?.cancel();
    disposeZoomAnimation();
    _interactionHandler = null;
    super.dispose();
  }
}

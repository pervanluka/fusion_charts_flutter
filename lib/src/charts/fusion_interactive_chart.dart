import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_tooltip_configuration.dart';
import '../core/enums/fusion_dismiss_strategy.dart';
import '../core/enums/fusion_tooltip_trackball_mode.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_interaction_handler.dart';
import '../series/series_with_data_points.dart';

/// State manager for interactive chart features.
///
///  Works with ANY series type that implements SeriesWithDataPoints.
///
///  Scales to infinite chart types without modification.
class FusionInteractiveChartState extends ChangeNotifier {
  FusionInteractiveChartState({
    required this.config,
    required FusionCoordinateSystem initialCoordSystem,
    required this.series,
  }) : _currentCoordSystem = initialCoordSystem,
       _originalCoordSystem = initialCoordSystem;

  final FusionChartConfiguration config;

  /// All series - works with Line, Bar, Area, Pie, Scatter, etc.
  final List<SeriesWithDataPoints> series;

  final FusionCoordinateSystem _originalCoordSystem;
  FusionCoordinateSystem _currentCoordSystem;
  FusionInteractionHandler? _interactionHandler;

  // Tooltip state
  TooltipRenderData? _tooltipData;

  bool _isPointerDown = false; // Track finger state
  DateTime? _pointerDownTime; // Track press duration
  // ignore: unused_field
  Offset? _lastPointerPosition; // Track movement (used in trackball - will be fully utilized later)

  // Timer management (preventing memory leaks)
  Timer? _tooltipShowTimer;
  Timer? _tooltipHideTimer;
  Timer? _debounceTimer;

  // Animation state
  double _tooltipOpacity = 0.0;
  // ignore: unused_field
  bool _isAnimatingIn = false; // Will be used for smooth animations
  // ignore: unused_field
  bool _isAnimatingOut = false; // Will be used for smooth animations

  // Crosshair state
  Offset? _crosshairPosition;
  FusionDataPoint? _crosshairPoint;
  Timer? _crosshairHideTimer;

  // Zoom/Pan state
  bool _isPanning = false;
  bool _isZooming = false;

  // Getters
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;
  TooltipRenderData? get tooltipData => _tooltipData;
  Offset? get crosshairPosition => _crosshairPosition;
  FusionDataPoint? get crosshairPoint => _crosshairPoint;
  bool get isInteracting => _isPanning || _isZooming;

  // Enhanced getters
  double get tooltipOpacity => _tooltipOpacity;
  bool get isPointerDown => _isPointerDown;

  /// âœ… Get all data points from all series (works with ANY series type!)
  List<FusionDataPoint> get _allDataPoints {
    return series
        .where((s) => s.visible) // Only visible series
        .expand((s) => s.dataPoints) // Flatten all data points
        .toList();
  }

  void initialize() {
    _interactionHandler = FusionInteractionHandler(
      coordSystem: _currentCoordSystem,
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

  // ========================================================================
  // TAP & HOVER HANDLING
  // ========================================================================

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

    final nearestPoint = _interactionHandler?.findNearestPoint(_allDataPoints, position);

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

  // ========================================================================
  // 🏆 ENHANCED POINTER EVENT HANDLERS - The Key to Superior UX!
  // ========================================================================

  /// Handle pointer down - COMPLETE LIFECYCLE TRACKING
  void handlePointerDown(PointerDownEvent event) {
    _isPointerDown = true;
    _pointerDownTime = DateTime.now();
    _lastPointerPosition = event.localPosition;

    // Cancel any pending timers
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();

    if (!config.enableTooltip) return;

    final point = _interactionHandler?.findNearestPoint(_allDataPoints, event.localPosition);

    if (point != null) {
      // For now, always show on tap (we'll add mode detection later)
      _showTooltipWithDelay(point, event.localPosition, false);
    }
  }

  /// Handle pointer move - TRACKBALL SUPPORT
  void handlePointerMove(PointerMoveEvent event) {
    if (!_isPointerDown || !config.enableTooltip) return;

    _lastPointerPosition = event.localPosition;

    final trackballMode = config.tooltipBehavior.trackballMode;

    if (trackballMode == FusionTooltipTrackballMode.none) return;

    // Check movement threshold to reduce update frequency
    if (_tooltipData != null) {
      final distance = (event.localPosition - _tooltipData!.screenPosition).distance;
      if (distance < config.tooltipBehavior.trackballUpdateThreshold) {
        return; // Too small movement, skip update
      }
    }

    // Debounce updates for performance (~60 FPS)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 16),
      () => _updateTrackball(event.localPosition, trackballMode),
    );
  }

  /// Handle pointer up - SMART DISMISSAL (THE KEY FEATURE!)
  void handlePointerUp(PointerUpEvent event) {
    _isPointerDown = false;

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
      // else: never dismiss automatically
    }

    _pointerDownTime = null;
  }

  /// Handle pointer cancel - IMMEDIATE CLEANUP
  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _lastPointerPosition = null;

    // Always hide on cancel
    _hideTooltipAnimated();
    _hideCrosshair();
  }

  /// Handle hover - DESKTOP SUPPORT
  void handlePointerHover(PointerHoverEvent event) {
    if (!config.enableTooltip) return;

    // For now, treat hover like tap
    // We'll add platform detection later
    final point = _interactionHandler?.findNearestPoint(_allDataPoints, event.localPosition);

    if (point != null) {
      _showTooltipWithDelay(point, event.localPosition, false);
    } else {
      _hideTooltipAnimated();
    }
  }

  // ========================================================================
  // 🚀 TRACKBALL IMPLEMENTATION
  // ========================================================================

  void _updateTrackball(Offset position, FusionTooltipTrackballMode mode) {
    FusionDataPoint? targetPoint;

    switch (mode) {
      case FusionTooltipTrackballMode.none:
        return;

      case FusionTooltipTrackballMode.follow:
        // Just find nearest point
        targetPoint = _interactionHandler?.findNearestPoint(_allDataPoints, position);
        break;

      case FusionTooltipTrackballMode.snap:
        // Snap to nearest within radius
        final nearest = _interactionHandler?.findNearestPoint(_allDataPoints, position);
        if (nearest != null) {
          final screenPos = _currentCoordSystem.dataToScreen(nearest);
          final distance = (screenPos - position).distance;
          if (distance < config.tooltipBehavior.trackballSnapRadius) {
            targetPoint = nearest;
          }
        }
        break;

      case FusionTooltipTrackballMode.magnetic:
        // Smooth magnetic snapping with interpolation
        targetPoint = _findMagneticTarget(position);
        break;
    }

    if (targetPoint != null) {
      _updateTooltipPosition(targetPoint, position);
    }
  }

  FusionDataPoint? _findMagneticTarget(Offset position) {
    final nearest = _interactionHandler?.findNearestPoint(_allDataPoints, position);

    if (nearest == null) return null;

    final screenPos = _currentCoordSystem.dataToScreen(nearest);
    final distance = (screenPos - position).distance;
    final snapRadius = config.tooltipBehavior.trackballSnapRadius;

    // Magnetic effect: stronger pull as you get closer
    if (distance < snapRadius) {
      final magnetStrength = 1.0 - (distance / snapRadius);

      // Smooth interpolation (stronger magnetic effect when closer)
      if (magnetStrength > 0.7) {
        return nearest; // Strong snap
      }
    }

    return nearest;
  }

  void _updateTooltipPosition(FusionDataPoint point, Offset position) {
    final seriesInfo = _findSeriesForPoint(point);

    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: _currentCoordSystem.dataToScreen(point),
      wasLongPress: _tooltipData?.wasLongPress ?? false,
      activationTime: _tooltipData?.activationTime,
    );

    notifyListeners();
  }

  // ========================================================================
  // 🚀 TOOLTIP SHOW/HIDE LOGIC
  // ========================================================================

  void _showTooltipWithDelay(FusionDataPoint point, Offset position, bool wasLongPress) {
    final delay = config.tooltipBehavior.activationDelay;

    if (delay == Duration.zero) {
      _showTooltipEnhanced(point, position, wasLongPress);
    } else {
      _tooltipShowTimer?.cancel();
      _tooltipShowTimer = Timer(delay, () {
        if (_isPointerDown) {
          // Only show if pointer still down
          _showTooltipEnhanced(point, position, wasLongPress);
        }
      });
    }
  }

  void _showTooltipEnhanced(FusionDataPoint point, Offset position, bool wasLongPress) {
    // Cancel any hide timers
    _tooltipHideTimer?.cancel();

    // Haptic feedback
    if (config.tooltipBehavior.hapticFeedback) {
      HapticFeedback.selectionClick();
    }

    // Find series info
    final seriesInfo = _findSeriesForPoint(point);

    // Create tooltip data
    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: _currentCoordSystem.dataToScreen(point),
      wasLongPress: wasLongPress,
      activationTime: DateTime.now(),
    );

    // Set full opacity immediately (animation can be added later)
    _tooltipOpacity = 1.0;
    _isAnimatingIn = false;
    notifyListeners();

    // Start hide timer if needed and pointer not down
    if (!_isPointerDown && config.tooltipBehavior.shouldUseTimer()) {
      _startHideTimer(config.tooltipBehavior.getDismissDelay(wasLongPress));
    }
  }

  void _hideTooltipAnimated() {
    if (_tooltipData == null) return;

    _tooltipHideTimer?.cancel();
    _tooltipShowTimer?.cancel();

    // Immediate hide for now (smooth animation can be added later)
    _tooltipData = null;
    _tooltipOpacity = 0.0;
    _isAnimatingOut = false;
    notifyListeners();
  }

  void _startHideTimer(Duration delay) {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = Timer(delay, () {
      if (!_isPointerDown) {
        // Double check pointer not down
        _hideTooltipAnimated();
      }
    });
  }

  // ========================================================================
  // LEGACY METHODS (Keep for backwards compatibility)
  // ========================================================================

  void _showTooltip(FusionDataPoint point, Offset position) {
    // âœ… Find which series this point belongs to
    final seriesInfo = _findSeriesForPoint(point);

    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: _currentCoordSystem.dataToScreen(point),
    );
    notifyListeners();

    // Auto-hide after duration
    if (!config.tooltipBehavior.shouldAlwaysShow) {
      Future.delayed(config.tooltipBehavior.duration, () {
        _hideTooltip();
      });
    }
  }

  /// CLEAN: Single loop works for ALL series types
  SeriesWithDataPoints _findSeriesForPoint(FusionDataPoint point) {
    for (final s in series) {
      // Check if this point exists in this series
      final exists = s.dataPoints.any((p) => p.x == point.x && p.y == point.y);

      if (exists) {
        return s;
      }
    }

    // Fallback (shouldn't happen)
    return series.first;
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

    // Auto-hide based on strategy (only if not 'never')
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
    _crosshairHideTimer = Timer(delay, () {
      _hideCrosshairAnimated();
    });
  }

  void _hideCrosshairAnimated() {
    _crosshairHideTimer?.cancel();

    if (_crosshairPosition != null) {
      _crosshairPosition = null;
      _crosshairPoint = null;
      notifyListeners();
    }
  }

  // ========================================================================
  // PAN HANDLING (unchanged)
  // ========================================================================

  void _handlePanStart(Offset position) {
    if (!config.enablePanning) return;
    _isPanning = true;

    // 🚀 Fade out tooltip during pan if enabled
    if (config.tooltipBehavior.fadeOutOnPanZoom && _tooltipData != null) {
      _tooltipOpacity = 0.3; // Partial fade
    }

    notifyListeners();
  }

  void _handlePanUpdate(Offset delta) {
    if (!config.enablePanning || !_isPanning) return;

    // Extract individual bounds from current coordinate system
    final currentXMin = _currentCoordSystem.dataXMin;
    final currentXMax = _currentCoordSystem.dataXMax;
    final currentYMin = _currentCoordSystem.dataYMin;
    final currentYMax = _currentCoordSystem.dataYMax;

    // Calculate panned bounds (returns named tuple)
    final newBounds = _interactionHandler!.calculatePannedBounds(
      delta, // âœ… POSITIONAL parameter
      currentXMin,
      currentXMax,
      currentYMin,
      currentYMax,
    );

    // Extract original bounds
    final originalXMin = _originalCoordSystem.dataXMin;
    final originalXMax = _originalCoordSystem.dataXMax;
    final originalYMin = _originalCoordSystem.dataYMin;
    final originalYMax = _originalCoordSystem.dataYMax;

    // Constrain bounds (returns named tuple)
    final constrainedBounds = _interactionHandler!.constrainBounds(
      newBounds.xMin, // âœ… POSITIONAL parameters
      newBounds.xMax,
      newBounds.yMin,
      newBounds.yMax,
      originalXMin,
      originalXMax,
      originalYMin,
      originalYMax,
    );

    // Update coordinate system using named tuple
    _currentCoordSystem = FusionCoordinateSystem(
      chartArea: _currentCoordSystem.chartArea,
      dataXMin: constrainedBounds.xMin,
      dataXMax: constrainedBounds.xMax,
      dataYMin: constrainedBounds.yMin,
      dataYMax: constrainedBounds.yMax,
    );

    notifyListeners();
  }

  void _handlePanEnd() {
    _isPanning = false;

    // 🚀 Restore tooltip opacity
    if (_tooltipData != null) {
      _tooltipOpacity = 1.0;
    }

    notifyListeners();
  }

  // ========================================================================
  // ZOOM HANDLING (unchanged)
  // ========================================================================

  void _handleScaleStart(Offset focalPoint) {
    if (!config.enableZoom) return;
    _isZooming = true;

    // 🚀 Fade tooltip during zoom
    if (config.tooltipBehavior.fadeOutOnPanZoom && _tooltipData != null) {
      _tooltipOpacity = 0.3;
    }

    notifyListeners();
  }

  void _handleScaleUpdate(double scaleFactor, Offset focalPoint) {
    if (!config.enableZoom || !_isZooming) return;

    // Extract current bounds
    final currentXMin = _currentCoordSystem.dataXMin;
    final currentXMax = _currentCoordSystem.dataXMax;
    final currentYMin = _currentCoordSystem.dataYMin;
    final currentYMax = _currentCoordSystem.dataYMax;

    // Calculate zoomed bounds (returns named tuple)
    final newBounds = _interactionHandler!.calculateZoomedBounds(
      scaleFactor, // âœ… POSITIONAL parameters
      focalPoint,
      currentXMin,
      currentXMax,
      currentYMin,
      currentYMax,
    );

    // Extract original bounds for constraints
    final originalXMin = _originalCoordSystem.dataXMin;
    final originalXMax = _originalCoordSystem.dataXMax;
    final originalYMin = _originalCoordSystem.dataYMin;
    final originalYMax = _originalCoordSystem.dataYMax;

    // Constrain bounds (returns named tuple)
    final constrainedBounds = _interactionHandler!.constrainBounds(
      newBounds.xMin, // âœ… POSITIONAL parameters
      newBounds.xMax,
      newBounds.yMin,
      newBounds.yMax,
      originalXMin,
      originalXMax,
      originalYMin,
      originalYMax,
    );

    // Update coordinate system using named tuple
    _currentCoordSystem = FusionCoordinateSystem(
      chartArea: _currentCoordSystem.chartArea,
      dataXMin: constrainedBounds.xMin,
      dataXMax: constrainedBounds.xMax,
      dataYMin: constrainedBounds.yMin,
      dataYMax: constrainedBounds.yMax,
    );

    notifyListeners();
  }

  void _handleScaleEnd() {
    _isZooming = false;

    // 🚀 Restore opacity
    if (_tooltipData != null) {
      _tooltipOpacity = 1.0;
    }

    notifyListeners();
  }

  // ========================================================================
  // RESET (unchanged)
  // ========================================================================

  void reset() {
    _currentCoordSystem = _originalCoordSystem;
    _hideTooltip();
    _hideCrosshair();
    notifyListeners();
  }

  // ========================================================================
  // GESTURE RECOGNIZERS (unchanged)
  // ========================================================================

  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    final recognizers = <Type, GestureRecognizerFactory>{};

    if (config.enableTooltip || config.enableSelection) {
      recognizers[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(() => TapGestureRecognizer(), (
            recognizer,
          ) {
            recognizer.onTapDown = (details) {
              _interactionHandler?.handleTapDown(details.localPosition, _allDataPoints);
            };
          });
    }

    if (config.enableCrosshair) {
      recognizers[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(),
            (recognizer) {
              recognizer.onLongPressStart = (details) {
                _interactionHandler?.handleLongPress(details.localPosition, _allDataPoints);
              };
            },
          );
    }

    if (config.enableZoom && config.enablePanning) {
      recognizers[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(),
            (recognizer) {
              recognizer
                ..onStart = (details) {
                  _interactionHandler?.handleScaleStart(details.localFocalPoint);
                }
                ..onUpdate = (details) {
                  _interactionHandler?.handleScaleUpdate(details.scale, details.localFocalPoint);
                }
                ..onEnd = (details) {
                  _interactionHandler?.handleScaleEnd();
                };
            },
          );
    } else if (config.enablePanning) {
      recognizers[PanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(() => PanGestureRecognizer(), (
            recognizer,
          ) {
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
          });
    }

    return recognizers;
  }

  @override
  void dispose() {
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();
    _debounceTimer?.cancel();
    _interactionHandler = null;
    super.dispose();
  }
}

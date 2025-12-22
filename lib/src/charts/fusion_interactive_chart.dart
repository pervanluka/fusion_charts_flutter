import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_tooltip_configuration.dart';
import '../core/enums/fusion_dismiss_strategy.dart';
import '../core/enums/fusion_tooltip_trackball_mode.dart';
import '../core/enums/fusion_zoom_mode.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_interaction_handler.dart';
import '../series/series_with_data_points.dart';

/// State manager for interactive chart features.
///
/// Works with ANY series type that implements SeriesWithDataPoints.
/// Scales to infinite chart types without modification.
class FusionInteractiveChartState extends ChangeNotifier {
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

  // Getters
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;
  TooltipRenderData? get tooltipData => _tooltipData;
  Offset? get crosshairPosition => _crosshairPosition;
  FusionDataPoint? get crosshairPoint => _crosshairPoint;
  bool get isInteracting => _isPanning || _isZooming;
  double get tooltipOpacity => _tooltipOpacity;
  bool get isPointerDown => _isPointerDown;

  /// Updates the coordinate system when chart dimensions change.
  /// 
  /// IMPORTANT: Always updates without comparison to ensure
  /// the painter always has the correct bounds.
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {
    // Always update - the comparison was causing issues where
    // placeholder values persisted
    _currentCoordSystem = newCoordSystem;
    _rebuildInteractionHandler();
  }

  List<FusionDataPoint> get _allDataPoints {
    return series.where((s) => s.visible).expand((s) => s.dataPoints).toList();
  }

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

  // ==========================================================================
  // POINTER EVENT HANDLERS
  // ==========================================================================

  void handlePointerDown(PointerDownEvent event) {
    _isPointerDown = true;
    _pointerDownTime = DateTime.now();
    _lastPointerPosition = event.localPosition;

    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();

    if (!config.enableTooltip) return;

    final point = _interactionHandler?.findNearestPoint(_allDataPoints, event.localPosition);

    if (point != null) {
      _showTooltipWithDelay(point, event.localPosition, false);
    }
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (!_isPointerDown) return;

    _lastPointerPosition = event.localPosition;

    // Update crosshair if active (during long press drag)
    if (config.enableCrosshair && _crosshairPosition != null) {
      _updateCrosshairPosition(event.localPosition);
    }

    // Update tooltip trackball if enabled
    if (config.enableTooltip) {
      final trackballMode = config.tooltipBehavior.trackballMode;
      if (trackballMode == FusionTooltipTrackballMode.none) return;

      if (_tooltipData != null) {
        final distance = (event.localPosition - _tooltipData!.screenPosition).distance;
        if (distance < config.tooltipBehavior.trackballUpdateThreshold) {
          return;
        }
      }

      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(milliseconds: 16),
        () => _updateTrackball(event.localPosition, trackballMode),
      );
    }
  }

  /// Updates crosshair position and finds nearest data point.
  void _updateCrosshairPosition(Offset position) {
    // Cancel any pending hide timer while dragging
    _crosshairHideTimer?.cancel();

    final dataX = _currentCoordSystem.screenXToDataX(position.dx);
    final dataY = _currentCoordSystem.screenYToDataY(position.dy);

    final clampedDataX = dataX.clamp(_currentCoordSystem.dataXMin, _currentCoordSystem.dataXMax);
    final clampedDataY = dataY.clamp(_currentCoordSystem.dataYMin, _currentCoordSystem.dataYMax);

    final clampedPosition = Offset(
      _currentCoordSystem.dataXToScreenX(clampedDataX),
      _currentCoordSystem.dataYToScreenY(clampedDataY),
    );

    // Find nearest point at clamped position
    final nearestPoint = _interactionHandler?.findNearestPoint(_allDataPoints, clampedPosition);

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
    }

    _pointerDownTime = null;
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _lastPointerPosition = null;

    _hideTooltipAnimated();
    _hideCrosshair();
  }

  void handlePointerHover(PointerHoverEvent event) {
    if (!config.enableTooltip) return;

    final point = _interactionHandler?.findNearestPoint(_allDataPoints, event.localPosition);

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
  void handlePointerSignal(PointerSignalEvent event) {
    if (!config.enableZoom) return;
    if (!config.zoomBehavior.enableMouseWheelZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    if (event is PointerScrollEvent) {
      // Check if pointer is within chart area
      if (!_currentCoordSystem.chartArea.contains(event.localPosition)) {
        return;
      }

      final scaleFactor = _interactionHandler!.calculateMouseWheelZoom(event.scrollDelta.dy);

      // Apply zoom
      _applyZoom(scaleFactor, event.localPosition);
    }
  }

  void _applyZoom(double scaleFactor, Offset focalPoint) {
    final currentXMin = _currentCoordSystem.dataXMin;
    final currentXMax = _currentCoordSystem.dataXMax;
    final currentYMin = _currentCoordSystem.dataYMin;
    final currentYMax = _currentCoordSystem.dataYMax;

    final newBounds = _interactionHandler!.calculateZoomedBounds(
      scaleFactor,
      focalPoint,
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

  // ==========================================================================
  // TRACKBALL IMPLEMENTATION
  // ==========================================================================

  void _updateTrackball(Offset position, FusionTooltipTrackballMode mode) {
    FusionDataPoint? targetPoint;

    switch (mode) {
      case FusionTooltipTrackballMode.none:
        return;

      case FusionTooltipTrackballMode.follow:
        targetPoint = _interactionHandler?.findNearestPoint(_allDataPoints, position);
        break;

      case FusionTooltipTrackballMode.snap:
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

    if (distance < snapRadius) {
      final magnetStrength = 1.0 - (distance / snapRadius);
      if (magnetStrength > 0.7) {
        return nearest;
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

  // ==========================================================================
  // TOOLTIP SHOW/HIDE
  // ==========================================================================

  void _showTooltipWithDelay(FusionDataPoint point, Offset position, bool wasLongPress) {
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

  void _showTooltipEnhanced(FusionDataPoint point, Offset position, bool wasLongPress) {
    _tooltipHideTimer?.cancel();

    if (config.tooltipBehavior.hapticFeedback) {
      HapticFeedback.selectionClick();
    }

    final seriesInfo = _findSeriesForPoint(point);

    // Find shared points if shared tooltip is enabled
    final sharedPoints = config.tooltipBehavior.shared ? _findPointsAtSameX(point) : null;

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
    final sharedPoints = config.tooltipBehavior.shared ? _findPointsAtSameX(point) : null;

    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: _currentCoordSystem.dataToScreen(point),
      sharedPoints: sharedPoints,
    );
    notifyListeners();

    if (!config.tooltipBehavior.shouldAlwaysShow) {
      Future.delayed(config.tooltipBehavior.duration, () {
        _hideTooltip();
      });
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

  // ==========================================================================
  // PAN HANDLING
  // ==========================================================================

  void _handlePanStart(Offset position) {
    if (!config.enablePanning) return;
    _isPanning = true;

    if (config.tooltipBehavior.fadeOutOnPanZoom && _tooltipData != null) {
      _tooltipOpacity = 0.3;
    }

    notifyListeners();
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

    if (_tooltipData != null) {
      _tooltipOpacity = 1.0;
    }

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

    if (config.tooltipBehavior.fadeOutOnPanZoom && _tooltipData != null) {
      _tooltipOpacity = 0.3;
    }

    notifyListeners();
  }

  void _handleScaleUpdate(double scaleFactor, Offset focalPoint) {
    if (!config.enableZoom || !_isZooming) return;
    if (!config.zoomBehavior.enablePinchZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    _applyZoom(scaleFactor, focalPoint);
  }

  void _handleScaleEnd() {
    _isZooming = false;

    if (_tooltipData != null) {
      _tooltipOpacity = 1.0;
    }

    notifyListeners();
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void reset() {
    _currentCoordSystem = _originalCoordSystem;
    _hideTooltip();
    _hideCrosshair();
    notifyListeners();
  }

  // ==========================================================================
  // GESTURE RECOGNIZERS
  // ==========================================================================

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
              recognizer
                ..onLongPressStart = (details) {
                  _interactionHandler?.handleLongPress(details.localPosition, _allDataPoints);
                }
                ..onLongPressMoveUpdate = (details) {
                  // Update crosshair position during drag
                  if (_crosshairPosition != null) {
                    _updateCrosshairPosition(details.localPosition);
                  }
                }
                ..onLongPressEnd = (details) {
                  // Handle crosshair hide based on dismiss strategy
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

    // Use ScaleGestureRecognizer when both zoom and pan are enabled (handles pinch + drag)
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
                  // Scale == 1.0 means no pinch, just pan
                  if (details.scale == 1.0) {
                    // This is a pan gesture disguised as scale
                    if (!_isPanning) {
                      _handlePanStart(details.localFocalPoint);
                    }
                    // Calculate delta from focal point movement
                    if (_lastPointerPosition != null) {
                      final delta = details.localFocalPoint - _lastPointerPosition!;
                      _handlePanUpdate(delta);
                    }
                    _lastPointerPosition = details.localFocalPoint;
                  } else {
                    // Actual pinch zoom
                    _interactionHandler?.handleScaleUpdate(details.scale, details.localFocalPoint);
                  }
                }
                ..onEnd = (details) {
                  if (_isPanning) {
                    _handlePanEnd();
                  }
                  if (_isZooming) {
                    _interactionHandler?.handleScaleEnd();
                  }
                  _lastPointerPosition = null;
                };
            },
          );
    } else if (config.enablePanning) {
      // Pan only - use PanGestureRecognizer
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
    } else if (config.enableZoom) {
      // Zoom only - use ScaleGestureRecognizer for pinch
      recognizers[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(),
            (recognizer) {
              recognizer
                ..onStart = (details) {
                  _interactionHandler?.handleScaleStart(details.localFocalPoint);
                }
                ..onUpdate = (details) {
                  if (details.scale != 1.0) {
                    _interactionHandler?.handleScaleUpdate(details.scale, details.localFocalPoint);
                  }
                }
                ..onEnd = (details) {
                  _interactionHandler?.handleScaleEnd();
                };
            },
          );
    }

    return recognizers;
  }

  @override
  void dispose() {
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();
    _debounceTimer?.cancel();
    _crosshairHideTimer?.cancel();
    _interactionHandler = null;
    super.dispose();
  }
}

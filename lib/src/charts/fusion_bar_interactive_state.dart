import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import '../rendering/fusion_bar_hit_tester.dart';
import '../rendering/fusion_interaction_handler.dart';
import 'base/fusion_interactive_state_base.dart';

/// Specialized interactive state for bar charts.
///
/// Unlike the generic interactive state that finds nearest points by distance,
/// this uses rectangle-based hit testing for accurate bar selection.
/// Also supports zoom and pan with configuration-aware constraints.
class FusionBarInteractiveState extends ChangeNotifier implements FusionInteractiveStateBase {
  FusionBarInteractiveState({
    required this.config,
    required FusionCoordinateSystem initialCoordSystem,
    required this.series,
    this.enableSideBySideSeriesPlacement = true,
  }) : _currentCoordSystem = initialCoordSystem,
       _originalCoordSystem = initialCoordSystem;

  final FusionChartConfiguration config;
  final List<FusionBarSeries> series;
  final bool enableSideBySideSeriesPlacement;

  FusionCoordinateSystem _currentCoordSystem;
  final FusionCoordinateSystem _originalCoordSystem;
  final FusionBarHitTester _hitTester = const FusionBarHitTester();
  FusionInteractionHandler? _interactionHandler;

  // Tooltip state
  TooltipRenderData? _tooltipData;
  double _tooltipOpacity = 0.0;

  // Crosshair state
  Offset? _crosshairPosition;
  FusionDataPoint? _crosshairPoint;

  // Pointer state
  bool _isPointerDown = false;
  DateTime? _pointerDownTime;
  Offset? _lastPointerPosition;

  // Zoom/Pan state
  bool _isPanning = false;
  bool _isZooming = false;

  // Timers
  Timer? _tooltipHideTimer;
  Timer? _crosshairHideTimer;

  // Getters
  @override
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;
  @override
  TooltipRenderData? get tooltipData => _tooltipData;
  @override
  double get tooltipOpacity => _tooltipOpacity;
  @override
  Offset? get crosshairPosition => _crosshairPosition;
  @override
  FusionDataPoint? get crosshairPoint => _crosshairPoint;
  @override
  bool get isInteracting => _isPanning || _isZooming;
  @override
  bool get isPointerDown => _isPointerDown;

  @override
  void initialize() {
    _rebuildInteractionHandler();
  }

  void _rebuildInteractionHandler() {
    _interactionHandler = FusionInteractionHandler(
      coordSystem: _currentCoordSystem,
      zoomConfig: config.zoomBehavior,
      panConfig: config.panBehavior,
    );
  }

  /// Updates the coordinate system when chart dimensions change.
  /// Always updates without comparison to ensure proper responsiveness.
  @override
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {
    _currentCoordSystem = newCoordSystem;
    _rebuildInteractionHandler();
  }

  // ========================================================================
  // POINTER EVENT HANDLERS
  // ========================================================================

  @override
  void handlePointerDown(PointerDownEvent event) {
    _isPointerDown = true;
    _pointerDownTime = DateTime.now();
    _lastPointerPosition = event.localPosition;
    _tooltipHideTimer?.cancel();

    if (!config.enableTooltip) return;

    final hitResult = _hitTester.hitTest(
      screenPosition: event.localPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null) {
      _showTooltip(hitResult, event.localPosition);
    } else {
      _hideTooltip();
    }
  }

  @override
  void handlePointerMove(PointerMoveEvent event) {
    if (!_isPointerDown) return;

    _lastPointerPosition = event.localPosition;

    if (!config.enableTooltip) return;

    final hitResult = _hitTester.hitTest(
      screenPosition: event.localPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null) {
      _showTooltip(hitResult, event.localPosition);
    } else {
      _hideTooltip();
    }
  }

  @override
  void handlePointerUp(PointerUpEvent event) {
    _isPointerDown = false;

    final pressDuration = _pointerDownTime != null
        ? DateTime.now().difference(_pointerDownTime!)
        : Duration.zero;
    final wasLongPress = pressDuration.inMilliseconds > 500;

    if (config.enableTooltip && _tooltipData != null) {
      final delay = config.tooltipBehavior.getDismissDelay(wasLongPress);
      if (delay == Duration.zero) {
        _hideTooltip();
      } else {
        _startHideTimer(delay);
      }
    }

    if (config.enableCrosshair && _crosshairPosition != null) {
      _hideCrosshair();
    }

    _pointerDownTime = null;
    _lastPointerPosition = null;
  }

  @override
  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _lastPointerPosition = null;
    _hideTooltip();
    _hideCrosshair();
  }

  @override
  void handlePointerHover(PointerHoverEvent event) {
    if (!config.enableTooltip) return;

    final hitResult = _hitTester.hitTest(
      screenPosition: event.localPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null) {
      _showTooltip(hitResult, event.localPosition);
    } else {
      _hideTooltip();
    }
  }

  // ========================================================================
  // MOUSE WHEEL ZOOM (Desktop Support)
  // ========================================================================

  @override
  void handlePointerSignal(PointerSignalEvent event) {
    if (!config.enableZoom) return;
    if (!config.zoomBehavior.enableMouseWheelZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    if (event is PointerScrollEvent) {
      if (!_currentCoordSystem.chartArea.contains(event.localPosition)) {
        return;
      }

      final scaleFactor = _interactionHandler!.calculateMouseWheelZoom(event.scrollDelta.dy);
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

  // ========================================================================
  // PAN HANDLING
  // ========================================================================

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

    final newBounds = _interactionHandler!.calculatePannedBounds(
      delta,
      _currentCoordSystem.dataXMin,
      _currentCoordSystem.dataXMax,
      _currentCoordSystem.dataYMin,
      _currentCoordSystem.dataYMax,
    );

    final constrainedBounds = _interactionHandler!.constrainBounds(
      newBounds.xMin,
      newBounds.xMax,
      newBounds.yMin,
      newBounds.yMax,
      _originalCoordSystem.dataXMin,
      _originalCoordSystem.dataXMax,
      _originalCoordSystem.dataYMin,
      _originalCoordSystem.dataYMax,
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

  // ========================================================================
  // ZOOM HANDLING
  // ========================================================================

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

  // ========================================================================
  // RESET
  // ========================================================================

  void reset() {
    _currentCoordSystem = _originalCoordSystem;
    _hideTooltip();
    _hideCrosshair();
    notifyListeners();
  }

  // ========================================================================
  // TOOLTIP MANAGEMENT
  // ========================================================================

  void _showTooltip(BarHitTestResult hitResult, Offset pointerPosition) {
    _tooltipHideTimer?.cancel();

    if (config.tooltipBehavior.hapticFeedback && _tooltipData == null) {
      HapticFeedback.selectionClick();
    }

    final tooltipPosition = Offset(hitResult.barRect.center.dx, hitResult.barRect.top);

    _tooltipData = TooltipRenderData(
      point: hitResult.point,
      seriesName: hitResult.seriesName,
      seriesColor: hitResult.seriesColor,
      screenPosition: tooltipPosition,
      wasLongPress: false,
      activationTime: DateTime.now(),
    );

    _tooltipOpacity = 1.0;
    notifyListeners();
  }

  void _hideTooltip() {
    if (_tooltipData != null) {
      _tooltipHideTimer?.cancel();
      _tooltipData = null;
      _tooltipOpacity = 0.0;
      notifyListeners();
    }
  }

  void _startHideTimer(Duration delay) {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = Timer(delay, () {
      if (!_isPointerDown) {
        _hideTooltip();
      }
    });
  }

  // ========================================================================
  // CROSSHAIR MANAGEMENT
  // ========================================================================

  void _showCrosshair(Offset position, BarHitTestResult? hitResult) {
    _crosshairHideTimer?.cancel();
    _crosshairPosition = position;

    // For bar charts, create a synthetic point with index as X for correct crosshair positioning
    // The crosshair layer uses point.x for screen position calculation
    if (hitResult != null) {
      _crosshairPoint = FusionDataPoint(
        hitResult.pointIndex.toDouble(), // Use index, not original x value
        hitResult.point.y,
        label: hitResult.point.label ?? _formatXLabel(hitResult.point.x),
      );
    } else {
      _crosshairPoint = null;
    }
    notifyListeners();
  }

  /// Formats X value as label string
  String _formatXLabel(double x) {
    return x == x.roundToDouble() ? x.round().toString() : x.toString();
  }

  /// Updates crosshair position during drag, with coordinate system clamping.
  void _updateCrosshairPosition(Offset position) {
    _crosshairHideTimer?.cancel();

    // CRITICAL FIX: Clamp in data space using coordinate system
    // This is more natural than clamping to pixel bounds
    final dataX = _currentCoordSystem.screenXToDataX(position.dx);
    final dataY = _currentCoordSystem.screenYToDataY(position.dy);

    final clampedDataX = dataX.clamp(_currentCoordSystem.dataXMin, _currentCoordSystem.dataXMax);
    final clampedDataY = dataY.clamp(_currentCoordSystem.dataYMin, _currentCoordSystem.dataYMax);

    final clampedPosition = Offset(
      _currentCoordSystem.dataXToScreenX(clampedDataX),
      _currentCoordSystem.dataYToScreenY(clampedDataY),
    );

    // Find hit at clamped position
    final hitResult = _hitTester.hitTest(
      screenPosition: clampedPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null && config.crosshairBehavior.snapToDataPoint) {
      // Snap to bar center
      final snappedPosition = Offset(hitResult.barRect.center.dx, hitResult.barRect.top);
      _crosshairPosition = snappedPosition;
      // Use index-based point for correct crosshair rendering
      _crosshairPoint = FusionDataPoint(
        hitResult.pointIndex.toDouble(),
        hitResult.point.y,
        label: hitResult.point.label ?? _formatXLabel(hitResult.point.x),
      );
    } else {
      // Follow finger (clamped to coordinate system bounds)
      _crosshairPosition = clampedPosition;
      if (hitResult != null) {
        _crosshairPoint = FusionDataPoint(
          hitResult.pointIndex.toDouble(),
          hitResult.point.y,
          label: hitResult.point.label ?? _formatXLabel(hitResult.point.x),
        );
      } else {
        _crosshairPoint = null;
      }
    }

    notifyListeners();
  }

  void _hideCrosshair() {
    _crosshairHideTimer?.cancel();
    if (_crosshairPosition != null) {
      _crosshairPosition = null;
      _crosshairPoint = null;
      notifyListeners();
    }
  }

  void _startCrosshairHideTimer(Duration delay) {
    _crosshairHideTimer?.cancel();
    _crosshairHideTimer = Timer(delay, _hideCrosshair);
  }

  // ========================================================================
  // GESTURE RECOGNIZERS
  // ========================================================================

  @override
  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    final recognizers = <Type, GestureRecognizerFactory>{};

    if (config.enableTooltip || config.enableSelection) {
      recognizers[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(TapGestureRecognizer.new, (
            recognizer,
          ) {
            recognizer.onTapDown = (details) {
              final hitResult = _hitTester.hitTest(
                screenPosition: details.localPosition,
                allSeries: series,
                coordSystem: _currentCoordSystem,
                enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
              );

              if (hitResult != null && config.enableTooltip) {
                _showTooltip(hitResult, details.localPosition);
              }
            };
          });
    }

    if (config.enableCrosshair) {
      recognizers[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            LongPressGestureRecognizer.new,
            (recognizer) {
              recognizer
                ..onLongPressStart = (details) {
                  final hitResult = _hitTester.hitTest(
                    screenPosition: details.localPosition,
                    allSeries: series,
                    coordSystem: _currentCoordSystem,
                    enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
                  );

                  // Pass full hit result for proper index-based positioning
                  _showCrosshair(details.localPosition, hitResult);
                }
                ..onLongPressMoveUpdate = (details) {
                  // CRITICAL FIX: Enable crosshair drag on bar charts
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
                      _hideCrosshair();
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

    // Use ScaleGestureRecognizer when both zoom and pan are enabled
    if (config.enableZoom && config.enablePanning) {
      recognizers[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(ScaleGestureRecognizer.new, (
            recognizer,
          ) {
            recognizer
              ..onStart = (details) {
                _handleScaleStart(details.localFocalPoint);
              }
              ..onUpdate = (details) {
                if (details.scale == 1.0) {
                  // Pan gesture
                  if (!_isPanning) {
                    _handlePanStart(details.localFocalPoint);
                  }
                  if (_lastPointerPosition != null) {
                    final delta = details.localFocalPoint - _lastPointerPosition!;
                    _handlePanUpdate(delta);
                  }
                  _lastPointerPosition = details.localFocalPoint;
                } else {
                  // Pinch zoom
                  _handleScaleUpdate(details.scale, details.localFocalPoint);
                }
              }
              ..onEnd = (details) {
                if (_isPanning) {
                  _handlePanEnd();
                }
                if (_isZooming) {
                  _handleScaleEnd();
                }
                _lastPointerPosition = null;
              };
          });
    } else if (config.enablePanning) {
      recognizers[PanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(PanGestureRecognizer.new, (
            recognizer,
          ) {
            recognizer
              ..onStart = (details) {
                _handlePanStart(details.localPosition);
              }
              ..onUpdate = (details) {
                _handlePanUpdate(details.delta);
              }
              ..onEnd = (details) {
                _handlePanEnd();
              };
          });
    } else if (config.enableZoom) {
      recognizers[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(ScaleGestureRecognizer.new, (
            recognizer,
          ) {
            recognizer
              ..onStart = (details) {
                _handleScaleStart(details.localFocalPoint);
              }
              ..onUpdate = (details) {
                if (details.scale != 1.0) {
                  _handleScaleUpdate(details.scale, details.localFocalPoint);
                }
              }
              ..onEnd = (details) {
                _handleScaleEnd();
              };
          });
    }

    return recognizers;
  }

  @override
  void dispose() {
    _tooltipHideTimer?.cancel();
    _crosshairHideTimer?.cancel();
    super.dispose();
  }
}

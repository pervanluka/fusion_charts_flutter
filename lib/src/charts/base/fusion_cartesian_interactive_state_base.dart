import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../configuration/fusion_chart_configuration.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../configuration/fusion_zoom_configuration.dart';
import '../../core/enums/fusion_zoom_mode.dart';
import '../../core/enums/interaction_anchor_mode.dart';
import '../../data/fusion_data_point.dart';
import '../../rendering/fusion_coordinate_system.dart';
import '../../rendering/fusion_interaction_handler.dart';
import '../../utils/fusion_desktop_helper.dart';
import '../mixins/fusion_zoom_animation_mixin.dart';
import 'fusion_interactive_state_base.dart';

/// Abstract base class for all cartesian (X-Y axis) chart interactive states.
///
/// Provides common implementation for:
/// - Zoom handling (pinch, double-tap, mouse wheel)
/// - Pan handling
/// - Coordinate system management
/// - Gesture recognizer setup
/// - Timer management
///
/// Subclasses implement chart-specific behavior:
/// - Hit testing
/// - Tooltip rendering
/// - Crosshair behavior
///
/// Type parameter:
/// - [TTooltipData] - The tooltip data type (must extend FusionTooltipDataBase)
abstract class FusionCartesianInteractiveStateBase<
  TTooltipData extends FusionTooltipDataBase
>
    extends ChangeNotifier
    with FusionZoomAnimationMixin
    implements FusionInteractiveStateBase {
  FusionCartesianInteractiveStateBase({
    required this.config,
    required FusionCoordinateSystem initialCoordSystem,
  }) : _currentCoordSystem = initialCoordSystem,
       _originalCoordSystem = initialCoordSystem;

  final FusionChartConfiguration config;

  FusionCoordinateSystem _currentCoordSystem;
  final FusionCoordinateSystem _originalCoordSystem;
  FusionInteractionHandler? _interactionHandler;

  /// Provides access to interaction handler for subclasses.
  @protected
  FusionInteractionHandler? get interactionHandler => _interactionHandler;

  // Tooltip state
  TTooltipData? _tooltipData;
  double _tooltipOpacity = 0.0;

  // Crosshair state
  Offset? _crosshairPosition;

  // Pointer state
  bool _isPointerDown = false;
  DateTime? _pointerDownTime;
  Offset? _lastPointerPosition;

  // Zoom/Pan state
  bool _isPanning = false;
  bool _isZooming = false;
  bool _hasActiveZoom = false;
  bool _hasLiveViewport =
      false; // True when setViewportRange is used for live scrolling
  double _lastScale = 1.0;

  // Timers
  Timer? _tooltipHideTimer;
  Timer? _crosshairHideTimer;

  // Anchor state for InteractionAnchorMode.dataPoint
  // When anchor mode is dataPoint, these store the data coordinates
  // so we can recalculate screen positions when viewport changes.
  FusionDataPoint? _anchoredDataPoint;
  double? _anchoredCrosshairDataX;
  double? _anchoredCrosshairDataY;

  // Cached gesture recognizers
  Map<Type, GestureRecognizerFactory>? _cachedGestureRecognizers;
  int? _lastGestureConfigHash;

  // Disposal flag to prevent notifyListeners after dispose
  bool _isDisposed = false;

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  @override
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;

  @override
  TTooltipData? get tooltipData => _tooltipData;

  @override
  double get tooltipOpacity => _tooltipOpacity;

  @override
  Offset? get crosshairPosition => _crosshairPosition;

  @override
  bool get isInteracting => _isPanning || _isZooming || isAnimatingZoom;

  @override
  bool get isPointerDown => _isPointerDown;

  /// Whether the chart has an active zoom (not at original bounds).
  bool get hasActiveZoom => _hasActiveZoom;

  /// Whether a live viewport is active.
  bool get hasLiveViewport => _hasLiveViewport;

  /// Resets the live viewport flag, allowing coordinate system to be reset.
  /// Call this when reinitializing or clearing live data.
  void resetLiveViewport() {
    _hasLiveViewport = false;
  }

  /// The last pointer position during interaction.
  @protected
  Offset? get lastPointerPosition => _lastPointerPosition;

  /// Whether panning is currently in progress.
  @protected
  bool get isPanning => _isPanning;

  /// Whether zooming is currently in progress.
  @protected
  bool get isZooming => _isZooming;

  /// Sets the last pointer position.
  @protected
  set lastPointerPosition(Offset? value) => _lastPointerPosition = value;

  /// The anchored data point for tooltip (when using dataPoint anchor mode).
  @protected
  FusionDataPoint? get anchoredDataPoint => _anchoredDataPoint;

  /// Sets the anchored data point.
  @protected
  set anchoredDataPoint(FusionDataPoint? value) => _anchoredDataPoint = value;

  /// The anchored crosshair data X coordinate.
  @protected
  double? get anchoredCrosshairDataX => _anchoredCrosshairDataX;

  /// The anchored crosshair data Y coordinate.
  @protected
  double? get anchoredCrosshairDataY => _anchoredCrosshairDataY;

  /// Sets the anchored crosshair position from data coordinates.
  @protected
  void setAnchoredCrosshairData(double? x, double? y) {
    _anchoredCrosshairDataX = x;
    _anchoredCrosshairDataY = y;
  }

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
    final isAtOriginal =
        (_currentCoordSystem.dataXMin - _originalCoordSystem.dataXMin).abs() <
            0.001 &&
        (_currentCoordSystem.dataXMax - _originalCoordSystem.dataXMax).abs() <
            0.001 &&
        (_currentCoordSystem.dataYMin - _originalCoordSystem.dataYMin).abs() <
            0.001 &&
        (_currentCoordSystem.dataYMax - _originalCoordSystem.dataYMax).abs() <
            0.001;

    _hasActiveZoom = !isAtOriginal;
    rebuildInteractionHandler();
  }

  @override
  void zoomIn() => zoomInByControl();

  @override
  void zoomOut() => zoomOutByControl();

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initialize() {
    rebuildInteractionHandler();
    onInitialize();
  }

  /// Called during initialization. Override for additional setup.
  @protected
  void onInitialize() {}

  /// Rebuilds the interaction handler. Call after coordinate system changes.
  @protected
  void rebuildInteractionHandler() {
    _interactionHandler = createInteractionHandler();
  }

  /// Creates the interaction handler. Override to customize callbacks.
  @protected
  FusionInteractionHandler createInteractionHandler() {
    return FusionInteractionHandler(
      coordSystem: _currentCoordSystem,
      zoomConfig: config.zoomBehavior,
      panConfig: config.panBehavior,
    );
  }

  @override
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {
    // Preserve current viewport bounds when:
    // - User is interacting (pan/zoom in progress)
    // - User has zoomed (hasActiveZoom)
    // - Live scrolling viewport is active (hasLiveViewport)
    if (isInteracting || _hasActiveZoom || _hasLiveViewport) {
      _currentCoordSystem = FusionCoordinateSystem(
        chartArea: newCoordSystem.chartArea,
        dataXMin: _currentCoordSystem.dataXMin,
        dataXMax: _currentCoordSystem.dataXMax,
        dataYMin: _currentCoordSystem.dataYMin,
        dataYMax: _currentCoordSystem.dataYMax,
        devicePixelRatio: newCoordSystem.devicePixelRatio,
      );
      if (!isInteracting) {
        rebuildInteractionHandler();
      }
    } else {
      _currentCoordSystem = newCoordSystem;
      rebuildInteractionHandler();
    }
  }

  /// Set the viewport range for live data scrolling.
  ///
  /// Updates the visible X range without affecting Y bounds.
  /// This is used by live charts for auto-scrolling.
  ///
  /// If [minY] and [maxY] are provided, Y bounds are also updated.
  void setViewportRange({
    required double minX,
    required double maxX,
    double? minY,
    double? maxY,
  }) {
    // Mark that we have an active live viewport (prevents reset during build)
    _hasLiveViewport = true;

    _currentCoordSystem = FusionCoordinateSystem(
      chartArea: _currentCoordSystem.chartArea,
      dataXMin: minX,
      dataXMax: maxX,
      dataYMin: minY ?? _currentCoordSystem.dataYMin,
      dataYMax: maxY ?? _currentCoordSystem.dataYMax,
      devicePixelRatio: _currentCoordSystem.devicePixelRatio,
    );
    rebuildInteractionHandler();

    // Update anchored interaction positions if in dataPoint anchor mode
    if (config.interactionAnchorMode == InteractionAnchorMode.dataPoint) {
      _updateAnchoredPositions(minX, maxX, minY, maxY);
    }

    notifyListeners();
  }

  /// Updates anchored positions when viewport changes (for dataPoint anchor mode).
  ///
  /// This recalculates the screen positions of crosshair/tooltip based on
  /// their anchored data coordinates. If the anchored point is outside the
  /// visible viewport, the interaction elements are hidden.
  void _updateAnchoredPositions(
    double minX,
    double maxX,
    double? minY,
    double? maxY,
  ) {
    // Update crosshair position if anchored
    if (_anchoredCrosshairDataX != null && _anchoredCrosshairDataY != null) {
      final dataX = _anchoredCrosshairDataX!;
      final dataY = _anchoredCrosshairDataY!;

      // Check if anchored point is still visible
      if (dataX < minX || dataX > maxX) {
        // Point has scrolled out of view - hide crosshair
        hideCrosshair();
        _anchoredCrosshairDataX = null;
        _anchoredCrosshairDataY = null;
        _anchoredDataPoint = null;
      } else {
        // Update screen position from data coordinates
        _crosshairPosition = Offset(
          _currentCoordSystem.dataXToScreenX(dataX),
          _currentCoordSystem.dataYToScreenY(dataY),
        );
      }
    }

    // Update tooltip position if anchored
    if (_anchoredDataPoint != null && _tooltipData != null) {
      final dataX = _anchoredDataPoint!.x;

      // Check if anchored point is still visible
      if (dataX < minX || dataX > maxX) {
        // Point has scrolled out of view - hide tooltip
        hideTooltip();
        _anchoredDataPoint = null;
      } else {
        // Let subclass handle tooltip position update
        onAnchoredTooltipPositionUpdate(_anchoredDataPoint!);
      }
    }
  }

  /// Called when the anchored tooltip position needs to be updated.
  ///
  /// Subclasses should override this to update their tooltip data
  /// with the new screen position calculated from the anchored data point.
  @protected
  void onAnchoredTooltipPositionUpdate(FusionDataPoint anchoredPoint) {
    // Default implementation does nothing.
    // Subclasses override to update tooltip screen position.
  }

  // ===========================================================================
  // ABSTRACT METHODS - Implement in subclasses
  // ===========================================================================

  /// Called when pointer down occurs. Implement chart-specific hit testing.
  @protected
  void onPointerDown(Offset position);

  /// Called when pointer moves. Implement chart-specific tracking.
  @protected
  void onPointerMove(Offset position);

  /// Called when pointer hovers. Implement chart-specific hover behavior.
  @protected
  void onPointerHover(Offset position);

  /// Called to hide the tooltip.
  void hideTooltip();

  /// Called to hide the crosshair.
  void hideCrosshair();

  // ===========================================================================
  // POINTER EVENT HANDLERS
  // ===========================================================================

  @override
  void handlePointerDown(PointerDownEvent event) {
    _isPointerDown = true;
    _pointerDownTime = DateTime.now();
    _lastPointerPosition = event.localPosition;
    _tooltipHideTimer?.cancel();

    onPointerDown(event.localPosition);
  }

  @override
  void handlePointerMove(PointerMoveEvent event) {
    if (!_isPointerDown) return;
    _lastPointerPosition = event.localPosition;
    onPointerMove(event.localPosition);
  }

  @override
  void handlePointerUp(PointerUpEvent event) {
    _isPointerDown = false;

    final pressDuration = _pointerDownTime != null
        ? DateTime.now().difference(_pointerDownTime!)
        : Duration.zero;
    final wasLongPress = pressDuration.inMilliseconds > 500;

    onPointerUp(wasLongPress);

    _pointerDownTime = null;
    _lastPointerPosition = null;
  }

  /// Called when pointer is released. Override for custom behavior.
  @protected
  void onPointerUp(bool wasLongPress) {
    if (config.enableTooltip && _tooltipData != null) {
      final delay = config.tooltipBehavior.getDismissDelay(wasLongPress);
      if (delay == Duration.zero) {
        hideTooltip();
      } else {
        startTooltipHideTimer(delay);
      }
    }

    if (config.enableCrosshair && _crosshairPosition != null) {
      hideCrosshair();
    }
  }

  @override
  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _lastPointerPosition = null;
    hideTooltip();
    hideCrosshair();
  }

  @override
  void handlePointerHover(PointerHoverEvent event) {
    onPointerHover(event.localPosition);
  }

  @override
  void handlePointerExit(PointerExitEvent event) {
    onPointerExit();
  }

  /// Called when pointer exits the chart area. Override for chart-specific behavior.
  @protected
  void onPointerExit() {
    // Default: hide tooltip and crosshair when mouse leaves
    hideTooltip();
    hideCrosshair();
  }

  // ===========================================================================
  // MOUSE WHEEL ZOOM
  // ===========================================================================

  @override
  void handlePointerSignal(PointerSignalEvent event) {
    if (!config.enableZoom) return;
    if (!config.zoomBehavior.enableMouseWheelZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    if (event is PointerScrollEvent) {
      if (!_currentCoordSystem.chartArea.contains(event.localPosition)) {
        return;
      }

      if (config.zoomBehavior.requireModifierForWheelZoom) {
        final hasModifier =
            FusionDesktopHelper.isControlPressed ||
            FusionDesktopHelper.isMetaPressed;
        if (!hasModifier) {
          return;
        }
      }

      GestureBinding.instance.pointerSignalResolver.register(event, (
        PointerSignalEvent resolvedEvent,
      ) {
        if (resolvedEvent is PointerScrollEvent) {
          final scaleFactor = _interactionHandler!.calculateMouseWheelZoom(
            resolvedEvent.scrollDelta.dy,
          );
          applyZoomWithHandler(scaleFactor, resolvedEvent.localPosition);
        }
      });
    }
  }

  /// Applies zoom using the interaction handler.
  @protected
  void applyZoomWithHandler(double scaleFactor, Offset focalPoint) {
    applyZoom(
      scaleFactor,
      focalPoint,
      _interactionHandler!,
      (value) => _hasActiveZoom = value,
    );
  }

  // ===========================================================================
  // PAN HANDLING
  // ===========================================================================

  /// Starts pan gesture handling.
  @protected
  void handlePanStart(Offset position) {
    if (!config.enablePanning) return;
    _isPanning = true;

    if (_tooltipData != null) {
      _tooltipData = null;
      _tooltipOpacity = 0.0;
      notifyListeners();
    }
  }

  /// Updates pan gesture handling.
  @protected
  void handlePanUpdate(Offset delta) {
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

  /// Ends pan gesture handling.
  @protected
  void handlePanEnd() {
    _isPanning = false;
    rebuildInteractionHandler();
    notifyListeners();
  }

  // ===========================================================================
  // ZOOM/SCALE HANDLING
  // ===========================================================================

  /// Starts scale/zoom gesture handling.
  @protected
  void handleScaleStart(Offset focalPoint) {
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

  /// Updates scale/zoom gesture handling.
  @protected
  void handleScaleUpdate(double scaleFactor, Offset focalPoint) {
    if (!config.enableZoom || !_isZooming) return;
    if (!config.zoomBehavior.enablePinchZoom) return;
    if (config.zoomBehavior.zoomMode == FusionZoomMode.none) return;

    applyZoomWithHandler(scaleFactor, focalPoint);
  }

  /// Ends scale/zoom gesture handling.
  @protected
  void handleScaleEnd() {
    _isZooming = false;
    rebuildInteractionHandler();
    notifyListeners();
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  @override
  void reset() {
    _currentCoordSystem = _originalCoordSystem;
    _hasActiveZoom = false;
    // Clear anchor state
    _anchoredDataPoint = null;
    _anchoredCrosshairDataX = null;
    _anchoredCrosshairDataY = null;
    hideTooltip();
    hideCrosshair();
    notifyListeners();
  }

  // ===========================================================================
  // TOOLTIP MANAGEMENT
  // ===========================================================================

  /// Sets the tooltip data. Call from subclass implementations.
  @protected
  void setTooltipData(TTooltipData? data) {
    _tooltipData = data;
    _tooltipOpacity = data != null ? 1.0 : 0.0;
  }

  /// Cancels the tooltip hide timer.
  @protected
  void cancelTooltipHideTimer() {
    _tooltipHideTimer?.cancel();
  }

  /// Starts the tooltip hide timer.
  @protected
  void startTooltipHideTimer(Duration delay) {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = Timer(delay, () {
      if (!_isPointerDown) {
        hideTooltip();
      }
    });
  }

  // ===========================================================================
  // CROSSHAIR MANAGEMENT
  // ===========================================================================

  /// Sets the crosshair position. Call from subclass implementations.
  @protected
  set crosshairPosition(Offset? position) {
    _crosshairPosition = position;
  }

  /// Cancels the crosshair hide timer.
  @protected
  void cancelCrosshairHideTimer() {
    _crosshairHideTimer?.cancel();
  }

  /// Starts the crosshair hide timer.
  @protected
  void startCrosshairHideTimer(Duration delay) {
    _crosshairHideTimer?.cancel();
    _crosshairHideTimer = Timer(delay, hideCrosshair);
  }

  /// Clamps a position to the current coordinate system bounds.
  @protected
  Offset clampPositionToCoordSystem(Offset position) {
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

    return Offset(
      _currentCoordSystem.dataXToScreenX(clampedDataX),
      _currentCoordSystem.dataYToScreenY(clampedDataY),
    );
  }

  // ===========================================================================
  // GESTURE RECOGNIZERS
  // ===========================================================================

  /// Computes hash for gesture config caching.
  @protected
  int computeGestureConfigHash() {
    return Object.hash(
      config.enableTooltip,
      config.enableSelection,
      config.enableCrosshair,
      config.enableZoom,
      config.enablePanning,
      config.zoomBehavior.enablePinchZoom,
      config.zoomBehavior.enableDoubleTapZoom,
      config.zoomBehavior.zoomMode,
    );
  }

  @override
  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    final currentHash = computeGestureConfigHash();
    if (_cachedGestureRecognizers != null &&
        _lastGestureConfigHash == currentHash) {
      return _cachedGestureRecognizers!;
    }

    final recognizers = buildGestureRecognizers();

    _cachedGestureRecognizers = recognizers;
    _lastGestureConfigHash = currentHash;

    return recognizers;
  }

  /// Builds gesture recognizers. Override to add chart-specific recognizers.
  @protected
  Map<Type, GestureRecognizerFactory> buildGestureRecognizers() {
    final recognizers = <Type, GestureRecognizerFactory>{};

    // Tap recognizer
    if (config.enableTooltip || config.enableSelection) {
      recognizers[TapGestureRecognizer] = buildTapRecognizer();
    }

    // Double-tap for zoom
    if (config.enableZoom && config.zoomBehavior.enableDoubleTapZoom) {
      recognizers[DoubleTapGestureRecognizer] = buildDoubleTapRecognizer();
    }

    // Long press for crosshair
    if (config.enableCrosshair) {
      recognizers[LongPressGestureRecognizer] = buildLongPressRecognizer();
    }

    // Scale/Pan recognizers
    if (config.enableZoom && config.enablePanning) {
      recognizers[ScaleGestureRecognizer] = buildScaleRecognizer();
    } else if (config.enablePanning) {
      recognizers[PanGestureRecognizer] = buildPanRecognizer();
    } else if (config.enableZoom) {
      recognizers[ScaleGestureRecognizer] = buildZoomOnlyScaleRecognizer();
    }

    return recognizers;
  }

  /// Builds tap gesture recognizer. Override for custom tap handling.
  @protected
  GestureRecognizerFactory<TapGestureRecognizer> buildTapRecognizer() {
    return GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      TapGestureRecognizer.new,
      (recognizer) {
        recognizer.onTapDown = (details) {
          onTapDown(details.localPosition);
        };
      },
    );
  }

  /// Called on tap down. Override for chart-specific tap handling.
  @protected
  void onTapDown(Offset position) {}

  /// Builds double-tap gesture recognizer.
  @protected
  GestureRecognizerFactory<DoubleTapGestureRecognizer>
  buildDoubleTapRecognizer() {
    return GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
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

  /// Builds long press gesture recognizer. Override for custom long press handling.
  @protected
  GestureRecognizerFactory<LongPressGestureRecognizer>
  buildLongPressRecognizer() {
    return GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
      LongPressGestureRecognizer.new,
      (recognizer) {
        recognizer
          ..onLongPressStart = (details) {
            onLongPressStart(details.localPosition);
          }
          ..onLongPressMoveUpdate = (details) {
            onLongPressMoveUpdate(details.localPosition);
          }
          ..onLongPressEnd = (details) {
            onLongPressEnd(details.localPosition);
          };
      },
    );
  }

  /// Called on long press start. Override for chart-specific handling.
  @protected
  void onLongPressStart(Offset position) {}

  /// Called on long press move. Override for chart-specific handling.
  @protected
  void onLongPressMoveUpdate(Offset position) {}

  /// Called on long press end. Override for chart-specific handling.
  @protected
  void onLongPressEnd(Offset position) {
    final crosshairBehavior = config.crosshairBehavior;
    if (crosshairBehavior.shouldDismissOnRelease()) {
      final delay = crosshairBehavior.getDismissDelay(true);
      if (delay == Duration.zero) {
        hideCrosshair();
      } else {
        startCrosshairHideTimer(delay);
      }
    } else if (crosshairBehavior.shouldUseTimer()) {
      startCrosshairHideTimer(crosshairBehavior.duration);
    }
  }

  /// Builds scale gesture recognizer for combined zoom and pan.
  @protected
  GestureRecognizerFactory<ScaleGestureRecognizer> buildScaleRecognizer() {
    return GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
      ScaleGestureRecognizer.new,
      (recognizer) {
        recognizer
          ..onStart = (details) {
            _lastPointerPosition = details.localFocalPoint;
            handleScaleStart(details.localFocalPoint);
          }
          ..onUpdate = (details) {
            if (details.scale == 1.0) {
              if (!_isPanning) {
                handlePanStart(details.localFocalPoint);
              }
              if (_lastPointerPosition != null) {
                final delta = details.localFocalPoint - _lastPointerPosition!;
                handlePanUpdate(delta);
              }
              _lastPointerPosition = details.localFocalPoint;
            } else {
              final scaleDelta = details.scale / _lastScale;
              _lastScale = details.scale;
              handleScaleUpdate(scaleDelta, details.localFocalPoint);
            }
          }
          ..onEnd = (details) {
            if (_isPanning) {
              handlePanEnd();
            }
            if (_isZooming) {
              handleScaleEnd();
            }
            _lastPointerPosition = null;
            _lastScale = 1.0;
          };
      },
    );
  }

  /// Builds pan-only gesture recognizer.
  @protected
  GestureRecognizerFactory<PanGestureRecognizer> buildPanRecognizer() {
    return GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
      PanGestureRecognizer.new,
      (recognizer) {
        recognizer
          ..onStart = (details) {
            handlePanStart(details.localPosition);
          }
          ..onUpdate = (details) {
            handlePanUpdate(details.delta);
          }
          ..onEnd = (details) {
            handlePanEnd();
          };
      },
    );
  }

  /// Builds scale recognizer for zoom-only (no pan).
  @protected
  GestureRecognizerFactory<ScaleGestureRecognizer>
  buildZoomOnlyScaleRecognizer() {
    return GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
      ScaleGestureRecognizer.new,
      (recognizer) {
        recognizer
          ..onStart = (details) {
            handleScaleStart(details.localFocalPoint);
          }
          ..onUpdate = (details) {
            if (details.scale != 1.0) {
              final scaleDelta = details.scale / _lastScale;
              _lastScale = details.scale;
              handleScaleUpdate(scaleDelta, details.localFocalPoint);
            }
          }
          ..onEnd = (details) {
            handleScaleEnd();
            _lastScale = 1.0;
          };
      },
    );
  }

  // ===========================================================================
  // SAFE NOTIFICATION
  // ===========================================================================

  /// Safely notifies listeners only if not disposed.
  ///
  /// This prevents "Trying to render a disposed EngineFlutterView" errors
  /// on Flutter web when timers or callbacks fire after disposal.
  @override
  void notifyListeners() {
    if (_isDisposed) return;
    // Uncomment to see all notifyListeners calls (can be very verbose)
    // debugPrint('[BaseState] notifyListeners called');
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tooltipHideTimer?.cancel();
    _crosshairHideTimer?.cancel();
    disposeZoomAnimation();
    super.dispose();
  }
}

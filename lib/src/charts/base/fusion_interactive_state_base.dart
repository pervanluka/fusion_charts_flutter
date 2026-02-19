import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../configuration/fusion_tooltip_configuration.dart'
    show FusionTooltipDataBase;
import '../../data/fusion_data_point.dart';
import '../../rendering/fusion_coordinate_system.dart';

/// Abstract base interface for chart interactive states.
///
/// Defines the common contract that all chart interactive states must implement.
/// This allows the base chart widget to work with any interactive state
/// implementation without knowing the concrete type.
///
/// ## Implementations
///
/// - [FusionInteractiveChartState] - For line/area charts (nearest point hit testing)
/// - [FusionBarInteractiveState] - For bar charts (rectangle hit testing)
/// - [FusionStackedBarInteractiveState] - For stacked bar charts (segment hit testing)
///
/// ## Example
///
/// ```dart
/// class MyCustomInteractiveState extends ChangeNotifier
///     implements FusionInteractiveStateBase {
///   @override
///   void initialize() { ... }
///
///   @override
///   void updateCoordinateSystem(FusionCoordinateSystem system) { ... }
///
///   // ... implement other members
/// }
/// ```
abstract class FusionInteractiveStateBase extends ChangeNotifier {
  // ===========================================================================
  // COORDINATE SYSTEM
  // ===========================================================================

  /// Current coordinate system for data-to-screen transformations.
  FusionCoordinateSystem get coordSystem;

  /// Updates the coordinate system when chart dimensions change.
  ///
  /// Called by the chart widget whenever the layout changes.
  /// Implementations should update internal state and rebuild
  /// any dependent objects (like hit testers).
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem);

  // ===========================================================================
  // TOOLTIP STATE
  // ===========================================================================

  /// Current tooltip data to render, or null if no tooltip visible.
  ///
  /// Returns [FusionTooltipDataBase] which can be:
  /// - [TooltipRenderData] for line/bar charts
  /// - [StackedTooltipData] for stacked bar charts
  FusionTooltipDataBase? get tooltipData;

  /// Tooltip opacity for fade animations (0.0 to 1.0).
  double get tooltipOpacity;

  // ===========================================================================
  // CROSSHAIR STATE
  // ===========================================================================

  /// Current crosshair screen position, or null if not visible.
  Offset? get crosshairPosition;

  /// Data point at crosshair position, or null if not visible.
  FusionDataPoint? get crosshairPoint;

  // ===========================================================================
  // INTERACTION STATE
  // ===========================================================================

  /// Whether user is currently panning or zooming.
  bool get isInteracting;

  /// Whether pointer is currently down on the chart.
  bool get isPointerDown;

  /// Whether zoom animation is currently in progress.
  bool get isAnimatingZoom => false;

  /// Current zoom animation progress (0.0 to 1.0).
  double get zoomAnimationProgress => 1.0;

  // ===========================================================================
  // SELECTION ZOOM STATE
  // ===========================================================================

  /// Whether selection zoom mode is active.
  bool get isSelectionZoomActive => false;

  /// Start point of selection rectangle in screen coordinates.
  Offset? get selectionStart => null;

  /// Current point of selection rectangle in screen coordinates.
  Offset? get selectionCurrent => null;

  /// Selection rectangle in screen coordinates, or null if not active.
  Rect? get selectionRect {
    final start = selectionStart;
    final current = selectionCurrent;
    if (start == null || current == null) return null;
    return Rect.fromPoints(start, current);
  }

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  /// Initializes the interactive state.
  ///
  /// Called once after construction. Sets up internal handlers,
  /// gesture recognizers, and any other required state.
  void initialize();

  // ===========================================================================
  // POINTER HANDLERS
  // ===========================================================================

  /// Handles pointer down events.
  void handlePointerDown(PointerDownEvent event);

  /// Handles pointer move events.
  void handlePointerMove(PointerMoveEvent event);

  /// Handles pointer up events.
  void handlePointerUp(PointerUpEvent event);

  /// Handles pointer cancel events.
  void handlePointerCancel(PointerCancelEvent event);

  /// Handles pointer hover events (desktop/web).
  void handlePointerHover(PointerHoverEvent event);

  /// Handles pointer exit events (desktop/web).
  ///
  /// Called when the mouse leaves the chart area.
  void handlePointerExit(PointerExitEvent event);

  /// Handles pointer signal events (scroll wheel).
  void handlePointerSignal(PointerSignalEvent event);

  // ===========================================================================
  // GESTURE RECOGNIZERS
  // ===========================================================================

  /// Returns gesture recognizers for the chart.
  ///
  /// Used by [RawGestureDetector] to handle complex gestures
  /// like pan and scale (pinch zoom).
  Map<Type, GestureRecognizerFactory> getGestureRecognizers();

  // ===========================================================================
  // ZOOM CONTROLS
  // ===========================================================================

  /// Zooms in by a fixed factor (default 1.5x) centered on chart.
  void zoomIn() {}

  /// Zooms out by a fixed factor (default 1.5x) centered on chart.
  void zoomOut() {}

  /// Resets zoom to original bounds.
  void reset() {}
}

/// Mixin providing common timer management for interactive states.
///
/// Handles tooltip show/hide timers, crosshair hide timers,
/// and debounce timers with proper cleanup.
mixin FusionInteractiveTimersMixin on ChangeNotifier {
  /// Timer for delayed tooltip show.
  Timer? tooltipShowTimer;

  /// Timer for auto-hide tooltip.
  Timer? tooltipHideTimer;

  /// Timer for debouncing rapid updates.
  Timer? debounceTimer;

  /// Timer for auto-hide crosshair.
  Timer? crosshairHideTimer;

  /// Cancels all active timers.
  void cancelAllTimers() {
    tooltipShowTimer?.cancel();
    tooltipShowTimer = null;
    tooltipHideTimer?.cancel();
    tooltipHideTimer = null;
    debounceTimer?.cancel();
    debounceTimer = null;
    crosshairHideTimer?.cancel();
    crosshairHideTimer = null;
  }

  /// Schedules tooltip hide after specified duration.
  void scheduleTooltipHide(Duration duration, VoidCallback onHide) {
    tooltipHideTimer?.cancel();
    tooltipHideTimer = Timer(duration, () {
      onHide();
      tooltipHideTimer = null;
    });
  }

  /// Schedules crosshair hide after specified duration.
  void scheduleCrosshairHide(Duration duration, VoidCallback onHide) {
    crosshairHideTimer?.cancel();
    crosshairHideTimer = Timer(duration, () {
      onHide();
      crosshairHideTimer = null;
    });
  }

  /// Debounces a callback by specified duration.
  void debounce(Duration duration, VoidCallback callback) {
    debounceTimer?.cancel();
    debounceTimer = Timer(duration, () {
      callback();
      debounceTimer = null;
    });
  }
}

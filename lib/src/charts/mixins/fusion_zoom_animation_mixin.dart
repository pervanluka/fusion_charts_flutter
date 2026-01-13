import 'dart:async';
import 'package:flutter/material.dart';
import '../../configuration/fusion_zoom_configuration.dart';
import '../../rendering/fusion_coordinate_system.dart';
import '../../rendering/fusion_interaction_handler.dart';

/// Mixin providing animated zoom functionality for interactive states.
///
/// Implements:
/// - Smooth animated zoom transitions
/// - Double-tap to zoom in/reset
/// - Selection zoom (rectangular area)
/// - Programmatic zoom in/out controls
///
/// ## Usage
///
/// ```dart
/// class MyInteractiveState extends ChangeNotifier
///     with FusionZoomAnimationMixin {
///   @override
///   FusionZoomConfiguration get zoomConfig => config.zoomBehavior;
///
///   @override
///   void onZoomAnimationUpdate() {
///     notifyListeners();
///   }
/// }
/// ```
mixin FusionZoomAnimationMixin on ChangeNotifier {
  // ===========================================================================
  // ABSTRACT MEMBERS - Must be implemented by using class
  // ===========================================================================

  /// Current zoom configuration.
  FusionZoomConfiguration get zoomConfig;

  /// Current coordinate system.
  FusionCoordinateSystem get currentCoordSystem;

  /// Original coordinate system (before any zoom).
  FusionCoordinateSystem get originalCoordSystem;

  /// Sets the current coordinate system.
  set currentCoordSystemValue(FusionCoordinateSystem value);

  /// Called when zoom animation updates - should call notifyListeners().
  void onZoomAnimationUpdate();

  /// Called when zoom completes.
  void onZoomComplete();

  // ===========================================================================
  // ANIMATION STATE
  // ===========================================================================

  Timer? _zoomAnimationTimer;
  double _zoomAnimationProgress = 1.0;
  bool _isAnimatingZoom = false;

  // Animation start/end bounds
  double _animStartXMin = 0;
  double _animStartXMax = 0;
  double _animStartYMin = 0;
  double _animStartYMax = 0;
  double _animEndXMin = 0;
  double _animEndXMax = 0;
  double _animEndYMin = 0;
  double _animEndYMax = 0;

  /// Whether zoom animation is currently in progress.
  bool get isAnimatingZoom => _isAnimatingZoom;

  /// Current zoom animation progress (0.0 to 1.0).
  double get zoomAnimationProgress => _zoomAnimationProgress;

  // ===========================================================================
  // SELECTION ZOOM STATE
  // ===========================================================================

  bool _isSelectionZoomActive = false;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  /// Whether selection zoom mode is active.
  bool get isSelectionZoomActive => _isSelectionZoomActive;

  /// Start point of selection rectangle.
  Offset? get selectionStart => _selectionStart;

  /// Current point of selection rectangle.
  Offset? get selectionCurrent => _selectionCurrent;

  /// Selection rectangle, or null if not active.
  Rect? get selectionRect {
    if (_selectionStart == null || _selectionCurrent == null) return null;
    return Rect.fromPoints(_selectionStart!, _selectionCurrent!);
  }

  // ===========================================================================
  // DOUBLE-TAP ZOOM
  // ===========================================================================

  /// Default zoom factor for double-tap (2x zoom in).
  static const double _doubleTapZoomFactor = 2.0;

  /// Handles double-tap gesture for zoom.
  ///
  /// If not zoomed: zooms in 2x at tap location.
  /// If zoomed: resets to original bounds.
  void handleDoubleTapZoom(Offset tapPosition, {bool hasActiveZoom = false}) {
    if (!zoomConfig.enableDoubleTapZoom) return;

    if (hasActiveZoom) {
      // Reset to original bounds
      animateZoomTo(
        originalCoordSystem.dataXMin,
        originalCoordSystem.dataXMax,
        originalCoordSystem.dataYMin,
        originalCoordSystem.dataYMax,
      );
    } else {
      // Zoom in 2x at tap position
      final currentXMin = currentCoordSystem.dataXMin;
      final currentXMax = currentCoordSystem.dataXMax;
      final currentYMin = currentCoordSystem.dataYMin;
      final currentYMax = currentCoordSystem.dataYMax;

      // Convert tap position to data coordinates
      final tapDataX = currentCoordSystem.screenXToDataX(tapPosition.dx);
      final tapDataY = currentCoordSystem.screenYToDataY(tapPosition.dy);

      // Calculate new range (half of current = 2x zoom)
      final newXRange = (currentXMax - currentXMin) / _doubleTapZoomFactor;
      final newYRange = (currentYMax - currentYMin) / _doubleTapZoomFactor;

      // Center on tap position
      var newXMin = tapDataX - newXRange / 2;
      var newXMax = tapDataX + newXRange / 2;
      var newYMin = tapDataY - newYRange / 2;
      var newYMax = tapDataY + newYRange / 2;

      // Constrain to original bounds
      final origXRange = originalCoordSystem.dataXMax - originalCoordSystem.dataXMin;
      final origYRange = originalCoordSystem.dataYMax - originalCoordSystem.dataYMin;

      // Check max zoom level
      final minXRange = origXRange / zoomConfig.maxZoomLevel;
      final minYRange = origYRange / zoomConfig.maxZoomLevel;

      if (newXRange < minXRange) {
        final center = (newXMin + newXMax) / 2;
        newXMin = center - minXRange / 2;
        newXMax = center + minXRange / 2;
      }

      if (newYRange < minYRange) {
        final center = (newYMin + newYMax) / 2;
        newYMin = center - minYRange / 2;
        newYMax = center + minYRange / 2;
      }

      // Constrain pan boundaries
      if (newXMin < originalCoordSystem.dataXMin) {
        newXMin = originalCoordSystem.dataXMin;
        newXMax = newXMin + (newXRange < minXRange ? minXRange : newXRange);
      }
      if (newXMax > originalCoordSystem.dataXMax) {
        newXMax = originalCoordSystem.dataXMax;
        newXMin = newXMax - (newXRange < minXRange ? minXRange : newXRange);
      }
      if (newYMin < originalCoordSystem.dataYMin) {
        newYMin = originalCoordSystem.dataYMin;
        newYMax = newYMin + (newYRange < minYRange ? minYRange : newYRange);
      }
      if (newYMax > originalCoordSystem.dataYMax) {
        newYMax = originalCoordSystem.dataYMax;
        newYMin = newYMax - (newYRange < minYRange ? minYRange : newYRange);
      }

      animateZoomTo(newXMin, newXMax, newYMin, newYMax);
    }
  }

  // ===========================================================================
  // ANIMATED ZOOM
  // ===========================================================================

  /// Animates zoom to specified bounds.
  void animateZoomTo(double targetXMin, double targetXMax, double targetYMin, double targetYMax) {
    if (!zoomConfig.animateZoom) {
      // No animation - immediate update
      _applyZoomBounds(targetXMin, targetXMax, targetYMin, targetYMax);
      onZoomComplete();
      return;
    }

    // Cancel any existing animation
    _zoomAnimationTimer?.cancel();

    // Store start bounds
    _animStartXMin = currentCoordSystem.dataXMin;
    _animStartXMax = currentCoordSystem.dataXMax;
    _animStartYMin = currentCoordSystem.dataYMin;
    _animStartYMax = currentCoordSystem.dataYMax;

    // Store end bounds
    _animEndXMin = targetXMin;
    _animEndXMax = targetXMax;
    _animEndYMin = targetYMin;
    _animEndYMax = targetYMax;

    // Start animation
    _isAnimatingZoom = true;
    _zoomAnimationProgress = 0.0;

    final duration = zoomConfig.zoomAnimationDuration;
    final curve = zoomConfig.zoomAnimationCurve;
    const frameRate = 60;
    final totalFrames = (duration.inMilliseconds / (1000 / frameRate)).round();
    var currentFrame = 0;

    _zoomAnimationTimer = Timer.periodic(Duration(milliseconds: (1000 / frameRate).round()), (
      timer,
    ) {
      currentFrame++;
      _zoomAnimationProgress = (currentFrame / totalFrames).clamp(0.0, 1.0);

      // Apply easing curve
      final easedProgress = curve.transform(_zoomAnimationProgress);

      // Interpolate bounds
      final xMin = _lerpDouble(_animStartXMin, _animEndXMin, easedProgress);
      final xMax = _lerpDouble(_animStartXMax, _animEndXMax, easedProgress);
      final yMin = _lerpDouble(_animStartYMin, _animEndYMin, easedProgress);
      final yMax = _lerpDouble(_animStartYMax, _animEndYMax, easedProgress);

      _applyZoomBounds(xMin, xMax, yMin, yMax);

      if (_zoomAnimationProgress >= 1.0) {
        timer.cancel();
        _isAnimatingZoom = false;
        _zoomAnimationTimer = null;
        onZoomComplete();
      }

      onZoomAnimationUpdate();
    });
  }

  /// Linear interpolation helper.
  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Applies zoom bounds to coordinate system.
  void _applyZoomBounds(double xMin, double xMax, double yMin, double yMax) {
    currentCoordSystemValue = FusionCoordinateSystem(
      chartArea: currentCoordSystem.chartArea,
      dataXMin: xMin,
      dataXMax: xMax,
      dataYMin: yMin,
      dataYMax: yMax,
      devicePixelRatio: currentCoordSystem.devicePixelRatio,
    );
  }

  // ===========================================================================
  // SELECTION ZOOM
  // ===========================================================================

  /// Starts selection zoom at the given position.
  void startSelectionZoom(Offset position) {
    if (!zoomConfig.enableSelectionZoom) return;

    _isSelectionZoomActive = true;
    _selectionStart = position;
    _selectionCurrent = position;
    onZoomAnimationUpdate();
  }

  /// Updates selection zoom rectangle.
  void updateSelectionZoom(Offset position) {
    if (!_isSelectionZoomActive) return;

    _selectionCurrent = position;
    onZoomAnimationUpdate();
  }

  /// Completes selection zoom and zooms to selected area.
  void completeSelectionZoom() {
    if (!_isSelectionZoomActive) return;
    if (_selectionStart == null || _selectionCurrent == null) {
      cancelSelectionZoom();
      return;
    }

    final rect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);

    // Minimum selection size (20x20 pixels)
    if (rect.width < 20 || rect.height < 20) {
      cancelSelectionZoom();
      return;
    }

    // Convert screen rect to data bounds
    final dataXMin = currentCoordSystem.screenXToDataX(rect.left);
    final dataXMax = currentCoordSystem.screenXToDataX(rect.right);
    final dataYMin = currentCoordSystem.screenYToDataY(rect.bottom); // Y inverted
    final dataYMax = currentCoordSystem.screenYToDataY(rect.top);

    // Clear selection state
    _isSelectionZoomActive = false;
    _selectionStart = null;
    _selectionCurrent = null;

    // Animate to selected bounds
    animateZoomTo(dataXMin, dataXMax, dataYMin, dataYMax);
  }

  /// Cancels selection zoom without zooming.
  void cancelSelectionZoom() {
    _isSelectionZoomActive = false;
    _selectionStart = null;
    _selectionCurrent = null;
    onZoomAnimationUpdate();
  }

  // ===========================================================================
  // ZOOM CONTROLS
  // ===========================================================================

  /// Zoom factor for zoom in/out buttons.
  static const double _controlZoomFactor = 1.5;

  /// Zooms in by control zoom factor, centered on chart.
  void zoomInByControl() {
    final centerX = (currentCoordSystem.dataXMin + currentCoordSystem.dataXMax) / 2;
    final centerY = (currentCoordSystem.dataYMin + currentCoordSystem.dataYMax) / 2;

    final currentXRange = currentCoordSystem.dataXMax - currentCoordSystem.dataXMin;
    final currentYRange = currentCoordSystem.dataYMax - currentCoordSystem.dataYMin;

    final newXRange = currentXRange / _controlZoomFactor;
    final newYRange = currentYRange / _controlZoomFactor;

    // Check max zoom level
    final origXRange = originalCoordSystem.dataXMax - originalCoordSystem.dataXMin;
    final origYRange = originalCoordSystem.dataYMax - originalCoordSystem.dataYMin;
    final minXRange = origXRange / zoomConfig.maxZoomLevel;
    final minYRange = origYRange / zoomConfig.maxZoomLevel;

    final finalXRange = newXRange < minXRange ? minXRange : newXRange;
    final finalYRange = newYRange < minYRange ? minYRange : newYRange;

    animateZoomTo(
      centerX - finalXRange / 2,
      centerX + finalXRange / 2,
      centerY - finalYRange / 2,
      centerY + finalYRange / 2,
    );
  }

  /// Zooms out by control zoom factor, centered on chart.
  void zoomOutByControl() {
    final centerX = (currentCoordSystem.dataXMin + currentCoordSystem.dataXMax) / 2;
    final centerY = (currentCoordSystem.dataYMin + currentCoordSystem.dataYMax) / 2;

    final currentXRange = currentCoordSystem.dataXMax - currentCoordSystem.dataXMin;
    final currentYRange = currentCoordSystem.dataYMax - currentCoordSystem.dataYMin;

    final newXRange = currentXRange * _controlZoomFactor;
    final newYRange = currentYRange * _controlZoomFactor;

    // Check min zoom level (max zoom out)
    final origXRange = originalCoordSystem.dataXMax - originalCoordSystem.dataXMin;
    final origYRange = originalCoordSystem.dataYMax - originalCoordSystem.dataYMin;
    final maxXRange = origXRange / zoomConfig.minZoomLevel;
    final maxYRange = origYRange / zoomConfig.minZoomLevel;

    final finalXRange = newXRange > maxXRange ? maxXRange : newXRange;
    final finalYRange = newYRange > maxYRange ? maxYRange : newYRange;

    var newXMin = centerX - finalXRange / 2;
    var newXMax = centerX + finalXRange / 2;
    var newYMin = centerY - finalYRange / 2;
    var newYMax = centerY + finalYRange / 2;

    // Constrain to original bounds when zoomed in
    if (finalXRange <= origXRange) {
      if (newXMin < originalCoordSystem.dataXMin) {
        newXMin = originalCoordSystem.dataXMin;
        newXMax = newXMin + finalXRange;
      }
      if (newXMax > originalCoordSystem.dataXMax) {
        newXMax = originalCoordSystem.dataXMax;
        newXMin = newXMax - finalXRange;
      }
    }

    if (finalYRange <= origYRange) {
      if (newYMin < originalCoordSystem.dataYMin) {
        newYMin = originalCoordSystem.dataYMin;
        newYMax = newYMin + finalYRange;
      }
      if (newYMax > originalCoordSystem.dataYMax) {
        newYMax = originalCoordSystem.dataYMax;
        newYMin = newYMax - finalYRange;
      }
    }

    animateZoomTo(newXMin, newXMax, newYMin, newYMax);
  }

  /// Resets zoom to original bounds with animation.
  void resetZoomAnimated() {
    animateZoomTo(
      originalCoordSystem.dataXMin,
      originalCoordSystem.dataXMax,
      originalCoordSystem.dataYMin,
      originalCoordSystem.dataYMax,
    );
  }

  // ===========================================================================
  // GESTURE-BASED ZOOM (MOUSE WHEEL, PINCH)
  // ===========================================================================

  /// Applies immediate zoom from gestures (pinch, mouse wheel).
  ///
  /// This is different from animated zoom - it applies zoom instantly
  /// and updates the active zoom flag.
  void applyZoom(
    double scaleFactor,
    Offset focalPoint,
    FusionInteractionHandler interactionHandler,
    void Function(bool) setHasActiveZoom,
  ) {
    final adjustedScaleFactor = interactionHandler.applyZoomSpeed(scaleFactor);

    final currentXMin = currentCoordSystem.dataXMin;
    final currentXMax = currentCoordSystem.dataXMax;
    final currentYMin = currentCoordSystem.dataYMin;
    final currentYMax = currentCoordSystem.dataYMax;

    final newBounds = interactionHandler.calculateZoomedBounds(
      adjustedScaleFactor,
      focalPoint,
      currentXMin,
      currentXMax,
      currentYMin,
      currentYMax,
    );

    final originalXMin = originalCoordSystem.dataXMin;
    final originalXMax = originalCoordSystem.dataXMax;
    final originalYMin = originalCoordSystem.dataYMin;
    final originalYMax = originalCoordSystem.dataYMax;

    final constrainedBounds = interactionHandler.constrainBounds(
      newBounds.xMin,
      newBounds.xMax,
      newBounds.yMin,
      newBounds.yMax,
      originalXMin,
      originalXMax,
      originalYMin,
      originalYMax,
    );

    currentCoordSystemValue = FusionCoordinateSystem(
      chartArea: currentCoordSystem.chartArea,
      dataXMin: constrainedBounds.xMin,
      dataXMax: constrainedBounds.xMax,
      dataYMin: constrainedBounds.yMin,
      dataYMax: constrainedBounds.yMax,
      devicePixelRatio: currentCoordSystem.devicePixelRatio,
    );

    setHasActiveZoom(true);
    onZoomAnimationUpdate();
  }

  // ===========================================================================
  // CLEANUP
  // ===========================================================================

  /// Disposes animation resources.
  void disposeZoomAnimation() {
    _zoomAnimationTimer?.cancel();
    _zoomAnimationTimer = null;
  }
}

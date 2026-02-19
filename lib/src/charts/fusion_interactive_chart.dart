import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../configuration/fusion_tooltip_configuration.dart';
import '../core/enums/fusion_dismiss_strategy.dart';
import '../core/enums/fusion_tooltip_trackball_mode.dart';
import '../core/enums/interaction_anchor_mode.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_interaction_handler.dart';
import '../series/series_with_data_points.dart';
import '../utils/fusion_desktop_helper.dart';
import 'base/fusion_cartesian_interactive_state_base.dart';
import 'mixins/fusion_live_chart_mixin.dart';

/// State manager for interactive chart features.
///
/// Works with ANY series type that implements SeriesWithDataPoints.
/// Scales to infinite chart types without modification.
///
/// Implements [FusionInteractiveStateBase] for compatibility with
/// [FusionChartBaseState].
///
/// Uses [FusionLiveChartMixin] for live streaming chart support.
class FusionInteractiveChartState
    extends FusionCartesianInteractiveStateBase<TooltipRenderData>
    with FusionLiveChartMixin<TooltipRenderData> {
  FusionInteractiveChartState({
    required super.config,
    required super.initialCoordSystem,
    required this.series,
    this.isLiveMode = false,
  });

  /// Whether this chart is in live streaming mode.
  ///
  /// In live mode:
  /// - Tooltip finds nearest point by X only (vertical time slice)
  /// - Probe mode allows persistent tooltip at a fixed X position
  ///
  /// In static mode:
  /// - Tooltip finds nearest point by 2D distance (both X and Y)
  /// - Standard tooltip behavior
  @override
  final bool isLiveMode;

  /// The current series data.
  ///
  /// For live charts, update this property then call [updateLiveTooltip]
  /// after viewport is updated for proper tooltip updates.
  List<SeriesWithDataPoints> series;

  // Crosshair state
  FusionDataPoint? _crosshairPoint;

  // Track the series that was selected during findPointAtScreenX
  // This is used by _findSeriesForPoint to return the correct series
  SeriesWithDataPoints? _lastSelectedSeries;

  // Additional timers for line charts
  Timer? _tooltipShowTimer;
  Timer? _debounceTimer;
  Timer? _tooltipAutoHideTimer;

  // Trackball position tracking
  Offset? _lastTrackballPosition;

  // Focal point tracking for scale gestures
  Offset? _lastScaleFocalPoint;

  @override
  FusionDataPoint? get crosshairPoint => _crosshairPoint;

  @override
  bool get crosshairSnapToDataPoint => config.crosshairBehavior.snapToDataPoint;

  @override
  bool get isInteracting => super.isInteracting || isSelectionZoomActive;

  // ===========================================================================
  // INITIALIZATION WITH VALIDATION
  // ===========================================================================

  @override
  @protected
  void onInitialize() {
    // Validate tooltip configuration in debug mode
    assert(() {
      config.tooltipBehavior.assertValid(
        isLiveMode: isLiveMode,
        seriesCount: series.length,
      );

      // Print warnings for potentially suboptimal configurations
      final warnings = config.tooltipBehavior.validateConfiguration(
        isLiveMode: isLiveMode,
        seriesCount: series.length,
      );
      for (final warning in warnings) {
        debugPrint('⚠️ FusionTooltipBehavior warning: $warning');
      }

      return true;
    }());
  }

  List<FusionDataPoint> get _allDataPoints {
    return series.where((s) => s.visible).expand((s) => s.dataPoints).toList();
  }

  /// Finds the nearest data point by screen X position with dynamic threshold.
  ///
  /// Uses the CURRENT coordinate system (not the handler's potentially stale one).
  /// This is critical for live charts where the coordinate system changes rapidly.
  ///
  /// For multiple series, uses **adaptive threshold** based on how close series
  /// are at the tap position:
  /// - When lines are far apart: uses full threshold (trackballSnapRadius)
  /// - When lines are close: shrinks threshold to half the distance between them
  /// - When lines overlap: must tap directly on the line
  ///
  /// **Exception**: When `shared` tooltip is enabled, threshold is bypassed
  /// to always return a point (the closest series). This ensures shared tooltips
  /// can show all series data at the tapped X position.
  ///
  /// Returns null if no series is within the dynamic threshold (unless shared mode).
  ///
  /// OPTIMIZATION: Uses binary search for sorted single-series data (O(log n)).
  @override
  FusionDataPoint? findPointAtScreenX(double screenX, {double? screenY}) {
    final visibleSeries = series.where((s) => s.visible).toList();
    if (visibleSeries.isEmpty) return null;

    // Single series: use simple binary search (no threshold needed for single line)
    if (visibleSeries.length == 1) {
      return _findNearestInSingleSeries(visibleSeries.first, screenX, screenY);
    }

    // Multiple series: use dynamic threshold selection
    // For shared tooltips, we bypass threshold to always show all series data
    final useThreshold = !config.tooltipBehavior.shared;
    return _findWithDynamicThreshold(
      visibleSeries,
      screenX,
      screenY,
      useThreshold: useThreshold,
    );
  }

  /// Finds nearest point in a single series using binary search.
  FusionDataPoint? _findNearestInSingleSeries(
    SeriesWithDataPoints singleSeries,
    double screenX,
    double? screenY,
  ) {
    final points = singleSeries.dataPoints;
    if (points.isEmpty) return null;

    // Track which series was selected
    _lastSelectedSeries = singleSeries;

    if (points.length == 1) return points.first;

    final targetDataX = currentCoordSystem.screenXToDataX(screenX);
    return _binarySearchNearestByX(points, targetDataX);
  }

  /// Finds point using dynamic threshold for multi-series charts.
  ///
  /// The threshold adapts based on how close series are at the tap X position:
  /// - Interpolates Y value for each series at tap X
  /// - Calculates distance to nearest neighbor series
  /// - Uses min(maxThreshold, distanceToNearest / 2) as selection radius
  ///
  /// When [useThreshold] is false (for shared tooltips), always returns the
  /// closest series without threshold rejection.
  FusionDataPoint? _findWithDynamicThreshold(
    List<SeriesWithDataPoints> visibleSeries,
    double screenX,
    double? screenY, {
    bool useThreshold = true,
  }) {
    final targetDataX = currentCoordSystem.screenXToDataX(screenX);
    final pointerY = screenY ?? lastPointerPosition?.dy;

    // Max threshold from configuration
    final maxThreshold = config.tooltipBehavior.trackballSnapRadius;

    // Step 1: For each series, find/interpolate Y at target X and convert to screen coords
    final seriesAtX = <_SeriesAtX>[];

    for (final s in visibleSeries) {
      final interpolated = _interpolateYAtX(s.dataPoints, targetDataX);
      if (interpolated == null) continue;

      final seriesScreenY = currentCoordSystem.dataYToScreenY(interpolated.y);
      seriesAtX.add(
        _SeriesAtX(
          series: s,
          point: interpolated.point,
          interpolatedY: interpolated.y,
          screenY: seriesScreenY,
        ),
      );
    }

    if (seriesAtX.isEmpty) return null;
    if (seriesAtX.length == 1) {
      // Single series visible at this X - use max threshold
      if (pointerY == null) return seriesAtX.first.point;
      final dist = (seriesAtX.first.screenY - pointerY).abs();
      return dist <= maxThreshold ? seriesAtX.first.point : null;
    }

    // Step 2: Sort by screen Y for distance calculations
    seriesAtX.sort((a, b) => a.screenY.compareTo(b.screenY));

    // Step 3: Calculate dynamic threshold for each series
    for (int i = 0; i < seriesAtX.length; i++) {
      double distanceToNearest = double.infinity;

      // Check distance to previous series
      if (i > 0) {
        final dist = (seriesAtX[i].screenY - seriesAtX[i - 1].screenY).abs();
        if (dist < distanceToNearest) distanceToNearest = dist;
      }

      // Check distance to next series
      if (i < seriesAtX.length - 1) {
        final dist = (seriesAtX[i].screenY - seriesAtX[i + 1].screenY).abs();
        if (dist < distanceToNearest) distanceToNearest = dist;
      }

      // Dynamic threshold: half the distance to nearest, capped at max
      // This prevents overlap between selection zones
      seriesAtX[i].dynamicThreshold = (distanceToNearest / 2).clamp(
        0,
        maxThreshold,
      );
    }

    // Step 4: Find series within threshold, closest to pointer
    if (pointerY == null) return seriesAtX.first.point;

    _SeriesAtX? bestMatch;
    double bestDistance = double.infinity;

    // Track the absolute closest series (ignoring threshold) for fallback
    _SeriesAtX? absoluteClosest;
    double absoluteClosestDistance = double.infinity;

    // Small epsilon for floating point comparison to prevent rapid switching
    // at boundaries due to sub-pixel movements
    const epsilon = 0.5;

    for (final s in seriesAtX) {
      final distance = (s.screenY - pointerY).abs();

      // Always track absolute closest for fallback (handles overlapping lines)
      if (distance < absoluteClosestDistance ||
          (distance == absoluteClosestDistance &&
              absoluteClosest != null &&
              s.screenY > absoluteClosest.screenY)) {
        absoluteClosestDistance = distance;
        absoluteClosest = s;
      }

      if (useThreshold) {
        // Only consider if within this series' dynamic threshold
        // Use < for threshold to create clean boundaries between selection zones
        if (distance < s.dynamicThreshold) {
          // Strictly closer - always prefer
          if (distance < bestDistance - epsilon) {
            bestDistance = distance;
            bestMatch = s;
          }
          // Within epsilon - prefer the one closer to pointer direction
          // (if pointer is below midpoint, prefer lower series)
          else if ((bestDistance - distance).abs() <= epsilon) {
            // Tie-breaker: prefer the series that's on the same side as pointer
            // relative to the midpoint between this series and current best
            if (bestMatch != null) {
              final midpoint = (s.screenY + bestMatch.screenY) / 2;
              final pointerBelowMidpoint = pointerY > midpoint;
              final thisSeriesIsLower = s.screenY > bestMatch.screenY;
              if (pointerBelowMidpoint == thisSeriesIsLower) {
                bestDistance = distance;
                bestMatch = s;
              }
            } else {
              bestDistance = distance;
              bestMatch = s;
            }
          }
        }
      } else {
        // Shared tooltip mode: always pick the closest, no threshold
        if (distance < bestDistance - epsilon) {
          bestDistance = distance;
          bestMatch = s;
        } else if ((bestDistance - distance).abs() <= epsilon &&
            bestMatch != null) {
          // Tie-breaker for shared mode
          final midpoint = (s.screenY + bestMatch.screenY) / 2;
          final pointerBelowMidpoint = pointerY > midpoint;
          final thisSeriesIsLower = s.screenY > bestMatch.screenY;
          if (pointerBelowMidpoint == thisSeriesIsLower) {
            bestDistance = distance;
            bestMatch = s;
          }
        }
      }
    }

    // Fallback: if no match within threshold but pointer is very close to a series
    // (e.g., overlapping lines with threshold=0), return the absolute closest.
    // Only apply fallback when the tap is actually near the lines (within max threshold).
    if (bestMatch == null &&
        absoluteClosest != null &&
        absoluteClosestDistance <= maxThreshold) {
      _lastSelectedSeries = absoluteClosest.series;
      return absoluteClosest.point;
    }

    // Track which series was selected for use by _findSeriesForPoint
    if (bestMatch != null) {
      _lastSelectedSeries = bestMatch.series;
    }

    return bestMatch?.point;
  }

  /// Interpolates the Y value at a given X position within a series.
  ///
  /// If X falls between two data points, linearly interpolates.
  /// If X is outside the data range, returns the nearest endpoint.
  /// Returns both the interpolated Y and the nearest actual data point.
  ({double y, FusionDataPoint point})? _interpolateYAtX(
    List<FusionDataPoint> points,
    double targetX,
  ) {
    if (points.isEmpty) return null;
    if (points.length == 1) {
      return (y: points.first.y, point: points.first);
    }

    // Find the two points surrounding targetX
    // Assuming points are sorted by X (which they should be within a single series)
    int? leftIdx;
    int? rightIdx;

    for (int i = 0; i < points.length; i++) {
      if (points[i].x <= targetX) {
        leftIdx = i;
      }
      if (points[i].x >= targetX && rightIdx == null) {
        rightIdx = i;
      }
    }

    // Handle edge cases
    if (leftIdx == null) {
      // Target is before all points
      return (y: points.first.y, point: points.first);
    }
    if (rightIdx == null) {
      // Target is after all points
      return (y: points.last.y, point: points.last);
    }
    if (leftIdx == rightIdx) {
      // Exact match
      return (y: points[leftIdx].y, point: points[leftIdx]);
    }

    // Linear interpolation between left and right points
    final leftPoint = points[leftIdx];
    final rightPoint = points[rightIdx];

    final xRange = rightPoint.x - leftPoint.x;
    if (xRange.abs() < 0.0001) {
      // Points are at same X, return left point
      return (y: leftPoint.y, point: leftPoint);
    }

    final t = (targetX - leftPoint.x) / xRange;
    final interpolatedY = leftPoint.y + t * (rightPoint.y - leftPoint.y);

    // Return the closer actual point for tooltip display
    final leftDist = (targetX - leftPoint.x).abs();
    final rightDist = (targetX - rightPoint.x).abs();
    final nearerPoint = leftDist <= rightDist ? leftPoint : rightPoint;

    return (y: interpolatedY, point: nearerPoint);
  }

  /// Binary search to find the nearest point by data X value.
  /// Assumes points are sorted by X in ascending order.
  FusionDataPoint _binarySearchNearestByX(
    List<FusionDataPoint> points,
    double targetX,
  ) {
    int left = 0;
    int right = points.length - 1;

    // Binary search to find insertion point
    while (left < right) {
      final mid = (left + right) ~/ 2;

      if (points[mid].x < targetX) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    // Now 'left' is the index where targetX would be inserted.
    // The nearest point is either at 'left' or 'left - 1'.
    if (left == 0) {
      return points[0];
    }
    if (left >= points.length) {
      return points.last;
    }

    // Compare distances to both candidates
    final leftDist = (points[left].x - targetX).abs();
    final prevDist = (points[left - 1].x - targetX).abs();

    return prevDist <= leftDist ? points[left - 1] : points[left];
  }

  // ===========================================================================
  // LIVE CHART MIXIN IMPLEMENTATION
  // ===========================================================================

  /// Shows tooltip for a point found during live update.
  ///
  /// Implementation of [FusionLiveChartMixin.showLiveTooltipForPoint].
  @override
  void showLiveTooltipForPoint(FusionDataPoint point, double queryScreenX) {
    final seriesInfo = _findSeriesForPoint(point);
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    // Position tooltip at the query X (finger/probe position), using point's Y
    final tooltipPosition = Offset(
      queryScreenX,
      currentCoordSystem.dataYToScreenY(point.y),
    );

    setTooltipData(
      TooltipRenderData(
        point: point,
        seriesName: seriesInfo.name,
        seriesColor: seriesInfo.color,
        screenPosition: tooltipPosition,
        wasLongPress: tooltipData?.wasLongPress ?? false,
        activationTime: tooltipData?.activationTime,
        sharedPoints: sharedPoints,
      ),
    );
  }

  /// Shows crosshair for a point found during live update.
  ///
  /// Implementation of [FusionLiveChartMixin.showLiveCrosshairForPoint].
  @override
  void showLiveCrosshairForPoint(FusionDataPoint point, double queryScreenX) {
    // Calculate crosshair position based on snap configuration
    Offset crosshairPos;

    if (crosshairSnapToDataPoint) {
      // Snap to data point position
      crosshairPos = currentCoordSystem.dataToScreen(point);
    } else {
      // Position at query X with point's Y
      crosshairPos = Offset(
        queryScreenX,
        currentCoordSystem.dataYToScreenY(point.y),
      );
    }

    // Update crosshair state
    crosshairPosition = crosshairPos;
    _crosshairPoint = point;

    // Update anchor state if using dataPoint anchor mode
    if (config.interactionAnchorMode == InteractionAnchorMode.dataPoint) {
      setAnchoredCrosshairData(point.x, point.y);
    }

    notifyListeners();
  }

  // ===========================================================================
  // INTERACTION HANDLER WITH CALLBACKS
  // ===========================================================================

  @override
  FusionInteractionHandler createInteractionHandler() {
    return FusionInteractionHandler(
      coordSystem: currentCoordSystem,
      zoomConfig: config.zoomBehavior,
      panConfig: config.panBehavior,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onPanStart: handlePanStart,
      onPanUpdate: handlePanUpdate,
      onPanEnd: handlePanEnd,
      onScaleStart: handleScaleStart,
      onScaleUpdate: handleScaleUpdate,
      onScaleEnd: handleScaleEnd,
      onHover: _handleHover,
    );
  }

  // ===========================================================================
  // TAP & HOVER HANDLING
  // ===========================================================================

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

  /// Callback for interaction handler hover events.
  ///
  /// Note: This callback is registered but hover events are currently routed
  /// directly through [onPointerHover] instead. This exists for potential
  /// future use with the interaction handler's hover mechanism.
  void _handleHover(Offset position) {
    if (!config.enableTooltip && !config.enableCrosshair) return;

    // Use findPointAtScreenX for proper multi-series selection with dynamic threshold
    final visibleSeries = series.where((s) => s.visible).toList();
    FusionDataPoint? nearestPoint;

    if (visibleSeries.length > 1) {
      nearestPoint = findPointAtScreenX(position.dx, screenY: position.dy);
    } else {
      nearestPoint = interactionHandler?.findNearestPoint(
        _allDataPoints,
        position,
      );
    }

    if (nearestPoint != null) {
      if (config.enableTooltip) {
        _showTooltip(nearestPoint, position);
      }
      if (config.enableCrosshair) {
        _showCrosshair(position, nearestPoint);
      }
    } else {
      hideTooltip();
      hideCrosshair();
    }
  }

  // ===========================================================================
  // POINTER EVENT IMPLEMENTATIONS
  // ===========================================================================

  @override
  void onPointerDown(Offset position) {
    _tooltipShowTimer?.cancel();
    cancelTooltipHideTimer();

    // Check for selection zoom (desktop only: Shift + mouse drag)
    if (config.enableZoom &&
        config.zoomBehavior.enableSelectionZoom &&
        FusionDesktopHelper.isShiftPressed) {
      startSelectionZoom(position);
      return;
    }

    if (!config.enableTooltip) return;

    if (isLiveMode) {
      // LIVE MODE: Find nearest point by X only (vertical time slice)
      // This shows data at the finger's X position regardless of Y distance
      // Pass Y position to select correct series when multiple have same X
      final point = findPointAtScreenX(position.dx, screenY: position.dy);

      if (point != null) {
        _showTooltipAtFingerPosition(point, position, false);
      }
    } else {
      // STATIC MODE: Use dynamic threshold for multi-series, 2D distance for single
      final visibleSeries = series.where((s) => s.visible).toList();
      FusionDataPoint? point;

      if (visibleSeries.length > 1) {
        // Multi-series: use dynamic threshold selection based on Y position
        point = findPointAtScreenX(position.dx, screenY: position.dy);
      } else {
        // Single series: use simple 2D distance
        point = interactionHandler?.findNearestPoint(_allDataPoints, position);
      }

      if (point != null) {
        _showTooltipWithDelay(point, position, false);
      }
    }
  }

  /// Shows tooltip at the finger position (for live charts).
  /// Unlike _showTooltipWithDelay, this positions tooltip at the finger X,
  /// not at the data point's current screen position.
  void _showTooltipAtFingerPosition(
    FusionDataPoint point,
    Offset fingerPosition,
    bool wasLongPress,
  ) {
    cancelTooltipHideTimer();

    if (config.tooltipBehavior.hapticFeedback && tooltipData == null) {
      HapticFeedback.selectionClick();
    }

    final seriesInfo = _findSeriesForPoint(point);
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    // Set probe mode for dismissStrategy: never
    if (config.tooltipBehavior.dismissStrategy == FusionDismissStrategy.never) {
      setProbePosition(fingerPosition);
    }

    // Position tooltip at the finger X, using the point's Y for vertical position
    final tooltipPosition = Offset(
      fingerPosition.dx,
      currentCoordSystem.dataYToScreenY(point.y),
    );

    setTooltipData(
      TooltipRenderData(
        point: point,
        seriesName: seriesInfo.name,
        seriesColor: seriesInfo.color,
        screenPosition: tooltipPosition,
        wasLongPress: wasLongPress,
        activationTime: DateTime.now(),
        sharedPoints: sharedPoints,
      ),
    );

    notifyListeners();
  }

  @override
  void onPointerMove(Offset position) {
    // Update selection rectangle if selection zoom is active
    if (isSelectionZoomActive) {
      updateSelectionZoom(position);
      return;
    }

    // Update crosshair if active (during long press drag)
    if (config.enableCrosshair && crosshairPosition != null) {
      _updateCrosshairPosition(position);
      // Don't update tooltip while crosshair is active - they shouldn't overlap
      return;
    }

    // Update tooltip trackball if enabled (only when crosshair is not active)
    if (config.enableTooltip) {
      final trackballMode = config.tooltipBehavior.trackballMode;
      if (trackballMode == FusionTooltipTrackballMode.none) return;

      if (_lastTrackballPosition != null) {
        final distance = (position - _lastTrackballPosition!).distance;
        if (distance < config.tooltipBehavior.trackballUpdateThreshold) {
          return;
        }
      }

      // When pointer is down (active dragging), update immediately for responsiveness
      // Only use debounce for hover events to reduce CPU usage
      if (isPointerDown) {
        _debounceTimer?.cancel();
        _updateTrackball(position, trackballMode);
      } else {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(
          const Duration(milliseconds: 16),
          () => _updateTrackball(position, trackballMode),
        );
      }
    }
  }

  @override
  void onPointerUp(bool wasLongPress) {
    _lastTrackballPosition = null;

    // Complete selection zoom if active
    if (isSelectionZoomActive &&
        selectionStart != null &&
        selectionCurrent != null) {
      completeSelectionZoom();
      return;
    }

    if (config.enableTooltip && tooltipData != null) {
      final tooltipBehavior = config.tooltipBehavior;

      if (tooltipBehavior.shouldDismissOnRelease()) {
        final delay = tooltipBehavior.getDismissDelay(wasLongPress);
        if (delay == Duration.zero) {
          _hideTooltipAnimated();
        } else {
          startTooltipHideTimer(delay);
        }
      } else if (tooltipBehavior.shouldUseTimer()) {
        startTooltipHideTimer(tooltipBehavior.duration);
      }
    }

    if (config.enableCrosshair && crosshairPosition != null) {
      final crosshairBehavior = config.crosshairBehavior;

      if (crosshairBehavior.shouldDismissOnRelease()) {
        final delay = crosshairBehavior.getDismissDelay(wasLongPress);

        if (delay == Duration.zero) {
          _hideCrosshairAnimated();
        } else {
          startCrosshairHideTimer(delay);
        }
      } else if (crosshairBehavior.shouldUseTimer()) {
        startCrosshairHideTimer(crosshairBehavior.duration);
      }
    }
  }

  @override
  void handlePointerCancel(PointerCancelEvent event) {
    _lastTrackballPosition = null;

    // Cancel selection zoom if active
    if (isSelectionZoomActive) {
      cancelSelectionZoom();
    }

    super.handlePointerCancel(event);
  }

  @override
  void onPointerHover(Offset position) {
    if (!config.enableTooltip) return;

    FusionDataPoint? point;

    if (isLiveMode) {
      // LIVE MODE: Find nearest point by X only (vertical time slice)
      point = findPointAtScreenX(position.dx, screenY: position.dy);

      if (point != null) {
        // ALWAYS set probe position in live mode during hover
        // This is CRITICAL for multi-series: updateLiveTooltip (triggered by live data
        // updates via notifyListeners) needs the Y position to select the correct series.
        // Without the stored Y, it would default to the first series.
        setProbePosition(position);
      }
    } else {
      // STATIC MODE: Use dynamic threshold for multi-series
      final visibleSeries = series.where((s) => s.visible).toList();
      if (visibleSeries.length > 1) {
        point = findPointAtScreenX(position.dx, screenY: position.dy);
      } else {
        point = interactionHandler?.findNearestPoint(_allDataPoints, position);
      }
    }

    if (point != null) {
      _showTooltipWithDelay(point, position, false);
    } else {
      _hideTooltipAnimated();
    }
  }

  @override
  void onPointerExit() {
    // Clear hover probe when mouse leaves chart area
    clearProbePosition();
    _lastTrackballPosition = null;
    super.onPointerExit();
  }

  // ===========================================================================
  // CROSSHAIR MANAGEMENT
  // ===========================================================================

  void _updateCrosshairPosition(Offset position) {
    cancelCrosshairHideTimer();

    final clampedPosition = clampPositionToCoordSystem(position);

    // Use dynamic threshold for multi-series to select correct series based on Y
    final visibleSeries = series.where((s) => s.visible).toList();
    FusionDataPoint? nearestPoint;
    if (visibleSeries.length > 1) {
      nearestPoint = findPointAtScreenX(
        clampedPosition.dx,
        screenY: clampedPosition.dy,
      );
    } else {
      nearestPoint = interactionHandler?.findNearestPoint(
        _allDataPoints,
        clampedPosition,
      );
    }

    if (nearestPoint != null && config.crosshairBehavior.snapToDataPoint) {
      final snappedPosition = currentCoordSystem.dataToScreen(nearestPoint);
      crosshairPosition = snappedPosition;
      _crosshairPoint = nearestPoint;
    } else {
      crosshairPosition = clampedPosition;
      _crosshairPoint = nearestPoint;
    }

    notifyListeners();
  }

  void _showCrosshair(Offset position, FusionDataPoint? snappedPoint) {
    cancelCrosshairHideTimer();

    // Hide tooltip when crosshair is activated - they shouldn't overlap
    if (tooltipData != null) {
      hideTooltip();
    }

    crosshairPosition = position;
    _crosshairPoint = snappedPoint;

    // Set anchor state if using dataPoint anchor mode
    if (config.interactionAnchorMode == InteractionAnchorMode.dataPoint) {
      if (snappedPoint != null) {
        setAnchoredCrosshairData(snappedPoint.x, snappedPoint.y);
      } else {
        // Convert screen position to data coordinates for anchoring
        final dataX = currentCoordSystem.screenXToDataX(position.dx);
        final dataY = currentCoordSystem.screenYToDataY(position.dy);
        setAnchoredCrosshairData(dataX, dataY);
      }
    }

    notifyListeners();

    final behavior = config.crosshairBehavior;
    if (behavior.dismissStrategy != FusionDismissStrategy.never) {
      if (behavior.shouldUseTimer()) {
        startCrosshairHideTimer(behavior.duration);
      }
    }
  }

  @override
  void hideCrosshair() {
    if (crosshairPosition != null) {
      crosshairPosition = null;
      _crosshairPoint = null;
      // Clear anchor state
      setAnchoredCrosshairData(null, null);
      notifyListeners();
    }
  }

  void _hideCrosshairAnimated() {
    cancelCrosshairHideTimer();

    if (crosshairPosition != null) {
      crosshairPosition = null;
      _crosshairPoint = null;
      notifyListeners();
    }
  }

  // ===========================================================================
  // TRACKBALL IMPLEMENTATION
  // ===========================================================================

  void _updateTrackball(Offset position, FusionTooltipTrackballMode mode) {
    FusionDataPoint? targetPoint;
    Offset? effectiveScreenPosition;

    switch (mode) {
      case FusionTooltipTrackballMode.none:
        return;

      case FusionTooltipTrackballMode.follow:
        // Follow mode: find nearest point, position tooltip at finger location
        // Use dynamic threshold for multi-series to select correct series based on Y
        final visibleSeriesFollow = series.where((s) => s.visible).toList();
        if (visibleSeriesFollow.length > 1) {
          targetPoint = findPointAtScreenX(position.dx, screenY: position.dy);
        } else if (config.tooltipBehavior.shared) {
          targetPoint = interactionHandler?.findNearestPointByX(
            _allDataPoints,
            position,
          );
        } else {
          targetPoint = interactionHandler?.findNearestPoint(
            _allDataPoints,
            position,
          );
        }
        if (targetPoint != null) {
          // Position at finger X, data point Y for vertical tracking
          effectiveScreenPosition = Offset(
            position.dx,
            currentCoordSystem.dataYToScreenY(targetPoint.y),
          );
        }

      case FusionTooltipTrackballMode.snapToX:
        // SnapToX mode: find nearest by X, snap to data point X position
        targetPoint = interactionHandler?.findNearestPointByX(
          _allDataPoints,
          position,
        );
        if (targetPoint != null) {
          // Snap X to data point, use finger Y or average Y for shared
          final dataScreenX = currentCoordSystem.dataXToScreenX(targetPoint.x);
          effectiveScreenPosition = Offset(
            dataScreenX,
            currentCoordSystem.dataYToScreenY(targetPoint.y),
          );
        }

      case FusionTooltipTrackballMode.snapToY:
        targetPoint = interactionHandler?.findNearestPointByY(
          _allDataPoints,
          position,
        );
        if (targetPoint != null) {
          effectiveScreenPosition = currentCoordSystem.dataToScreen(
            targetPoint,
          );
        }

      case FusionTooltipTrackballMode.snap:
        // Use dynamic threshold for multi-series to select correct series based on Y
        final visibleSeriesSnap = series.where((s) => s.visible).toList();
        FusionDataPoint? nearest;
        if (visibleSeriesSnap.length > 1) {
          nearest = findPointAtScreenX(position.dx, screenY: position.dy);
        } else {
          nearest = interactionHandler?.findNearestPoint(
            _allDataPoints,
            position,
          );
        }
        if (nearest != null) {
          final screenPos = currentCoordSystem.dataToScreen(nearest);
          final distance = (screenPos - position).distance;
          if (distance < config.tooltipBehavior.trackballSnapRadius) {
            targetPoint = nearest;
            effectiveScreenPosition = screenPos;
          } else {
            if (tooltipData != null) {
              return;
            }
            targetPoint = nearest;
            effectiveScreenPosition = screenPos;
          }
        }

      case FusionTooltipTrackballMode.magnetic:
        final result = _findMagneticTarget(position);
        targetPoint = result.point;
        effectiveScreenPosition = result.magneticOffset;
        if (targetPoint != null && effectiveScreenPosition == null) {
          effectiveScreenPosition = currentCoordSystem.dataToScreen(
            targetPoint,
          );
        }
    }

    if (targetPoint != null) {
      _lastTrackballPosition = position;
      _updateTooltipPosition(
        targetPoint,
        position,
        effectiveScreenPosition: effectiveScreenPosition,
      );
    }
  }

  ({FusionDataPoint? point, Offset? magneticOffset}) _findMagneticTarget(
    Offset position,
  ) {
    // Use dynamic threshold for multi-series to select correct series based on Y
    final visibleSeries = series.where((s) => s.visible).toList();
    FusionDataPoint? nearest;
    if (visibleSeries.length > 1) {
      nearest = findPointAtScreenX(position.dx, screenY: position.dy);
    } else {
      nearest = interactionHandler?.findNearestPoint(_allDataPoints, position);
    }

    if (nearest == null) return (point: null, magneticOffset: null);

    final screenPos = currentCoordSystem.dataToScreen(nearest);
    final distance = (screenPos - position).distance;
    final snapRadius = config.tooltipBehavior.trackballSnapRadius;

    if (distance < snapRadius) {
      final magnetStrength = 1.0 - (distance / snapRadius);
      final easedStrength = magnetStrength * magnetStrength;

      final magneticOffset = Offset(
        position.dx + (screenPos.dx - position.dx) * easedStrength,
        position.dy + (screenPos.dy - position.dy) * easedStrength,
      );

      return (point: nearest, magneticOffset: magneticOffset);
    }

    return (point: nearest, magneticOffset: null);
  }

  void _updateTooltipPosition(
    FusionDataPoint point,
    Offset position, {
    Offset? effectiveScreenPosition,
  }) {
    final seriesInfo = _findSeriesForPoint(point);

    // Use provided screen position or default to data point's position
    final screenPos =
        effectiveScreenPosition ?? currentCoordSystem.dataToScreen(point);

    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    // Update probe position when dragging (for dismissStrategy: never)
    if (config.tooltipBehavior.dismissStrategy == FusionDismissStrategy.never) {
      setProbePosition(position);
    }

    setTooltipData(
      TooltipRenderData(
        point: point,
        seriesName: seriesInfo.name,
        seriesColor: seriesInfo.color,
        screenPosition: screenPos,
        wasLongPress: tooltipData?.wasLongPress ?? false,
        activationTime: tooltipData?.activationTime,
        sharedPoints: sharedPoints,
      ),
    );

    notifyListeners();
  }

  // ===========================================================================
  // TOOLTIP SHOW/HIDE
  // ===========================================================================

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
        if (isPointerDown) {
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
    cancelTooltipHideTimer();

    if (config.tooltipBehavior.hapticFeedback) {
      HapticFeedback.selectionClick();
    }

    final seriesInfo = _findSeriesForPoint(point);
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    // Set anchor state if using dataPoint anchor mode
    if (config.interactionAnchorMode == InteractionAnchorMode.dataPoint) {
      anchoredDataPoint = point;
    }

    // Set probe mode for live charts with dismissStrategy: never
    // This enables the tooltip to show live data at the tapped X position
    if (config.tooltipBehavior.dismissStrategy == FusionDismissStrategy.never) {
      setProbePosition(position);
    }

    setTooltipData(
      TooltipRenderData(
        point: point,
        seriesName: seriesInfo.name,
        seriesColor: seriesInfo.color,
        screenPosition: currentCoordSystem.dataToScreen(point),
        wasLongPress: wasLongPress,
        activationTime: DateTime.now(),
        sharedPoints: sharedPoints,
      ),
    );

    notifyListeners();

    if (!isPointerDown && config.tooltipBehavior.shouldUseTimer()) {
      startTooltipHideTimer(
        config.tooltipBehavior.getDismissDelay(wasLongPress),
      );
    }
  }

  void _hideTooltipAnimated() {
    if (tooltipData == null) return;

    cancelTooltipHideTimer();
    _tooltipShowTimer?.cancel();

    // Clear probe mode
    clearProbePosition();

    setTooltipData(null);
    notifyListeners();
  }

  void _showTooltip(FusionDataPoint point, Offset position) {
    final seriesInfo = _findSeriesForPoint(point);
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(point)
        : null;

    // Set anchor state if using dataPoint anchor mode
    if (config.interactionAnchorMode == InteractionAnchorMode.dataPoint) {
      anchoredDataPoint = point;
    }

    // Set probe mode for live charts with dismissStrategy: never
    if (config.tooltipBehavior.dismissStrategy == FusionDismissStrategy.never) {
      setProbePosition(position);
    }

    setTooltipData(
      TooltipRenderData(
        point: point,
        seriesName: seriesInfo.name,
        seriesColor: seriesInfo.color,
        screenPosition: currentCoordSystem.dataToScreen(point),
        sharedPoints: sharedPoints,
      ),
    );
    notifyListeners();

    if (config.tooltipBehavior.dismissStrategy != FusionDismissStrategy.never) {
      _tooltipAutoHideTimer?.cancel();
      _tooltipAutoHideTimer = Timer(
        config.tooltipBehavior.duration,
        hideTooltip,
      );
    }
  }

  @override
  void hideTooltip() {
    // Cancel both timers to ensure no stale callbacks
    _tooltipAutoHideTimer?.cancel();
    _tooltipAutoHideTimer = null;
    cancelTooltipHideTimer(); // Base class timer

    if (tooltipData != null) {
      setTooltipData(null);
      // Clear anchor state
      anchoredDataPoint = null;
      // Clear probe mode
      clearProbePosition();
      notifyListeners();
    }
  }

  @override
  void onAnchoredTooltipPositionUpdate(FusionDataPoint anchoredPoint) {
    // Update tooltip screen position when viewport changes (for dataPoint anchor mode)
    if (tooltipData == null) return;

    final seriesInfo = _findSeriesForPoint(anchoredPoint);
    final sharedPoints = config.tooltipBehavior.shared
        ? _findPointsAtSameX(anchoredPoint)
        : null;

    setTooltipData(
      TooltipRenderData(
        point: anchoredPoint,
        seriesName: seriesInfo.name,
        seriesColor: seriesInfo.color,
        screenPosition: currentCoordSystem.dataToScreen(anchoredPoint),
        wasLongPress: tooltipData?.wasLongPress ?? false,
        activationTime: tooltipData?.activationTime,
        sharedPoints: sharedPoints,
      ),
    );
  }

  SeriesWithDataPoints _findSeriesForPoint(FusionDataPoint point) {
    // First, check if we have a tracked series from the last selection
    // This ensures we return the correct series even when multiple series
    // have points at the same coordinates
    if (_lastSelectedSeries != null) {
      final existsInSelected = _lastSelectedSeries!.dataPoints.any(
        (p) => (p.x - point.x).abs() < 0.0001 && (p.y - point.y).abs() < 0.0001,
      );
      if (existsInSelected) {
        return _lastSelectedSeries!;
      }
    }

    // Fallback: search all series (with fuzzy comparison for floating point)
    for (final s in series) {
      final exists = s.dataPoints.any(
        (p) => (p.x - point.x).abs() < 0.0001 && (p.y - point.y).abs() < 0.0001,
      );
      if (exists) {
        return s;
      }
    }
    return series.first;
  }

  /// Finds all other series data at the same X position as [point].
  ///
  /// Uses interpolation to find Y values for series that don't have
  /// data points at exactly the same X. This ensures shared tooltips
  /// work correctly even when series have different data point densities.
  List<SharedTooltipPoint> _findPointsAtSameX(FusionDataPoint point) {
    final sharedPoints = <SharedTooltipPoint>[];
    final targetX = point.x;

    for (final s in series) {
      if (!s.visible) continue;
      if (s.dataPoints.isEmpty) continue;

      // Use interpolation to find Y at targetX for this series
      final interpolated = _interpolateYAtX(s.dataPoints, targetX);
      if (interpolated == null) continue;

      // Skip if this is the primary point
      if (interpolated.point.x == point.x && interpolated.point.y == point.y) {
        continue;
      }

      // Create shared point with interpolated screen position
      // Use the actual nearest data point for display, but position at interpolated Y
      final screenPosition = Offset(
        currentCoordSystem.dataXToScreenX(targetX),
        currentCoordSystem.dataYToScreenY(interpolated.y),
      );

      sharedPoints.add(
        SharedTooltipPoint(
          point: interpolated.point,
          seriesName: s.name,
          seriesColor: s.color,
          screenPosition: screenPosition,
        ),
      );
    }

    return sharedPoints;
  }

  // ===========================================================================
  // GESTURE RECOGNIZER OVERRIDES
  // ===========================================================================

  @override
  int computeGestureConfigHash() {
    return Object.hash(
      super.computeGestureConfigHash(),
      config.zoomBehavior.enableSelectionZoom,
    );
  }

  @override
  void onTapDown(Offset position) {
    interactionHandler?.handleTapDown(position, _allDataPoints);
  }

  @override
  void onLongPressStart(Offset position) {
    interactionHandler?.handleLongPress(position, _allDataPoints);
  }

  @override
  void onLongPressMoveUpdate(Offset position) {
    if (crosshairPosition != null) {
      _updateCrosshairPosition(position);
    }
  }

  @override
  GestureRecognizerFactory<ScaleGestureRecognizer> buildScaleRecognizer() {
    return GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
      ScaleGestureRecognizer.new,
      (recognizer) {
        recognizer
          ..onStart = (details) {
            _lastScaleFocalPoint = details.localFocalPoint;
            handleScaleStart(details.localFocalPoint);
          }
          ..onUpdate = (details) {
            const scaleTolerance = 0.01;
            final scaleChange = (details.scale - 1.0).abs();
            if (scaleChange < scaleTolerance) {
              if (!isPanning) {
                handlePanStart(details.localFocalPoint);
              }
              if (_lastScaleFocalPoint != null) {
                final delta = details.localFocalPoint - _lastScaleFocalPoint!;
                handlePanUpdate(delta);
              }
              _lastScaleFocalPoint = details.localFocalPoint;
            } else {
              final scaleDelta = details.scale / _localLastScale;
              _localLastScale = details.scale;
              handleScaleUpdate(scaleDelta, details.localFocalPoint);
            }
          }
          ..onEnd = (details) {
            if (isPanning) {
              handlePanEnd();
            }
            if (isZooming) {
              handleScaleEnd();
            }
            _lastScaleFocalPoint = null;
            _localLastScale = 1.0;
          };
      },
    );
  }

  // Local scale tracking since base class _lastScale is private
  double _localLastScale = 1.0;

  @override
  void dispose() {
    _tooltipShowTimer?.cancel();
    _debounceTimer?.cancel();
    _tooltipAutoHideTimer?.cancel();
    super.dispose();
  }
}

// =============================================================================
// HELPER CLASSES
// =============================================================================

/// Helper class for dynamic threshold calculation.
///
/// Stores information about a series at a specific X position for
/// multi-series tooltip selection with adaptive threshold.
class _SeriesAtX {
  _SeriesAtX({
    required this.series,
    required this.point,
    required this.interpolatedY,
    required this.screenY,
  }) : dynamicThreshold = 0;

  /// The series this data belongs to.
  final SeriesWithDataPoints series;

  /// The nearest actual data point (for tooltip display).
  final FusionDataPoint point;

  /// The interpolated Y value at the target X position.
  final double interpolatedY;

  /// The screen Y coordinate of the interpolated position.
  final double screenY;

  /// The calculated dynamic threshold for this series.
  ///
  /// This is min(maxThreshold, distanceToNearestSeries / 2).
  /// When series are close together, this shrinks to prevent overlap.
  double dynamicThreshold;
}

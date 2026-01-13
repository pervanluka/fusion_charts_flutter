import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../configuration/fusion_pan_configuration.dart';
import '../configuration/fusion_zoom_configuration.dart';
import '../core/enums/fusion_pan_mode.dart';
import '../core/enums/fusion_zoom_mode.dart';
import '../data/fusion_data_point.dart';
import 'fusion_coordinate_system.dart' as coord;
import 'interaction/fusion_spatial_index.dart';

/// Handles user interactions with the chart.
///
/// Provides methods for:
/// - Hit testing (finding points near tap position)
/// - Gesture handling (tap, long press, pan, scale)
/// - Zoom and pan constraints
/// - Crosshair positioning
///
/// ## Architecture
///
/// ```
/// User Interaction
///       ↓
/// GestureDetector
///       ↓
/// FusionInteractionHandler ← Spatial Index (fast lookup)
///       ↓
/// FusionInteractiveChartState (updates UI)
/// ```
class FusionInteractionHandler {
  FusionInteractionHandler({
    required this.coordSystem,
    this.hitTestRadius = 20.0,
    this.zoomConfig = const FusionZoomConfiguration(),
    this.panConfig = const FusionPanConfiguration(),
    this.onTap,
    this.onLongPress,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onHover,
  });

  /// Coordinate system for data/screen transformations.
  final coord.FusionCoordinateSystem coordSystem;

  /// Maximum distance (in pixels) for hit testing.
  final double hitTestRadius;

  /// Zoom configuration for constraints and behavior.
  final FusionZoomConfiguration zoomConfig;

  /// Pan configuration for constraints and behavior.
  final FusionPanConfiguration panConfig;

  /// Callback when user taps on a data point.
  final void Function(FusionDataPoint point, Offset screenPosition)? onTap;

  /// Callback when user long-presses on a data point.
  final void Function(FusionDataPoint point, Offset screenPosition)?
  onLongPress;

  /// Callback when pan gesture starts.
  final void Function(Offset position)? onPanStart;

  /// Callback when pan gesture updates.
  final void Function(Offset delta)? onPanUpdate;

  /// Callback when pan gesture ends.
  final void Function()? onPanEnd;

  /// Callback when scale gesture starts.
  final void Function(Offset focalPoint)? onScaleStart;

  /// Callback when scale gesture updates.
  final void Function(double scale, Offset focalPoint)? onScaleUpdate;

  /// Callback when scale gesture ends.
  final void Function()? onScaleEnd;

  final void Function(Offset position)? onHover;

  // Internal state
  FusionSpatialIndex? _spatialIndex;
  Offset? _lastPanPosition;
  double _lastScale = 1.0;

  /// Updates the spatial index with new data points.
  void updateDataPoints(List<FusionDataPoint> allPoints) {
    _spatialIndex = FusionSpatialIndex(
      coordSystem: coordSystem,
      maxPointsPerNode: 20,
      maxDepth: 8,
      dataPoints: allPoints,
    );
    _spatialIndex!.rebuild(allPoints);
  }

  /// Finds the nearest data point to a screen position.
  FusionDataPoint? findNearestPoint(
    List<FusionDataPoint> points,
    Offset screenPosition,
  ) {
    if (points.isEmpty) return null;

    if (_spatialIndex != null) {
      return _findNearestPointOptimized(screenPosition);
    }

    return _findNearestPointLinear(points, screenPosition);
  }

  FusionDataPoint? _findNearestPointOptimized(Offset screenPosition) {
    if (_spatialIndex == null) return null;
    return _spatialIndex!.findNearest(
      screenPosition,
      maxDistance: hitTestRadius,
    );
  }

  /// Finds the nearest data point by X-coordinate only.
  ///
  /// Ideal for line charts - snaps to the point at the closest X position
  /// regardless of Y distance.
  FusionDataPoint? findNearestPointByX(
    List<FusionDataPoint> points,
    Offset screenPosition,
  ) {
    if (points.isEmpty) return null;

    if (_spatialIndex != null) {
      return _spatialIndex!.findNearestByX(screenPosition);
    }

    // Fallback: linear search by X
    FusionDataPoint? nearest;
    double minXDist = double.infinity;

    for (final point in points) {
      final screenPoint = coordSystem.dataToScreen(point);
      final xDist = (screenPoint.dx - screenPosition.dx).abs();

      if (xDist < minXDist) {
        minXDist = xDist;
        nearest = point;
      }
    }

    return nearest;
  }

  /// Finds the nearest data point by Y-coordinate only.
  FusionDataPoint? findNearestPointByY(
    List<FusionDataPoint> points,
    Offset screenPosition,
  ) {
    if (points.isEmpty) return null;

    if (_spatialIndex != null) {
      return _spatialIndex!.findNearestByY(screenPosition);
    }

    // Fallback: linear search by Y
    FusionDataPoint? nearest;
    double minYDist = double.infinity;

    for (final point in points) {
      final screenPoint = coordSystem.dataToScreen(point);
      final yDist = (screenPoint.dy - screenPosition.dy).abs();

      if (yDist < minYDist) {
        minYDist = yDist;
        nearest = point;
      }
    }

    return nearest;
  }

  FusionDataPoint? _findNearestPointLinear(
    List<FusionDataPoint> points,
    Offset screenPosition,
  ) {
    double minDistance = hitTestRadius;
    FusionDataPoint? nearestPoint;

    for (final point in points) {
      final screenPoint = coordSystem.dataToScreen(point);
      final distance = (screenPoint - screenPosition).distance;

      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }

    return nearestPoint;
  }

  void handleTapDown(Offset position, List<FusionDataPoint> allPoints) {
    final nearest = findNearestPoint(allPoints, position);
    if (nearest != null && onTap != null) {
      onTap!(nearest, position);
    }
  }

  void handleLongPress(Offset position, List<FusionDataPoint> allPoints) {
    final nearest = findNearestPoint(allPoints, position);
    if (nearest != null && onLongPress != null) {
      onLongPress!(nearest, position);
    }
  }

  void handleScaleStart(Offset focalPoint) {
    _lastScale = 1.0;
    onScaleStart?.call(focalPoint);
  }

  void handleScaleUpdate(double scale, Offset focalPoint) {
    final scaleDelta = scale / _lastScale;
    _lastScale = scale;
    onScaleUpdate?.call(scaleDelta, focalPoint);
  }

  void handleScaleEnd() {
    _lastScale = 1.0;
    onScaleEnd?.call();
  }

  void handlePanStart(Offset position) {
    _lastPanPosition = position;
    onPanStart?.call(position);
  }

  void handlePanUpdate(Offset delta) {
    onPanUpdate?.call(delta);
  }

  void handlePanEnd() {
    _lastPanPosition = null;
    onPanEnd?.call();
  }

  void handleHover(Offset position) {
    onHover?.call(position);
  }

  /// Calculates zoom factor with zoomSpeed applied.
  double applyZoomSpeed(double rawScaleFactor) {
    if (rawScaleFactor == 1.0) return 1.0;
    
    final delta = rawScaleFactor - 1.0;
    final adjustedDelta = delta * zoomConfig.zoomSpeed;
    return 1.0 + adjustedDelta;
  }

  /// Calculates new bounds after panning with pan mode support.
  ({double xMin, double xMax, double yMin, double yMax}) calculatePannedBounds(
    Offset delta,
    double currentXMin,
    double currentXMax,
    double currentYMin,
    double currentYMax,
  ) {
    final xRange = currentXMax - currentXMin;
    final yRange = currentYMax - currentYMin;

    final chartWidth = coordSystem.chartArea.width;
    final chartHeight = coordSystem.chartArea.height;

    double xShift = 0.0;
    double yShift = 0.0;

    if (panConfig.panMode == FusionPanMode.x ||
        panConfig.panMode == FusionPanMode.both) {
      xShift = -(delta.dx / chartWidth) * xRange;
    }

    if (panConfig.panMode == FusionPanMode.y ||
        panConfig.panMode == FusionPanMode.both) {
      yShift = (delta.dy / chartHeight) * yRange;
    }

    return (
      xMin: currentXMin + xShift,
      xMax: currentXMax + xShift,
      yMin: currentYMin + yShift,
      yMax: currentYMax + yShift,
    );
  }

  /// Calculates new bounds after zooming with zoom mode support.
  ({double xMin, double xMax, double yMin, double yMax}) calculateZoomedBounds(
    double scaleFactor,
    Offset focalPoint,
    double currentXMin,
    double currentXMax,
    double currentYMin,
    double currentYMax,
  ) {
    final focalDataX = _screenXToDataX(focalPoint.dx, currentXMin, currentXMax);
    final focalDataY = _screenYToDataY(focalPoint.dy, currentYMin, currentYMax);

    double newXMin = currentXMin;
    double newXMax = currentXMax;
    double newYMin = currentYMin;
    double newYMax = currentYMax;
    if (zoomConfig.zoomMode == FusionZoomMode.x ||
        zoomConfig.zoomMode == FusionZoomMode.both) {
      final xRange = (currentXMax - currentXMin) / scaleFactor;
      final xRatio = (focalDataX - currentXMin) / (currentXMax - currentXMin);
      newXMin = focalDataX - (xRange * xRatio);
      newXMax = focalDataX + (xRange * (1 - xRatio));
    }

    if (zoomConfig.zoomMode == FusionZoomMode.y ||
        zoomConfig.zoomMode == FusionZoomMode.both) {
      final yRange = (currentYMax - currentYMin) / scaleFactor;
      final yRatio = (focalDataY - currentYMin) / (currentYMax - currentYMin);
      newYMin = focalDataY - (yRange * yRatio);
      newYMax = focalDataY + (yRange * (1 - yRatio));
    }

    return (xMin: newXMin, xMax: newXMax, yMin: newYMin, yMax: newYMax);
  }

  /// Constrains bounds using zoom configuration limits and pan boundaries.
  ({double xMin, double xMax, double yMin, double yMax}) constrainBounds(
    double xMin,
    double xMax,
    double yMin,
    double yMax,
    double dataXMin,
    double dataXMax,
    double dataYMin,
    double dataYMax,
  ) {
    var bounds = (xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);

    bounds = _constrainZoomLevels(
      bounds,
      dataXMin,
      dataXMax,
      dataYMin,
      dataYMax,
    );

    bounds = _constrainPanBoundaries(
      bounds,
      dataXMin,
      dataXMax,
      dataYMin,
      dataYMax,
    );

    return bounds;
  }

  /// Constrains zoom levels to configured min/max zoom.
  ///
  /// ## Zoom Level Conversion
  ///
  /// The zoom configuration uses magnification factors:
  /// - `minZoomLevel = 0.5` means minimum 0.5x magnification (zoomed out)
  /// - `maxZoomLevel = 5.0` means maximum 5x magnification (zoomed in)
  ///
  /// We convert these to range multipliers:
  /// - `maxZoomOut = 1/minZoomLevel = 2.0` → can see 200% of original range
  /// - `minZoomIn = 1/maxZoomLevel = 0.2` → can see 20% of original range
  ///
  /// ## Example
  ///
  /// Original data range: 0-100 (range = 100)
  /// - At max zoom out (0.5x): visible range = 100 * 2.0 = 200 units
  /// - At max zoom in (5.0x): visible range = 100 * 0.2 = 20 units
  ({double xMin, double xMax, double yMin, double yMax}) _constrainZoomLevels(
    ({double xMin, double xMax, double yMin, double yMax}) bounds,
    double dataXMin,
    double dataXMax,
    double dataYMin,
    double dataYMax,
  ) {
    // Convert magnification factors to range multipliers
    // minZoomLevel=0.5 → maxZoomOut=2.0 (can see 2x the original range)
    // maxZoomLevel=5.0 → minZoomIn=0.2 (can see 0.2x the original range)
    final maxZoomOut = 1.0 / zoomConfig.minZoomLevel;
    final minZoomIn = 1.0 / zoomConfig.maxZoomLevel;

    final originalXRange = dataXMax - dataXMin;
    final originalYRange = dataYMax - dataYMin;

    var newXMin = bounds.xMin;
    var newXMax = bounds.xMax;
    var newYMin = bounds.yMin;
    var newYMax = bounds.yMax;

    final newXRange = newXMax - newXMin;
    final newYRange = newYMax - newYMin;

    if (newXRange > originalXRange * maxZoomOut) {
      final center = (newXMin + newXMax) / 2;
      final halfRange = (originalXRange * maxZoomOut) / 2;
      newXMin = center - halfRange;
      newXMax = center + halfRange;
    }

    if (newYRange > originalYRange * maxZoomOut) {
      final center = (newYMin + newYMax) / 2;
      final halfRange = (originalYRange * maxZoomOut) / 2;
      newYMin = center - halfRange;
      newYMax = center + halfRange;
    }

    if (newXRange < originalXRange * minZoomIn) {
      final center = (newXMin + newXMax) / 2;
      final halfRange = (originalXRange * minZoomIn) / 2;
      newXMin = center - halfRange;
      newXMax = center + halfRange;
    }

    if (newYRange < originalYRange * minZoomIn) {
      final center = (newYMin + newYMax) / 2;
      final halfRange = (originalYRange * minZoomIn) / 2;
      newYMin = center - halfRange;
      newYMax = center + halfRange;
    }

    return (xMin: newXMin, xMax: newXMax, yMin: newYMin, yMax: newYMax);
  }

  /// Constrains pan boundaries to prevent panning outside reasonable bounds.
  ///
  /// ## How Pan Boundaries Work
  ///
  /// This method prevents the user from panning too far outside the original
  /// data bounds. The constraint is based on the viewport center position.
  ///
  /// ### Terminology
  /// - `constrainedXRange`: The current visible X range (after zoom)
  /// - `maxPanXRange`: The maximum theoretical visible range (at max zoom out)
  /// - `centerX`: The center of the current viewport in data coordinates
  ///
  /// ### Center Bounds Calculation
  ///
  /// The viewport center is constrained to stay within bounds such that:
  /// - The left edge of viewport doesn't go below `dataXMin`
  /// - The right edge of viewport doesn't exceed the max pan boundary
  ///
  /// ```
  /// |<-------- maxPanXRange -------->|
  /// |                                |
  /// dataXMin                    max boundary
  ///     |<-- constrainedXRange -->|
  ///     ^                         ^
  ///   minXCenter              maxXCenter
  /// ```
  ///
  /// - `minXCenter = dataXMin + constrainedXRange/2`
  ///   (center when left edge touches dataXMin)
  /// - `maxXCenter = dataXMin + maxPanXRange - constrainedXRange/2`
  ///   (center when right edge touches max boundary)
  ///
  /// ### Edge Cases
  ///
  /// When zoomed out to maximum (`constrainedXRange == maxPanXRange`):
  /// - `minXCenter == maxXCenter` → center is fixed, no panning possible
  ///
  /// When zoomed in (`constrainedXRange < maxPanXRange`):
  /// - `minXCenter < maxXCenter` → panning is allowed within this range
  ({double xMin, double xMax, double yMin, double yMax}) _constrainPanBoundaries(
    ({double xMin, double xMax, double yMin, double yMax}) bounds,
    double dataXMin,
    double dataXMax,
    double dataYMin,
    double dataYMax,
  ) {
    // Calculate the maximum viewable range (at max zoom out level)
    final maxZoomOut = 1.0 / zoomConfig.minZoomLevel;
    final originalXRange = dataXMax - dataXMin;
    final originalYRange = dataYMax - dataYMin;

    var newXMin = bounds.xMin;
    var newXMax = bounds.xMax;
    var newYMin = bounds.yMin;
    var newYMax = bounds.yMax;

    // Current viewport size in data coordinates
    final constrainedXRange = newXMax - newXMin;
    final constrainedYRange = newYMax - newYMin;

    // Maximum pan boundary (allows panning within the max zoom out view)
    final maxPanXRange = originalXRange * maxZoomOut;
    final maxPanYRange = originalYRange * maxZoomOut;

    // Calculate current viewport center
    final centerX = (newXMin + newXMax) / 2;
    final centerY = (newYMin + newYMax) / 2;

    // Calculate allowed center bounds for X axis
    // minXCenter: center position when left edge is at dataXMin
    // maxXCenter: center position when right edge is at max pan boundary
    final maxXCenter = dataXMin + maxPanXRange - constrainedXRange / 2;
    final minXCenter = dataXMin + constrainedXRange / 2;

    // Constrain X center: shift viewport if center is outside allowed bounds
    if (centerX < minXCenter) {
      // Panned too far left - shift right to bring left edge to dataXMin
      final shift = minXCenter - centerX;
      newXMin += shift;
      newXMax += shift;
    } else if (centerX > maxXCenter) {
      // Panned too far right - shift left to bring right edge to max boundary
      final shift = centerX - maxXCenter;
      newXMin -= shift;
      newXMax -= shift;
    }

    // Calculate allowed center bounds for Y axis (same logic as X)
    final maxYCenter = dataYMin + maxPanYRange - constrainedYRange / 2;
    final minYCenter = dataYMin + constrainedYRange / 2;

    // Constrain Y center: shift viewport if center is outside allowed bounds
    if (centerY < minYCenter) {
      // Panned too far down - shift up to bring bottom edge to dataYMin
      final shift = minYCenter - centerY;
      newYMin += shift;
      newYMax += shift;
    } else if (centerY > maxYCenter) {
      // Panned too far up - shift down to bring top edge to max boundary
      final shift = centerY - maxYCenter;
      newYMin -= shift;
      newYMax -= shift;
    }

    return (xMin: newXMin, xMax: newXMax, yMin: newYMin, yMax: newYMax);
  }

  /// Calculates zoom from mouse wheel delta.
  double calculateMouseWheelZoom(double scrollDelta) {
    const baseZoomFactor = 0.1;
    final zoomDelta =
        -scrollDelta * baseZoomFactor * zoomConfig.zoomSpeed / 100;
    return 1.0 + zoomDelta.clamp(-0.3, 0.3);
  }

  double _screenXToDataX(double screenX, double dataXMin, double dataXMax) {
    final chartLeft = coordSystem.chartArea.left;
    final chartWidth = coordSystem.chartArea.width;
    final normalized = (screenX - chartLeft) / chartWidth;
    return dataXMin + (normalized * (dataXMax - dataXMin));
  }

  double _screenYToDataY(double screenY, double dataYMin, double dataYMax) {
    final chartTop = coordSystem.chartArea.top;
    final chartHeight = coordSystem.chartArea.height;
    final normalized = 1.0 - ((screenY - chartTop) / chartHeight);
    return dataYMin + (normalized * (dataYMax - dataYMin));
  }

  Map<Type, GestureRecognizerFactory> buildGestureRecognizers(
    List<FusionDataPoint> allPoints,
  ) {
    return <Type, GestureRecognizerFactory>{
      if (onTap != null)
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (instance) {
                instance.onTapDown = (details) {
                  handleTapDown(details.localPosition, allPoints);
                };
              },
            ),
      if (onLongPress != null)
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              LongPressGestureRecognizer.new,
              (instance) {
                instance.onLongPress = () {
                  if (_lastPanPosition != null) {
                    handleLongPress(_lastPanPosition!, allPoints);
                  }
                };
              },
            ),
      if (onPanStart != null || onPanUpdate != null || onPanEnd != null)
        PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
              PanGestureRecognizer.new,
              (instance) {
                instance
                  ..onStart = (details) {
                    _lastPanPosition = details.localPosition;
                    handlePanStart(details.localPosition);
                  }
                  ..onUpdate = (details) {
                    handlePanUpdate(details.delta);
                    _lastPanPosition = details.localPosition;
                  }
                  ..onEnd = (details) {
                    handlePanEnd();
                    _lastPanPosition = null;
                  };
              },
            ),
      if (onScaleStart != null || onScaleUpdate != null || onScaleEnd != null)
        ScaleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
              ScaleGestureRecognizer.new,
              (instance) {
                instance
                  ..onStart = (details) {
                    handleScaleStart(details.localFocalPoint);
                  }
                  ..onUpdate = (details) {
                    handleScaleUpdate(details.scale, details.localFocalPoint);
                  }
                  ..onEnd = (details) {
                    handleScaleEnd();
                  };
              },
            ),
    };
  }
}

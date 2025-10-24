// lib/src/rendering/fusion_interaction_handler.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../data/fusion_data_point.dart';
import 'fusion_coordinate_system.dart' as coord; // 👈 Use prefix to avoid conflict
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
  final coord.FusionCoordinateSystem coordSystem; // 👈 Use prefix

  /// Maximum distance (in pixels) for hit testing.
  ///
  /// When user taps, points within this radius are considered "hit".
  final double hitTestRadius;

  /// Callback when user taps on a data point.
  final void Function(FusionDataPoint point, Offset screenPosition)? onTap;

  /// Callback when user long-presses on a data point.
  final void Function(FusionDataPoint point, Offset screenPosition)? onLongPress;

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
  ///
  /// Call this whenever data changes to rebuild the spatial index.
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
  ///
  /// Uses spatial indexing for O(log n) performance with large datasets.
  ///
  /// Returns `null` if no point is within [hitTestRadius].
  FusionDataPoint? findNearestPoint(List<FusionDataPoint> points, Offset screenPosition) {
    if (points.isEmpty) return null;

    // Use spatial index if available
    if (_spatialIndex != null) {
      return _findNearestPointOptimized(screenPosition);
    }

    // Fallback to linear search
    return _findNearestPointLinear(points, screenPosition);
  }

  /// Fast point lookup using spatial index.
  FusionDataPoint? _findNearestPointOptimized(Offset screenPosition) {
    if (_spatialIndex == null) return null;

    // ✅ Use the public findNearest API
    return _spatialIndex!.findNearest(screenPosition, maxDistance: hitTestRadius);
  }

  /// Linear search fallback (O(n) but simple).
  FusionDataPoint? _findNearestPointLinear(List<FusionDataPoint> points, Offset screenPosition) {
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

  /// Handles tap down event.
  void handleTapDown(Offset position, List<FusionDataPoint> allPoints) {
    final nearest = findNearestPoint(allPoints, position);
    if (nearest != null && onTap != null) {
      onTap!(nearest, position);
    }
  }

  /// Handles long press event.
  void handleLongPress(Offset position, List<FusionDataPoint> allPoints) {
    final nearest = findNearestPoint(allPoints, position);
    if (nearest != null && onLongPress != null) {
      onLongPress!(nearest, position);
    }
  }

  /// Handles scale gesture start.
  void handleScaleStart(Offset focalPoint) {
    _lastScale = 1.0;
    onScaleStart?.call(focalPoint);
  }

  /// Handles scale gesture update.
  void handleScaleUpdate(double scale, Offset focalPoint) {
    final scaleDelta = scale / _lastScale;
    _lastScale = scale;
    onScaleUpdate?.call(scaleDelta, focalPoint);
  }

  /// Handles scale gesture end.
  void handleScaleEnd() {
    _lastScale = 1.0;
    onScaleEnd?.call();
  }

  /// Handles pan gesture start.
  void handlePanStart(Offset position) {
    _lastPanPosition = position;
    onPanStart?.call(position);
  }

  /// Handles pan gesture update.
  void handlePanUpdate(Offset delta) {
    onPanUpdate?.call(delta);
  }

  /// Handles pan gesture end.
  void handlePanEnd() {
    _lastPanPosition = null;
    onPanEnd?.call();
  }

  void handleHover(Offset position) {
    onHover?.call(position);
  }

  /// Calculates new bounds after panning.
  ///
  /// Returns adjusted data bounds based on pan delta.
  ({double xMin, double xMax, double yMin, double yMax}) calculatePannedBounds(
    Offset delta,
    double currentXMin,
    double currentXMax,
    double currentYMin,
    double currentYMax,
  ) {
    // Convert screen delta to data delta
    final xRange = currentXMax - currentXMin;
    final yRange = currentYMax - currentYMin;

    final chartWidth = coordSystem.chartArea.width;
    final chartHeight = coordSystem.chartArea.height;

    // Calculate data shift
    final xShift = -(delta.dx / chartWidth) * xRange;
    final yShift = (delta.dy / chartHeight) * yRange; // Y is inverted

    return (
      xMin: currentXMin + xShift,
      xMax: currentXMax + xShift,
      yMin: currentYMin + yShift,
      yMax: currentYMax + yShift,
    );
  }

  /// Calculates new bounds after zooming.
  ///
  /// Returns adjusted data bounds based on scale factor and focal point.
  ({double xMin, double xMax, double yMin, double yMax}) calculateZoomedBounds(
    double scaleFactor,
    Offset focalPoint,
    double currentXMin,
    double currentXMax,
    double currentYMin,
    double currentYMax,
  ) {
    // Convert focal point to data coordinates
    final focalDataX = _screenXToDataX(focalPoint.dx, currentXMin, currentXMax);
    final focalDataY = _screenYToDataY(focalPoint.dy, currentYMin, currentYMax);

    // Calculate new ranges
    final xRange = (currentXMax - currentXMin) / scaleFactor;
    final yRange = (currentYMax - currentYMin) / scaleFactor;

    // Center zoom around focal point
    final xRatio = (focalDataX - currentXMin) / (currentXMax - currentXMin);
    final yRatio = (focalDataY - currentYMin) / (currentYMax - currentYMin);

    return (
      xMin: focalDataX - (xRange * xRatio),
      xMax: focalDataX + (xRange * (1 - xRatio)),
      yMin: focalDataY - (yRange * yRatio),
      yMax: focalDataY + (yRange * (1 - yRatio)),
    );
  }

  /// Constrains bounds to valid range.
  ///
  /// Prevents zooming out too far or panning beyond data limits.
  ({double xMin, double xMax, double yMin, double yMax}) constrainBounds(
    double xMin,
    double xMax,
    double yMin,
    double yMax,
    double dataXMin,
    double dataXMax,
    double dataYMin,
    double dataYMax, {
    double maxZoomOut = 1.5, // Allow 150% of original range
    double minZoomIn = 0.1, // Minimum 10% of original range
  }) {
    final originalXRange = dataXMax - dataXMin;
    final originalYRange = dataYMax - dataYMin;

    final newXRange = xMax - xMin;
    final newYRange = yMax - yMin;

    // Prevent zooming out too far
    if (newXRange > originalXRange * maxZoomOut) {
      final center = (xMin + xMax) / 2;
      final halfRange = (originalXRange * maxZoomOut) / 2;
      xMin = center - halfRange;
      xMax = center + halfRange;
    }

    if (newYRange > originalYRange * maxZoomOut) {
      final center = (yMin + yMax) / 2;
      final halfRange = (originalYRange * maxZoomOut) / 2;
      yMin = center - halfRange;
      yMax = center + halfRange;
    }

    // Prevent zooming in too far
    if (newXRange < originalXRange * minZoomIn) {
      final center = (xMin + xMax) / 2;
      final halfRange = (originalXRange * minZoomIn) / 2;
      xMin = center - halfRange;
      xMax = center + halfRange;
    }

    if (newYRange < originalYRange * minZoomIn) {
      final center = (yMin + yMax) / 2;
      final halfRange = (originalYRange * minZoomIn) / 2;
      yMin = center - halfRange;
      yMax = center + halfRange;
    }

    return (xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);
  }

  /// Converts screen X to data X.
  double _screenXToDataX(double screenX, double dataXMin, double dataXMax) {
    final chartLeft = coordSystem.chartArea.left;
    final chartWidth = coordSystem.chartArea.width;
    final normalized = (screenX - chartLeft) / chartWidth;
    return dataXMin + (normalized * (dataXMax - dataXMin));
  }

  /// Converts screen Y to data Y.
  double _screenYToDataY(double screenY, double dataYMin, double dataYMax) {
    final chartTop = coordSystem.chartArea.top;
    final chartHeight = coordSystem.chartArea.height;
    final normalized = 1.0 - ((screenY - chartTop) / chartHeight); // Y inverted
    return dataYMin + (normalized * (dataYMax - dataYMin));
  }

  /// Creates gesture recognizers for all enabled interactions.
  Map<Type, GestureRecognizerFactory> buildGestureRecognizers(List<FusionDataPoint> allPoints) {
    return <Type, GestureRecognizerFactory>{
      if (onTap != null)
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (instance) {
            instance.onTapDown = (details) {
              handleTapDown(details.localPosition, allPoints);
            };
          },
        ),
      if (onLongPress != null)
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(),
              (instance) {
                instance.onLongPress = () {
                  if (_lastPanPosition != null) {
                    handleLongPress(_lastPanPosition!, allPoints);
                  }
                };
              },
            ),
      if (onPanStart != null || onPanUpdate != null || onPanEnd != null)
        PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
          () => PanGestureRecognizer(),
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
        ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer(),
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

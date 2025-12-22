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
  FusionDataPoint? findNearestPoint(List<FusionDataPoint> points, Offset screenPosition) {
    if (points.isEmpty) return null;

    if (_spatialIndex != null) {
      return _findNearestPointOptimized(screenPosition);
    }

    return _findNearestPointLinear(points, screenPosition);
  }

  FusionDataPoint? _findNearestPointOptimized(Offset screenPosition) {
    if (_spatialIndex == null) return null;
    return _spatialIndex!.findNearest(screenPosition, maxDistance: hitTestRadius);
  }

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

    // Apply pan mode constraints
    double xShift = 0.0;
    double yShift = 0.0;

    if (panConfig.panMode == FusionPanMode.x || panConfig.panMode == FusionPanMode.both) {
      xShift = -(delta.dx / chartWidth) * xRange;
    }

    if (panConfig.panMode == FusionPanMode.y || panConfig.panMode == FusionPanMode.both) {
      yShift = (delta.dy / chartHeight) * yRange; // Y is inverted
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
    // Convert focal point to data coordinates
    final focalDataX = _screenXToDataX(focalPoint.dx, currentXMin, currentXMax);
    final focalDataY = _screenYToDataY(focalPoint.dy, currentYMin, currentYMax);

    // Calculate new ranges based on zoom mode
    double newXMin = currentXMin;
    double newXMax = currentXMax;
    double newYMin = currentYMin;
    double newYMax = currentYMax;

    // Apply zoom based on mode
    if (zoomConfig.zoomMode == FusionZoomMode.x || zoomConfig.zoomMode == FusionZoomMode.both) {
      final xRange = (currentXMax - currentXMin) / scaleFactor;
      final xRatio = (focalDataX - currentXMin) / (currentXMax - currentXMin);
      newXMin = focalDataX - (xRange * xRatio);
      newXMax = focalDataX + (xRange * (1 - xRatio));
    }

    if (zoomConfig.zoomMode == FusionZoomMode.y || zoomConfig.zoomMode == FusionZoomMode.both) {
      final yRange = (currentYMax - currentYMin) / scaleFactor;
      final yRatio = (focalDataY - currentYMin) / (currentYMax - currentYMin);
      newYMin = focalDataY - (yRange * yRatio);
      newYMax = focalDataY + (yRange * (1 - yRatio));
    }

    return (
      xMin: newXMin,
      xMax: newXMax,
      yMin: newYMin,
      yMax: newYMax,
    );
  }

  /// Constrains bounds using zoom configuration limits.
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
    // Use configuration values for zoom limits
    // minZoomLevel = 0.5 means you can zoom out to see 200% of original range (1/0.5 = 2x)
    // maxZoomLevel = 5.0 means you can zoom in to see 20% of original range (1/5 = 0.2x)
    final maxZoomOut = 1.0 / zoomConfig.minZoomLevel; // e.g., 1/0.5 = 2.0 (200% of range)
    final minZoomIn = 1.0 / zoomConfig.maxZoomLevel;  // e.g., 1/5.0 = 0.2 (20% of range)

    final originalXRange = dataXMax - dataXMin;
    final originalYRange = dataYMax - dataYMin;

    var newXMin = xMin;
    var newXMax = xMax;
    var newYMin = yMin;
    var newYMax = yMax;

    final newXRange = newXMax - newXMin;
    final newYRange = newYMax - newYMin;

    // Prevent zooming out too far
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

    // Prevent zooming in too far
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

  /// Calculates zoom from mouse wheel delta.
  double calculateMouseWheelZoom(double scrollDelta) {
    // Negative delta = scroll up = zoom in
    // Positive delta = scroll down = zoom out
    const baseZoomFactor = 0.1;
    final zoomDelta = -scrollDelta * baseZoomFactor * zoomConfig.zoomSpeed / 100;
    return 1.0 + zoomDelta.clamp(-0.3, 0.3); // Clamp for smooth zooming
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

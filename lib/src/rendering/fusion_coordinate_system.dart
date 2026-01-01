import 'package:flutter/material.dart' show Offset, Rect, immutable;

import '../data/fusion_data_point.dart';

/// Immutable coordinate system for chart transformations.
///
/// This class is the CORE of pixel-perfect rendering. It handles
/// all coordinate transformations with mathematical precision.
///
/// ## Design Philosophy
///
/// 1. **Immutability**: Once created, never changes (thread-safe, cacheable)
/// 2. **Precision**: All calculations use double precision
/// 3. **Performance**: Precomputed scales for O(1) transformations
/// 4. **Correctness**: Handles edge cases (zero ranges, inversions)
///
/// ## Mathematics
///
/// ### Forward Transform (Data → Screen):
/// ```
/// screenX = chartArea.left + (dataX - minX) × scaleX
/// screenY = chartArea.bottom - (dataY - minY) × scaleY  // Inverted Y
/// ```
///
/// ### Inverse Transform (Screen → Data):
/// ```
/// dataX = minX + (screenX - chartArea.left) / scaleX
/// dataY = minY + (chartArea.bottom - screenY) / scaleY
/// ```
///
/// ## Example
///
/// ```dart
/// final coordSystem = FusionCoordinateSystem(
///   chartArea: Rect.fromLTWH(60, 10, 300, 200),
///   dataXMin: 0,
///   dataXMax: 12,
///   dataYMin: 0,
///   dataYMax: 100,
/// );
///
/// // Transform data point to screen
/// final screenPos = coordSystem.dataToScreen(FusionDataPoint(6, 50));
/// // Result: Offset(210, 110) - center of chart
/// ```
@immutable
class FusionCoordinateSystem {
  const FusionCoordinateSystem({
    required this.chartArea,
    required this.dataXMin,
    required this.dataXMax,
    required this.dataYMin,
    required this.dataYMax,
    this.xInversed = false,
    this.yInversed = false,
    this.devicePixelRatio = 1.0,
  }) : assert(dataXMax >= dataXMin, 'dataXMax must be >= dataXMin'),
       assert(dataYMax >= dataYMin, 'dataYMax must be >= dataYMin'),
       assert(devicePixelRatio > 0, 'devicePixelRatio must be positive');

  final Rect chartArea;
  final double dataXMin;
  final double dataXMax;
  final double dataYMin;
  final double dataYMax;
  final bool xInversed;
  final bool yInversed;

  /// Device pixel ratio for high-DPI screens (Retina, etc.)
  final double devicePixelRatio;

  /// Precomputed X scale factor (pixels per data unit).
  double get scaleX {
    final range = dataXMax - dataXMin;
    return range != 0 ? chartArea.width / range : 1.0;
  }

  /// Precomputed Y scale factor (pixels per data unit).
  double get scaleY {
    final range = dataYMax - dataYMin;
    return range != 0 ? chartArea.height / range : 1.0;
  }

  double get dataXRange => dataXMax - dataXMin;
  double get dataYRange => dataYMax - dataYMin;
  double get chartWidth => chartArea.width;
  double get chartHeight => chartArea.height;
  Rect get dataBounds => Rect.fromLTRB(dataXMin, dataYMin, dataXMax, dataYMax);

  // ==========================================================================
  // FORWARD TRANSFORMS WITH PIXEL SNAPPING
  // ==========================================================================

  /// Converts data X to screen X with pixel snapping.
  double dataXToScreenX(double dataX) {
    if (dataXRange == 0) return _snapToPixel(chartArea.left);

    final normalizedX = (dataX - dataXMin) * scaleX;
    final screenX = xInversed
        ? chartArea.right - normalizedX
        : chartArea.left + normalizedX;

    return _snapToPixel(screenX);
  }

  /// Converts data Y to screen Y with pixel snapping.
  double dataYToScreenY(double dataY) {
    if (dataYRange == 0) return _snapToPixel(chartArea.bottom);

    final normalizedY = (dataY - dataYMin) * scaleY;
    final screenY = yInversed
        ? chartArea.top + normalizedY
        : chartArea.bottom - normalizedY;

    return _snapToPixel(screenY);
  }

  /// Converts data point to screen coordinates with snapping.
  Offset dataToScreen(FusionDataPoint point) {
    return Offset(dataXToScreenX(point.x), dataYToScreenY(point.y));
  }

  /// Batch conversion with pixel snapping.
  List<Offset> dataPointsToScreen(List<FusionDataPoint> points) {
    return points.map(dataToScreen).toList();
  }

  // ==========================================================================
  // INVERSE TRANSFORMS (No snapping - for precise calculations)
  // ==========================================================================

  double screenXToDataX(double screenX) {
    if (dataXRange == 0) return dataXMin;

    final offsetX = xInversed
        ? chartArea.right - screenX
        : screenX - chartArea.left;

    return dataXMin + (offsetX / scaleX);
  }

  double screenYToDataY(double screenY) {
    if (dataYRange == 0) return dataYMin;

    final offsetY = yInversed
        ? screenY - chartArea.top
        : chartArea.bottom - screenY;

    return dataYMin + (offsetY / scaleY);
  }

  FusionDataPoint screenToData(Offset screenPoint) {
    return FusionDataPoint(
      screenXToDataX(screenPoint.dx),
      screenYToDataY(screenPoint.dy),
    );
  }

  // ==========================================================================
  // PIXEL SNAPPING UTILITIES
  // ==========================================================================

  /// Snaps coordinate to nearest pixel boundary.
  ///
  /// **Critical for crisp rendering:**
  /// - 1x DPI: Rounds to whole pixels
  /// - 2x DPI (Retina): Rounds to 0.5 pixel boundaries
  /// - 3x DPI: Rounds to 0.333 pixel boundaries
  double _snapToPixel(double coordinate) {
    return (coordinate * devicePixelRatio).roundToDouble() / devicePixelRatio;
  }

  /// Snaps offset to pixel boundaries.
  Offset snapOffsetToPixel(Offset offset) {
    return Offset(_snapToPixel(offset.dx), _snapToPixel(offset.dy));
  }

  /// Snaps rect to pixel boundaries.
  Rect snapRectToPixel(Rect rect) {
    return Rect.fromLTRB(
      _snapToPixel(rect.left),
      _snapToPixel(rect.top),
      _snapToPixel(rect.right),
      _snapToPixel(rect.bottom),
    );
  }

  // ==========================================================================
  // UTILITY TRANSFORMS
  // ==========================================================================

  double dataWidthToScreenWidth(double dataWidth) {
    return dataWidth * scaleX;
  }

  double dataHeightToScreenHeight(double dataHeight) {
    return dataHeight * scaleY;
  }

  double screenWidthToDataWidth(double screenWidth) {
    return screenWidth / scaleX;
  }

  double screenHeightToDataHeight(double screenHeight) {
    return screenHeight / scaleY;
  }

  // ==========================================================================
  // HIT TESTING
  // ==========================================================================

  bool containsScreen(Offset screenPoint) {
    return chartArea.contains(screenPoint);
  }

  bool containsData(FusionDataPoint dataPoint) {
    return dataPoint.x >= dataXMin &&
        dataPoint.x <= dataXMax &&
        dataPoint.y >= dataYMin &&
        dataPoint.y <= dataYMax;
  }

  FusionDataPoint? findNearestPoint(
    Offset screenPosition,
    List<FusionDataPoint> dataPoints, {
    double maxDistance = 30.0,
  }) {
    if (dataPoints.isEmpty) return null;

    FusionDataPoint? nearest;
    double minDistance = maxDistance;

    for (final point in dataPoints) {
      final screenPoint = dataToScreen(point);
      final distance = (screenPoint - screenPosition).distance;

      if (distance < minDistance) {
        minDistance = distance;
        nearest = point;
      }
    }

    return nearest;
  }

  // ==========================================================================
  // VIEWPORT & CLIPPING
  // ==========================================================================

  List<FusionDataPoint> getVisiblePoints(List<FusionDataPoint> points) {
    return points
        .where(
          (p) =>
              p.x >= dataXMin &&
              p.x <= dataXMax &&
              p.y >= dataYMin &&
              p.y <= dataYMax,
        )
        .toList();
  }

  FusionCoordinateSystem zoom({
    required double dataXMin,
    required double dataXMax,
    required double dataYMin,
    required double dataYMax,
  }) {
    return FusionCoordinateSystem(
      chartArea: chartArea,
      dataXMin: dataXMin,
      dataXMax: dataXMax,
      dataYMin: dataYMin,
      dataYMax: dataYMax,
      xInversed: xInversed,
      yInversed: yInversed,
      devicePixelRatio: devicePixelRatio,
    );
  }

  // ==========================================================================
  // EQUALITY & HASH
  // ==========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionCoordinateSystem &&
        other.chartArea == chartArea &&
        other.dataXMin == dataXMin &&
        other.dataXMax == dataXMax &&
        other.dataYMin == dataYMin &&
        other.dataYMax == dataYMax &&
        other.xInversed == xInversed &&
        other.yInversed == yInversed &&
        other.devicePixelRatio == devicePixelRatio;
  }

  @override
  int get hashCode => Object.hash(
    chartArea,
    dataXMin,
    dataXMax,
    dataYMin,
    dataYMax,
    xInversed,
    yInversed,
    devicePixelRatio,
  );

  @override
  String toString() {
    return 'FusionCoordinateSystem('
        'chartArea: $chartArea, '
        'dataX: [$dataXMin, $dataXMax], '
        'dataY: [$dataYMin, $dataYMax], '
        'scale: ${scaleX.toStringAsFixed(2)}x${scaleY.toStringAsFixed(2)}, '
        'dpi: ${devicePixelRatio}x '
        ')';
  }
}

import 'dart:ui';

/// Manages clipping regions for efficient rendering.
///
/// Only renders data points that are visible in the viewport.
class FusionClippingManager {
  FusionClippingManager({
    this.enableClipping = true,
    this.viewportPadding = 50.0, // Render slightly beyond viewport
  });

  final bool enableClipping;
  final double viewportPadding;

  /// Clips a list of points to the visible viewport.
  List<T> clipToViewport<T extends Object>({
    required List<T> points,
    required Rect viewport,
    required double Function(T) getX,
    required double Function(T) getY,
  }) {
    if (!enableClipping) return points;
    if (points.isEmpty) return points;

    // Expand viewport by padding
    final paddedViewport = viewport.inflate(viewportPadding);

    // Find first visible index
    int startIndex = _binarySearchStart(points, paddedViewport.left, getX);

    // Find last visible index
    int endIndex = _binarySearchEnd(points, paddedViewport.right, getX);

    // Include one point before and after for proper line continuity
    startIndex = (startIndex - 1).clamp(0, points.length - 1);
    endIndex = (endIndex + 1).clamp(0, points.length - 1);

    return points.sublist(startIndex, endIndex + 1);
  }

  /// Clips a path to the viewport bounds.
  Path clipPath(Path path, Rect clipRect) {
    if (!enableClipping) return path;

    final clippedPath = Path();
    clippedPath.addRect(clipRect);

    // Use path operations to clip (this is expensive, use sparingly)
    return Path.combine(PathOperation.intersect, path, clippedPath);
  }

  /// Checks if a rect is visible in viewport.
  bool isVisible(Rect rect, Rect viewport) {
    if (!enableClipping) return true;

    final paddedViewport = viewport.inflate(viewportPadding);
    return paddedViewport.overlaps(rect);
  }

  /// Checks if a point is visible in viewport.
  bool isPointVisible(Offset point, Rect viewport) {
    if (!enableClipping) return true;

    final paddedViewport = viewport.inflate(viewportPadding);
    return paddedViewport.contains(point);
  }

  /// Binary search for first visible point.
  int _binarySearchStart<T>(List<T> points, double minX, double Function(T) getX) {
    int left = 0;
    int right = points.length - 1;
    int result = 0;

    while (left <= right) {
      final mid = (left + right) ~/ 2;
      final x = getX(points[mid]);

      if (x < minX) {
        left = mid + 1;
      } else {
        result = mid;
        right = mid - 1;
      }
    }

    return result;
  }

  /// Binary search for last visible point.
  int _binarySearchEnd<T>(List<T> points, double maxX, double Function(T) getX) {
    int left = 0;
    int right = points.length - 1;
    int result = points.length - 1;

    while (left <= right) {
      final mid = (left + right) ~/ 2;
      final x = getX(points[mid]);

      if (x <= maxX) {
        result = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    return result;
  }

  /// Estimates number of points that will be visible.
  int estimateVisiblePoints({
    required int totalPoints,
    required double viewportMin,
    required double viewportMax,
    required double dataMin,
    required double dataMax,
  }) {
    if (!enableClipping) return totalPoints;

    final dataRange = dataMax - dataMin;
    if (dataRange == 0) return totalPoints;

    final viewportRange = viewportMax - viewportMin;
    final ratio = viewportRange / dataRange;

    return (totalPoints * ratio).ceil();
  }
}

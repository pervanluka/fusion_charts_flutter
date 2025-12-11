import 'dart:ui';
import '../data/fusion_data_point.dart';
import '../utils/fusion_mathematics.dart';
import 'fusion_coordinate_system.dart';

/// Builder for creating smooth, high-quality paths for chart rendering.
///
/// ## Features
///
/// - Straight line paths
/// - Smooth Bezier curves
/// - Catmull-Rom splines
/// - Area fills
/// - Optimized for performance
///
/// ## Mathematics
///
/// Uses control point calculation based on adjacent points:
/// ```
/// controlPoint1 = p1 + (p2 - p0) × smoothness
/// controlPoint2 = p2 - (p3 - p1) × smoothness
/// ```
class FusionPathBuilder {
  FusionPathBuilder._();

  // ==========================================================================
  // STRAIGHT LINE PATHS
  // ==========================================================================

  /// Creates a path with straight lines connecting data points.
  ///
  /// This is the fastest method, used when curves are disabled.
  ///
  /// Example:
  /// ```dart
  /// final path = FusionPathBuilder.createLinePath(
  ///   dataPoints,
  ///   coordSystem,
  /// );
  /// ```
  static Path createLinePath(List<FusionDataPoint> dataPoints, FusionCoordinateSystem coordSystem) {
    final path = Path();

    if (dataPoints.isEmpty) return path;

    // Move to first point
    final firstPoint = coordSystem.dataToScreen(dataPoints[0]);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    // Draw lines to subsequent points
    for (int i = 1; i < dataPoints.length; i++) {
      final screenPoint = coordSystem.dataToScreen(dataPoints[i]);
      path.lineTo(screenPoint.dx, screenPoint.dy);
    }

    return path;
  }

  // ==========================================================================
  // SMOOTH CURVED PATHS
  // ==========================================================================

  /// Creates a smooth curved path using cubic Bezier curves.
  ///
  /// Parameters:
  /// - [dataPoints]: The data to render
  /// - [coordSystem]: Coordinate transformation system
  /// - [smoothness]: Curve smoothness (0.0-1.0), default 0.35
  ///
  /// Example:
  /// ```dart
  /// final path = FusionPathBuilder.createSmoothPath(
  ///   dataPoints,
  ///   coordSystem,
  ///   smoothness: 0.35,
  /// );
  /// ```
  static Path createSmoothPath(
    List<FusionDataPoint> dataPoints,
    FusionCoordinateSystem coordSystem, {
    double smoothness = 0.35,
  }) {
    final path = Path();

    if (dataPoints.isEmpty) return path;
    if (dataPoints.length == 1) {
      final point = coordSystem.dataToScreen(dataPoints[0]);
      path.moveTo(point.dx, point.dy);
      return path;
    }

    // Convert data points to screen coordinates
    final screenPoints = dataPoints.map(coordSystem.dataToScreen).toList();

    // Move to first point
    path.moveTo(screenPoints[0].dx, screenPoints[0].dy);

    if (screenPoints.length == 2) {
      // Only two points: draw straight line
      path.lineTo(screenPoints[1].dx, screenPoints[1].dy);
      return path;
    }

    // Generate control points for smooth curves
    for (int i = 0; i < screenPoints.length - 1; i++) {
      final p0 = i > 0 ? screenPoints[i - 1] : screenPoints[i];
      final p1 = screenPoints[i];
      final p2 = screenPoints[i + 1];
      final p3 = i < screenPoints.length - 2 ? screenPoints[i + 2] : screenPoints[i + 1];

      // Calculate control points
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * smoothness,
        p1.dy + (p2.dy - p0.dy) * smoothness,
      );

      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * smoothness,
        p2.dy - (p3.dy - p1.dy) * smoothness,
      );

      // Draw cubic Bezier curve
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    return path;
  }

  // ==========================================================================
  // AREA PATHS (for area charts)
  // ==========================================================================

  /// Creates a closed path for area fill.
  ///
  /// The path follows the data points and then closes at the baseline.
  ///
  /// Parameters:
  /// - [dataPoints]: The data to render
  /// - [coordSystem]: Coordinate transformation system
  /// - [isCurved]: Whether to use smooth curves
  /// - [smoothness]: Curve smoothness (only if isCurved is true)
  /// - [baseline]: Y value for the baseline (default: 0)
  static Path createAreaPath(
    List<FusionDataPoint> dataPoints,
    FusionCoordinateSystem coordSystem, {
    bool isCurved = true,
    double smoothness = 0.35,
    double baseline = 0.0,
  }) {
    if (dataPoints.isEmpty) return Path();

    // Create the top path
    final topPath = isCurved
        ? createSmoothPath(dataPoints, coordSystem, smoothness: smoothness)
        : createLinePath(dataPoints, coordSystem);

    // Add closure to baseline
    final lastPoint = dataPoints.last;
    final lastScreen = coordSystem.dataToScreen(lastPoint);
    final baselineY = coordSystem.dataYToScreenY(baseline);

    topPath.lineTo(lastScreen.dx, baselineY);

    // Line back to start
    final firstPoint = dataPoints.first;
    final firstScreen = coordSystem.dataToScreen(firstPoint);
    topPath.lineTo(firstScreen.dx, baselineY);

    // Close the path
    topPath.close();

    return topPath;
  }

  // ==========================================================================
  // CATMULL-ROM SPLINE PATHS
  // ==========================================================================

  /// Creates a path using Catmull-Rom spline interpolation.
  ///
  /// This creates extremely smooth curves that pass through all points.
  /// More computationally expensive than Bezier but smoother results.
  static Path createCatmullRomPath(
    List<FusionDataPoint> dataPoints,
    FusionCoordinateSystem coordSystem, {
    int segmentsPerCurve = 20,
    double tension = 0.5,
  }) {
    final path = Path();

    if (dataPoints.isEmpty) return path;
    if (dataPoints.length < 4) {
      return createLinePath(dataPoints, coordSystem);
    }

    final screenPoints = dataPoints.map(coordSystem.dataToScreen).toList();

    // Use mathematics utility for Catmull-Rom calculation
    final smoothPoints = FusionMathematics.calculateCatmullRomSpline(
      screenPoints,
      segmentsPerCurve: segmentsPerCurve,
      tension: tension,
    );

    if (smoothPoints.isEmpty) return path;

    path.moveTo(smoothPoints[0].dx, smoothPoints[0].dy);

    for (int i = 1; i < smoothPoints.length; i++) {
      path.lineTo(smoothPoints[i].dx, smoothPoints[i].dy);
    }

    return path;
  }

  // ==========================================================================
  // OPTIMIZATION: SIMPLIFIED PATHS
  // ==========================================================================

  /// Creates a simplified path using Douglas-Peucker algorithm.
  ///
  /// Reduces the number of points while maintaining visual fidelity.
  /// Useful for performance optimization with large datasets.
  ///
  /// Parameters:
  /// - [dataPoints]: The data to render
  /// - [coordSystem]: Coordinate transformation system
  /// - [tolerance]: Maximum deviation allowed (in pixels)
  static Path createSimplifiedPath(
    List<FusionDataPoint> dataPoints,
    FusionCoordinateSystem coordSystem, {
    double tolerance = 2.0,
  }) {
    if (dataPoints.length < 3) {
      return createLinePath(dataPoints, coordSystem);
    }

    final screenPoints = dataPoints.map(coordSystem.dataToScreen).toList();
    final simplified = _douglasPeucker(screenPoints, tolerance);

    final path = Path();
    if (simplified.isEmpty) return path;

    path.moveTo(simplified[0].dx, simplified[0].dy);
    for (int i = 1; i < simplified.length; i++) {
      path.lineTo(simplified[i].dx, simplified[i].dy);
    }

    return path;
  }

  /// Douglas-Peucker line simplification algorithm.
  static List<Offset> _douglasPeucker(List<Offset> points, double tolerance) {
    if (points.length <= 2) return points;

    // Find point with maximum distance from line
    double maxDistance = 0;
    int maxIndex = 0;

    final first = points.first;
    final last = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(points[i], first, last);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    // If max distance is greater than tolerance, recursively simplify
    if (maxDistance > tolerance) {
      final left = _douglasPeucker(points.sublist(0, maxIndex + 1), tolerance);
      final right = _douglasPeucker(points.sublist(maxIndex), tolerance);

      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [first, last];
    }
  }

  /// Calculates perpendicular distance from point to line.
  static double _perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;

    final numerator = ((point.dx - lineStart.dx) * dy - (point.dy - lineStart.dy) * dx).abs();
    final denominator = (dx * dx + dy * dy);

    if (denominator == 0) return 0;

    return numerator / denominator;
  }

  // ==========================================================================
  // DASHED PATHS
  // ==========================================================================

  /// Creates a dashed path from a regular path.
  ///
  /// Parameters:
  /// - [path]: The original path
  /// - [dashArray]: Pattern of dashes [dash length, gap length, ...]
  ///
  /// Example:
  /// ```dart
  /// final dashed = FusionPathBuilder.createDashedPath(
  ///   originalPath,
  ///   dashArray: [5, 3, 2, 3], // Custom dash pattern
  /// );
  /// ```
  static Path createDashedPath(Path path, List<double> dashArray) {
    if (dashArray.isEmpty || dashArray.length.isOdd) {
      return path;
    }

    final dashedPath = Path();
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      int dashIndex = 0;

      while (distance < metric.length) {
        final dashLength = dashArray[dashIndex % dashArray.length];
        final nextDistance = distance + dashLength;

        if (draw) {
          final extractPath = metric.extractPath(distance, nextDistance.clamp(0, metric.length));
          dashedPath.addPath(extractPath, Offset.zero);
        }

        distance = nextDistance;
        draw = !draw;
        dashIndex++;
      }
    }

    return dashedPath;
  }

  // ==========================================================================
  // GRADIENT PATHS
  // ==========================================================================

  /// Prepares a path for gradient rendering.
  ///
  /// Returns the path along with the gradient bounds.
  static PathWithBounds createGradientPath(
    List<FusionDataPoint> dataPoints,
    FusionCoordinateSystem coordSystem, {
    bool isCurved = true,
    double smoothness = 0.35,
  }) {
    final path = isCurved
        ? createSmoothPath(dataPoints, coordSystem, smoothness: smoothness)
        : createLinePath(dataPoints, coordSystem);

    final bounds = path.getBounds();

    return PathWithBounds(path: path, bounds: bounds);
  }
}

/// Container for a path with its bounding rectangle.
class PathWithBounds {
  const PathWithBounds({required this.path, required this.bounds});

  final Path path;
  final Rect bounds;
}

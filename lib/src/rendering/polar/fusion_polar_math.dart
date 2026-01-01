import 'dart:math';
import 'package:flutter/material.dart';

/// High-performance polar coordinate mathematics for pie/donut charts.
///
/// All angles are in **degrees** for developer ergonomics (matching CSS, design tools).
/// Internal conversions to radians happen only at render time.
///
/// ## Coordinate System
///
/// ```
///           -90° (top)
///             │
///             │
///   180° ─────┼───── 0° (right)
///   -180°     │
///             │
///           90° (bottom)
/// ```
///
/// ## Performance Notes
///
/// - Trigonometric functions are cached where possible
/// - Angle normalization uses bitwise operations when safe
/// - Hit testing uses squared distances to avoid sqrt()
abstract final class FusionPolarMath {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  /// Degrees to radians conversion factor.
  static const double deg2Rad = pi / 180.0;

  /// Radians to degrees conversion factor.
  static const double rad2Deg = 180.0 / pi;

  /// Full circle in degrees.
  static const double fullCircle = 360.0;

  /// Small epsilon for floating point comparisons.
  static const double epsilon = 1e-10;

  // ===========================================================================
  // ANGLE CONVERSIONS
  // ===========================================================================

  /// Converts degrees to radians.
  @pragma('vm:prefer-inline')
  static double toRadians(double degrees) => degrees * deg2Rad;

  /// Converts radians to degrees.
  @pragma('vm:prefer-inline')
  static double toDegrees(double radians) => radians * rad2Deg;

  /// Normalizes angle to range [0, 360).
  @pragma('vm:prefer-inline')
  static double normalizeAngle(double degrees) {
    final normalized = degrees % fullCircle;
    return normalized < 0 ? normalized + fullCircle : normalized;
  }

  /// Normalizes angle to range [-180, 180).
  @pragma('vm:prefer-inline')
  static double normalizeAngleSigned(double degrees) {
    final normalized = normalizeAngle(degrees);
    return normalized >= 180 ? normalized - fullCircle : normalized;
  }

  // ===========================================================================
  // POINT CALCULATIONS
  // ===========================================================================

  /// Calculates a point on a circle.
  ///
  /// [center] - Center of the circle
  /// [radius] - Distance from center
  /// [angleDegrees] - Angle in degrees (0° = right, -90° = top)
  ///
  /// Returns the (x, y) offset on the circle.
  @pragma('vm:prefer-inline')
  static Offset pointOnCircle(
    Offset center,
    double radius,
    double angleDegrees,
  ) {
    final radians = toRadians(angleDegrees);
    return Offset(
      center.dx + radius * cos(radians),
      center.dy + radius * sin(radians),
    );
  }

  /// Calculates multiple points on a circle (optimized for arcs).
  ///
  /// Pre-allocates list and uses incremental angle calculation.
  static List<Offset> pointsOnArc({
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required int segments,
  }) {
    if (segments <= 0) return const [];
    if (segments == 1) {
      return [pointOnCircle(center, radius, startAngle + sweepAngle / 2)];
    }

    final points = List<Offset>.filled(segments + 1, Offset.zero);
    final angleStep = sweepAngle / segments;

    for (int i = 0; i <= segments; i++) {
      final angle = startAngle + (i * angleStep);
      points[i] = pointOnCircle(center, radius, angle);
    }

    return points;
  }

  // ===========================================================================
  // CENTROID CALCULATIONS
  // ===========================================================================

  /// Calculates the centroid (visual center) of a pie segment.
  ///
  /// For labels and tooltips, the centroid is at the midpoint between
  /// inner and outer radius, at the mid-angle of the segment.
  static Offset segmentCentroid({
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required double startAngle,
    required double sweepAngle,
  }) {
    final midAngle = startAngle + sweepAngle / 2;
    // Use true midpoint (50%) for better visual centering
    final centroidRadius = (innerRadius + outerRadius) / 2;
    return pointOnCircle(center, centroidRadius, midAngle);
  }

  /// Calculates the outer edge midpoint of a segment (for outside labels).
  static Offset segmentOuterMidpoint({
    required Offset center,
    required double outerRadius,
    required double startAngle,
    required double sweepAngle,
  }) {
    final midAngle = startAngle + sweepAngle / 2;
    return pointOnCircle(center, outerRadius, midAngle);
  }

  /// Calculates label anchor point with connector line endpoint.
  ///
  /// Returns a record with:
  /// - `arcPoint` - Point on the outer arc
  /// - `labelPoint` - Point where label should be positioned
  /// - `alignment` - Suggested text alignment
  static ({Offset arcPoint, Offset labelPoint, TextAlign alignment})
  labelAnchor({
    required Offset center,
    required double outerRadius,
    required double connectorLength,
    required double startAngle,
    required double sweepAngle,
  }) {
    final midAngle = startAngle + sweepAngle / 2;
    final normalizedAngle = normalizeAngle(midAngle);

    final arcPoint = pointOnCircle(center, outerRadius, midAngle);
    final labelPoint = pointOnCircle(
      center,
      outerRadius + connectorLength,
      midAngle,
    );

    // Determine text alignment based on which side of the chart
    final alignment = (normalizedAngle > 90 && normalizedAngle < 270)
        ? TextAlign.right
        : TextAlign.left;

    return (arcPoint: arcPoint, labelPoint: labelPoint, alignment: alignment);
  }

  // ===========================================================================
  // HIT TESTING (Performance Critical)
  // ===========================================================================

  /// Checks if a point is inside a pie/donut segment.
  ///
  /// Uses squared distance comparison to avoid expensive sqrt().
  ///
  /// [point] - The point to test
  /// [center] - Center of the pie
  /// [innerRadius] - Inner radius (0 for pie, >0 for donut)
  /// [outerRadius] - Outer radius
  /// [startAngle] - Start angle in degrees
  /// [sweepAngle] - Sweep angle in degrees (positive = clockwise)
  ///
  /// Returns `true` if point is inside the segment.
  static bool isPointInSegment({
    required Offset point,
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required double startAngle,
    required double sweepAngle,
  }) {
    // Fast path: check radius first (cheaper than angle)
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final distanceSquared = dx * dx + dy * dy;

    final innerRadiusSquared = innerRadius * innerRadius;
    final outerRadiusSquared = outerRadius * outerRadius;

    // Outside radius bounds - quick reject
    if (distanceSquared < innerRadiusSquared ||
        distanceSquared > outerRadiusSquared) {
      return false;
    }

    // Calculate point angle
    final pointAngle = toDegrees(atan2(dy, dx));
    final normalizedPointAngle = normalizeAngle(pointAngle);
    final normalizedStartAngle = normalizeAngle(startAngle);
    final endAngle = normalizedStartAngle + sweepAngle;

    // Handle wrap-around (e.g., segment from 350° to 10°)
    if (endAngle > fullCircle) {
      // Segment wraps around 0°
      return normalizedPointAngle >= normalizedStartAngle ||
          normalizedPointAngle <= (endAngle - fullCircle);
    } else if (endAngle < 0) {
      // Negative sweep (counter-clockwise)
      return normalizedPointAngle <= normalizedStartAngle &&
          normalizedPointAngle >=
              (normalizedStartAngle + sweepAngle + fullCircle) % fullCircle;
    } else {
      // Normal case
      return normalizedPointAngle >= normalizedStartAngle &&
          normalizedPointAngle <= endAngle;
    }
  }

  /// Finds which segment index a point is in (optimized for multiple segments).
  ///
  /// Returns segment index or -1 if not in any segment.
  static int findSegmentAtPoint({
    required Offset point,
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required List<({double startAngle, double sweepAngle})> segments,
  }) {
    // Pre-check radius bounds once
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final distanceSquared = dx * dx + dy * dy;

    final innerRadiusSquared = innerRadius * innerRadius;
    final outerRadiusSquared = outerRadius * outerRadius;

    if (distanceSquared < innerRadiusSquared ||
        distanceSquared > outerRadiusSquared) {
      return -1;
    }

    // Calculate angle once
    final pointAngle = normalizeAngle(toDegrees(atan2(dy, dx)));

    // Find matching segment
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final normalizedStart = normalizeAngle(segment.startAngle);
      final endAngle = normalizedStart + segment.sweepAngle;

      bool inSegment;
      if (endAngle > fullCircle) {
        inSegment =
            pointAngle >= normalizedStart ||
            pointAngle <= (endAngle - fullCircle);
      } else {
        inSegment = pointAngle >= normalizedStart && pointAngle <= endAngle;
      }

      if (inSegment) return i;
    }

    return -1;
  }

  // ===========================================================================
  // ARC PATH UTILITIES
  // ===========================================================================

  /// Creates an arc path for a pie segment.
  ///
  /// Supports both pie (from center) and donut (from inner arc) modes.
  static Path createSegmentPath({
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required double startAngle,
    required double sweepAngle,
    double cornerRadius = 0.0,
  }) {
    final path = Path();
    final startRad = toRadians(startAngle);
    final sweepRad = toRadians(sweepAngle);

    if (innerRadius <= 0) {
      // PIE mode: wedge from center
      if (cornerRadius > 0 && sweepAngle < 360) {
        // Rounded corners (complex path)
        _addRoundedPieSegment(
          path,
          center,
          outerRadius,
          startRad,
          sweepRad,
          cornerRadius,
        );
      } else {
        // Simple wedge
        path.moveTo(center.dx, center.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          startRad,
          sweepRad,
          false,
        );
        path.close();
      }
    } else {
      // DONUT mode: ring segment
      if (cornerRadius > 0 && sweepAngle < 360) {
        // Rounded corners (complex path)
        _addRoundedDonutSegment(
          path,
          center,
          innerRadius,
          outerRadius,
          startRad,
          sweepRad,
          cornerRadius,
        );
      } else {
        // Simple ring segment
        path.arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          startRad,
          sweepRad,
          true,
        );
        path.arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          startRad + sweepRad,
          -sweepRad,
          false,
        );
        path.close();
      }
    }

    return path;
  }

  /// Adds a rounded pie segment to the path.
  ///
  /// Rounds the two outer corners where radial lines meet the arc.
  /// The center point remains sharp.
  static void _addRoundedPieSegment(
    Path path,
    Offset center,
    double radius,
    double startRad,
    double sweepRad,
    double cornerRadius,
  ) {
    // Clamp corner radius to reasonable values
    // Max is limited by both radius and arc length
    final arcLength = radius * sweepRad.abs();
    final maxCorner = min(radius * 0.4, arcLength * 0.3);
    final cr = cornerRadius.clamp(0.0, maxCorner);

    if (cr < 1.0) {
      // Corner radius too small, use simple path
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startRad,
        sweepRad,
        false,
      );
      path.close();
      return;
    }

    // Calculate angular offset for corner radius on outer arc
    // cornerAngle = cr / radius (in radians)
    final cornerAngle = cr / radius;

    // Adjusted arc angles (shortened to make room for rounded corners)
    final adjustedStartRad = startRad + cornerAngle;
    final adjustedSweepRad = sweepRad - (cornerAngle * 2);

    // Points for the rounded corners
    // Start corner: where radial line meets outer arc
    final startRadialEnd = Offset(
      center.dx + (radius - cr) * cos(startRad),
      center.dy + (radius - cr) * sin(startRad),
    );
    final startArcPoint = Offset(
      center.dx + radius * cos(adjustedStartRad),
      center.dy + radius * sin(adjustedStartRad),
    );

    // End corner: where outer arc meets return radial line
    final endRad = startRad + sweepRad;
    final endRadialEnd = Offset(
      center.dx + (radius - cr) * cos(endRad),
      center.dy + (radius - cr) * sin(endRad),
    );

    // Control points for quadratic curves (at the actual corner positions)
    final startCorner = Offset(
      center.dx + radius * cos(startRad),
      center.dy + radius * sin(startRad),
    );
    final endCorner = Offset(
      center.dx + radius * cos(endRad),
      center.dy + radius * sin(endRad),
    );

    // Build the path
    path.moveTo(center.dx, center.dy);

    // Line to start of first corner
    path.lineTo(startRadialEnd.dx, startRadialEnd.dy);

    // Rounded corner at start (quadratic bezier)
    path.quadraticBezierTo(
      startCorner.dx,
      startCorner.dy,
      startArcPoint.dx,
      startArcPoint.dy,
    );

    // Main outer arc (shortened)
    if (adjustedSweepRad > 0.01) {
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        adjustedStartRad,
        adjustedSweepRad,
        false,
      );
    }

    // Rounded corner at end (quadratic bezier)
    path.quadraticBezierTo(
      endCorner.dx,
      endCorner.dy,
      endRadialEnd.dx,
      endRadialEnd.dy,
    );

    // Line back to center
    path.close();
  }

  /// Adds a rounded donut segment to the path.
  ///
  /// Rounds all four corners:
  /// - 2 outer corners (where radial edges meet outer arc)
  /// - 2 inner corners (where radial edges meet inner arc)
  static void _addRoundedDonutSegment(
    Path path,
    Offset center,
    double innerRadius,
    double outerRadius,
    double startRad,
    double sweepRad,
    double cornerRadius,
  ) {
    // Clamp corner radius to fit within the ring width and arc length
    final ringWidth = outerRadius - innerRadius;
    final minArcLength = innerRadius * sweepRad.abs();
    final maxCorner = min(ringWidth * 0.4, minArcLength * 0.3);
    final cr = cornerRadius.clamp(0.0, maxCorner);

    if (cr < 1.0) {
      // Corner radius too small, use simple path
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startRad,
        sweepRad,
        true,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startRad + sweepRad,
        -sweepRad,
        false,
      );
      path.close();
      return;
    }

    // Calculate angular offsets for corners on each arc
    final outerCornerAngle = cr / outerRadius;
    final innerCornerAngle = cr / innerRadius;

    final endRad = startRad + sweepRad;

    // === OUTER ARC POINTS ===
    // Start corner (outer)
    final outerStartCorner = Offset(
      center.dx + outerRadius * cos(startRad),
      center.dy + outerRadius * sin(startRad),
    );
    final outerStartArc = Offset(
      center.dx + outerRadius * cos(startRad + outerCornerAngle),
      center.dy + outerRadius * sin(startRad + outerCornerAngle),
    );
    final outerStartRadial = Offset(
      center.dx + (outerRadius - cr) * cos(startRad),
      center.dy + (outerRadius - cr) * sin(startRad),
    );

    // End corner (outer)
    final outerEndCorner = Offset(
      center.dx + outerRadius * cos(endRad),
      center.dy + outerRadius * sin(endRad),
    );
    final outerEndRadial = Offset(
      center.dx + (outerRadius - cr) * cos(endRad),
      center.dy + (outerRadius - cr) * sin(endRad),
    );

    // === INNER ARC POINTS ===
    // End corner (inner) - we traverse inner arc in reverse
    final innerEndCorner = Offset(
      center.dx + innerRadius * cos(endRad),
      center.dy + innerRadius * sin(endRad),
    );
    final innerEndArc = Offset(
      center.dx + innerRadius * cos(endRad - innerCornerAngle),
      center.dy + innerRadius * sin(endRad - innerCornerAngle),
    );
    final innerEndRadial = Offset(
      center.dx + (innerRadius + cr) * cos(endRad),
      center.dy + (innerRadius + cr) * sin(endRad),
    );

    // Start corner (inner)
    final innerStartCorner = Offset(
      center.dx + innerRadius * cos(startRad),
      center.dy + innerRadius * sin(startRad),
    );
    final innerStartRadial = Offset(
      center.dx + (innerRadius + cr) * cos(startRad),
      center.dy + (innerRadius + cr) * sin(startRad),
    );

    // === BUILD PATH ===
    // Start at the radial edge between inner and outer at startRad
    path.moveTo(outerStartRadial.dx, outerStartRadial.dy);

    // 1. Outer start corner (quadratic bezier)
    path.quadraticBezierTo(
      outerStartCorner.dx,
      outerStartCorner.dy,
      outerStartArc.dx,
      outerStartArc.dy,
    );

    // 2. Outer arc (main arc, shortened)
    final outerArcSweep = sweepRad - (outerCornerAngle * 2);
    if (outerArcSweep > 0.01) {
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startRad + outerCornerAngle,
        outerArcSweep,
        false,
      );
    }

    // 3. Outer end corner (quadratic bezier)
    path.quadraticBezierTo(
      outerEndCorner.dx,
      outerEndCorner.dy,
      outerEndRadial.dx,
      outerEndRadial.dy,
    );

    // 4. Radial line from outer to inner at endRad
    path.lineTo(innerEndRadial.dx, innerEndRadial.dy);

    // 5. Inner end corner (quadratic bezier)
    path.quadraticBezierTo(
      innerEndCorner.dx,
      innerEndCorner.dy,
      innerEndArc.dx,
      innerEndArc.dy,
    );

    // 6. Inner arc (reverse direction, shortened)
    final innerArcSweep = -(sweepRad - (innerCornerAngle * 2));
    if (innerArcSweep.abs() > 0.01) {
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        endRad - innerCornerAngle,
        innerArcSweep,
        false,
      );
    }

    // 7. Inner start corner (quadratic bezier)
    path.quadraticBezierTo(
      innerStartCorner.dx,
      innerStartCorner.dy,
      innerStartRadial.dx,
      innerStartRadial.dy,
    );

    // 8. Close path (radial line from inner to outer at startRad)
    path.close();
  }

  // ===========================================================================
  // GRADIENT UTILITIES
  // ===========================================================================

  /// Creates a sweep gradient shader for pie charts.
  ///
  /// Unlike linear gradients, sweep gradients follow the arc of segments.
  static Shader createSweepGradient({
    required Offset center,
    required List<Color> colors,
    List<double>? stops,
    double startAngle = -90.0,
    double endAngle = 270.0,
  }) {
    return SweepGradient(
      center: Alignment.center,
      startAngle: toRadians(startAngle),
      endAngle: toRadians(endAngle),
      colors: colors,
      stops: stops,
    ).createShader(Rect.fromCircle(center: center, radius: 1));
  }

  // ===========================================================================
  // LAYOUT UTILITIES
  // ===========================================================================

  /// Calculates optimal pie radius given available space.
  ///
  /// Accounts for:
  /// - Labels (if outside)
  /// - Legend position
  /// - Padding
  static ({double radius, Offset center}) calculateOptimalLayout({
    required Size availableSize,
    required double outerRadiusRatio,
    required bool hasOutsideLabels,
    required double labelSpace,
    required EdgeInsets padding,
  }) {
    // Available drawing area
    final drawWidth = availableSize.width - padding.horizontal;
    final drawHeight = availableSize.height - padding.vertical;

    // Account for label space
    final effectiveWidth = hasOutsideLabels
        ? drawWidth - (labelSpace * 2)
        : drawWidth;
    final effectiveHeight = hasOutsideLabels
        ? drawHeight - (labelSpace * 2)
        : drawHeight;

    // Maximum radius that fits
    final maxRadius = min(effectiveWidth, effectiveHeight) / 2;
    final radius = maxRadius * outerRadiusRatio;

    // Center in available space
    final center = Offset(
      padding.left + drawWidth / 2,
      padding.top + drawHeight / 2,
    );

    return (radius: radius, center: center);
  }

  /// Distributes labels to avoid overlapping (smart positioning).
  ///
  /// Takes a list of label positions and adjusts them to prevent overlap.
  static List<Offset> distributeLabels({
    required List<Offset> idealPositions,
    required List<Size> labelSizes,
    required double minSpacing,
    required Rect bounds,
  }) {
    if (idealPositions.isEmpty) return const [];

    final adjusted = List<Offset>.from(idealPositions);

    // Simple collision resolution - push overlapping labels apart
    for (int iteration = 0; iteration < 10; iteration++) {
      bool hasOverlap = false;

      for (int i = 0; i < adjusted.length; i++) {
        for (int j = i + 1; j < adjusted.length; j++) {
          final rect1 = Rect.fromCenter(
            center: adjusted[i],
            width: labelSizes[i].width + minSpacing,
            height: labelSizes[i].height + minSpacing,
          );
          final rect2 = Rect.fromCenter(
            center: adjusted[j],
            width: labelSizes[j].width + minSpacing,
            height: labelSizes[j].height + minSpacing,
          );

          if (rect1.overlaps(rect2)) {
            hasOverlap = true;

            // Push apart vertically
            final overlap = (rect1.bottom - rect2.top).abs();
            final push = overlap / 2 + minSpacing / 2;

            if (adjusted[i].dy < adjusted[j].dy) {
              adjusted[i] = Offset(adjusted[i].dx, adjusted[i].dy - push);
              adjusted[j] = Offset(adjusted[j].dx, adjusted[j].dy + push);
            } else {
              adjusted[i] = Offset(adjusted[i].dx, adjusted[i].dy + push);
              adjusted[j] = Offset(adjusted[j].dx, adjusted[j].dy - push);
            }
          }
        }
      }

      if (!hasOverlap) break;
    }

    // Clamp to bounds
    for (int i = 0; i < adjusted.length; i++) {
      adjusted[i] = Offset(
        adjusted[i].dx.clamp(bounds.left, bounds.right),
        adjusted[i].dy.clamp(bounds.top, bounds.bottom),
      );
    }

    return adjusted;
  }
}

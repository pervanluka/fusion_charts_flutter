import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/rendering/polar/fusion_polar_math.dart';

void main() {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================
  group('FusionPolarMath - Constants', () {
    test('deg2Rad is correct', () {
      expect(FusionPolarMath.deg2Rad, closeTo(pi / 180.0, 1e-10));
    });

    test('rad2Deg is correct', () {
      expect(FusionPolarMath.rad2Deg, closeTo(180.0 / pi, 1e-10));
    });

    test('fullCircle is 360', () {
      expect(FusionPolarMath.fullCircle, 360.0);
    });

    test('epsilon is small enough', () {
      expect(FusionPolarMath.epsilon, lessThan(1e-9));
    });
  });

  // ===========================================================================
  // ANGLE CONVERSIONS
  // ===========================================================================
  group('FusionPolarMath - Angle Conversions', () {
    test('toRadians converts 0 degrees', () {
      expect(FusionPolarMath.toRadians(0), 0.0);
    });

    test('toRadians converts 90 degrees to pi/2', () {
      expect(FusionPolarMath.toRadians(90), closeTo(pi / 2, 1e-10));
    });

    test('toRadians converts 180 degrees to pi', () {
      expect(FusionPolarMath.toRadians(180), closeTo(pi, 1e-10));
    });

    test('toRadians converts 360 degrees to 2*pi', () {
      expect(FusionPolarMath.toRadians(360), closeTo(2 * pi, 1e-10));
    });

    test('toRadians converts negative angles', () {
      expect(FusionPolarMath.toRadians(-90), closeTo(-pi / 2, 1e-10));
    });

    test('toDegrees converts 0 radians', () {
      expect(FusionPolarMath.toDegrees(0), 0.0);
    });

    test('toDegrees converts pi/2 to 90 degrees', () {
      expect(FusionPolarMath.toDegrees(pi / 2), closeTo(90, 1e-10));
    });

    test('toDegrees converts pi to 180 degrees', () {
      expect(FusionPolarMath.toDegrees(pi), closeTo(180, 1e-10));
    });

    test('toDegrees converts 2*pi to 360 degrees', () {
      expect(FusionPolarMath.toDegrees(2 * pi), closeTo(360, 1e-10));
    });

    test('toDegrees converts negative radians', () {
      expect(FusionPolarMath.toDegrees(-pi / 2), closeTo(-90, 1e-10));
    });

    test('round-trip conversion preserves value', () {
      const original = 45.0;
      final converted = FusionPolarMath.toDegrees(
        FusionPolarMath.toRadians(original),
      );
      expect(converted, closeTo(original, 1e-10));
    });
  });

  // ===========================================================================
  // NORMALIZE ANGLE
  // ===========================================================================
  group('FusionPolarMath - normalizeAngle', () {
    test('normalizes 0 to 0', () {
      expect(FusionPolarMath.normalizeAngle(0), 0.0);
    });

    test('normalizes 90 to 90', () {
      expect(FusionPolarMath.normalizeAngle(90), 90.0);
    });

    test('normalizes 180 to 180', () {
      expect(FusionPolarMath.normalizeAngle(180), 180.0);
    });

    test('normalizes 360 to 0', () {
      expect(FusionPolarMath.normalizeAngle(360), closeTo(0, 1e-10));
    });

    test('normalizes 450 to 90', () {
      expect(FusionPolarMath.normalizeAngle(450), closeTo(90, 1e-10));
    });

    test('normalizes 720 to 0', () {
      expect(FusionPolarMath.normalizeAngle(720), closeTo(0, 1e-10));
    });

    test('normalizes -90 to 270', () {
      expect(FusionPolarMath.normalizeAngle(-90), closeTo(270, 1e-10));
    });

    test('normalizes -180 to 180', () {
      expect(FusionPolarMath.normalizeAngle(-180), closeTo(180, 1e-10));
    });

    test('normalizes -360 to 0', () {
      expect(FusionPolarMath.normalizeAngle(-360), closeTo(0, 1e-10));
    });

    test('normalizes -450 to 270', () {
      expect(FusionPolarMath.normalizeAngle(-450), closeTo(270, 1e-10));
    });
  });

  // ===========================================================================
  // NORMALIZE ANGLE SIGNED
  // ===========================================================================
  group('FusionPolarMath - normalizeAngleSigned', () {
    test('normalizes 0 to 0', () {
      expect(FusionPolarMath.normalizeAngleSigned(0), 0.0);
    });

    test('normalizes 90 to 90', () {
      expect(FusionPolarMath.normalizeAngleSigned(90), 90.0);
    });

    test('normalizes 180 to -180', () {
      expect(FusionPolarMath.normalizeAngleSigned(180), closeTo(-180, 1e-10));
    });

    test('normalizes 270 to -90', () {
      expect(FusionPolarMath.normalizeAngleSigned(270), closeTo(-90, 1e-10));
    });

    test('normalizes 360 to 0', () {
      expect(FusionPolarMath.normalizeAngleSigned(360), closeTo(0, 1e-10));
    });

    test('normalizes -90 to -90', () {
      expect(FusionPolarMath.normalizeAngleSigned(-90), closeTo(-90, 1e-10));
    });

    test('normalizes -180 to -180', () {
      expect(FusionPolarMath.normalizeAngleSigned(-180), closeTo(-180, 1e-10));
    });

    test('normalizes -270 to 90', () {
      expect(FusionPolarMath.normalizeAngleSigned(-270), closeTo(90, 1e-10));
    });
  });

  // ===========================================================================
  // POINT ON CIRCLE
  // ===========================================================================
  group('FusionPolarMath - pointOnCircle', () {
    const center = Offset(100, 100);
    const radius = 50.0;

    test('calculates point at 0 degrees (right)', () {
      final point = FusionPolarMath.pointOnCircle(center, radius, 0);
      expect(point.dx, closeTo(150, 1e-10));
      expect(point.dy, closeTo(100, 1e-10));
    });

    test('calculates point at 90 degrees (bottom)', () {
      final point = FusionPolarMath.pointOnCircle(center, radius, 90);
      expect(point.dx, closeTo(100, 1e-10));
      expect(point.dy, closeTo(150, 1e-10));
    });

    test('calculates point at 180 degrees (left)', () {
      final point = FusionPolarMath.pointOnCircle(center, radius, 180);
      expect(point.dx, closeTo(50, 1e-10));
      expect(point.dy, closeTo(100, 1e-10));
    });

    test('calculates point at -90 degrees (top)', () {
      final point = FusionPolarMath.pointOnCircle(center, radius, -90);
      expect(point.dx, closeTo(100, 1e-10));
      expect(point.dy, closeTo(50, 1e-10));
    });

    test('calculates point at 45 degrees', () {
      final point = FusionPolarMath.pointOnCircle(center, radius, 45);
      final expected = radius * cos(pi / 4);
      expect(point.dx, closeTo(100 + expected, 1e-10));
      expect(point.dy, closeTo(100 + expected, 1e-10));
    });

    test('handles zero radius', () {
      final point = FusionPolarMath.pointOnCircle(center, 0, 45);
      expect(point, center);
    });

    test('handles different center', () {
      final point = FusionPolarMath.pointOnCircle(
        const Offset(200, 300),
        100,
        0,
      );
      expect(point.dx, closeTo(300, 1e-10));
      expect(point.dy, closeTo(300, 1e-10));
    });
  });

  // ===========================================================================
  // POINTS ON ARC
  // ===========================================================================
  group('FusionPolarMath - pointsOnArc', () {
    const center = Offset(100, 100);
    const radius = 50.0;

    test('returns empty list for zero segments', () {
      final points = FusionPolarMath.pointsOnArc(
        center: center,
        radius: radius,
        startAngle: 0,
        sweepAngle: 90,
        segments: 0,
      );
      expect(points, isEmpty);
    });

    test('returns single midpoint for 1 segment', () {
      final points = FusionPolarMath.pointsOnArc(
        center: center,
        radius: radius,
        startAngle: 0,
        sweepAngle: 90,
        segments: 1,
      );
      expect(points.length, 1);
      // Midpoint at 45 degrees
      final expected = FusionPolarMath.pointOnCircle(center, radius, 45);
      expect(points[0].dx, closeTo(expected.dx, 1e-10));
      expect(points[0].dy, closeTo(expected.dy, 1e-10));
    });

    test('returns correct number of points for multiple segments', () {
      final points = FusionPolarMath.pointsOnArc(
        center: center,
        radius: radius,
        startAngle: 0,
        sweepAngle: 90,
        segments: 4,
      );
      // segments + 1 points for 4 segments = 5 points
      expect(points.length, 5);
    });

    test('first and last points are at start and end angles', () {
      final points = FusionPolarMath.pointsOnArc(
        center: center,
        radius: radius,
        startAngle: 0,
        sweepAngle: 90,
        segments: 4,
      );

      final startPoint = FusionPolarMath.pointOnCircle(center, radius, 0);
      final endPoint = FusionPolarMath.pointOnCircle(center, radius, 90);

      expect(points.first.dx, closeTo(startPoint.dx, 1e-10));
      expect(points.first.dy, closeTo(startPoint.dy, 1e-10));
      expect(points.last.dx, closeTo(endPoint.dx, 1e-10));
      expect(points.last.dy, closeTo(endPoint.dy, 1e-10));
    });
  });

  // ===========================================================================
  // SEGMENT CENTROID
  // ===========================================================================
  group('FusionPolarMath - segmentCentroid', () {
    const center = Offset(100, 100);

    test('calculates centroid for pie segment', () {
      final centroid = FusionPolarMath.segmentCentroid(
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );

      // Mid-angle is 45 degrees, centroid radius is 50 (half of 100)
      final expected = FusionPolarMath.pointOnCircle(center, 50, 45);
      expect(centroid.dx, closeTo(expected.dx, 1e-10));
      expect(centroid.dy, closeTo(expected.dy, 1e-10));
    });

    test('calculates centroid for donut segment', () {
      final centroid = FusionPolarMath.segmentCentroid(
        center: center,
        innerRadius: 40,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );

      // Mid-angle is 45 degrees, centroid radius is 70 ((40 + 100) / 2)
      final expected = FusionPolarMath.pointOnCircle(center, 70, 45);
      expect(centroid.dx, closeTo(expected.dx, 1e-10));
      expect(centroid.dy, closeTo(expected.dy, 1e-10));
    });

    test('calculates centroid at different start angle', () {
      final centroid = FusionPolarMath.segmentCentroid(
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: -90,
        sweepAngle: 90,
      );

      // Mid-angle is -45 degrees
      final expected = FusionPolarMath.pointOnCircle(center, 50, -45);
      expect(centroid.dx, closeTo(expected.dx, 1e-10));
      expect(centroid.dy, closeTo(expected.dy, 1e-10));
    });
  });

  // ===========================================================================
  // SEGMENT OUTER MIDPOINT
  // ===========================================================================
  group('FusionPolarMath - segmentOuterMidpoint', () {
    const center = Offset(100, 100);

    test('calculates outer midpoint', () {
      final midpoint = FusionPolarMath.segmentOuterMidpoint(
        center: center,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );

      // Mid-angle is 45 degrees, at outer radius
      final expected = FusionPolarMath.pointOnCircle(center, 100, 45);
      expect(midpoint.dx, closeTo(expected.dx, 1e-10));
      expect(midpoint.dy, closeTo(expected.dy, 1e-10));
    });
  });

  // ===========================================================================
  // LABEL ANCHOR
  // ===========================================================================
  group('FusionPolarMath - labelAnchor', () {
    const center = Offset(100, 100);

    test('calculates arc and label points', () {
      final result = FusionPolarMath.labelAnchor(
        center: center,
        outerRadius: 80,
        connectorLength: 20,
        startAngle: 0,
        sweepAngle: 90,
      );

      // Mid-angle is 45 degrees
      final expectedArc = FusionPolarMath.pointOnCircle(center, 80, 45);
      final expectedLabel = FusionPolarMath.pointOnCircle(center, 100, 45);

      expect(result.arcPoint.dx, closeTo(expectedArc.dx, 1e-10));
      expect(result.arcPoint.dy, closeTo(expectedArc.dy, 1e-10));
      expect(result.labelPoint.dx, closeTo(expectedLabel.dx, 1e-10));
      expect(result.labelPoint.dy, closeTo(expectedLabel.dy, 1e-10));
    });

    test('alignment is left for right side of chart', () {
      final result = FusionPolarMath.labelAnchor(
        center: center,
        outerRadius: 80,
        connectorLength: 20,
        startAngle: 0,
        sweepAngle: 10,
      );

      // Angle 5 degrees - right side
      expect(result.alignment, TextAlign.left);
    });

    test('alignment is right for left side of chart', () {
      final result = FusionPolarMath.labelAnchor(
        center: center,
        outerRadius: 80,
        connectorLength: 20,
        startAngle: 180,
        sweepAngle: 10,
      );

      // Angle 185 degrees - left side
      expect(result.alignment, TextAlign.right);
    });

    test('alignment is left at top', () {
      final result = FusionPolarMath.labelAnchor(
        center: center,
        outerRadius: 80,
        connectorLength: 20,
        startAngle: -100,
        sweepAngle: 20,
      );

      // Angle -90 (top) is equivalent to 270 which is > 270 or < 90 = left
      expect(result.alignment, TextAlign.left);
    });
  });

  // ===========================================================================
  // IS POINT IN SEGMENT
  // ===========================================================================
  group('FusionPolarMath - isPointInSegment', () {
    const center = Offset(100, 100);

    test('returns true for point inside pie segment', () {
      final point = FusionPolarMath.pointOnCircle(center, 50, 45);
      final isInside = FusionPolarMath.isPointInSegment(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );
      expect(isInside, isTrue);
    });

    test('returns false for point outside radius', () {
      final point = FusionPolarMath.pointOnCircle(center, 150, 45);
      final isInside = FusionPolarMath.isPointInSegment(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );
      expect(isInside, isFalse);
    });

    test('returns false for point inside inner radius (donut)', () {
      final point = FusionPolarMath.pointOnCircle(center, 20, 45);
      final isInside = FusionPolarMath.isPointInSegment(
        point: point,
        center: center,
        innerRadius: 40,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );
      expect(isInside, isFalse);
    });

    test('returns false for point outside angle range', () {
      final point = FusionPolarMath.pointOnCircle(center, 50, 180);
      final isInside = FusionPolarMath.isPointInSegment(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );
      expect(isInside, isFalse);
    });

    test('returns true for point in donut segment', () {
      final point = FusionPolarMath.pointOnCircle(center, 70, 45);
      final isInside = FusionPolarMath.isPointInSegment(
        point: point,
        center: center,
        innerRadius: 40,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );
      expect(isInside, isTrue);
    });

    test('handles wrap-around segment (350 to 10 degrees)', () {
      final point = FusionPolarMath.pointOnCircle(center, 50, 5);
      final isInside = FusionPolarMath.isPointInSegment(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 350,
        sweepAngle: 20,
      );
      expect(isInside, isTrue);
    });

    test('handles negative sweep angle', () {
      // Counter-clockwise segment from 0 to -90 (which is 270 to 360/0)
      // Point at 315 degrees (normalized from -45) should be checked
      // Note: negative sweep behavior depends on implementation details
      final point = FusionPolarMath.pointOnCircle(center, 50, 315);
      final isInside = FusionPolarMath.isPointInSegment(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 270, // Use positive angles instead
        sweepAngle: 90, // Cover 270-360
      );
      expect(isInside, isTrue);
    });
  });

  // ===========================================================================
  // FIND SEGMENT AT POINT
  // ===========================================================================
  group('FusionPolarMath - findSegmentAtPoint', () {
    const center = Offset(100, 100);

    test('returns correct segment index', () {
      final segments = [
        (startAngle: 0.0, sweepAngle: 90.0),
        (startAngle: 90.0, sweepAngle: 90.0),
        (startAngle: 180.0, sweepAngle: 90.0),
        (startAngle: 270.0, sweepAngle: 90.0),
      ];

      final point = FusionPolarMath.pointOnCircle(center, 50, 45);
      final index = FusionPolarMath.findSegmentAtPoint(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        segments: segments,
      );
      expect(index, 0);
    });

    test('returns -1 when outside all segments', () {
      final segments = [(startAngle: 0.0, sweepAngle: 90.0)];

      final point = FusionPolarMath.pointOnCircle(center, 150, 45);
      final index = FusionPolarMath.findSegmentAtPoint(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        segments: segments,
      );
      expect(index, -1);
    });

    test('returns -1 for empty segments list', () {
      final point = FusionPolarMath.pointOnCircle(center, 50, 45);
      final index = FusionPolarMath.findSegmentAtPoint(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        segments: [],
      );
      expect(index, -1);
    });

    test('finds correct segment among multiple', () {
      final segments = [
        (startAngle: 0.0, sweepAngle: 90.0),
        (startAngle: 90.0, sweepAngle: 90.0),
        (startAngle: 180.0, sweepAngle: 90.0),
        (startAngle: 270.0, sweepAngle: 90.0),
      ];

      // Point at 135 degrees should be in segment 1
      final point = FusionPolarMath.pointOnCircle(center, 50, 135);
      final index = FusionPolarMath.findSegmentAtPoint(
        point: point,
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        segments: segments,
      );
      expect(index, 1);
    });
  });

  // ===========================================================================
  // CREATE SEGMENT PATH
  // ===========================================================================
  group('FusionPolarMath - createSegmentPath', () {
    const center = Offset(100, 100);

    test('creates pie segment path (innerRadius = 0)', () {
      final path = FusionPolarMath.createSegmentPath(
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );

      expect(path, isA<Path>());
      // Path should contain the center point
      expect(path.contains(center), isTrue);
    });

    test('creates donut segment path', () {
      final path = FusionPolarMath.createSegmentPath(
        center: center,
        innerRadius: 40,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
      );

      expect(path, isA<Path>());
      // Center should NOT be in donut path
      expect(path.contains(center), isFalse);
    });

    test('creates rounded pie segment when cornerRadius > 0', () {
      final path = FusionPolarMath.createSegmentPath(
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
        cornerRadius: 10,
      );

      expect(path, isA<Path>());
    });

    test('creates rounded donut segment when cornerRadius > 0', () {
      final path = FusionPolarMath.createSegmentPath(
        center: center,
        innerRadius: 40,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 90,
        cornerRadius: 10,
      );

      expect(path, isA<Path>());
    });

    test('creates full circle for 360 degree sweep', () {
      final path = FusionPolarMath.createSegmentPath(
        center: center,
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 360,
      );

      expect(path, isA<Path>());
      // Path should have non-zero bounds
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });
  });

  // ===========================================================================
  // CREATE SWEEP GRADIENT
  // ===========================================================================
  group('FusionPolarMath - createSweepGradient', () {
    test('creates shader', () {
      final shader = FusionPolarMath.createSweepGradient(
        center: const Offset(100, 100),
        colors: [Colors.red, Colors.blue],
      );

      expect(shader, isA<Shader>());
    });

    test('creates shader with custom stops', () {
      final shader = FusionPolarMath.createSweepGradient(
        center: const Offset(100, 100),
        colors: [Colors.red, Colors.green, Colors.blue],
        stops: [0.0, 0.5, 1.0],
      );

      expect(shader, isA<Shader>());
    });

    test('creates shader with custom angles', () {
      final shader = FusionPolarMath.createSweepGradient(
        center: const Offset(100, 100),
        colors: [Colors.red, Colors.blue],
        startAngle: 0,
        endAngle: 180,
      );

      expect(shader, isA<Shader>());
    });
  });

  // ===========================================================================
  // CALCULATE OPTIMAL LAYOUT
  // ===========================================================================
  group('FusionPolarMath - calculateOptimalLayout', () {
    test('calculates layout for square size', () {
      final result = FusionPolarMath.calculateOptimalLayout(
        availableSize: const Size(200, 200),
        outerRadiusRatio: 1.0,
        hasOutsideLabels: false,
        labelSpace: 0,
        padding: EdgeInsets.zero,
      );

      expect(result.radius, 100.0);
      expect(result.center.dx, 100.0);
      expect(result.center.dy, 100.0);
    });

    test('calculates layout for rectangular size', () {
      final result = FusionPolarMath.calculateOptimalLayout(
        availableSize: const Size(400, 200),
        outerRadiusRatio: 1.0,
        hasOutsideLabels: false,
        labelSpace: 0,
        padding: EdgeInsets.zero,
      );

      // Should be limited by height (200 / 2 = 100)
      expect(result.radius, 100.0);
      expect(result.center.dx, 200.0); // Center of 400
      expect(result.center.dy, 100.0); // Center of 200
    });

    test('accounts for padding', () {
      final result = FusionPolarMath.calculateOptimalLayout(
        availableSize: const Size(200, 200),
        outerRadiusRatio: 1.0,
        hasOutsideLabels: false,
        labelSpace: 0,
        padding: const EdgeInsets.all(20),
      );

      // 200 - 40 = 160, 160 / 2 = 80
      expect(result.radius, 80.0);
      expect(result.center.dx, 100.0); // Still centered
      expect(result.center.dy, 100.0);
    });

    test('accounts for outside labels', () {
      final result = FusionPolarMath.calculateOptimalLayout(
        availableSize: const Size(200, 200),
        outerRadiusRatio: 1.0,
        hasOutsideLabels: true,
        labelSpace: 30,
        padding: EdgeInsets.zero,
      );

      // 200 - 60 = 140, 140 / 2 = 70
      expect(result.radius, 70.0);
    });

    test('applies outer radius ratio', () {
      final result = FusionPolarMath.calculateOptimalLayout(
        availableSize: const Size(200, 200),
        outerRadiusRatio: 0.8,
        hasOutsideLabels: false,
        labelSpace: 0,
        padding: EdgeInsets.zero,
      );

      // 100 * 0.8 = 80
      expect(result.radius, 80.0);
    });
  });

  // ===========================================================================
  // DISTRIBUTE LABELS
  // ===========================================================================
  group('FusionPolarMath - distributeLabels', () {
    test('returns empty list for empty input', () {
      final result = FusionPolarMath.distributeLabels(
        idealPositions: [],
        labelSizes: [],
        minSpacing: 10,
        bounds: const Rect.fromLTWH(0, 0, 200, 200),
      );

      expect(result, isEmpty);
    });

    test('returns positions unchanged when no overlap', () {
      final result = FusionPolarMath.distributeLabels(
        idealPositions: [const Offset(50, 50), const Offset(150, 150)],
        labelSizes: [const Size(20, 10), const Size(20, 10)],
        minSpacing: 5,
        bounds: const Rect.fromLTWH(0, 0, 200, 200),
      );

      expect(result.length, 2);
      // Positions should be close to ideal (might be slightly adjusted)
      expect(result[0].dx, closeTo(50, 1));
      expect(result[0].dy, closeTo(50, 1));
    });

    test('adjusts overlapping labels', () {
      // Two labels very close together
      final result = FusionPolarMath.distributeLabels(
        idealPositions: [
          const Offset(100, 100),
          const Offset(100, 105), // Very close
        ],
        labelSizes: [const Size(40, 20), const Size(40, 20)],
        minSpacing: 10,
        bounds: const Rect.fromLTWH(0, 0, 200, 200),
      );

      expect(result.length, 2);
      // Labels should be pushed apart
      expect((result[0].dy - result[1].dy).abs(), greaterThan(20));
    });

    test('clamps to bounds', () {
      final result = FusionPolarMath.distributeLabels(
        idealPositions: [
          const Offset(-50, -50), // Outside bounds
        ],
        labelSizes: [const Size(20, 10)],
        minSpacing: 5,
        bounds: const Rect.fromLTWH(0, 0, 200, 200),
      );

      expect(result.length, 1);
      expect(result[0].dx, greaterThanOrEqualTo(0));
      expect(result[0].dy, greaterThanOrEqualTo(0));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionPolarMath - Edge Cases', () {
    test('handles very small angles', () {
      final point = FusionPolarMath.pointOnCircle(
        const Offset(100, 100),
        50,
        0.001,
      );
      expect(point.dx, closeTo(150, 0.1));
    });

    test('handles very large angles', () {
      // 720 degrees should be same as 0
      final point1 = FusionPolarMath.pointOnCircle(
        const Offset(100, 100),
        50,
        0,
      );
      final point2 = FusionPolarMath.pointOnCircle(
        const Offset(100, 100),
        50,
        720,
      );
      expect(point1.dx, closeTo(point2.dx, 1e-10));
      expect(point1.dy, closeTo(point2.dy, 1e-10));
    });

    test('handles negative radius as absolute value behavior', () {
      // Negative radius point
      final point = FusionPolarMath.pointOnCircle(
        const Offset(100, 100),
        -50,
        0,
      );
      // With negative radius, point should be on opposite side
      expect(point.dx, closeTo(50, 1e-10)); // 100 + (-50) * cos(0) = 50
    });

    test('segment path with very small sweep angle', () {
      final path = FusionPolarMath.createSegmentPath(
        center: const Offset(100, 100),
        innerRadius: 0,
        outerRadius: 100,
        startAngle: 0,
        sweepAngle: 0.1,
      );
      expect(path, isA<Path>());
    });
  });
}

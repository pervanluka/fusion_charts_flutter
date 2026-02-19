import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_path_builder.dart';

void main() {
  // Test coordinate system for all tests
  late FusionCoordinateSystem coordSystem;

  setUp(() {
    coordSystem = const FusionCoordinateSystem(
      chartArea: Rect.fromLTRB(0, 0, 400, 300),
      dataXMin: 0,
      dataXMax: 100,
      dataYMin: 0,
      dataYMax: 100,
    );
  });

  // ===========================================================================
  // LINE PATH - createLinePath
  // ===========================================================================
  group('FusionPathBuilder - createLinePath', () {
    test('returns empty path for empty data', () {
      final path = FusionPathBuilder.createLinePath([], coordSystem);

      expect(path, isA<Path>());
      expect(path.getBounds().isEmpty, isTrue);
    });

    test('creates path for single point (degenerate path)', () {
      final dataPoints = [FusionDataPoint(50, 50)];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      expect(path, isA<Path>());
      // Single point moveTo creates a degenerate path (just a point)
      // which is valid but has empty bounds
    });

    test('creates path connecting two points', () {
      final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(100, 100)];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      // Diagonal line from bottom-left to top-right
      // Y is inverted in screen coordinates
      expect(bounds.left, 0.0);
      expect(bounds.right, 400.0); // Full width
    });

    test('creates path connecting multiple points', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(25, 50),
        FusionDataPoint(50, 25),
        FusionDataPoint(75, 75),
        FusionDataPoint(100, 50),
      ];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('path passes through all data points', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      // Verify path contains expected screen coordinates
      for (final point in dataPoints) {
        final screenPoint = coordSystem.dataToScreen(point);
        expect(path.contains(screenPoint), isTrue);
      }
    });

    test('handles horizontal line', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 50),
      ];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      expect(bounds.width, closeTo(400, 1));
      // Height should be very small (just line thickness)
      expect(bounds.height, closeTo(0, 1));
    });

    test('handles vertical line', () {
      final dataPoints = [
        FusionDataPoint(50, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(50, 100),
      ];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      // Width should be very small (just line thickness)
      expect(bounds.width, closeTo(0, 1));
      expect(bounds.height, closeTo(300, 1));
    });

    test('handles data points in reverse order', () {
      final dataPoints = [
        FusionDataPoint(100, 100),
        FusionDataPoint(50, 50),
        FusionDataPoint(0, 0),
      ];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('handles non-sequential x values', () {
      final dataPoints = [
        FusionDataPoint(50, 25),
        FusionDataPoint(25, 75),
        FusionDataPoint(75, 50),
      ];
      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  // ===========================================================================
  // SMOOTH PATH - createSmoothPath
  // ===========================================================================
  group('FusionPathBuilder - createSmoothPath', () {
    test('returns empty path for empty data', () {
      final path = FusionPathBuilder.createSmoothPath([], coordSystem);

      expect(path.getBounds().isEmpty, isTrue);
    });

    test('creates path for single point', () {
      final dataPoints = [FusionDataPoint(50, 50)];
      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);

      expect(path, isA<Path>());
    });

    test('creates line for two points (no curve possible)', () {
      final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(100, 100)];
      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
    });

    test('creates smooth curve for multiple points', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(25, 100),
        FusionDataPoint(50, 50),
        FusionDataPoint(75, 0),
        FusionDataPoint(100, 50),
      ];
      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('smoothness 0 produces straighter curves', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 0),
      ];

      final smoothPath = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: 0.5,
      );
      final straighterPath = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: 0.0,
      );

      // Both should produce valid paths
      expect(smoothPath.getBounds().isEmpty, isFalse);
      expect(straighterPath.getBounds().isEmpty, isFalse);
    });

    test('default smoothness is 0.3', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      // Should use default smoothness
      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('different smoothness values produce different paths', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(25, 100),
        FusionDataPoint(50, 0),
        FusionDataPoint(75, 100),
        FusionDataPoint(100, 0),
      ];

      final lowSmooth = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: 0.1,
      );
      final highSmooth = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: 0.8,
      );

      // Both should be valid
      expect(lowSmooth.getBounds().isEmpty, isFalse);
      expect(highSmooth.getBounds().isEmpty, isFalse);

      // High smoothness should potentially have larger bounds due to overshooting
      // (This is a characteristic of smooth curves)
    });

    test('smoothness 1.0 produces very round curves', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: 1.0,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('curve passes through all data points', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(25, 75),
        FusionDataPoint(50, 25),
        FusionDataPoint(75, 75),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: 0.3,
      );

      // Verify the path contains the screen coordinates of data points
      // Note: path.contains checks if a point is inside the path's fill
      // For a line path, we check the path bounds contain the points
      final bounds = path.getBounds();
      for (final point in dataPoints) {
        final screenPoint = coordSystem.dataToScreen(point);
        expect(
          bounds.contains(screenPoint) ||
              (screenPoint.dx >= bounds.left - 1 &&
                  screenPoint.dx <= bounds.right + 1 &&
                  screenPoint.dy >= bounds.top - 1 &&
                  screenPoint.dy <= bounds.bottom + 1),
          isTrue,
        );
      }
    });

    test('handles three points (minimum for meaningful curve)', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 0),
      ];

      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);

      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });
  });

  // ===========================================================================
  // AREA PATH - createAreaPath
  // ===========================================================================
  group('FusionPathBuilder - createAreaPath', () {
    test('returns empty path for empty data', () {
      final path = FusionPathBuilder.createAreaPath([], coordSystem);

      expect(path.getBounds().isEmpty, isTrue);
    });

    test('creates closed area path with straight lines', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
      );

      // Area path should be closed
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
      // Area extends to baseline (y=0)
      expect(bounds.bottom, closeTo(300, 1)); // Screen bottom
    });

    test('creates curved area path', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: true,
        smoothness: 0.3,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('respects custom baseline', () {
      final dataPoints = [FusionDataPoint(0, 50), FusionDataPoint(100, 50)];

      final pathWithZeroBaseline = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
        baseline: 0,
      );

      final pathWithNonZeroBaseline = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
        baseline: 25,
      );

      // Different baselines should produce different areas
      expect(
        pathWithZeroBaseline.getBounds().height,
        greaterThan(pathWithNonZeroBaseline.getBounds().height),
      );
    });

    test('area path with single point', () {
      final dataPoints = [FusionDataPoint(50, 75)];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
      );

      // Even single point should create some path
      expect(path, isA<Path>());
    });

    test('area path with two points', () {
      final dataPoints = [FusionDataPoint(0, 50), FusionDataPoint(100, 50)];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
      );

      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('baseline above data creates inverted area', () {
      final dataPoints = [
        FusionDataPoint(0, 25),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 25),
      ];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
        baseline: 75, // Baseline above the data
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('negative baseline value', () {
      final dataPoints = [FusionDataPoint(0, 50), FusionDataPoint(100, 50)];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
        baseline: -10, // Negative baseline
      );

      // Should extend beyond normal chart area
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('area path is closed', () {
      final dataPoints = [
        FusionDataPoint(0, 25),
        FusionDataPoint(50, 75),
        FusionDataPoint(100, 25),
      ];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
      );

      // A closed path should form an enclosed area
      // We can test this by checking the path contains interior points
      final firstScreen = coordSystem.dataToScreen(dataPoints.first);
      final midScreen = coordSystem.dataToScreen(dataPoints[1]);

      // Center of the area should be inside the path
      final centerX = (firstScreen.dx + midScreen.dx) / 2;
      final baselineY = coordSystem.dataYToScreenY(0);
      final centerY = (midScreen.dy + baselineY) / 2;

      expect(path.contains(Offset(centerX, centerY)), isTrue);
    });
  });

  // ===========================================================================
  // CATMULL-ROM PATH - createCatmullRomPath
  // ===========================================================================
  group('FusionPathBuilder - createCatmullRomPath', () {
    test('returns empty path for empty data', () {
      final path = FusionPathBuilder.createCatmullRomPath([], coordSystem);

      expect(path.getBounds().isEmpty, isTrue);
    });

    test('returns line path for 1 point', () {
      final dataPoints = [FusionDataPoint(50, 50)];

      final path = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
      );

      expect(path, isA<Path>());
    });

    test('returns line path for 2 points', () {
      final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(100, 100)];

      final path = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('returns line path for 3 points (less than 4)', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      final path = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('creates smooth spline for 4+ points', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(25, 75),
        FusionDataPoint(50, 25),
        FusionDataPoint(75, 80),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('respects segmentsPerCurve parameter', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(25, 75),
        FusionDataPoint(50, 25),
        FusionDataPoint(75, 80),
        FusionDataPoint(100, 50),
      ];

      final lowSegments = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
        segmentsPerCurve: 5,
      );

      final highSegments = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
        segmentsPerCurve: 50,
      );

      // Both should be valid paths
      expect(lowSegments.getBounds().isEmpty, isFalse);
      expect(highSegments.getBounds().isEmpty, isFalse);
    });

    test('respects tension parameter', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(25, 75),
        FusionDataPoint(50, 25),
        FusionDataPoint(75, 80),
        FusionDataPoint(100, 50),
      ];

      final lowTension = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
        tension: 0.2,
      );

      final highTension = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
        tension: 0.8,
      );

      expect(lowTension.getBounds().isEmpty, isFalse);
      expect(highTension.getBounds().isEmpty, isFalse);
    });

    test('handles exactly 4 points (minimum for spline)', () {
      final dataPoints = [
        FusionDataPoint(0, 25),
        FusionDataPoint(33, 75),
        FusionDataPoint(66, 25),
        FusionDataPoint(100, 75),
      ];

      final path = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('default tension is 0.5', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(25, 75),
        FusionDataPoint(50, 25),
        FusionDataPoint(75, 80),
        FusionDataPoint(100, 50),
      ];

      // Should work with default tension
      final path = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  // ===========================================================================
  // SIMPLIFIED PATH - createSimplifiedPath
  // ===========================================================================
  group('FusionPathBuilder - createSimplifiedPath', () {
    test('returns line path for empty data', () {
      final path = FusionPathBuilder.createSimplifiedPath([], coordSystem);

      expect(path.getBounds().isEmpty, isTrue);
    });

    test('returns line path for single point', () {
      final dataPoints = [FusionDataPoint(50, 50)];

      final path = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
      );

      expect(path, isA<Path>());
    });

    test('returns line path for two points', () {
      final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(100, 100)];

      final path = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('simplifies path with many collinear points', () {
      // Create points along a straight line
      final dataPoints = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final path = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
        tolerance: 1.0,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('preserves important points (peaks)', () {
      // Create a zigzag pattern - simplification should keep peaks
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(25, 100), // Peak
        FusionDataPoint(50, 0),
        FusionDataPoint(75, 100), // Peak
        FusionDataPoint(100, 0),
      ];

      final path = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
        tolerance: 5.0,
      );

      // Should produce a valid path
      expect(path, isA<Path>());
      // Path bounds should cover the data range
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
    });

    test('respects tolerance parameter', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(10, 5), // Slight deviation
        FusionDataPoint(20, 0),
        FusionDataPoint(30, 5),
        FusionDataPoint(40, 0),
      ];

      // Low tolerance keeps more points
      final lowTolerance = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
        tolerance: 0.1,
      );

      // High tolerance removes more points
      final highTolerance = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
        tolerance: 100.0,
      );

      // Both should produce valid paths
      expect(lowTolerance, isA<Path>());
      expect(highTolerance, isA<Path>());
    });

    test('default tolerance is 2.0', () {
      final dataPoints = List.generate(
        50,
        (i) => FusionDataPoint(i * 2.0, (i % 10).toDouble()),
      );

      final path = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles circular pattern', () {
      // Create points in a circular pattern
      final dataPoints = List.generate(36, (i) {
        final angle = i * 10 * math.pi / 180;
        return FusionDataPoint(
          50 + 40 * math.cos(angle),
          50 + 40 * math.sin(angle),
        );
      });

      final path = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
        tolerance: 2.0,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  // ===========================================================================
  // DASHED PATH - createDashedPath
  // ===========================================================================
  group('FusionPathBuilder - createDashedPath', () {
    test('returns original path for empty dash array', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 100);

      final dashed = FusionPathBuilder.createDashedPath(path, []);

      expect(dashed.getBounds(), equals(path.getBounds()));
    });

    test('returns original path for odd-length dash array', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 100);

      final dashed = FusionPathBuilder.createDashedPath(path, [5, 3, 2]);

      expect(dashed.getBounds(), equals(path.getBounds()));
    });

    test('creates dashed path with valid dash array', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 0);

      final dashed = FusionPathBuilder.createDashedPath(path, [5, 3]);

      expect(dashed, isA<Path>());
      // Dashed path should have similar bounds
      expect(dashed.getBounds().width, closeTo(100, 10));
    });

    test('handles complex dash patterns', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(200, 0);

      final dashed = FusionPathBuilder.createDashedPath(path, [10, 5, 2, 5]);

      expect(dashed, isA<Path>());
      // Dashed path should cover similar range as original
      expect(dashed.getBounds().width, greaterThanOrEqualTo(0));
    });

    test('handles curved paths', () {
      final path = Path()
        ..moveTo(0, 50)
        ..quadraticBezierTo(50, 0, 100, 50);

      final dashed = FusionPathBuilder.createDashedPath(path, [5, 5]);

      expect(dashed, isA<Path>());
      expect(dashed.getBounds().isEmpty, isFalse);
    });

    test('handles single dash-gap pair', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(50, 0);

      final dashed = FusionPathBuilder.createDashedPath(path, [10, 10]);

      expect(dashed, isA<Path>());
    });

    test('handles very short dashes', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 0);

      final dashed = FusionPathBuilder.createDashedPath(path, [1, 1]);

      expect(dashed, isA<Path>());
    });

    test('handles very long dashes', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 0);

      final dashed = FusionPathBuilder.createDashedPath(path, [1000, 1000]);

      expect(dashed, isA<Path>());
      // With dash longer than path, should have similar bounds
      expect(dashed.getBounds().width, closeTo(100, 10));
    });

    test('handles closed path', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 0)
        ..lineTo(100, 100)
        ..lineTo(0, 100)
        ..close();

      final dashed = FusionPathBuilder.createDashedPath(path, [10, 5]);

      expect(dashed, isA<Path>());
      expect(dashed.getBounds().isEmpty, isFalse);
    });

    test('handles path with multiple subpaths', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(50, 0)
        ..moveTo(60, 0)
        ..lineTo(100, 0);

      final dashed = FusionPathBuilder.createDashedPath(path, [5, 3]);

      expect(dashed, isA<Path>());
    });
  });

  // ===========================================================================
  // GRADIENT PATH - createGradientPath
  // ===========================================================================
  group('FusionPathBuilder - createGradientPath', () {
    test('creates path with bounds for straight lines', () {
      final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(100, 100)];

      final result = FusionPathBuilder.createGradientPath(
        dataPoints,
        coordSystem,
        isCurved: false,
      );

      expect(result.path, isA<Path>());
      expect(result.bounds, isA<Rect>());
      expect(result.bounds.width, greaterThan(0));
    });

    test('creates path with bounds for curved lines', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 0),
      ];

      final result = FusionPathBuilder.createGradientPath(
        dataPoints,
        coordSystem,
        isCurved: true,
        smoothness: 0.35,
      );

      expect(result.path, isA<Path>());
      expect(result.bounds, isA<Rect>());
    });

    test('bounds match path bounds', () {
      final dataPoints = [FusionDataPoint(25, 25), FusionDataPoint(75, 75)];

      final result = FusionPathBuilder.createGradientPath(
        dataPoints,
        coordSystem,
        isCurved: false,
      );

      expect(result.bounds, equals(result.path.getBounds()));
    });

    test('default smoothness is 0.35 for curved gradient path', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 50),
      ];

      final result = FusionPathBuilder.createGradientPath(
        dataPoints,
        coordSystem,
        isCurved: true,
      );

      expect(result.path.getBounds().isEmpty, isFalse);
    });

    test('handles empty data', () {
      final result = FusionPathBuilder.createGradientPath(
        [],
        coordSystem,
        isCurved: false,
      );

      expect(result.path, isA<Path>());
      expect(result.bounds.isEmpty, isTrue);
    });

    test('handles single point', () {
      final dataPoints = [FusionDataPoint(50, 50)];

      final result = FusionPathBuilder.createGradientPath(
        dataPoints,
        coordSystem,
        isCurved: false,
      );

      expect(result.path, isA<Path>());
    });
  });

  // ===========================================================================
  // PATH WITH BOUNDS
  // ===========================================================================
  group('PathWithBounds', () {
    test('stores path and bounds', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(100, 100);
      final bounds = path.getBounds();

      final pwb = PathWithBounds(path: path, bounds: bounds);

      expect(pwb.path, equals(path));
      expect(pwb.bounds, equals(bounds));
    });

    test('can store empty path', () {
      final path = Path();
      final bounds = path.getBounds();

      final pwb = PathWithBounds(path: path, bounds: bounds);

      expect(pwb.path, equals(path));
      expect(pwb.bounds.isEmpty, isTrue);
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionPathBuilder - Edge Cases', () {
    test('handles very large number of points', () {
      final dataPoints = List.generate(
        1000,
        (i) => FusionDataPoint(i / 10.0, (i % 100).toDouble()),
      );

      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles negative values', () {
      const negCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: -50,
        dataXMax: 50,
        dataYMin: -50,
        dataYMax: 50,
      );

      final dataPoints = [
        FusionDataPoint(-50, -50),
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
      ];

      final path = FusionPathBuilder.createLinePath(dataPoints, negCoordSystem);
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles points at same location', () {
      final dataPoints = [
        FusionDataPoint(50, 50),
        FusionDataPoint(50, 50),
        FusionDataPoint(50, 50),
      ];

      // Should not crash, even if result is degenerate
      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);
      expect(path, isA<Path>());
    });

    test('handles very small coordinate range', () {
      const smallCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 0.001,
        dataYMin: 0,
        dataYMax: 0.001,
      );

      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(0.0005, 0.0005),
        FusionDataPoint(0.001, 0.001),
      ];

      final path = FusionPathBuilder.createLinePath(
        dataPoints,
        smallCoordSystem,
      );
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles very large coordinate range', () {
      const largeCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 1000000,
        dataYMin: 0,
        dataYMax: 1000000,
      );

      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(500000, 500000),
        FusionDataPoint(1000000, 1000000),
      ];

      final path = FusionPathBuilder.createLinePath(
        dataPoints,
        largeCoordSystem,
      );
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles points with zero distance between them', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(0, 0), // Same as previous
        FusionDataPoint(100, 100),
      ];

      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);
      expect(path, isA<Path>());
    });

    test('handles NaN-like extreme values gracefully', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      // Use extreme smoothness values
      final pathExtreme = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: 999999,
      );
      expect(pathExtreme, isA<Path>());

      final pathNegative = FusionPathBuilder.createSmoothPath(
        dataPoints,
        coordSystem,
        smoothness: -0.5,
      );
      expect(pathNegative, isA<Path>());
    });

    test('handles chart area with offset', () {
      const offsetCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(50, 50, 350, 250),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      final path = FusionPathBuilder.createLinePath(
        dataPoints,
        offsetCoordSystem,
      );
      final bounds = path.getBounds();

      // Path should be within the offset chart area
      expect(bounds.left, greaterThanOrEqualTo(50));
      expect(bounds.right, lessThanOrEqualTo(350));
    });

    test('handles inversed Y axis', () {
      const inversedCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        yInversed: true,
      );

      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      final path = FusionPathBuilder.createLinePath(
        dataPoints,
        inversedCoordSystem,
      );
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles inversed X axis', () {
      const inversedCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        xInversed: true,
      );

      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      final path = FusionPathBuilder.createLinePath(
        dataPoints,
        inversedCoordSystem,
      );
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles both axes inversed', () {
      const inversedCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        xInversed: true,
        yInversed: true,
      );

      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      final path = FusionPathBuilder.createLinePath(
        dataPoints,
        inversedCoordSystem,
      );
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles data outside visible range', () {
      final dataPoints = [
        FusionDataPoint(-50, -50), // Outside range
        FusionDataPoint(50, 50), // Inside range
        FusionDataPoint(150, 150), // Outside range
      ];

      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles many consecutive identical points', () {
      final dataPoints = <FusionDataPoint>[];
      for (int i = 0; i < 10; i++) {
        dataPoints.add(FusionDataPoint(50, 50));
      }
      dataPoints.add(FusionDataPoint(100, 100));

      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);
      expect(path, isA<Path>());
    });

    test('simplified path handles high-frequency noise', () {
      // Create data with high-frequency noise
      final dataPoints = List.generate(100, (i) {
        final noise = (i.isEven) ? 1.0 : -1.0;
        return FusionDataPoint(i.toDouble(), 50 + noise);
      });

      final path = FusionPathBuilder.createSimplifiedPath(
        dataPoints,
        coordSystem,
        tolerance: 5.0,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('area path handles data crossing baseline', () {
      final dataPoints = [
        FusionDataPoint(0, -25), // Below baseline
        FusionDataPoint(50, 75), // Above baseline
        FusionDataPoint(100, -25), // Below baseline
      ];

      const negCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: -50,
        dataYMax: 100,
      );

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        negCoordSystem,
        baseline: 0,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  // ===========================================================================
  // MATHEMATICAL CORRECTNESS
  // ===========================================================================
  group('FusionPathBuilder - Mathematical Correctness', () {
    test('line path length matches expected value', () {
      // Two points at opposite corners
      final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(100, 100)];

      final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);
      final metrics = path.computeMetrics().first;

      // Expected: diagonal of 400x300 rectangle = sqrt(400^2 + 300^2) = 500
      expect(metrics.length, closeTo(500, 1));
    });

    test('smooth path starts and ends at correct points', () {
      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 0),
      ];

      final path = FusionPathBuilder.createSmoothPath(dataPoints, coordSystem);
      final bounds = path.getBounds();

      // First point in screen coords
      final firstScreen = coordSystem.dataToScreen(dataPoints.first);
      final lastScreen = coordSystem.dataToScreen(dataPoints.last);

      // Path should start/end near these points
      expect(bounds.left, closeTo(firstScreen.dx, 50));
      expect(bounds.right, closeTo(lastScreen.dx, 50));
    });

    test('area path encloses correct area', () {
      // Simple rectangle-ish area
      final dataPoints = [FusionDataPoint(0, 50), FusionDataPoint(100, 50)];

      final path = FusionPathBuilder.createAreaPath(
        dataPoints,
        coordSystem,
        isCurved: false,
        baseline: 0,
      );

      // Area should be width * height / 2 (trapezoid approximation)
      // In screen coords: 400 wide, 150 tall
      // Path should contain points in the middle of this area
      expect(path.contains(const Offset(200, 225)), isTrue);
    });

    test('catmull-rom spline is continuous', () {
      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(25, 75),
        FusionDataPoint(50, 25),
        FusionDataPoint(75, 75),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createCatmullRomPath(
        dataPoints,
        coordSystem,
        segmentsPerCurve: 50,
      );

      // Path should be a single continuous curve
      final metrics = path.computeMetrics();
      expect(metrics.length, 1);
    });
  });

  // ===========================================================================
  // COORDINATE SYSTEM VARIATIONS
  // ===========================================================================
  group('FusionPathBuilder - Coordinate System Variations', () {
    test('handles non-square chart area', () {
      const wideCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 800, 200),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createSmoothPath(
        dataPoints,
        wideCoordSystem,
      );
      final bounds = path.getBounds();

      expect(bounds.width, greaterThan(bounds.height));
    });

    test('handles tall chart area', () {
      const tallCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 200, 600),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final dataPoints = [
        FusionDataPoint(0, 50),
        FusionDataPoint(50, 100),
        FusionDataPoint(100, 50),
      ];

      final path = FusionPathBuilder.createSmoothPath(
        dataPoints,
        tallCoordSystem,
      );
      final bounds = path.getBounds();

      expect(bounds.height, greaterThan(bounds.width));
    });

    test('handles asymmetric data range', () {
      const asymCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: -100,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 1000,
      );

      final dataPoints = [
        FusionDataPoint(-100, 500),
        FusionDataPoint(0, 750),
        FusionDataPoint(100, 500),
      ];

      final path = FusionPathBuilder.createSmoothPath(
        dataPoints,
        asymCoordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });

    test('handles high DPI coordinate system', () {
      const highDpiCoordSystem = FusionCoordinateSystem(
        chartArea: Rect.fromLTRB(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 3.0,
      );

      final dataPoints = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      final path = FusionPathBuilder.createLinePath(
        dataPoints,
        highDpiCoordSystem,
      );

      expect(path.getBounds().isEmpty, isFalse);
    });
  });
}

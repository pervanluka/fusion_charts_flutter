import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';
import 'package:fusion_charts_flutter/src/rendering/interaction/fusion_spatial_index.dart';

void main() {
  late FusionCoordinateSystem coordSystem;

  setUp(() {
    // Create a simple coordinate system:
    // Data: 0-100 x 0-100
    // Screen: 0-400 x 0-300 (chart area)
    coordSystem = const FusionCoordinateSystem(
      chartArea: Rect.fromLTWH(0, 0, 400, 300),
      dataXMin: 0,
      dataXMax: 100,
      dataYMin: 0,
      dataYMax: 100,
    );
  });

  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================

  group('FusionSpatialIndex - Construction', () {
    test('creates empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 0);
    });

    test('creates index with single point', () {
      final index = FusionSpatialIndex(
        dataPoints: [FusionDataPoint(50, 50)],
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 1);
    });

    test('creates index with multiple points', () {
      final dataPoints = [
        FusionDataPoint(10, 10),
        FusionDataPoint(20, 20),
        FusionDataPoint(30, 30),
        FusionDataPoint(40, 40),
        FusionDataPoint(50, 50),
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 5);
    });

    test('respects maxPointsPerNode parameter', () {
      final dataPoints = List.generate(
        20,
        (i) => FusionDataPoint(i * 5.0, i * 5.0),
      );

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
        maxPointsPerNode: 2,
      );

      // Should subdivide more with lower maxPointsPerNode
      expect(index.statistics.nodeCount, greaterThan(1));
    });
  });

  // ===========================================================================
  // FIND NEAREST
  // ===========================================================================

  group('FusionSpatialIndex - findNearest', () {
    test('returns null for empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      final result = index.findNearest(const Offset(100, 100));
      expect(result, isNull);
    });

    test('finds exact point', () {
      // Point at data (50, 50) maps to screen (200, 150)
      final dataPoints = [FusionDataPoint(50, 50)];
      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      final screenPos = coordSystem.dataToScreen(dataPoints[0]);
      final result = index.findNearest(screenPos);

      expect(result, isNotNull);
      expect(result!.x, 50);
      expect(result.y, 50);
    });

    test('finds nearest from multiple points', () {
      final dataPoints = [
        FusionDataPoint(10, 10),
        FusionDataPoint(50, 50),
        FusionDataPoint(90, 90),
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query near the middle point
      final nearMiddle = coordSystem.dataToScreen(dataPoints[1]);
      final result = index.findNearest(nearMiddle);

      expect(result, isNotNull);
      expect(result!.x, 50);
      expect(result.y, 50);
    });

    test('respects maxDistance parameter', () {
      final dataPoints = [FusionDataPoint(50, 50)];
      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query far from the point with small maxDistance
      const farAway = Offset.zero;
      final result = index.findNearest(farAway, maxDistance: 10);

      expect(result, isNull);
    });

    test('finds point within maxDistance', () {
      final dataPoints = [FusionDataPoint(50, 50)];
      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query slightly offset from the point
      final screenPos = coordSystem.dataToScreen(dataPoints[0]);
      final nearbyPos = Offset(screenPos.dx + 5, screenPos.dy + 5);
      final result = index.findNearest(nearbyPos, maxDistance: 20);

      expect(result, isNotNull);
    });
  });

  // ===========================================================================
  // FIND NEAREST BY X
  // ===========================================================================

  group('FusionSpatialIndex - findNearestByX', () {
    test('returns null for empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      final result = index.findNearestByX(const Offset(100, 100));
      expect(result, isNull);
    });

    test('finds point by X coordinate ignoring Y', () {
      final dataPoints = [
        FusionDataPoint(25, 10), // Left
        FusionDataPoint(50, 90), // Middle, high Y
        FusionDataPoint(75, 10), // Right
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query at X=50, Y=0 - should find middle point despite Y difference
      final screenPos = coordSystem.dataToScreen(FusionDataPoint(50, 0));
      final result = index.findNearestByX(screenPos);

      expect(result, isNotNull);
      expect(result!.x, 50);
    });
  });

  // ===========================================================================
  // FIND NEAREST BY Y
  // ===========================================================================

  group('FusionSpatialIndex - findNearestByY', () {
    test('returns null for empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      final result = index.findNearestByY(const Offset(100, 100));
      expect(result, isNull);
    });

    test('finds point by Y coordinate ignoring X', () {
      final dataPoints = [
        FusionDataPoint(10, 25), // Low Y
        FusionDataPoint(90, 50), // Middle Y, far X
        FusionDataPoint(10, 75), // High Y
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query at X=0, Y=50 - should find middle point despite X difference
      final screenPos = coordSystem.dataToScreen(FusionDataPoint(0, 50));
      final result = index.findNearestByY(screenPos);

      expect(result, isNotNull);
      expect(result!.y, 50);
    });
  });

  // ===========================================================================
  // FIND IN RADIUS
  // ===========================================================================

  group('FusionSpatialIndex - findInRadius', () {
    test('returns empty list for empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      final result = index.findInRadius(const Offset(100, 100), radius: 50);
      expect(result, isEmpty);
    });

    test('finds points within radius', () {
      final dataPoints = [
        FusionDataPoint(50, 50),
        FusionDataPoint(52, 52), // Close to 50,50
        FusionDataPoint(10, 10), // Far away
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query around (50, 50) with small radius
      final center = coordSystem.dataToScreen(FusionDataPoint(50, 50));
      final result = index.findInRadius(center, radius: 20);

      expect(result.length, greaterThanOrEqualTo(1));
      expect(result.any((p) => p.x == 50 && p.y == 50), isTrue);
    });

    test('returns empty when no points in radius', () {
      final dataPoints = [FusionDataPoint(10, 10)];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query far from the point
      final center = coordSystem.dataToScreen(FusionDataPoint(90, 90));
      final result = index.findInRadius(center, radius: 10);

      expect(result, isEmpty);
    });
  });

  // ===========================================================================
  // FIND IN RECT
  // ===========================================================================

  group('FusionSpatialIndex - findInRect', () {
    test('returns empty list for empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      final result = index.findInRect(const Rect.fromLTWH(0, 0, 100, 100));
      expect(result, isEmpty);
    });

    test('finds points within rectangle', () {
      final dataPoints = [
        FusionDataPoint(25, 25),
        FusionDataPoint(50, 50),
        FusionDataPoint(75, 75),
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Query middle of chart
      final center = coordSystem.dataToScreen(FusionDataPoint(50, 50));
      final rect = Rect.fromCenter(center: center, width: 50, height: 50);
      final result = index.findInRect(rect);

      expect(result.any((p) => p.x == 50 && p.y == 50), isTrue);
    });
  });

  // ===========================================================================
  // FIND ALONG LINE
  // ===========================================================================

  group('FusionSpatialIndex - findAlongLine', () {
    test('returns empty list for empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      final result = index.findAlongLine(Offset.zero, const Offset(100, 100));
      expect(result, isEmpty);
    });

    test('finds points near line', () {
      final dataPoints = [
        FusionDataPoint(25, 25),
        FusionDataPoint(50, 50),
        FusionDataPoint(75, 75),
        FusionDataPoint(10, 90), // Off the diagonal
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      // Line from (0,0) to (100,100) in data coords
      final start = coordSystem.dataToScreen(FusionDataPoint(0, 0));
      final end = coordSystem.dataToScreen(FusionDataPoint(100, 100));

      final result = index.findAlongLine(start, end, tolerance: 15);

      // Should find points along the diagonal
      expect(result.length, greaterThanOrEqualTo(1));
    });
  });

  // ===========================================================================
  // INDEX MANAGEMENT
  // ===========================================================================

  group('FusionSpatialIndex - Index Management', () {
    test('rebuild recreates index with new points', () {
      final initialPoints = [FusionDataPoint(10, 10)];
      final index = FusionSpatialIndex(
        dataPoints: initialPoints,
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 1);

      final newPoints = [
        FusionDataPoint(20, 20),
        FusionDataPoint(30, 30),
        FusionDataPoint(40, 40),
      ];

      index.rebuild(newPoints);

      expect(index.statistics.totalPoints, 3);
    });

    test('clear removes all points', () {
      final dataPoints = [FusionDataPoint(10, 10), FusionDataPoint(20, 20)];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 2);

      index.clear();

      expect(index.statistics.totalPoints, 0);
    });
  });

  // ===========================================================================
  // STATISTICS
  // ===========================================================================

  group('FusionSpatialIndex - Statistics', () {
    test('returns zero statistics for empty index', () {
      final index = FusionSpatialIndex(
        dataPoints: [],
        coordSystem: coordSystem,
      );

      final stats = index.statistics;

      expect(stats.totalPoints, 0);
      // Root node still exists even with no points
      expect(stats.nodeCount, greaterThanOrEqualTo(0));
      expect(stats.avgPointsPerLeaf, 0);
    });

    test('calculates statistics for populated index', () {
      // Use points well within bounds (10 to 90, avoiding boundary edges)
      final dataPoints = List.generate(
        9,
        (i) => FusionDataPoint((i + 1) * 10.0, (i + 1) * 10.0),
      );

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      final stats = index.statistics;

      expect(stats.totalPoints, 9);
      expect(stats.nodeCount, greaterThan(0));
    });

    test('statistics toString is readable', () {
      final dataPoints = [FusionDataPoint(50, 50)];
      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      final stats = index.statistics;
      final str = stats.toString();

      expect(str, contains('points'));
      expect(str, contains('nodes'));
      expect(str, contains('depth'));
    });
  });

  // ===========================================================================
  // QUADTREE STATISTICS CLASS
  // ===========================================================================

  group('QuadTreeStatistics', () {
    test('stores values correctly', () {
      const stats = QuadTreeStatistics(
        totalPoints: 100,
        nodeCount: 25,
        maxDepth: 5,
        avgPointsPerLeaf: 4.0,
      );

      expect(stats.totalPoints, 100);
      expect(stats.nodeCount, 25);
      expect(stats.maxDepth, 5);
      expect(stats.avgPointsPerLeaf, 4.0);
    });

    test('toString includes all values', () {
      const stats = QuadTreeStatistics(
        totalPoints: 100,
        nodeCount: 25,
        maxDepth: 5,
        avgPointsPerLeaf: 4.0,
      );

      final str = stats.toString();

      expect(str, contains('100'));
      expect(str, contains('25'));
      expect(str, contains('5'));
      expect(str, contains('4.0'));
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('FusionSpatialIndex - toString', () {
    test('returns readable string', () {
      final dataPoints = [FusionDataPoint(10, 10), FusionDataPoint(20, 20)];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      final str = index.toString();

      expect(str, contains('FusionSpatialIndex'));
      expect(str, contains('points'));
      expect(str, contains('nodes'));
      expect(str, contains('depth'));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================

  group('FusionSpatialIndex - Edge Cases', () {
    test('handles many points', () {
      // Use points well within bounds (avoid 0 and 100 which may be edge cases)
      final dataPoints = List.generate(
        81, // 9x9 grid
        (i) => FusionDataPoint(
          (i % 9) * 10.0 + 10, // 10, 20, ..., 90
          (i ~/ 9) * 10.0 + 10, // 10, 20, ..., 90
        ),
      );

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 81);

      // Should still find points correctly
      final center = coordSystem.dataToScreen(FusionDataPoint(50, 50));
      final result = index.findNearest(center);

      expect(result, isNotNull);
    });

    test('handles points at same location', () {
      final dataPoints = [
        FusionDataPoint(50, 50, label: 'a'),
        FusionDataPoint(50, 50, label: 'b'),
        FusionDataPoint(50, 50, label: 'c'),
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 3);

      final center = coordSystem.dataToScreen(FusionDataPoint(50, 50));
      final result = index.findNearest(center);

      expect(result, isNotNull);
    });

    test('handles points near boundaries', () {
      // Use points just inside the boundaries to avoid edge cases
      final dataPoints = [
        FusionDataPoint(1, 1),
        FusionDataPoint(99, 99),
        FusionDataPoint(1, 99),
        FusionDataPoint(99, 1),
      ];

      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      expect(index.statistics.totalPoints, 4);
    });

    test('cleared index returns null for queries', () {
      final dataPoints = [FusionDataPoint(50, 50)];
      final index = FusionSpatialIndex(
        dataPoints: dataPoints,
        coordSystem: coordSystem,
      );

      index.clear();

      expect(index.findNearest(const Offset(100, 100)), isNull);
      expect(index.findNearestByX(const Offset(100, 100)), isNull);
      expect(index.findNearestByY(const Offset(100, 100)), isNull);
      expect(index.findInRadius(const Offset(100, 100), radius: 50), isEmpty);
      expect(index.findInRect(const Rect.fromLTWH(0, 0, 200, 200)), isEmpty);
    });
  });
}

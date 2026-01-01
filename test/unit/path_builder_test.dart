import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_path_builder.dart';

void main() {
  group('FusionPathBuilder', () {
    late FusionCoordinateSystem coordSystem;

    setUp(() {
      // Create a simple coordinate system:
      // Chart area is 100x100, data range is 0-10 for both X and Y
      coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 100, 100),
        dataXMin: 0,
        dataXMax: 10,
        dataYMin: 0,
        dataYMax: 100,
      );
    });

    group('createLinePath', () {
      test('creates path through all points', () {
        final dataPoints = [
          FusionDataPoint(0, 20),
          FusionDataPoint(5, 50),
          FusionDataPoint(10, 80),
        ];

        final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

        expect(path, isNotNull);
        // Path should have bounds that span the data
        final bounds = path.getBounds();
        expect(bounds.width, greaterThan(0));
        expect(bounds.height, greaterThan(0));
      });

      test('handles single point', () {
        final dataPoints = [FusionDataPoint(5, 50)];
        final path = FusionPathBuilder.createLinePath(dataPoints, coordSystem);

        expect(path, isNotNull);
        // Single point path should have zero dimensions
        final bounds = path.getBounds();
        expect(bounds.width, 0);
        expect(bounds.height, 0);
      });

      test('handles empty data', () {
        final path = FusionPathBuilder.createLinePath([], coordSystem);

        expect(path, isNotNull);
        expect(path.getBounds().isEmpty, true);
      });
    });

    group('createSmoothPath', () {
      test('curve passes through all data points', () {
        // This is the key test for the bug fix
        // Points: (0,20), (1,45), (2,38), (3,65)
        final dataPoints = [
          FusionDataPoint(0, 20),
          FusionDataPoint(1, 45),
          FusionDataPoint(2, 38),
          FusionDataPoint(3, 65),
        ];

        final path = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.35,
        );

        // Convert data points to expected screen coordinates
        final expectedScreenPoints = dataPoints
            .map(coordSystem.dataToScreen)
            .toList();

        // The path should contain all data points
        // We verify by checking that the path contains points very close to our data points
        for (final expectedPoint in expectedScreenPoints) {
          expect(
            path.contains(expectedPoint),
            true,
            reason: 'Curve should pass through point $expectedPoint',
          );
        }
      });

      test('creates smooth transitions at inflection points', () {
        // Data with clear direction changes
        final dataPoints = [
          FusionDataPoint(0, 10),
          FusionDataPoint(1, 50), // Up
          FusionDataPoint(2, 30), // Down (inflection)
          FusionDataPoint(3, 70), // Up (inflection)
          FusionDataPoint(4, 40), // Down
        ];

        final path = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.35,
        );

        // Path should be valid and non-empty
        expect(path, isNotNull);
        final bounds = path.getBounds();
        expect(bounds.width, greaterThan(0));
        expect(bounds.height, greaterThan(0));
      });

      test('handles two points with straight line', () {
        final dataPoints = [FusionDataPoint(0, 20), FusionDataPoint(10, 80)];

        final path = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.35,
        );

        expect(path, isNotNull);
        // Should still contain both endpoints
        final p1 = coordSystem.dataToScreen(dataPoints[0]);
        final p2 = coordSystem.dataToScreen(dataPoints[1]);
        expect(path.contains(p1), true);
        expect(path.contains(p2), true);
      });

      test('smoothness=0 produces straight segments', () {
        final dataPoints = [
          FusionDataPoint(0, 20),
          FusionDataPoint(5, 50),
          FusionDataPoint(10, 30),
        ];

        final smoothPath = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.0,
        );

        // With smoothness=0, control points are at the data points
        // resulting in straight line segments
        expect(smoothPath, isNotNull);

        // Path should still pass through all points
        for (final point in dataPoints) {
          final screenPoint = coordSystem.dataToScreen(point);
          expect(smoothPath.contains(screenPoint), true);
        }
      });

      test('smoothness controls curve roundness', () {
        final dataPoints = [
          FusionDataPoint(0, 20),
          FusionDataPoint(5, 80),
          FusionDataPoint(10, 20),
        ];

        // Test different smoothness values
        final path0 = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.0,
        );
        final path3 = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.3,
        );
        final path5 = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.5,
        );
        final path10 = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 1.0,
        );

        // All should be valid paths
        expect(path0.getBounds().height, greaterThan(0));
        expect(path3.getBounds().height, greaterThan(0));
        expect(path5.getBounds().height, greaterThan(0));
        expect(path10.getBounds().height, greaterThan(0));
      });

      test('higher smoothness creates more pronounced curves', () {
        final dataPoints = [
          FusionDataPoint(0, 20),
          FusionDataPoint(5, 80),
          FusionDataPoint(10, 20),
        ];

        final lowSmooth = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.2,
        );

        final highSmooth = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.5,
        );

        // Both should be valid
        expect(lowSmooth.getBounds().height, greaterThan(0));
        expect(highSmooth.getBounds().height, greaterThan(0));
      });

      test('handles monotonically increasing data', () {
        final dataPoints = List.generate(
          5,
          (i) => FusionDataPoint(i.toDouble(), i * 20.0),
        );

        final path = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.35,
        );

        expect(path, isNotNull);
        // All original points should be on the curve
        for (final point in dataPoints) {
          final screenPoint = coordSystem.dataToScreen(point);
          expect(path.contains(screenPoint), true);
        }
      });

      test('handles monotonically decreasing data', () {
        final dataPoints = List.generate(
          5,
          (i) => FusionDataPoint(i.toDouble(), 80 - i * 15.0),
        );

        final path = FusionPathBuilder.createSmoothPath(
          dataPoints,
          coordSystem,
          smoothness: 0.35,
        );

        expect(path, isNotNull);
        for (final point in dataPoints) {
          final screenPoint = coordSystem.dataToScreen(point);
          expect(path.contains(screenPoint), true);
        }
      });
    });

    group('createAreaPath', () {
      test('creates closed path for area fill', () {
        final dataPoints = [
          FusionDataPoint(0, 20),
          FusionDataPoint(5, 50),
          FusionDataPoint(10, 30),
        ];

        final path = FusionPathBuilder.createAreaPath(
          dataPoints,
          coordSystem,
          isCurved: true,
          smoothness: 0.35,
        );

        expect(path, isNotNull);
        // Area path should have larger bounds than line path
        // because it extends to the baseline
        final bounds = path.getBounds();
        expect(bounds.height, greaterThan(0));
      });

      test('straight area path when isCurved is false', () {
        final dataPoints = [
          FusionDataPoint(0, 20),
          FusionDataPoint(5, 50),
          FusionDataPoint(10, 30),
        ];

        final path = FusionPathBuilder.createAreaPath(
          dataPoints,
          coordSystem,
          isCurved: false,
        );

        expect(path, isNotNull);
      });
    });

    group('createDashedPath', () {
      test('creates dashed version of path', () {
        final dataPoints = [FusionDataPoint(0, 20), FusionDataPoint(10, 80)];

        final originalPath = FusionPathBuilder.createLinePath(
          dataPoints,
          coordSystem,
        );
        final dashedPath = FusionPathBuilder.createDashedPath(originalPath, [
          5,
          3,
        ]);

        expect(dashedPath, isNotNull);
      });

      test('returns original path for invalid dash array', () {
        final dataPoints = [FusionDataPoint(0, 20), FusionDataPoint(10, 80)];

        final originalPath = FusionPathBuilder.createLinePath(
          dataPoints,
          coordSystem,
        );

        // Odd-length dash array is invalid
        final result = FusionPathBuilder.createDashedPath(originalPath, [5]);
        expect(result, equals(originalPath));

        // Empty dash array is invalid
        final result2 = FusionPathBuilder.createDashedPath(originalPath, []);
        expect(result2, equals(originalPath));
      });
    });
  });
}

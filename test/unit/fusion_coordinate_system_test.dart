import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================

  group('FusionCoordinateSystem - Construction', () {
    test('creates coordinate system with required parameters', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.chartArea.width, 400);
      expect(coordSystem.chartArea.height, 300);
      expect(coordSystem.dataXMin, 0);
      expect(coordSystem.dataXMax, 100);
    });

    test('creates coordinate system with default values', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.xInversed, isFalse);
      expect(coordSystem.yInversed, isFalse);
      expect(coordSystem.devicePixelRatio, 1.0);
    });

    test('creates coordinate system with inversed axes', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        xInversed: true,
        yInversed: true,
      );

      expect(coordSystem.xInversed, isTrue);
      expect(coordSystem.yInversed, isTrue);
    });

    test('creates coordinate system with custom DPI', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 2.0,
      );

      expect(coordSystem.devicePixelRatio, 2.0);
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  group('FusionCoordinateSystem - Computed Properties', () {
    test('calculates correct scaleX', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.scaleX, 4.0); // 400 / 100 = 4
    });

    test('calculates correct scaleY', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.scaleY, 3.0); // 300 / 100 = 3
    });

    test('returns 1.0 for zero X range', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 50,
        dataXMax: 50,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.scaleX, 1.0);
    });

    test('returns 1.0 for zero Y range', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 50,
        dataYMax: 50,
      );

      expect(coordSystem.scaleY, 1.0);
    });

    test('calculates data ranges', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 10,
        dataXMax: 50,
        dataYMin: 20,
        dataYMax: 80,
      );

      expect(coordSystem.dataXRange, 40);
      expect(coordSystem.dataYRange, 60);
    });

    test('returns chart dimensions', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 20, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.chartWidth, 400);
      expect(coordSystem.chartHeight, 300);
    });

    test('returns data bounds', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 10,
        dataXMax: 90,
        dataYMin: 20,
        dataYMax: 80,
      );

      final bounds = coordSystem.dataBounds;
      expect(bounds.left, 10);
      expect(bounds.top, 20);
      expect(bounds.right, 90);
      expect(bounds.bottom, 80);
    });
  });

  // ===========================================================================
  // FORWARD TRANSFORMS
  // ===========================================================================

  group('FusionCoordinateSystem - Forward Transforms', () {
    test('transforms data X to screen X', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.dataXToScreenX(0), closeTo(0, 0.5));
      expect(coordSystem.dataXToScreenX(50), closeTo(200, 0.5));
      expect(coordSystem.dataXToScreenX(100), closeTo(400, 0.5));
    });

    test('transforms data Y to screen Y (inverted)', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      // Y is inverted by default (0 at bottom)
      expect(coordSystem.dataYToScreenY(0), closeTo(300, 0.5)); // Bottom
      expect(coordSystem.dataYToScreenY(100), closeTo(0, 0.5)); // Top
      expect(coordSystem.dataYToScreenY(50), closeTo(150, 0.5)); // Middle
    });

    test('transforms data point to screen', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final screenPoint = coordSystem.dataToScreen(FusionDataPoint(50, 50));

      expect(screenPoint.dx, closeTo(200, 0.5));
      expect(screenPoint.dy, closeTo(150, 0.5));
    });

    test('handles inversed X axis', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        xInversed: true,
      );

      expect(coordSystem.dataXToScreenX(0), closeTo(400, 0.5)); // Right
      expect(coordSystem.dataXToScreenX(100), closeTo(0, 0.5)); // Left
    });

    test('handles inversed Y axis', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        yInversed: true,
      );

      expect(coordSystem.dataYToScreenY(0), closeTo(0, 0.5)); // Top
      expect(coordSystem.dataYToScreenY(100), closeTo(300, 0.5)); // Bottom
    });

    test('batch transforms data points', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final points = [
        FusionDataPoint(0, 0),
        FusionDataPoint(50, 50),
        FusionDataPoint(100, 100),
      ];

      final screenPoints = coordSystem.dataPointsToScreen(points);

      expect(screenPoints.length, 3);
      expect(screenPoints[0].dx, closeTo(0, 0.5));
      expect(screenPoints[1].dx, closeTo(200, 0.5));
      expect(screenPoints[2].dx, closeTo(400, 0.5));
    });

    test('handles zero X range', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 20, 400, 300),
        dataXMin: 50,
        dataXMax: 50,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.dataXToScreenX(50), closeTo(10, 0.5)); // Returns left
    });

    test('handles zero Y range', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 20, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 50,
        dataYMax: 50,
      );

      expect(
        coordSystem.dataYToScreenY(50),
        closeTo(320, 0.5),
      ); // Returns bottom
    });
  });

  // ===========================================================================
  // INVERSE TRANSFORMS
  // ===========================================================================

  group('FusionCoordinateSystem - Inverse Transforms', () {
    test('transforms screen X to data X', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.screenXToDataX(0), closeTo(0, 0.1));
      expect(coordSystem.screenXToDataX(200), closeTo(50, 0.1));
      expect(coordSystem.screenXToDataX(400), closeTo(100, 0.1));
    });

    test('transforms screen Y to data Y', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.screenYToDataY(300), closeTo(0, 0.1)); // Bottom
      expect(coordSystem.screenYToDataY(0), closeTo(100, 0.1)); // Top
      expect(coordSystem.screenYToDataY(150), closeTo(50, 0.1)); // Middle
    });

    test('transforms screen to data point', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final dataPoint = coordSystem.screenToData(const Offset(200, 150));

      expect(dataPoint.x, closeTo(50, 0.1));
      expect(dataPoint.y, closeTo(50, 0.1));
    });

    test('round-trip transform is accurate', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 20, 400, 300),
        dataXMin: -50,
        dataXMax: 150,
        dataYMin: -100,
        dataYMax: 200,
      );

      final originalPoint = FusionDataPoint(25, 75);
      final screenPoint = coordSystem.dataToScreen(originalPoint);
      final roundTrip = coordSystem.screenToData(screenPoint);

      expect(roundTrip.x, closeTo(originalPoint.x, 0.5));
      expect(roundTrip.y, closeTo(originalPoint.y, 0.5));
    });
  });

  // ===========================================================================
  // UTILITY TRANSFORMS
  // ===========================================================================

  group('FusionCoordinateSystem - Utility Transforms', () {
    test('converts data width to screen width', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.dataWidthToScreenWidth(10), 40); // 10 * 4 = 40
      expect(coordSystem.dataWidthToScreenWidth(25), 100); // 25 * 4 = 100
    });

    test('converts data height to screen height', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.dataHeightToScreenHeight(10), 30); // 10 * 3 = 30
      expect(coordSystem.dataHeightToScreenHeight(50), 150); // 50 * 3 = 150
    });

    test('converts screen width to data width', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.screenWidthToDataWidth(40), 10); // 40 / 4 = 10
      expect(coordSystem.screenWidthToDataWidth(100), 25); // 100 / 4 = 25
    });

    test('converts screen height to data height', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.screenHeightToDataHeight(30), 10); // 30 / 3 = 10
      expect(coordSystem.screenHeightToDataHeight(150), 50); // 150 / 3 = 50
    });
  });

  // ===========================================================================
  // HIT TESTING
  // ===========================================================================

  group('FusionCoordinateSystem - Hit Testing', () {
    test('containsScreen returns true for point inside chart', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 20, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.containsScreen(const Offset(100, 100)), isTrue);
      expect(coordSystem.containsScreen(const Offset(10, 20)), isTrue);
    });

    test('containsScreen returns false for point outside chart', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 20, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.containsScreen(Offset.zero), isFalse);
      expect(coordSystem.containsScreen(const Offset(500, 400)), isFalse);
    });

    test('containsData returns true for point inside data bounds', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.containsData(FusionDataPoint(50, 50)), isTrue);
      expect(coordSystem.containsData(FusionDataPoint(0, 0)), isTrue);
      expect(coordSystem.containsData(FusionDataPoint(100, 100)), isTrue);
    });

    test('containsData returns false for point outside data bounds', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(coordSystem.containsData(FusionDataPoint(-10, 50)), isFalse);
      expect(coordSystem.containsData(FusionDataPoint(110, 50)), isFalse);
      expect(coordSystem.containsData(FusionDataPoint(50, -10)), isFalse);
      expect(coordSystem.containsData(FusionDataPoint(50, 110)), isFalse);
    });

    test('findNearestPoint returns nearest point', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final points = [
        FusionDataPoint(25, 50),
        FusionDataPoint(50, 50),
        FusionDataPoint(75, 50),
      ];

      // Query near the middle point
      final screenPos = coordSystem.dataToScreen(FusionDataPoint(50, 50));
      final nearest = coordSystem.findNearestPoint(screenPos, points);

      expect(nearest, isNotNull);
      expect(nearest!.x, 50);
    });

    test('findNearestPoint returns null for empty list', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final nearest = coordSystem.findNearestPoint(const Offset(100, 100), []);

      expect(nearest, isNull);
    });

    test('findNearestPoint returns null when no point within maxDistance', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final points = [FusionDataPoint(0, 0)];
      const farAway = Offset(400, 300);

      final nearest = coordSystem.findNearestPoint(
        farAway,
        points,
        maxDistance: 10,
      );

      expect(nearest, isNull);
    });
  });

  // ===========================================================================
  // VIEWPORT & CLIPPING
  // ===========================================================================

  group('FusionCoordinateSystem - Viewport', () {
    test('getVisiblePoints filters points within bounds', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 20,
        dataXMax: 80,
        dataYMin: 20,
        dataYMax: 80,
      );

      final points = [
        FusionDataPoint(10, 50), // Outside (x too low)
        FusionDataPoint(50, 50), // Inside
        FusionDataPoint(90, 50), // Outside (x too high)
        FusionDataPoint(50, 10), // Outside (y too low)
        FusionDataPoint(50, 90), // Outside (y too high)
      ];

      final visible = coordSystem.getVisiblePoints(points);

      expect(visible.length, 1);
      expect(visible[0].x, 50);
    });

    test('zoom creates new coordinate system with zoomed range', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final zoomed = coordSystem.zoom(
        dataXMin: 25,
        dataXMax: 75,
        dataYMin: 25,
        dataYMax: 75,
      );

      expect(zoomed.dataXMin, 25);
      expect(zoomed.dataXMax, 75);
      expect(zoomed.dataYMin, 25);
      expect(zoomed.dataYMax, 75);
      expect(zoomed.chartArea, coordSystem.chartArea);
    });
  });

  // ===========================================================================
  // PIXEL SNAPPING
  // ===========================================================================

  group('FusionCoordinateSystem - Pixel Snapping', () {
    test('snapOffsetToPixel snaps to whole pixels at 1x DPI', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 1.0,
      );

      final snapped = coordSystem.snapOffsetToPixel(const Offset(10.3, 20.7));

      expect(snapped.dx, 10.0);
      expect(snapped.dy, 21.0);
    });

    test('snapOffsetToPixel snaps to half pixels at 2x DPI', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 2.0,
      );

      final snapped = coordSystem.snapOffsetToPixel(const Offset(10.3, 20.7));

      expect(snapped.dx, 10.5);
      expect(snapped.dy, 20.5);
    });

    test('snapRectToPixel snaps all corners', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 1.0,
      );

      final snapped = coordSystem.snapRectToPixel(
        const Rect.fromLTRB(10.3, 20.7, 30.4, 40.6),
      );

      expect(snapped.left, 10.0);
      expect(snapped.top, 21.0);
      expect(snapped.right, 30.0);
      expect(snapped.bottom, 41.0);
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================

  group('FusionCoordinateSystem - Equality', () {
    test('equal coordinate systems are equal', () {
      final cs1 = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final cs2 = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(cs1, equals(cs2));
    });

    test('different chart areas are not equal', () {
      final cs1 = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final cs2 = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 10, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(cs1, isNot(equals(cs2)));
    });
  });

  // ===========================================================================
  // HASH CODE & TO STRING
  // ===========================================================================

  group('FusionCoordinateSystem - hashCode & toString', () {
    test('equal coordinate systems have equal hash codes', () {
      final cs1 = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final cs2 = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      expect(cs1.hashCode, equals(cs2.hashCode));
    });

    test('toString contains key information', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
      );

      final str = coordSystem.toString();

      expect(str, contains('FusionCoordinateSystem'));
      expect(str, contains('chartArea'));
      expect(str, contains('dataX'));
      expect(str, contains('dataY'));
      expect(str, contains('scale'));
    });
  });
}

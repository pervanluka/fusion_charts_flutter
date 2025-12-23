import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('FusionCoordinateSystem', () {
    late FusionCoordinateSystem coordSystem;

    setUp(() {
      coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(50, 10, 300, 200),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 50,
      );
    });

    group('Forward Transformations', () {
      test('dataToScreen transforms origin correctly', () {
        final origin = coordSystem.dataToScreen(FusionDataPoint(0, 0));
        expect(origin.dx, closeTo(50, 1)); // chartArea.left
        expect(origin.dy, closeTo(210, 1)); // chartArea.bottom (Y inverted)
      });

      test('dataToScreen transforms max point correctly', () {
        final max = coordSystem.dataToScreen(FusionDataPoint(100, 50));
        expect(max.dx, closeTo(350, 1)); // chartArea.right
        expect(max.dy, closeTo(10, 1)); // chartArea.top
      });

      test('dataToScreen transforms center correctly', () {
        final center = coordSystem.dataToScreen(FusionDataPoint(50, 25));
        expect(center.dx, closeTo(200, 1)); // middle of chart
        expect(center.dy, closeTo(110, 1)); // middle of chart
      });

      test('dataXToScreenX handles boundary values', () {
        expect(coordSystem.dataXToScreenX(0), closeTo(50, 1));
        expect(coordSystem.dataXToScreenX(100), closeTo(350, 1));
        expect(coordSystem.dataXToScreenX(50), closeTo(200, 1));
      });

      test('dataYToScreenY handles boundary values', () {
        expect(coordSystem.dataYToScreenY(0), closeTo(210, 1));
        expect(coordSystem.dataYToScreenY(50), closeTo(10, 1));
        expect(coordSystem.dataYToScreenY(25), closeTo(110, 1));
      });
    });

    group('Inverse Transformations', () {
      test('screenToData is inverse of dataToScreen', () {
        final testPoints = [
          FusionDataPoint(0, 0),
          FusionDataPoint(50, 25),
          FusionDataPoint(100, 50),
        ];

        for (final original in testPoints) {
          final screen = coordSystem.dataToScreen(original);
          final roundTrip = coordSystem.screenToData(screen);

          // Tolerance of 1.0 accounts for pixel snapping
          expect(roundTrip.x, closeTo(original.x, 1.0),
              reason: 'X round-trip failed for $original');
          expect(roundTrip.y, closeTo(original.y, 1.0),
              reason: 'Y round-trip failed for $original');
        }
      });

      test('screenXToDataX handles screen coordinates', () {
        expect(coordSystem.screenXToDataX(50), closeTo(0, 0.1));
        expect(coordSystem.screenXToDataX(350), closeTo(100, 0.1));
        expect(coordSystem.screenXToDataX(200), closeTo(50, 0.1));
      });

      test('screenYToDataY handles screen coordinates', () {
        expect(coordSystem.screenYToDataY(210), closeTo(0, 0.1));
        expect(coordSystem.screenYToDataY(10), closeTo(50, 0.1));
        expect(coordSystem.screenYToDataY(110), closeTo(25, 0.1));
      });
    });

    group('Edge Cases', () {
      test('handles zero X range gracefully', () {
        final zeroXRange = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: 50,
          dataXMax: 50, // Zero range
          dataYMin: 0,
          dataYMax: 100,
        );

        final screen = zeroXRange.dataToScreen(FusionDataPoint(50, 50));
        expect(screen.dx.isFinite, true);
        expect(screen.dx.isNaN, false);
      });

      test('handles zero Y range gracefully', () {
        final zeroYRange = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: 0,
          dataXMax: 100,
          dataYMin: 25,
          dataYMax: 25, // Zero range
        );

        final screen = zeroYRange.dataToScreen(FusionDataPoint(50, 25));
        expect(screen.dy.isFinite, true);
        expect(screen.dy.isNaN, false);
      });

      test('handles negative data ranges', () {
        final negativeRange = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: -50,
          dataXMax: 50,
          dataYMin: -100,
          dataYMax: 100,
        );

        // Zero should be at center
        final zero = negativeRange.dataToScreen(FusionDataPoint(0, 0));
        expect(zero.dx, closeTo(50, 1));
        expect(zero.dy, closeTo(50, 1));
      });

      test('handles very large values', () {
        final largeValues = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: 0,
          dataXMax: 1e12,
          dataYMin: 0,
          dataYMax: 1e12,
        );

        final screen = largeValues.dataToScreen(FusionDataPoint(5e11, 5e11));
        expect(screen.dx.isFinite, true);
        expect(screen.dy.isFinite, true);
        expect(screen.dx, closeTo(50, 1));
        expect(screen.dy, closeTo(50, 1));
      });

      test('handles very small values', () {
        final smallValues = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: 0,
          dataXMax: 1e-9,
          dataYMin: 0,
          dataYMax: 1e-9,
        );

        final screen = smallValues.dataToScreen(FusionDataPoint(5e-10, 5e-10));
        expect(screen.dx.isFinite, true);
        expect(screen.dy.isFinite, true);
      });
    });

    group('Pixel Snapping', () {
      test('snaps to pixel boundaries on 1x displays', () {
        final coord = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: 0,
          dataXMax: 100,
          dataYMin: 0,
          dataYMax: 100,
          devicePixelRatio: 1.0,
        );

        // 33.333... should snap to nearest pixel
        final screen = coord.dataToScreen(FusionDataPoint(33.333, 50));
        expect(screen.dx % 1.0, closeTo(0.0, 0.01));
      });

      test('snaps to half-pixel boundaries on 2x displays', () {
        final coord = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: 0,
          dataXMax: 100,
          dataYMin: 0,
          dataYMax: 100,
          devicePixelRatio: 2.0,
        );

        final screen = coord.dataToScreen(FusionDataPoint(33.333, 50));
        // Should be snapped to 0.5 boundary
        expect((screen.dx * 2).round() / 2, closeTo(screen.dx, 0.01));
      });
    });

    group('Computed Properties', () {
      test('dataXRange is correct', () {
        expect(coordSystem.dataXRange, 100);
      });

      test('dataYRange is correct', () {
        expect(coordSystem.dataYRange, 50);
      });

      test('chartWidth is correct', () {
        expect(coordSystem.chartWidth, 300);
      });

      test('chartHeight is correct', () {
        expect(coordSystem.chartHeight, 200);
      });
    });

    group('Scale Factors', () {
      test('scaleX is calculated correctly', () {
        // chartWidth / dataRange = 300 / 100 = 3.0
        expect(coordSystem.scaleX, closeTo(3.0, 0.01));
      });

      test('scaleY is calculated correctly', () {
        // chartHeight / dataRange = 200 / 50 = 4.0
        expect(coordSystem.scaleY, closeTo(4.0, 0.01));
      });
    });

    group('Equality', () {
      test('equal coordinate systems are equal', () {
        final other = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(50, 10, 300, 200),
          dataXMin: 0,
          dataXMax: 100,
          dataYMin: 0,
          dataYMax: 50,
        );

        expect(coordSystem, equals(other));
        expect(coordSystem.hashCode, equals(other.hashCode));
      });

      test('different coordinate systems are not equal', () {
        final differentMax = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(50, 10, 300, 200),
          dataXMin: 0,
          dataXMax: 200, // Different!
          dataYMin: 0,
          dataYMax: 50,
        );

        expect(coordSystem, isNot(equals(differentMax)));
      });

      test('different chart areas are not equal', () {
        final differentArea = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(100, 20, 300, 200), // Different!
          dataXMin: 0,
          dataXMax: 100,
          dataYMin: 0,
          dataYMax: 50,
        );

        expect(coordSystem, isNot(equals(differentArea)));
      });
    });

    group('toString', () {
      test('returns readable string', () {
        final str = coordSystem.toString();

        expect(str, contains('FusionCoordinateSystem'));
      });
    });
  });
}

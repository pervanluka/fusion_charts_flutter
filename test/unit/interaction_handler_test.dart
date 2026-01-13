import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_interaction_handler.dart';

void main() {
  group('FusionInteractionHandler', () {
    late FusionCoordinateSystem coordSystem;
    late FusionInteractionHandler handler;

    setUp(() {
      coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(50, 10, 300, 200),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 50,
      );

      handler = FusionInteractionHandler(
        coordSystem: coordSystem,
        zoomConfig: const FusionZoomConfiguration(
          minZoomLevel: 0.5, // Can zoom out to see 2x range
          maxZoomLevel: 5.0, // Can zoom in to see 0.2x range
          zoomSpeed: 1.0,
        ),
        panConfig: const FusionPanConfiguration(
          panMode: FusionPanMode.both,
        ),
      );
    });

    group('applyZoomSpeed', () {
      test('returns 1.0 for no zoom', () {
        expect(handler.applyZoomSpeed(1.0), 1.0);
      });

      test('applies zoom speed to zoom in', () {
        // zoomSpeed = 1.0, so 1.5 should stay 1.5
        expect(handler.applyZoomSpeed(1.5), 1.5);
      });

      test('applies zoom speed to zoom out', () {
        // zoomSpeed = 1.0, so 0.8 should stay 0.8
        expect(handler.applyZoomSpeed(0.8), 0.8);
      });

      test('applies custom zoom speed', () {
        final fastHandler = FusionInteractionHandler(
          coordSystem: coordSystem,
          zoomConfig: const FusionZoomConfiguration(
            zoomSpeed: 2.0, // 2x speed
          ),
        );

        // Delta is 0.5 (1.5 - 1.0), with 2x speed it becomes 1.0
        // Result: 1.0 + 1.0 = 2.0
        expect(fastHandler.applyZoomSpeed(1.5), 2.0);
      });
    });

    group('calculatePannedBounds', () {
      test('pans in X direction correctly', () {
        // Pan 30 pixels right (which is 10% of 300px chart width)
        // This should shift X by 10% of data range (10 units)
        final result = handler.calculatePannedBounds(
          const Offset(-30, 0), // Negative = pan right (content moves left)
          0,
          100,
          0,
          50,
        );

        expect(result.xMin, closeTo(10, 0.1));
        expect(result.xMax, closeTo(110, 0.1));
        expect(result.yMin, closeTo(0, 0.1));
        expect(result.yMax, closeTo(50, 0.1));
      });

      test('pans in Y direction correctly', () {
        // Pan 40 pixels down (which is 20% of 200px chart height)
        // This should shift Y by 20% of data range (10 units)
        final result = handler.calculatePannedBounds(
          const Offset(0, 40), // Positive Y = pan down
          0,
          100,
          0,
          50,
        );

        expect(result.xMin, closeTo(0, 0.1));
        expect(result.xMax, closeTo(100, 0.1));
        expect(result.yMin, closeTo(10, 0.1));
        expect(result.yMax, closeTo(60, 0.1));
      });

      test('pans in both directions simultaneously', () {
        final result = handler.calculatePannedBounds(
          const Offset(-30, 40),
          0,
          100,
          0,
          50,
        );

        expect(result.xMin, closeTo(10, 0.1));
        expect(result.xMax, closeTo(110, 0.1));
        expect(result.yMin, closeTo(10, 0.1));
        expect(result.yMax, closeTo(60, 0.1));
      });

      test('respects X-only pan mode', () {
        final xOnlyHandler = FusionInteractionHandler(
          coordSystem: coordSystem,
          panConfig: const FusionPanConfiguration(
            panMode: FusionPanMode.x,
          ),
        );

        final result = xOnlyHandler.calculatePannedBounds(
          const Offset(-30, 40),
          0,
          100,
          0,
          50,
        );

        expect(result.xMin, closeTo(10, 0.1)); // X should change
        expect(result.xMax, closeTo(110, 0.1));
        expect(result.yMin, closeTo(0, 0.1)); // Y should NOT change
        expect(result.yMax, closeTo(50, 0.1));
      });

      test('respects Y-only pan mode', () {
        final yOnlyHandler = FusionInteractionHandler(
          coordSystem: coordSystem,
          panConfig: const FusionPanConfiguration(
            panMode: FusionPanMode.y,
          ),
        );

        final result = yOnlyHandler.calculatePannedBounds(
          const Offset(-30, 40),
          0,
          100,
          0,
          50,
        );

        expect(result.xMin, closeTo(0, 0.1)); // X should NOT change
        expect(result.xMax, closeTo(100, 0.1));
        expect(result.yMin, closeTo(10, 0.1)); // Y should change
        expect(result.yMax, closeTo(60, 0.1));
      });
    });

    group('calculateZoomedBounds', () {
      test('zooms in at center', () {
        // Zoom 2x at chart center
        final result = handler.calculateZoomedBounds(
          2.0, // 2x zoom
          const Offset(200, 110), // Center of chart area
          0,
          100,
          0,
          50,
        );

        // Range should be halved, centered at data center (50, 25)
        expect(result.xMax - result.xMin, closeTo(50, 1));
        expect(result.yMax - result.yMin, closeTo(25, 1));
        expect((result.xMin + result.xMax) / 2, closeTo(50, 1));
        expect((result.yMin + result.yMax) / 2, closeTo(25, 1));
      });

      test('zooms out at center', () {
        // Start with zoomed in bounds, then zoom out
        final result = handler.calculateZoomedBounds(
          0.5, // 0.5x zoom (zoom out)
          const Offset(200, 110), // Center
          25,
          75, // Zoomed in X range
          12.5,
          37.5, // Zoomed in Y range
        );

        // Range should double
        expect(result.xMax - result.xMin, closeTo(100, 1));
        expect(result.yMax - result.yMin, closeTo(50, 1));
      });

      test('zooms at focal point (preserves point under cursor)', () {
        // Zoom at left edge of chart
        final result = handler.calculateZoomedBounds(
          2.0,
          const Offset(50, 110), // Left edge of chart (x=0 in data)
          0,
          100,
          0,
          50,
        );

        // X=0 should remain at x=0 after zoom
        expect(result.xMin, closeTo(0, 1));
        // Range should be halved
        expect(result.xMax - result.xMin, closeTo(50, 1));
      });

      test('respects X-only zoom mode', () {
        final xOnlyHandler = FusionInteractionHandler(
          coordSystem: coordSystem,
          zoomConfig: const FusionZoomConfiguration(
            zoomMode: FusionZoomMode.x,
          ),
        );

        final result = xOnlyHandler.calculateZoomedBounds(
          2.0,
          const Offset(200, 110),
          0,
          100,
          0,
          50,
        );

        // X range should be halved
        expect(result.xMax - result.xMin, closeTo(50, 1));
        // Y range should remain unchanged
        expect(result.yMax - result.yMin, closeTo(50, 1));
      });

      test('respects Y-only zoom mode', () {
        final yOnlyHandler = FusionInteractionHandler(
          coordSystem: coordSystem,
          zoomConfig: const FusionZoomConfiguration(
            zoomMode: FusionZoomMode.y,
          ),
        );

        final result = yOnlyHandler.calculateZoomedBounds(
          2.0,
          const Offset(200, 110),
          0,
          100,
          0,
          50,
        );

        // X range should remain unchanged
        expect(result.xMax - result.xMin, closeTo(100, 1));
        // Y range should be halved
        expect(result.yMax - result.yMin, closeTo(25, 1));
      });
    });

    group('constrainBounds - Zoom Limits', () {
      test('prevents zooming out beyond minZoomLevel', () {
        // Try to zoom out to 3x range (max allowed is 2x with minZoomLevel=0.5)
        final result = handler.constrainBounds(
          -100, // Would be 3x range
          200,
          -25,
          75,
          0, // Original bounds
          100,
          0,
          50,
        );

        // Range should be clamped to max 2x (200 units X, 100 units Y)
        expect(result.xMax - result.xMin, closeTo(200, 1));
        expect(result.yMax - result.yMin, closeTo(100, 1));
      });

      test('prevents zooming in beyond maxZoomLevel', () {
        // Try to zoom in to 0.1x range (min allowed is 0.2x with maxZoomLevel=5.0)
        final result = handler.constrainBounds(
          45, // Would be 0.1x range (10 units)
          55,
          22,
          27,
          0, // Original bounds
          100,
          0,
          50,
        );

        // Range should be clamped to min 0.2x (20 units X, 10 units Y)
        expect(result.xMax - result.xMin, closeTo(20, 1));
        expect(result.yMax - result.yMin, closeTo(10, 1));
      });

      test('allows zoom within limits', () {
        // Normal zoom that's within limits
        final result = handler.constrainBounds(
          25,
          75, // 50 units = 0.5x range (allowed)
          12.5,
          37.5, // 25 units = 0.5x range (allowed)
          0,
          100,
          0,
          50,
        );

        expect(result.xMin, closeTo(25, 0.1));
        expect(result.xMax, closeTo(75, 0.1));
        expect(result.yMin, closeTo(12.5, 0.1));
        expect(result.yMax, closeTo(37.5, 0.1));
      });
    });

    group('constrainBounds - Pan Limits', () {
      test('prevents panning too far left', () {
        // Try to pan so center is beyond left boundary
        final result = handler.constrainBounds(
          -30, // Center at -5, range is 50
          20,
          0,
          50,
          0, // Original bounds
          100,
          0,
          50,
        );

        // Should be shifted right so left edge is at 0
        expect(result.xMin, greaterThanOrEqualTo(0));
      });

      test('prevents panning too far right', () {
        // Try to pan beyond right boundary when zoomed at 1x
        final result = handler.constrainBounds(
          50, // Try to start at 50 with 100 range
          150,
          0,
          50,
          0, // Original bounds
          100,
          0,
          50,
        );

        // With maxZoomOut=2, max visible range is 200
        // Center can go from 50 (left edge at 0) to 150 (right edge at 200)
        expect(result.xMax - result.xMin, 100); // Range preserved
      });

      test('allows panning within bounds when zoomed in', () {
        // Zoomed to 50% (range = 50), should be able to pan
        final result = handler.constrainBounds(
          10,
          60, // Range of 50, centered at 35
          0,
          25,
          0,
          100,
          0,
          50,
        );

        // Should be allowed as-is since it's within pan bounds
        expect(result.xMin, closeTo(10, 0.1));
        expect(result.xMax, closeTo(60, 0.1));
      });
    });

    group('calculateMouseWheelZoom', () {
      test('scroll up zooms in', () {
        // Negative scroll delta = scroll up = zoom in
        final zoom = handler.calculateMouseWheelZoom(-100);
        expect(zoom, greaterThan(1.0));
      });

      test('scroll down zooms out', () {
        // Positive scroll delta = scroll down = zoom out
        final zoom = handler.calculateMouseWheelZoom(100);
        expect(zoom, lessThan(1.0));
      });

      test('larger scroll produces larger zoom', () {
        final smallScroll = handler.calculateMouseWheelZoom(-50);
        final largeScroll = handler.calculateMouseWheelZoom(-200);

        expect(largeScroll, greaterThan(smallScroll));
      });

      test('zoom is clamped to prevent extreme values', () {
        // Very large scroll should be clamped
        final extremeZoom = handler.calculateMouseWheelZoom(-10000);
        expect(extremeZoom, lessThanOrEqualTo(1.3)); // Max is 1.0 + 0.3
        expect(extremeZoom, greaterThanOrEqualTo(0.7)); // Min is 1.0 - 0.3
      });

      test('respects zoom speed configuration', () {
        final fastHandler = FusionInteractionHandler(
          coordSystem: coordSystem,
          zoomConfig: const FusionZoomConfiguration(
            zoomSpeed: 2.0,
          ),
        );

        final normalZoom = handler.calculateMouseWheelZoom(-100);
        final fastZoom = fastHandler.calculateMouseWheelZoom(-100);

        // Fast zoom should have larger delta from 1.0
        expect((fastZoom - 1.0).abs(), greaterThan((normalZoom - 1.0).abs()));
      });
    });

    group('Edge Cases', () {
      test('handles zero data range gracefully', () {
        final zeroRangeCoord = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: 50,
          dataXMax: 50, // Zero range
          dataYMin: 25,
          dataYMax: 25,
        );

        final zeroHandler = FusionInteractionHandler(
          coordSystem: zeroRangeCoord,
        );

        // Should not crash
        final pannedBounds = zeroHandler.calculatePannedBounds(
          const Offset(10, 10),
          50,
          50,
          25,
          25,
        );

        expect(pannedBounds.xMin.isFinite, true);
        expect(pannedBounds.yMin.isFinite, true);
      });

      test('handles negative data ranges', () {
        final negativeCoord = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 100, 100),
          dataXMin: -100,
          dataXMax: 100,
          dataYMin: -50,
          dataYMax: 50,
        );

        final negativeHandler = FusionInteractionHandler(
          coordSystem: negativeCoord,
        );

        final zoomedBounds = negativeHandler.calculateZoomedBounds(
          2.0,
          const Offset(50, 50), // Center
          -100,
          100,
          -50,
          50,
        );

        // Should zoom around center (0, 0)
        expect((zoomedBounds.xMin + zoomedBounds.xMax) / 2, closeTo(0, 1));
        expect((zoomedBounds.yMin + zoomedBounds.yMax) / 2, closeTo(0, 1));
      });

      test('handles very small zoom factors', () {
        final result = handler.calculateZoomedBounds(
          1.001, // Very small zoom
          const Offset(200, 110),
          0,
          100,
          0,
          50,
        );

        // Should still produce valid, slightly different bounds
        expect(result.xMax - result.xMin, lessThan(100));
        expect(result.xMax - result.xMin, greaterThan(99));
      });

      test('handles zoom factor of exactly 1.0', () {
        final result = handler.calculateZoomedBounds(
          1.0, // No zoom
          const Offset(200, 110),
          0,
          100,
          0,
          50,
        );

        // Bounds should be unchanged
        expect(result.xMin, closeTo(0, 0.01));
        expect(result.xMax, closeTo(100, 0.01));
        expect(result.yMin, closeTo(0, 0.01));
        expect(result.yMax, closeTo(50, 0.01));
      });
    });

    group('Integration - Zoom then Pan', () {
      test('can pan after zooming in', () {
        // First zoom in 2x
        var bounds = handler.calculateZoomedBounds(
          2.0,
          const Offset(200, 110), // Center
          0,
          100,
          0,
          50,
        );

        bounds = handler.constrainBounds(
          bounds.xMin,
          bounds.xMax,
          bounds.yMin,
          bounds.yMax,
          0,
          100,
          0,
          50,
        );

        // Now pan right
        final pannedBounds = handler.calculatePannedBounds(
          const Offset(-30, 0),
          bounds.xMin,
          bounds.xMax,
          bounds.yMin,
          bounds.yMax,
        );

        final finalBounds = handler.constrainBounds(
          pannedBounds.xMin,
          pannedBounds.xMax,
          pannedBounds.yMin,
          pannedBounds.yMax,
          0,
          100,
          0,
          50,
        );

        // Range should still be 50 (2x zoom)
        expect(finalBounds.xMax - finalBounds.xMin, closeTo(50, 1));
        // But position should have shifted
        expect(finalBounds.xMin, greaterThan(bounds.xMin));
      });

      test('zoom preserves center when zoomed out then back', () {
        // Zoom out
        var bounds = handler.calculateZoomedBounds(
          0.5,
          const Offset(200, 110),
          0,
          100,
          0,
          50,
        );

        // Zoom back in
        bounds = handler.calculateZoomedBounds(
          2.0,
          const Offset(200, 110),
          bounds.xMin,
          bounds.xMax,
          bounds.yMin,
          bounds.yMax,
        );

        // Should be approximately back to original
        expect(bounds.xMin, closeTo(0, 1));
        expect(bounds.xMax, closeTo(100, 1));
      });
    });
  });
}

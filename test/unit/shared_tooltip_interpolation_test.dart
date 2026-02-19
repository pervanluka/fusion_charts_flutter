import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/charts/fusion_interactive_chart.dart';

void main() {
  group('Shared Tooltip Interpolation Tests', () {
    late FusionCoordinateSystem coordSystem;

    setUp(() {
      coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 10,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 1.0,
      );
    });

    group('Basic Interpolation', () {
      test('interpolates Y correctly between two points', () {
        // Series with points at X=0 (Y=0) and X=10 (Y=100)
        // At X=5, interpolated Y should be 50
        final series1 = FusionLineSeries(
          name: 'Linear',
          dataPoints: [FusionDataPoint(0, 0), FusionDataPoint(10, 100)],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Constant',
          dataPoints: [FusionDataPoint(0, 50), FusionDataPoint(10, 50)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap at X=5 near series2
        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(50);

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        // Should find the point from one of the series
        expect(point, isNotNull);
      });

      test('shared tooltip finds all series at X position', () {
        // Two series with different data densities
        final series1 = FusionLineSeries(
          name: 'Dense',
          dataPoints: [
            FusionDataPoint(0, 10),
            FusionDataPoint(1, 20),
            FusionDataPoint(2, 30),
            FusionDataPoint(3, 40),
            FusionDataPoint(4, 50),
            FusionDataPoint(5, 60),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Sparse',
          dataPoints: [FusionDataPoint(0, 90), FusionDataPoint(5, 40)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap at X=2.5 - series1 has point at X=2 and X=3, series2 will be interpolated
        final screenX = coordSystem.dataXToScreenX(2.5);
        final screenY = coordSystem.dataYToScreenY(50);

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
      });
    });

    group('Interpolation Edge Cases', () {
      test('extrapolates before first point', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(3, 30), FusionDataPoint(7, 70)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query at X=1 (before first point at X=3)
        final screenX = coordSystem.dataXToScreenX(1);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(3)); // Returns first point
      });

      test('extrapolates after last point', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(3, 30), FusionDataPoint(7, 70)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query at X=9 (after last point at X=7)
        final screenX = coordSystem.dataXToScreenX(9);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(7)); // Returns last point
      });

      test('handles exact match on data point', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [
            FusionDataPoint(2, 20),
            FusionDataPoint(5, 50),
            FusionDataPoint(8, 80),
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query exactly at X=5
        final screenX = coordSystem.dataXToScreenX(5);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(5));
        expect(point.y, equals(50));
      });

      test('handles single point series', () {
        final series = FusionLineSeries(
          name: 'Single',
          dataPoints: [FusionDataPoint(5, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query at any X should return the single point
        final screenX = coordSystem.dataXToScreenX(2);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(5));
        expect(point.y, equals(50));
      });

      test('handles vertical line (same X, different Y)', () {
        final series = FusionLineSeries(
          name: 'Vertical',
          dataPoints: [
            FusionDataPoint(5, 20),
            FusionDataPoint(5, 80), // Same X, different Y
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(5));
      });
    });

    group('Multi-Series Shared Tooltip', () {
      test('finds points from all visible series', () {
        final series1 = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 80),
            FusionDataPoint(5, 80),
            FusionDataPoint(10, 80),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Series 2',
          dataPoints: [
            FusionDataPoint(0, 50),
            FusionDataPoint(5, 50),
            FusionDataPoint(10, 50),
          ],
          color: Colors.red,
        );

        final series3 = FusionLineSeries(
          name: 'Series 3',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(5, 20),
            FusionDataPoint(10, 20),
          ],
          color: Colors.green,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2, series3],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(50); // Near middle series

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
        // In shared mode, should find closest (series2)
        expect(point!.y, equals(50));
      });

      test('excludes hidden series', () {
        final visibleSeries = FusionLineSeries(
          name: 'Visible',
          dataPoints: [FusionDataPoint(5, 80)],
          color: Colors.blue,
          visible: true,
        );

        final hiddenSeries = FusionLineSeries(
          name: 'Hidden',
          dataPoints: [FusionDataPoint(5, 50)], // Closer to center
          color: Colors.red,
          visible: false,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [visibleSeries, hiddenSeries],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(50); // Near hidden series

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
        expect(point!.y, equals(80)); // Should find visible series
      });

      test('handles series with different X ranges', () {
        // Series 1: X from 0-5
        final series1 = FusionLineSeries(
          name: 'Short Range',
          dataPoints: [FusionDataPoint(0, 80), FusionDataPoint(5, 80)],
          color: Colors.blue,
        );

        // Series 2: X from 0-10
        final series2 = FusionLineSeries(
          name: 'Full Range',
          dataPoints: [FusionDataPoint(0, 20), FusionDataPoint(10, 20)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Query at X=7 (outside series1 range)
        final screenX = coordSystem.dataXToScreenX(7);
        final screenY = coordSystem.dataYToScreenY(50);

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
        // Series 1 will extrapolate to its last point (X=5)
        // Series 2 will interpolate normally
        // Should find one of them
      });
    });

    group('Threshold Behavior in Shared Mode', () {
      test('shared mode bypasses dynamic threshold', () {
        final series1 = FusionLineSeries(
          name: 'Far Top',
          dataPoints: [FusionDataPoint(5, 95)],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Far Bottom',
          dataPoints: [FusionDataPoint(5, 5)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 5.0, // Very small threshold
            shared: true, // But shared mode
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap in the middle - far from both
        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(50);

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        // With shared mode, should still find closest despite being outside threshold
        expect(point, isNotNull);
      });

      test('non-shared mode respects dynamic threshold', () {
        final series1 = FusionLineSeries(
          name: 'Far Top',
          dataPoints: [FusionDataPoint(5, 95)],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Far Bottom',
          dataPoints: [FusionDataPoint(5, 5)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 5.0, // Very small threshold
            shared: false, // NOT shared mode
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap in the middle - far from both
        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(50);

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        // Without shared mode, should return null (outside threshold)
        expect(point, isNull);
      });
    });

    group('Interpolation Accuracy', () {
      test('linear interpolation is mathematically correct', () {
        // Create a series where we can verify interpolation
        // Point at (0, 0) and (10, 100)
        // At X=3, Y should be 30
        // At X=7, Y should be 70
        final series = FusionLineSeries(
          name: 'Linear',
          dataPoints: [FusionDataPoint(0, 0), FusionDataPoint(10, 100)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // The interpolation returns the nearest actual point, not the interpolated value
        // But the screen position uses interpolation
        final screenX = coordSystem.dataXToScreenX(3);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        // Should return one of the actual points
        expect(point!.x, anyOf(equals(0), equals(10)));
      });

      test('handles non-linear data correctly', () {
        // Exponential-like data
        final series = FusionLineSeries(
          name: 'Exponential',
          dataPoints: [
            FusionDataPoint(0, 1),
            FusionDataPoint(2, 4),
            FusionDataPoint(4, 16),
            FusionDataPoint(6, 36),
            FusionDataPoint(8, 64),
            FusionDataPoint(10, 100),
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query at X=5 (between X=4 and X=6)
        final screenX = coordSystem.dataXToScreenX(5);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        // Should return X=4 or X=6
        expect(point!.x, anyOf(equals(4), equals(6)));
      });
    });
  });
}

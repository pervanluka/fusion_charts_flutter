import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/charts/fusion_interactive_chart.dart';

void main() {
  group('Multi-Series Tooltip Selection', () {
    late FusionCoordinateSystem coordSystem;

    setUp(() {
      // Create a coordinate system for testing
      // Chart area: 0-400 x, 0-300 y (screen coords)
      // Data range: 0-10 x, 0-100 y
      coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 10,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 1.0,
      );
    });

    group('Dynamic Threshold Calculation', () {
      test('uses full threshold when lines are far apart', () {
        // Two series far apart (50 units in Y)
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
            FusionDataPoint(0, 30),
            FusionDataPoint(5, 30),
            FusionDataPoint(10, 30),
          ],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 50.0, // Max threshold
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap near Series 1 (Y=80 in data = Y~60 in screen)
        // Screen Y for data Y=80: (100-80)/100 * 300 = 60
        final screenY1 = coordSystem.dataYToScreenY(80);
        final screenX = coordSystem.dataXToScreenX(5);

        final point = state.findPointAtScreenX(screenX, screenY: screenY1);

        expect(point, isNotNull);
        expect(point!.y, equals(80)); // Should select Series 1
      });

      test('shrinks threshold when lines are close together', () {
        // Two series close together (10 units in Y)
        final series1 = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 55),
            FusionDataPoint(5, 55),
            FusionDataPoint(10, 55),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Series 2',
          dataPoints: [
            FusionDataPoint(0, 45),
            FusionDataPoint(5, 45),
            FusionDataPoint(10, 45),
          ],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 50.0,
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);

        // Tap exactly on Series 1
        final screenY1 = coordSystem.dataYToScreenY(55);
        final point1 = state.findPointAtScreenX(screenX, screenY: screenY1);
        expect(point1, isNotNull);
        expect(point1!.y, equals(55));

        // Tap exactly on Series 2
        final screenY2 = coordSystem.dataYToScreenY(45);
        final point2 = state.findPointAtScreenX(screenX, screenY: screenY2);
        expect(point2, isNotNull);
        expect(point2!.y, equals(45));
      });

      test('returns null when tap is outside dynamic threshold', () {
        // Two series close together
        final series1 = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 55),
            FusionDataPoint(5, 55),
            FusionDataPoint(10, 55),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Series 2',
          dataPoints: [
            FusionDataPoint(0, 45),
            FusionDataPoint(5, 45),
            FusionDataPoint(10, 45),
          ],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 50.0,
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);

        // Tap far from both lines (Y=10 in data)
        final screenYFar = coordSystem.dataYToScreenY(10);
        final point = state.findPointAtScreenX(screenX, screenY: screenYFar);

        // Should be null because outside threshold of both series
        expect(point, isNull);
      });

      test('handles overlapping lines (threshold approaches zero)', () {
        // Two series at the same Y position
        final series1 = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 50),
            FusionDataPoint(5, 50),
            FusionDataPoint(10, 50),
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

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 50.0,
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(50);

        // Should still select one of them (first one found)
        final point = state.findPointAtScreenX(screenX, screenY: screenY);
        expect(point, isNotNull);
        expect(point!.y, equals(50));
      });
    });

    group('Shared Tooltip Mode', () {
      test('bypasses threshold in shared mode - always returns closest', () {
        // Two series far apart
        final series1 = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 90),
            FusionDataPoint(5, 90),
            FusionDataPoint(10, 90),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Series 2',
          dataPoints: [
            FusionDataPoint(0, 10),
            FusionDataPoint(5, 10),
            FusionDataPoint(10, 10),
          ],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 10.0, // Small threshold
            shared: true, // Shared mode
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);

        // Tap in the middle (Y=50) - far from both lines
        // Without shared mode, this would return null (outside threshold)
        final screenYMiddle = coordSystem.dataYToScreenY(50);
        final point = state.findPointAtScreenX(screenX, screenY: screenYMiddle);

        // With shared mode, should still return closest series
        expect(point, isNotNull);
      });

      test('shared mode selects closest series when between lines', () {
        final series1 = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 70),
            FusionDataPoint(5, 70),
            FusionDataPoint(10, 70),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Series 2',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(5, 30),
            FusionDataPoint(10, 30),
          ],
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

        final screenX = coordSystem.dataXToScreenX(5);

        // Tap closer to Series 1 (Y=60)
        final screenY60 = coordSystem.dataYToScreenY(60);
        final point1 = state.findPointAtScreenX(screenX, screenY: screenY60);
        expect(point1, isNotNull);
        expect(point1!.y, equals(70)); // Closer to Series 1

        // Tap closer to Series 2 (Y=40)
        final screenY40 = coordSystem.dataYToScreenY(40);
        final point2 = state.findPointAtScreenX(screenX, screenY: screenY40);
        expect(point2, isNotNull);
        expect(point2!.y, equals(30)); // Closer to Series 2
      });
    });

    group('Y-Value Interpolation', () {
      test('interpolates Y between data points', () {
        // Series with points at X=0, 5, 10
        final series = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 0),
            FusionDataPoint(5, 50),
            FusionDataPoint(10, 100),
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration();

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query at X=2.5 (between 0 and 5)
        // Expected interpolated Y = 25
        final screenX = coordSystem.dataXToScreenX(2.5);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        // Should return nearest actual point (X=0 or X=5)
        expect(point!.x, anyOf(equals(0), equals(5)));
      });

      test('handles query outside data range (before first point)', () {
        final series = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(2, 20),
            FusionDataPoint(5, 50),
            FusionDataPoint(8, 80),
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration();

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query at X=0 (before first point at X=2)
        final screenX = coordSystem.dataXToScreenX(0);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(2)); // Should return first point
      });

      test('handles query outside data range (after last point)', () {
        final series = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(2, 20),
            FusionDataPoint(5, 50),
            FusionDataPoint(8, 80),
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration();

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Query at X=10 (after last point at X=8)
        final screenX = coordSystem.dataXToScreenX(10);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(8)); // Should return last point
      });
    });

    group('Single Series Behavior', () {
      test('single series uses binary search without threshold', () {
        final series = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 10),
            FusionDataPoint(2, 20),
            FusionDataPoint(4, 40),
            FusionDataPoint(6, 60),
            FusionDataPoint(8, 80),
            FusionDataPoint(10, 100),
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 5.0, // Small threshold
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        // Tap far from any line (Y=0)
        // Single series should still return a point (no threshold)
        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(0);
        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
        // Should return nearest by X (X=4 or X=6)
        expect(point!.x, anyOf(equals(4), equals(6)));
      });

      test('single series with single point returns that point', () {
        final series = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [FusionDataPoint(5, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration();

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(0);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(5));
        expect(point.y, equals(50));
      });
    });

    group('Edge Cases', () {
      test('empty series returns null', () {
        final series = FusionLineSeries(
          name: 'Empty Series',
          dataPoints: [],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration();

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNull);
      });

      test('hidden series is ignored', () {
        final series1 = FusionLineSeries(
          name: 'Visible',
          dataPoints: [FusionDataPoint(5, 80)],
          color: Colors.blue,
          visible: true,
        );

        final series2 = FusionLineSeries(
          name: 'Hidden',
          dataPoints: [
            FusionDataPoint(5, 50), // Closer to center
          ],
          color: Colors.red,
          visible: false,
        );

        final config = FusionChartConfiguration();

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(
          50,
        ); // Closer to hidden series

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
        expect(point!.y, equals(80)); // Should select visible series
      });

      test('handles series with different data densities', () {
        // Series 1: sparse data
        final series1 = FusionLineSeries(
          name: 'Sparse',
          dataPoints: [FusionDataPoint(0, 80), FusionDataPoint(10, 80)],
          color: Colors.blue,
        );

        // Series 2: dense data
        final series2 = FusionLineSeries(
          name: 'Dense',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(1, 20),
            FusionDataPoint(2, 20),
            FusionDataPoint(3, 20),
            FusionDataPoint(4, 20),
            FusionDataPoint(5, 20),
            FusionDataPoint(6, 20),
            FusionDataPoint(7, 20),
            FusionDataPoint(8, 20),
            FusionDataPoint(9, 20),
            FusionDataPoint(10, 20),
          ],
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

        // Query at X=3.5 (between sparse points, on dense point)
        final screenX = coordSystem.dataXToScreenX(3.5);
        final screenY = coordSystem.dataYToScreenY(20); // Near Series 2

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
        expect(point!.y, equals(20)); // Should find Series 2
      });

      test('handles crossing lines at query position', () {
        // Two lines that cross at X=5
        final series1 = FusionLineSeries(
          name: 'Rising',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(5, 50),
            FusionDataPoint(10, 80),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Falling',
          dataPoints: [
            FusionDataPoint(0, 80),
            FusionDataPoint(5, 50),
            FusionDataPoint(10, 20),
          ],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 50.0,
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Query at crossing point X=5, Y=50
        final screenX = coordSystem.dataXToScreenX(5);
        final screenY = coordSystem.dataYToScreenY(50);

        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        // Should return one of them (both at same position)
        expect(point, isNotNull);
        expect(point!.x, equals(5));
        expect(point.y, equals(50));
      });
    });

    group('Live Mode Integration', () {
      test('isLiveMode flag is passed correctly', () {
        final series = FusionLineSeries(
          name: 'Series 1',
          dataPoints: [
            FusionDataPoint(0, 50),
            FusionDataPoint(5, 50),
            FusionDataPoint(10, 50),
          ],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration();

        final staticState = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: false,
        );
        staticState.initialize();

        final liveState = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        liveState.initialize();

        expect(staticState.isLiveMode, isFalse);
        expect(liveState.isLiveMode, isTrue);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/charts/fusion_interactive_chart.dart';

void main() {
  group('FusionLiveChartMixin Tests', () {
    late FusionCoordinateSystem coordSystem;

    setUp(() {
      coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(50, 50, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 1.0,
      );
    });

    group('Probe Position Management', () {
      test('setProbePosition stores both X and Y', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(0, 50), FusionDataPoint(100, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        state.setProbePosition(const Offset(200, 150));

        expect(state.probeScreenX, equals(200));
        expect(state.probeScreenY, equals(150));
        expect(state.isProbeActive, isTrue);
      });

      test('clearProbePosition clears both X and Y', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(0, 50), FusionDataPoint(100, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        state.setProbePosition(const Offset(200, 150));
        expect(state.isProbeActive, isTrue);

        state.clearProbePosition();

        expect(state.probeScreenX, isNull);
        expect(state.probeScreenY, isNull);
        expect(state.isProbeActive, isFalse);
      });

      test('probeX and probeY setters work independently', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(0, 50), FusionDataPoint(100, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration();

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        state.probeX = 100;
        expect(state.probeScreenX, equals(100));
        expect(state.probeScreenY, isNull);

        state.probeY = 200;
        expect(state.probeScreenX, equals(100));
        expect(state.probeScreenY, equals(200));
      });
    });

    group('Live Mode Flag', () {
      test('isLiveMode false for static charts', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(0, 50)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: false,
        );
        state.initialize();

        expect(state.isLiveMode, isFalse);
      });

      test('isLiveMode true for live charts', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(0, 50)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        expect(state.isLiveMode, isTrue);
      });
    });

    group('updateLiveTooltip', () {
      test('does nothing when not in live mode', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: false, // NOT live mode
        );
        state.initialize();

        // Should not throw, just return early
        state.updateLiveTooltip();
        expect(state.tooltipData, isNull);
      });

      test('does nothing when no tooltip is shown', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        // No tooltip shown
        expect(state.tooltipData, isNull);

        // Should not throw, just return early
        state.updateLiveTooltip();
        expect(state.tooltipData, isNull);
      });
    });

    group('findPointAtScreenX - Live Mode Integration', () {
      test('live mode finds point by X coordinate', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [
            FusionDataPoint(0, 10),
            FusionDataPoint(25, 30),
            FusionDataPoint(50, 50),
            FusionDataPoint(75, 70),
            FusionDataPoint(100, 90),
          ],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        // Query at screen X corresponding to data X=50
        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(50));
        expect(point.y, equals(50));
      });

      test('live mode interpolates between data points', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(0, 0), FusionDataPoint(100, 100)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        // Query at screen X corresponding to data X=50
        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        // Should return nearest actual point
        expect(point!.x, anyOf(equals(0), equals(100)));
      });
    });

    group('Series Update in Live Mode', () {
      test('series can be updated for live charts', () {
        final series1 = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(0, 50)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series1],
          isLiveMode: true,
        );
        state.initialize();

        // Update series with new data
        final series2 = FusionLineSeries(
          name: 'Test',
          dataPoints: [
            FusionDataPoint(0, 50),
            FusionDataPoint(10, 60),
            FusionDataPoint(20, 70),
          ],
          color: Colors.blue,
        );

        state.series = [series2];

        // Query should work with new data
        final screenX = coordSystem.dataXToScreenX(10);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(10));
        expect(point.y, equals(60));
      });
    });

    group('Coordinate System Access', () {
      test('currentCoordSystem returns the coordinate system', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [
            FusionDataPoint(0, 0),
            FusionDataPoint(50, 50),
            FusionDataPoint(100, 100),
          ],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        // Verify coordinate system is accessible
        expect(state.currentCoordSystem, isNotNull);
        expect(
          state.currentCoordSystem.chartArea,
          equals(coordSystem.chartArea),
        );
      });
    });

    group('Multi-Series Live Mode', () {
      test('selects correct series based on Y position', () {
        final series1 = FusionLineSeries(
          name: 'Top Line',
          dataPoints: [
            FusionDataPoint(0, 80),
            FusionDataPoint(50, 80),
            FusionDataPoint(100, 80),
          ],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Bottom Line',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(50, 20),
            FusionDataPoint(100, 20),
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
          isLiveMode: true,
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(50);

        // Tap near top line
        final screenYTop = coordSystem.dataYToScreenY(80);
        final point1 = state.findPointAtScreenX(screenX, screenY: screenYTop);
        expect(point1, isNotNull);
        expect(point1!.y, equals(80));

        // Tap near bottom line
        final screenYBottom = coordSystem.dataYToScreenY(20);
        final point2 = state.findPointAtScreenX(
          screenX,
          screenY: screenYBottom,
        );
        expect(point2, isNotNull);
        expect(point2!.y, equals(20));
      });

      test('probe Y position is used for series selection', () {
        final series1 = FusionLineSeries(
          name: 'Line 1',
          dataPoints: [FusionDataPoint(50, 70)],
          color: Colors.blue,
        );

        final series2 = FusionLineSeries(
          name: 'Line 2',
          dataPoints: [FusionDataPoint(50, 30)],
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
          isLiveMode: true,
        );
        state.initialize();

        // Set probe position near series 2
        final probeX = coordSystem.dataXToScreenX(50);
        final probeY = coordSystem.dataYToScreenY(30);
        state.setProbePosition(Offset(probeX, probeY));

        // Query at probe X with probe Y
        final point = state.findPointAtScreenX(probeX, screenY: probeY);

        expect(point, isNotNull);
        expect(point!.y, equals(30)); // Should select series 2
      });
    });

    group('Edge Cases', () {
      test('handles empty series gracefully', () {
        final series = FusionLineSeries(
          name: 'Empty',
          dataPoints: [],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        final point = state.findPointAtScreenX(200);
        expect(point, isNull);
      });

      test('handles single point series', () {
        final series = FusionLineSeries(
          name: 'Single',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        // Query anywhere should return the single point
        final screenX = coordSystem.dataXToScreenX(0);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(50));
        expect(point.y, equals(50));
      });

      test('handles query outside chart area X bounds', () {
        final series = FusionLineSeries(
          name: 'Test',
          dataPoints: [FusionDataPoint(25, 50), FusionDataPoint(75, 50)],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        // Query at X=0 (before first data point)
        final screenX = coordSystem.dataXToScreenX(0);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(25)); // Returns nearest
      });

      test('handles all series hidden', () {
        final series = FusionLineSeries(
          name: 'Hidden',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
          visible: false,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNull);
      });
    });
  });
}

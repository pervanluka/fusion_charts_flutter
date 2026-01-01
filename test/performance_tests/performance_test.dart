import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('Performance & Stress Tests', () {
    // ==========================================================================
    // LARGE DATASET TESTS
    // ==========================================================================
    group('Large Dataset Handling', () {
      testWidgets('renders 1000 points without timeout', (tester) async {
        final data = List.generate(
          1000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1) * 50 + 50),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: FusionLineChart(
                  series: [FusionLineSeries(name: 'Large', dataPoints: data, color: Colors.blue)],
                  config: const FusionChartConfiguration(enableAnimation: false),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('renders 5000 points without timeout', (tester) async {
        final data = List.generate(
          5000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.05) * 50 + 50),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(name: 'VeryLarge', dataPoints: data, color: Colors.blue),
                  ],
                  config: const FusionChartConfiguration(enableAnimation: false),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('renders 10000 points without timeout', (tester) async {
        final data = List.generate(
          10000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.02) * 50 + 50),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: FusionLineChart(
                  series: [FusionLineSeries(name: 'Massive', dataPoints: data, color: Colors.blue)],
                  config: const FusionChartConfiguration(enableAnimation: false),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      test('LTTB downsamples 10000 points efficiently', () {
        final data = List.generate(
          10000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.02) * 50 + 50),
        );

        const downsampler = LTTBDownsampler();

        final stopwatch = Stopwatch()..start();
        final result = downsampler.downsample(data: data, targetPoints: 500);
        stopwatch.stop();

        expect(result.length, 500);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: 'Downsampling should complete in < 100ms',
        );
      });
    });

    // ==========================================================================
    // MULTIPLE SERIES TESTS
    // ==========================================================================
    group('Multiple Series Performance', () {
      testWidgets('renders 10 series efficiently', (tester) async {
        final series = List.generate(
          10,
          (seriesIndex) => FusionLineSeries(
            name: 'Series $seriesIndex',
            dataPoints: List.generate(
              100,
              (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1 + seriesIndex) * 30 + 50),
            ),
            color: Colors.primaries[seriesIndex % Colors.primaries.length],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: FusionLineChart(
                  series: series,
                  config: const FusionChartConfiguration(enableAnimation: false),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('renders 20 bar series efficiently', (tester) async {
        final series = List.generate(
          20,
          (seriesIndex) => FusionBarSeries(
            name: 'Series $seriesIndex',
            dataPoints: List.generate(
              5,
              (i) => FusionDataPoint(
                i.toDouble(),
                math.Random(seriesIndex * 100 + i).nextDouble() * 80 + 20,
                label: 'Cat $i',
              ),
            ),
            color: Colors.primaries[seriesIndex % Colors.primaries.length],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: FusionBarChart(
                  series: series,
                  config: const FusionBarChartConfiguration(enableAnimation: false),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionBarChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // ANIMATION PERFORMANCE TESTS
    // ==========================================================================
    group('Animation Performance', () {
      testWidgets('animation runs smoothly with 500 points', (tester) async {
        final data = List.generate(
          500,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1) * 50 + 50),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(name: 'Animated', dataPoints: data, color: Colors.blue),
                  ],
                  config: const FusionChartConfiguration(
                    enableAnimation: true,
                    animationDuration: Duration(milliseconds: 500),
                  ),
                ),
              ),
            ),
          ),
        );

        // Let animation run
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // RESIZE PERFORMANCE TESTS
    // ==========================================================================
    group('Resize Performance', () {
      testWidgets('handles rapid resize without crash', (tester) async {
        final data = List.generate(
          200,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1) * 50 + 50),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [FusionLineSeries(name: 'Resize', dataPoints: data, color: Colors.blue)],
                  config: const FusionChartConfiguration(enableAnimation: false),
                ),
              ),
            ),
          ),
        );

        // Simulate rapid resizes
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 300 + (i * 50).toDouble(),
                  height: 300,
                  child: FusionLineChart(
                    series: [
                      FusionLineSeries(name: 'Resize', dataPoints: data, color: Colors.blue),
                    ],
                    config: const FusionChartConfiguration(enableAnimation: false),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // DATA UPDATE PERFORMANCE TESTS
    // ==========================================================================
    group('Data Update Performance', () {
      testWidgets('handles rapid data updates', (tester) async {
        var data = List.generate(100, (i) => FusionDataPoint(i.toDouble(), 50.0));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [FusionLineSeries(name: 'Dynamic', dataPoints: data, color: Colors.blue)],
                  config: const FusionChartConfiguration(enableAnimation: false),
                ),
              ),
            ),
          ),
        );

        // Simulate rapid data updates (like real-time streaming)
        for (int update = 0; update < 20; update++) {
          data = List.generate(
            100,
            (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1 + update * 0.5) * 50 + 50),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 400,
                  height: 300,
                  child: FusionLineChart(
                    series: [
                      FusionLineSeries(name: 'Dynamic', dataPoints: data, color: Colors.blue),
                    ],
                    config: const FusionChartConfiguration(enableAnimation: false),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // COORDINATE TRANSFORMATION PERFORMANCE
    // ==========================================================================
    group('Coordinate Transformation Performance', () {
      test('performs 100000 transformations efficiently', () {
        final coordSystem = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 800, 400),
          dataXMin: 0,
          dataXMax: 1000,
          dataYMin: 0,
          dataYMax: 100,
        );

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100000; i++) {
          final x = i % 1000;
          final y = i % 100;
          final screen = coordSystem.dataToScreen(FusionDataPoint(x.toDouble(), y.toDouble()));
          coordSystem.screenToData(screen);
        }

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason: '100k transformations should complete in < 500ms',
        );
      });
    });

    // ==========================================================================
    // VALIDATION PERFORMANCE
    // ==========================================================================
    group('Data Validation Performance', () {
      test('validates 50000 points efficiently', () {
        final data = List.generate(
          50000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.01) * 50 + 50),
        );

        final validator = DataValidator();

        final stopwatch = Stopwatch()..start();
        final result = validator.validate(data);
        stopwatch.stop();

        expect(result.validCount, 50000);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason: 'Validating 50k points should complete in < 200ms',
        );
      });

      test('sorts 50000 points efficiently', () {
        final random = math.Random(42);
        final data = List.generate(
          50000,
          (i) => FusionDataPoint(random.nextDouble() * 50000, random.nextDouble() * 100),
        );

        final validator = DataValidator(sortByX: true);

        final stopwatch = Stopwatch()..start();
        final result = validator.validate(data);
        stopwatch.stop();

        expect(result.validCount, 50000);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason: 'Sorting 50k points should complete in < 500ms',
        );

        // Verify sorted
        for (int i = 0; i < result.validData.length - 1; i++) {
          expect(result.validData[i].x, lessThanOrEqualTo(result.validData[i + 1].x));
        }
      });
    });

    // ==========================================================================
    // AXIS BOUNDS CALCULATION PERFORMANCE
    // ==========================================================================
    group('Axis Calculation Performance', () {
      test('calculates bounds for large dataset efficiently', () {
        final data = List.generate(
          100000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.001) * 1000 + 500),
        );

        final minY = data.map((p) => p.y).reduce(math.min);
        final maxY = data.map((p) => p.y).reduce(math.max);

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          ChartBoundsCalculator.calculateNiceYBounds(dataMinY: minY, dataMaxY: maxY);
        }

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: '1000 bounds calculations should complete in < 100ms',
        );
      });
    });
  });
}

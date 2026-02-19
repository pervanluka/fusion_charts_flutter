import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/live/fusion_live_chart_controller.dart';
import 'package:fusion_charts_flutter/src/live/live_viewport_mode.dart';
import 'package:fusion_charts_flutter/src/live/retention_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Live FusionLineChart', () {
    late FusionLiveChartController controller;

    setUp(() {
      controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(100),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with live controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                series: [
                  FusionLineSeries(
                    name: 'test',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('updates when data is added', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                series: [
                  FusionLineSeries(
                    name: 'sensor',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add some data points
      controller.addPoint('sensor', const FusionDataPoint(0, 10));
      controller.addPoint('sensor', const FusionDataPoint(1, 20));
      controller.addPoint('sensor', const FusionDataPoint(2, 15));

      await tester.pump();

      // Verify data was added
      expect(controller.getPoints('sensor').length, 3);
    });

    testWidgets('handles multiple series', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                series: [
                  FusionLineSeries(
                    name: 'temp',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.red,
                  ),
                  FusionLineSeries(
                    name: 'humidity',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add data to both series
      controller.addPoint('temp', const FusionDataPoint(0, 25));
      controller.addPoint('humidity', const FusionDataPoint(0, 60));
      controller.addPoint('temp', const FusionDataPoint(1, 26));
      controller.addPoint('humidity', const FusionDataPoint(1, 58));

      await tester.pump();

      expect(controller.getPoints('temp').length, 2);
      expect(controller.getPoints('humidity').length, 2);
    });

    testWidgets('respects liveViewportMode autoScroll', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                liveViewportMode: const LiveViewportMode.autoScroll(
                  visibleDuration: Duration(seconds: 30),
                ),
                series: [
                  FusionLineSeries(
                    name: 'data',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add data points with timestamps
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();
      controller.addPoints('data', [
        for (var i = 0; i < 10; i++) FusionDataPoint(now + i * 1000, i * 10.0),
      ]);

      await tester.pump();

      expect(controller.getPoints('data').length, 10);
    });

    testWidgets('works with autoScrollPoints mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                liveViewportMode: const LiveViewportMode.autoScrollPoints(
                  visiblePoints: 5,
                ),
                series: [
                  FusionLineSeries(
                    name: 'points',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add points in batch
      controller.addPoints('points', [
        for (var i = 0; i < 20; i++) FusionDataPoint(i.toDouble(), i * 5.0),
      ]);

      await tester.pump();

      expect(controller.getPoints('points').length, 20);
    });

    testWidgets('handles controller changes in didUpdateWidget', (
      tester,
    ) async {
      final controller1 = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(50),
      );
      final controller2 = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(50),
      );

      var currentController = controller1;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentController = controller2;
                        });
                      },
                      child: const Text('Switch'),
                    ),
                    Expanded(
                      child: FusionLineChart(
                        liveController: currentController,
                        series: [
                          FusionLineSeries(
                            name: 'test',
                            dataPoints: const [FusionDataPoint(0, 0)],
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Add data to first controller
      controller1.addPoint('test', const FusionDataPoint(0, 10));
      await tester.pump();

      expect(controller1.getPoints('test').length, 1);
      expect(controller2.getPoints('test').length, 0);

      // Switch controllers
      await tester.tap(find.text('Switch'));
      await tester.pump();

      // Add data to second controller
      controller2.addPoint('test', const FusionDataPoint(1, 20));
      await tester.pump();

      expect(controller2.getPoints('test').length, 1);

      controller1.dispose();
      controller2.dispose();
    });

    testWidgets('isLiveMode returns correct value', (tester) async {
      // With live controller
      final liveChart = FusionLineChart(
        liveController: controller,
        series: [
          FusionLineSeries(
            name: 'test',
            dataPoints: const [FusionDataPoint(0, 0)],
            color: Colors.blue,
          ),
        ],
      );
      expect(liveChart.isLiveMode, isTrue);

      // Without live controller
      final staticChart = FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'test',
            dataPoints: [const FusionDataPoint(0, 10)],
            color: Colors.blue,
          ),
        ],
      );
      expect(staticChart.isLiveMode, isFalse);
    });
  });

  group('Live FusionBarChart', () {
    late FusionLiveChartController controller;

    setUp(() {
      controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(50),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with live controller and initial data', (
      tester,
    ) async {
      // Pre-populate data for bar chart
      controller.addPoint('sales', const FusionDataPoint(0, 100, label: 'Q1'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                liveController: controller,
                series: [
                  FusionBarSeries(
                    name: 'sales',
                    dataPoints: const [FusionDataPoint(0, 50, label: 'Init')],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FusionBarChart), findsOneWidget);
    });

    testWidgets('updates when data is added', (tester) async {
      // Pre-populate data
      controller.addPoint('sales', const FusionDataPoint(0, 100, label: 'Q1'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                liveController: controller,
                series: [
                  FusionBarSeries(
                    name: 'sales',
                    dataPoints: const [FusionDataPoint(0, 50, label: 'Init')],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add more data points
      controller.addPoint('sales', const FusionDataPoint(1, 150, label: 'Q2'));
      controller.addPoint('sales', const FusionDataPoint(2, 120, label: 'Q3'));

      await tester.pump();

      expect(controller.getPoints('sales').length, 3);
    });

    testWidgets('handles grouped bar series', (tester) async {
      // Pre-populate data
      controller.addPoint('product_a', const FusionDataPoint(0, 10));
      controller.addPoint('product_b', const FusionDataPoint(0, 15));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                liveController: controller,
                config: const FusionBarChartConfiguration(
                  enableSideBySideSeriesPlacement: true,
                ),
                series: [
                  FusionBarSeries(
                    name: 'product_a',
                    dataPoints: const [FusionDataPoint(0, 5)],
                    color: Colors.blue,
                  ),
                  FusionBarSeries(
                    name: 'product_b',
                    dataPoints: const [FusionDataPoint(0, 10)],
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add more data to both series
      for (var i = 1; i < 5; i++) {
        controller.addPoint(
          'product_a',
          FusionDataPoint(i.toDouble(), (i * 10).toDouble()),
        );
        controller.addPoint(
          'product_b',
          FusionDataPoint(i.toDouble(), (i * 15).toDouble()),
        );
      }

      await tester.pump();

      expect(controller.getPoints('product_a').length, 5);
      expect(controller.getPoints('product_b').length, 5);
    });

    testWidgets('isLiveMode returns correct value', (tester) async {
      // With live controller
      final liveChart = FusionBarChart(
        liveController: controller,
        series: [
          FusionBarSeries(
            name: 'test',
            dataPoints: const [FusionDataPoint(0, 10)],
            color: Colors.blue,
          ),
        ],
      );
      expect(liveChart.isLiveMode, isTrue);

      // Without live controller
      final staticChart = FusionBarChart(
        series: [
          FusionBarSeries(
            name: 'test',
            dataPoints: [const FusionDataPoint(0, 10)],
            color: Colors.blue,
          ),
        ],
      );
      expect(staticChart.isLiveMode, isFalse);
    });
  });

  group('Live Viewport Modes', () {
    testWidgets('FixedViewport does not auto-scroll', (tester) async {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                liveViewportMode: const LiveViewportMode.fixed(
                  initialRange: (0, 100),
                ),
                series: [
                  FusionLineSeries(
                    name: 'data',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add points in batch
      controller.addPoints('data', [
        for (var i = 0; i < 150; i++) FusionDataPoint(i.toDouble(), i * 2.0),
      ]);

      await tester.pump();

      // Data should still be added (limited by retention policy)
      expect(controller.getPoints('data').length, 100);

      controller.dispose();
    });

    testWidgets('FillThenScroll fills then scrolls', (tester) async {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.unlimited(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                liveViewportMode: const LiveViewportMode.fillThenScroll(
                  maxDuration: Duration(seconds: 10),
                ),
                series: [
                  FusionLineSeries(
                    name: 'data',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add points in batch
      final baseTime = DateTime.now().millisecondsSinceEpoch.toDouble();
      controller.addPoints('data', [
        for (var i = 0; i < 20; i++)
          FusionDataPoint(baseTime + i * 1000, i * 5.0),
      ]);

      await tester.pump();

      expect(controller.getPoints('data').length, 20);

      controller.dispose();
    });
  });

  group('Stream Binding Integration', () {
    testWidgets('updates chart when stream emits', (tester) async {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(100),
      );

      final streamController = StreamController<double>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                series: [
                  FusionLineSeries(
                    name: 'stream_data',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Bind stream
      var x = 0.0;
      controller.bindStream<double>(
        'stream_data',
        streamController.stream,
        mapper: (value) => FusionDataPoint(x++, value),
      );

      // Emit values
      streamController.add(10.0);
      streamController.add(20.0);
      streamController.add(15.0);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.getPoints('stream_data').length, 3);

      await streamController.close();
      controller.dispose();
    });
  });

  group('Live Viewport Reset', () {
    testWidgets('resets viewport flag when controller is attached', (
      tester,
    ) async {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                liveViewportMode: const LiveViewportMode.autoScroll(
                  visibleDuration: Duration(seconds: 10),
                ),
                series: [
                  FusionLineSeries(
                    name: 'sensor',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
                config: const FusionChartConfiguration(enableAnimation: false),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add data with proper timestamps
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();
      controller.addPoints('sensor', [
        FusionDataPoint(now, 10),
        FusionDataPoint(now + 1000, 20),
        FusionDataPoint(now + 2000, 15),
      ]);

      await tester.pump();

      // Chart should be rendered with data
      expect(find.byType(FusionLineChart), findsOneWidget);
      expect(controller.getPoints('sensor').length, 3);

      controller.dispose();
    });

    testWidgets('properly handles controller change with viewport reset', (
      tester,
    ) async {
      final controller1 = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(50),
      );
      final controller2 = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(50),
      );

      var currentController = controller1;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentController = controller2;
                        });
                      },
                      child: const Text('Switch'),
                    ),
                    Expanded(
                      child: FusionLineChart(
                        liveController: currentController,
                        liveViewportMode: const LiveViewportMode.autoScroll(
                          visibleDuration: Duration(seconds: 5),
                        ),
                        series: [
                          FusionLineSeries(
                            name: 'data',
                            dataPoints: const [FusionDataPoint(0, 0)],
                            color: Colors.blue,
                          ),
                        ],
                        config: const FusionChartConfiguration(
                          enableAnimation: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Add data to first controller
      final now1 = DateTime.now().millisecondsSinceEpoch.toDouble();
      controller1.addPoints('data', [
        FusionDataPoint(now1, 10),
        FusionDataPoint(now1 + 1000, 20),
      ]);
      await tester.pump();

      // Switch to second controller
      await tester.tap(find.text('Switch'));
      await tester.pump();

      // Add data to second controller with different timestamps
      final now2 = DateTime.now().millisecondsSinceEpoch.toDouble();
      controller2.addPoints('data', [
        FusionDataPoint(now2, 30),
        FusionDataPoint(now2 + 1000, 40),
      ]);
      await tester.pump();

      // Both should work without viewport issues
      expect(controller1.getPoints('data').length, 2);
      expect(controller2.getPoints('data').length, 2);

      controller1.dispose();
      controller2.dispose();
    });
  });

  group('Hover Probe Mode (Desktop)', () {
    testWidgets('hover on live chart with never-dismiss shows tooltip', (
      tester,
    ) async {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                series: [
                  FusionLineSeries(
                    name: 'data',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
                config: const FusionChartConfiguration(
                  enableTooltip: true,
                  tooltipBehavior: FusionTooltipBehavior(
                    dismissStrategy: FusionDismissStrategy.never,
                  ),
                  enableAnimation: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add data
      controller.addPoints('data', [
        for (var i = 0; i < 10; i++) FusionDataPoint(i.toDouble(), i * 10.0),
      ]);
      await tester.pump();

      // Simulate hover (desktop)
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(200, 150));
      await tester.pump();
      await gesture.moveTo(const Offset(250, 150));
      await tester.pump();

      // Chart should render without crash
      expect(find.byType(FusionLineChart), findsOneWidget);

      await gesture.removePointer();
      controller.dispose();
    });

    testWidgets('hover probe clears when mouse exits', (tester) async {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                series: [
                  FusionLineSeries(
                    name: 'data',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
                config: const FusionChartConfiguration(
                  enableTooltip: true,
                  tooltipBehavior: FusionTooltipBehavior(
                    dismissStrategy: FusionDismissStrategy.never,
                  ),
                  enableAnimation: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add data
      controller.addPoints('data', [
        for (var i = 0; i < 10; i++) FusionDataPoint(i.toDouble(), i * 10.0),
      ]);
      await tester.pump();

      // Hover then exit
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(200, 150));
      await tester.pump();

      // Exit chart area
      await gesture.moveTo(const Offset(450, 350));
      await tester.pump();

      // Should still render correctly
      expect(find.byType(FusionLineChart), findsOneWidget);

      await gesture.removePointer();
      controller.dispose();
    });
  });

  group('Pause/Resume', () {
    testWidgets('paused chart still receives data', (tester) async {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                liveController: controller,
                series: [
                  FusionLineSeries(
                    name: 'data',
                    dataPoints: const [FusionDataPoint(0, 0)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add some data
      controller.addPoint('data', const FusionDataPoint(0, 10));
      controller.addPoint('data', const FusionDataPoint(1, 20));

      await tester.pump();
      expect(controller.getPoints('data').length, 2);

      // Pause
      controller.pause();
      expect(controller.isPaused, isTrue);

      // Add more data while paused
      controller.addPoint('data', const FusionDataPoint(2, 30));
      controller.addPoint('data', const FusionDataPoint(3, 40));

      await tester.pump();

      // Data should still be added
      expect(controller.getPoints('data').length, 4);

      // Resume
      controller.resume();
      expect(controller.isPaused, isFalse);

      controller.dispose();
    });
  });
}

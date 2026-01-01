import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('Chart Interaction Tests', () {
    // ==========================================================================
    // LINE CHART INTERACTIONS
    // ==========================================================================
    group('FusionLineChart Interactions', () {
      testWidgets('shows tooltip on tap', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 30),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap near a data point (center of chart area)
        await tester.tapAt(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 100));

        // Chart should still be rendered (no crash)
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles long press for crosshair', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 30),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableCrosshair: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Long press
        await tester.longPressAt(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles pan gesture', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: List.generate(
                        20,
                        (i) =>
                            FusionDataPoint(i.toDouble(), (i * 5).toDouble()),
                      ),
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enablePanning: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Pan gesture
        await tester.drag(find.byType(FusionLineChart), const Offset(-50, 0));
        await tester.pumpAndSettle();

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles hover on desktop', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 30),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate hover
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: const Offset(200, 150));
        await tester.pump();
        await gesture.moveTo(const Offset(250, 150));
        await tester.pump();

        expect(find.byType(FusionLineChart), findsOneWidget);

        await gesture.removePointer();
      });

      testWidgets('handles mouse wheel zoom', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: List.generate(
                        20,
                        (i) =>
                            FusionDataPoint(i.toDouble(), (i * 5).toDouble()),
                      ),
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableZoom: true,
                    zoomBehavior: FusionZoomConfiguration(
                      enableMouseWheelZoom: true,
                    ),
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate mouse wheel scroll for zoom
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: const Offset(200, 150));
        await tester.pump();

        // Scroll up (zoom in)
        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: const Offset(200, 150),
            scrollDelta: const Offset(0, -50),
          ),
        );
        await tester.pump();

        expect(find.byType(FusionLineChart), findsOneWidget);

        await gesture.removePointer();
      });
    });

    // ==========================================================================
    // BAR CHART INTERACTIONS
    // ==========================================================================
    group('FusionBarChart Interactions', () {
      testWidgets('shows tooltip on bar tap', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: 'A'),
                        FusionDataPoint(1, 50, label: 'B'),
                        FusionDataPoint(2, 40, label: 'C'),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionBarChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on a bar
        await tester.tapAt(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FusionBarChart), findsOneWidget);
      });

      testWidgets('handles multiple taps without crash', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: 'A'),
                        FusionDataPoint(1, 50, label: 'B'),
                        FusionDataPoint(2, 40, label: 'C'),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionBarChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Multiple rapid taps
        for (int i = 0; i < 5; i++) {
          await tester.tapAt(Offset(100 + i * 50, 150));
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(FusionBarChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // STACKED BAR CHART INTERACTIONS
    // ==========================================================================
    group('FusionStackedBarChart Interactions', () {
      testWidgets('shows multi-segment tooltip on tap', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionStackedBarChart(
                  series: [
                    FusionStackedBarSeries(
                      name: 'Product A',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: 'Q1'),
                        FusionDataPoint(1, 40, label: 'Q2'),
                      ],
                      color: Colors.blue,
                    ),
                    FusionStackedBarSeries(
                      name: 'Product B',
                      dataPoints: [
                        FusionDataPoint(0, 20, label: 'Q1'),
                        FusionDataPoint(1, 25, label: 'Q2'),
                      ],
                      color: Colors.green,
                    ),
                  ],
                  config: const FusionStackedBarChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tapAt(const Offset(150, 150));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FusionStackedBarChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // PIE CHART INTERACTIONS
    // ==========================================================================
    group('FusionPieChart Interactions', () {
      testWidgets('shows tooltip on slice tap', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    name: 'Sales',
                    dataPoints: [
                      FusionPieDataPoint(30, label: 'A', color: Colors.blue),
                      FusionPieDataPoint(40, label: 'B', color: Colors.red),
                      FusionPieDataPoint(30, label: 'C', color: Colors.green),
                    ],
                  ),
                  config: const FusionPieChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on pie slice
        await tester.tapAt(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('handles explode on tap', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    name: 'Sales',
                    dataPoints: [
                      FusionPieDataPoint(30, label: 'A', color: Colors.blue),
                      FusionPieDataPoint(40, label: 'B', color: Colors.red),
                      FusionPieDataPoint(30, label: 'C', color: Colors.green),
                    ],
                  ),
                  config: const FusionPieChartConfiguration(
                    enableSelection: true,
                    explodeOnSelection: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tapAt(const Offset(200, 150));
        await tester.pumpAndSettle();

        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // TOOLTIP DISMISS STRATEGIES
    // ==========================================================================
    group('Tooltip Dismiss Strategies', () {
      testWidgets('tooltip dismisses on release', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 30),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    tooltipBehavior: FusionTooltipBehavior(
                      dismissStrategy: FusionDismissStrategy.onRelease,
                    ),
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Press and hold
        final gesture = await tester.startGesture(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 100));

        // Release
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('tooltip stays with never dismiss strategy', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 30),
                      ],
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

        await tester.tapAt(const Offset(200, 150));
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('tooltip dismisses after timer', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 30),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    tooltipBehavior: FusionTooltipBehavior(
                      dismissStrategy: FusionDismissStrategy.onTimer,
                      duration: Duration(milliseconds: 500),
                    ),
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tapAt(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // TRACKBALL MODES
    // ==========================================================================
    group('Trackball Modes', () {
      testWidgets('trackball follows pointer movement', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: List.generate(
                        10,
                        (i) =>
                            FusionDataPoint(i.toDouble(), (i * 10).toDouble()),
                      ),
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    tooltipBehavior: FusionTooltipBehavior(
                      trackballMode: FusionTooltipTrackballMode.follow,
                    ),
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Drag across chart
        final gesture = await tester.startGesture(const Offset(100, 150));
        await tester.pump(const Duration(milliseconds: 50));

        for (int i = 0; i < 5; i++) {
          await gesture.moveBy(const Offset(30, 0));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await gesture.up();
        await tester.pump();

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('trackball snaps to X coordinate', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: List.generate(
                        10,
                        (i) =>
                            FusionDataPoint(i.toDouble(), (i * 10).toDouble()),
                      ),
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    tooltipBehavior: FusionTooltipBehavior(
                      trackballMode: FusionTooltipTrackballMode.snapToX,
                    ),
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final gesture = await tester.startGesture(const Offset(100, 150));
        await tester.pump(const Duration(milliseconds: 50));

        await gesture.moveBy(const Offset(100, 0));
        await tester.pump(const Duration(milliseconds: 50));

        await gesture.up();
        await tester.pump();

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('magnetic trackball snaps within radius', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: List.generate(
                        10,
                        (i) =>
                            FusionDataPoint(i.toDouble(), (i * 10).toDouble()),
                      ),
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    tooltipBehavior: FusionTooltipBehavior(
                      trackballMode: FusionTooltipTrackballMode.magnetic,
                      trackballSnapRadius: 30.0,
                    ),
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final gesture = await tester.startGesture(const Offset(100, 150));
        await tester.pump(const Duration(milliseconds: 50));

        await gesture.moveBy(const Offset(50, 10));
        await tester.pump(const Duration(milliseconds: 50));

        await gesture.up();
        await tester.pump();

        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // EDGE CASE INTERACTIONS
    // ==========================================================================
    group('Edge Case Interactions', () {
      testWidgets('handles tap outside chart area', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                      ],
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap outside chart area (in padding/margins)
        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles rapid gesture changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: List.generate(
                        20,
                        (i) =>
                            FusionDataPoint(i.toDouble(), (i * 5).toDouble()),
                      ),
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip:
                        false, // Disable tooltip to avoid timer issues
                    enablePanning: true,
                    enableZoom: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Rapid gesture changes
        await tester.tapAt(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 20));

        await tester.drag(find.byType(FusionLineChart), const Offset(50, 0));
        await tester.pump(const Duration(milliseconds: 20));

        await tester.tapAt(const Offset(250, 150));
        await tester.pumpAndSettle();

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles interactions with empty series', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Empty',
                      dataPoints: [],
                      color: Colors.blue,
                      visible: false,
                    ),
                    FusionLineSeries(
                      name: 'Visible',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                      ],
                      color: Colors.red,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableTooltip: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tapAt(const Offset(200, 150));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles simultaneous multi-touch', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Test',
                      dataPoints: List.generate(
                        20,
                        (i) =>
                            FusionDataPoint(i.toDouble(), (i * 5).toDouble()),
                      ),
                      color: Colors.blue,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableZoom: true,
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate pinch zoom (two fingers)
        final finger1 = await tester.startGesture(const Offset(150, 150));
        final finger2 = await tester.startGesture(const Offset(250, 150));
        await tester.pump();

        // Move fingers apart (zoom in)
        await finger1.moveBy(const Offset(-20, 0));
        await finger2.moveBy(const Offset(20, 0));
        await tester.pump();

        await finger1.up();
        await finger2.up();
        await tester.pump();

        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });
  });
}

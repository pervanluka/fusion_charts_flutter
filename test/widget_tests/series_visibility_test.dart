import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('Series Visibility Tests', () {
    // ==========================================================================
    // LINE CHART SERIES VISIBILITY
    // ==========================================================================
    group('FusionLineChart Series Visibility', () {
      testWidgets('renders only visible series', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Visible',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                      ],
                      color: Colors.blue,
                      visible: true,
                    ),
                    FusionLineSeries(
                      name: 'Hidden',
                      dataPoints: [
                        FusionDataPoint(0, 30),
                        FusionDataPoint(1, 70),
                      ],
                      color: Colors.red,
                      visible: false,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('renders correctly when all series hidden', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Hidden1',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                      ],
                      color: Colors.blue,
                      visible: false,
                    ),
                    FusionLineSeries(
                      name: 'Hidden2',
                      dataPoints: [
                        FusionDataPoint(0, 30),
                        FusionDataPoint(1, 70),
                      ],
                      color: Colors.red,
                      visible: false,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // Should render without crash even with no visible data
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles toggling series visibility', (tester) async {
        bool seriesVisible = true;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      Expanded(
                        child: FusionLineChart(
                          series: [
                            FusionLineSeries(
                              name: 'Toggle',
                              dataPoints: [
                                FusionDataPoint(0, 10),
                                FusionDataPoint(1, 50),
                                FusionDataPoint(2, 30),
                              ],
                              color: Colors.blue,
                              visible: seriesVisible,
                            ),
                          ],
                          config: const FusionChartConfiguration(
                            enableAnimation: false,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            seriesVisible = !seriesVisible;
                          });
                        },
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);

        // Toggle visibility
        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);

        // Toggle back
        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // BAR CHART SERIES VISIBILITY
    // ==========================================================================
    group('FusionBarChart Series Visibility', () {
      testWidgets('renders only visible series', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Visible',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: 'A'),
                        FusionDataPoint(1, 50, label: 'B'),
                      ],
                      color: Colors.blue,
                      visible: true,
                    ),
                    FusionBarSeries(
                      name: 'Hidden',
                      dataPoints: [
                        FusionDataPoint(0, 40, label: 'A'),
                        FusionDataPoint(1, 60, label: 'B'),
                      ],
                      color: Colors.red,
                      visible: false,
                    ),
                  ],
                  config: const FusionBarChartConfiguration(
                    enableAnimation: false,
                  ),
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
    // STACKED BAR CHART SERIES VISIBILITY
    // ==========================================================================
    group('FusionStackedBarChart Series Visibility', () {
      testWidgets('renders only visible stacked series', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionStackedBarChart(
                  series: [
                    FusionStackedBarSeries(
                      name: 'Visible',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: 'Q1'),
                        FusionDataPoint(1, 40, label: 'Q2'),
                      ],
                      color: Colors.blue,
                      visible: true,
                    ),
                    FusionStackedBarSeries(
                      name: 'Hidden',
                      dataPoints: [
                        FusionDataPoint(0, 20, label: 'Q1'),
                        FusionDataPoint(1, 25, label: 'Q2'),
                      ],
                      color: Colors.green,
                      visible: false,
                    ),
                  ],
                  config: const FusionStackedBarChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionStackedBarChart), findsOneWidget);
      });
    });

    // ==========================================================================
    // MIXED VISIBILITY SCENARIOS
    // ==========================================================================
    group('Mixed Visibility Scenarios', () {
      testWidgets('handles alternating visible/hidden series', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Series 0',
                      dataPoints: [FusionDataPoint(0, 10), FusionDataPoint(1, 20)],
                      color: Colors.blue,
                      visible: true,
                    ),
                    FusionLineSeries(
                      name: 'Series 1',
                      dataPoints: [FusionDataPoint(0, 15), FusionDataPoint(1, 25)],
                      color: Colors.red,
                      visible: false,
                    ),
                    FusionLineSeries(
                      name: 'Series 2',
                      dataPoints: [FusionDataPoint(0, 12), FusionDataPoint(1, 22)],
                      color: Colors.green,
                      visible: true,
                    ),
                    FusionLineSeries(
                      name: 'Series 3',
                      dataPoints: [FusionDataPoint(0, 18), FusionDataPoint(1, 28)],
                      color: Colors.orange,
                      visible: false,
                    ),
                    FusionLineSeries(
                      name: 'Series 4',
                      dataPoints: [FusionDataPoint(0, 14), FusionDataPoint(1, 24)],
                      color: Colors.purple,
                      visible: true,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionLineChart), findsOneWidget);
      });

      testWidgets('handles empty visible series with data in hidden', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Empty Visible',
                      dataPoints: [],
                      color: Colors.blue,
                      visible: true,
                    ),
                    FusionLineSeries(
                      name: 'Hidden With Data',
                      dataPoints: [
                        FusionDataPoint(0, 10),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 30),
                      ],
                      color: Colors.red,
                      visible: false,
                    ),
                  ],
                  config: const FusionChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // Should not crash
        expect(find.byType(FusionLineChart), findsOneWidget);
      });
    });
  });
}

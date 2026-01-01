import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('FusionStackedBarChart Widget Tests', () {
    testWidgets('renders without error', (tester) async {
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
                      FusionDataPoint(0, 30),
                      FusionDataPoint(1, 40),
                      FusionDataPoint(2, 35),
                    ],
                    color: Colors.blue,
                  ),
                  FusionStackedBarSeries(
                    name: 'Product B',
                    dataPoints: [
                      FusionDataPoint(0, 20),
                      FusionDataPoint(1, 25),
                      FusionDataPoint(2, 30),
                    ],
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionStackedBarChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with single series', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionStackedBarChart(
                series: [
                  FusionStackedBarSeries(
                    name: 'Only Series',
                    dataPoints: [
                      FusionDataPoint(0, 50),
                      FusionDataPoint(1, 60),
                    ],
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionStackedBarChart), findsOneWidget);
    });

    testWidgets('renders three stacked series', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionStackedBarChart(
                series: [
                  FusionStackedBarSeries(
                    name: 'Series 1',
                    dataPoints: [
                      FusionDataPoint(0, 20),
                      FusionDataPoint(1, 30),
                    ],
                    color: Colors.blue,
                  ),
                  FusionStackedBarSeries(
                    name: 'Series 2',
                    dataPoints: [
                      FusionDataPoint(0, 25),
                      FusionDataPoint(1, 20),
                    ],
                    color: Colors.green,
                  ),
                  FusionStackedBarSeries(
                    name: 'Series 3',
                    dataPoints: [
                      FusionDataPoint(0, 15),
                      FusionDataPoint(1, 25),
                    ],
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionStackedBarChart), findsOneWidget);
    });

    testWidgets('renders with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionStackedBarChart(
                series: [
                  FusionStackedBarSeries(
                    name: 'Dark A',
                    dataPoints: [
                      FusionDataPoint(0, 30),
                      FusionDataPoint(1, 40),
                    ],
                    color: Colors.cyan,
                  ),
                  FusionStackedBarSeries(
                    name: 'Dark B',
                    dataPoints: [
                      FusionDataPoint(0, 20),
                      FusionDataPoint(1, 30),
                    ],
                    color: Colors.pink,
                  ),
                ],
                config: const FusionStackedBarChartConfiguration(
                  theme: FusionDarkTheme(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionStackedBarChart), findsOneWidget);
    });

    testWidgets('handles animation disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionStackedBarChart(
                series: [
                  FusionStackedBarSeries(
                    name: 'No Anim',
                    dataPoints: [
                      FusionDataPoint(0, 40),
                      FusionDataPoint(1, 50),
                    ],
                    color: Colors.indigo,
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

      await tester.pump();
      expect(find.byType(FusionStackedBarChart), findsOneWidget);
    });

    testWidgets('renders with single data point per series', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionStackedBarChart(
                series: [
                  FusionStackedBarSeries(
                    name: 'Single A',
                    dataPoints: [FusionDataPoint(0, 50)],
                    color: Colors.red,
                  ),
                  FusionStackedBarSeries(
                    name: 'Single B',
                    dataPoints: [FusionDataPoint(0, 30)],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionStackedBarChart), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('FusionBarChart Widget Tests', () {
    testWidgets('renders without error', (tester) async {
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
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionBarChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with single bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                series: [
                  FusionBarSeries(
                    name: 'Single',
                    dataPoints: [
                      FusionDataPoint(0, 50, label: 'Only'),
                    ],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionBarChart), findsOneWidget);
    });

    testWidgets('renders grouped bars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                series: [
                  FusionBarSeries(
                    name: 'Series 1',
                    dataPoints: [
                      FusionDataPoint(0, 30),
                      FusionDataPoint(1, 50),
                    ],
                    color: Colors.blue,
                  ),
                  FusionBarSeries(
                    name: 'Series 2',
                    dataPoints: [
                      FusionDataPoint(0, 40),
                      FusionDataPoint(1, 60),
                    ],
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionBarChart), findsOneWidget);
    });

    testWidgets('renders with rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                series: [
                  FusionBarSeries(
                    name: 'Rounded',
                    dataPoints: [
                      FusionDataPoint(0, 60),
                      FusionDataPoint(1, 75),
                      FusionDataPoint(2, 65),
                    ],
                    color: Colors.green,
                    borderRadius: 12.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionBarChart), findsOneWidget);
    });

    testWidgets('renders with gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                series: [
                  FusionBarSeries(
                    name: 'Gradient',
                    dataPoints: [
                      FusionDataPoint(0, 60),
                      FusionDataPoint(1, 80),
                    ],
                    color: Colors.purple,
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.pink],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionBarChart), findsOneWidget);
    });

    testWidgets('renders with border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                series: [
                  FusionBarSeries(
                    name: 'Bordered',
                    dataPoints: [
                      FusionDataPoint(0, 50),
                      FusionDataPoint(1, 70),
                    ],
                    color: Colors.amber,
                    borderColor: Colors.orange,
                    borderWidth: 2.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionBarChart), findsOneWidget);
    });

    testWidgets('renders with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                series: [
                  FusionBarSeries(
                    name: 'Dark',
                    dataPoints: [
                      FusionDataPoint(0, 40),
                      FusionDataPoint(1, 60),
                    ],
                    color: Colors.teal,
                  ),
                ],
                config: const FusionBarChartConfiguration(
                  theme: FusionDarkTheme(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionBarChart), findsOneWidget);
    });

    testWidgets('handles animation disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionBarChart(
                series: [
                  FusionBarSeries(
                    name: 'No Animation',
                    dataPoints: [
                      FusionDataPoint(0, 50),
                      FusionDataPoint(1, 70),
                    ],
                    color: Colors.blue,
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

      await tester.pump();
      expect(find.byType(FusionBarChart), findsOneWidget);
    });
  });
}

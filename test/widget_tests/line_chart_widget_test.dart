import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('FusionLineChart Widget Tests', () {
    testWidgets('renders without error', (tester) async {
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
                      FusionDataPoint(1, 20),
                      FusionDataPoint(2, 15),
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

      expect(find.byType(FusionLineChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with single data point', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                series: [
                  FusionLineSeries(
                    name: 'Single',
                    dataPoints: [
                      FusionDataPoint(0, 50),
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
      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('renders multiple series', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                series: [
                  FusionLineSeries(
                    name: 'Series 1',
                    dataPoints: [
                      FusionDataPoint(0, 10),
                      FusionDataPoint(1, 20),
                    ],
                    color: Colors.blue,
                  ),
                  FusionLineSeries(
                    name: 'Series 2',
                    dataPoints: [
                      FusionDataPoint(0, 15),
                      FusionDataPoint(1, 25),
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
      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('renders with dark theme', (tester) async {
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
                      FusionDataPoint(1, 20),
                    ],
                    color: Colors.blue,
                  ),
                ],
                config: const FusionChartConfiguration(
                  theme: FusionDarkTheme(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('renders with curved lines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                series: [
                  FusionLineSeries(
                    name: 'Curved',
                    dataPoints: [
                      FusionDataPoint(0, 10),
                      FusionDataPoint(1, 30),
                      FusionDataPoint(2, 20),
                      FusionDataPoint(3, 40),
                    ],
                    color: Colors.purple,
                    isCurved: true,
                    smoothness: 0.4,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('renders with area fill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                series: [
                  FusionLineSeries(
                    name: 'Area',
                    dataPoints: [
                      FusionDataPoint(0, 10),
                      FusionDataPoint(1, 30),
                      FusionDataPoint(2, 20),
                    ],
                    color: Colors.green,
                    showArea: true,
                    areaOpacity: 0.3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('renders with markers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                series: [
                  FusionLineSeries(
                    name: 'Markers',
                    dataPoints: [
                      FusionDataPoint(0, 10),
                      FusionDataPoint(1, 20),
                      FusionDataPoint(2, 15),
                    ],
                    color: Colors.orange,
                    showMarkers: true,
                    markerSize: 8.0,
                    markerShape: MarkerShape.circle,
                  ),
                ],
                config: const FusionLineChartConfiguration(
                  enableMarkers: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('handles animation disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                series: [
                  FusionLineSeries(
                    name: 'No Animation',
                    dataPoints: [
                      FusionDataPoint(0, 10),
                      FusionDataPoint(1, 20),
                    ],
                    color: Colors.blue,
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

      await tester.pump();
      expect(find.byType(FusionLineChart), findsOneWidget);
    });

    testWidgets('renders with title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FusionLineChart(
                title: 'Revenue Chart',
                subtitle: 'Q1 2025',
                series: [
                  FusionLineSeries(
                    name: 'Revenue',
                    dataPoints: [
                      FusionDataPoint(0, 10),
                      FusionDataPoint(1, 20),
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
      expect(find.text('Revenue Chart'), findsOneWidget);
      expect(find.text('Q1 2025'), findsOneWidget);
    });
  });
}

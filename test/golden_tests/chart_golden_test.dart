import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('Chart Golden Tests', () {
    testWidgets('line chart matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              child: SizedBox(
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Revenue',
                      dataPoints: [
                        FusionDataPoint(0, 30),
                        FusionDataPoint(1, 50),
                        FusionDataPoint(2, 40),
                        FusionDataPoint(3, 65),
                        FusionDataPoint(4, 55),
                        FusionDataPoint(5, 80),
                      ],
                      color: const Color(0xFF6366F1),
                      lineWidth: 2.5,
                    ),
                  ],
                  config: const FusionLineChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RepaintBoundary),
        matchesGoldenFile('goldens/line_chart.png'),
      );
    });

    testWidgets('bar chart matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              child: SizedBox(
                width: 400,
                height: 300,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Sales',
                      dataPoints: [
                        FusionDataPoint(0, 65, label: 'Q1'),
                        FusionDataPoint(1, 78, label: 'Q2'),
                        FusionDataPoint(2, 82, label: 'Q3'),
                        FusionDataPoint(3, 95, label: 'Q4'),
                      ],
                      color: const Color(0xFF3B82F6),
                      barWidth: 0.6,
                      borderRadius: 4.0,
                    ),
                  ],
                  config: const FusionBarChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RepaintBoundary),
        matchesGoldenFile('goldens/bar_chart.png'),
      );
    });

    testWidgets('dark theme line chart matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1F2937),
            body: RepaintBoundary(
              child: Container(
                color: const Color(0xFF1F2937),
                width: 400,
                height: 300,
                child: FusionLineChart(
                  series: [
                    FusionLineSeries(
                      name: 'Data',
                      dataPoints: [
                        FusionDataPoint(0, 25),
                        FusionDataPoint(1, 45),
                        FusionDataPoint(2, 35),
                        FusionDataPoint(3, 60),
                        FusionDataPoint(4, 50),
                      ],
                      color: const Color(0xFF8B5CF6),
                      lineWidth: 2.5,
                    ),
                  ],
                  config: const FusionLineChartConfiguration(
                    enableAnimation: false,
                    theme: FusionDarkTheme(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RepaintBoundary),
        matchesGoldenFile('goldens/dark_theme_line_chart.png'),
      );
    });

    testWidgets('stacked bar chart matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              child: SizedBox(
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
                        FusionDataPoint(3, 45),
                      ],
                      color: const Color(0xFF6366F1),
                    ),
                    FusionStackedBarSeries(
                      name: 'Product B',
                      dataPoints: [
                        FusionDataPoint(0, 25),
                        FusionDataPoint(1, 30),
                        FusionDataPoint(2, 28),
                        FusionDataPoint(3, 35),
                      ],
                      color: const Color(0xFF10B981),
                    ),
                  ],
                  config: const FusionStackedBarChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RepaintBoundary),
        matchesGoldenFile('goldens/stacked_bar_chart.png'),
      );
    });
  });
}

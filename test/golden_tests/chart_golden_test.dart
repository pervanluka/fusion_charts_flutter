import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('Chart Golden Tests', () {
    testWidgets('line chart matches golden', (tester) async {
      final chartKey = GlobalKey();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              key: chartKey,
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
        find.byKey(chartKey),
        matchesGoldenFile('goldens/line_chart.png'),
      );
    });

    testWidgets('bar chart matches golden', (tester) async {
      final chartKey = GlobalKey();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              key: chartKey,
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
        find.byKey(chartKey),
        matchesGoldenFile('goldens/bar_chart.png'),
      );
    });

    testWidgets('dark theme line chart matches golden', (tester) async {
      final chartKey = GlobalKey();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1F2937),
            body: RepaintBoundary(
              key: chartKey,
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
        find.byKey(chartKey),
        matchesGoldenFile('goldens/dark_theme_line_chart.png'),
      );
    });

    testWidgets('stacked bar chart matches golden', (tester) async {
      final chartKey = GlobalKey();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              key: chartKey,
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
        find.byKey(chartKey),
        matchesGoldenFile('goldens/stacked_bar_chart.png'),
      );
    });

    testWidgets('pie chart matches golden', (tester) async {
      final chartKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              key: chartKey,
              child: SizedBox(
                width: 400,
                height: 300,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: [
                      FusionPieDataPoint(35, label: 'Sales', color: const Color(0xFF6366F1)),
                      FusionPieDataPoint(25, label: 'Marketing', color: const Color(0xFF22C55E)),
                      FusionPieDataPoint(20, label: 'Engineering', color: const Color(0xFFF59E0B)),
                      FusionPieDataPoint(15, label: 'Support', color: const Color(0xFFA855F7)),
                      FusionPieDataPoint(5, label: 'Other', color: const Color(0xFF6B7280)),
                    ],
                  ),
                  config: const FusionPieChartConfiguration(
                    enableAnimation: false,
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(chartKey),
        matchesGoldenFile('goldens/pie_chart.png'),
      );
    });

    testWidgets('donut chart matches golden', (tester) async {
      final chartKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              key: chartKey,
              child: SizedBox(
                width: 400,
                height: 300,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: [
                      FusionPieDataPoint(40, label: 'Revenue', color: const Color(0xFF3B82F6)),
                      FusionPieDataPoint(30, label: 'Costs', color: const Color(0xFFEF4444)),
                      FusionPieDataPoint(20, label: 'Profit', color: const Color(0xFF10B981)),
                      FusionPieDataPoint(10, label: 'Tax', color: const Color(0xFF6B7280)),
                    ],
                  ),
                  config: const FusionPieChartConfiguration(
                    enableAnimation: false,
                    innerRadiusPercent: 0.55,
                    showCenterLabel: true,
                    centerLabelText: '\$2.4M',
                    centerSubLabelText: 'Total',
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(chartKey),
        matchesGoldenFile('goldens/donut_chart.png'),
      );
    });

    testWidgets('dark theme pie chart matches golden', (tester) async {
      final chartKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1E1E2E),
            body: RepaintBoundary(
              key: chartKey,
              child: Container(
                color: const Color(0xFF1E1E2E),
                width: 400,
                height: 300,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: [
                      FusionPieDataPoint(35, label: 'A', color: const Color(0xFF8B5CF6)),
                      FusionPieDataPoint(25, label: 'B', color: const Color(0xFF06B6D4)),
                      FusionPieDataPoint(20, label: 'C', color: const Color(0xFF10B981)),
                      FusionPieDataPoint(15, label: 'D', color: const Color(0xFFF59E0B)),
                      FusionPieDataPoint(5, label: 'E', color: const Color(0xFF6B7280)),
                    ],
                  ),
                  config: const FusionPieChartConfiguration(
                    theme: FusionDarkTheme(),
                    enableAnimation: false,
                    innerRadiusPercent: 0.5,
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(chartKey),
        matchesGoldenFile('goldens/dark_theme_pie_chart.png'),
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  // Sample data for tests
  final basicPieData = [
    FusionPieDataPoint(35, label: 'Sales', color: const Color(0xFF6366F1)),
    FusionPieDataPoint(25, label: 'Marketing', color: const Color(0xFF22C55E)),
    FusionPieDataPoint(
      20,
      label: 'Engineering',
      color: const Color(0xFFF59E0B),
    ),
    FusionPieDataPoint(20, label: 'Support', color: const Color(0xFFA855F7)),
  ];

  group('FusionPieChart Widget Tests', () {
    group('Basic Rendering', () {
      testWidgets('renders without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(FusionPieChart), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('renders with single data point', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: [FusionPieDataPoint(100, label: 'Total')],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with many data points', (tester) async {
        final manyPoints = List.generate(
          12,
          (i) => FusionPieDataPoint((i + 1) * 10.0, label: 'Segment ${i + 1}'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: manyPoints),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with title and subtitle', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  title: 'Revenue Distribution',
                  subtitle: 'Q4 2024',
                  series: FusionPieSeries(dataPoints: basicPieData),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Revenue Distribution'), findsOneWidget);
        expect(find.text('Q4 2024'), findsOneWidget);
      });
    });

    group('Donut Chart', () {
      testWidgets('renders donut chart with inner radius', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    innerRadiusPercent: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders donut with center label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    innerRadiusPercent: 0.5,
                  ),
                  config: const FusionPieChartConfiguration(
                    innerRadiusPercent: 0.5,
                    showCenterLabel: true,
                    centerLabelText: '\$2.4M',
                    centerSubLabelText: 'Total Revenue',
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('\$2.4M'), findsOneWidget);
        expect(find.text('Total Revenue'), findsOneWidget);
      });

      testWidgets('renders donut with custom center widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    innerRadiusPercent: 0.5,
                    centerWidget: const Icon(Icons.pie_chart, size: 48),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.pie_chart), findsOneWidget);
      });

      testWidgets('renders thin ring donut', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    innerRadiusPercent: 0.75,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Theming', () {
      testWidgets('renders with light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    theme: FusionLightTheme(),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: const Color(0xFF1E1E2E),
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    theme: FusionDarkTheme(),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Visual Features', () {
      testWidgets('renders with rounded corners', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    cornerRadius: 10.0,
                  ),
                  config: const FusionPieChartConfiguration(cornerRadius: 10.0),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with gaps between slices', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    gapBetweenSlices: 3.0,
                  ),
                  config: const FusionPieChartConfiguration(
                    gapBetweenSlices: 3.0,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with stroke/border', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    strokeWidth: 2.0,
                    strokeColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with exploded segments', (tester) async {
        final explodedData = [
          FusionPieDataPoint(
            35,
            label: 'Sales',
            color: Colors.blue,
            explode: true,
          ),
          FusionPieDataPoint(25, label: 'Marketing', color: Colors.green),
          FusionPieDataPoint(20, label: 'Engineering', color: Colors.orange),
          FusionPieDataPoint(20, label: 'Support', color: Colors.purple),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: explodedData,
                    explodeOffset: 15.0,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with all segments exploded', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    explodeAll: true,
                    explodeOffset: 10.0,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Labels', () {
      testWidgets('renders with inside labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    labelPosition: PieLabelPosition.inside,
                  ),
                  config: const FusionPieChartConfiguration(
                    labelPosition: PieLabelPosition.inside,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with outside labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    labelPosition: PieLabelPosition.outside,
                  ),
                  config: const FusionPieChartConfiguration(
                    labelPosition: PieLabelPosition.outside,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with no labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    showLabels: false,
                  ),
                  config: const FusionPieChartConfiguration(
                    labelPosition: PieLabelPosition.none,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with percentage labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    showPercentages: true,
                    labelPosition: PieLabelPosition.inside,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Legend', () {
      testWidgets('renders with legend on right', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 500,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableLegend: true,
                    legendPosition: LegendPosition.right,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
        // Legend items should be visible
        expect(find.text('Sales'), findsWidgets);
        expect(find.text('Marketing'), findsWidgets);
      });

      testWidgets('renders with legend on bottom', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 500,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableLegend: true,
                    legendPosition: LegendPosition.bottom,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders without legend', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableLegend: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('legend shows values and percentages', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 500,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableLegend: true,
                    legendPosition: LegendPosition.right,
                    showLegendValues: true,
                    showLegendPercentages: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Selection', () {
      testWidgets('single selection mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    selectionMode: PieSelectionMode.single,
                  ),
                  config: const FusionPieChartConfiguration(
                    selectionMode: PieSelectionMode.single,
                    enableSelection: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('multiple selection mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    selectionMode: PieSelectionMode.multiple,
                  ),
                  config: const FusionPieChartConfiguration(
                    selectionMode: PieSelectionMode.multiple,
                    enableSelection: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('selection disabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    selectionMode: PieSelectionMode.none,
                  ),
                  config: const FusionPieChartConfiguration(
                    enableSelection: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Animation', () {
      testWidgets('renders with animation enabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableAnimation: true,
                    animationDuration: Duration(milliseconds: 500),
                  ),
                ),
              ),
            ),
          ),
        );

        // Pump a few frames to see animation
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(FusionPieChart), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(FusionPieChart), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with animation disabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableAnimation: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Sorting and Grouping', () {
      testWidgets('renders with ascending sort', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    sortMode: PieSortMode.ascending,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with descending sort', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    sortMode: PieSortMode.descending,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with small segments grouped', (tester) async {
        final dataWithSmallSegments = [
          FusionPieDataPoint(50, label: 'Large'),
          FusionPieDataPoint(30, label: 'Medium'),
          FusionPieDataPoint(2, label: 'Tiny 1'),
          FusionPieDataPoint(1, label: 'Tiny 2'),
          FusionPieDataPoint(1, label: 'Tiny 3'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: dataWithSmallSegments,
                    groupSmallSegments: true,
                    groupThreshold: 5.0,
                    groupLabel: 'Other',
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Start Angle and Direction', () {
      testWidgets('renders with custom start angle', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    startAngle: 0, // 3 o'clock position
                  ),
                  config: const FusionPieChartConfiguration(startAngle: 0),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with counter-clockwise direction', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    direction: PieDirection.counterClockwise,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Tooltip', () {
      testWidgets('renders with tooltip enabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableTooltip: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with tooltip disabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableTooltip: false,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Color Palettes', () {
      testWidgets('renders with material palette', (tester) async {
        final dataWithoutColors = [
          FusionPieDataPoint(35, label: 'A'),
          FusionPieDataPoint(25, label: 'B'),
          FusionPieDataPoint(20, label: 'C'),
          FusionPieDataPoint(20, label: 'D'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: dataWithoutColors,
                    colorPalette: FusionColorPalette.material,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders with pastel palette', (tester) async {
        final dataWithoutColors = [
          FusionPieDataPoint(35, label: 'A'),
          FusionPieDataPoint(25, label: 'B'),
          FusionPieDataPoint(20, label: 'C'),
          FusionPieDataPoint(20, label: 'D'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: dataWithoutColors,
                    colorPalette: FusionColorPalette.pastel,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Responsive Sizing', () {
      testWidgets('renders correctly at small size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 150,
                height: 150,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  config: const FusionPieChartConfiguration(
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('renders correctly at large size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 800,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('handles resize gracefully', (tester) async {
        final sizeNotifier = ValueNotifier<Size>(const Size(400, 400));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<Size>(
                valueListenable: sizeNotifier,
                builder: (context, size, _) {
                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: FusionPieChart(
                      series: FusionPieSeries(dataPoints: basicPieData),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);

        // Resize
        sizeNotifier.value = const Size(300, 300);
        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);

        // Resize again
        sizeNotifier.value = const Size(500, 400);
        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Data Updates', () {
      testWidgets('handles data change', (tester) async {
        final dataNotifier = ValueNotifier<List<FusionPieDataPoint>>(
          basicPieData,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<List<FusionPieDataPoint>>(
                valueListenable: dataNotifier,
                builder: (context, data, _) {
                  return SizedBox(
                    width: 400,
                    height: 400,
                    child: FusionPieChart(
                      series: FusionPieSeries(dataPoints: data),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);

        // Update data
        dataNotifier.value = [
          FusionPieDataPoint(50, label: 'New A'),
          FusionPieDataPoint(30, label: 'New B'),
          FusionPieDataPoint(20, label: 'New C'),
        ];

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });

    group('Callbacks', () {
      testWidgets('onSegmentTap callback is set correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: basicPieData),
                  onSegmentTap: (index, series) {
                    // Callback is registered
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });

      testWidgets('onSelectionChanged callback is set correctly', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FusionPieChart(
                  series: FusionPieSeries(
                    dataPoints: basicPieData,
                    selectionMode: PieSelectionMode.single,
                  ),
                  config: const FusionPieChartConfiguration(
                    enableSelection: true,
                  ),
                  onSelectionChanged: (selection) {
                    // Callback is registered
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(FusionPieChart), findsOneWidget);
      });
    });
  });

  group('FusionPieSeries Unit Tests', () {
    test('calculates total correctly', () {
      final series = FusionPieSeries(dataPoints: basicPieData);
      expect(series.total, 100.0); // 35 + 25 + 20 + 20
    });

    test('isDonut returns correct value', () {
      final pie = FusionPieSeries(
        dataPoints: basicPieData,
        innerRadiusPercent: 0.0,
      );
      expect(pie.isDonut, false);

      final donut = FusionPieSeries(
        dataPoints: basicPieData,
        innerRadiusPercent: 0.5,
      );
      expect(donut.isDonut, true);
    });

    test('sliceCount returns correct count', () {
      final series = FusionPieSeries(dataPoints: basicPieData);
      expect(series.sliceCount, 4);
    });

    test('getColorForIndex respects color cascade', () {
      final dataWithMixedColors = [
        FusionPieDataPoint(35, label: 'A', color: Colors.red),
        FusionPieDataPoint(25, label: 'B'), // No color
        FusionPieDataPoint(20, label: 'C', color: Colors.blue),
        FusionPieDataPoint(20, label: 'D'), // No color
      ];

      final series = FusionPieSeries(
        dataPoints: dataWithMixedColors,
        colorPalette: FusionColorPalette.material,
      );

      expect(series.getColorForIndex(0), Colors.red);
      expect(series.getColorForIndex(2), Colors.blue);
      // Index 1 and 3 should get palette colors
    });

    test('getSortedDataPoints sorts correctly', () {
      final series = FusionPieSeries(
        dataPoints: [
          FusionPieDataPoint(20, label: 'Small'),
          FusionPieDataPoint(50, label: 'Large'),
          FusionPieDataPoint(30, label: 'Medium'),
        ],
        sortMode: PieSortMode.ascending,
      );

      final sorted = series.getSortedDataPoints();
      expect(sorted[0].value, 20);
      expect(sorted[1].value, 30);
      expect(sorted[2].value, 50);
    });

    test('getGroupedDataPoints groups small segments', () {
      final series = FusionPieSeries(
        dataPoints: [
          FusionPieDataPoint(60, label: 'Large'),
          FusionPieDataPoint(2, label: 'Tiny1'),
          FusionPieDataPoint(1, label: 'Tiny2'),
        ],
        groupSmallSegments: true,
        groupThreshold: 5.0,
        groupLabel: 'Other',
      );

      final grouped = series.getGroupedDataPoints();
      // Should have 2 segments: Large and Other
      expect(grouped.length, 2);
      expect(grouped.any((p) => p.label == 'Other'), true);
    });

    test('copyWith creates modified copy', () {
      final original = FusionPieSeries(
        dataPoints: basicPieData,
        name: 'Original',
        innerRadiusPercent: 0.0,
      );

      final copy = original.copyWith(name: 'Copy', innerRadiusPercent: 0.5);

      expect(copy.name, 'Copy');
      expect(copy.innerRadiusPercent, 0.5);
      expect(copy.dataPoints, basicPieData); // Unchanged
    });
  });

  group('FusionPieDataPoint Unit Tests', () {
    test('creates data point with required value', () {
      final point = FusionPieDataPoint(50);
      expect(point.value, 50);
      expect(point.label, null);
      expect(point.color, null);
    });

    test('creates data point with all properties', () {
      final point = FusionPieDataPoint(
        50,
        label: 'Test',
        color: Colors.blue,
        borderWidth: 2.0,
        cornerRadius: 8.0,
        explode: true,
      );

      expect(point.value, 50);
      expect(point.label, 'Test');
      expect(point.color, Colors.blue);
      expect(point.borderWidth, 2.0);
      expect(point.cornerRadius, 8.0);
      expect(point.explode, true);
    });

    test('copyWith creates modified copy', () {
      final original = FusionPieDataPoint(50, label: 'Original');
      final copy = original.copyWith(label: 'Modified', value: 75);

      expect(copy.value, 75);
      expect(copy.label, 'Modified');
    });

    test('equality works correctly', () {
      final point1 = FusionPieDataPoint(50, label: 'Test');
      final point2 = FusionPieDataPoint(50, label: 'Test');
      final point3 = FusionPieDataPoint(50, label: 'Different');

      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });

    test('hasBorder returns correct value', () {
      final withBorder = FusionPieDataPoint(
        50,
        borderWidth: 2.0,
        borderColor: Colors.white,
      );
      expect(withBorder.hasBorder, true);

      final withoutBorder = FusionPieDataPoint(50);
      expect(withoutBorder.hasBorder, false);

      final borderWidthOnly = FusionPieDataPoint(50, borderWidth: 2.0);
      expect(borderWidthOnly.hasBorder, false);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

/// Run this to capture screenshots for pub.dev
///
/// Usage:
/// 1. Run: flutter run -d chrome (or any device)
/// 2. Navigate to each tab
/// 3. Take screenshot (Command+Shift+4 on Mac, Snipping Tool on Windows)
/// 4. Save to: screenshots/
///
/// Recommended size: 640x480 or similar 4:3 ratio
void main() {
  runApp(const ScreenshotApp());
}

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fusion Charts - Screenshots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      ),
      home: const ScreenshotPages(),
    );
  }
}

class ScreenshotPages extends StatefulWidget {
  const ScreenshotPages({super.key});

  @override
  State<ScreenshotPages> createState() => _ScreenshotPagesState();
}

class _ScreenshotPagesState extends State<ScreenshotPages> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LineChartScreenshot(),
    BarChartScreenshot(),
    BarChartShowcase(),
  ];

  final List<String> _titles = [
    'Line Chart',
    'Bar Chart (Grouped)',
    'Bar Chart Showcase',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Line'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Bar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Showcase',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LINE CHART SCREENSHOT
// =============================================================================

class LineChartScreenshot extends StatelessWidget {
  const LineChartScreenshot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Monthly Revenue Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Product performance comparison 2024',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FusionLineChart(
              series: [
                FusionLineSeries(
                  name: 'Product A',
                  dataPoints: [
                    FusionDataPoint(0, 32, label: 'Jan'),
                    FusionDataPoint(1, 45, label: 'Feb'),
                    FusionDataPoint(2, 38, label: 'Mar'),
                    FusionDataPoint(3, 52, label: 'Apr'),
                    FusionDataPoint(4, 61, label: 'May'),
                    FusionDataPoint(5, 55, label: 'Jun'),
                    FusionDataPoint(6, 72, label: 'Jul'),
                    FusionDataPoint(7, 68, label: 'Aug'),
                  ],
                  color: const Color(0xFF6366F1),
                  lineWidth: 3.0,
                  isCurved: true,
                  smoothness: 0.35,
                  showArea: true,
                  areaOpacity: 0.15,
                  showMarkers: true,
                  markerSize: 6,
                  markerShape: MarkerShape.circle,
                ),
                FusionLineSeries(
                  name: 'Product B',
                  dataPoints: [
                    FusionDataPoint(0, 22, label: 'Jan'),
                    FusionDataPoint(1, 35, label: 'Feb'),
                    FusionDataPoint(2, 42, label: 'Mar'),
                    FusionDataPoint(3, 38, label: 'Apr'),
                    FusionDataPoint(4, 48, label: 'May'),
                    FusionDataPoint(5, 52, label: 'Jun'),
                    FusionDataPoint(6, 58, label: 'Jul'),
                    FusionDataPoint(7, 62, label: 'Aug'),
                  ],
                  color: const Color(0xFF10B981),
                  lineWidth: 3.0,
                  isCurved: true,
                  smoothness: 0.35,
                  showMarkers: true,
                  markerSize: 6,
                  markerShape: MarkerShape.diamond,
                ),
              ],
              config: const FusionLineChartConfiguration(
                enableAnimation: false,
                enableGrid: true,
                enableMarkers: true,
                enableTooltip: true,
                enableCrosshair: false,
                theme: FusionLightTheme(),
              ),
              xAxis: FusionAxisConfiguration(
                title: 'Month',
                labelFormatter: (value) {
                  const months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                  ];
                  final index = value.toInt();
                  if (index >= 0 && index < months.length) return months[index];
                  return '';
                },
              ),
              yAxis: FusionAxisConfiguration(
                title: 'Revenue (K)',
                labelFormatter: (value) => '\$${value.toInt()}K',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: const Color(0xFF6366F1), label: 'Product A'),
              const SizedBox(width: 24),
              _LegendItem(color: const Color(0xFF10B981), label: 'Product B'),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BAR CHART SCREENSHOT (Grouped)
// =============================================================================

class BarChartScreenshot extends StatelessWidget {
  const BarChartScreenshot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Quarterly Sales Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Year-over-year comparison',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FusionBarChart(
              series: [
                FusionBarSeries(
                  name: '2023',
                  dataPoints: [
                    FusionDataPoint(0, 65, label: 'Q1'),
                    FusionDataPoint(1, 78, label: 'Q2'),
                    FusionDataPoint(2, 72, label: 'Q3'),
                    FusionDataPoint(3, 85, label: 'Q4'),
                  ],
                  color: const Color(0xFF6366F1),
                  barWidth: 0.35,
                  borderRadius: 6.0,
                ),
                FusionBarSeries(
                  name: '2024',
                  dataPoints: [
                    FusionDataPoint(0, 82, label: 'Q1'),
                    FusionDataPoint(1, 95, label: 'Q2'),
                    FusionDataPoint(2, 88, label: 'Q3'),
                    FusionDataPoint(3, 105, label: 'Q4'),
                  ],
                  color: const Color(0xFF10B981),
                  barWidth: 0.35,
                  borderRadius: 6.0,
                ),
              ],
              config: const FusionChartConfiguration(
                enableAnimation: false,
                enableGrid: true,
                enableTooltip: true,
                enableCrosshair: false,
                theme: FusionLightTheme(),
              ),
              xAxis: FusionAxisConfiguration(
                title: 'Quarter',
                labelFormatter: (value) {
                  const quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
                  final index = value.toInt();
                  if (index >= 0 && index < quarters.length)
                    return quarters[index];
                  return '';
                },
              ),
              yAxis: FusionAxisConfiguration(
                title: 'Sales (M)',
                labelFormatter: (value) => '\$${value.toInt()}M',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: const Color(0xFF6366F1), label: '2023'),
              const SizedBox(width: 32),
              _LegendItem(color: const Color(0xFF10B981), label: '2024'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                label: 'Total 2023',
                value: '\$300M',
                color: const Color(0xFF6366F1),
              ),
              _StatCard(
                label: 'Total 2024',
                value: '\$370M',
                color: const Color(0xFF10B981),
              ),
              _StatCard(
                label: 'Growth',
                value: '+23%',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BAR CHART SHOWCASE - Demonstrates all new features
// =============================================================================

class BarChartShowcase extends StatelessWidget {
  const BarChartShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Grouped Bars
            _SectionTitle(
              title: '1. Grouped Bars',
              subtitle: 'Multiple series side-by-side',
            ),
            _ChartCard(
              child: SizedBox(
                height: 250,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Revenue',
                      dataPoints: [
                        FusionDataPoint(0, 45, label: 'Jan'),
                        FusionDataPoint(1, 62, label: 'Feb'),
                        FusionDataPoint(2, 55, label: 'Mar'),
                        FusionDataPoint(3, 78, label: 'Apr'),
                      ],
                      color: const Color(0xFF3B82F6),
                      barWidth: 0.4,
                      borderRadius: 4.0,
                    ),
                    FusionBarSeries(
                      name: 'Expenses',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: 'Jan'),
                        FusionDataPoint(1, 45, label: 'Feb'),
                        FusionDataPoint(2, 38, label: 'Mar'),
                        FusionDataPoint(3, 52, label: 'Apr'),
                      ],
                      color: const Color(0xFFEF4444),
                      barWidth: 0.4,
                      borderRadius: 4.0,
                    ),
                  ],
                  config: const FusionBarChartConfiguration(
                    enableAnimation: true,
                    enableSideBySideSeriesPlacement: true,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section 2: Overlapped Bars (Actual vs Target)
            _SectionTitle(
              title: '2. Overlapped Bars',
              subtitle: 'Actual vs Target comparison',
            ),
            _ChartCard(
              child: SizedBox(
                height: 250,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Target',
                      dataPoints: [
                        FusionDataPoint(0, 100, label: 'Q1'),
                        FusionDataPoint(1, 100, label: 'Q2'),
                        FusionDataPoint(2, 100, label: 'Q3'),
                        FusionDataPoint(3, 100, label: 'Q4'),
                      ],
                      color: const Color(0xFFE5E7EB),
                      barWidth: 0.6,
                      borderRadius: 6.0,
                    ),
                    FusionBarSeries(
                      name: 'Actual',
                      dataPoints: [
                        FusionDataPoint(0, 85, label: 'Q1'),
                        FusionDataPoint(1, 92, label: 'Q2'),
                        FusionDataPoint(2, 78, label: 'Q3'),
                        FusionDataPoint(3, 105, label: 'Q4'),
                      ],
                      color: const Color(0xFF10B981),
                      barWidth: 0.45,
                      borderRadius: 6.0,
                    ),
                  ],
                  config: const FusionBarChartConfiguration(
                    enableAnimation: true,
                    enableSideBySideSeriesPlacement: false, // Overlapped mode
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Track Bars (Progress)
            _SectionTitle(
              title: '3. Track Bars',
              subtitle: 'Progress visualization with background',
            ),
            _ChartCard(
              child: SizedBox(
                height: 250,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Completion',
                      dataPoints: [
                        FusionDataPoint(0, 75, label: 'Task A'),
                        FusionDataPoint(1, 90, label: 'Task B'),
                        FusionDataPoint(2, 45, label: 'Task C'),
                        FusionDataPoint(3, 100, label: 'Task D'),
                        FusionDataPoint(4, 60, label: 'Task E'),
                      ],
                      color: const Color(0xFF8B5CF6),
                      barWidth: 0.5,
                      borderRadius: 8.0,
                      isTrackVisible: true,
                      trackColor: const Color(0xFFE5E7EB),
                      trackBorderWidth: 0,
                    ),
                  ],
                  config: const FusionChartConfiguration(enableAnimation: true),
                  yAxis: FusionAxisConfiguration(
                    labelFormatter: (value) => '${value.toInt()}%',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section 4: Gradient Bars
            _SectionTitle(
              title: '4. Gradient Bars',
              subtitle: 'Beautiful gradient fills',
            ),
            _ChartCard(
              child: SizedBox(
                height: 250,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Performance',
                      dataPoints: [
                        FusionDataPoint(0, 65, label: 'Mon'),
                        FusionDataPoint(1, 85, label: 'Tue'),
                        FusionDataPoint(2, 72, label: 'Wed'),
                        FusionDataPoint(3, 90, label: 'Thu'),
                        FusionDataPoint(4, 78, label: 'Fri'),
                      ],
                      color: const Color(0xFF6366F1),
                      barWidth: 0.6,
                      borderRadius: 8.0,
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                      ),
                    ),
                  ],
                  config: const FusionChartConfiguration(enableAnimation: true),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section 5: Stacked Bar Chart
            _SectionTitle(
              title: '5. Stacked Bars',
              subtitle: 'Cumulative data visualization',
            ),
            _ChartCard(
              child: SizedBox(
                height: 280,
                child: FusionStackedBarChart(
                  series: [
                    FusionStackedBarSeries(
                      name: 'Product A',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: 'Q1'),
                        FusionDataPoint(1, 40, label: 'Q2'),
                        FusionDataPoint(2, 35, label: 'Q3'),
                        FusionDataPoint(3, 45, label: 'Q4'),
                      ],
                      color: const Color(0xFF3B82F6),
                      barWidth: 0.6,
                      borderRadius: 4.0,
                    ),
                    FusionStackedBarSeries(
                      name: 'Product B',
                      dataPoints: [
                        FusionDataPoint(0, 25, label: 'Q1'),
                        FusionDataPoint(1, 30, label: 'Q2'),
                        FusionDataPoint(2, 28, label: 'Q3'),
                        FusionDataPoint(3, 35, label: 'Q4'),
                      ],
                      color: const Color(0xFF10B981),
                      barWidth: 0.6,
                      borderRadius: 4.0,
                    ),
                    FusionStackedBarSeries(
                      name: 'Product C',
                      dataPoints: [
                        FusionDataPoint(0, 15, label: 'Q1'),
                        FusionDataPoint(1, 20, label: 'Q2'),
                        FusionDataPoint(2, 22, label: 'Q3'),
                        FusionDataPoint(3, 25, label: 'Q4'),
                      ],
                      color: const Color(0xFFF59E0B),
                      barWidth: 0.6,
                      borderRadius: 4.0,
                    ),
                  ],
                  config: const FusionChartConfiguration(enableAnimation: true),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section 6: 100% Stacked Bar Chart
            _SectionTitle(
              title: '6. 100% Stacked Bars',
              subtitle: 'Market share / percentage breakdown',
            ),
            _ChartCard(
              child: SizedBox(
                height: 280,
                child: FusionStackedBarChart(
                  series: [
                    FusionStackedBarSeries(
                      name: 'Desktop',
                      dataPoints: [
                        FusionDataPoint(0, 60, label: '2021'),
                        FusionDataPoint(1, 55, label: '2022'),
                        FusionDataPoint(2, 48, label: '2023'),
                        FusionDataPoint(3, 42, label: '2024'),
                      ],
                      color: const Color(0xFF6366F1),
                      barWidth: 0.6,
                    ),
                    FusionStackedBarSeries(
                      name: 'Mobile',
                      dataPoints: [
                        FusionDataPoint(0, 30, label: '2021'),
                        FusionDataPoint(1, 35, label: '2022'),
                        FusionDataPoint(2, 40, label: '2023'),
                        FusionDataPoint(3, 45, label: '2024'),
                      ],
                      color: const Color(0xFF10B981),
                      barWidth: 0.6,
                    ),
                    FusionStackedBarSeries(
                      name: 'Tablet',
                      dataPoints: [
                        FusionDataPoint(0, 10, label: '2021'),
                        FusionDataPoint(1, 10, label: '2022'),
                        FusionDataPoint(2, 12, label: '2023'),
                        FusionDataPoint(3, 13, label: '2024'),
                      ],
                      color: const Color(0xFFF59E0B),
                      barWidth: 0.6,
                    ),
                  ],
                  config: const FusionStackedBarChartConfiguration(
                    isStacked100: true,
                    enableAnimation: true,
                  ),
                  yAxis: FusionAxisConfiguration(
                    labelFormatter: (value) => '${value.toInt()}%',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section 7: Styled Bars with Borders
            _SectionTitle(
              title: '7. Styled Bars',
              subtitle: 'Custom borders and shadows',
            ),
            _ChartCard(
              child: SizedBox(
                height: 250,
                child: FusionBarChart(
                  series: [
                    FusionBarSeries(
                      name: 'Sales',
                      dataPoints: [
                        FusionDataPoint(0, 42, label: 'A'),
                        FusionDataPoint(1, 68, label: 'B'),
                        FusionDataPoint(2, 55, label: 'C'),
                        FusionDataPoint(3, 82, label: 'D'),
                      ],
                      color: const Color(0xFFDDD6FE),
                      barWidth: 0.5,
                      borderRadius: 10.0,
                      borderColor: const Color(0xFF7C3AED),
                      borderWidth: 2.0,
                      showShadow: true,
                      shadow: BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ),
                  ],
                  config: const FusionChartConfiguration(enableAnimation: true),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Feature summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ New Bar Chart Features',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeatureChip(label: 'Grouped Bars'),
                      _FeatureChip(label: 'Overlapped Bars'),
                      _FeatureChip(label: 'Track Background'),
                      _FeatureChip(label: 'Stacked Bars'),
                      _FeatureChip(label: '100% Stacked'),
                      _FeatureChip(label: 'Gradients'),
                      _FeatureChip(label: 'Borders'),
                      _FeatureChip(label: 'Shadows'),
                      _FeatureChip(label: 'Accurate Tooltips'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;

  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }
}

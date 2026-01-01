import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

// =============================================================================
// BAR CHART SHOWCASE - Complete API Reference
// =============================================================================

/// Comprehensive Bar Chart Showcase demonstrating all FusionBarChart capabilities.
class BarChartShowcase extends StatefulWidget {
  const BarChartShowcase({super.key});

  @override
  State<BarChartShowcase> createState() => _BarChartShowcaseState();
}

class _BarChartShowcaseState extends State<BarChartShowcase> {
  int _currentPage = 0;
  final _pageController = PageController();

  final List<_ShowcaseItem> _showcaseItems = [
    _ShowcaseItem(
      title: '1. Basic Bar Chart',
      description: 'Simple vertical bars with auto-spacing',
      code: '''
FusionBarChart(
  series: [
    FusionBarSeries(
      name: 'Sales',
      dataPoints: [
        FusionDataPoint(0, 65, label: 'Q1'),
        FusionDataPoint(1, 78, label: 'Q2'),
        FusionDataPoint(2, 82, label: 'Q3'),
        FusionDataPoint(3, 95, label: 'Q4'),
      ],
      color: Color(0xFF6366F1),
      barWidth: 0.6,
    ),
  ],
)''',
      builder: _buildBasicBarChart,
    ),
    _ShowcaseItem(
      title: '2. Grouped Bars',
      description: 'Multiple series side by side',
      code: '''
FusionBarChart(
  series: [
    FusionBarSeries(name: '2023', ...),
    FusionBarSeries(name: '2024', ...),
  ],
  config: FusionBarChartConfiguration(
    enableLegend: true,
  ),
)''',
      builder: _buildGroupedBars,
    ),
    _ShowcaseItem(
      title: '3. Stacked Bars',
      description: 'Series stacked on top of each other',
      code: '''
FusionStackedBarChart(
  series: [
    FusionStackedBarSeries(name: 'Product A', ...),
    FusionStackedBarSeries(name: 'Product B', ...),
    FusionStackedBarSeries(name: 'Product C', ...),
  ],
  config: FusionStackedBarChartConfiguration(
    enableLegend: true,
    barWidthRatio: 0.6,
  ),
)''',
      builder: _buildStackedBars,
    ),
    _ShowcaseItem(
      title: '4. Rounded Corners',
      description: 'Beautiful rounded bar edges',
      code: '''
FusionBarSeries(
  borderRadius: 12.0,  // All corners
)''',
      builder: _buildRoundedBars,
    ),
    _ShowcaseItem(
      title: '5. Gradient Bars',
      description: 'Vertical and horizontal gradients',
      code: '''
FusionBarSeries(
  gradient: LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
)''',
      builder: _buildGradientBars,
    ),
    _ShowcaseItem(
      title: '6. Borders & Shadows',
      description: 'Add depth with borders and shadows',
      code: '''
FusionBarSeries(
  borderColor: Color(0xFFD97706),
  borderWidth: 2.0,
  showShadow: true,
  shadow: BoxShadow(
    color: Colors.black26,
    blurRadius: 8,
    offset: Offset(0, 4),
  ),
)''',
      builder: _buildBorderedBars,
    ),
    _ShowcaseItem(
      title: '7. Selection Mode',
      description: 'Tap to select bars',
      code: '''
FusionBarChartConfiguration(
  enableSelection: true,
  enableTooltip: true,
)''',
      builder: _buildSelectableBars,
    ),
    _ShowcaseItem(
      title: '8. Negative Values',
      description: 'Bars extending below zero',
      code: '''
FusionBarSeries(
  dataPoints: [
    FusionDataPoint(0, 45, label: 'Q1'),
    FusionDataPoint(1, -20, label: 'Q2'),
    FusionDataPoint(2, 30, label: 'Q3'),
    FusionDataPoint(3, -15, label: 'Q4'),
  ],
)''',
      builder: _buildNegativeValueBars,
    ),
    _ShowcaseItem(
      title: '9. Data Labels',
      description: 'Show values on bars',
      code: '''
FusionBarSeries(
  showDataLabels: true,
  dataLabelFormatter: (value) => '\$\${value}K',
)''',
      builder: _buildDataLabelBars,
    ),
    _ShowcaseItem(
      title: '10. Dark Theme',
      description: 'Full dark theme support',
      code: '''
FusionBarChartConfiguration(
  theme: FusionDarkTheme(),
)''',
      builder: _buildDarkThemeBars,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bar Chart Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _currentPage > 0
                ? () => _goToPage(_currentPage - 1)
                : null,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1} / ${_showcaseItems.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentPage < _showcaseItems.length - 1
                ? () => _goToPage(_currentPage + 1)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showcaseItems[_currentPage].title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _showcaseItems[_currentPage].description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Chart
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _showcaseItems.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: _showcaseItems[index].builder(),
                );
              },
            ),
          ),
          // Code
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _showcaseItems[_currentPage].code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFFCDD6F4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseItem {
  final String title;
  final String description;
  final String code;
  final Widget Function() builder;

  _ShowcaseItem({
    required this.title,
    required this.description,
    required this.code,
    required this.builder,
  });
}

// =============================================================================
// SHOWCASE BUILDERS
// =============================================================================

Widget _buildBasicBarChart() {
  return FusionBarChart(
    series: [
      FusionBarSeries(
        name: 'Sales',
        dataPoints: [
          FusionDataPoint(0, 65, label: 'Q1'),
          FusionDataPoint(1, 78, label: 'Q2'),
          FusionDataPoint(2, 82, label: 'Q3'),
          FusionDataPoint(3, 95, label: 'Q4'),
        ],
        color: const Color(0xFF6366F1),
        barWidth: 0.6,
        borderRadius: 6.0,
      ),
    ],
    config: const FusionBarChartConfiguration(
      enableAnimation: true,
      animationDuration: Duration(milliseconds: 800),
    ),
  );
}

Widget _buildGroupedBars() {
  return FusionBarChart(
    series: [
      FusionBarSeries(
        name: '2023',
        dataPoints: [
          FusionDataPoint(0, 55, label: 'Q1'),
          FusionDataPoint(1, 62, label: 'Q2'),
          FusionDataPoint(2, 58, label: 'Q3'),
          FusionDataPoint(3, 70, label: 'Q4'),
        ],
        color: const Color(0xFF6366F1),
        barWidth: 0.35,
        borderRadius: 4.0,
      ),
      FusionBarSeries(
        name: '2024',
        dataPoints: [
          FusionDataPoint(0, 68, label: 'Q1'),
          FusionDataPoint(1, 75, label: 'Q2'),
          FusionDataPoint(2, 72, label: 'Q3'),
          FusionDataPoint(3, 88, label: 'Q4'),
        ],
        color: const Color(0xFF8B5CF6),
        barWidth: 0.35,
        borderRadius: 4.0,
      ),
    ],
    config: const FusionBarChartConfiguration(
      enableLegend: true,
      enableAnimation: true,
    ),
  );
}

Widget _buildStackedBars() {
  return FusionStackedBarChart(
    series: [
      FusionStackedBarSeries(
        name: 'Product A',
        dataPoints: [
          FusionDataPoint(0, 30, label: 'Q1'),
          FusionDataPoint(1, 35, label: 'Q2'),
          FusionDataPoint(2, 28, label: 'Q3'),
          FusionDataPoint(3, 40, label: 'Q4'),
        ],
        color: const Color(0xFF6366F1),
      ),
      FusionStackedBarSeries(
        name: 'Product B',
        dataPoints: [
          FusionDataPoint(0, 25, label: 'Q1'),
          FusionDataPoint(1, 30, label: 'Q2'),
          FusionDataPoint(2, 35, label: 'Q3'),
          FusionDataPoint(3, 28, label: 'Q4'),
        ],
        color: const Color(0xFF22C55E),
      ),
      FusionStackedBarSeries(
        name: 'Product C',
        dataPoints: [
          FusionDataPoint(0, 20, label: 'Q1'),
          FusionDataPoint(1, 18, label: 'Q2'),
          FusionDataPoint(2, 22, label: 'Q3'),
          FusionDataPoint(3, 25, label: 'Q4'),
        ],
        color: const Color(0xFFF59E0B),
      ),
    ],
    config: const FusionStackedBarChartConfiguration(
      enableLegend: true,
      enableAnimation: true,
      barWidthRatio: 0.6,
      borderRadius: 4.0,
    ),
  );
}

Widget _buildRoundedBars() {
  return Column(
    children: [
      Expanded(
        child: FusionBarChart(
          title: 'Fully Rounded (radius: 12)',
          series: [
            FusionBarSeries(
              name: 'Rounded',
              dataPoints: [
                FusionDataPoint(0, 60, label: 'A'),
                FusionDataPoint(1, 75, label: 'B'),
                FusionDataPoint(2, 55, label: 'C'),
                FusionDataPoint(3, 85, label: 'D'),
              ],
              color: const Color(0xFF10B981),
              barWidth: 0.5,
              borderRadius: 12.0,
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionBarChart(
          title: 'Pill Shape (radius: 50)',
          series: [
            FusionBarSeries(
              name: 'Pill',
              dataPoints: [
                FusionDataPoint(0, 60, label: 'A'),
                FusionDataPoint(1, 75, label: 'B'),
                FusionDataPoint(2, 55, label: 'C'),
                FusionDataPoint(3, 85, label: 'D'),
              ],
              color: const Color(0xFFEC4899),
              barWidth: 0.4,
              borderRadius: 50.0,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildGradientBars() {
  return FusionBarChart(
    series: [
      FusionBarSeries(
        name: 'Gradient',
        dataPoints: [
          FusionDataPoint(0, 65, label: 'Q1'),
          FusionDataPoint(1, 78, label: 'Q2'),
          FusionDataPoint(2, 72, label: 'Q3'),
          FusionDataPoint(3, 90, label: 'Q4'),
        ],
        color: const Color(0xFF8B5CF6),
        barWidth: 0.6,
        borderRadius: 8.0,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ],
  );
}

Widget _buildBorderedBars() {
  return Column(
    children: [
      Expanded(
        child: FusionBarChart(
          title: 'With Borders',
          series: [
            FusionBarSeries(
              name: 'Bordered',
              dataPoints: [
                FusionDataPoint(0, 55, label: 'A'),
                FusionDataPoint(1, 70, label: 'B'),
                FusionDataPoint(2, 60, label: 'C'),
                FusionDataPoint(3, 85, label: 'D'),
              ],
              color: const Color(0xFFFEF3C7),
              barWidth: 0.6,
              borderRadius: 8.0,
              borderColor: const Color(0xFFD97706),
              borderWidth: 2.0,
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionBarChart(
          title: 'With Shadows',
          series: [
            FusionBarSeries(
              name: 'Shadowed',
              dataPoints: [
                FusionDataPoint(0, 55, label: 'A'),
                FusionDataPoint(1, 70, label: 'B'),
                FusionDataPoint(2, 60, label: 'C'),
                FusionDataPoint(3, 85, label: 'D'),
              ],
              color: const Color(0xFF6366F1),
              barWidth: 0.6,
              borderRadius: 8.0,
              showShadow: true,
              shadow: const BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildSelectableBars() {
  return FusionBarChart(
    title: 'Tap bars to select',
    series: [
      FusionBarSeries(
        name: 'Revenue',
        dataPoints: [
          FusionDataPoint(0, 65, label: 'Jan'),
          FusionDataPoint(1, 78, label: 'Feb'),
          FusionDataPoint(2, 72, label: 'Mar'),
          FusionDataPoint(3, 90, label: 'Apr'),
          FusionDataPoint(4, 85, label: 'May'),
          FusionDataPoint(5, 95, label: 'Jun'),
        ],
        color: const Color(0xFF3B82F6),
        barWidth: 0.6,
        borderRadius: 6.0,
      ),
    ],
    config: const FusionBarChartConfiguration(
      enableSelection: true,
      enableTooltip: true,
    ),
  );
}

Widget _buildNegativeValueBars() {
  return FusionBarChart(
    title: 'Profit/Loss by Quarter',
    series: [
      FusionBarSeries(
        name: 'Profit/Loss',
        dataPoints: [
          FusionDataPoint(0, 45, label: 'Q1'),
          FusionDataPoint(1, -20, label: 'Q2'),
          FusionDataPoint(2, 30, label: 'Q3'),
          FusionDataPoint(3, -15, label: 'Q4'),
          FusionDataPoint(4, 55, label: 'Q5'),
          FusionDataPoint(5, -8, label: 'Q6'),
        ],
        color: const Color(0xFF10B981),
        barWidth: 0.6,
        borderRadius: 4.0,
      ),
    ],
    config: const FusionBarChartConfiguration(enableAnimation: true),
  );
}

Widget _buildDataLabelBars() {
  return FusionBarChart(
    series: [
      FusionBarSeries(
        name: 'Revenue',
        dataPoints: [
          FusionDataPoint(0, 65, label: 'Q1'),
          FusionDataPoint(1, 78, label: 'Q2'),
          FusionDataPoint(2, 82, label: 'Q3'),
          FusionDataPoint(3, 95, label: 'Q4'),
        ],
        color: const Color(0xFF8B5CF6),
        barWidth: 0.6,
        borderRadius: 6.0,
        showDataLabels: true,
        dataLabelFormatter: (value) => '\$${value.toStringAsFixed(0)}K',
      ),
    ],
    config: const FusionBarChartConfiguration(enableDataLabels: true),
  );
}

Widget _buildDarkThemeBars() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E2E),
      borderRadius: BorderRadius.circular(12),
    ),
    child: FusionBarChart(
      title: 'Dark Theme Analytics',
      series: [
        FusionBarSeries(
          name: 'Revenue',
          dataPoints: [
            FusionDataPoint(0, 65, label: 'Q1'),
            FusionDataPoint(1, 78, label: 'Q2'),
            FusionDataPoint(2, 72, label: 'Q3'),
            FusionDataPoint(3, 90, label: 'Q4'),
          ],
          color: const Color(0xFF8B5CF6),
          barWidth: 0.6,
          borderRadius: 6.0,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
      config: const FusionBarChartConfiguration(
        theme: FusionDarkTheme(),
        enableAnimation: true,
      ),
    ),
  );
}

// =============================================================================
// STANDALONE MAIN
// =============================================================================

void main() {
  runApp(
    const MaterialApp(
      title: 'Bar Chart Showcase',
      debugShowCheckedModeBanner: false,
      home: BarChartShowcase(),
    ),
  );
}

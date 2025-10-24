// example/lib/main.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  runApp(const FusionChartsShowcaseApp());
}

class FusionChartsShowcaseApp extends StatelessWidget {
  const FusionChartsShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fusion Charts - Complete Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const ShowcaseHomePage(),
    );
  }
}

class ShowcaseHomePage extends StatefulWidget {
  const ShowcaseHomePage({super.key});

  @override
  State<ShowcaseHomePage> createState() => _ShowcaseHomePageState();
}

class _ShowcaseHomePageState extends State<ShowcaseHomePage> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<ShowcaseCategory> _categories = [
    ShowcaseCategory(
      name: '🎨 Themes & Styles',
      icon: Icons.palette,
      examples: [
        ShowcaseExample(
          title: 'Light Theme',
          description: 'Clean and professional light theme',
          builder: (context) => const LightThemeExample(),
        ),
        ShowcaseExample(
          title: 'Dark Theme',
          description: 'Elegant dark theme for modern apps',
          builder: (context) => const DarkThemeExample(),
        ),
        ShowcaseExample(
          title: 'Custom Colors',
          description: 'Beautiful custom color palettes',
          builder: (context) => const CustomColorsExample(),
        ),
        ShowcaseExample(
          title: 'Gradient Lines',
          description: 'Stunning gradient effects',
          builder: (context) => const GradientLinesExample(),
        ),
      ],
    ),
    ShowcaseCategory(
      name: '📊 Line Charts',
      icon: Icons.show_chart,
      examples: [
        ShowcaseExample(
          title: 'Simple Line',
          description: 'Basic line chart with single series',
          builder: (context) => const SimpleLineExample(),
        ),
        ShowcaseExample(
          title: 'Multi-Series',
          description: 'Multiple lines with different colors',
          builder: (context) => const MultiSeriesLineExample(),
        ),
        ShowcaseExample(
          title: 'Smooth Curves',
          description: 'Bezier curves with custom smoothness',
          builder: (context) => const SmoothCurvesExample(),
        ),
        ShowcaseExample(
          title: 'Area Fill',
          description: 'Line charts with filled areas',
          builder: (context) => const AreaFillExample(),
        ),
        ShowcaseExample(
          title: 'Step Line',
          description: 'Step interpolation for discrete data',
          builder: (context) => const StepLineExample(),
        ),
        // ShowcaseExample(
        //   title: 'Dashed Lines',
        //   description: 'Dashed and dotted line styles',
        //   builder: (context) => const DashedLinesExample(),
        // ),
      ],
    ),
    ShowcaseCategory(
      name: '📊 Bar Charts',
      icon: Icons.bar_chart,
      examples: [
        ShowcaseExample(
          title: 'Vertical Bars',
          description: 'Classic column chart',
          builder: (context) => const VerticalBarsExample(),
        ),
        ShowcaseExample(
          title: 'Horizontal Bars',
          description: 'Bar chart with horizontal orientation',
          builder: (context) => const HorizontalBarsExample(),
        ),
        ShowcaseExample(
          title: 'Grouped Bars',
          description: 'Multiple series side by side',
          builder: (context) => const GroupedBarsExample(),
        ),
        ShowcaseExample(
          title: 'Stacked Bars',
          description: 'Stacked bar chart for totals',
          builder: (context) => const StackedBarsExample(),
        ),
        ShowcaseExample(
          title: 'Rounded Corners',
          description: 'Beautiful rounded bar edges',
          builder: (context) => const RoundedBarsExample(),
        ),
      ],
    ),
    ShowcaseCategory(
      name: '🎯 Markers & Labels',
      icon: Icons.scatter_plot,
      examples: [
        ShowcaseExample(
          title: 'Marker Shapes',
          description: 'Circle, square, diamond, triangle, star',
          builder: (context) => const MarkerShapesExample(),
        ),
        ShowcaseExample(
          title: 'Data Labels',
          description: 'Show values on data points',
          builder: (context) => const DataLabelsExample(),
        ),
        ShowcaseExample(
          title: 'Custom Markers',
          description: 'Custom styled markers',
          builder: (context) => const CustomMarkersExample(),
        ),
      ],
    ),
    ShowcaseCategory(
      name: '🎮 Interactions',
      icon: Icons.touch_app,
      examples: [
        ShowcaseExample(
          title: 'Tooltips',
          description: 'Interactive tooltips on hover',
          builder: (context) => const TooltipsExample(),
        ),
        ShowcaseExample(
          title: 'Crosshair',
          description: 'Crosshair indicator for precision',
          builder: (context) => const CrosshairExample(),
        ),
        ShowcaseExample(
          title: 'Zoom & Pan',
          description: 'Pinch to zoom and pan to explore',
          builder: (context) => const ZoomPanExample(),
        ),
        ShowcaseExample(
          title: 'Selection',
          description: 'Select data points with tap',
          builder: (context) => const SelectionExample(),
        ),
        ShowcaseExample(
          title: 'Live Data',
          description: 'Real-time updating charts',
          builder: (context) => const LiveDataExample(),
        ),
      ],
    ),
    ShowcaseCategory(
      name: '⚡ Performance',
      icon: Icons.speed,
      examples: [
        ShowcaseExample(
          title: '1K Data Points',
          description: 'Smooth rendering with 1,000 points',
          builder: (context) => const Performance1KExample(),
        ),
        ShowcaseExample(
          title: '10K Data Points',
          description: 'Optimized for 10,000 points',
          builder: (context) => const Performance10KExample(),
        ),
        ShowcaseExample(
          title: 'LTTB Downsampling',
          description: 'Largest-Triangle-Three-Buckets algorithm',
          builder: (context) => const LTTBExample(),
        ),
      ],
    ),
    ShowcaseCategory(
      name: '🎭 Real-World Examples',
      icon: Icons.cases,
      examples: [
        ShowcaseExample(
          title: '💰 Crypto Dashboard',
          description: 'Bitcoin price tracker with trends',
          builder: (context) => const CryptoDashboardExample(),
        ),
        ShowcaseExample(
          title: '📈 Stock Market',
          description: 'Financial chart with candlesticks',
          builder: (context) => const StockMarketExample(),
        ),
        ShowcaseExample(
          title: '❤️ Health Monitor',
          description: 'Heart rate and activity tracking',
          builder: (context) => const HealthMonitorExample(),
        ),
        ShowcaseExample(
          title: '🌡️ Weather Forecast',
          description: 'Temperature and precipitation',
          builder: (context) => const WeatherForecastExample(),
        ),
        ShowcaseExample(
          title: '📊 Sales Analytics',
          description: 'Revenue trends and comparisons',
          builder: (context) => const SalesAnalyticsExample(),
        ),
        ShowcaseExample(
          title: '⚡ Energy Usage',
          description: 'Power consumption over time',
          builder: (context) => const EnergyUsageExample(),
        ),
      ],
    ),
    ShowcaseCategory(
      name: '🔬 Edge Cases',
      icon: Icons.science,
      examples: [
        ShowcaseExample(
          title: 'Empty Data',
          description: 'Graceful handling of no data',
          builder: (context) => const EmptyDataExample(),
        ),
        ShowcaseExample(
          title: 'Single Point',
          description: 'Chart with only one data point',
          builder: (context) => const SinglePointExample(),
        ),
        ShowcaseExample(
          title: 'Negative Values',
          description: 'Charts with negative data',
          builder: (context) => const NegativeValuesExample(),
        ),
        ShowcaseExample(
          title: 'Large Numbers',
          description: 'Billions and scientific notation',
          builder: (context) => const LargeNumbersExample(),
        ),
        ShowcaseExample(
          title: 'Tiny Numbers',
          description: 'Handling very small values',
          builder: (context) => const TinyNumbersExample(),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fusion Charts Showcase'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() => _isDarkMode = !_isDarkMode);
            },
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.selected,
            destinations: _categories.map((category) {
              return NavigationRailDestination(
                icon: Icon(category.icon),
                selectedIcon: Icon(category.icon),
                label: Text(category.name),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // Content area
          Expanded(child: _buildCategoryContent()),
        ],
      ),
    );
  }

  Widget _buildCategoryContent() {
    final category = _categories[_selectedIndex];

    return CustomScrollView(
      slivers: [
        // Category header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(category.icon, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${category.examples.length} examples',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Examples grid
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 600,
              childAspectRatio: 1.2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final example = category.examples[index];
              return _buildExampleCard(example);
            }, childCount: category.examples.length),
          ),
        ),
      ],
    );
  }

  Widget _buildExampleCard(ShowcaseExample example) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExampleDetailPage(example: example)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(padding: const EdgeInsets.all(16), child: example.builder(context)),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    example.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    example.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fusion Charts Flutter'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional Flutter Charting Library',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('✨ Features:'),
              SizedBox(height: 8),
              Text('• Layer-based rendering pipeline'),
              Text('• Object pooling for 60 FPS'),
              Text('• LTTB downsampling for 10K+ points'),
              Text('• Shader caching (100x faster gradients)'),
              Text('• Zero-copy coordinate transforms'),
              Text('• SOLID architecture principles'),
              SizedBox(height: 16),
              Text('🎨 Chart Types:'),
              SizedBox(height: 8),
              Text('• Line Charts (smooth, stepped, area)'),
              Text('• Bar Charts (vertical, horizontal, grouped)'),
              Text('• Multiple series support'),
              SizedBox(height: 16),
              Text('⚡ Performance:'),
              SizedBox(height: 8),
              Text('• 60 FPS with 10,000+ data points'),
              Text('• Smart downsampling with LTTB'),
              Text('• Efficient memory management'),
              SizedBox(height: 16),
              Text('Built with ❤️ using Flutter'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}

// =============================================================================
// EXAMPLE DETAIL PAGE
// =============================================================================

class ExampleDetailPage extends StatelessWidget {
  final ShowcaseExample example;

  const ExampleDetailPage({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(example.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              // TODO: Show source code
            },
            tooltip: 'View source',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: example.builder(context),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(example.description, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DATA MODELS
// =============================================================================

class ShowcaseCategory {
  final String name;
  final IconData icon;
  final List<ShowcaseExample> examples;

  ShowcaseCategory({required this.name, required this.icon, required this.examples});
}

class ShowcaseExample {
  final String title;
  final String description;
  final Widget Function(BuildContext) builder;

  ShowcaseExample({required this.title, required this.description, required this.builder});
}

// =============================================================================
// EXAMPLE IMPLEMENTATIONS - THEMES & STYLES
// =============================================================================

class LightThemeExample extends StatelessWidget {
  const LightThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Revenue',
            dataPoints: _generateSampleData(20, min: 10, max: 100),
            color: const Color(0xFF3498DB),
            lineWidth: 3,
            showMarkers: true,
            markerSize: 6,
          ),
        ],
        config: const FusionChartConfiguration(
          enableAnimation: true,
          enableTooltip: true,
          enableGrid: true,
        ),
        xAxis: const FusionAxisConfiguration(title: 'Time', showGrid: true),
        yAxis: const FusionAxisConfiguration(title: 'Value', showGrid: true),
      ),
    );
  }
}

class DarkThemeExample extends StatelessWidget {
  const DarkThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Users',
            dataPoints: _generateSampleData(20, min: 50, max: 200),
            color: const Color(0xFF00D9FF),
            lineWidth: 3,
            showMarkers: true,
            markerSize: 6,
            showArea: true,
            areaOpacity: 0.2,
          ),
        ],
        config: FusionChartConfiguration(
          theme: FusionDarkTheme(),
          enableAnimation: true,
          enableTooltip: true,
        ),
      ),
    );
  }
}

class CustomColorsExample extends StatelessWidget {
  const CustomColorsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Product A',
            dataPoints: _generateSampleData(15, min: 30, max: 90),
            color: const Color(0xFFE74C3C),
            lineWidth: 3,
          ),
          FusionLineSeries(
            name: 'Product B',
            dataPoints: _generateSampleData(15, min: 40, max: 80),
            color: const Color(0xFF9B59B6),
            lineWidth: 3,
          ),
          FusionLineSeries(
            name: 'Product C',
            dataPoints: _generateSampleData(15, min: 20, max: 70),
            color: const Color(0xFFF39C12),
            lineWidth: 3,
          ),
        ],
        config: const FusionChartConfiguration(enableLegend: true, enableGrid: true),
      ),
    );
  }
}

class GradientLinesExample extends StatelessWidget {
  const GradientLinesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Gradient Line',
            dataPoints: _generateSampleData(20, min: 20, max: 100),
            color: const Color(0xFF667EEA),
            lineWidth: 4,
            showArea: true,
            areaOpacity: 0.3,
            gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
          ),
        ],
        config: const FusionChartConfiguration(enableAnimation: true),
      ),
    );
  }
}

// =============================================================================
// LINE CHART EXAMPLES
// =============================================================================

class SimpleLineExample extends StatelessWidget {
  const SimpleLineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Sales',
            dataPoints: [
              FusionDataPoint(0, 30),
              FusionDataPoint(1, 45),
              FusionDataPoint(2, 40),
              FusionDataPoint(3, 55),
              FusionDataPoint(4, 50),
              FusionDataPoint(5, 70),
              FusionDataPoint(6, 65),
            ],
            color: const Color(0xFF2ECC71),
            lineWidth: 3,
          ),
        ],
      ),
    );
  }
}

class MultiSeriesLineExample extends StatelessWidget {
  const MultiSeriesLineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Series 1',
            dataPoints: _generateSampleData(15, min: 30, max: 80),
            color: Colors.blue,
            lineWidth: 2.5,
          ),
          FusionLineSeries(
            name: 'Series 2',
            dataPoints: _generateSampleData(15, min: 40, max: 90),
            color: Colors.red,
            lineWidth: 2.5,
          ),
          FusionLineSeries(
            name: 'Series 3',
            dataPoints: _generateSampleData(15, min: 20, max: 70),
            color: Colors.green,
            lineWidth: 2.5,
          ),
        ],
        config: const FusionChartConfiguration(enableLegend: true),
      ),
    );
  }
}

class SmoothCurvesExample extends StatelessWidget {
  const SmoothCurvesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Smooth Curve',
            dataPoints: _generateSampleData(12, min: 20, max: 100),
            color: const Color(0xFF8E44AD),
            lineWidth: 3,
            smoothness: 0.4,
            showMarkers: true,
            markerSize: 6,
          ),
        ],
      ),
    );
  }
}

class AreaFillExample extends StatelessWidget {
  const AreaFillExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Area Chart',
            dataPoints: _generateSampleData(20, min: 30, max: 90),
            color: const Color(0xFF16A085),
            lineWidth: 2,
            showArea: true,
            areaOpacity: 0.3,
          ),
        ],
      ),
    );
  }
}

class StepLineExample extends StatelessWidget {
  const StepLineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Step Line',
            dataPoints: [
              FusionDataPoint(0, 20),
              FusionDataPoint(1, 20),
              FusionDataPoint(2, 40),
              FusionDataPoint(3, 40),
              FusionDataPoint(4, 60),
              FusionDataPoint(5, 60),
              FusionDataPoint(6, 80),
            ],
            color: const Color(0xFFE67E22),
            lineWidth: 2.5,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BAR CHART EXAMPLES
// =============================================================================

class VerticalBarsExample extends StatelessWidget {
  const VerticalBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            color: const Color(0xFF3498DB),
            barWidth: 0.6,
          ),
        ],
      ),
    );
  }
}

class HorizontalBarsExample extends StatelessWidget {
  const HorizontalBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionBarChart(
        series: [
          FusionBarSeries(
            name: 'Categories',
            dataPoints: [
              FusionDataPoint(0, 45, label: 'Electronics'),
              FusionDataPoint(1, 65, label: 'Clothing'),
              FusionDataPoint(2, 55, label: 'Food'),
              FusionDataPoint(3, 75, label: 'Books'),
            ],
            color: const Color(0xFF1ABC9C),
            barWidth: 0.7,
          ),
        ],
      ),
    );
  }
}

class GroupedBarsExample extends StatelessWidget {
  const GroupedBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionBarChart(
        series: [
          FusionBarSeries(
            name: '2023',
            dataPoints: [
              FusionDataPoint(0, 55),
              FusionDataPoint(1, 62),
              FusionDataPoint(2, 58),
              FusionDataPoint(3, 70),
            ],
            color: Colors.blue,
            barWidth: 0.35,
          ),
          FusionBarSeries(
            name: '2024',
            dataPoints: [
              FusionDataPoint(0, 68),
              FusionDataPoint(1, 75),
              FusionDataPoint(2, 72),
              FusionDataPoint(3, 88),
            ],
            color: Colors.green,
            barWidth: 0.35,
          ),
        ],
        config: const FusionChartConfiguration(enableLegend: true),
      ),
    );
  }
}

class StackedBarsExample extends StatelessWidget {
  const StackedBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionBarChart(
        series: [
          FusionBarSeries(
            name: 'Product A',
            dataPoints: [
              FusionDataPoint(0, 30),
              FusionDataPoint(1, 40),
              FusionDataPoint(2, 35),
              FusionDataPoint(3, 45),
            ],
            color: const Color(0xFFE74C3C),
            barWidth: 0.6,
          ),
          FusionBarSeries(
            name: 'Product B',
            dataPoints: [
              FusionDataPoint(0, 25),
              FusionDataPoint(1, 30),
              FusionDataPoint(2, 28),
              FusionDataPoint(3, 35),
            ],
            color: const Color(0xFF3498DB),
            barWidth: 0.6,
          ),
          FusionBarSeries(
            name: 'Product C',
            dataPoints: [
              FusionDataPoint(0, 20),
              FusionDataPoint(1, 25),
              FusionDataPoint(2, 22),
              FusionDataPoint(3, 30),
            ],
            color: const Color(0xFF2ECC71),
            barWidth: 0.6,
          ),
        ],
        config: const FusionChartConfiguration(enableLegend: true),
      ),
    );
  }
}

class RoundedBarsExample extends StatelessWidget {
  const RoundedBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionBarChart(
        series: [
          FusionBarSeries(
            name: 'Rounded Bars',
            dataPoints: [
              FusionDataPoint(0, 45),
              FusionDataPoint(1, 65),
              FusionDataPoint(2, 55),
              FusionDataPoint(3, 75),
              FusionDataPoint(4, 60),
            ],
            color: const Color(0xFF9B59B6),
            barWidth: 0.5,
            borderRadius: 8.0,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MARKERS & LABELS EXAMPLES
// =============================================================================

class MarkerShapesExample extends StatelessWidget {
  const MarkerShapesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Circle',
            dataPoints: _generateSampleData(8, min: 70, max: 90),
            color: Colors.red,
            showMarkers: true,
            markerShape: MarkerShape.circle,
            markerSize: 8,
          ),
          FusionLineSeries(
            name: 'Square',
            dataPoints: _generateSampleData(8, min: 50, max: 70),
            color: Colors.blue,
            showMarkers: true,
            markerShape: MarkerShape.square,
            markerSize: 8,
          ),
          FusionLineSeries(
            name: 'Diamond',
            dataPoints: _generateSampleData(8, min: 30, max: 50),
            color: Colors.green,
            showMarkers: true,
            markerShape: MarkerShape.diamond,
            markerSize: 8,
          ),
          FusionLineSeries(
            name: 'Triangle',
            dataPoints: _generateSampleData(8, min: 10, max: 30),
            color: Colors.orange,
            showMarkers: true,
            markerShape: MarkerShape.triangle,
            markerSize: 8,
          ),
        ],
        config: const FusionChartConfiguration(enableLegend: true, enableMarkers: true),
      ),
    );
  }
}

class DataLabelsExample extends StatelessWidget {
  const DataLabelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionBarChart(
        series: [
          FusionBarSeries(
            name: 'Revenue',
            dataPoints: [
              FusionDataPoint(0, 45, label: '\$45K'),
              FusionDataPoint(1, 62, label: '\$62K'),
              FusionDataPoint(2, 58, label: '\$58K'),
              FusionDataPoint(3, 78, label: '\$78K'),
            ],
            color: const Color(0xFF27AE60),
            barWidth: 0.6,
          ),
        ],
        config: const FusionChartConfiguration(enableDataLabels: true),
      ),
    );
  }
}

class CustomMarkersExample extends StatelessWidget {
  const CustomMarkersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Custom',
            dataPoints: _generateSampleData(12, min: 30, max: 80),
            color: const Color(0xFFE67E22),
            lineWidth: 3,
            showMarkers: true,
            markerSize: 10,
            markerShape: MarkerShape.x,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INTERACTION EXAMPLES
// =============================================================================

class TooltipsExample extends StatelessWidget {
  const TooltipsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Sales',
            dataPoints: _generateSampleData(15, min: 40, max: 90),
            color: const Color(0xFF3498DB),
            lineWidth: 3,
            showMarkers: true,
          ),
        ],
        config: const FusionChartConfiguration(
          enableTooltip: true,
          tooltipBehavior: FusionTooltipBehavior(
            enable: true,
            elevation: 8,
            opacity: 0.9,
            canShowMarker: true,
          ),
        ),
      ),
    );
  }
}

class CrosshairExample extends StatelessWidget {
  const CrosshairExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Data',
            dataPoints: _generateSampleData(20, min: 30, max: 80),
            color: const Color(0xFF8E44AD),
            lineWidth: 2.5,
          ),
        ],
        config: const FusionChartConfiguration(enableCrosshair: true, enableTooltip: true),
      ),
    );
  }
}

class ZoomPanExample extends StatelessWidget {
  const ZoomPanExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Zoom & Pan',
            dataPoints: _generateSampleData(50, min: 20, max: 100),
            color: const Color(0xFF16A085),
            lineWidth: 2,
          ),
        ],
        config: const FusionChartConfiguration(
          enableZoom: true,
          enablePanning: true,
          enableTooltip: true,
        ),
      ),
    );
  }
}

class SelectionExample extends StatefulWidget {
  const SelectionExample({super.key});

  @override
  State<SelectionExample> createState() => _SelectionExampleState();
}

class _SelectionExampleState extends State<SelectionExample> {
  FusionDataPoint? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: FusionLineChart(
            series: [
              FusionLineSeries(
                name: 'Selectable',
                dataPoints: _generateSampleData(12, min: 30, max: 80),
                color: const Color(0xFFE74C3C),
                lineWidth: 3,
                showMarkers: true,
                markerSize: 8,
              ),
            ],
            config: const FusionChartConfiguration(enableSelection: true),
            // onBarTap: (point, seriesName) {
            //   setState(() => _selectedPoint = point);
            // },
          ),
        ),
        if (_selectedPoint != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected: X=${_selectedPoint!.x.toStringAsFixed(0)}, Y=${_selectedPoint!.y.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}

class LiveDataExample extends StatefulWidget {
  const LiveDataExample({super.key});

  @override
  State<LiveDataExample> createState() => _LiveDataExampleState();
}

class _LiveDataExampleState extends State<LiveDataExample> {
  final List<FusionDataPoint> _data = [];
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _data.addAll(_generateSampleData(20, min: 40, max: 80));

    // Simulate live data updates
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _data.add(FusionDataPoint(_counter.toDouble(), 40 + math.Random().nextDouble() * 40));
          _counter++;

          // Keep only last 20 points
          if (_data.length > 20) {
            _data.removeAt(0);
            // Adjust X values
            for (int i = 0; i < _data.length; i++) {
              _data[i] = FusionDataPoint(i.toDouble(), _data[i].y);
            }
          }
        });
      }
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Live Data',
            dataPoints: _data,
            color: const Color(0xFF00D9FF),
            lineWidth: 2.5,
            showArea: true,
            areaOpacity: 0.2,
          ),
        ],
        config: const FusionChartConfiguration(
          enableAnimation: false, // Disable for smoother updates
        ),
      ),
    );
  }
}

// =============================================================================
// PERFORMANCE EXAMPLES
// =============================================================================

class Performance1KExample extends StatelessWidget {
  const Performance1KExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: '1K Points',
            dataPoints: _generateSampleData(1000, min: 20, max: 100),
            color: const Color(0xFF2ECC71),
            lineWidth: 2,
          ),
        ],
        config: const FusionChartConfiguration(enableAnimation: true, enableTooltip: true),
      ),
    );
  }
}

class Performance10KExample extends StatelessWidget {
  const Performance10KExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: '10K Points',
            dataPoints: _generateSampleData(10000, min: 30, max: 90),
            color: const Color(0xFFE67E22),
            lineWidth: 1.5,
          ),
        ],
        config: const FusionChartConfiguration(
          enableAnimation: false, // Better performance
          enableTooltip: false,
        ),
      ),
    );
  }
}

class LTTBExample extends StatelessWidget {
  const LTTBExample({super.key});

  @override
  Widget build(BuildContext context) {
    final largeDataset = _generateSampleData(5000, min: 20, max: 100);
    const downsampler = LTTBDownsampler();
    final downsampled = downsampler.downsample(data: largeDataset, targetPoints: 200);

    return Column(
      children: [
        Text(
          'Original: ${largeDataset.length} → Downsampled: ${downsampled.length}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: FusionLineChart(
            series: [
              FusionLineSeries(
                name: 'Downsampled',
                dataPoints: downsampled,
                color: const Color(0xFF9B59B6),
                lineWidth: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// REAL-WORLD EXAMPLES
// =============================================================================

class CryptoDashboardExample extends StatefulWidget {
  const CryptoDashboardExample({super.key});

  @override
  State<CryptoDashboardExample> createState() => _CryptoDashboardExampleState();
}

class _CryptoDashboardExampleState extends State<CryptoDashboardExample> {
  final List<FusionDataPoint> _btcData = [];

  @override
  void initState() {
    super.initState();
    // Generate Bitcoin-like price data
    double price = 45000;
    for (int i = 0; i < 30; i++) {
      price += (math.Random().nextDouble() - 0.5) * 2000;
      _btcData.add(FusionDataPoint(i.toDouble(), price));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrice = _btcData.last.y;
    final dayChange = currentPrice - _btcData.first.y;
    final dayChangePercent = (dayChange / _btcData.first.y) * 100;
    final isPositive = dayChange >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1E3A8A), const Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '₿ Bitcoin',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${dayChangePercent.toStringAsFixed(2)}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: FusionLineChart(
              series: [
                FusionLineSeries(
                  name: 'BTC/USD',
                  dataPoints: _btcData,
                  color: const Color(0xFFF7931A),
                  lineWidth: 2,
                  showArea: true,
                  areaOpacity: 0.2,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF7931A), Colors.transparent],
                  ),
                ),
              ],
              config: FusionChartConfiguration(
                theme: FusionDarkTheme(),
                enableTooltip: true,
                enableCrosshair: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StockMarketExample extends StatelessWidget {
  const StockMarketExample({super.key});

  @override
  Widget build(BuildContext context) {
    final data = _generateStockData(40);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('AAPL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(
                '\$${data.last.y.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: FusionLineChart(
            series: [
              FusionLineSeries(
                name: 'Price',
                dataPoints: data,
                color: const Color(0xFF0071E3),
                lineWidth: 2.5,
                smoothness: 0.3,
              ),
            ],
            config: const FusionChartConfiguration(
              enableTooltip: true,
              enableCrosshair: true,
              enableZoom: true,
              enablePanning: true,
            ),
          ),
        ),
      ],
    );
  }

  List<FusionDataPoint> _generateStockData(int count) {
    final data = <FusionDataPoint>[];
    double price = 150;

    for (int i = 0; i < count; i++) {
      price += (math.Random().nextDouble() - 0.48) * 5;
      data.add(FusionDataPoint(i.toDouble(), price));
    }

    return data;
  }
}

class HealthMonitorExample extends StatefulWidget {
  const HealthMonitorExample({super.key});

  @override
  State<HealthMonitorExample> createState() => _HealthMonitorExampleState();
}

class _HealthMonitorExampleState extends State<HealthMonitorExample> {
  final List<FusionDataPoint> _heartRateData = [];
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Generate heart rate pattern
    for (int i = 0; i < 50; i++) {
      _heartRateData.add(
        FusionDataPoint(
          i.toDouble(),
          70 + math.sin(i * 0.3) * 10 + (math.Random().nextDouble() - 0.5) * 5,
        ),
      );
    }

    // Simulate live heart rate
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _heartRateData.add(
            FusionDataPoint(
              _counter.toDouble(),
              70 + math.sin(_counter * 0.3) * 10 + (math.Random().nextDouble() - 0.5) * 5,
            ),
          );
          _counter++;

          if (_heartRateData.length > 50) {
            _heartRateData.removeAt(0);
            for (int i = 0; i < _heartRateData.length; i++) {
              _heartRateData[i] = FusionDataPoint(i.toDouble(), _heartRateData[i].y);
            }
          }
        });
      }
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avgHeartRate = _heartRateData.isEmpty
        ? 0
        : _heartRateData.map((p) => p.y).reduce((a, b) => a + b) / _heartRateData.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red[700], size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Heart Rate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${avgHeartRate.toStringAsFixed(0)} BPM',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: FusionLineChart(
              series: [
                FusionLineSeries(
                  name: 'Heart Rate',
                  dataPoints: _heartRateData,
                  color: Colors.red,
                  lineWidth: 2.5,
                  showArea: true,
                  areaOpacity: 0.15,
                ),
              ],
              config: const FusionChartConfiguration(enableAnimation: false, enableGrid: true),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherForecastExample extends StatelessWidget {
  const WeatherForecastExample({super.key});

  @override
  Widget build(BuildContext context) {
    final tempData = _generateWeatherData(7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                '7-Day Forecast',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: FusionLineChart(
              series: [
                FusionLineSeries(
                  name: 'Temperature',
                  dataPoints: tempData,
                  color: Colors.white,
                  lineWidth: 3,
                  showMarkers: true,
                  markerSize: 8,
                  showArea: true,
                  areaOpacity: 0.2,
                ),
              ],
              config: FusionChartConfiguration(theme: FusionDarkTheme(), enableTooltip: true),
              xAxis: FusionAxisConfiguration(
                labelFormatter: (value) {
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return days[value.toInt() % 7];
                },
              ),
              yAxis: FusionAxisConfiguration(labelFormatter: (value) => '${value.toInt()}°C'),
            ),
          ),
        ],
      ),
    );
  }

  List<FusionDataPoint> _generateWeatherData(int days) {
    final data = <FusionDataPoint>[];
    for (int i = 0; i < days; i++) {
      data.add(
        FusionDataPoint(
          i.toDouble(),
          18 + math.sin(i * 0.8) * 6 + (math.Random().nextDouble() - 0.5) * 3,
        ),
      );
    }
    return data;
  }
}

class SalesAnalyticsExample extends StatelessWidget {
  const SalesAnalyticsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionBarChart(
        series: [
          FusionBarSeries(
            name: 'Online',
            dataPoints: [
              FusionDataPoint(0, 45),
              FusionDataPoint(1, 52),
              FusionDataPoint(2, 48),
              FusionDataPoint(3, 65),
              FusionDataPoint(4, 58),
              FusionDataPoint(5, 72),
            ],
            color: const Color(0xFF3498DB),
            barWidth: 0.35,
          ),
          FusionBarSeries(
            name: 'Retail',
            dataPoints: [
              FusionDataPoint(0, 35),
              FusionDataPoint(1, 42),
              FusionDataPoint(2, 38),
              FusionDataPoint(3, 48),
              FusionDataPoint(4, 45),
              FusionDataPoint(5, 55),
            ],
            color: const Color(0xFF2ECC71),
            barWidth: 0.35,
          ),
        ],
        config: const FusionChartConfiguration(enableLegend: true, enableTooltip: true),
        xAxis: FusionAxisConfiguration(
          labelFormatter: (value) {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
            return months[value.toInt() % 6];
          },
        ),
        yAxis: FusionAxisConfiguration(title: 'Revenue (\$K)'),
      ),
    );
  }
}

class EnergyUsageExample extends StatelessWidget {
  const EnergyUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    final data = _generateEnergyData(24);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.green[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Energy Usage (24h)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: FusionLineChart(
              series: [
                FusionLineSeries(
                  name: 'Power (kW)',
                  dataPoints: data,
                  color: Colors.green,
                  lineWidth: 2.5,
                  showArea: true,
                  areaOpacity: 0.3,
                ),
              ],
              xAxis: FusionAxisConfiguration(labelFormatter: (value) => '${value.toInt()}:00'),
              yAxis: FusionAxisConfiguration(labelFormatter: (value) => '${value.toInt()}kW'),
            ),
          ),
        ],
      ),
    );
  }

  List<FusionDataPoint> _generateEnergyData(int hours) {
    final data = <FusionDataPoint>[];
    for (int i = 0; i < hours; i++) {
      // Simulate daily energy pattern (low at night, high during day)
      final baseUsage = 20 + math.sin((i - 6) * math.pi / 12) * 15;
      final noise = (math.Random().nextDouble() - 0.5) * 5;
      data.add(FusionDataPoint(i.toDouble(), baseUsage + noise));
    }
    return data;
  }
}

// =============================================================================
// EDGE CASE EXAMPLES
// =============================================================================

class EmptyDataExample extends StatelessWidget {
  const EmptyDataExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('Chart handles empty data gracefully', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class SinglePointExample extends StatelessWidget {
  const SinglePointExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Single Point',
            dataPoints: [FusionDataPoint(5, 50, label: 'Only Point')],
            color: const Color(0xFFE74C3C),
            lineWidth: 3,
            showMarkers: true,
            markerSize: 12,
          ),
        ],
        config: const FusionChartConfiguration(enableDataLabels: true),
      ),
    );
  }
}

class NegativeValuesExample extends StatelessWidget {
  const NegativeValuesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Profit/Loss',
            dataPoints: [
              FusionDataPoint(0, 20),
              FusionDataPoint(1, 15),
              FusionDataPoint(2, -5),
              FusionDataPoint(3, -15),
              FusionDataPoint(4, -10),
              FusionDataPoint(5, 5),
              FusionDataPoint(6, 25),
              FusionDataPoint(7, 30),
            ],
            color: const Color(0xFF3498DB),
            lineWidth: 3,
            showMarkers: true,
            markerSize: 6,
          ),
        ],
        yAxis: FusionAxisConfiguration(
          title: 'Value',
          labelFormatter: (value) => value >= 0 ? '+\$${value.toInt()}' : '-\$${(-value).toInt()}',
        ),
      ),
    );
  }
}

class LargeNumbersExample extends StatelessWidget {
  const LargeNumbersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Big Numbers',
            dataPoints: [
              FusionDataPoint(0, 1.2e9),
              FusionDataPoint(1, 1.5e9),
              FusionDataPoint(2, 1.8e9),
              FusionDataPoint(3, 2.1e9),
              FusionDataPoint(4, 2.5e9),
              FusionDataPoint(5, 3.0e9),
            ],
            color: const Color(0xFF9B59B6),
            lineWidth: 3,
            showMarkers: true,
          ),
        ],
        yAxis: FusionAxisConfiguration(
          labelFormatter: (value) => FusionDataFormatter.formatLargeNumber(value),
        ),
      ),
    );
  }
}

class TinyNumbersExample extends StatelessWidget {
  const TinyNumbersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Tiny Numbers',
            dataPoints: [
              FusionDataPoint(0, 0.00012),
              FusionDataPoint(1, 0.00015),
              FusionDataPoint(2, 0.00018),
              FusionDataPoint(3, 0.00022),
              FusionDataPoint(4, 0.00025),
              FusionDataPoint(5, 0.00030),
            ],
            color: const Color(0xFF16A085),
            lineWidth: 3,
            showMarkers: true,
          ),
        ],
        yAxis: FusionAxisConfiguration(labelFormatter: (value) => value.toStringAsExponential(2)),
      ),
    );
  }
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

List<FusionDataPoint> _generateSampleData(
  int count, {
  double min = 0,
  double max = 100,
  double? seed,
}) {
  final random = seed != null ? math.Random(seed.toInt()) : math.Random();
  final data = <FusionDataPoint>[];

  for (int i = 0; i < count; i++) {
    final value = min + random.nextDouble() * (max - min);
    data.add(FusionDataPoint(i.toDouble(), value));
  }

  return data;
}

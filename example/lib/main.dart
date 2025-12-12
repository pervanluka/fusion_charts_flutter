// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  runApp(const FusionChartsShowcaseApp());
}

// =============================================================================
// MAIN APP
// =============================================================================

class FusionChartsShowcaseApp extends StatelessWidget {
  const FusionChartsShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fusion Charts Flutter - Showcase Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const ShowcaseGalleryHome(),
    );
  }
}

// =============================================================================
// GALLERY HOME
// =============================================================================

class ShowcaseGalleryHome extends StatelessWidget {
  const ShowcaseGalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fusion Charts Flutter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Professional Charting Library', style: TextStyle(fontSize: 12)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              // Toggle theme (would need theme provider in real app)
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          ...categories.map((category) => _buildCategory(context, category)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_graph, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feature Showcase',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Explore all features with interactive examples'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge('📊 Line & Bar Charts'),
                _buildBadge('🎨 Themes & Styles'),
                _buildBadge('🎯 Markers & Labels'),
                _buildBadge('🎮 Interactive'),
                _buildBadge('⚡ High Performance'),
                _buildBadge('📱 Responsive'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildCategory(BuildContext context, ShowcaseCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(category.icon, size: 28, color: const Color(0xFF6366F1)),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: category.examples.length,
          itemBuilder: (context, index) {
            final example = category.examples[index];
            return _buildExampleCard(context, example);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExampleCard(BuildContext context, ShowcaseExample example) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(padding: const EdgeInsets.all(8), child: example.builder(context)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    example.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    example.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      appBar: AppBar(title: Text(example.title), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(example.description, style: const TextStyle(fontSize: 16))],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(height: 400, child: example.builder(context)),
              ),
            ),
          ],
        ),
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
// SHOWCASE CATEGORIES & EXAMPLES
// =============================================================================

final List<ShowcaseCategory> categories = [
  ShowcaseCategory(
    name: '📈 Line Charts',
    icon: Icons.show_chart,
    examples: [
      ShowcaseExample(
        title: 'Basic Line Chart',
        description: 'Simple line chart with single series',
        builder: (context) => const BasicLineChartExample(),
      ),
      ShowcaseExample(
        title: 'Multi-Series Lines',
        description: 'Multiple lines on the same chart',
        builder: (context) => const MultiSeriesLineExample(),
      ),
      ShowcaseExample(
        title: 'Curved Lines',
        description: 'Smooth Catmull-Rom curves',
        builder: (context) => const CurvedLineExample(),
      ),
      ShowcaseExample(
        title: 'Area Chart',
        description: 'Filled area beneath line',
        builder: (context) => const AreaChartExample(),
      ),
      ShowcaseExample(
        title: 'Gradient Lines',
        description: 'Beautiful gradient effects',
        builder: (context) => const GradientLineExample(),
      ),
      ShowcaseExample(
        title: 'Line with Markers',
        description: 'Data points highlighted',
        builder: (context) => const LineWithMarkersExample(),
      ),
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
        title: 'Grouped Bars',
        description: 'Multiple series side by side',
        builder: (context) => const GroupedBarsExample(),
      ),
      ShowcaseExample(
        title: 'Rounded Corners',
        description: 'Beautiful rounded bar edges',
        builder: (context) => const RoundedBarsExample(),
      ),
      ShowcaseExample(
        title: 'Bar with Borders',
        description: 'Bars with custom borders',
        builder: (context) => const BorderedBarsExample(),
      ),
      ShowcaseExample(
        title: 'Gradient Bars',
        description: 'Gradient fill on bars',
        builder: (context) => const GradientBarsExample(),
      ),
      ShowcaseExample(
        title: 'Bar with Shadows',
        description: 'Depth with shadow effects',
        builder: (context) => const ShadowBarsExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '🎯 Markers & Labels',
    icon: Icons.scatter_plot,
    examples: [
      ShowcaseExample(
        title: 'Marker Shapes',
        description: 'Circle, square, diamond, triangle',
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
        description: 'Interactive tooltips on tap',
        builder: (context) => const TooltipsExample(),
      ),
      ShowcaseExample(
        title: 'Crosshair',
        description: 'Crosshair indicator for precision',
        builder: (context) => const CrosshairExample(),
      ),
      ShowcaseExample(
        title: 'Interactive Chart',
        description: 'Full interactivity enabled',
        builder: (context) => const InteractiveChartExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '🎨 Themes & Styles',
    icon: Icons.palette,
    examples: [
      ShowcaseExample(
        title: 'Light Theme',
        description: 'Default light theme',
        builder: (context) => const LightThemeExample(),
      ),
      ShowcaseExample(
        title: 'Dark Theme',
        description: 'Beautiful dark mode',
        builder: (context) => const DarkThemeExample(),
      ),
      ShowcaseExample(
        title: 'Custom Colors',
        description: 'Personalized color schemes',
        builder: (context) => const CustomColorsExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '⚙️ Axis Configuration',
    icon: Icons.settings,
    examples: [
      ShowcaseExample(
        title: 'Numeric Axis',
        description: 'Auto-calculated intervals',
        builder: (context) => const NumericAxisExample(),
      ),
      ShowcaseExample(
        title: 'Category Axis',
        description: 'Named categories',
        builder: (context) => const CategoryAxisExample(),
      ),
      ShowcaseExample(
        title: 'Custom Labels',
        description: 'Formatted axis labels',
        builder: (context) => const CustomLabelsExample(),
      ),
      ShowcaseExample(
        title: 'Grid Customization',
        description: 'Custom grid lines',
        builder: (context) => const GridCustomizationExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '⚡ Performance',
    icon: Icons.speed,
    examples: [
      ShowcaseExample(
        title: 'Large Dataset',
        description: '1000+ data points',
        builder: (context) => const LargeDatasetExample(),
      ),
      ShowcaseExample(
        title: 'Real-time Updates',
        description: 'Live data streaming',
        builder: (context) => const RealTimeExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '✨ Animations',
    icon: Icons.animation,
    examples: [
      ShowcaseExample(
        title: 'Animated Entry',
        description: 'Smooth chart entrance',
        builder: (context) => const AnimatedEntryExample(),
      ),
      ShowcaseExample(
        title: 'Custom Animation',
        description: 'Custom animation curves',
        builder: (context) => const CustomAnimationExample(),
      ),
    ],
  ),
];

// =============================================================================
// LINE CHART EXAMPLES
// =============================================================================

class BasicLineChartExample extends StatelessWidget {
  const BasicLineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
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
        enableAnimation: true,
        enableGrid: true,
        enableMarkers: false,
      ),
    );
  }
}

class MultiSeriesLineExample extends StatelessWidget {
  const MultiSeriesLineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Product A',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 45),
            FusionDataPoint(2, 35),
            FusionDataPoint(3, 60),
            FusionDataPoint(4, 50),
            FusionDataPoint(5, 75),
          ],
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
        ),
        FusionLineSeries(
          name: 'Product B',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(1, 35),
            FusionDataPoint(2, 45),
            FusionDataPoint(3, 40),
            FusionDataPoint(4, 65),
            FusionDataPoint(5, 55),
          ],
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
        ),
        FusionLineSeries(
          name: 'Product C',
          dataPoints: [
            FusionDataPoint(0, 15),
            FusionDataPoint(1, 25),
            FusionDataPoint(2, 30),
            FusionDataPoint(3, 35),
            FusionDataPoint(4, 45),
            FusionDataPoint(5, 50),
          ],
          color: const Color(0xFF10B981),
          lineWidth: 2.5,
        ),
      ],
      config: const FusionChartConfiguration(
        enableAnimation: true,
        enableLegend: true,
        enableCrosshair: false,
        tooltipBehavior: FusionTooltipBehavior(
          trackballMode: FusionTooltipTrackballMode.magnetic,
          shared: true,
        ),
      ),
    );
  }
}

class CurvedLineExample extends StatelessWidget {
  const CurvedLineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Smooth Curve',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(1, 45),
            FusionDataPoint(2, 30),
            FusionDataPoint(3, 65),
            FusionDataPoint(4, 50),
            FusionDataPoint(5, 80),
          ],
          color: const Color(0xFFEC4899),
          lineWidth: 3.0,
          isCurved: true,
          smoothness: 0.4,
        ),
      ],
    );
  }
}

class AreaChartExample extends StatelessWidget {
  const AreaChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Area Data',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 50),
            FusionDataPoint(2, 40),
            FusionDataPoint(3, 70),
            FusionDataPoint(4, 55),
            FusionDataPoint(5, 85),
          ],
          color: const Color(0xFF3B82F6),
          lineWidth: 2.5,
          showArea: true,
          areaOpacity: 0.3,
          isCurved: true,
        ),
      ],
    );
  }
}

class GradientLineExample extends StatelessWidget {
  const GradientLineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Gradient Line',
          dataPoints: [
            FusionDataPoint(0, 25),
            FusionDataPoint(1, 55),
            FusionDataPoint(2, 45),
            FusionDataPoint(3, 75),
            FusionDataPoint(4, 60),
            FusionDataPoint(5, 90),
          ],
          color: const Color(0xFF8B5CF6),
          lineWidth: 3.0,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          showArea: true,
          areaOpacity: 0.2,
        ),
      ],
    );
  }
}

class LineWithMarkersExample extends StatelessWidget {
  const LineWithMarkersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'With Markers',
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
          showMarkers: true,
          markerSize: 8.0,
          markerShape: MarkerShape.circle,
        ),
      ],
      config: const FusionLineChartConfiguration(enableMarkers: true),
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
          color: const Color(0xFF3B82F6),
          barWidth: 0.6,
        ),
      ],
    );
  }
}

class GroupedBarsExample extends StatelessWidget {
  const GroupedBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: '2023',
          dataPoints: [
            FusionDataPoint(0, 55),
            FusionDataPoint(1, 62),
            FusionDataPoint(2, 58),
            FusionDataPoint(3, 70),
          ],
          color: const Color(0xFF6366F1),
          barWidth: 0.4,
        ),
        FusionBarSeries(
          name: '2024',
          dataPoints: [
            FusionDataPoint(0, 65),
            FusionDataPoint(1, 75),
            FusionDataPoint(2, 70),
            FusionDataPoint(3, 85),
          ],
          color: const Color(0xFF8B5CF6),
          barWidth: 0.4,
        ),
      ],
    );
  }
}

class RoundedBarsExample extends StatelessWidget {
  const RoundedBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Rounded',
          dataPoints: [
            FusionDataPoint(0, 60),
            FusionDataPoint(1, 75),
            FusionDataPoint(2, 65),
            FusionDataPoint(3, 90),
          ],
          color: const Color(0xFF10B981),
          barWidth: 0.6,
          borderRadius: 12.0,
        ),
      ],
    );
  }
}

class BorderedBarsExample extends StatelessWidget {
  const BorderedBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Bordered',
          dataPoints: [
            FusionDataPoint(0, 55),
            FusionDataPoint(1, 70),
            FusionDataPoint(2, 60),
            FusionDataPoint(3, 85),
          ],
          color: const Color(0xFFF59E0B),
          barWidth: 0.6,
          borderRadius: 8.0,
          borderColor: const Color(0xFFD97706),
          borderWidth: 2.0,
        ),
      ],
    );
  }
}

class GradientBarsExample extends StatelessWidget {
  const GradientBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Gradient',
          dataPoints: [
            FusionDataPoint(0, 60),
            FusionDataPoint(1, 75),
            FusionDataPoint(2, 65),
            FusionDataPoint(3, 90),
          ],
          color: const Color(0xFF8B5CF6),
          barWidth: 0.6,
          borderRadius: 10.0,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }
}

class ShadowBarsExample extends StatelessWidget {
  const ShadowBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Shadowed',
          dataPoints: [
            FusionDataPoint(0, 55),
            FusionDataPoint(1, 70),
            FusionDataPoint(2, 60),
            FusionDataPoint(3, 85),
          ],
          color: const Color(0xFF6366F1),
          barWidth: 0.6,
          borderRadius: 8.0,
          showShadow: true,
          shadow: const BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 4)),
        ),
      ],
    );
  }
}

// =============================================================================
// MARKER & LABEL EXAMPLES
// =============================================================================

class MarkerShapesExample extends StatelessWidget {
  const MarkerShapesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Circle',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 45),
            FusionDataPoint(2, 35),
            FusionDataPoint(3, 60),
          ],
          color: const Color(0xFF6366F1),
          showMarkers: true,
          markerShape: MarkerShape.circle,
          markerSize: 8.0,
        ),
        FusionLineSeries(
          name: 'Square',
          dataPoints: [
            FusionDataPoint(0, 25),
            FusionDataPoint(1, 40),
            FusionDataPoint(2, 50),
            FusionDataPoint(3, 45),
          ],
          color: const Color(0xFF8B5CF6),
          showMarkers: true,
          markerShape: MarkerShape.square,
          markerSize: 8.0,
        ),
        FusionLineSeries(
          name: 'Diamond',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(1, 35),
            FusionDataPoint(2, 45),
            FusionDataPoint(3, 40),
          ],
          color: const Color(0xFF10B981),
          showMarkers: true,
          markerShape: MarkerShape.diamond,
          markerSize: 8.0,
        ),
      ],
      config: const FusionLineChartConfiguration(enableMarkers: true, enableLegend: true),
    );
  }
}

class DataLabelsExample extends StatelessWidget {
  const DataLabelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'With Labels',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 50),
            FusionDataPoint(2, 40),
            FusionDataPoint(3, 65),
          ],
          color: const Color(0xFF6366F1),
          showDataLabels: true,
          dataLabelFormatter: (value) => '\$${value.toStringAsFixed(0)}',
        ),
      ],
      config: const FusionChartConfiguration(enableDataLabels: true),
    );
  }
}

class CustomMarkersExample extends StatelessWidget {
  const CustomMarkersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Custom Style',
          dataPoints: [
            FusionDataPoint(0, 35),
            FusionDataPoint(1, 55),
            FusionDataPoint(2, 45),
            FusionDataPoint(3, 70),
          ],
          color: const Color(0xFFEC4899),
          lineWidth: 3.0,
          showMarkers: true,
          markerSize: 10.0,
          markerShape: MarkerShape.diamond,
        ),
      ],
      config: const FusionLineChartConfiguration(enableMarkers: true),
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
    return FusionLineChart(
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
      config: const FusionChartConfiguration(enableTooltip: true, enableCrosshair: false),
    );
  }
}

class CrosshairExample extends StatelessWidget {
  const CrosshairExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Data',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 50),
            FusionDataPoint(2, 40),
            FusionDataPoint(3, 65),
            FusionDataPoint(4, 55),
            FusionDataPoint(5, 80),
          ],
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
        ),
      ],
      config: const FusionChartConfiguration(enableCrosshair: true, enableTooltip: true),
    );
  }
}

class InteractiveChartExample extends StatelessWidget {
  const InteractiveChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Interactive',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 50),
            FusionDataPoint(2, 40),
            FusionDataPoint(3, 65),
            FusionDataPoint(4, 55),
            FusionDataPoint(5, 80),
          ],
          color: const Color(0xFF10B981),
          lineWidth: 2.5,
          showMarkers: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableTooltip: true,
        enableCrosshair: true,
        enableSelection: true,
      ),
    );
  }
}

// =============================================================================
// THEME EXAMPLES
// =============================================================================

class LightThemeExample extends StatelessWidget {
  const LightThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Light Theme',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 50),
            FusionDataPoint(2, 40),
            FusionDataPoint(3, 65),
          ],
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
        ),
      ],
      config: const FusionChartConfiguration(theme: FusionLightTheme()),
    );
  }
}

class DarkThemeExample extends StatelessWidget {
  const DarkThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F2937),
      child: FusionLineChart(
        series: [
          FusionLineSeries(
            name: 'Dark Theme',
            dataPoints: [
              FusionDataPoint(0, 30),
              FusionDataPoint(1, 50),
              FusionDataPoint(2, 40),
              FusionDataPoint(3, 65),
            ],
            color: const Color(0xFF8B5CF6),
            lineWidth: 2.5,
          ),
        ],
        config: const FusionChartConfiguration(theme: FusionDarkTheme()),
      ),
    );
  }
}

class CustomColorsExample extends StatelessWidget {
  const CustomColorsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Custom 1',
          dataPoints: [
            FusionDataPoint(0, 25),
            FusionDataPoint(1, 40),
            FusionDataPoint(2, 35),
            FusionDataPoint(3, 55),
          ],
          color: const Color(0xFFFF6B6B),
          lineWidth: 2.5,
        ),
        FusionLineSeries(
          name: 'Custom 2',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(1, 35),
            FusionDataPoint(2, 45),
            FusionDataPoint(3, 40),
          ],
          color: const Color(0xFF4ECDC4),
          lineWidth: 2.5,
        ),
        FusionLineSeries(
          name: 'Custom 3',
          dataPoints: [
            FusionDataPoint(0, 15),
            FusionDataPoint(1, 25),
            FusionDataPoint(2, 30),
            FusionDataPoint(3, 35),
          ],
          color: const Color(0xFFFFE66D),
          lineWidth: 2.5,
        ),
      ],
      config: const FusionChartConfiguration(enableLegend: true),
    );
  }
}

// =============================================================================
// AXIS CONFIGURATION EXAMPLES
// =============================================================================

class NumericAxisExample extends StatelessWidget {
  const NumericAxisExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Numeric',
          dataPoints: [
            FusionDataPoint(0, 120),
            FusionDataPoint(1, 250),
            FusionDataPoint(2, 180),
            FusionDataPoint(3, 320),
          ],
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
        ),
      ],
      yAxis: FusionAxisConfiguration(title: 'Value', showGrid: true, showTicks: true),
    );
  }
}

class CategoryAxisExample extends StatelessWidget {
  const CategoryAxisExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Sales',
          dataPoints: [
            FusionDataPoint(0, 65, label: 'Jan'),
            FusionDataPoint(1, 78, label: 'Feb'),
            FusionDataPoint(2, 82, label: 'Mar'),
            FusionDataPoint(3, 95, label: 'Apr'),
          ],
          color: const Color(0xFF3B82F6),
          barWidth: 0.6,
        ),
      ],
      xAxis: FusionAxisConfiguration(title: 'Month'),
    );
  }
}

class CustomLabelsExample extends StatelessWidget {
  const CustomLabelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Revenue',
          dataPoints: [
            FusionDataPoint(0, 1200),
            FusionDataPoint(1, 2500),
            FusionDataPoint(2, 1800),
            FusionDataPoint(3, 3200),
          ],
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
        ),
      ],
      yAxis: FusionAxisConfiguration(
        title: 'Revenue',
        labelFormatter: (value) => '\$${(value / 1000).toStringAsFixed(1)}K',
        showGrid: true,
      ),
    );
  }
}

class GridCustomizationExample extends StatelessWidget {
  const GridCustomizationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Data',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 50),
            FusionDataPoint(2, 40),
            FusionDataPoint(3, 65),
          ],
          color: const Color(0xFF10B981),
          lineWidth: 2.5,
        ),
      ],
      config: const FusionChartConfiguration(enableGrid: true),
    );
  }
}

// =============================================================================
// PERFORMANCE EXAMPLES
// =============================================================================

class LargeDatasetExample extends StatelessWidget {
  const LargeDatasetExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate 100 data points
    final dataPoints = List.generate(
      100,
      (i) => FusionDataPoint(i.toDouble(), 20 + (50 * (i % 10 / 10)) + (10 * (i % 3))),
    );

    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Large Dataset',
          dataPoints: dataPoints,
          color: const Color(0xFF6366F1),
          lineWidth: 2.0,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(enableAnimation: false),
    );
  }
}

class RealTimeExample extends StatefulWidget {
  const RealTimeExample({super.key});

  @override
  _RealTimeExampleState createState() => _RealTimeExampleState();
}

class _RealTimeExampleState extends State<RealTimeExample> {
  List<FusionDataPoint> dataPoints = [];
  int counter = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with some data
    dataPoints = List.generate(20, (i) => FusionDataPoint(i.toDouble(), 50.0));

    // Simulate real-time updates
    Future.delayed(const Duration(milliseconds: 100), updateData);
  }

  void updateData() {
    if (!mounted) return;

    setState(() {
      if (dataPoints.length >= 50) {
        dataPoints.removeAt(0);
        // Shift x values
        for (int i = 0; i < dataPoints.length; i++) {
          dataPoints[i] = FusionDataPoint(i.toDouble(), dataPoints[i].y);
        }
      }

      final newY = 30 + (40 * (counter % 20 / 20));
      dataPoints.add(FusionDataPoint(dataPoints.length.toDouble(), newY));
      counter++;
    });

    Future.delayed(const Duration(milliseconds: 100), updateData);
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Real-time',
          dataPoints: dataPoints,
          color: const Color(0xFFEF4444),
          lineWidth: 2.0,
        ),
      ],
      config: const FusionChartConfiguration(enableAnimation: false),
    );
  }
}

// =============================================================================
// ANIMATION EXAMPLES
// =============================================================================

class AnimatedEntryExample extends StatelessWidget {
  const AnimatedEntryExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Animated',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 55),
            FusionDataPoint(2, 45),
            FusionDataPoint(3, 75),
            FusionDataPoint(4, 60),
            FusionDataPoint(5, 85),
          ],
          color: const Color(0xFF8B5CF6),
          lineWidth: 3.0,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableAnimation: true,
        animationDuration: Duration(milliseconds: 1500),
      ),
    );
  }
}

class CustomAnimationExample extends StatelessWidget {
  const CustomAnimationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Custom Curve',
          dataPoints: [
            FusionDataPoint(0, 60),
            FusionDataPoint(1, 75),
            FusionDataPoint(2, 65),
            FusionDataPoint(3, 90),
          ],
          color: const Color(0xFFEC4899),
          barWidth: 0.6,
          borderRadius: 10.0,
        ),
      ],
      config: const FusionChartConfiguration(
        enableAnimation: true,
        animationDuration: Duration(milliseconds: 2000),
        animationCurve: Curves.elasticOut,
      ),
    );
  }
}

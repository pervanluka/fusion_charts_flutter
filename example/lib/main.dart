// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'pie_chart_showcase.dart';
import 'line_chart_showcase.dart';
import 'bar_chart_showcase.dart';
import 'feature_highlights.dart';

void main() {
  runApp(const FusionChartsShowcaseApp());
}

// =============================================================================
// MAIN APP
// =============================================================================

class FusionChartsShowcaseApp extends StatefulWidget {
  const FusionChartsShowcaseApp({super.key});

  @override
  State<FusionChartsShowcaseApp> createState() => _FusionChartsShowcaseAppState();
}

class _FusionChartsShowcaseAppState extends State<FusionChartsShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fusion Charts Flutter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
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
      home: ShowcaseGalleryHome(onThemeToggle: _toggleTheme),
    );
  }
}

// =============================================================================
// GALLERY HOME
// =============================================================================

class ShowcaseGalleryHome extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const ShowcaseGalleryHome({super.key, required this.onThemeToggle});

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
            Text('High-Performance Charting Library', style: TextStyle(fontSize: 12)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: onThemeToggle,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildShowcaseSection(context),
          const SizedBox(height: 24),
          ...categories.map((category) => _buildCategory(context, category)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                        'Feature Gallery',
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
                _buildBadge('📊 5 Chart Types'),
                _buildBadge('⚡ O(log n) Hit Testing'),
                _buildBadge('📈 LTTB Downsampling'),
                _buildBadge('🎯 Smart Labels'),
                _buildBadge('🎨 Themes'),
                _buildBadge('📱 60fps'),
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

  Widget _buildShowcaseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 28, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text(
                '🌟 Full API Showcases',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _ShowcaseCard(
                title: 'Feature Highlights',
                subtitle: 'Unique differentiators',
                icon: Icons.star,
                color: const Color(0xFF10B981),
                examples: '6 demos',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeatureHighlights()),
                ),
              ),
              _ShowcaseCard(
                title: 'Pie Charts',
                subtitle: 'Complete API reference',
                icon: Icons.pie_chart,
                color: const Color(0xFF6366F1),
                examples: '14 examples',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PieChartShowcase()),
                ),
              ),
              _ShowcaseCard(
                title: 'Line Charts',
                subtitle: 'Complete API reference',
                icon: Icons.show_chart,
                color: const Color(0xFF8B5CF6),
                examples: '11 examples',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LineChartShowcase()),
                ),
              ),
              _ShowcaseCard(
                title: 'Bar Charts',
                subtitle: 'Complete API reference',
                icon: Icons.bar_chart,
                color: const Color(0xFFF59E0B),
                examples: '10 examples',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BarChartShowcase()),
                ),
              ),
            ],
          ),
        ),
      ],
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

class _ShowcaseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String examples;
  final VoidCallback onTap;

  const _ShowcaseCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.examples,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    examples,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                child: Text(example.description, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SizedBox(
                height: 400,
                child: Padding(padding: const EdgeInsets.all(16), child: example.builder(context)),
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
    name: '🥧 Pie Charts',
    icon: Icons.pie_chart,
    examples: [
      ShowcaseExample(
        title: 'Basic Pie',
        description: 'Simple pie with auto-coloring',
        builder: (context) => const BasicPieExample(),
      ),
      ShowcaseExample(
        title: 'Donut Chart',
        description: 'With center label',
        builder: (context) => const DonutExample(),
      ),
      ShowcaseExample(
        title: 'Rounded Corners',
        description: 'cornerRadius for smooth edges',
        builder: (context) => const RoundedCornersPieExample(),
      ),
      ShowcaseExample(
        title: 'Smart Labels',
        description: 'Auto-contrast text',
        builder: (context) => const SmartLabelsPieExample(),
      ),
      ShowcaseExample(
        title: 'Selection Mode',
        description: 'Tap to select',
        builder: (context) => const SelectablePieExample(),
      ),
      ShowcaseExample(
        title: 'Dark Theme',
        description: 'Full dark mode',
        builder: (context) => const DarkThemePieExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '📈 Line Charts',
    icon: Icons.show_chart,
    examples: [
      ShowcaseExample(
        title: 'Basic Line',
        description: 'With area fill',
        builder: (context) => const BasicLineExample(),
      ),
      ShowcaseExample(
        title: 'Multi-Series',
        description: 'Multiple lines',
        builder: (context) => const MultiSeriesLineExample(),
      ),
      ShowcaseExample(
        title: 'Curved Line',
        description: 'Smooth curves',
        builder: (context) => const CurvedLineExample(),
      ),
      ShowcaseExample(
        title: 'With Markers',
        description: 'Data point indicators',
        builder: (context) => const MarkersLineExample(),
      ),
      ShowcaseExample(
        title: 'Gradient',
        description: 'Beautiful gradients',
        builder: (context) => const GradientLineExample(),
      ),
      ShowcaseExample(
        title: 'Large Dataset',
        description: '1000+ points (LTTB)',
        builder: (context) => const LargeDatasetExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '📊 Bar Charts',
    icon: Icons.bar_chart,
    examples: [
      ShowcaseExample(
        title: 'Basic Bars',
        description: 'Vertical columns',
        builder: (context) => const BasicBarsExample(),
      ),
      ShowcaseExample(
        title: 'Grouped Bars',
        description: 'Side by side',
        builder: (context) => const GroupedBarsExample(),
      ),
      ShowcaseExample(
        title: 'Stacked Bars',
        description: 'Series stacked',
        builder: (context) => const StackedBarsExample(),
      ),
      ShowcaseExample(
        title: 'Rounded',
        description: 'Beautiful edges',
        builder: (context) => const RoundedBarsExample(),
      ),
      ShowcaseExample(
        title: 'Gradient',
        description: 'Color gradients',
        builder: (context) => const GradientBarsExample(),
      ),
      ShowcaseExample(
        title: 'With Shadows',
        description: 'Depth effects',
        builder: (context) => const ShadowBarsExample(),
      ),
      ShowcaseExample(
        title: 'Track Background',
        description: 'Progress indicator style',
        builder: (context) => const TrackBarsExample(),
      ),
      ShowcaseExample(
        title: 'Stacked 100%',
        description: 'Normalized to 100%',
        builder: (context) => const Stacked100BarsExample(),
      ),
    ],
  ),
  ShowcaseCategory(
    name: '🎮 Interactions',
    icon: Icons.touch_app,
    examples: [
      ShowcaseExample(
        title: 'Tooltips',
        description: 'Tap for info',
        builder: (context) => const TooltipExample(),
      ),
      ShowcaseExample(
        title: 'Crosshair',
        description: 'Precision tracking',
        builder: (context) => const CrosshairExample(),
      ),
      ShowcaseExample(
        title: 'Zoom & Pan',
        description: 'Navigate data',
        builder: (context) => const ZoomPanExample(),
      ),
    ],
  ),
];

// =============================================================================
// EXAMPLE WIDGETS - PIE
// =============================================================================

final _pieData = [
  FusionPieDataPoint(35, label: 'Sales', color: const Color(0xFF6366F1)),
  FusionPieDataPoint(25, label: 'Marketing', color: const Color(0xFF22C55E)),
  FusionPieDataPoint(20, label: 'Engineering', color: const Color(0xFFF59E0B)),
  FusionPieDataPoint(15, label: 'Support', color: const Color(0xFFA855F7)),
  FusionPieDataPoint(5, label: 'Other', color: const Color(0xFF6B7280)),
];

class _PieContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const _PieContainer({required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor != null
          ? BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8))
          : null,
      child: Center(child: AspectRatio(aspectRatio: 1.0, child: child)),
    );
  }
}

class BasicPieExample extends StatelessWidget {
  const BasicPieExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _PieContainer(
      child: FusionPieChart(
        series: FusionPieSeries(dataPoints: _pieData),
        config: const FusionPieChartConfiguration(
          enableLegend: false,
          labelPosition: PieLabelPosition.none,
          padding: EdgeInsets.zero,
          chartPadding: EdgeInsets.all(4),
        ),
      ),
    );
  }
}

class DonutExample extends StatelessWidget {
  const DonutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _PieContainer(
      child: FusionPieChart(
        series: FusionPieSeries(dataPoints: _pieData),
        config: const FusionPieChartConfiguration(
          innerRadiusPercent: 0.55,
          showCenterLabel: true,
          centerLabelText: '\$2.4M',
          centerSubLabelText: 'Total',
          enableLegend: false,
          labelPosition: PieLabelPosition.none,
          padding: EdgeInsets.zero,
          chartPadding: EdgeInsets.all(4),
        ),
      ),
    );
  }
}

class RoundedCornersPieExample extends StatelessWidget {
  const RoundedCornersPieExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _PieContainer(
      child: FusionPieChart(
        series: FusionPieSeries(dataPoints: _pieData, strokeWidth: 2, strokeColor: Colors.white),
        config: const FusionPieChartConfiguration(
          innerRadiusPercent: 0.5,
          cornerRadius: 10.0,
          gapBetweenSlices: 2.0,
          enableLegend: false,
          labelPosition: PieLabelPosition.none,
          padding: EdgeInsets.zero,
          chartPadding: EdgeInsets.all(4),
        ),
      ),
    );
  }
}

class SmartLabelsPieExample extends StatelessWidget {
  const SmartLabelsPieExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _PieContainer(
      child: FusionPieChart(
        series: FusionPieSeries(
          dataPoints: [
            FusionPieDataPoint(40, label: 'Dark', color: const Color(0xFF1E293B)),
            FusionPieDataPoint(30, label: 'Light', color: const Color(0xFFFEF3C7)),
            FusionPieDataPoint(20, label: 'Blue', color: const Color(0xFF3B82F6)),
            FusionPieDataPoint(10, label: 'Green', color: const Color(0xFF22C55E)),
          ],
        ),
        config: const FusionPieChartConfiguration(
          labelPosition: PieLabelPosition.inside,
          showPercentages: true,
          enableLegend: false,
          padding: EdgeInsets.zero,
          chartPadding: EdgeInsets.all(4),
        ),
      ),
    );
  }
}

class SelectablePieExample extends StatelessWidget {
  const SelectablePieExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _PieContainer(
      child: FusionPieChart(
        series: FusionPieSeries(dataPoints: _pieData),
        config: const FusionPieChartConfiguration(
          selectionMode: PieSelectionMode.single,
          selectedScale: 1.05,
          explodeOnSelection: true,
          enableLegend: false,
          labelPosition: PieLabelPosition.none,
          padding: EdgeInsets.zero,
          chartPadding: EdgeInsets.all(4),
        ),
      ),
    );
  }
}

class DarkThemePieExample extends StatelessWidget {
  const DarkThemePieExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _PieContainer(
      backgroundColor: const Color(0xFF1E1E2E),
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
          innerRadiusPercent: 0.5,
          showCenterLabel: true,
          centerLabelText: 'Dark',
          centerLabelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          enableLegend: false,
          labelPosition: PieLabelPosition.none,
          padding: EdgeInsets.zero,
          chartPadding: EdgeInsets.all(4),
        ),
      ),
    );
  }
}

// =============================================================================
// EXAMPLE WIDGETS - LINE
// =============================================================================

class BasicLineExample extends StatelessWidget {
  const BasicLineExample({super.key});

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
          showArea: true,
          areaOpacity: 0.3,
          isCurved: true,
        ),
      ],
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
          name: 'A',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 45),
            FusionDataPoint(2, 35),
            FusionDataPoint(3, 60),
          ],
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
        ),
        FusionLineSeries(
          name: 'B',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(1, 35),
            FusionDataPoint(2, 45),
            FusionDataPoint(3, 40),
          ],
          color: const Color(0xFF22C55E),
          lineWidth: 2.5,
        ),
      ],
      config: const FusionChartConfiguration(enableLegend: true),
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

class MarkersLineExample extends StatelessWidget {
  const MarkersLineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 50),
            FusionDataPoint(2, 40),
            FusionDataPoint(3, 65),
          ],
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
          showMarkers: true,
          markerSize: 8.0,
        ),
      ],
      config: const FusionLineChartConfiguration(enableMarkers: true),
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
          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
          showArea: true,
          areaOpacity: 0.2,
          isCurved: true,
        ),
      ],
    );
  }
}

class LargeDatasetExample extends StatelessWidget {
  const LargeDatasetExample({super.key});

  @override
  Widget build(BuildContext context) {
    final dataPoints = List.generate(
      500,
      (i) => FusionDataPoint(i.toDouble(), 20 + (50 * (i % 10 / 10)) + (10 * (i % 3))),
    );

    return FusionLineChart(
      series: [
        FusionLineSeries(dataPoints: dataPoints, color: const Color(0xFF6366F1), lineWidth: 1.5),
      ],
      config: const FusionChartConfiguration(enableAnimation: false),
    );
  }
}

// =============================================================================
// EXAMPLE WIDGETS - BAR
// =============================================================================

class BasicBarsExample extends StatelessWidget {
  const BasicBarsExample({super.key});

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
          borderRadius: 6.0,
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
          barWidth: 0.35,
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
          barWidth: 0.35,
        ),
      ],
      config: const FusionBarChartConfiguration(enableLegend: true),
    );
  }
}

class StackedBarsExample extends StatelessWidget {
  const StackedBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionStackedBarChart(
      series: [
        FusionStackedBarSeries(
          name: 'A',
          dataPoints: [
            FusionDataPoint(0, 30),
            FusionDataPoint(1, 35),
            FusionDataPoint(2, 28),
            FusionDataPoint(3, 40),
          ],
          color: const Color(0xFF6366F1),
        ),
        FusionStackedBarSeries(
          name: 'B',
          dataPoints: [
            FusionDataPoint(0, 25),
            FusionDataPoint(1, 30),
            FusionDataPoint(2, 35),
            FusionDataPoint(3, 28),
          ],
          color: const Color(0xFF22C55E),
        ),
        FusionStackedBarSeries(
          name: 'C',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(1, 18),
            FusionDataPoint(2, 22),
            FusionDataPoint(3, 25),
          ],
          color: const Color(0xFFF59E0B),
        ),
      ],
      config: const FusionStackedBarChartConfiguration(enableLegend: true),
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
          dataPoints: [
            FusionDataPoint(0, 60),
            FusionDataPoint(1, 75),
            FusionDataPoint(2, 65),
            FusionDataPoint(3, 90),
          ],
          color: const Color(0xFF10B981),
          barWidth: 0.5,
          borderRadius: 12.0,
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
          dataPoints: [
            FusionDataPoint(0, 60),
            FusionDataPoint(1, 75),
            FusionDataPoint(2, 65),
            FusionDataPoint(3, 90),
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
}

class ShadowBarsExample extends StatelessWidget {
  const ShadowBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
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
          shadow: const BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(2, 4)),
        ),
      ],
    );
  }
}

// =============================================================================
// EXAMPLE WIDGETS - INTERACTIONS
// =============================================================================

class TooltipExample extends StatelessWidget {
  const TooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
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
      config: const FusionChartConfiguration(
        enableTooltip: true,
        tooltipBehavior: FusionTooltipBehavior(
          activationMode: FusionTooltipActivationMode.singleTap,
        ),
      ),
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

class ZoomPanExample extends StatelessWidget {
  const ZoomPanExample({super.key});

  @override
  Widget build(BuildContext context) {
    final dataPoints = List.generate(
      100,
      (i) => FusionDataPoint(i.toDouble(), 30 + 40 * (i % 10 / 10) + (i % 5)),
    );

    return FusionLineChart(
      series: [
        FusionLineSeries(dataPoints: dataPoints, color: const Color(0xFF3B82F6), lineWidth: 2.0),
      ],
      config: const FusionChartConfiguration(
        enableAnimation: false,
        enableZoom: true,
        enablePanning: true,
        zoomBehavior: FusionZoomConfiguration(
          enabled: true,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
          enableDoubleTapZoom: true,
        ),
        panBehavior: FusionPanConfiguration(enabled: true),
      ),
    );
  }
}

// =============================================================================
// EXAMPLE WIDGETS - BAR (TRACK & STACKED 100%)
// =============================================================================

/// Bar chart with track (background bar) - progress indicator style
class TrackBarsExample extends StatelessWidget {
  const TrackBarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Progress',
          dataPoints: [
            FusionDataPoint(0, 65, label: 'A'),
            FusionDataPoint(1, 85, label: 'B'),
            FusionDataPoint(2, 45, label: 'C'),
            FusionDataPoint(3, 92, label: 'D'),
          ],
          color: const Color(0xFF10B981),
          barWidth: 0.5,
          borderRadius: 8.0,
          isTrackVisible: true,
          trackColor: const Color(0xFFE5E7EB),
        ),
      ],
      yAxis: const FusionAxisConfiguration(min: 0, max: 100),
    );
  }
}

/// Stacked bar chart normalized to 100%
class Stacked100BarsExample extends StatelessWidget {
  const Stacked100BarsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionStackedBarChart(
      series: [
        FusionStackedBarSeries(
          name: 'Desktop',
          dataPoints: [
            FusionDataPoint(0, 45, label: 'Q1'),
            FusionDataPoint(1, 38, label: 'Q2'),
            FusionDataPoint(2, 32, label: 'Q3'),
            FusionDataPoint(3, 28, label: 'Q4'),
          ],
          color: const Color(0xFF6366F1),
        ),
        FusionStackedBarSeries(
          name: 'Mobile',
          dataPoints: [
            FusionDataPoint(0, 35, label: 'Q1'),
            FusionDataPoint(1, 42, label: 'Q2'),
            FusionDataPoint(2, 48, label: 'Q3'),
            FusionDataPoint(3, 52, label: 'Q4'),
          ],
          color: const Color(0xFF22C55E),
        ),
        FusionStackedBarSeries(
          name: 'Tablet',
          dataPoints: [
            FusionDataPoint(0, 20, label: 'Q1'),
            FusionDataPoint(1, 20, label: 'Q2'),
            FusionDataPoint(2, 20, label: 'Q3'),
            FusionDataPoint(3, 20, label: 'Q4'),
          ],
          color: const Color(0xFFF59E0B),
        ),
      ],
      config: const FusionStackedBarChartConfiguration(isStacked100: true, enableLegend: true),
    );
  }
}

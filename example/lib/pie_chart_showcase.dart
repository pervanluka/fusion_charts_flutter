import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

// =============================================================================
// PIE CHART SHOWCASE - Complete API Reference
// =============================================================================

/// Comprehensive Pie Chart Showcase demonstrating all FusionPieChart capabilities.
///
/// Features covered:
/// - Basic pie and donut charts
/// - Exploded segments
/// - Selection modes (single, multiple, none)
/// - Hover effects
/// - Sorting and grouping
/// - Label positions (inside, outside, auto, none)
/// - Legend positions (top, bottom, left, right)
/// - Full FusionTooltipBehavior integration
/// - Custom styling (gradients, shadows, borders)
/// - Animation types (sweep, scale, fade)
/// - Dark theme support
/// - Per-segment customization
/// - Center widgets and labels
/// - Callbacks (onTap, onLongPress, onSelectionChanged)
class PieChartShowcase extends StatefulWidget {
  const PieChartShowcase({super.key});

  @override
  State<PieChartShowcase> createState() => _PieChartShowcaseState();
}

class _PieChartShowcaseState extends State<PieChartShowcase> {
  int _currentPage = 0;
  final _pageController = PageController();

  final List<_ShowcaseItem> _showcaseItems = [
    _ShowcaseItem(
      title: '1. Basic Pie Chart',
      description: 'Simple pie chart with auto-coloring from palette',
      code: '''
FusionPieChart(
  series: FusionPieSeries(
    dataPoints: [
      FusionPieDataPoint(35, label: 'Sales'),
      FusionPieDataPoint(25, label: 'Marketing'),
      FusionPieDataPoint(20, label: 'Engineering'),
      FusionPieDataPoint(20, label: 'Support'),
    ],
  ),
)''',
      builder: _buildBasicPieChart,
    ),
    _ShowcaseItem(
      title: '2. Donut Chart with Center',
      description: 'innerRadiusPercent > 0 creates donut, with center label',
      code: '''
FusionPieChart(
  series: FusionPieSeries(dataPoints: data),
  config: FusionPieChartConfiguration(
    innerRadiusPercent: 0.55,
    showCenterLabel: true,
    centerLabelText: '\$2.4M',
    centerSubLabelText: 'Total Budget',
  ),
)''',
      builder: _buildDonutChart,
    ),
    _ShowcaseItem(
      title: '3. Exploded Segments',
      description: 'explode: true on data point or gapBetweenSlices for all',
      code: '''
// Per-segment explode (radial offset)
FusionPieDataPoint(35, label: 'Winner', explode: true)

// All segments with uniform gaps (angular)
FusionPieChartConfiguration(
  gapBetweenSlices: 3.0, // degrees
)''',
      builder: _buildExplodedChart,
    ),
    _ShowcaseItem(
      title: '4. Selection Modes',
      description: 'single, multiple, or none + visual feedback',
      code: '''
FusionPieChartConfiguration(
  selectionMode: PieSelectionMode.single,
  selectedScale: 1.05,
  selectedOpacity: 1.0,
  unselectedOpacity: 0.5,
  explodeOnSelection: true,
)''',
      builder: _buildSelectionChart,
    ),
    _ShowcaseItem(
      title: '5. Hover Effects',
      description: 'hoverScale + explodeOnHover for desktop/web',
      code: '''
FusionPieChartConfiguration(
  enableHover: true,
  hoverScale: 1.08,
  explodeOnHover: true,
  explodeOffset: 20,
)''',
      builder: _buildHoverChart,
    ),
    _ShowcaseItem(
      title: '6. Sorting & Grouping',
      description: 'Sort slices and group small ones into "Other"',
      code: '''
FusionPieChartConfiguration(
  sortMode: PieSortMode.descending,
  groupSmallSegments: true,
  groupThreshold: 5.0,
  groupLabel: 'Other Regions',
)''',
      builder: _buildSortedGroupedChart,
    ),
    _ShowcaseItem(
      title: '7. Label Positions',
      description: 'inside, outside (with connectors), auto, or none',
      code: '''
FusionPieChartConfiguration(
  labelPosition: PieLabelPosition.outside,
  labelConnectorLength: 25,
  labelConnectorWidth: 1.5,
  showPercentages: true,
  showValues: true,
)''',
      builder: _buildLabelChart,
    ),
    _ShowcaseItem(
      title: '8. Legend Positions',
      description: 'right, left, top, bottom with icon shapes',
      code: '''
FusionPieChartConfiguration(
  legendPosition: LegendPosition.right,
  legendIconShape: LegendIconShape.circle,
  showLegendPercentages: true,
  showLegendValues: true,
)''',
      builder: _buildLegendChart,
    ),
    _ShowcaseItem(
      title: '9. Tooltip Behaviors',
      description: 'Tap or long-press activation, auto-dismiss options',
      code: '''
FusionTooltipBehavior(
  activationMode: FusionTooltipActivationMode.singleTap,
  dismissStrategy: FusionDismissStrategy.onTimer,
  duration: Duration(seconds: 2),
  hapticFeedback: true,
  elevation: 4.0,
  decimalPlaces: 1,
)''',
      builder: _buildTooltipChart,
    ),
    _ShowcaseItem(
      title: '10. Custom Styling',
      description: 'Corner radius, gradients, gaps, borders',
      code: '''
// Rounded corners for pie segments
FusionPieChartConfiguration(
  cornerRadius: 12.0,  // Smooth rounded edges
  gapBetweenSlices: 2.0,
)

// Per-segment gradients
FusionPieDataPoint(
  35,
  label: 'Premium',
  gradient: RadialGradient(colors: [...]),
)''',
      builder: _buildStyledChart,
    ),
    _ShowcaseItem(
      title: '11. Animation Types',
      description: 'sweep (default), scale, fade, scaleFade, none',
      code: '''
FusionPieChartConfiguration(
  animationType: PieAnimationType.sweep,
  animationDuration: Duration(milliseconds: 1200),
)''',
      builder: _buildAnimatedChart,
    ),
    _ShowcaseItem(
      title: '12. Dark Theme',
      description: 'Full dark theme support',
      code: '''
FusionPieChartConfiguration(
  theme: FusionDarkTheme(),
  strokeWidth: 1,
  strokeColor: Color(0xFF374151),
)''',
      builder: _buildDarkThemeChart,
    ),
    _ShowcaseItem(
      title: '13. Callbacks',
      description: 'onSegmentTap, onLongPress, onSelectionChanged',
      code: '''
FusionPieChart(
  series: series,
  onSegmentTap: (index, series) {
    print('Tapped segment \$index');
  },
  onSelectionChanged: (indices) {
    print('Selected: \$indices');
  },
)''',
      builder: _buildCallbackChart,
    ),
    _ShowcaseItem(
      title: '14. Per-Segment Callbacks',
      description: 'Callbacks on individual data points',
      code: '''
FusionPieDataPoint(
  35,
  label: 'Sales',
  onTap: (point, index) => print('Tapped \$index'),
  onLongPress: (point, index) => print('Long pressed'),
  onHover: (point, index, isHovered) => print('Hover: \$isHovered'),
)''',
      builder: _buildPerSegmentCallbackChart,
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
        title: const Text('Pie Chart Showcase'),
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
          // Header with title and description
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

          // Chart area
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

          // Code snippet
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        currentIndex: (_currentPage / 4).floor().clamp(0, 3),
        onTap: (index) => _goToPage(index * 4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Basic'),
          BottomNavigationBarItem(
            icon: Icon(Icons.touch_app),
            label: 'Interactive',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: 'Labels'),
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Styling'),
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
// SAMPLE DATA
// =============================================================================

final _sampleData = [
  FusionPieDataPoint(35, label: 'Sales', color: const Color(0xFF6366F1)),
  FusionPieDataPoint(25, label: 'Marketing', color: const Color(0xFF22C55E)),
  FusionPieDataPoint(20, label: 'Engineering', color: const Color(0xFFF59E0B)),
  FusionPieDataPoint(15, label: 'Support', color: const Color(0xFFA855F7)),
  FusionPieDataPoint(5, label: 'Other', color: const Color(0xFF6B7280)),
];

final _detailedData = [
  FusionPieDataPoint(35, label: 'North America'),
  FusionPieDataPoint(28, label: 'Europe'),
  FusionPieDataPoint(18, label: 'Asia Pacific'),
  FusionPieDataPoint(12, label: 'Latin America'),
  FusionPieDataPoint(4, label: 'Middle East'),
  FusionPieDataPoint(2, label: 'Africa'),
  FusionPieDataPoint(1, label: 'Other'),
];

// =============================================================================
// SHOWCASE BUILDERS
// =============================================================================

Widget _buildBasicPieChart() {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return FusionPieChart(
        title: 'Revenue by Department',
        subtitle: 'Q4 2024',
        series: FusionPieSeries(dataPoints: _sampleData),
        config: FusionPieChartConfiguration(
          theme: isDark ? const FusionDarkTheme() : const FusionLightTheme(),
        ),
      );
    },
  );
}

Widget _buildDonutChart() {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return FusionPieChart(
        title: 'Budget Allocation',
        series: FusionPieSeries(dataPoints: _sampleData),
        config: FusionPieChartConfiguration(
          theme: isDark ? const FusionDarkTheme() : const FusionLightTheme(),
          innerRadiusPercent: 0.55,
          showCenterLabel: true,
          centerLabelText: '\$2.4M',
          centerSubLabelText: 'Total Budget',
          centerLabelStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          centerSubLabelStyle: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          labelPosition: PieLabelPosition.outside,
          labelConnectorLength: 30,
          labelStyle: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      );
    },
  );
}

Widget _buildExplodedChart() {
  return Column(
    children: [
      Expanded(
        child: FusionPieChart(
          title: 'Single Exploded',
          series: FusionPieSeries(
            dataPoints: [
              FusionPieDataPoint(
                35,
                label: 'Winner',
                color: Colors.green,
                explode: true,
              ),
              FusionPieDataPoint(25, label: 'Second', color: Colors.blue),
              FusionPieDataPoint(20, label: 'Third', color: Colors.orange),
              FusionPieDataPoint(20, label: 'Fourth', color: Colors.purple),
            ],
            explodeOffset: 15,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionPieChart(
          title: 'All Separated (uniform gaps)',
          series: FusionPieSeries(dataPoints: _sampleData),
          config: const FusionPieChartConfiguration(gapBetweenSlices: 10.0),
        ),
      ),
    ],
  );
}

Widget _buildSelectionChart() {
  return Column(
    children: [
      Expanded(
        child: FusionPieChart(
          title: 'Single Selection (tap to select)',
          series: FusionPieSeries(dataPoints: _sampleData),
          config: const FusionPieChartConfiguration(
            selectionMode: PieSelectionMode.single,
            selectedScale: 1.05,
            selectedOpacity: 1.0,
            unselectedOpacity: 0.5,
            explodeOnSelection: true,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionPieChart(
          title: 'Multiple Selection',
          series: FusionPieSeries(dataPoints: _sampleData),
          config: const FusionPieChartConfiguration(
            selectionMode: PieSelectionMode.multiple,
            selectedOpacity: 1.0,
            unselectedOpacity: 0.3,
          ),
        ),
      ),
    ],
  );
}

Widget _buildHoverChart() {
  return FusionPieChart(
    title: 'Hover to Scale & Explode',
    subtitle: 'Best experienced on desktop/web',
    series: FusionPieSeries(dataPoints: _sampleData),
    config: const FusionPieChartConfiguration(
      enableHover: true,
      hoverScale: 1.08,
      explodeOnHover: true,
      explodeOffset: 20,
    ),
  );
}

Widget _buildSortedGroupedChart() {
  return Column(
    children: [
      Expanded(
        child: FusionPieChart(
          title: 'Sorted Descending',
          series: FusionPieSeries(dataPoints: _detailedData),
          config: const FusionPieChartConfiguration(
            sortMode: PieSortMode.descending,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionPieChart(
          title: 'Grouped (< 5% → Other)',
          series: FusionPieSeries(dataPoints: _detailedData),
          config: FusionPieChartConfiguration(
            groupSmallSegments: true,
            groupThreshold: 5.0,
            groupLabel: 'Other Regions',
            groupColor: Colors.grey.shade400,
            labelPosition: PieLabelPosition.outside,
          ),
        ),
      ),
    ],
  );
}

Widget _buildLabelChart() {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final FusionChartTheme theme = isDark
          ? const FusionDarkTheme()
          : const FusionLightTheme();
      final labelColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;

      return Column(
        children: [
          Expanded(
            child: FusionPieChart(
              title: 'Inside Labels',
              series: FusionPieSeries(dataPoints: _sampleData),
              config: FusionPieChartConfiguration(
                theme: theme,
                labelPosition: PieLabelPosition.inside,
                showPercentages: true,
                showValues: false,
                enableLegend: false,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FusionPieChart(
              title: 'Outside Labels with Connectors',
              series: FusionPieSeries(dataPoints: _sampleData),
              config: FusionPieChartConfiguration(
                theme: theme,
                labelPosition: PieLabelPosition.outside,
                labelConnectorLength: 15,
                labelConnectorWidth: 1.0,
                labelConnectorColor: isDark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                showPercentages: true,
                showValues: false,
                enableLegend: false,
                labelStyle: TextStyle(fontSize: 11, color: labelColor),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildLegendChart() {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final FusionChartTheme theme = isDark
          ? const FusionDarkTheme()
          : const FusionLightTheme();

      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _buildLegendVariant(
            'Right',
            LegendPosition.right,
            LegendIconShape.circle,
            theme,
          ),
          _buildLegendVariant(
            'Left',
            LegendPosition.left,
            LegendIconShape.roundedSquare,
            theme,
          ),
          _buildLegendVariant(
            'Top',
            LegendPosition.top,
            LegendIconShape.square,
            theme,
          ),
          _buildLegendVariant(
            'Bottom',
            LegendPosition.bottom,
            LegendIconShape.diamond,
            theme,
          ),
        ],
      );
    },
  );
}

Widget _buildLegendVariant(
  String title,
  LegendPosition pos,
  LegendIconShape shape,
  FusionChartTheme theme,
) {
  return FusionPieChart(
    title: title,
    series: FusionPieSeries(dataPoints: _sampleData),
    config: FusionPieChartConfiguration(
      theme: theme,
      legendPosition: pos,
      legendIconShape: shape,
      showLegendPercentages: true,
      showLabels: false,
    ),
  );
}

Widget _buildTooltipChart() {
  return Column(
    children: [
      Expanded(
        child: FusionPieChart(
          title: 'Tap to Show Tooltip',
          series: FusionPieSeries(dataPoints: _sampleData),
          config: FusionPieChartConfiguration(
            tooltipBehavior: FusionTooltipBehavior(
              activationMode: FusionTooltipActivationMode.singleTap,
              dismissStrategy: FusionDismissStrategy.onTimer,
              duration: const Duration(seconds: 2),
              hapticFeedback: true,
              elevation: 4.0,
              opacity: 0.95,
              borderWidth: 1.0,
              decimalPlaces: 1,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionPieChart(
          title: 'Long Press Tooltip',
          series: FusionPieSeries(dataPoints: _sampleData),
          config: FusionPieChartConfiguration(
            tooltipBehavior: FusionTooltipBehavior(
              activationMode: FusionTooltipActivationMode.longPress,
              dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
              dismissDelay: const Duration(milliseconds: 500),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildStyledChart() {
  return Column(
    children: [
      // Pie with rounded corners
      Expanded(
        child: FusionPieChart(
          title: 'Rounded Corners (Pie)',
          series: FusionPieSeries(
            dataPoints: [
              FusionPieDataPoint(
                35,
                label: 'Premium',
                color: const Color(0xFF6366F1),
              ),
              FusionPieDataPoint(
                25,
                label: 'Standard',
                color: const Color(0xFF22C55E),
              ),
              FusionPieDataPoint(
                20,
                label: 'Basic',
                color: const Color(0xFFF59E0B),
              ),
              FusionPieDataPoint(
                20,
                label: 'Free',
                color: const Color(0xFFA855F7),
              ),
            ],
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
          config: const FusionPieChartConfiguration(
            cornerRadius: 12.0,
            gapBetweenSlices: 2.0,
            enableLegend: false,
          ),
        ),
      ),
      const SizedBox(height: 8),
      // Donut with rounded corners + gradients
      Expanded(
        child: FusionPieChart(
          title: 'Rounded Corners (Donut)',
          series: FusionPieSeries(
            dataPoints: [
              FusionPieDataPoint(
                35,
                label: 'Premium',
                gradient: const RadialGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
              ),
              FusionPieDataPoint(
                25,
                label: 'Standard',
                gradient: const RadialGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                ),
              ),
              FusionPieDataPoint(
                20,
                label: 'Basic',
                gradient: const RadialGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
              ),
              FusionPieDataPoint(
                20,
                label: 'Free',
                color: Colors.grey.shade400,
              ),
            ],
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
          config: const FusionPieChartConfiguration(
            innerRadiusPercent: 0.5,
            cornerRadius: 8.0,
            gapBetweenSlices: 3.0,
            enableLegend: false,
          ),
        ),
      ),
    ],
  );
}

Widget _buildAnimatedChart() {
  return Column(
    children: [
      Expanded(
        child: FusionPieChart(
          key: UniqueKey(),
          title: 'Sweep Animation (default)',
          series: FusionPieSeries(dataPoints: _sampleData),
          config: const FusionPieChartConfiguration(
            animationType: PieAnimationType.sweep,
            animationDuration: Duration(milliseconds: 1200),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: FusionPieChart(
                key: UniqueKey(),
                title: 'Scale',
                series: FusionPieSeries(dataPoints: _sampleData),
                config: const FusionPieChartConfiguration(
                  animationType: PieAnimationType.scale,
                  animationDuration: Duration(milliseconds: 800),
                  enableLegend: false,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FusionPieChart(
                key: UniqueKey(),
                title: 'Fade',
                series: FusionPieSeries(dataPoints: _sampleData),
                config: const FusionPieChartConfiguration(
                  animationType: PieAnimationType.fade,
                  animationDuration: Duration(milliseconds: 600),
                  enableLegend: false,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildDarkThemeChart() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E2E),
      borderRadius: BorderRadius.circular(12),
    ),
    child: FusionPieChart(
      title: 'Dark Theme Portfolio',
      series: FusionPieSeries(
        dataPoints: [
          FusionPieDataPoint(
            35,
            label: 'Crypto',
            color: const Color(0xFF8B5CF6),
          ),
          FusionPieDataPoint(
            25,
            label: 'Stocks',
            color: const Color(0xFF06B6D4),
          ),
          FusionPieDataPoint(
            20,
            label: 'Bonds',
            color: const Color(0xFF10B981),
          ),
          FusionPieDataPoint(
            15,
            label: 'Real Estate',
            color: const Color(0xFFF59E0B),
          ),
          FusionPieDataPoint(5, label: 'Cash', color: const Color(0xFF6B7280)),
        ],
      ),
      config: FusionPieChartConfiguration(
        theme: FusionDarkTheme(),
        innerRadiusPercent: 0.5,
        strokeWidth: 1,
        strokeColor: const Color(0xFF374151),
        showCenterLabel: true,
        centerLabelText: 'Portfolio',
        centerLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        legendPosition: LegendPosition.right,
        legendTextStyle: const TextStyle(color: Colors.white70),
      ),
    ),
  );
}

Widget _buildCallbackChart() {
  return StatefulBuilder(
    builder: (context, setState) {
      String message = 'Tap a segment to see callbacks in action';

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            child: FusionPieChart(
              series: FusionPieSeries(dataPoints: _sampleData),
              onSegmentTap: (index, series) {
                setState(() {
                  message =
                      'Tapped: ${series.dataPoints[index].label} (index $index)';
                });
              },
              onSelectionChanged: (indices) {
                setState(() {
                  message = 'Selection changed: $indices';
                });
              },
              config: const FusionPieChartConfiguration(
                selectionMode: PieSelectionMode.single,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildPerSegmentCallbackChart() {
  return StatefulBuilder(
    builder: (context, setState) {
      String message = 'Tap or long-press segments';

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Expanded(
            child: FusionPieChart(
              series: FusionPieSeries(
                dataPoints: [
                  FusionPieDataPoint(
                    35,
                    label: 'Sales',
                    color: Colors.blue,
                    onTap: (point, index) {
                      setState(() => message = 'Tapped: ${point.label}');
                    },
                    onLongPress: (point, index) {
                      setState(() => message = 'Long pressed: ${point.label}');
                    },
                  ),
                  FusionPieDataPoint(
                    25,
                    label: 'Marketing',
                    color: Colors.green,
                    onTap: (point, index) {
                      setState(() => message = 'Tapped: ${point.label}');
                    },
                  ),
                  FusionPieDataPoint(
                    20,
                    label: 'Engineering',
                    color: Colors.orange,
                    onTap: (point, index) {
                      setState(() => message = 'Tapped: ${point.label}');
                    },
                  ),
                  FusionPieDataPoint(
                    20,
                    label: 'Support',
                    color: Colors.purple,
                    onTap: (point, index) {
                      setState(() => message = 'Tapped: ${point.label}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

// =============================================================================
// STANDALONE MAIN (for running this file directly)
// =============================================================================

void main() {
  runApp(
    const MaterialApp(
      title: 'Pie Chart Showcase',
      debugShowCheckedModeBanner: false,
      home: PieChartShowcase(),
    ),
  );
}

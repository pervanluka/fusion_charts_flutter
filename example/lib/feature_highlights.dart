import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

// =============================================================================
// FEATURE HIGHLIGHTS - Unique Differentiators
// =============================================================================

/// Showcases the unique features that differentiate FusionCharts from competitors.
class FeatureHighlights extends StatefulWidget {
  const FeatureHighlights({super.key});

  @override
  State<FeatureHighlights> createState() => _FeatureHighlightsState();
}

class _FeatureHighlightsState extends State<FeatureHighlights> {
  int _currentPage = 0;
  final _pageController = PageController();

  final List<_HighlightItem> _highlights = [
    _HighlightItem(
      title: 'LTTB Downsampling',
      subtitle: '10,000 points → 500 points at 60fps',
      icon: Icons.speed,
      color: const Color(0xFF10B981),
      description: '''
Largest Triangle Three Buckets (LTTB) algorithm automatically reduces massive datasets while preserving visual shape.

• 10,000 points rendered at 60fps
• Visual accuracy maintained
• Automatic threshold detection
• Zero configuration required
''',
      builder: _buildLTTBDemo,
    ),
    _HighlightItem(
      title: 'QuadTree Hit Testing',
      subtitle: 'O(log n) point queries',
      icon: Icons.touch_app,
      color: const Color(0xFF6366F1),
      description: '''
QuadTree spatial index provides lightning-fast hit testing for touch interactions.

| Points  | Linear | QuadTree | Speedup |
|---------|--------|----------|---------|
| 100     | 100    | 7 ops    | 14x     |
| 1,000   | 1,000  | 10 ops   | 100x    |
| 10,000  | 10,000 | 13 ops   | 769x    |
''',
      builder: _buildQuadTreeDemo,
    ),
    _HighlightItem(
      title: '5 Tooltip Dismiss Strategies',
      subtitle: 'Context-aware UX',
      icon: Icons.chat_bubble_outline,
      color: const Color(0xFF8B5CF6),
      description: '''
Fine-grained control over tooltip lifecycle:

• onRelease - Instant dismiss on lift
• onTimer - Auto-dismiss after duration  
• onReleaseDelayed - Hybrid approach
• never - Manual dismiss only
• smart - Context-aware (desktop vs mobile)

Plus haptic feedback support!
''',
      builder: _buildTooltipStrategiesDemo,
    ),
    _HighlightItem(
      title: 'Smart Label System',
      subtitle: 'Auto-contrast & progressive sizing',
      icon: Icons.label_outline,
      color: const Color(0xFFF59E0B),
      description: '''
Intelligent label rendering for pie charts:

• Auto-contrast text colors based on segment luminance
• Progressive sizing: full → short → skip
• L-shaped elbow connectors for top/bottom zones
• Graceful degradation when space is limited
• Adaptive outside labels
''',
      builder: _buildSmartLabelsDemo,
    ),
    _HighlightItem(
      title: 'Performance Architecture',
      subtitle: 'Paint pooling, path caching, dirty regions',
      icon: Icons.memory,
      color: const Color(0xFFEC4899),
      description: '''
Built for performance from the ground up:

• FusionPaintPool - Object pooling reduces GC pressure
• FusionRenderOptimizer - Dirty region tracking
• Path caching with LRU eviction
• Frame-to-frame change detection
• Pre-computed segment geometry
''',
      builder: _buildPerformanceDemo,
    ),
    _HighlightItem(
      title: 'Flat API Design',
      subtitle: 'No 5-level nesting',
      icon: Icons.code,
      color: const Color(0xFF3B82F6),
      description: '''
Clean, ergonomic API without verbose boilerplate:

Verbose API:
  series: <PieSeries>[
    PieSeries(
      dataLabelSettings: DataLabelSettings(
        labelPosition: ...outside,
        connectorLineSettings: ConnectorLineSettings(
          length: '20%',
        ),
      ),
    ),
  ]

Clean API:
  config: FusionPieChartConfiguration(
    labelPosition: PieLabelPosition.outside,
    labelConnectorLength: 20,
  )
''',
      builder: _buildAPIComparisonDemo,
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
    final highlight = _highlights[_currentPage];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Highlights'),
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
                color: highlight.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1} / ${_highlights.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: highlight.color,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentPage < _highlights.length - 1
                ? () => _goToPage(_currentPage + 1)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  highlight.color.withValues(alpha: 0.1),
                  highlight.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: highlight.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(highlight.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        highlight.subtitle,
                        style: TextStyle(
                          color: highlight.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Demo area
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _highlights.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: _highlights[index].builder(),
                );
              },
            ),
          ),
          // Description
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  highlight.description,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.5,
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

class _HighlightItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;
  final Widget Function() builder;

  _HighlightItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
    required this.builder,
  });
}

// =============================================================================
// DEMO BUILDERS
// =============================================================================

Widget _buildLTTBDemo() {
  // Generate large dataset
  final random = math.Random(42);
  double value = 50;
  final dataPoints = List.generate(10000, (i) {
    value += (random.nextDouble() - 0.5) * 10;
    value = value.clamp(0.0, 100.0);
    return FusionDataPoint(i.toDouble(), value);
  });

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
            SizedBox(width: 8),
            Text(
              '10,000 data points • 60fps rendering',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: FusionLineChart(
          series: [
            FusionLineSeries(
              name: 'Large Dataset',
              dataPoints: dataPoints,
              color: const Color(0xFF10B981),
              lineWidth: 1.5,
            ),
          ],
          config: const FusionChartConfiguration(enableAnimation: false),
        ),
      ),
    ],
  );
}

Widget _buildQuadTreeDemo() {
  final dataPoints = List.generate(500, (i) {
    return FusionDataPoint(
      i.toDouble(),
      30 + 40 * math.sin(i * 0.05) + (i % 20),
    );
  });

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, color: Color(0xFF6366F1), size: 18),
            SizedBox(width: 8),
            Text(
              'Tap anywhere to test O(log n) hit detection',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: FusionLineChart(
          series: [
            FusionLineSeries(
              name: 'QuadTree Test',
              dataPoints: dataPoints,
              color: const Color(0xFF6366F1),
              lineWidth: 2.0,
              showMarkers: true,
              markerSize: 4.0,
            ),
          ],
          config: const FusionLineChartConfiguration(
            enableMarkers: true,
            enableTooltip: true,
            tooltipBehavior: FusionTooltipBehavior(
              trackballMode: FusionTooltipTrackballMode.magnetic,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildTooltipStrategiesDemo() {
  final data = [
    FusionPieDataPoint(35, label: 'Sales', color: const Color(0xFF6366F1)),
    FusionPieDataPoint(25, label: 'Marketing', color: const Color(0xFF22C55E)),
    FusionPieDataPoint(
      20,
      label: 'Engineering',
      color: const Color(0xFFF59E0B),
    ),
    FusionPieDataPoint(20, label: 'Support', color: const Color(0xFFA855F7)),
  ];

  return Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: _TooltipStrategyCard(
                strategy: 'onTimer',
                description: '3s auto-dismiss',
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: data),
                  config: const FusionPieChartConfiguration(
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                    tooltipBehavior: FusionTooltipBehavior(
                      dismissStrategy: FusionDismissStrategy.onTimer,
                      duration: Duration(seconds: 3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TooltipStrategyCard(
                strategy: 'onRelease',
                description: 'Instant dismiss',
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: data),
                  config: const FusionPieChartConfiguration(
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                    tooltipBehavior: FusionTooltipBehavior(
                      dismissStrategy: FusionDismissStrategy.onRelease,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: _TooltipStrategyCard(
                strategy: 'smart',
                description: 'Context-aware',
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: data),
                  config: const FusionPieChartConfiguration(
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                    tooltipBehavior: FusionTooltipBehavior(
                      dismissStrategy: FusionDismissStrategy.smart,
                      hapticFeedback: true,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TooltipStrategyCard(
                strategy: 'never',
                description: 'Tap outside',
                child: FusionPieChart(
                  series: FusionPieSeries(dataPoints: data),
                  config: const FusionPieChartConfiguration(
                    enableLegend: false,
                    labelPosition: PieLabelPosition.none,
                    tooltipBehavior: FusionTooltipBehavior(
                      dismissStrategy: FusionDismissStrategy.never,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _TooltipStrategyCard extends StatelessWidget {
  final String strategy;
  final String description;
  final Widget child;

  const _TooltipStrategyCard({
    required this.strategy,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  strategy,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

Widget _buildSmartLabelsDemo() {
  return Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Inside Labels (auto-contrast)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: FusionPieChart(
                      series: FusionPieSeries(
                        dataPoints: [
                          FusionPieDataPoint(
                            40,
                            label: 'Dark',
                            color: const Color(0xFF1E293B),
                          ),
                          FusionPieDataPoint(
                            30,
                            label: 'Light',
                            color: const Color(0xFFFEF3C7),
                          ),
                          FusionPieDataPoint(
                            20,
                            label: 'Blue',
                            color: const Color(0xFF6366F1),
                          ),
                          FusionPieDataPoint(
                            10,
                            label: 'Green',
                            color: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                      config: const FusionPieChartConfiguration(
                        labelPosition: PieLabelPosition.inside,
                        showPercentages: true,
                        enableLegend: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Outside Labels (L-shaped)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: FusionPieChart(
                      series: FusionPieSeries(
                        dataPoints: [
                          FusionPieDataPoint(
                            35,
                            label: 'Sales',
                            color: const Color(0xFF6366F1),
                          ),
                          FusionPieDataPoint(
                            25,
                            label: 'Marketing',
                            color: const Color(0xFF22C55E),
                          ),
                          FusionPieDataPoint(
                            20,
                            label: 'Engineering',
                            color: const Color(0xFFF59E0B),
                          ),
                          FusionPieDataPoint(
                            15,
                            label: 'Support',
                            color: const Color(0xFFA855F7),
                          ),
                          FusionPieDataPoint(
                            5,
                            label: 'Other',
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                      config: const FusionPieChartConfiguration(
                        labelPosition: PieLabelPosition.outside,
                        showPercentages: true,
                        enableLegend: false,
                        labelConnectorLength: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Corner Radius (Pie)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: FusionPieChart(
                      series: FusionPieSeries(
                        dataPoints: [
                          FusionPieDataPoint(
                            35,
                            label: 'A',
                            color: const Color(0xFF6366F1),
                          ),
                          FusionPieDataPoint(
                            25,
                            label: 'B',
                            color: const Color(0xFF22C55E),
                          ),
                          FusionPieDataPoint(
                            20,
                            label: 'C',
                            color: const Color(0xFFF59E0B),
                          ),
                          FusionPieDataPoint(
                            20,
                            label: 'D',
                            color: const Color(0xFFA855F7),
                          ),
                        ],
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                      config: const FusionPieChartConfiguration(
                        cornerRadius: 10.0,
                        gapBetweenSlices: 2.0,
                        labelPosition: PieLabelPosition.none,
                        enableLegend: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Corner Radius (Donut)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: FusionPieChart(
                      series: FusionPieSeries(
                        dataPoints: [
                          FusionPieDataPoint(
                            35,
                            label: 'A',
                            color: const Color(0xFF6366F1),
                          ),
                          FusionPieDataPoint(
                            25,
                            label: 'B',
                            color: const Color(0xFF22C55E),
                          ),
                          FusionPieDataPoint(
                            20,
                            label: 'C',
                            color: const Color(0xFFF59E0B),
                          ),
                          FusionPieDataPoint(
                            20,
                            label: 'D',
                            color: const Color(0xFFA855F7),
                          ),
                        ],
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                      config: const FusionPieChartConfiguration(
                        innerRadiusPercent: 0.5,
                        cornerRadius: 8.0,
                        gapBetweenSlices: 3.0,
                        labelPosition: PieLabelPosition.none,
                        enableLegend: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildPerformanceDemo() {
  return Column(
    children: [
      _PerformanceMetricCard(
        icon: Icons.recycling,
        title: 'Paint Object Pooling',
        value: '~0 GC',
        description:
            'Reuses Paint objects instead of creating new ones each frame',
        color: const Color(0xFF10B981),
      ),
      const SizedBox(height: 8),
      _PerformanceMetricCard(
        icon: Icons.route,
        title: 'Path Caching',
        value: 'LRU 100',
        description: 'Caches computed paths with automatic eviction',
        color: const Color(0xFF6366F1),
      ),
      const SizedBox(height: 8),
      _PerformanceMetricCard(
        icon: Icons.grid_4x4,
        title: 'Dirty Region Tracking',
        value: 'Δ only',
        description: 'Only repaints regions that actually changed',
        color: const Color(0xFF8B5CF6),
      ),
      const SizedBox(height: 8),
      _PerformanceMetricCard(
        icon: Icons.pie_chart,
        title: 'Segment Pre-computation',
        value: '1x calc',
        description: 'Angles, paths, centroids computed once per layout',
        color: const Color(0xFFF59E0B),
      ),
    ],
  );
}

class _PerformanceMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String description;
  final Color color;

  const _PerformanceMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAPIComparisonDemo() {
  return Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.close, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Verbose API',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Text('''
series: <PieSeries>[
  PieSeries(
    dataLabelSettings: 
      DataLabelSettings(
        isVisible: true,
        labelPosition: 
          ChartDataLabelPosition
            .outside,
        connectorLineSettings: 
          ConnectorLineSettings(
            length: '20%',
            type: ConnectorType
              .curve,
          ),
      ),
  ),
]''', style: TextStyle(fontFamily: 'monospace', fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Clean API',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Text('''
config: 
  FusionPieChartConfiguration(
    labelPosition: 
      PieLabelPosition.outside,
    labelConnectorLength: 20,
    showLabels: true,
  )
''', style: TextStyle(fontFamily: 'monospace', fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.lightbulb, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Result: ~60% fewer lines of code, easier to read and maintain',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// =============================================================================
// STANDALONE MAIN
// =============================================================================

void main() {
  runApp(
    MaterialApp(
      title: 'Feature Highlights',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      ),
      home: const FeatureHighlights(),
    ),
  );
}

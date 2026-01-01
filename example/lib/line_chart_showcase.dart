import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

// =============================================================================
// LINE CHART SHOWCASE - Complete API Reference
// =============================================================================

/// Comprehensive Line Chart Showcase demonstrating all FusionLineChart capabilities.
class LineChartShowcase extends StatefulWidget {
  const LineChartShowcase({super.key});

  @override
  State<LineChartShowcase> createState() => _LineChartShowcaseState();
}

class _LineChartShowcaseState extends State<LineChartShowcase> {
  int _currentPage = 0;
  final _pageController = PageController();

  final List<_ShowcaseItem> _showcaseItems = [
    _ShowcaseItem(
      title: '1. Basic Line Chart',
      description: 'Simple line with area fill and gradient',
      code: '''
FusionLineChart(
  series: [
    FusionLineSeries(
      name: 'Revenue',
      dataPoints: [...],
      color: Color(0xFF6366F1),
      lineWidth: 2.5,
      showArea: true,
      areaOpacity: 0.3,
    ),
  ],
  xAxis: FusionAxisConfiguration(interval: 1),
  config: const FusionChartConfiguration(
    enableAnimation: true,
    animationDuration: Duration(milliseconds: 1200),
  ),
)''',
      builder: _buildBasicLineChart,
    ),
    _ShowcaseItem(
      title: '2. Multi-Series',
      description: 'Multiple lines with shared tooltip',
      code: '''
FusionLineChart(
  series: [
    FusionLineSeries(name: 'Product A', ...),
    FusionLineSeries(name: 'Product B', ...),
  ],
  config: FusionChartConfiguration(
    enableLegend: true,
    tooltipBehavior: FusionTooltipBehavior(
      shared: true,
    ),
  ),
)''',
      builder: _buildMultiSeriesChart,
    ),
    _ShowcaseItem(
      title: '3. Curved vs Sharp',
      description: 'Smooth Catmull-Rom curves with adjustable smoothness',
      code: '''
FusionLineSeries(
  isCurved: true,
  smoothness: 0.4,  // 0.0 = sharp, 1.0 = very smooth
)''',
      builder: _buildCurvedChart,
    ),
    _ShowcaseItem(
      title: '4. Markers & Labels',
      description: 'Data point markers with value labels',
      code: '''
FusionLineSeries(
  showMarkers: true,
  markerSize: 8.0,
  markerShape: MarkerShape.circle,
  showDataLabels: true,
  dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
)''',
      builder: _buildMarkersChart,
    ),
    _ShowcaseItem(
      title: '5. Crosshair & Trackball',
      description: 'Precision tracking with snap-to-point',
      code: '''
FusionChartConfiguration(
  enableCrosshair: true,
  crosshairBehavior: FusionCrosshairConfiguration(
    snapToDataPoint: true,
    showHorizontalLine: true,
    showVerticalLine: true,
  ),
)''',
      builder: _buildCrosshairChart,
    ),
    _ShowcaseItem(
      title: '6. Zoom & Pan',
      description: 'Pinch zoom, mouse wheel, selection zoom',
      code: '''
FusionChartConfiguration(
  enableZoom: true,
  enablePanning: true,
  zoomBehavior: FusionZoomConfiguration(
    enablePinchZoom: true,
    enableMouseWheelZoom: true,
  ),
  panBehavior: FusionPanConfiguration(
    panMode: FusionPanMode.both,
  ),
)''',
      builder: _buildZoomPanChart,
    ),
    _ShowcaseItem(
      title: '7. DateTime Axis',
      description: 'Time series with auto-formatted dates',
      code: '''
FusionLineChart(
  xAxis: FusionAxisConfiguration(
    title: 'Month',
    labelFormatter: (value) {
      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      return monthName(date.month);
    },
  ),
)''',
      builder: _buildDateTimeChart,
    ),
    _ShowcaseItem(
      title: '8. Large Dataset (LTTB)',
      description: '10,000 points downsampled for smooth 60fps',
      code: '''
// LTTB (Largest Triangle Three Buckets) 
// automatically reduces 10K → 500 points
// while preserving visual shape

FusionLineSeries(
  dataPoints: generateLargeDataset(10000),
  // LTTB applied automatically
)''',
      builder: _buildLargeDatasetChart,
    ),
    _ShowcaseItem(
      title: '9. Gradient Styling',
      description: 'Line and area gradients',
      code: '''
FusionLineSeries(
  gradient: LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  ),
  showArea: true,
  areaOpacity: 0.4,
)''',
      builder: _buildGradientChart,
    ),
    _ShowcaseItem(
      title: '10. Tooltip Behaviors',
      description: '5 dismiss strategies + haptic feedback',
      code: '''
FusionTooltipBehavior(
  activationMode: FusionTooltipActivationMode.singleTap,
  dismissStrategy: FusionDismissStrategy.smart,
  // Options: onRelease, onTimer, onReleaseDelayed, never, smart
  duration: Duration(seconds: 3),
  hapticFeedback: true,
)''',
      builder: _buildTooltipChart,
    ),
    _ShowcaseItem(
      title: '11. Dark Theme',
      description: 'Full dark theme support',
      code: '''
FusionChartConfiguration(
  theme: FusionDarkTheme(),
)''',
      builder: _buildDarkThemeChart,
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
        title: const Text('Line Chart Showcase'),
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
// SAMPLE DATA GENERATORS
// =============================================================================

List<FusionDataPoint> _generateMonthlyData() {
  return [
    FusionDataPoint(0, 30, label: 'Jan'),
    FusionDataPoint(1, 45, label: 'Feb'),
    FusionDataPoint(2, 38, label: 'Mar'),
    FusionDataPoint(3, 65, label: 'Apr'),
    FusionDataPoint(4, 52, label: 'May'),
    FusionDataPoint(5, 78, label: 'Jun'),
    FusionDataPoint(6, 85, label: 'Jul'),
    FusionDataPoint(7, 72, label: 'Aug'),
    FusionDataPoint(8, 90, label: 'Sep'),
    FusionDataPoint(9, 68, label: 'Oct'),
    FusionDataPoint(10, 95, label: 'Nov'),
    FusionDataPoint(11, 88, label: 'Dec'),
  ];
}

List<FusionDataPoint> _generateLargeDataset(int count) {
  final random = math.Random(42);
  double value = 50;
  return List.generate(count, (i) {
    value += (random.nextDouble() - 0.5) * 10;
    value = value.clamp(0, 100);
    return FusionDataPoint(i.toDouble(), value);
  });
}

// =============================================================================
// SHOWCASE BUILDERS
// =============================================================================

Widget _buildBasicLineChart() {
  return FusionLineChart(
    series: [
      FusionLineSeries(
        name: 'Revenue',
        dataPoints: _generateMonthlyData(),
        color: const Color(0xFF6366F1),
        lineWidth: 2.5,
        showArea: true,
        areaOpacity: 0.3,
        isCurved: true,
        smoothness: 0.3,
      ),
    ],
    xAxis: FusionAxisConfiguration(interval: 1),
    config: const FusionChartConfiguration(
      enableAnimation: true,
      animationDuration: Duration(milliseconds: 1200),
    ),
  );
}

Widget _buildMultiSeriesChart() {
  return FusionLineChart(
    series: [
      FusionLineSeries(
        name: 'Product A',
        dataPoints: [
          FusionDataPoint(0, 30),
          FusionDataPoint(1, 45),
          FusionDataPoint(2, 38),
          FusionDataPoint(3, 65),
          FusionDataPoint(4, 52),
          FusionDataPoint(5, 78),
        ],
        color: const Color(0xFF6366F1),
        lineWidth: 2.5,
      ),
      FusionLineSeries(
        name: 'Product B',
        dataPoints: [
          FusionDataPoint(0, 20),
          FusionDataPoint(1, 35),
          FusionDataPoint(2, 48),
          FusionDataPoint(3, 42),
          FusionDataPoint(4, 68),
          FusionDataPoint(5, 55),
        ],
        color: const Color(0xFF22C55E),
        lineWidth: 2.5,
      ),
      FusionLineSeries(
        name: 'Product C',
        dataPoints: [
          FusionDataPoint(0, 15),
          FusionDataPoint(1, 28),
          FusionDataPoint(2, 32),
          FusionDataPoint(3, 38),
          FusionDataPoint(4, 45),
          FusionDataPoint(5, 62),
        ],
        color: const Color(0xFFF59E0B),
        lineWidth: 2.5,
      ),
    ],
    config: const FusionChartConfiguration(
      enableLegend: true,
      tooltipBehavior: FusionTooltipBehavior(
        shared: true,
        trackballMode: FusionTooltipTrackballMode.magnetic,
      ),
    ),
  );
}

Widget _buildCurvedChart() {
  final data = _generateMonthlyData();

  return Column(
    children: [
      Expanded(
        child: FusionLineChart(
          title: 'Curved (smoothness: 0.4)',
          series: [
            FusionLineSeries(
              dataPoints: data,
              color: const Color(0xFF8B5CF6),
              lineWidth: 3.0,
              isCurved: true,
              smoothness: 0.4,
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionLineChart(
          title: 'Sharp (isCurved: false)',
          series: [
            FusionLineSeries(
              dataPoints: data,
              color: const Color(0xFFEC4899),
              lineWidth: 3.0,
              isCurved: false,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildMarkersChart() {
  return FusionLineChart(
    series: [
      FusionLineSeries(
        name: 'Circle Markers',
        dataPoints: [
          FusionDataPoint(0, 30),
          FusionDataPoint(1, 55),
          FusionDataPoint(2, 42),
          FusionDataPoint(3, 68),
          FusionDataPoint(4, 52),
          FusionDataPoint(5, 80),
        ],
        color: const Color(0xFF6366F1),
        lineWidth: 2.5,
        showMarkers: true,
        markerSize: 8.0,
        markerShape: MarkerShape.circle,
        showDataLabels: true,
        dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
      ),
    ],
    config: const FusionLineChartConfiguration(
      enableMarkers: true,
      enableDataLabels: true,
    ),
  );
}

Widget _buildCrosshairChart() {
  return FusionLineChart(
    title: 'Long press or drag to activate crosshair',
    series: [
      FusionLineSeries(
        dataPoints: _generateMonthlyData(),
        color: const Color(0xFF10B981),
        lineWidth: 2.5,
        isCurved: true,
      ),
    ],
    config: const FusionChartConfiguration(
      enableCrosshair: true,
      enableTooltip: true,
      crosshairBehavior: FusionCrosshairConfiguration(
        enabled: true,
        snapToDataPoint: true,
        showHorizontalLine: true,
        showVerticalLine: true,
        activationMode: FusionCrosshairActivationMode.longPress,
        showLabel: true,
      ),
    ),
  );
}

Widget _buildZoomPanChart() {
  return FusionLineChart(
    title: 'Pinch to zoom, drag to pan, double-tap to reset',
    series: [
      FusionLineSeries(
        dataPoints: _generateLargeDataset(100),
        color: const Color(0xFF3B82F6),
        lineWidth: 2.0,
        isCurved: true,
        smoothness: 0.2,
      ),
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
        minZoomLevel: 0.5,
        maxZoomLevel: 5.0,
        zoomMode: FusionZoomMode.both,
      ),
      panBehavior: FusionPanConfiguration(
        enabled: true,
        panMode: FusionPanMode.both,
      ),
    ),
  );
}

Widget _buildDateTimeChart() {
  // Generate datetime data points
  final now = DateTime(2024, 1, 1);
  final dataPoints = List.generate(12, (i) {
    final date = DateTime(now.year, now.month + i, 1);
    final value = 30 + (50 * math.sin(i * 0.5)).abs() + (i * 3);
    return FusionDataPoint(
      date.millisecondsSinceEpoch.toDouble(),
      value,
      label: _monthName(date.month),
    );
  });

  return FusionLineChart(
    title: 'Monthly Revenue 2024',
    series: [
      FusionLineSeries(
        dataPoints: dataPoints,
        color: const Color(0xFF8B5CF6),
        lineWidth: 2.5,
        showArea: true,
        areaOpacity: 0.2,
        isCurved: true,
      ),
    ],
    config: const FusionChartConfiguration(enableAnimation: true),
    xAxis: FusionAxisConfiguration(
      title: 'Month',
      labelFormatter: (value) {
        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
        return _monthName(date.month);
      },
    ),
    yAxis: FusionAxisConfiguration(
      title: 'Revenue (K)',
      labelFormatter: (value) => '\$${value.toStringAsFixed(0)}K',
    ),
  );
}

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

Widget _buildLargeDatasetChart() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.speed, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'LTTB downsampling: 10,000 points → ~500 visible points\n'
                'Maintains visual accuracy while ensuring 60fps rendering',
                style: TextStyle(fontSize: 12, color: Color(0xFF10B981)),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: FusionLineChart(
          series: [
            FusionLineSeries(
              name: '10K Points',
              dataPoints: _generateLargeDataset(10000),
              color: const Color(0xFF6366F1),
              lineWidth: 1.5,
            ),
          ],
          config: const FusionChartConfiguration(enableAnimation: false),
        ),
      ),
    ],
  );
}

Widget _buildGradientChart() {
  return FusionLineChart(
    series: [
      FusionLineSeries(
        dataPoints: _generateMonthlyData(),
        color: const Color(0xFF8B5CF6),
        lineWidth: 3.0,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        showArea: true,
        areaOpacity: 0.4,
        isCurved: true,
        smoothness: 0.3,
      ),
    ],
  );
}

Widget _buildTooltipChart() {
  return Column(
    children: [
      Expanded(
        child: FusionLineChart(
          title: 'Smart Dismiss (adapts to interaction)',
          series: [
            FusionLineSeries(
              dataPoints: _generateMonthlyData(),
              color: const Color(0xFF6366F1),
              lineWidth: 2.5,
              isCurved: true,
            ),
          ],
          config: const FusionChartConfiguration(
            enableTooltip: true,
            tooltipBehavior: FusionTooltipBehavior(
              activationMode: FusionTooltipActivationMode.singleTap,
              dismissStrategy: FusionDismissStrategy.smart,
              hapticFeedback: true,
              elevation: 4.0,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FusionLineChart(
          title: 'Timer Dismiss (3 seconds)',
          series: [
            FusionLineSeries(
              dataPoints: _generateMonthlyData(),
              color: const Color(0xFF22C55E),
              lineWidth: 2.5,
              isCurved: true,
            ),
          ],
          config: const FusionChartConfiguration(
            enableTooltip: true,
            tooltipBehavior: FusionTooltipBehavior(
              dismissStrategy: FusionDismissStrategy.onTimer,
              duration: Duration(seconds: 3),
            ),
          ),
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
    child: FusionLineChart(
      title: 'Dark Theme Analytics',
      series: [
        FusionLineSeries(
          name: 'Users',
          dataPoints: _generateMonthlyData(),
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
          showArea: true,
          areaOpacity: 0.3,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        theme: FusionDarkTheme(),
        enableLegend: true,
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
      title: 'Line Chart Showcase',
      debugShowCheckedModeBanner: false,
      home: LineChartShowcase(),
    ),
  );
}

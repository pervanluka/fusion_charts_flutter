import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/live/fusion_live_chart_controller.dart';
import 'package:fusion_charts_flutter/src/live/live_viewport_mode.dart';
import 'package:fusion_charts_flutter/src/live/retention_policy.dart';

/// Comprehensive showcase of live/real-time charting capabilities.
///
/// Demonstrates:
/// - Real-time data streaming
/// - Multiple viewport modes
/// - Retention policies
/// - Pause/resume functionality
/// - Multiple series
/// - Live bar charts
class LiveChartShowcase extends StatelessWidget {
  const LiveChartShowcase({super.key});

  /// All showcase items in a flat list for ListView.builder.
  /// This ensures widgets are disposed when scrolled out of view,
  /// preventing timer leaks.
  static final List<_ShowcaseItem> _items = [
    const _ShowcaseItem.header(),
    const _ShowcaseItem.sectionHeader(
      title: '📡 Real-Time Streaming',
      subtitle: 'Live data visualization',
    ),
    const _ShowcaseItem.example(
      title: 'Basic Live Line Chart',
      description: 'Simulated sensor data at 10Hz',
      hint: 'Watch data stream in real-time',
      builder: _BasicLiveLineExample.new,
    ),
    const _ShowcaseItem.example(
      title: 'Multiple Live Series',
      description: 'Temperature & humidity sensors',
      hint: 'Multiple data streams on one chart',
      builder: _MultipleLiveSeriesExample.new,
    ),
    const _ShowcaseItem.example(
      title: 'High Frequency Data',
      description: 'Streaming at 60Hz with downsampling',
      hint: 'Efficient rendering of high-speed data',
      builder: _HighFrequencyExample.new,
    ),
    const _ShowcaseItem.sectionHeader(
      title: '🎯 Viewport Modes',
      subtitle: 'Control how the chart scrolls',
    ),
    const _ShowcaseItem.example(
      title: 'Auto-Scroll (Duration)',
      description: 'Show last 10 seconds of data',
      hint: 'Viewport follows latest data by time',
      builder: _AutoScrollDurationExample.new,
    ),
    const _ShowcaseItem.example(
      title: 'Auto-Scroll (Points)',
      description: 'Show last 50 data points',
      hint: 'Viewport follows latest data by count',
      builder: _AutoScrollPointsExample.new,
    ),
    const _ShowcaseItem.example(
      title: 'Fill Then Scroll',
      description: 'Fill viewport, then start scrolling',
      hint: 'Chart fills before scrolling begins',
      builder: _FillThenScrollExample.new,
    ),
    const _ShowcaseItem.example(
      title: 'Auto-Scroll Until Interaction',
      description: 'Auto-scrolls until you pan/zoom',
      hint: 'Scroll stops when user interacts',
      builder: _AutoScrollUntilInteractionExample.new,
    ),
    const _ShowcaseItem.sectionHeader(
      title: '🗃️ Retention Policies',
      subtitle: 'Manage memory for long sessions',
    ),
    const _ShowcaseItem.example(
      title: 'Rolling Count (100 points)',
      description: 'Keep last 100 points per series',
      hint: 'Memory bounded by point count',
      builder: _RollingCountExample.new,
    ),
    const _ShowcaseItem.example(
      title: 'Rolling Duration (30s)',
      description: 'Keep last 30 seconds of data',
      hint: 'Memory bounded by time',
      builder: _RollingDurationExample.new,
    ),
    const _ShowcaseItem.sectionHeader(
      title: '⏸️ Controls',
      subtitle: 'Interactive live chart controls',
    ),
    const _ShowcaseItem.example(
      title: 'Pause / Resume',
      description: 'Freeze display while data streams',
      hint: 'Tap button to pause/resume',
      builder: _PauseResumeExample.new,
    ),
    const _ShowcaseItem.example(
      title: 'Clear & Restart',
      description: 'Reset the live chart',
      hint: 'Tap to clear all data',
      builder: _ClearRestartExample.new,
    ),
    const _ShowcaseItem.sectionHeader(
      title: '📊 Live Bar Charts',
      subtitle: 'Real-time categorical data',
    ),
    const _ShowcaseItem.example(
      title: 'Live Sales Dashboard',
      description: 'Updating sales by region',
      hint: 'Bar chart with live updates',
      builder: _LiveBarChartExample.new,
    ),
    const _ShowcaseItem.spacer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Charts Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About Live Charts',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        // This ensures widgets are properly disposed when scrolled far enough
        // out of view, preventing timer leaks
        cacheExtent: 100,
        itemBuilder: (context, index) {
          final item = _items[index];
          return item.build(context);
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.stream, color: Color(0xFF10B981)),
            SizedBox(width: 12),
            Text('Live Charts'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FusionLiveChartController provides efficient real-time '
                'data visualization with:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _InfoItem(
                icon: Icons.speed,
                title: '60fps Frame Coalescing',
                description: 'Batches rapid updates for smooth rendering',
              ),
              _InfoItem(
                icon: Icons.data_array,
                title: 'Ring Buffer Storage',
                description: 'O(1) operations with automatic eviction',
              ),
              _InfoItem(
                icon: Icons.memory,
                title: 'Retention Policies',
                description: 'Control memory usage for long sessions',
              ),
              _InfoItem(
                icon: Icons.auto_graph,
                title: 'Viewport Modes',
                description: 'Auto-scroll, fixed, fill-then-scroll',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF059669)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF059669),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a single item in the showcase list.
///
/// Using a flat list with builder pattern ensures widgets are properly
/// disposed when scrolled out of view, preventing timer leaks.
class _ShowcaseItem {
  final _ShowcaseItemType type;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? hint;
  final Widget Function()? builder;

  const _ShowcaseItem._({
    required this.type,
    this.title,
    this.subtitle,
    this.description,
    this.hint,
    this.builder,
  });

  const _ShowcaseItem.header() : this._(type: _ShowcaseItemType.header);

  const _ShowcaseItem.sectionHeader({
    required String title,
    required String subtitle,
  }) : this._(
         type: _ShowcaseItemType.sectionHeader,
         title: title,
         subtitle: subtitle,
       );

  const _ShowcaseItem.example({
    required String title,
    required String description,
    required String hint,
    required Widget Function() builder,
  }) : this._(
         type: _ShowcaseItemType.example,
         title: title,
         description: description,
         hint: hint,
         builder: builder,
       );

  const _ShowcaseItem.spacer() : this._(type: _ShowcaseItemType.spacer);

  Widget build(BuildContext context) {
    switch (type) {
      case _ShowcaseItemType.header:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildHeader(),
        );
      case _ShowcaseItemType.sectionHeader:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle!, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        );
      case _ShowcaseItemType.example:
        return _ExampleCard(
          title: title!,
          description: description!,
          hint: hint!,
          // Builder creates the widget lazily when needed
          child: builder!(),
        );
      case _ShowcaseItemType.spacer:
        return const SizedBox(height: 32);
    }
  }

  static Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF059669).withValues(alpha: 0.1),
            const Color(0xFF10B981).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stream,
                  color: Color(0xFF059669),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Streaming Charts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Real-time data visualization at up to 60fps',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeatureChip(icon: Icons.speed, label: '60fps rendering'),
              _FeatureChip(icon: Icons.memory, label: 'Memory efficient'),
              _FeatureChip(icon: Icons.auto_graph, label: 'Auto-scroll'),
              _FeatureChip(icon: Icons.pause_circle, label: 'Pause/Resume'),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ShowcaseItemType { header, sectionHeader, example, spacer }

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final String hint;
  final Widget child;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 14,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      hint,
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: child),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EXAMPLE WIDGETS
// =============================================================================

/// Base class for live chart examples with common setup/teardown.
abstract class _LiveExampleState<T extends StatefulWidget> extends State<T> {
  late FusionLiveChartController controller;
  Timer? timer;

  RetentionPolicy get retentionPolicy =>
      const RetentionPolicy.rollingCount(200);

  @override
  void initState() {
    super.initState();
    controller = FusionLiveChartController(retentionPolicy: retentionPolicy);
    startStreaming();
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void startStreaming();
}

// -----------------------------------------------------------------------------
// Basic Live Line Example
// -----------------------------------------------------------------------------

class _BasicLiveLineExample extends StatefulWidget {
  const _BasicLiveLineExample();

  @override
  State<_BasicLiveLineExample> createState() => _BasicLiveLineExampleState();
}

class _BasicLiveLineExampleState
    extends _LiveExampleState<_BasicLiveLineExample> {
  final _random = Random();
  double _value = 50;

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      // Random walk
      _value += (_random.nextDouble() - 0.5) * 5;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'sensor',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: controller,
      liveViewportMode: const LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 10),
      ),
      series: [
        FusionLineSeries(
          name: 'sensor',
          dataPoints: const [],
          color: const Color(0xFF10B981),
          lineWidth: 2,
        ),
      ],
      config: FusionChartConfiguration(
        enableTooltip: true,
        enableCrosshair: true,
        // For live charts, screenPosition anchor works better - tooltip follows
        // the finger position rather than getting stuck on a scrolling data point
        interactionAnchorMode: InteractionAnchorMode.screenPosition,
        tooltipBehavior: const FusionTooltipBehavior(
          // Follow mode is better for live charts - smooth tracking
          trackballMode: FusionTooltipTrackballMode.follow,
          dismissStrategy: FusionDismissStrategy.onRelease,
          // Reduce threshold for more responsive tracking
          trackballUpdateThreshold: 2.0,
        ),
        crosshairBehavior: FusionCrosshairConfiguration(
          snapToDataPoint: false,
          // Format timestamp as HH:MM:SS for crosshair X-axis label
          xLabelFormatter: (value, point) {
            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            return '${date.hour.toString().padLeft(2, '0')}:'
                '${date.minute.toString().padLeft(2, '0')}:'
                '${date.second.toString().padLeft(2, '0')}';
          },
          // Format Y value with unit
          yLabelFormatter: (value, point) => '${value.toStringAsFixed(1)}%',
        ),
      ),
      xAxis: FusionAxisConfiguration(
        // Use labelGenerator to show edge labels (including current time)
        labelGenerator: (bounds, availableSize, isVertical) {
          final range = bounds.max - bounds.min;
          // Show 5 labels including edges
          return [
            bounds.min,
            bounds.min + range * 0.25,
            bounds.min + range * 0.5,
            bounds.min + range * 0.75,
            bounds.max,
          ];
        },
        labelFormatter: (value) {
          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          return '${date.second}s';
        },
      ),
      yAxis: const FusionAxisConfiguration(min: 0, max: 100),
    );
  }
}

// -----------------------------------------------------------------------------
// Multiple Live Series Example
// -----------------------------------------------------------------------------

class _MultipleLiveSeriesExample extends StatefulWidget {
  const _MultipleLiveSeriesExample();

  @override
  State<_MultipleLiveSeriesExample> createState() =>
      _MultipleLiveSeriesExampleState();
}

class _MultipleLiveSeriesExampleState
    extends _LiveExampleState<_MultipleLiveSeriesExample> {
  final _random = Random();
  double _temp = 22;
  double _humidity = 55;

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();

      // Temperature (18-28°C range)
      _temp += (_random.nextDouble() - 0.5) * 0.5;
      _temp = _temp.clamp(18.0, 28.0);

      // Humidity (40-70% range)
      _humidity += (_random.nextDouble() - 0.5) * 2;
      _humidity = _humidity.clamp(40.0, 70.0);

      controller.addPoint('temp', FusionDataPoint(now, _temp));
      controller.addPoint('humidity', FusionDataPoint(now, _humidity));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: controller,
      liveViewportMode: const LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 15),
      ),
      series: [
        FusionLineSeries(
          name: 'temp',
          dataPoints: const [],
          color: const Color(0xFFEF4444),
          lineWidth: 2,
        ),
        FusionLineSeries(
          name: 'humidity',
          dataPoints: const [],
          color: const Color(0xFF3B82F6),
          lineWidth: 2,
        ),
      ],
      config: const FusionChartConfiguration(enableTooltip: true),
      xAxis: FusionAxisConfiguration(
        labelFormatter: (value) {
          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          return '${date.second}s';
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// High Frequency Example
// -----------------------------------------------------------------------------

class _HighFrequencyExample extends StatefulWidget {
  const _HighFrequencyExample();

  @override
  State<_HighFrequencyExample> createState() => _HighFrequencyExampleState();
}

class _HighFrequencyExampleState
    extends _LiveExampleState<_HighFrequencyExample> {
  final _random = Random();
  double _phase = 0;

  @override
  RetentionPolicy get retentionPolicy =>
      const RetentionPolicy.rollingCount(500);

  @override
  void startStreaming() {
    // 60Hz updates
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();

      // Sine wave with noise
      _phase += 0.1;
      final value = 50 + sin(_phase) * 30 + (_random.nextDouble() - 0.5) * 10;

      controller.addPoint('signal', FusionDataPoint(now, value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: controller,
      liveViewportMode: const LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 5),
      ),
      series: [
        FusionLineSeries(
          name: 'signal',
          dataPoints: const [],
          color: const Color(0xFF8B5CF6),
          lineWidth: 1.5,
        ),
      ],
      config: const FusionChartConfiguration(
        enableTooltip: false,
        enableCrosshair: false,
      ),
      yAxis: const FusionAxisConfiguration(min: 0, max: 100),
    );
  }
}

// -----------------------------------------------------------------------------
// Auto-Scroll Duration Example
// -----------------------------------------------------------------------------

class _AutoScrollDurationExample extends StatefulWidget {
  const _AutoScrollDurationExample();

  @override
  State<_AutoScrollDurationExample> createState() =>
      _AutoScrollDurationExampleState();
}

class _AutoScrollDurationExampleState
    extends _LiveExampleState<_AutoScrollDurationExample> {
  final _random = Random();
  double _value = 50;

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _value += (_random.nextDouble() - 0.5) * 8;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: controller,
      liveViewportMode: const LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 10),
        leadingPadding: Duration(milliseconds: 500),
      ),
      series: [
        FusionLineSeries(
          name: 'data',
          dataPoints: const [],
          color: const Color(0xFF06B6D4),
          lineWidth: 2,
        ),
      ],
      yAxis: const FusionAxisConfiguration(min: 0, max: 100),
    );
  }
}

// -----------------------------------------------------------------------------
// Auto-Scroll Points Example
// -----------------------------------------------------------------------------

class _AutoScrollPointsExample extends StatefulWidget {
  const _AutoScrollPointsExample();

  @override
  State<_AutoScrollPointsExample> createState() =>
      _AutoScrollPointsExampleState();
}

class _AutoScrollPointsExampleState
    extends _LiveExampleState<_AutoScrollPointsExample> {
  final _random = Random();
  double _value = 50;

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      _value += (_random.nextDouble() - 0.5) * 10;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: controller,
      liveViewportMode: const LiveViewportMode.autoScrollPoints(
        visiblePoints: 50,
        leadingPoints: 2,
      ),
      series: [
        FusionLineSeries(
          name: 'data',
          dataPoints: const [],
          color: const Color(0xFFF59E0B),
          lineWidth: 2,
        ),
      ],
      yAxis: const FusionAxisConfiguration(min: 0, max: 100),
    );
  }
}

// -----------------------------------------------------------------------------
// Fill Then Scroll Example
// -----------------------------------------------------------------------------

class _FillThenScrollExample extends StatefulWidget {
  const _FillThenScrollExample();

  @override
  State<_FillThenScrollExample> createState() => _FillThenScrollExampleState();
}

class _FillThenScrollExampleState
    extends _LiveExampleState<_FillThenScrollExample> {
  final _random = Random();
  double _value = 50;

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _value += (_random.nextDouble() - 0.5) * 6;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: controller,
      liveViewportMode: const LiveViewportMode.fillThenScroll(
        maxDuration: Duration(seconds: 15),
      ),
      series: [
        FusionLineSeries(
          name: 'data',
          dataPoints: const [],
          color: const Color(0xFFEC4899),
          lineWidth: 2,
        ),
      ],
      yAxis: const FusionAxisConfiguration(min: 0, max: 100),
    );
  }
}

// -----------------------------------------------------------------------------
// Auto-Scroll Until Interaction Example
// -----------------------------------------------------------------------------

class _AutoScrollUntilInteractionExample extends StatefulWidget {
  const _AutoScrollUntilInteractionExample();

  @override
  State<_AutoScrollUntilInteractionExample> createState() =>
      _AutoScrollUntilInteractionExampleState();
}

class _AutoScrollUntilInteractionExampleState
    extends _LiveExampleState<_AutoScrollUntilInteractionExample> {
  final _random = Random();
  double _value = 50;

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _value += (_random.nextDouble() - 0.5) * 5;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: controller,
      liveViewportMode: const LiveViewportMode.autoScrollUntilInteraction(
        visibleDuration: Duration(seconds: 10),
      ),
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
      ),
      series: [
        FusionLineSeries(
          name: 'data',
          dataPoints: const [],
          color: const Color(0xFF14B8A6),
          lineWidth: 2,
        ),
      ],
      yAxis: const FusionAxisConfiguration(min: 0, max: 100),
    );
  }
}

// -----------------------------------------------------------------------------
// Rolling Count Example
// -----------------------------------------------------------------------------

class _RollingCountExample extends StatefulWidget {
  const _RollingCountExample();

  @override
  State<_RollingCountExample> createState() => _RollingCountExampleState();
}

class _RollingCountExampleState
    extends _LiveExampleState<_RollingCountExample> {
  final _random = Random();
  double _value = 50;
  int _pointCount = 0;

  @override
  RetentionPolicy get retentionPolicy =>
      const RetentionPolicy.rollingCount(100);

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _value += (_random.nextDouble() - 0.5) * 8;
      _value = _value.clamp(0.0, 100.0);
      _pointCount++;

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final actualPoints = controller.getPoints('data').length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Added: $_pointCount', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Text(
                'In buffer: $actualPoints / 100',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FusionLineChart(
            liveController: controller,
            liveViewportMode: const LiveViewportMode.autoScrollPoints(
              visiblePoints: 100,
            ),
            series: [
              FusionLineSeries(
                name: 'data',
                dataPoints: const [],
                color: const Color(0xFF6366F1),
                lineWidth: 2,
              ),
            ],
            yAxis: const FusionAxisConfiguration(min: 0, max: 100),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Rolling Duration Example
// -----------------------------------------------------------------------------

class _RollingDurationExample extends StatefulWidget {
  const _RollingDurationExample();

  @override
  State<_RollingDurationExample> createState() =>
      _RollingDurationExampleState();
}

class _RollingDurationExampleState
    extends _LiveExampleState<_RollingDurationExample> {
  final _random = Random();
  double _value = 50;

  @override
  RetentionPolicy get retentionPolicy =>
      const RetentionPolicy.rollingDuration(Duration(seconds: 30));

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _value += (_random.nextDouble() - 0.5) * 6;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = controller.getPoints('data');
    final duration = points.length > 1
        ? ((points.last.x - points.first.x) / 1000).toStringAsFixed(1)
        : '0';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Buffer span: ${duration}s / 30s max',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF59E0B),
            ),
          ),
        ),
        Expanded(
          child: FusionLineChart(
            liveController: controller,
            liveViewportMode: const LiveViewportMode.autoScroll(
              visibleDuration: Duration(seconds: 15),
            ),
            series: [
              FusionLineSeries(
                name: 'data',
                dataPoints: const [],
                color: const Color(0xFFF59E0B),
                lineWidth: 2,
              ),
            ],
            yAxis: const FusionAxisConfiguration(min: 0, max: 100),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Pause/Resume Example
// -----------------------------------------------------------------------------

class _PauseResumeExample extends StatefulWidget {
  const _PauseResumeExample();

  @override
  State<_PauseResumeExample> createState() => _PauseResumeExampleState();
}

class _PauseResumeExampleState extends _LiveExampleState<_PauseResumeExample> {
  final _random = Random();
  double _value = 50;
  bool _isPaused = false;

  @override
  void startStreaming() {
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _value += (_random.nextDouble() - 0.5) * 6;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        // Stop both the timer AND pause the controller display
        timer?.cancel();
        timer = null;
        controller.pause();
      } else {
        // Resume data streaming and controller display
        controller.resume();
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton.icon(
            onPressed: _togglePause,
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(_isPaused ? 'Resume' : 'Pause'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPaused
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: FusionLineChart(
            liveController: controller,
            liveViewportMode: const LiveViewportMode.autoScroll(
              visibleDuration: Duration(seconds: 10),
            ),
            series: [
              FusionLineSeries(
                name: 'data',
                dataPoints: const [],
                color: _isPaused
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF3B82F6),
                lineWidth: 2,
              ),
            ],
            yAxis: const FusionAxisConfiguration(min: 0, max: 100),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Clear/Restart Example
// -----------------------------------------------------------------------------

class _ClearRestartExample extends StatefulWidget {
  const _ClearRestartExample();

  @override
  State<_ClearRestartExample> createState() => _ClearRestartExampleState();
}

class _ClearRestartExampleState
    extends _LiveExampleState<_ClearRestartExample> {
  final _random = Random();
  double _value = 50;

  @override
  void startStreaming() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _value += (_random.nextDouble() - 0.5) * 6;
      _value = _value.clamp(0.0, 100.0);

      controller.addPoint(
        'data',
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          _value,
        ),
      );
    });
  }

  void _clearData() {
    controller.clear();
    _value = 50;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton.icon(
            onPressed: _clearData,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear & Restart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: FusionLineChart(
            liveController: controller,
            liveViewportMode: const LiveViewportMode.autoScroll(
              visibleDuration: Duration(seconds: 10),
            ),
            series: [
              FusionLineSeries(
                name: 'data',
                dataPoints: const [],
                color: const Color(0xFFF59E0B),
                lineWidth: 2,
              ),
            ],
            yAxis: const FusionAxisConfiguration(min: 0, max: 100),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Live Bar Chart Example
// -----------------------------------------------------------------------------

class _LiveBarChartExample extends StatefulWidget {
  const _LiveBarChartExample();

  @override
  State<_LiveBarChartExample> createState() => _LiveBarChartExampleState();
}

class _LiveBarChartExampleState extends State<_LiveBarChartExample> {
  late FusionLiveChartController controller;
  Timer? timer;
  final _random = Random();
  final _regions = ['North', 'South', 'East', 'West'];
  final _values = <String, double>{};

  @override
  void initState() {
    super.initState();
    controller = FusionLiveChartController(
      retentionPolicy: const RetentionPolicy.rollingCount(4),
    );

    // Initialize values
    for (var i = 0; i < _regions.length; i++) {
      _values[_regions[i]] = 50 + _random.nextDouble() * 50;
      controller.addPoint(
        'sales',
        FusionDataPoint(
          i.toDouble(),
          _values[_regions[i]]!,
          label: _regions[i],
        ),
      );
    }

    // Update values periodically
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      controller.clear('sales');

      for (var i = 0; i < _regions.length; i++) {
        _values[_regions[i]] =
            (_values[_regions[i]]! + (_random.nextDouble() - 0.4) * 15).clamp(
              20.0,
              150.0,
            );
        controller.addPoint(
          'sales',
          FusionDataPoint(
            i.toDouble(),
            _values[_regions[i]]!,
            label: _regions[i],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      liveController: controller,
      series: [
        FusionBarSeries(
          name: 'sales',
          dataPoints: const [],
          color: const Color(0xFF8B5CF6),
        ),
      ],
      config: const FusionBarChartConfiguration(
        enableTooltip: true,
        barWidthRatio: 0.6,
        borderRadius: 6,
      ),
      yAxis: const FusionAxisConfiguration(min: 0, max: 160),
    );
  }
}

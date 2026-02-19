import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

/// Comprehensive showcase of zoom and pan capabilities.
///
/// Demonstrates:
/// - Pinch zoom (mobile)
/// - Mouse wheel zoom (desktop)
/// - Double-tap zoom
/// - Selection zoom (desktop)
/// - Pan constraints
/// - Zoom limits
/// - Animation options
class ZoomPanShowcase extends StatelessWidget {
  const ZoomPanShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoom & Pan Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About Zoom & Pan',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection(
            title: '📱 Mobile Gestures',
            subtitle: 'Pinch to zoom, drag to pan',
            examples: [
              _ExampleCard(
                title: 'Pinch Zoom Only',
                description: 'Two-finger pinch to zoom in/out',
                hint: '📱 Pinch with two fingers to zoom • Double-tap to reset',
                child: const _PinchZoomOnlyExample(),
              ),
              _ExampleCard(
                title: 'Pan Only',
                description: 'Drag to navigate the chart',
                hint: '📱 Drag to pan the chart view',
                child: const _PanOnlyExample(),
              ),
              _ExampleCard(
                title: 'Zoom + Pan Combined',
                description: 'Full mobile navigation',
                hint: '📱 Pinch to zoom • Drag to pan • Double-tap to reset',
                child: const _ZoomAndPanExample(),
              ),
            ],
          ),
          _buildSection(
            title: '🖱️ Desktop Features',
            subtitle: 'Mouse wheel, double-tap, selection zoom',
            examples: [
              _ExampleCard(
                title: 'Mouse Wheel Zoom',
                description: 'Scroll to zoom at cursor position',
                hint:
                    '🖱️ Ctrl + Scroll (Win/Linux) or ⌘ + Scroll (Mac) to zoom',
                child: const _MouseWheelZoomExample(),
              ),
              _ExampleCard(
                title: 'Double-Tap Zoom',
                description: 'Double-tap to zoom in, repeat to reset',
                hint:
                    '🖱️ Double-click to zoom 2x • Double-click again to reset',
                child: const _DoubleTapZoomExample(),
              ),
              _ExampleCard(
                title: 'Selection Zoom',
                description: 'Shift + drag to select area (desktop)',
                hint: '🖱️ Hold Shift + Drag to draw selection rectangle',
                child: const _SelectionZoomExample(),
              ),
            ],
          ),
          _buildSection(
            title: '⚙️ Zoom Modes',
            subtitle: 'Control which axis can zoom',
            examples: [
              _ExampleCard(
                title: 'X-Axis Only',
                description: 'Zoom horizontally (time series)',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom X-axis only',
                child: const _ZoomXOnlyExample(),
              ),
              _ExampleCard(
                title: 'Y-Axis Only',
                description: 'Zoom vertically (value analysis)',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom Y-axis only',
                child: const _ZoomYOnlyExample(),
              ),
              _ExampleCard(
                title: 'Both Axes',
                description: 'Full 2D zoom control',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom both axes',
                child: const _ZoomBothAxesExample(),
              ),
            ],
          ),
          _buildSection(
            title: '📊 Pan Modes',
            subtitle: 'Control which axis can pan',
            examples: [
              _ExampleCard(
                title: 'X-Axis Only',
                description: 'Pan horizontally',
                hint: '🖱️ Drag left/right to pan horizontally',
                child: const _PanXOnlyExample(),
              ),
              _ExampleCard(
                title: 'Y-Axis Only',
                description: 'Pan vertically',
                hint: '🖱️ Drag up/down to pan vertically',
                child: const _PanYOnlyExample(),
              ),
              _ExampleCard(
                title: 'Both Axes',
                description: 'Free-form panning',
                hint: '🖱️ Drag in any direction to pan',
                child: const _PanBothAxesExample(),
              ),
            ],
          ),
          _buildSection(
            title: '🎯 Zoom Limits',
            subtitle: 'Constrain zoom range',
            examples: [
              _ExampleCard(
                title: 'Max Zoom In (10x)',
                description: 'Prevent over-zooming',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom (max 10x)',
                child: const _MaxZoomExample(),
              ),
              _ExampleCard(
                title: 'Max Zoom Out (0.5x)',
                description: 'Limit zoom-out for context',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom (min 0.5x)',
                child: const _MinZoomExample(),
              ),
              _ExampleCard(
                title: 'Zoom Speed Control',
                description: 'Slower zoom for precision',
                hint: '🖱️ Ctrl/⌘ + Scroll (reduced speed for finer control)',
                child: const _ZoomSpeedExample(),
              ),
            ],
          ),
          _buildSection(
            title: '🎬 Animation',
            subtitle: 'Smooth zoom transitions',
            examples: [
              _ExampleCard(
                title: 'Animated Zoom',
                description: 'Smooth double-tap zoom',
                hint: '🖱️ Double-click for animated zoom',
                child: const _AnimatedZoomExample(),
              ),
              _ExampleCard(
                title: 'Instant Zoom',
                description: 'No animation for speed',
                hint: '🖱️ Ctrl/⌘ + Scroll for instant zoom',
                child: const _InstantZoomExample(),
              ),
              _ExampleCard(
                title: 'Custom Curve',
                description: 'Elastic zoom animation',
                hint: '🖱️ Double-click for elastic animation effect',
                child: const _CustomCurveZoomExample(),
              ),
            ],
          ),
          _buildSection(
            title: '📈 Bar Chart Zoom/Pan',
            subtitle: 'Works with all chart types',
            examples: [
              _ExampleCard(
                title: 'Grouped Bars',
                description: 'Zoom into bar details',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom • Drag to pan',
                child: const _BarChartZoomExample(),
              ),
              _ExampleCard(
                title: 'Stacked Bars',
                description: 'Pan through large datasets',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom • Drag to pan',
                child: const _StackedBarZoomExample(),
              ),
              _ExampleCard(
                title: 'Large Dataset',
                description: 'Navigate 100+ bars efficiently',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom • Drag to pan through data',
                child: const _LargeBarDatasetExample(),
              ),
            ],
          ),
          _buildSection(
            title: '🔧 Advanced',
            subtitle: 'Complex configurations',
            examples: [
              _ExampleCard(
                title: 'Zoom with Tooltip',
                description: 'Tooltips hide during zoom',
                hint: '🖱️ Hover for tooltip • Ctrl/⌘ + Scroll to zoom',
                child: const _ZoomWithTooltipExample(),
              ),
              _ExampleCard(
                title: 'Programmatic Controls',
                description: 'Zoom in/out/reset buttons',
                hint: '🖱️ Use buttons below OR Ctrl/⌘ + Scroll to zoom',
                child: const _ProgrammaticZoomExample(),
              ),
              _ExampleCard(
                title: 'Multi-Series Navigation',
                description: 'Compare trends while zoomed',
                hint: '🖱️ Ctrl/⌘ + Scroll to zoom • Drag to pan',
                child: const _MultiSeriesZoomExample(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zoom & Pan Features',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Navigate large datasets with precision',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Fusion Charts provides professional-grade zoom and pan capabilities '
              'with intelligent constraints, smooth animations, and cross-platform support.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> examples,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        ...examples.map(
          (e) => Padding(padding: const EdgeInsets.only(bottom: 16), child: e),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.touch_app, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text('Gesture Guide'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mobile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              _GestureItem(
                icon: '👆',
                title: 'Pinch Zoom',
                description: 'Two fingers to zoom in/out',
              ),
              _GestureItem(
                icon: '👉',
                title: 'Pan',
                description: 'Drag with one finger',
              ),
              _GestureItem(
                icon: '👆👆',
                title: 'Double Tap',
                description: 'Double-tap to zoom in, repeat to reset',
              ),
              Divider(height: 24),
              Text(
                'Desktop / Web',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              _GestureItem(
                icon: '🖱️',
                title: 'Mouse Wheel Zoom',
                description: 'Ctrl + Scroll (Win/Linux) or ⌘ + Scroll (Mac)',
              ),
              _GestureItem(
                icon: '⇧',
                title: 'Selection Zoom',
                description: 'Shift + Drag to select rectangular area',
              ),
              _GestureItem(
                icon: '👆',
                title: 'Pan',
                description: 'Click and drag to pan the view',
              ),
              _GestureItem(
                icon: '👆👆',
                title: 'Double Click',
                description: 'Double-click to zoom 2x, repeat to reset',
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

class _GestureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _GestureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final String? hint;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
          if (hint != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hint!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
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

// =============================================================================
// MOBILE GESTURES
// =============================================================================

class _PinchZoomOnlyExample extends StatelessWidget {
  const _PinchZoomOnlyExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: false,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enablePinchZoom: true,
          enableMouseWheelZoom: false,
          enableDoubleTapZoom: false,
        ),
      ),
    );
  }
}

class _PanOnlyExample extends StatelessWidget {
  const _PanOnlyExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF22C55E),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: false,
        enablePanning: true,
        enableAnimation: false,
      ),
    );
  }
}

class _ZoomAndPanExample extends StatelessWidget {
  const _ZoomAndPanExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(enablePinchZoom: true),
      ),
    );
  }
}

// =============================================================================
// DESKTOP FEATURES
// =============================================================================

class _MouseWheelZoomExample extends StatelessWidget {
  const _MouseWheelZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF3B82F6),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enableMouseWheelZoom: true,
          enablePinchZoom: false,
          enableDoubleTapZoom: false,
        ),
      ),
    );
  }
}

class _DoubleTapZoomExample extends StatelessWidget {
  const _DoubleTapZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(80),
          color: const Color(0xFFEC4899),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enableDoubleTapZoom: true,
          enablePinchZoom: false,
          enableMouseWheelZoom: false,
        ),
      ),
    );
  }
}

class _SelectionZoomExample extends StatelessWidget {
  const _SelectionZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF10B981),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enableSelectionZoom: true,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
          enableDoubleTapZoom: true,
        ),
      ),
    );
  }
}

// =============================================================================
// ZOOM MODES
// =============================================================================

class _ZoomXOnlyExample extends StatelessWidget {
  const _ZoomXOnlyExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          zoomMode: FusionZoomMode.x,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

class _ZoomYOnlyExample extends StatelessWidget {
  const _ZoomYOnlyExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFFF59E0B),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          zoomMode: FusionZoomMode.y,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

class _ZoomBothAxesExample extends StatelessWidget {
  const _ZoomBothAxesExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          zoomMode: FusionZoomMode.both,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

// =============================================================================
// PAN MODES
// =============================================================================

class _PanXOnlyExample extends StatelessWidget {
  const _PanXOnlyExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF3B82F6),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enablePanning: true,
        enableAnimation: false,
        panBehavior: FusionPanConfiguration(panMode: FusionPanMode.x),
      ),
    );
  }
}

class _PanYOnlyExample extends StatelessWidget {
  const _PanYOnlyExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFFEC4899),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enablePanning: true,
        enableAnimation: false,
        panBehavior: FusionPanConfiguration(panMode: FusionPanMode.y),
      ),
    );
  }
}

class _PanBothAxesExample extends StatelessWidget {
  const _PanBothAxesExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(100),
          color: const Color(0xFF10B981),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enablePanning: true,
        enableAnimation: false,
        panBehavior: FusionPanConfiguration(panMode: FusionPanMode.both),
      ),
    );
  }
}

// =============================================================================
// ZOOM LIMITS
// =============================================================================

class _MaxZoomExample extends StatelessWidget {
  const _MaxZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(60),
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          maxZoomLevel: 10.0,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

class _MinZoomExample extends StatelessWidget {
  const _MinZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(60),
          color: const Color(0xFFF59E0B),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          minZoomLevel: 0.5,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

class _ZoomSpeedExample extends StatelessWidget {
  const _ZoomSpeedExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(60),
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          zoomSpeed: 0.5,
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

// =============================================================================
// ANIMATION
// =============================================================================

class _AnimatedZoomExample extends StatelessWidget {
  const _AnimatedZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(80),
          color: const Color(0xFF10B981),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enableDoubleTapZoom: true,
          animateZoom: true,
          zoomAnimationDuration: Duration(milliseconds: 400),
        ),
      ),
    );
  }
}

class _InstantZoomExample extends StatelessWidget {
  const _InstantZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(80),
          color: const Color(0xFF3B82F6),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enableDoubleTapZoom: true,
          animateZoom: false,
        ),
      ),
    );
  }
}

class _CustomCurveZoomExample extends StatelessWidget {
  const _CustomCurveZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(80),
          color: const Color(0xFFEC4899),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enableDoubleTapZoom: true,
          animateZoom: true,
          zoomAnimationDuration: Duration(milliseconds: 600),
          zoomAnimationCurve: Curves.elasticOut,
        ),
      ),
    );
  }
}

// =============================================================================
// BAR CHART EXAMPLES
// =============================================================================

class _BarChartZoomExample extends StatelessWidget {
  const _BarChartZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: '2023',
          dataPoints: List.generate(
            20,
            (i) => FusionDataPoint(i.toDouble(), 40 + (i % 5) * 10),
          ),
          color: const Color(0xFF6366F1),
          barWidth: 0.35,
        ),
        FusionBarSeries(
          name: '2024',
          dataPoints: List.generate(
            20,
            (i) => FusionDataPoint(i.toDouble(), 50 + (i % 4) * 12),
          ),
          color: const Color(0xFF22C55E),
          barWidth: 0.35,
        ),
      ],
      config: const FusionBarChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

class _StackedBarZoomExample extends StatelessWidget {
  const _StackedBarZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionStackedBarChart(
      series: [
        FusionStackedBarSeries(
          name: 'A',
          dataPoints: List.generate(
            25,
            (i) => FusionDataPoint(i.toDouble(), 20 + (i % 3) * 5),
          ),
          color: const Color(0xFF6366F1),
        ),
        FusionStackedBarSeries(
          name: 'B',
          dataPoints: List.generate(
            25,
            (i) => FusionDataPoint(i.toDouble(), 25 + (i % 4) * 4),
          ),
          color: const Color(0xFF22C55E),
        ),
        FusionStackedBarSeries(
          name: 'C',
          dataPoints: List.generate(
            25,
            (i) => FusionDataPoint(i.toDouble(), 15 + (i % 5) * 3),
          ),
          color: const Color(0xFFF59E0B),
        ),
      ],
      config: const FusionStackedBarChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

class _LargeBarDatasetExample extends StatelessWidget {
  const _LargeBarDatasetExample();

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Sales',
          dataPoints: List.generate(
            100,
            (i) => FusionDataPoint(i.toDouble(), 30 + (i % 20) * 2.5),
          ),
          color: const Color(0xFF8B5CF6),
          barWidth: 0.7,
        ),
      ],
      config: const FusionBarChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
          enableDoubleTapZoom: true,
        ),
      ),
    );
  }
}

// =============================================================================
// ADVANCED
// =============================================================================

class _ZoomWithTooltipExample extends StatelessWidget {
  const _ZoomWithTooltipExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          dataPoints: _generateSineWave(80),
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableTooltip: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
        ),
      ),
    );
  }
}

class _ProgrammaticZoomExample extends StatefulWidget {
  const _ProgrammaticZoomExample();

  @override
  State<_ProgrammaticZoomExample> createState() =>
      _ProgrammaticZoomExampleState();
}

class _ProgrammaticZoomExampleState extends State<_ProgrammaticZoomExample> {
  final _controller = FusionChartController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FusionLineChart(
            controller: _controller,
            series: [
              FusionLineSeries(
                dataPoints: _generateSineWave(80),
                color: const Color(0xFF10B981),
                lineWidth: 2.5,
                isCurved: true,
              ),
            ],
            config: const FusionChartConfiguration(
              enableZoom: true,
              enablePanning: true,
              enableAnimation: false,
              zoomBehavior: FusionZoomConfiguration(enablePinchZoom: true),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _controller.zoomIn,
              icon: const Icon(Icons.zoom_in, size: 16),
              label: const Text('Zoom In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _controller.zoomOut,
              icon: const Icon(Icons.zoom_out, size: 16),
              label: const Text('Zoom Out'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _controller.resetZoom,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MultiSeriesZoomExample extends StatelessWidget {
  const _MultiSeriesZoomExample();

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Revenue',
          dataPoints: _generateSineWave(100, amplitude: 40, offset: 60),
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
          isCurved: true,
        ),
        FusionLineSeries(
          name: 'Costs',
          dataPoints: _generateSineWave(
            100,
            amplitude: 25,
            offset: 40,
            phase: 1,
          ),
          color: const Color(0xFFEF4444),
          lineWidth: 2.5,
          isCurved: true,
        ),
        FusionLineSeries(
          name: 'Profit',
          dataPoints: _generateSineWave(
            100,
            amplitude: 15,
            offset: 20,
            phase: 2,
          ),
          color: const Color(0xFF22C55E),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      config: const FusionChartConfiguration(
        enableZoom: true,
        enablePanning: true,
        enableLegend: true,
        enableAnimation: false,
        zoomBehavior: FusionZoomConfiguration(
          enablePinchZoom: true,
          enableMouseWheelZoom: true,
          enableDoubleTapZoom: true,
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

List<FusionDataPoint> _generateSineWave(
  int count, {
  double amplitude = 30,
  double offset = 50,
  double phase = 0,
}) {
  return List.generate(
    count,
    (i) => FusionDataPoint(
      i.toDouble(),
      offset + amplitude * Math.sin((i / 10) + phase),
    ),
  );
}

class Math {
  static double sin(double x) => _sin(x);
  static double _sin(double x) {
    const double pi = 3.14159265359;
    x = x % (2 * pi);
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}

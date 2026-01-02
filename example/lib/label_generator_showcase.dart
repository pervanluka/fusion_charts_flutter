// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

/// Showcase for the new labelGenerator feature (v1.1)
///
/// Demonstrates custom label positioning for various use cases.
class LabelGeneratorShowcase extends StatelessWidget {
  const LabelGeneratorShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Label Generator Showcase'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildExample(
            context,
            title: '1. Edge-Inclusive Labels',
            description:
                'Always shows exact min/max values plus evenly distributed labels in between.',
            child: const EdgeInclusiveExample(),
          ),
          _buildExample(
            context,
            title: '2. Percentage Labels',
            description: 'Shows labels at 0%, 25%, 50%, 75%, 100% of the range.',
            child: const PercentageLabelsExample(),
          ),
          _buildExample(
            context,
            title: '3. Powers of 10 (Log-Scale Style)',
            description:
                'Labels at 1, 10, 100, 1000... Useful for data spanning multiple orders of magnitude.',
            child: const PowersOf10Example(),
          ),
          _buildExample(
            context,
            title: '4. Fibonacci Sequence',
            description: 'Labels at Fibonacci numbers within the data range.',
            child: const FibonacciLabelsExample(),
          ),
          _buildExample(
            context,
            title: '5. Custom Fixed Values',
            description: 'Labels at specific business-meaningful values (e.g., thresholds).',
            child: const CustomFixedValuesExample(),
          ),
          _buildExample(
            context,
            title: '6. DateTime: First of Each Month',
            description: 'For DateTime axis - shows labels only on the 1st of each month.',
            child: const DateTimeMonthStartExample(),
          ),
          _buildExample(
            context,
            title: '7. DateTime: Every Monday',
            description: 'For DateTime axis - shows labels only on Mondays.',
            child: const DateTimeMondaysExample(),
          ),
          _buildExample(
            context,
            title: '8. Density-Based Labels',
            description: 'Adjusts label count based on available pixel space.',
            child: const DensityBasedLabelsExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.label, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'labelGenerator',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'v1.1 Feature - Custom Label Positioning',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'labelGenerator gives you complete control over where axis '
                'labels appear. Return a list of values and the chart will '
                'place labels at those exact positions.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExample(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: child),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EXAMPLE 1: Edge-Inclusive Labels
// =============================================================================

class EdgeInclusiveExample extends StatelessWidget {
  const EdgeInclusiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Data',
          dataPoints: [
            FusionDataPoint(3, 42),
            FusionDataPoint(7, 58),
            FusionDataPoint(12, 35),
            FusionDataPoint(18, 72),
            FusionDataPoint(23, 65),
            FusionDataPoint(27, 88),
          ],
          color: const Color(0xFF6366F1),
          lineWidth: 2.5,
          isCurved: true,
          showArea: true,
          areaOpacity: 0.2,
        ),
      ],
      xAxis: FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) {
          // Always include min and max, plus 3 evenly spaced labels
          final labels = <double>[bounds.min];

          for (int i = 1; i <= 3; i++) {
            labels.add(bounds.min + (bounds.range * i / 4));
          }

          labels.add(bounds.max);
          return labels;
        },
        labelFormatter: (value) => value.toStringAsFixed(0),
      ),
      yAxis: FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) {
          // Edge-inclusive for Y axis too
          return [bounds.min, bounds.min + bounds.range * 0.5, bounds.max];
        },
        labelFormatter: (value) => value.toStringAsFixed(0),
      ),
      config: const FusionChartConfiguration(enableAnimation: true),
    );
  }
}

// =============================================================================
// EXAMPLE 2: Percentage Labels
// =============================================================================

class PercentageLabelsExample extends StatelessWidget {
  const PercentageLabelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionBarChart(
      series: [
        FusionBarSeries(
          name: 'Progress',
          dataPoints: [
            FusionDataPoint(0, 75, label: 'Task A'),
            FusionDataPoint(1, 45, label: 'Task B'),
            FusionDataPoint(2, 90, label: 'Task C'),
            FusionDataPoint(3, 60, label: 'Task D'),
          ],
          color: const Color(0xFF10B981),
          barWidth: 0.6,
          borderRadius: 6,
        ),
      ],
      yAxis: FusionAxisConfiguration(
        min: 0,
        max: 100,
        labelGenerator: (bounds, availableSize, isVertical) {
          // 0%, 25%, 50%, 75%, 100%
          return [0, 25, 50, 75, 100];
        },
        labelFormatter: (value) => '${value.toInt()}%',
      ),
    );
  }
}

// =============================================================================
// EXAMPLE 3: Powers of 10 (Log-Scale Style)
// =============================================================================

class PowersOf10Example extends StatelessWidget {
  const PowersOf10Example({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Growth',
          dataPoints: [
            FusionDataPoint(0, 5),
            FusionDataPoint(1, 15),
            FusionDataPoint(2, 80),
            FusionDataPoint(3, 250),
            FusionDataPoint(4, 800),
            FusionDataPoint(5, 2500),
          ],
          color: const Color(0xFFF59E0B),
          lineWidth: 2.5,
          showMarkers: true,
          markerSize: 6,
        ),
      ],
      yAxis: FusionAxisConfiguration(
        min: 1,
        max: 10000,
        labelGenerator: (bounds, availableSize, isVertical) {
          // Powers of 10 within range
          final labels = <double>[];
          var value = 1.0;

          while (value <= bounds.max) {
            if (value >= bounds.min) {
              labels.add(value);
            }
            value *= 10;
          }

          return labels;
        },
        labelFormatter: (value) {
          if (value >= 1000) return '${(value / 1000).toInt()}K';
          return value.toInt().toString();
        },
      ),
      config: const FusionLineChartConfiguration(enableMarkers: true),
    );
  }
}

// =============================================================================
// EXAMPLE 4: Fibonacci Labels
// =============================================================================

class FibonacciLabelsExample extends StatelessWidget {
  const FibonacciLabelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Fibonacci Scale',
          dataPoints: [
            FusionDataPoint(0, 2),
            FusionDataPoint(5, 8),
            FusionDataPoint(13, 21),
            FusionDataPoint(21, 34),
            FusionDataPoint(34, 55),
            FusionDataPoint(55, 89),
          ],
          color: const Color(0xFF8B5CF6),
          lineWidth: 2.5,
          isCurved: true,
          showMarkers: true,
          markerSize: 8,
        ),
      ],
      xAxis: FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) {
          // Fibonacci sequence
          final fibs = <double>[1, 2, 3, 5, 8, 13, 21, 34, 55, 89];
          return fibs.where((f) => f >= bounds.min && f <= bounds.max).toList();
        },
      ),
      yAxis: FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) {
          // Fibonacci sequence for Y too
          final fibs = <double>[1, 2, 3, 5, 8, 13, 21, 34, 55, 89];
          return fibs.where((f) => f >= bounds.min && f <= bounds.max).toList();
        },
      ),
      config: const FusionLineChartConfiguration(enableMarkers: true),
    );
  }
}

// =============================================================================
// EXAMPLE 5: Custom Fixed Values (Business Thresholds)
// =============================================================================

class CustomFixedValuesExample extends StatelessWidget {
  const CustomFixedValuesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Performance',
          dataPoints: [
            FusionDataPoint(0, 45),
            FusionDataPoint(1, 62),
            FusionDataPoint(2, 78),
            FusionDataPoint(3, 55),
            FusionDataPoint(4, 88),
            FusionDataPoint(5, 72),
          ],
          color: const Color(0xFF3B82F6),
          lineWidth: 2.5,
          showArea: true,
          areaOpacity: 0.15,
        ),
      ],
      yAxis: FusionAxisConfiguration(
        min: 0,
        max: 100,
        labelGenerator: (bounds, availableSize, isVertical) {
          // Business thresholds: Poor, Fair, Good, Excellent
          return [0, 40, 60, 80, 100];
        },
        labelFormatter: (value) {
          switch (value.toInt()) {
            case 0:
              return '0 (Min)';
            case 40:
              return '40 (Poor)';
            case 60:
              return '60 (Fair)';
            case 80:
              return '80 (Good)';
            case 100:
              return '100 (Max)';
            default:
              return value.toInt().toString();
          }
        },
      ),
    );
  }
}

// =============================================================================
// EXAMPLE 6: DateTime - First of Each Month
// =============================================================================

class DateTimeMonthStartExample extends StatelessWidget {
  const DateTimeMonthStartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Data spanning 6 months
    final startDate = DateTime(2025, 1, 15);
    final dataPoints = List.generate(180, (i) {
      final date = startDate.add(Duration(days: i));
      final value = 50 + 30 * (i % 30 / 30) + (i % 7) * 2;
      return FusionDataPoint(date.millisecondsSinceEpoch.toDouble(), value);
    });

    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Daily Values',
          dataPoints: dataPoints,
          color: const Color(0xFF06B6D4),
          lineWidth: 1.5,
        ),
      ],
      xAxis: FusionAxisConfiguration(
        axisType: FusionDateTimeAxis(),
        labelGenerator: (bounds, availableSize, isVertical) {
          // Find first of each month within range
          final labels = <double>[];

          var date = DateTime.fromMillisecondsSinceEpoch(bounds.min.toInt());
          final maxDate = DateTime.fromMillisecondsSinceEpoch(bounds.max.toInt());

          // Move to first of next month if not already on 1st
          if (date.day != 1) {
            date = DateTime(date.year, date.month + 1, 1);
          }

          // Add first of each month
          while (date.isBefore(maxDate)) {
            labels.add(date.millisecondsSinceEpoch.toDouble());
            date = DateTime(date.year, date.month + 1, 1);
          }

          return labels;
        },
      ),
      config: const FusionChartConfiguration(enableAnimation: false),
    );
  }
}

// =============================================================================
// EXAMPLE 7: DateTime - Every Monday
// =============================================================================

class DateTimeMondaysExample extends StatelessWidget {
  const DateTimeMondaysExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Data spanning 8 weeks
    final startDate = DateTime(2025, 3, 1);
    final dataPoints = List.generate(56, (i) {
      final date = startDate.add(Duration(days: i));
      final value = 100 + 50 * (i % 7 / 7) + (i % 14) * 3;
      return FusionDataPoint(date.millisecondsSinceEpoch.toDouble(), value);
    });

    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Weekly Trend',
          dataPoints: dataPoints,
          color: const Color(0xFFEC4899),
          lineWidth: 2,
          isCurved: true,
        ),
      ],
      xAxis: FusionAxisConfiguration(
        axisType: FusionDateTimeAxis(),
        labelGenerator: (bounds, availableSize, isVertical) {
          // Find all Mondays within range
          final labels = <double>[];

          var date = DateTime.fromMillisecondsSinceEpoch(bounds.min.toInt());
          final maxDate = DateTime.fromMillisecondsSinceEpoch(bounds.max.toInt());

          // Move to first Monday
          while (date.weekday != DateTime.monday) {
            date = date.add(const Duration(days: 1));
          }

          // Add all Mondays
          while (date.isBefore(maxDate)) {
            labels.add(date.millisecondsSinceEpoch.toDouble());
            date = date.add(const Duration(days: 7));
          }

          return labels;
        },
      ),
      config: const FusionChartConfiguration(enableAnimation: false),
    );
  }
}

// =============================================================================
// EXAMPLE 8: Density-Based Labels
// =============================================================================

class DensityBasedLabelsExample extends StatelessWidget {
  const DensityBasedLabelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      series: [
        FusionLineSeries(
          name: 'Responsive',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(10, 45),
            FusionDataPoint(20, 35),
            FusionDataPoint(30, 60),
            FusionDataPoint(40, 50),
            FusionDataPoint(50, 75),
            FusionDataPoint(60, 65),
            FusionDataPoint(70, 85),
            FusionDataPoint(80, 70),
            FusionDataPoint(90, 95),
            FusionDataPoint(100, 80),
          ],
          color: const Color(0xFF22C55E),
          lineWidth: 2.5,
          isCurved: true,
        ),
      ],
      xAxis: FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) {
          // Calculate label count based on available pixels
          // Aim for ~60 pixels per label
          const pixelsPerLabel = 60.0;
          final labelCount = (availableSize / pixelsPerLabel).floor().clamp(3, 10);

          final labels = <double>[];
          for (int i = 0; i <= labelCount; i++) {
            labels.add(bounds.min + (bounds.range * i / labelCount));
          }

          return labels;
        },
        labelFormatter: (value) => value.toStringAsFixed(0),
      ),
      yAxis: FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) {
          // Fewer labels for Y axis due to less space
          const pixelsPerLabel = 50.0;
          final labelCount = (availableSize / pixelsPerLabel).floor().clamp(3, 8);

          final labels = <double>[];
          for (int i = 0; i <= labelCount; i++) {
            labels.add(bounds.min + (bounds.range * i / labelCount));
          }

          return labels;
        },
        labelFormatter: (value) => value.toStringAsFixed(0),
      ),
    );
  }
}

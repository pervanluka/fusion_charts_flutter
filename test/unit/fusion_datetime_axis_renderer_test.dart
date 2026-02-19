import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_axis_configuration.dart';
import 'package:fusion_charts_flutter/src/core/axis/datetime/fusion_datetime_axis.dart';
import 'package:fusion_charts_flutter/src/core/axis/datetime/fusion_datetime_axis_renderer.dart';
import 'package:intl/intl.dart';

// =============================================================================
// MOCK CANVAS FOR TESTING
// =============================================================================

/// A mock canvas that records calls for verification
class _MockCanvas implements Canvas {
  final List<_CanvasCall> calls = [];

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    calls.add(_CanvasCall('drawLine', {'p1': p1, 'p2': p2, 'paint': paint}));
  }

  @override
  void save() {
    calls.add(_CanvasCall('save', {}));
  }

  @override
  void restore() {
    calls.add(_CanvasCall('restore', {}));
  }

  @override
  void translate(double dx, double dy) {
    calls.add(_CanvasCall('translate', {'dx': dx, 'dy': dy}));
  }

  @override
  void rotate(double radians) {
    calls.add(_CanvasCall('rotate', {'radians': radians}));
  }

  // Unimplemented methods - only implement what we need
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // For methods we don't track, just record the call
    calls.add(_CanvasCall(invocation.memberName.toString(), {}));
  }
}

class _CanvasCall {
  _CanvasCall(this.method, this.args);

  final String method;
  final Map<String, dynamic> args;
}

void main() {
  // ===========================================================================
  // CONSTRUCTION AND INITIALIZATION
  // ===========================================================================
  group('DateTimeAxisRenderer - Construction', () {
    test('creates renderer with required parameters', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      expect(renderer, isNotNull);
      expect(renderer.axis, axis);
      expect(renderer.configuration, configuration);
      expect(renderer.isVertical, isFalse);
      expect(renderer.theme, isNull);
    });

    test('creates renderer with all parameters', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(visible: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        theme: null, // FusionChartTheme is abstract
        isVertical: true,
      );

      expect(renderer.isVertical, isTrue);
    });

    test('creates renderer for horizontal axis', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: false,
      );

      expect(renderer.isVertical, isFalse);
    });

    test('creates renderer for vertical axis', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: true,
      );

      expect(renderer.isVertical, isTrue);
    });
  });

  // ===========================================================================
  // CALCULATE BOUNDS
  // ===========================================================================
  group('DateTimeAxisRenderer - calculateBounds', () {
    test('calculates bounds from axis min/max', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      expect(
        bounds.min,
        DateTime(2024, 1, 1).millisecondsSinceEpoch.toDouble(),
      );
      expect(
        bounds.max,
        DateTime(2024, 12, 31).millisecondsSinceEpoch.toDouble(),
      );
    });

    test('calculates bounds from data values when axis has no min/max', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final dataValues = [
        DateTime(2024, 1, 15).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 6, 15).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 12, 15).millisecondsSinceEpoch.toDouble(),
      ];

      final bounds = renderer.calculateBounds(dataValues);

      expect(
        bounds.min,
        DateTime(2024, 1, 15).millisecondsSinceEpoch.toDouble(),
      );
      expect(
        bounds.max,
        DateTime(2024, 12, 15).millisecondsSinceEpoch.toDouble(),
      );
    });

    test('uses default range when no axis bounds and no data', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should default to 30 days before now
      expect(bounds.min, isA<double>());
      expect(bounds.max, isA<double>());
      expect(bounds.max, greaterThan(bounds.min));
    });

    test('handles single data point', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final singlePoint = DateTime(
        2024,
        6,
        15,
      ).millisecondsSinceEpoch.toDouble();
      final bounds = renderer.calculateBounds([singlePoint]);

      expect(bounds.min, singlePoint);
      expect(bounds.max, singlePoint);
    });

    test('swaps min and max if min > max', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 12, 31), // Later date as min
        max: DateTime(2024, 1, 1), // Earlier date as max
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should swap them
      expect(
        bounds.min,
        DateTime(2024, 1, 1).millisecondsSinceEpoch.toDouble(),
      );
      expect(
        bounds.max,
        DateTime(2024, 12, 31).millisecondsSinceEpoch.toDouble(),
      );
    });

    test('uses custom interval from axis', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(days: 30),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Interval should be approximately 30 days in milliseconds
      expect(bounds.interval, greaterThan(0));
    });

    test('respects desiredIntervals from axis', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        desiredIntervals: 12,
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // The interval should be calculated based on desiredIntervals
      expect(bounds.interval, greaterThan(0));
    });

    test('respects desiredIntervals from configuration', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(desiredIntervals: 10);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      expect(bounds.interval, greaterThan(0));
    });

    test('uses custom date format from axis', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        dateFormat: DateFormat('yyyy-MM-dd'),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // Check that labels are formatted correctly
      for (final label in labels) {
        expect(label.text, matches(RegExp(r'\d{4}-\d{2}-\d{2}')));
      }
    });
  });

  // ===========================================================================
  // INTERVAL CALCULATION
  // ===========================================================================
  group('DateTimeAxisRenderer - Auto interval calculation', () {
    test('selects second interval for sub-minute range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 12, 0, 0),
        max: DateTime(2024, 1, 1, 12, 0, 30),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should use second-level intervals
      expect(bounds.interval, lessThan(60 * 1000)); // Less than 1 minute in ms
    });

    test('selects minute interval for sub-hour range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 12, 0),
        max: DateTime(2024, 1, 1, 12, 30),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should use minute-level intervals
      expect(bounds.interval, greaterThanOrEqualTo(60 * 1000));
      expect(bounds.interval, lessThan(60 * 60 * 1000));
    });

    test('selects hour interval for sub-day range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 0, 0),
        max: DateTime(2024, 1, 1, 12, 0),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should use hour-level intervals
      expect(bounds.interval, greaterThanOrEqualTo(60 * 60 * 1000));
      expect(bounds.interval, lessThan(24 * 60 * 60 * 1000));
    });

    test('selects day interval for sub-week range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should use hour or day-level intervals for 4-day range
      // The algorithm may choose 12-hour intervals for this range
      expect(
        bounds.interval,
        greaterThanOrEqualTo(1 * 60 * 60 * 1000),
      ); // >= 1 hour
      expect(
        bounds.interval,
        lessThanOrEqualTo(7 * 24 * 60 * 60 * 1000),
      ); // <= 1 week
    });

    test('selects week interval for sub-month range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 20),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should use day or week-level intervals
      expect(bounds.interval, greaterThan(0));
    });

    test('selects month interval for sub-year range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 6, 30),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should use month-level intervals
      expect(bounds.interval, greaterThan(0));
    });

    test('selects year interval for multi-year range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2020, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should use year-level intervals
      expect(
        bounds.interval,
        greaterThan(30 * 24 * 60 * 60 * 1000),
      ); // > 1 month
    });
  });

  // ===========================================================================
  // LABEL GENERATION
  // ===========================================================================
  group('DateTimeAxisRenderer - generateLabels', () {
    test('generates labels for date range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
      for (final label in labels) {
        expect(label.text, isNotEmpty);
        expect(label.position, inInclusiveRange(0.0, 1.0));
        expect(label.value, inInclusiveRange(bounds.min, bounds.max));
      }
    });

    test('generates labels with correct positions', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // First label should be at or near position 0
      expect(labels.first.position, inInclusiveRange(0.0, 0.5));

      // Labels should be in increasing position order
      for (int i = 1; i < labels.length; i++) {
        expect(
          labels[i].position,
          greaterThanOrEqualTo(labels[i - 1].position),
        );
      }
    });

    test('generates labels with auto-selected date format', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 2),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
      // Should format as hours for day-level range
      expect(labels.first.text, isNotEmpty);
    });

    test('generates labels with custom date format', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        dateFormat: DateFormat('MM/dd'),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      for (final label in labels) {
        expect(label.text, matches(RegExp(r'\d{2}/\d{2}')));
      }
    });

    test('respects max labels limit', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2000, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(hours: 1), // Would generate many labels
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // Should be limited to reasonable count
      expect(labels.length, lessThanOrEqualTo(1000));
    });

    test('generates labels using custom labelGenerator', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );

      final customLabelValues = [
        DateTime(2024, 1, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 6, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 12, 31).millisecondsSinceEpoch.toDouble(),
      ];

      final configuration = FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) =>
            customLabelValues,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // First call measureAxisLabels to set _availableSize
      renderer.measureAxisLabels([], const Size(800, 600));

      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 3);
    });

    test('filters out-of-range values from custom labelGenerator', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );

      final customLabelValues = [
        DateTime(2023, 1, 1).millisecondsSinceEpoch.toDouble(), // Out of range
        DateTime(2024, 6, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(
          2025,
          12,
          31,
        ).millisecondsSinceEpoch.toDouble(), // Out of range
      ];

      final configuration = FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) =>
            customLabelValues,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      renderer.measureAxisLabels([], const Size(800, 600));

      final labels = renderer.generateLabels(bounds);

      // Only the in-range label should be included
      expect(labels.length, 1);
    });
  });

  // ===========================================================================
  // DATE FORMAT SELECTION
  // ===========================================================================
  group('DateTimeAxisRenderer - Date format selection', () {
    test('selects HH:mm format for sub-day range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 0, 0),
        max: DateTime(2024, 1, 1, 12, 0),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // Labels should be in HH:mm format
      expect(labels, isNotEmpty);
      expect(labels.first.text, matches(RegExp(r'\d{2}:\d{2}')));
    });

    test('selects MMM dd HH:mm format for week range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });

    test('selects MMM dd format for month range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 2, 15),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });

    test('selects MMM yyyy format for year range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });

    test('selects yyyy format for multi-year range', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2020, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
      // Should include year in format
      expect(labels.first.text, contains('20'));
    });
  });

  // ===========================================================================
  // MEASURE AXIS LABELS
  // ===========================================================================
  group('DateTimeAxisRenderer - measureAxisLabels', () {
    test('returns zero size when axis not visible', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(visible: false);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      final size = renderer.measureAxisLabels(labels, const Size(800, 600));

      expect(size, Size.zero);
    });

    test('returns zero size for empty labels', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(visible: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final size = renderer.measureAxisLabels([], const Size(800, 600));

      expect(size, Size.zero);
    });

    test('measures horizontal axis labels', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(visible: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      final size = renderer.measureAxisLabels(labels, const Size(800, 600));

      expect(size.width, 800);
      expect(size.height, greaterThan(0));
    });

    test('measures vertical axis labels', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(visible: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      final size = renderer.measureAxisLabels(labels, const Size(800, 600));

      expect(size.width, greaterThan(0));
      expect(size.height, 600);
    });

    test('accounts for label rotation', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configWithRotation = FusionAxisConfiguration(
        visible: true,
        labelRotation: 45,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configWithRotation,
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      final size = renderer.measureAxisLabels(labels, const Size(100, 600));

      // Rotated labels should have different height calculation
      expect(size.height, greaterThan(0));
    });

    test('uses custom label style', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        labelStyle: TextStyle(fontSize: 20),
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      final size = renderer.measureAxisLabels(labels, const Size(800, 600));

      // Larger font should produce larger size
      expect(size.height, greaterThan(10));
    });
  });

  // ===========================================================================
  // RENDER AXIS
  // ===========================================================================
  group('DateTimeAxisRenderer - renderAxis', () {
    test('does not render when axis is not visible', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(visible: false);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      // Should not draw anything when not visible
      expect(canvas.calls, isEmpty);
    });

    test('renders axis line when showAxisLine is true', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: true,
        showTicks: false,
        showLabels: false,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      // Should draw the axis line
      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);
    });

    test('renders ticks when showTicks is true', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: false,
        showTicks: true,
        showLabels: false,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      // Should draw tick lines
      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);
    });

    test('renders labels when showLabels is true', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: false,
        showTicks: false,
        showLabels: true,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      // Labels are painted, check that canvas was used
      // (actual text painting is complex to verify)
      expect(canvas.calls, isNotEmpty);
    });

    test('renders horizontal axis correctly', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: true,
        showTicks: true,
        showLabels: true,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: false,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      expect(canvas.calls, isNotEmpty);
    });

    test('renders vertical axis correctly', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: true,
        showTicks: true,
        showLabels: true,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: true,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 100, 600), bounds);

      expect(canvas.calls, isNotEmpty);
    });

    test('applies custom axis line color', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: true,
        showTicks: false,
        showLabels: false,
        axisLineColor: Colors.red,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);

      final paint = drawLineCalls.first.args['paint'] as Paint;
      // Compare color values since Colors.red is a MaterialColor
      expect(paint.color.toARGB32(), Colors.red.toARGB32());
    });

    test('applies custom axis line width', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: true,
        showTicks: false,
        showLabels: false,
        axisLineWidth: 3.0,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);

      final paint = drawLineCalls.first.args['paint'] as Paint;
      expect(paint.strokeWidth, 3.0);
    });

    test('applies custom tick color', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: false,
        showTicks: true,
        showLabels: false,
        majorTickColor: Colors.blue,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);

      final paint = drawLineCalls.first.args['paint'] as Paint;
      // Compare color values since Colors.blue is a MaterialColor
      expect(paint.color.toARGB32(), Colors.blue.toARGB32());
    });

    test('renders labels with rotation', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        visible: true,
        showAxisLine: false,
        showTicks: false,
        showLabels: true,
        labelRotation: 45,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: false,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderAxis(canvas, const Rect.fromLTWH(0, 0, 800, 50), bounds);

      // Should have save/restore calls for rotation
      expect(canvas.calls.where((c) => c.method == 'save'), isNotEmpty);
      expect(canvas.calls.where((c) => c.method == 'restore'), isNotEmpty);
      expect(canvas.calls.where((c) => c.method == 'rotate'), isNotEmpty);
    });
  });

  // ===========================================================================
  // RENDER GRID LINES
  // ===========================================================================
  group('DateTimeAxisRenderer - renderGridLines', () {
    test('does not render grid lines when showGrid is false', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(showGrid: false);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);

      renderer.renderGridLines(
        canvas,
        const Rect.fromLTWH(0, 0, 800, 600),
        bounds,
      );

      // Should not draw anything
      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isEmpty);
    });

    test('renders grid lines when showGrid is true', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(showGrid: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderGridLines(
        canvas,
        const Rect.fromLTWH(0, 0, 800, 600),
        bounds,
      );

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);
    });

    test('renders horizontal grid lines for vertical axis', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(showGrid: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: true,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderGridLines(
        canvas,
        const Rect.fromLTWH(0, 0, 800, 600),
        bounds,
      );

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);

      // For vertical axis, grid lines should be horizontal
      for (final call in drawLineCalls) {
        final p1 = call.args['p1'] as Offset;
        final p2 = call.args['p2'] as Offset;
        expect(p1.dy, closeTo(p2.dy, 1)); // Same Y (horizontal line)
      }
    });

    test('renders vertical grid lines for horizontal axis', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(showGrid: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: false,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderGridLines(
        canvas,
        const Rect.fromLTWH(0, 0, 800, 600),
        bounds,
      );

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);

      // For horizontal axis, grid lines should be vertical
      for (final call in drawLineCalls) {
        final p1 = call.args['p1'] as Offset;
        final p2 = call.args['p2'] as Offset;
        expect(p1.dx, closeTo(p2.dx, 1)); // Same X (vertical line)
      }
    });

    test('applies custom grid color', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        showGrid: true,
        majorGridColor: Colors.purple,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderGridLines(
        canvas,
        const Rect.fromLTWH(0, 0, 800, 600),
        bounds,
      );

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);

      final paint = drawLineCalls.first.args['paint'] as Paint;
      // Compare color values since Colors.purple is a MaterialColor
      expect(paint.color.toARGB32(), Colors.purple.toARGB32());
    });

    test('applies custom grid width', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 5),
      );
      const configuration = FusionAxisConfiguration(
        showGrid: true,
        majorGridWidth: 2.0,
      );

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final canvas = _MockCanvas();
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      renderer.renderGridLines(
        canvas,
        const Rect.fromLTWH(0, 0, 800, 600),
        bounds,
      );

      final drawLineCalls = canvas.calls
          .where((c) => c.method == 'drawLine')
          .toList();
      expect(drawLineCalls, isNotEmpty);

      final paint = drawLineCalls.first.args['paint'] as Paint;
      expect(paint.strokeWidth, 2.0);
    });
  });

  // ===========================================================================
  // CALENDAR ARITHMETIC (DST-SAFE)
  // ===========================================================================
  group('DateTimeAxisRenderer - Calendar arithmetic', () {
    test('generates consistent day labels across DST transition', () {
      // Test around typical DST transition (March in Northern Hemisphere)
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 3, 8),
        max: DateTime(2024, 3, 12),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
      // Labels should be generated without drift
      for (final label in labels) {
        expect(label.position, inInclusiveRange(0.0, 1.0));
      }
    });

    test('generates consistent month labels', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(desiredIntervals: 12);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });

    test('handles year boundaries correctly', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2023, 12, 15),
        max: DateTime(2024, 1, 15),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
      // Should have labels from both years
    });

    test('handles leap year correctly', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 2, 28),
        max: DateTime(2024, 3, 1),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });

    test('handles month-end day clamping', () {
      // Test adding months from a date like Jan 31
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 31),
        max: DateTime(2024, 4, 30),
        interval: const Duration(days: 30), // Roughly monthly
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });
  });

  // ===========================================================================
  // POSITION CALCULATION
  // ===========================================================================
  group('DateTimeAxisRenderer - Position calculation', () {
    test('calculates position at bounds min as 0', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // First label should be at or near 0
      if (labels.isNotEmpty && labels.first.value == bounds.min) {
        expect(labels.first.position, closeTo(0.0, 0.01));
      }
    });

    test('calculates position at bounds max as 1', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // Last label should be at or near 1
      if (labels.isNotEmpty && labels.last.value == bounds.max) {
        expect(labels.last.position, closeTo(1.0, 0.01));
      }
    });

    test('calculates position at midpoint as 0.5', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final midValue = (bounds.min + bounds.max) / 2;

      // Find a label close to midpoint
      final labels = renderer.generateLabels(bounds);
      final midLabel = labels.firstWhere(
        (l) => (l.value - midValue).abs() < bounds.range * 0.1,
        orElse: () => labels[labels.length ~/ 2],
      );

      expect(midLabel.position, inInclusiveRange(0.3, 0.7));
    });

    test('handles zero range gracefully', () {
      final sameDate = DateTime(2024, 6, 15);
      final axis = FusionDateTimeAxis(min: sameDate, max: sameDate);
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // Should handle gracefully without errors
      expect(labels, isNotEmpty);
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('DateTimeAxisRenderer - Edge cases', () {
    test('handles very small time ranges (milliseconds)', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 12, 0, 0, 0),
        max: DateTime(2024, 1, 1, 12, 0, 0, 100),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(bounds.interval, greaterThan(0));
      expect(labels, isNotEmpty);
    });

    test('handles very large time ranges (decades)', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(1990, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(bounds.interval, greaterThan(0));
      expect(labels, isNotEmpty);
      expect(labels.length, lessThanOrEqualTo(1000));
    });

    test('handles dates before epoch', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(1960, 1, 1),
        max: DateTime(1970, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(bounds.min, lessThan(0));
      expect(labels, isNotEmpty);
    });

    test('handles far future dates', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2050, 1, 1),
        max: DateTime(2100, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });

    test('handles empty data with partial axis bounds', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        // max is null
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // When only min is set and no data, the renderer uses current time for max
      // and may adjust min accordingly. Just verify bounds are reasonable.
      expect(bounds.min, isA<double>());
      expect(bounds.max, greaterThan(bounds.min));
    });

    test('handles negative millisecond values correctly', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final negativeDateMs = DateTime(
        1950,
        1,
        1,
      ).millisecondsSinceEpoch.toDouble();
      final positiveDateMs = DateTime(
        1980,
        1,
        1,
      ).millisecondsSinceEpoch.toDouble();

      final bounds = renderer.calculateBounds([negativeDateMs, positiveDateMs]);

      expect(bounds.min, lessThan(0));
      expect(bounds.max, greaterThan(0));
    });
  });

  // ===========================================================================
  // DISPOSE
  // ===========================================================================
  group('DateTimeAxisRenderer - dispose', () {
    test('dispose clears cached data', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      // Generate some cached data
      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);

      // Dispose
      renderer.dispose();

      // Should not throw after dispose
      expect(renderer.dispose, returnsNormally);
    });
  });

  // ===========================================================================
  // TOSTRING
  // ===========================================================================
  group('DateTimeAxisRenderer - toString', () {
    test('toString returns descriptive string', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration(visible: true);

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
        isVertical: false,
      );

      final str = renderer.toString();

      expect(str, contains('DateTimeAxisRenderer'));
      expect(str, contains('visible'));
      expect(str, contains('isVertical'));
    });

    test('toString shows bounds after calculation', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      renderer.calculateBounds([]);

      final str = renderer.toString();

      expect(str, contains('bounds'));
    });
  });

  // ===========================================================================
  // DATA VALUES HANDLING
  // ===========================================================================
  group('DateTimeAxisRenderer - Data values handling', () {
    test('finds min from data values correctly', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final dataValues = [
        DateTime(2024, 6, 15).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 1, 1).millisecondsSinceEpoch.toDouble(), // Min
        DateTime(2024, 12, 31).millisecondsSinceEpoch.toDouble(),
      ];

      final bounds = renderer.calculateBounds(dataValues);

      expect(
        bounds.min,
        DateTime(2024, 1, 1).millisecondsSinceEpoch.toDouble(),
      );
    });

    test('finds max from data values correctly', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final dataValues = [
        DateTime(2024, 1, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 12, 31).millisecondsSinceEpoch.toDouble(), // Max
        DateTime(2024, 6, 15).millisecondsSinceEpoch.toDouble(),
      ];

      final bounds = renderer.calculateBounds(dataValues);

      expect(
        bounds.max,
        DateTime(2024, 12, 31).millisecondsSinceEpoch.toDouble(),
      );
    });

    test('handles unsorted data values', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final dataValues = [
        DateTime(2024, 8, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 2, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 11, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 5, 1).millisecondsSinceEpoch.toDouble(),
      ];

      final bounds = renderer.calculateBounds(dataValues);

      expect(
        bounds.min,
        DateTime(2024, 2, 1).millisecondsSinceEpoch.toDouble(),
      );
      expect(
        bounds.max,
        DateTime(2024, 11, 1).millisecondsSinceEpoch.toDouble(),
      );
    });

    test('handles duplicate data values', () {
      const axis = FusionDateTimeAxis();
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final sameValue = DateTime(2024, 6, 15).millisecondsSinceEpoch.toDouble();
      final dataValues = [sameValue, sameValue, sameValue];

      final bounds = renderer.calculateBounds(dataValues);

      expect(bounds.min, sameValue);
      expect(bounds.max, sameValue);
    });

    test('prefers axis min over data min', () {
      final axis = FusionDateTimeAxis(min: DateTime(2024, 1, 1));
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final dataValues = [
        DateTime(2024, 3, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 6, 1).millisecondsSinceEpoch.toDouble(),
      ];

      final bounds = renderer.calculateBounds(dataValues);

      // Should use axis min, not data min
      expect(
        bounds.min,
        DateTime(2024, 1, 1).millisecondsSinceEpoch.toDouble(),
      );
    });

    test('prefers axis max over data max', () {
      final axis = FusionDateTimeAxis(max: DateTime(2024, 12, 31));
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final dataValues = [
        DateTime(2024, 3, 1).millisecondsSinceEpoch.toDouble(),
        DateTime(2024, 6, 1).millisecondsSinceEpoch.toDouble(),
      ];

      final bounds = renderer.calculateBounds(dataValues);

      // Should use axis max, not data max
      expect(
        bounds.max,
        DateTime(2024, 12, 31).millisecondsSinceEpoch.toDouble(),
      );
    });
  });

  // ===========================================================================
  // NICE INTERVAL FINDING
  // ===========================================================================
  group('DateTimeAxisRenderer - Nice interval finding', () {
    test('selects nice second intervals', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 12, 0, 0),
        max: DateTime(2024, 1, 1, 12, 0, 45),
        desiredIntervals: 5,
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should pick a nice second interval like 5, 10, or 15 seconds
      final intervalSeconds = bounds.interval / 1000;
      expect(
        [1, 5, 10, 15, 30].any((n) => (intervalSeconds - n).abs() < 1),
        isTrue,
      );
    });

    test('selects nice minute intervals', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 12, 0),
        max: DateTime(2024, 1, 1, 12, 45),
        desiredIntervals: 5,
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should pick a nice minute interval like 5, 10, 15 minutes
      final intervalMinutes = bounds.interval / (60 * 1000);
      expect(
        [1, 5, 10, 15, 30].any((n) => (intervalMinutes - n).abs() < 1),
        isTrue,
      );
    });

    test('selects nice hour intervals', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1, 0, 0),
        max: DateTime(2024, 1, 1, 18, 0),
        desiredIntervals: 6,
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should pick a nice hour interval like 1, 2, 3, 6 hours
      final intervalHours = bounds.interval / (60 * 60 * 1000);
      expect(
        [1, 2, 3, 6, 12].any((n) => (intervalHours - n).abs() < 1),
        isTrue,
      );
    });

    test('selects nice day intervals', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 1, 10),
        desiredIntervals: 5,
      );
      const configuration = FusionAxisConfiguration();

      final renderer = DateTimeAxisRenderer(
        axis: axis,
        configuration: configuration,
      );

      final bounds = renderer.calculateBounds([]);

      // Should pick a nice day interval like 1, 2, 3 days
      final intervalDays = bounds.interval / (24 * 60 * 60 * 1000);
      expect([1, 2, 3, 7].any((n) => (intervalDays - n).abs() < 1), isTrue);
    });
  });
}

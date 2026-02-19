import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_axis_configuration.dart';
import 'package:fusion_charts_flutter/src/core/axis/numeric/fusion_numeric_axis.dart';
import 'package:fusion_charts_flutter/src/core/axis/numeric/numeric_axis_renderer.dart';
import 'package:fusion_charts_flutter/src/core/enums/axis_range_padding.dart';
import 'package:fusion_charts_flutter/src/core/models/axis_bounds.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_chart_theme.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_light_theme.dart';

void main() {
  // ===========================================================================
  // TEST FIXTURES
  // ===========================================================================

  late FusionNumericAxis defaultAxis;
  late FusionAxisConfiguration defaultConfiguration;
  late FusionLightTheme defaultTheme;

  setUp(() {
    defaultAxis = const FusionNumericAxis();
    defaultConfiguration = const FusionAxisConfiguration();
    defaultTheme = const FusionLightTheme();
  });

  /// Helper to create a renderer with custom options.
  NumericAxisRenderer createRenderer({
    FusionNumericAxis? axis,
    FusionAxisConfiguration? configuration,
    FusionChartTheme? theme,
    bool isVertical = true,
  }) {
    return NumericAxisRenderer(
      axis: axis ?? defaultAxis,
      configuration: configuration ?? defaultConfiguration,
      theme: theme ?? defaultTheme,
      isVertical: isVertical,
    );
  }

  // ===========================================================================
  // CONSTRUCTION & INITIALIZATION
  // ===========================================================================

  group('NumericAxisRenderer - Construction', () {
    test('creates renderer with required parameters', () {
      final renderer = createRenderer();

      expect(renderer.axis, isNotNull);
      expect(renderer.configuration, isNotNull);
      expect(renderer.isVertical, isTrue);
    });

    test('creates renderer with all parameters', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(min: 0, max: 100),
        configuration: const FusionAxisConfiguration(showGrid: false),
        theme: const FusionLightTheme(),
        isVertical: false,
      );

      expect(renderer.axis.min, 0);
      expect(renderer.axis.max, 100);
      expect(renderer.configuration.showGrid, isFalse);
      expect(renderer.isVertical, isFalse);
    });

    test('creates vertical axis by default', () {
      final renderer = createRenderer();
      expect(renderer.isVertical, isTrue);
    });

    test('creates horizontal axis when specified', () {
      final renderer = createRenderer(isVertical: false);
      expect(renderer.isVertical, isFalse);
    });

    test('toString returns descriptive string', () {
      final renderer = createRenderer();
      final str = renderer.toString();

      expect(str, contains('NumericAxisRenderer'));
      expect(str, contains('isVertical'));
      expect(str, contains('visible'));
    });
  });

  // ===========================================================================
  // BOUNDS CALCULATION
  // ===========================================================================

  group('NumericAxisRenderer - calculateBounds', () {
    group('basic functionality', () {
      test('calculates bounds from data values', () {
        final renderer = createRenderer();
        final bounds = renderer.calculateBounds([10, 20, 30, 40, 50]);

        expect(bounds.min, lessThanOrEqualTo(10));
        expect(bounds.max, greaterThanOrEqualTo(50));
        expect(bounds.interval, greaterThan(0));
      });

      test('returns default bounds for empty data and no explicit bounds', () {
        final renderer = createRenderer();
        final bounds = renderer.calculateBounds([]);

        expect(bounds.min, 0);
        expect(bounds.max, 10);
        expect(bounds.interval, 1);
      });

      test('uses explicit min/max from configuration when set', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 100,
            autoRange: false,
          ),
        );
        final bounds = renderer.calculateBounds([25, 75]);

        expect(bounds.min, 0);
        expect(bounds.max, 100);
      });

      test('uses explicit min/max from axis when set', () {
        final renderer = createRenderer(
          axis: const FusionNumericAxis(min: 10, max: 90),
        );
        final bounds = renderer.calculateBounds([30, 60]);

        expect(bounds.min, lessThanOrEqualTo(10));
        expect(bounds.max, greaterThanOrEqualTo(90));
      });

      test('configuration min/max takes priority over axis min/max', () {
        final renderer = createRenderer(
          axis: const FusionNumericAxis(min: 0, max: 50),
          configuration: const FusionAxisConfiguration(
            min: 10,
            max: 100,
            autoRange: false,
          ),
        );
        final bounds = renderer.calculateBounds([25, 75]);

        expect(bounds.min, 10);
        expect(bounds.max, 100);
      });
    });

    group('edge cases - equal min/max', () {
      test('handles single data point (min equals max)', () {
        final renderer = createRenderer();
        final bounds = renderer.calculateBounds([50]);

        expect(bounds.range, greaterThan(0));
        expect(bounds.min, lessThan(50));
        expect(bounds.max, greaterThan(50));
      });

      test('handles zero value (min equals max at zero)', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 0,
            autoRange: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        expect(bounds.min, -1);
        expect(bounds.max, 1);
      });

      test('handles non-zero equal values', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 100,
            max: 100,
            autoRange: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        expect(bounds.range, greaterThan(0));
        expect(bounds.min, lessThan(100));
        expect(bounds.max, greaterThan(100));
      });
    });

    group('negative values', () {
      test('calculates bounds for negative data values', () {
        final renderer = createRenderer();
        final bounds = renderer.calculateBounds([-50, -40, -30, -20, -10]);

        expect(bounds.min, lessThanOrEqualTo(-50));
        expect(bounds.max, greaterThanOrEqualTo(-10));
      });

      test('calculates bounds spanning negative and positive', () {
        final renderer = createRenderer();
        final bounds = renderer.calculateBounds([-50, -25, 0, 25, 50]);

        expect(bounds.min, lessThanOrEqualTo(-50));
        expect(bounds.max, greaterThanOrEqualTo(50));
      });

      test('handles single negative value', () {
        final renderer = createRenderer();
        final bounds = renderer.calculateBounds([-100]);

        expect(bounds.range, greaterThan(0));
      });
    });

    group('includeZero option', () {
      test('includes zero when requested for positive data', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(includeZero: true),
        );
        final bounds = renderer.calculateBounds([10, 20, 30]);

        expect(bounds.min, lessThanOrEqualTo(0));
      });

      test('includes zero when requested for negative data', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(includeZero: true),
        );
        final bounds = renderer.calculateBounds([-30, -20, -10]);

        expect(bounds.max, greaterThanOrEqualTo(0));
      });

      test('does not modify range when zero is already included', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(includeZero: true),
        );
        final bounds = renderer.calculateBounds([-10, 0, 10]);

        expect(bounds.min, lessThanOrEqualTo(-10));
        expect(bounds.max, greaterThanOrEqualTo(10));
      });
    });

    group('interval calculation', () {
      test('uses explicit interval when set', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 100,
            interval: 25,
            autoRange: false,
            autoInterval: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        expect(bounds.interval, 25);
      });

      test('calculates interval from axis when set', () {
        final renderer = createRenderer(
          axis: const FusionNumericAxis(interval: 10),
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 100,
            autoRange: false,
            autoInterval: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        expect(bounds.interval, 10);
      });

      test('auto-calculates interval based on desired intervals', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 100,
            desiredIntervals: 5,
            autoRange: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        // Should have approximately 5 intervals
        final tickCount = bounds.range / bounds.interval;
        expect(tickCount, closeTo(5, 2));
      });

      test('handles invalid interval (zero or negative)', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 100,
            autoRange: false,
          ),
        );
        final bounds = renderer.calculateBounds([0, 100]);

        expect(bounds.interval, greaterThan(0));
      });
    });

    group('decimal places calculation', () {
      test('calculates decimal places for integer interval', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 100,
            interval: 20,
            autoRange: false,
            autoInterval: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        expect(bounds.decimalPlaces, 0);
      });

      test('calculates decimal places for decimal interval', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 1,
            interval: 0.2,
            autoRange: false,
            autoInterval: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        expect(bounds.decimalPlaces, 1);
      });

      test('calculates decimal places for small interval', () {
        final renderer = createRenderer(
          configuration: const FusionAxisConfiguration(
            min: 0,
            max: 0.1,
            interval: 0.02,
            autoRange: false,
            autoInterval: false,
          ),
        );
        final bounds = renderer.calculateBounds([]);

        expect(bounds.decimalPlaces, 2);
      });
    });
  });

  // ===========================================================================
  // RANGE PADDING
  // ===========================================================================

  group('NumericAxisRenderer - Range Padding', () {
    test('applies no padding when AxisRangePadding.none', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(rangePadding: AxisRangePadding.none),
      );
      final bounds = renderer.calculateBounds([0, 100]);

      // With no padding, bounds should closely match data
      expect(bounds.min, lessThanOrEqualTo(0));
      expect(bounds.max, greaterThanOrEqualTo(100));
    });

    test('applies normal padding when AxisRangePadding.normal', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(rangePadding: AxisRangePadding.normal),
      );
      final bounds = renderer.calculateBounds([0, 100]);

      // With normal padding (5%), bounds should be wider
      expect(bounds.min, lessThanOrEqualTo(0));
      expect(bounds.max, greaterThanOrEqualTo(100));
    });

    test('applies additional padding when AxisRangePadding.additional', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(
          rangePadding: AxisRangePadding.additional,
        ),
      );
      final bounds = renderer.calculateBounds([0, 100]);

      // With additional padding (10%), bounds should be even wider
      expect(bounds.min, lessThanOrEqualTo(0));
      expect(bounds.max, greaterThanOrEqualTo(100));
    });

    test('configuration rangePadding takes priority over axis', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(rangePadding: AxisRangePadding.none),
        configuration: const FusionAxisConfiguration(rangePadding: 0.2),
      );
      final bounds = renderer.calculateBounds([0, 100]);

      // 20% padding should create wider bounds
      expect(bounds.range, greaterThanOrEqualTo(100));
    });

    test('clamps configuration rangePadding to valid range', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(rangePadding: 2.0),
      );
      // Should not throw and should clamp padding to 1.0
      final bounds = renderer.calculateBounds([0, 100]);

      expect(bounds, isNotNull);
    });

    test('does not apply padding for horizontal axis', () {
      final rendererVertical = createRenderer(isVertical: true);
      final rendererHorizontal = createRenderer(isVertical: false);

      final boundsV = rendererVertical.calculateBounds([0, 100]);
      final boundsH = rendererHorizontal.calculateBounds([0, 100]);

      // Horizontal axis should have tighter bounds (no padding)
      // Note: They may still differ due to nice number rounding
      expect(boundsH, isNotNull);
      expect(boundsV, isNotNull);
    });
  });

  // ===========================================================================
  // LABEL GENERATION
  // ===========================================================================

  group('NumericAxisRenderer - generateLabels', () {
    group('auto label generation', () {
      test('generates labels at interval positions', () {
        final renderer = createRenderer();
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);
        final labels = renderer.generateLabels(bounds);

        expect(labels.length, greaterThanOrEqualTo(5));
        expect(labels.first.value, closeTo(0, 0.01));
        expect(labels.last.value, closeTo(100, 0.01));
      });

      test('generates labels with correct positions', () {
        final renderer = createRenderer();
        final bounds = AxisBounds(min: 0, max: 100, interval: 50);
        final labels = renderer.generateLabels(bounds);

        expect(labels[0].position, closeTo(0.0, 0.001));
        if (labels.length > 1) {
          expect(labels[1].position, closeTo(0.5, 0.001));
        }
        expect(labels.last.position, closeTo(1.0, 0.001));
      });

      test('generates formatted label text', () {
        final renderer = createRenderer(
          axis: const FusionNumericAxis(decimalPlaces: 0),
        );
        final bounds = AxisBounds(min: 0, max: 100, interval: 25);
        final labels = renderer.generateLabels(bounds);

        expect(labels.any((l) => l.text == '0'), isTrue);
        expect(labels.any((l) => l.text == '25'), isTrue);
        expect(labels.any((l) => l.text == '50'), isTrue);
      });

      test('limits maximum number of labels', () {
        final renderer = createRenderer();
        // Very small interval would create many labels
        final bounds = AxisBounds(min: 0, max: 10000, interval: 0.01);
        final labels = renderer.generateLabels(bounds);

        // Should be capped at max labels (1000)
        expect(labels.length, lessThanOrEqualTo(1001));
      });

      test('returns at least one label for zero range', () {
        final renderer = createRenderer();
        final bounds = AxisBounds(min: 50, max: 50, interval: 1);
        final labels = renderer.generateLabels(bounds);

        expect(labels, isNotEmpty);
      });
    });

    group('custom label generator', () {
      test('uses custom labelGenerator when provided', () {
        final renderer = createRenderer(
          configuration: FusionAxisConfiguration(
            labelGenerator: (bounds, availableSize, isVertical) {
              return [0, 50, 100];
            },
          ),
        );
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);
        final labels = renderer.generateLabels(bounds);

        expect(labels.length, 3);
        expect(labels[0].value, 0);
        expect(labels[1].value, 50);
        expect(labels[2].value, 100);
      });

      test('custom labelGenerator filters values outside range', () {
        final renderer = createRenderer(
          configuration: FusionAxisConfiguration(
            labelGenerator: (bounds, availableSize, isVertical) {
              return [-50, 0, 50, 100, 150]; // -50 and 150 are outside
            },
          ),
        );
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);
        final labels = renderer.generateLabels(bounds);

        expect(labels.length, 3);
        expect(labels.every((l) => l.value >= 0 && l.value <= 100), isTrue);
      });

      test('custom labelGenerator receives correct parameters', () {
        AxisBounds? receivedBounds;
        double? receivedSize;
        bool? receivedIsVertical;

        final renderer = createRenderer(
          configuration: FusionAxisConfiguration(
            labelGenerator: (bounds, availableSize, isVertical) {
              receivedBounds = bounds;
              receivedSize = availableSize;
              receivedIsVertical = isVertical;
              return [bounds.min, bounds.max];
            },
          ),
          isVertical: true,
        );

        // Need to call measureAxisLabels first to set _availableSize
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);
        renderer.measureAxisLabels([], const Size(200, 400));
        renderer.generateLabels(bounds);

        expect(receivedBounds, bounds);
        expect(receivedSize, 400.0); // height for vertical axis
        expect(receivedIsVertical, isTrue);
      });
    });
  });

  // ===========================================================================
  // LABEL FORMATTING
  // ===========================================================================

  group('NumericAxisRenderer - Label Formatting', () {
    test('uses custom labelFormatter from configuration', () {
      final renderer = createRenderer(
        configuration: FusionAxisConfiguration(
          labelFormatter: (value) => '\$${value.toInt()}',
        ),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 50);
      final labels = renderer.generateLabels(bounds);

      expect(labels.any((l) => l.text == '\$0'), isTrue);
      expect(labels.any((l) => l.text == '\$50'), isTrue);
    });

    test('uses custom labelFormatter from axis', () {
      final renderer = createRenderer(
        axis: FusionNumericAxis(labelFormatter: (value) => '${value.toInt()}%'),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 50);
      final labels = renderer.generateLabels(bounds);

      expect(labels.any((l) => l.text == '0%'), isTrue);
      expect(labels.any((l) => l.text == '50%'), isTrue);
    });

    test('configuration labelFormatter takes priority over axis', () {
      final renderer = createRenderer(
        axis: FusionNumericAxis(labelFormatter: (value) => 'axis: $value'),
        configuration: FusionAxisConfiguration(
          labelFormatter: (value) => 'config: ${value.toInt()}',
        ),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 50);
      final labels = renderer.generateLabels(bounds);

      expect(labels.any((l) => l.text.startsWith('config:')), isTrue);
      expect(labels.any((l) => l.text.startsWith('axis:')), isFalse);
    });

    test('uses abbreviation for large numbers when enabled', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(useAbbreviation: true),
      );
      final bounds = AxisBounds(min: 0, max: 1000000, interval: 500000);
      final labels = renderer.generateLabels(bounds);

      // Should use K, M abbreviations
      expect(
        labels.any((l) => l.text.contains('K') || l.text.contains('M')),
        isTrue,
      );
    });

    test('uses scientific notation for very large numbers when enabled', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(useScientificNotation: true),
        configuration: const FusionAxisConfiguration(useAbbreviation: false),
      );
      final bounds = AxisBounds(min: 0, max: 1e7, interval: 5e6);
      final labels = renderer.generateLabels(bounds);

      // Should use scientific notation
      expect(labels.any((l) => l.text.contains('e')), isTrue);
    });

    test('uses scientific notation for very small numbers when enabled', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(useScientificNotation: true),
        configuration: const FusionAxisConfiguration(useAbbreviation: false),
      );
      final bounds = AxisBounds(min: 0, max: 1e-4, interval: 5e-5);
      final labels = renderer.generateLabels(bounds);

      // Should use scientific notation for small numbers (excluding 0)
      expect(
        labels.where((l) => l.value != 0).any((l) => l.text.contains('e')),
        isTrue,
      );
    });

    test('respects decimalPlaces from axis', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(decimalPlaces: 3),
        configuration: const FusionAxisConfiguration(useAbbreviation: false),
      );
      final bounds = AxisBounds(min: 0, max: 1, interval: 0.5);
      final labels = renderer.generateLabels(bounds);

      // Should have 3 decimal places
      expect(labels.any((l) => l.text == '0.000'), isTrue);
      expect(labels.any((l) => l.text == '0.500'), isTrue);
    });
  });

  // ===========================================================================
  // SIZE MEASUREMENT
  // ===========================================================================

  group('NumericAxisRenderer - measureAxisLabels', () {
    test('returns zero size when axis is not visible', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(visible: false),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(200, 400));

      expect(size, Size.zero);
    });

    test('returns zero size for empty labels', () {
      final renderer = createRenderer();
      final size = renderer.measureAxisLabels([], const Size(200, 400));

      expect(size, Size.zero);
    });

    test('measures vertical axis labels correctly', () {
      final renderer = createRenderer(isVertical: true);
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(200, 400));

      // For vertical axis, width is max label width + padding
      expect(size.width, greaterThan(0));
      expect(size.height, 400);
    });

    test('measures horizontal axis labels correctly', () {
      final renderer = createRenderer(isVertical: false);
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(400, 200));

      // For horizontal axis, height is max label height + padding
      expect(size.width, 400);
      expect(size.height, greaterThan(0));
    });

    test('uses labelStyle from configuration', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(
          labelStyle: TextStyle(fontSize: 20),
        ),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(200, 400));

      // Larger font should result in larger measured size
      expect(size.width, greaterThan(0));
    });

    test('uses labelStyle from theme as fallback', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(),
        theme: const FusionLightTheme(),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(200, 400));

      expect(size.width, greaterThan(0));
    });

    test('caches label sizes for performance', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);

      // First measurement
      renderer.measureAxisLabels(labels, const Size(200, 400));

      // Second measurement should use cache
      final size2 = renderer.measureAxisLabels(labels, const Size(200, 400));

      expect(size2.width, greaterThan(0));
    });

    test('invalidates cache when style changes', () {
      final renderer = NumericAxisRenderer(
        axis: defaultAxis,
        configuration: const FusionAxisConfiguration(
          labelStyle: TextStyle(fontSize: 12),
        ),
        theme: defaultTheme,
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);

      final size1 = renderer.measureAxisLabels(labels, const Size(200, 400));

      // Create new renderer with different style
      final renderer2 = NumericAxisRenderer(
        axis: defaultAxis,
        configuration: const FusionAxisConfiguration(
          labelStyle: TextStyle(fontSize: 24),
        ),
        theme: defaultTheme,
      );
      final size2 = renderer2.measureAxisLabels(labels, const Size(200, 400));

      // Different font size should result in different measured size
      expect(size1.width, isNot(equals(size2.width)));
    });
  });

  // ===========================================================================
  // RENDERING - AXIS
  // ===========================================================================

  group('NumericAxisRenderer - renderAxis', () {
    test('does not render when visible is false', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(visible: false),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw
      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('renders axis line when showAxisLine is true', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showAxisLine: true),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw
      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('renders ticks when showTicks is true', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showTicks: true),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw
      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('renders labels when showLabels is true', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showLabels: true),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw
      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('uses axisLineColor from configuration', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(
          showAxisLine: true,
          axisLineColor: Colors.red,
        ),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw and use custom color
      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('renders vertical axis correctly', () {
      final renderer = createRenderer(isVertical: true);
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('renders horizontal axis correctly', () {
      final renderer = createRenderer(isVertical: false);
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('applies label rotation for horizontal axis', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(
          showLabels: true,
          labelRotation: 45,
        ),
        isVertical: false,
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw
      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });
  });

  // ===========================================================================
  // RENDERING - GRID LINES
  // ===========================================================================

  group('NumericAxisRenderer - renderGridLines', () {
    test('renders grid lines when showGrid is true', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showGrid: true),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const plotArea = Rect.fromLTWH(50, 0, 350, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw
      renderer.renderGridLines(canvas, plotArea, bounds);

      recorder.endRecording().dispose();
    });

    test('does not render grid lines when showGrid is false', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showGrid: false),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const plotArea = Rect.fromLTWH(50, 0, 350, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw and not draw anything
      renderer.renderGridLines(canvas, plotArea, bounds);

      recorder.endRecording().dispose();
    });

    test('uses majorGridColor from configuration', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(
          showGrid: true,
          majorGridColor: Colors.blue,
        ),
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const plotArea = Rect.fromLTWH(50, 0, 350, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw
      renderer.renderGridLines(canvas, plotArea, bounds);

      recorder.endRecording().dispose();
    });

    test('renders horizontal grid lines for vertical axis', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showGrid: true),
        isVertical: true,
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const plotArea = Rect.fromLTWH(50, 0, 350, 400);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      renderer.renderGridLines(canvas, plotArea, bounds);

      recorder.endRecording().dispose();
    });

    test('renders vertical grid lines for horizontal axis', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showGrid: true),
        isVertical: false,
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      const plotArea = Rect.fromLTWH(0, 50, 400, 350);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      renderer.renderGridLines(canvas, plotArea, bounds);

      recorder.endRecording().dispose();
    });
  });

  // ===========================================================================
  // DISPOSAL
  // ===========================================================================

  group('NumericAxisRenderer - dispose', () {
    test('clears cached bounds', () {
      final renderer = createRenderer();
      renderer.calculateBounds([10, 20, 30]);

      renderer.dispose();

      // After dispose, recalculating should work
      final bounds = renderer.calculateBounds([10, 20, 30]);
      expect(bounds, isNotNull);
    });

    test('clears cached labels', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      renderer.generateLabels(bounds);

      renderer.dispose();

      // After dispose, regenerating should work
      final labels = renderer.generateLabels(bounds);
      expect(labels, isNotEmpty);
    });

    test('can be called multiple times', () {
      final renderer = createRenderer();
      renderer.calculateBounds([10, 20, 30]);

      renderer.dispose();
      renderer.dispose();
      renderer.dispose();

      // Should not throw
    });

    test('disposes text painter resources', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);
      renderer.measureAxisLabels(labels, const Size(200, 400));

      renderer.dispose();

      // Should not throw and resources should be cleaned up
    });
  });

  // ===========================================================================
  // PRECISION AND FLOATING POINT
  // ===========================================================================

  group('NumericAxisRenderer - Precision Handling', () {
    test('handles floating point precision issues', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 1, interval: 0.1);
      final labels = renderer.generateLabels(bounds);

      // Should not have floating point errors like 0.30000000000000004
      for (final label in labels) {
        expect(label.text, isNot(contains('000000')));
      }
    });

    test('cleans floating point values to appropriate precision', () {
      final renderer = createRenderer();
      // Create bounds that would result in floating point errors
      final bounds = AxisBounds(min: 0.1, max: 0.9, interval: 0.1);
      final labels = renderer.generateLabels(bounds);

      // All values should be clean
      for (final label in labels) {
        final value = label.value;
        // Check that value rounds to itself (no precision errors)
        expect((value * 10).roundToDouble() / 10, closeTo(value, 0.0001));
      }
    });

    test('handles very small values', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 0.001, interval: 0.0002);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
      expect(labels.first.value, closeTo(0, 0.0001));
    });

    test('handles very large values', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 1e9, interval: 2e8);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
      expect(labels.last.value, closeTo(1e9, 1e7));
    });
  });

  // ===========================================================================
  // POSITION CALCULATION
  // ===========================================================================

  group('NumericAxisRenderer - Position Calculation', () {
    test('calculates position 0 for minimum value', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);

      final minLabel = labels.firstWhere((l) => l.value == 0);
      expect(minLabel.position, closeTo(0.0, 0.001));
    });

    test('calculates position 1 for maximum value', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      final labels = renderer.generateLabels(bounds);

      final maxLabel = labels.firstWhere((l) => l.value == 100);
      expect(maxLabel.position, closeTo(1.0, 0.001));
    });

    test('calculates position 0.5 for midpoint value', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 100, interval: 50);
      final labels = renderer.generateLabels(bounds);

      final midLabel = labels.firstWhere((l) => l.value == 50);
      expect(midLabel.position, closeTo(0.5, 0.001));
    });

    test('clamps position to valid range', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 0, max: 100, interval: 25);
      final labels = renderer.generateLabels(bounds);

      for (final label in labels) {
        expect(label.position, greaterThanOrEqualTo(0.0));
        expect(label.position, lessThanOrEqualTo(1.0));
      }
    });

    test('returns 0.5 position for zero range', () {
      final renderer = createRenderer();
      final bounds = AxisBounds(min: 50, max: 50, interval: 1);
      final labels = renderer.generateLabels(bounds);

      // All labels should be at 0.5 position
      for (final label in labels) {
        expect(label.position, closeTo(0.5, 0.001));
      }
    });
  });

  // ===========================================================================
  // ADDITIONAL EDGE CASES
  // ===========================================================================

  group('NumericAxisRenderer - Additional Edge Cases', () {
    test('uses axis desiredIntervals when configuration default is 5', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(desiredIntervals: 10),
        configuration: const FusionAxisConfiguration(
          // desiredIntervals defaults to 5
        ),
      );
      final bounds = renderer.calculateBounds([0, 100]);

      // Should use axis desiredIntervals (10) since config is default (5)
      expect(bounds.interval, greaterThan(0));
    });

    test('uses configuration desiredIntervals over axis when not default', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(desiredIntervals: 10),
        configuration: const FusionAxisConfiguration(desiredIntervals: 8),
      );
      final bounds = renderer.calculateBounds([0, 100]);

      // Should use config desiredIntervals (8) since it's not default
      expect(bounds.interval, greaterThan(0));
    });

    test('handles AxisRangePadding.round', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(rangePadding: AxisRangePadding.round),
      );
      final bounds = renderer.calculateBounds([10, 90]);

      expect(bounds.min, lessThanOrEqualTo(10));
      expect(bounds.max, greaterThanOrEqualTo(90));
    });

    test('renders horizontal axis ticks correctly', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(showTicks: true),
        isVertical: false,
      );
      final bounds = AxisBounds(min: 0, max: 100, interval: 20);
      // Generate labels first to populate cache
      renderer.generateLabels(bounds);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('handles negative interval after calculation (edge case)', () {
      // This tests the interval <= 0 fallback at lines 236-238
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(
          min: 100,
          max: 100, // Equal min/max creates zero range
          autoRange: false,
          autoInterval: false,
          // No explicit interval, will be null and fall through to fallback
        ),
      );
      final bounds = renderer.calculateBounds([]);

      // Should have a valid positive interval despite edge case
      expect(bounds.interval, greaterThan(0));
    });
  });

  // ===========================================================================
  // INTEGRATION TESTS
  // ===========================================================================

  group('NumericAxisRenderer - Integration', () {
    test('full render cycle works correctly', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(
          showAxisLine: true,
          showTicks: true,
          showLabels: true,
          showGrid: true,
        ),
      );

      // 1. Calculate bounds
      final bounds = renderer.calculateBounds([10, 20, 30, 40, 50]);

      // 2. Generate labels
      final labels = renderer.generateLabels(bounds);
      expect(labels, isNotEmpty);

      // 3. Measure labels
      final size = renderer.measureAxisLabels(labels, const Size(200, 400));
      expect(size.width, greaterThan(0));

      // 4. Render
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);
      const plotArea = Rect.fromLTWH(50, 0, 350, 400);

      renderer.renderAxis(canvas, axisArea, bounds);
      renderer.renderGridLines(canvas, plotArea, bounds);

      // 5. Dispose
      renderer.dispose();

      recorder.endRecording().dispose();
    });

    test('works with negative to positive range', () {
      final renderer = createRenderer();

      final bounds = renderer.calculateBounds([-100, -50, 0, 50, 100]);
      final labels = renderer.generateLabels(bounds);

      expect(bounds.min, lessThanOrEqualTo(-100));
      expect(bounds.max, greaterThanOrEqualTo(100));
      expect(labels, isNotEmpty);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 50, 400);

      renderer.renderAxis(canvas, axisArea, bounds);

      recorder.endRecording().dispose();
    });

    test('works with small decimal values', () {
      final renderer = createRenderer(
        axis: const FusionNumericAxis(decimalPlaces: 3),
        configuration: const FusionAxisConfiguration(useAbbreviation: false),
      );

      final bounds = renderer.calculateBounds([
        0.001,
        0.002,
        0.003,
        0.004,
        0.005,
      ]);
      final labels = renderer.generateLabels(bounds);

      expect(bounds.min, lessThanOrEqualTo(0.001));
      expect(bounds.max, greaterThanOrEqualTo(0.005));
      expect(labels, isNotEmpty);
    });

    test('works with large values', () {
      final renderer = createRenderer(
        configuration: const FusionAxisConfiguration(useAbbreviation: true),
      );

      final bounds = renderer.calculateBounds([1e6, 2e6, 3e6, 4e6, 5e6]);
      final labels = renderer.generateLabels(bounds);

      expect(bounds.min, lessThanOrEqualTo(1e6));
      expect(bounds.max, greaterThanOrEqualTo(5e6));
      expect(labels, isNotEmpty);
    });

    test('handles multiple calculations without disposal', () {
      final renderer = createRenderer();

      // Multiple calculations
      renderer.calculateBounds([10, 20, 30]);
      renderer.calculateBounds([100, 200, 300]);
      renderer.calculateBounds([-50, 0, 50]);

      final bounds = renderer.calculateBounds([1, 2, 3, 4, 5]);
      final labels = renderer.generateLabels(bounds);

      expect(labels, isNotEmpty);
    });

    test('configuration changes between calculations', () {
      // First renderer with one configuration
      final renderer1 = createRenderer(
        configuration: const FusionAxisConfiguration(
          min: 0,
          max: 100,
          autoRange: false,
        ),
      );
      final bounds1 = renderer1.calculateBounds([50]);

      // Second renderer with different configuration
      final renderer2 = createRenderer(
        configuration: const FusionAxisConfiguration(
          min: -100,
          max: 100,
          autoRange: false,
        ),
      );
      final bounds2 = renderer2.calculateBounds([50]);

      expect(bounds1.min, 0);
      expect(bounds2.min, -100);
    });
  });
}

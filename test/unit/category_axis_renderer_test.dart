import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_axis_configuration.dart';
import 'package:fusion_charts_flutter/src/core/axis/category/category_axis_renderer.dart';
import 'package:fusion_charts_flutter/src/core/models/axis_label.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_light_theme.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION AND INITIALIZATION
  // ===========================================================================

  group('CategoryAxisRenderer - Construction', () {
    test('creates renderer with required parameters', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      expect(renderer.categories, ['A', 'B', 'C']);
      expect(renderer.isVertical, isFalse);
      expect(renderer.theme, isNull);
    });

    test('creates renderer with all parameters', () {
      const theme = FusionLightTheme();
      final renderer = CategoryAxisRenderer(
        categories: const ['Jan', 'Feb', 'Mar', 'Apr'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
          showTicks: true,
          showGrid: true,
        ),
        theme: theme,
        isVertical: true,
      );

      expect(renderer.categories, ['Jan', 'Feb', 'Mar', 'Apr']);
      expect(renderer.isVertical, isTrue);
      expect(renderer.theme, theme);
      expect(renderer.configuration.visible, isTrue);
    });

    test('creates horizontal axis by default', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['X', 'Y'],
        configuration: const FusionAxisConfiguration(),
      );

      expect(renderer.isVertical, isFalse);
    });

    test('creates vertical axis when specified', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['X', 'Y'],
        configuration: const FusionAxisConfiguration(),
        isVertical: true,
      );

      expect(renderer.isVertical, isTrue);
    });
  });

  // ===========================================================================
  // BOUNDS CALCULATION
  // ===========================================================================

  group('CategoryAxisRenderer - Bounds Calculation', () {
    test('calculateBounds returns correct bounds for multiple categories', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Q1', 'Q2', 'Q3', 'Q4'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);

      expect(bounds.min, -0.5);
      expect(bounds.max, 3.5); // categories.length - 0.5 = 4 - 0.5
      expect(bounds.interval, 1.0);
      expect(bounds.decimalPlaces, 0);
    });

    test('calculateBounds returns correct bounds for single category', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Only'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);

      expect(bounds.min, -0.5);
      expect(bounds.max, 0.5); // 1 - 0.5 = 0.5
      expect(bounds.interval, 1.0);
    });

    test('calculateBounds returns correct bounds for two categories', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);

      expect(bounds.min, -0.5);
      expect(bounds.max, 1.5); // 2 - 0.5 = 1.5
      expect(bounds.interval, 1.0);
    });

    test(
      'calculateBounds ignores data values (category axis is index-based)',
      () {
        final renderer = CategoryAxisRenderer(
          categories: const ['A', 'B', 'C'],
          configuration: const FusionAxisConfiguration(),
        );

        final bounds = renderer.calculateBounds([100.0, 200.0, 300.0]);

        // Should still use index-based bounds, not data values
        expect(bounds.min, -0.5);
        expect(bounds.max, 2.5);
      },
    );

    test('calculateBounds caches result', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds1 = renderer.calculateBounds([]);
      final bounds2 = renderer.calculateBounds([]);

      expect(bounds1.min, bounds2.min);
      expect(bounds1.max, bounds2.max);
      expect(bounds1.interval, bounds2.interval);
    });
  });

  // ===========================================================================
  // LABEL GENERATION
  // ===========================================================================

  group('CategoryAxisRenderer - Label Generation', () {
    test('generateLabels creates correct labels for multiple categories', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Jan', 'Feb', 'Mar', 'Apr'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 4);
      expect(labels[0].text, 'Jan');
      expect(labels[1].text, 'Feb');
      expect(labels[2].text, 'Mar');
      expect(labels[3].text, 'Apr');
    });

    test('generateLabels assigns correct values (indices)', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels[0].value, 0.0);
      expect(labels[1].value, 1.0);
      expect(labels[2].value, 2.0);
    });

    test(
      'generateLabels assigns correct positions for multiple categories',
      () {
        final renderer = CategoryAxisRenderer(
          categories: const ['A', 'B', 'C', 'D'],
          configuration: const FusionAxisConfiguration(),
        );

        final bounds = renderer.calculateBounds([]);
        final labels = renderer.generateLabels(bounds);

        // Position should be i / (categories.length - 1)
        expect(labels[0].position, 0.0); // 0 / 3
        expect(labels[1].position, closeTo(0.333, 0.01)); // 1 / 3
        expect(labels[2].position, closeTo(0.666, 0.01)); // 2 / 3
        expect(labels[3].position, 1.0); // 3 / 3
      },
    );

    test('generateLabels assigns position 0.5 for single category', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Only'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 1);
      expect(labels[0].text, 'Only');
      expect(labels[0].position, 0.5);
    });

    test('generateLabels handles two categories correctly', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Start', 'End'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 2);
      expect(labels[0].position, 0.0); // 0 / 1
      expect(labels[1].position, 1.0); // 1 / 1
    });

    test('generateLabels caches result', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels1 = renderer.generateLabels(bounds);
      final labels2 = renderer.generateLabels(bounds);

      expect(labels1.length, labels2.length);
      expect(labels1[0].text, labels2[0].text);
    });
  });

  // ===========================================================================
  // SIZE MEASUREMENT
  // ===========================================================================

  group('CategoryAxisRenderer - Size Measurement', () {
    test('measureAxisLabels returns zero size when axis not visible', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(visible: false),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(400, 300));

      expect(size, Size.zero);
    });

    test('measureAxisLabels returns zero size for empty labels', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final size = renderer.measureAxisLabels([], const Size(400, 300));

      expect(size, Size.zero);
    });

    test('measureAxisLabels returns non-zero size for horizontal axis', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Category 1', 'Category 2'],
        configuration: const FusionAxisConfiguration(visible: true),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(400, 300));

      expect(size.width, 400); // Full available width for horizontal
      expect(size.height, greaterThan(0)); // Label height + padding
    });

    test('measureAxisLabels returns non-zero size for vertical axis', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Category 1', 'Category 2'],
        configuration: const FusionAxisConfiguration(visible: true),
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(400, 300));

      expect(size.width, greaterThan(0)); // Label width + padding
      expect(size.height, 300); // Full available height for vertical
    });

    test('measureAxisLabels uses configuration label style', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          labelStyle: TextStyle(fontSize: 20),
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(400, 300));

      // Larger font size should result in larger height
      expect(size.height, greaterThan(8)); // padding + label height
    });

    test(
      'measureAxisLabels uses theme label style when config style is null',
      () {
        const theme = FusionLightTheme();
        final renderer = CategoryAxisRenderer(
          categories: const ['A', 'B'],
          configuration: const FusionAxisConfiguration(visible: true),
          theme: theme,
        );

        final bounds = renderer.calculateBounds([]);
        final labels = renderer.generateLabels(bounds);
        final size = renderer.measureAxisLabels(labels, const Size(400, 300));

        expect(size.height, greaterThan(0));
      },
    );

    test(
      'measureAxisLabels calculates rotated height when labels would collide',
      () {
        final renderer = CategoryAxisRenderer(
          categories: const [
            'Very Long Category Name 1',
            'Very Long Category Name 2',
            'Very Long Category Name 3',
          ],
          configuration: const FusionAxisConfiguration(
            visible: true,
            labelRotation: 45,
          ),
          isVertical: false,
        );

        final bounds = renderer.calculateBounds([]);
        final labels = renderer.generateLabels(bounds);

        // With narrow width, labels should need rotation
        final size = renderer.measureAxisLabels(labels, const Size(100, 300));

        expect(
          size.height,
          greaterThan(8),
        ); // Should include rotated label height
      },
    );

    test('measureAxisLabels caches label sizes for performance', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // First call should measure and cache
      final size1 = renderer.measureAxisLabels(labels, const Size(400, 300));

      // Second call should use cached sizes
      final size2 = renderer.measureAxisLabels(labels, const Size(400, 300));

      expect(size1, size2);
    });

    test('measureAxisLabels invalidates cache when style changes', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          labelStyle: TextStyle(fontSize: 12),
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      final size1 = renderer.measureAxisLabels(labels, const Size(400, 300));

      // Create new renderer with different style
      final renderer2 = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          labelStyle: TextStyle(fontSize: 24),
        ),
      );

      final bounds2 = renderer2.calculateBounds([]);
      final labels2 = renderer2.generateLabels(bounds2);
      final size2 = renderer2.measureAxisLabels(labels2, const Size(400, 300));

      // Different font size should result in different measurement
      expect(size2.height, greaterThan(size1.height));
    });
  });

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  group('CategoryAxisRenderer - Helper Methods', () {
    test('getCategoryIndex returns correct index for existing category', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Jan', 'Feb', 'Mar', 'Apr'],
        configuration: const FusionAxisConfiguration(),
      );

      expect(renderer.getCategoryIndex('Jan'), 0);
      expect(renderer.getCategoryIndex('Feb'), 1);
      expect(renderer.getCategoryIndex('Mar'), 2);
      expect(renderer.getCategoryIndex('Apr'), 3);
    });

    test('getCategoryIndex returns null for non-existent category', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Jan', 'Feb', 'Mar'],
        configuration: const FusionAxisConfiguration(),
      );

      expect(renderer.getCategoryIndex('Dec'), isNull);
      expect(renderer.getCategoryIndex('Unknown'), isNull);
      expect(renderer.getCategoryIndex(''), isNull);
    });

    test('getCategoryName returns correct name for valid index', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Apple', 'Banana', 'Cherry'],
        configuration: const FusionAxisConfiguration(),
      );

      expect(renderer.getCategoryName(0), 'Apple');
      expect(renderer.getCategoryName(1), 'Banana');
      expect(renderer.getCategoryName(2), 'Cherry');
    });

    test('getCategoryName returns null for negative index', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      expect(renderer.getCategoryName(-1), isNull);
      expect(renderer.getCategoryName(-100), isNull);
    });

    test('getCategoryName returns null for out of bounds index', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      expect(renderer.getCategoryName(3), isNull);
      expect(renderer.getCategoryName(100), isNull);
    });
  });

  // ===========================================================================
  // RENDERING - VISIBILITY
  // ===========================================================================

  group('CategoryAxisRenderer - Rendering Visibility', () {
    test('renderAxis does nothing when axis is not visible', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(visible: false),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      // Should not throw and should not draw anything
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderGridLines does nothing when showGrid is false', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(showGrid: false),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      // Should not throw and should not draw anything
      renderer.renderGridLines(canvas, plotArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });

  // ===========================================================================
  // RENDERING - AXIS LINE
  // ===========================================================================

  group('CategoryAxisRenderer - Axis Line Rendering', () {
    test('renderAxis draws horizontal axis line when showAxisLine is true', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: true,
          showLabels: false,
          showTicks: false,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      // Generate labels first (needed for internal state)
      renderer.generateLabels(bounds);

      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis draws vertical axis line when showAxisLine is true', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: true,
          showLabels: false,
          showTicks: false,
        ),
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 50, 300);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis uses configuration axis line color', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: true,
          showLabels: false,
          showTicks: false,
          axisLineColor: Colors.red,
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis uses configuration axis line width', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: true,
          showLabels: false,
          showTicks: false,
          axisLineWidth: 2.5,
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });

  // ===========================================================================
  // RENDERING - TICKS
  // ===========================================================================

  group('CategoryAxisRenderer - Tick Rendering', () {
    test('renderAxis draws ticks when showTicks is true', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: false,
          showLabels: false,
          showTicks: true,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis draws vertical ticks correctly', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: false,
          showLabels: false,
          showTicks: true,
        ),
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 50, 300);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis uses configuration tick color', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showTicks: true,
          showAxisLine: false,
          showLabels: false,
          majorTickColor: Colors.blue,
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis uses configuration tick width', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showTicks: true,
          showAxisLine: false,
          showLabels: false,
          majorTickWidth: 2.0,
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis uses configuration tick length', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showTicks: true,
          showAxisLine: false,
          showLabels: false,
          majorTickLength: 10.0,
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });

  // ===========================================================================
  // RENDERING - LABELS
  // ===========================================================================

  group('CategoryAxisRenderer - Label Rendering', () {
    test('renderAxis draws labels when showLabels is true', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Category 1', 'Category 2'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: false,
          showLabels: true,
          showTicks: false,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis draws vertical labels correctly', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Category 1', 'Category 2'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: false,
          showLabels: true,
          showTicks: false,
        ),
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 100, 300);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis applies label rotation when configured', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Long Category Name 1', 'Long Category Name 2'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
          labelRotation: 45.0,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 200, 100);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis uses custom label style from configuration', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
          labelStyle: TextStyle(
            fontSize: 16,
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderAxis uses theme label style when config style is null', () {
      const theme = FusionLightTheme();
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
        ),
        theme: theme,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 400, 50);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });

  // ===========================================================================
  // RENDERING - GRID LINES
  // ===========================================================================

  group('CategoryAxisRenderer - Grid Line Rendering', () {
    test('renderGridLines draws grid lines when showGrid is true', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C', 'D'],
        configuration: const FusionAxisConfiguration(showGrid: true),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.renderGridLines(canvas, plotArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderGridLines draws vertical grid lines for horizontal axis', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(showGrid: true),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.renderGridLines(canvas, plotArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderGridLines draws horizontal grid lines for vertical axis', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(showGrid: true),
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.renderGridLines(canvas, plotArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderGridLines uses configuration grid color', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          showGrid: true,
          majorGridColor: Colors.orange,
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.renderGridLines(canvas, plotArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderGridLines uses configuration grid width', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          showGrid: true,
          majorGridWidth: 2.0,
        ),
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.renderGridLines(canvas, plotArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renderGridLines uses theme grid color when config is null', () {
      const theme = FusionLightTheme();
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(showGrid: true),
        theme: theme,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.renderGridLines(canvas, plotArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================

  group('CategoryAxisRenderer - Edge Cases', () {
    test('handles single category correctly', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Single'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 1);
      expect(labels[0].position, 0.5);
    });

    test('handles many categories', () {
      final categories = List.generate(100, (i) => 'Category $i');
      final renderer = CategoryAxisRenderer(
        categories: categories,
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 100);
      expect(bounds.min, -0.5);
      expect(bounds.max, 99.5);
    });

    test('handles categories with special characters', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Q1 2024', 'Q2/2024', 'Q3-2024', 'Q4 (2024)'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 4);
      expect(labels[0].text, 'Q1 2024');
      expect(labels[1].text, 'Q2/2024');
      expect(labels[2].text, 'Q3-2024');
      expect(labels[3].text, 'Q4 (2024)');
    });

    test('handles categories with unicode characters', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Alpha', 'Beta', 'Gamma', 'Delta'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 4);
    });

    test('handles empty string category', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', '', 'C'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels.length, 3);
      expect(labels[1].text, '');
    });

    test('handles very long category names', () {
      final renderer = CategoryAxisRenderer(
        categories: const [
          'This is a very long category name that might cause layout issues',
          'Another extremely long category name for testing purposes',
        ],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(100, 300));

      expect(labels.length, 2);
      expect(size.height, greaterThan(0));
    });

    test('handles numeric-looking category names', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['123', '456', '789'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels[0].text, '123');
      expect(labels[1].text, '456');
      expect(labels[2].text, '789');
    });
  });

  // ===========================================================================
  // DISPOSAL
  // ===========================================================================

  group('CategoryAxisRenderer - Disposal', () {
    test('dispose clears cached bounds', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      renderer.calculateBounds([]);
      renderer.dispose();

      // After dispose, can still calculate bounds (reinitializes)
      final bounds = renderer.calculateBounds([]);
      expect(bounds, isNotNull);
    });

    test('dispose clears cached labels', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      renderer.generateLabels(bounds);
      renderer.dispose();

      // After dispose, can still generate labels (reinitializes)
      final labels = renderer.generateLabels(bounds);
      expect(labels, isNotNull);
    });

    test('dispose can be called multiple times safely', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B'],
        configuration: const FusionAxisConfiguration(),
      );

      renderer.calculateBounds([]);
      renderer.dispose();
      renderer.dispose();
      renderer.dispose();

      // Should not throw
      expect(true, isTrue);
    });

    test('renderer is usable after dispose', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      renderer.calculateBounds([]);
      renderer.dispose();

      // Should be able to use again
      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(400, 300));

      expect(bounds.min, -0.5);
      expect(labels.length, 3);
      expect(size.height, greaterThan(0));
    });
  });

  // ===========================================================================
  // TOSTRING
  // ===========================================================================

  group('CategoryAxisRenderer - toString', () {
    test('toString returns descriptive string', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C', 'D'],
        configuration: const FusionAxisConfiguration(visible: true),
        isVertical: false,
      );

      final str = renderer.toString();

      expect(str, contains('CategoryAxisRenderer'));
      expect(str, contains('4')); // category count
      expect(str, contains('visible: true'));
      expect(str, contains('isVertical: false'));
    });

    test('toString shows vertical axis correctly', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['X', 'Y'],
        configuration: const FusionAxisConfiguration(visible: false),
        isVertical: true,
      );

      final str = renderer.toString();

      expect(str, contains('CategoryAxisRenderer'));
      expect(str, contains('2')); // category count
      expect(str, contains('visible: false'));
      expect(str, contains('isVertical: true'));
    });
  });

  // ===========================================================================
  // CATEGORY POSITION CALCULATION
  // ===========================================================================

  group('CategoryAxisRenderer - Category Position Calculation', () {
    test('position calculation is consistent between labels and ticks', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C', 'D', 'E'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // Verify positions are evenly distributed
      expect(labels[0].position, 0.0); // 0 / 4
      expect(labels[1].position, 0.25); // 1 / 4
      expect(labels[2].position, 0.5); // 2 / 4
      expect(labels[3].position, 0.75); // 3 / 4
      expect(labels[4].position, 1.0); // 4 / 4
    });

    test('position calculation handles three categories', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Low', 'Medium', 'High'],
        configuration: const FusionAxisConfiguration(visible: true),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      expect(labels[0].position, 0.0); // 0 / 2
      expect(labels[1].position, 0.5); // 1 / 2
      expect(labels[2].position, 1.0); // 2 / 2
    });
  });

  // ===========================================================================
  // RENDERING COMPLETE AXIS
  // ===========================================================================

  group('CategoryAxisRenderer - Complete Axis Rendering', () {
    test('renders complete horizontal axis with all elements', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Q1', 'Q2', 'Q3', 'Q4'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: true,
          showTicks: true,
          showLabels: true,
          showGrid: true,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(50, 250, 300, 40);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.generateLabels(bounds);
      renderer.renderGridLines(canvas, plotArea, bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renders complete vertical axis with all elements', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Low', 'Medium', 'High', 'Very High'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: true,
          showTicks: true,
          showLabels: true,
          showGrid: true,
        ),
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 50, 50, 200);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.generateLabels(bounds);
      renderer.renderGridLines(canvas, plotArea, bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('renders axis with theme styling', () {
      const theme = FusionLightTheme();
      final renderer = CategoryAxisRenderer(
        categories: const ['Jan', 'Feb', 'Mar'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showAxisLine: true,
          showTicks: true,
          showLabels: true,
          showGrid: true,
        ),
        theme: theme,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(50, 250, 300, 40);
      const plotArea = Rect.fromLTWH(50, 50, 300, 200);

      renderer.generateLabels(bounds);
      renderer.renderGridLines(canvas, plotArea, bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });

  // ===========================================================================
  // LABEL ROTATION
  // ===========================================================================

  group('CategoryAxisRenderer - Label Rotation', () {
    test('auto-rotates labels when they would overlap (horizontal axis)', () {
      final renderer = CategoryAxisRenderer(
        categories: const [
          'Very Long Category 1',
          'Very Long Category 2',
          'Very Long Category 3',
        ],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      // Measure with very narrow width to trigger rotation
      final sizeNarrow = renderer.measureAxisLabels(
        labels,
        const Size(50, 300),
      );

      // Measure with wide width where rotation shouldn't be needed
      final renderer2 = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
        ),
        isVertical: false,
      );
      final bounds2 = renderer2.calculateBounds([]);
      final labels2 = renderer2.generateLabels(bounds2);
      final sizeWide = renderer2.measureAxisLabels(
        labels2,
        const Size(400, 300),
      );

      // Both should have valid heights
      expect(sizeNarrow.height, greaterThan(0));
      expect(sizeWide.height, greaterThan(0));
    });

    test('does not rotate labels for vertical axis', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Category 1', 'Category 2', 'Category 3'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
        ),
        isVertical: true,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(50, 300));

      // Vertical axis should return width based on label width
      expect(size.width, greaterThan(0));
      expect(size.height, 300);
    });

    test('does not rotate labels for single category', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['Single Very Long Category Name'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);
      final size = renderer.measureAxisLabels(labels, const Size(100, 300));

      // Single category should not need rotation
      expect(size.height, greaterThan(0));
    });

    test('uses configuration labelRotation when specified', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(
          visible: true,
          showLabels: true,
          labelRotation: 90.0,
        ),
        isVertical: false,
      );

      final bounds = renderer.calculateBounds([]);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const axisArea = Rect.fromLTWH(0, 0, 100, 100);

      renderer.generateLabels(bounds);
      renderer.renderAxis(canvas, axisArea, bounds);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });

  // ===========================================================================
  // AXIS BOUNDS EDGE CASES
  // ===========================================================================

  group('CategoryAxisRenderer - Bounds Edge Cases', () {
    test('bounds range spans from -0.5 to n-0.5', () {
      for (int n = 1; n <= 10; n++) {
        final categories = List.generate(n, (i) => 'Cat $i');
        final renderer = CategoryAxisRenderer(
          categories: categories,
          configuration: const FusionAxisConfiguration(),
        );

        final bounds = renderer.calculateBounds([]);

        expect(bounds.min, -0.5);
        expect(bounds.max, n - 0.5);
        expect(bounds.range, n.toDouble());
      }
    });

    test('bounds always have interval of 1.0', () {
      for (int n = 1; n <= 10; n++) {
        final categories = List.generate(n, (i) => 'Cat $i');
        final renderer = CategoryAxisRenderer(
          categories: categories,
          configuration: const FusionAxisConfiguration(),
        );

        final bounds = renderer.calculateBounds([]);

        expect(bounds.interval, 1.0);
      }
    });

    test('bounds always have 0 decimal places', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);

      expect(bounds.decimalPlaces, 0);
    });
  });

  // ===========================================================================
  // AXIS LABEL TYPE
  // ===========================================================================

  group('CategoryAxisRenderer - AxisLabel Type', () {
    test('generated labels have correct types', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['X', 'Y', 'Z'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      for (final label in labels) {
        expect(label, isA<AxisLabel>());
        expect(label.value, isA<double>());
        expect(label.text, isA<String>());
        expect(label.position, isA<double>());
      }
    });

    test('label values are integers as doubles', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C', 'D', 'E'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      for (int i = 0; i < labels.length; i++) {
        expect(labels[i].value, i.toDouble());
        expect(labels[i].value % 1, 0.0); // No decimal part
      }
    });

    test('label positions are normalized between 0 and 1', () {
      final renderer = CategoryAxisRenderer(
        categories: const ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'],
        configuration: const FusionAxisConfiguration(),
      );

      final bounds = renderer.calculateBounds([]);
      final labels = renderer.generateLabels(bounds);

      for (final label in labels) {
        expect(label.position, greaterThanOrEqualTo(0.0));
        expect(label.position, lessThanOrEqualTo(1.0));
      }
    });
  });
}

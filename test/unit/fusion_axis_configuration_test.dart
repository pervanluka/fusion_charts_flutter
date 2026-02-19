import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_axis_configuration.dart';
import 'package:fusion_charts_flutter/src/core/enums/axis_position.dart';
import 'package:fusion_charts_flutter/src/core/enums/label_alignment.dart';

void main() {
  // ===========================================================================
  // FUSION AXIS CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionAxisConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionAxisConfiguration();

      expect(config.min, isNull);
      expect(config.max, isNull);
      expect(config.interval, isNull);
      expect(config.title, isNull);
      expect(config.labelFormatter, isNull);
      expect(config.labelStyle, isNull);
      expect(config.labelRotation, isNull);
      expect(config.labelAlignment, LabelAlignment.center);
      expect(config.visible, isTrue);
      expect(config.autoRange, isTrue);
      expect(config.autoInterval, isTrue);
      expect(config.includeZero, isNull);
      expect(config.desiredTickCount, 5);
      expect(config.desiredIntervals, 5);
      expect(config.useAbbreviation, isTrue);
      expect(config.useScientificNotation, isFalse);
      expect(config.showGrid, isTrue);
      expect(config.showMinorGrid, isFalse);
      expect(config.showMinorTicks, isFalse);
      expect(config.showTicks, isFalse);
      expect(config.showLabels, isTrue);
      expect(config.showAxisLine, isTrue);
    });

    test('creates with custom values', () {
      const config = FusionAxisConfiguration(
        min: 0,
        max: 100,
        interval: 20,
        title: 'Revenue',
        labelRotation: 45.0,
        labelAlignment: LabelAlignment.start,
        visible: true,
        autoRange: false,
        autoInterval: false,
        includeZero: true,
        desiredTickCount: 10,
        desiredIntervals: 10,
        useAbbreviation: false,
        useScientificNotation: true,
        showGrid: false,
        showMinorGrid: true,
        showMinorTicks: true,
        showTicks: true,
        showLabels: false,
        showAxisLine: false,
        position: AxisPosition.right,
        majorTickColor: Colors.red,
        majorTickWidth: 2.0,
        majorTickLength: 8.0,
        minorTickColor: Colors.blue,
        minorTickWidth: 1.0,
        minorTickLength: 4.0,
        majorGridColor: Colors.grey,
        majorGridWidth: 1.0,
        minorGridColor: Colors.black12,
        minorGridWidth: 0.5,
        axisLineColor: Colors.black,
        axisLineWidth: 2.0,
        rangePadding: 0.1,
      );

      expect(config.min, 0);
      expect(config.max, 100);
      expect(config.interval, 20);
      expect(config.title, 'Revenue');
      expect(config.labelRotation, 45.0);
      expect(config.labelAlignment, LabelAlignment.start);
      expect(config.autoRange, isFalse);
      expect(config.autoInterval, isFalse);
      expect(config.includeZero, isTrue);
      expect(config.desiredTickCount, 10);
      expect(config.desiredIntervals, 10);
      expect(config.useAbbreviation, isFalse);
      expect(config.useScientificNotation, isTrue);
      expect(config.showGrid, isFalse);
      expect(config.showMinorGrid, isTrue);
      expect(config.showMinorTicks, isTrue);
      expect(config.showTicks, isTrue);
      expect(config.showLabels, isFalse);
      expect(config.showAxisLine, isFalse);
      expect(config.position, AxisPosition.right);
      expect(config.majorTickColor, Colors.red);
      expect(config.majorTickWidth, 2.0);
      expect(config.majorTickLength, 8.0);
      expect(config.minorTickColor, Colors.blue);
      expect(config.minorTickWidth, 1.0);
      expect(config.minorTickLength, 4.0);
      expect(config.majorGridColor, Colors.grey);
      expect(config.majorGridWidth, 1.0);
      expect(config.minorGridColor, Colors.black12);
      expect(config.minorGridWidth, 0.5);
      expect(config.axisLineColor, Colors.black);
      expect(config.axisLineWidth, 2.0);
      expect(config.rangePadding, 0.1);
    });

    test('creates with label formatter', () {
      final config = FusionAxisConfiguration(
        labelFormatter: (value) => '\$${value.toStringAsFixed(2)}',
      );

      expect(config.labelFormatter, isNotNull);
      expect(config.labelFormatter!(100), '\$100.00');
    });

    test('creates with label generator', () {
      final config = FusionAxisConfiguration(
        labelGenerator: (bounds, availableSize, isVertical) => [0, 50, 100],
      );

      expect(config.labelGenerator, isNotNull);
      expect(config.hasLabelGenerator, isTrue);
    });
  });

  // ===========================================================================
  // FUSION AXIS CONFIGURATION - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionAxisConfiguration - Computed Properties', () {
    test('effectiveMin returns min when set', () {
      const config = FusionAxisConfiguration(min: 10);
      expect(config.effectiveMin, 10);
    });

    test('effectiveMin returns 0 when not set', () {
      const config = FusionAxisConfiguration();
      expect(config.effectiveMin, 0.0);
    });

    test('effectiveMax returns max when set', () {
      const config = FusionAxisConfiguration(max: 100);
      expect(config.effectiveMax, 100);
    });

    test('effectiveMax returns 10 when not set', () {
      const config = FusionAxisConfiguration();
      expect(config.effectiveMax, 10.0);
    });

    test('effectiveInterval returns interval when set', () {
      const config = FusionAxisConfiguration(interval: 5);
      expect(config.effectiveInterval, 5);
    });

    test('effectiveInterval returns 1 when not set', () {
      const config = FusionAxisConfiguration();
      expect(config.effectiveInterval, 1.0);
    });

    test('hasExplicitBounds returns true when both min and max set', () {
      const config = FusionAxisConfiguration(min: 0, max: 100);
      expect(config.hasExplicitBounds, isTrue);
    });

    test('hasExplicitBounds returns false when only min set', () {
      const config = FusionAxisConfiguration(min: 0);
      expect(config.hasExplicitBounds, isFalse);
    });

    test('hasExplicitBounds returns false when only max set', () {
      const config = FusionAxisConfiguration(max: 100);
      expect(config.hasExplicitBounds, isFalse);
    });

    test('hasExplicitInterval returns true when interval set', () {
      const config = FusionAxisConfiguration(interval: 10);
      expect(config.hasExplicitInterval, isTrue);
    });

    test('hasExplicitInterval returns false when interval not set', () {
      const config = FusionAxisConfiguration();
      expect(config.hasExplicitInterval, isFalse);
    });

    test(
      'isFullyAutomatic returns true when both autoRange and autoInterval',
      () {
        const config = FusionAxisConfiguration(
          autoRange: true,
          autoInterval: true,
        );
        expect(config.isFullyAutomatic, isTrue);
      },
    );

    test('isFullyAutomatic returns false when not both auto', () {
      const config = FusionAxisConfiguration(
        autoRange: false,
        autoInterval: true,
      );
      expect(config.isFullyAutomatic, isFalse);
    });

    test('hasAnyAutomatic returns true when autoRange', () {
      const config = FusionAxisConfiguration(
        autoRange: true,
        autoInterval: false,
      );
      expect(config.hasAnyAutomatic, isTrue);
    });

    test('hasAnyAutomatic returns true when autoInterval', () {
      const config = FusionAxisConfiguration(
        autoRange: false,
        autoInterval: true,
      );
      expect(config.hasAnyAutomatic, isTrue);
    });

    test('hasAnyAutomatic returns false when neither auto', () {
      const config = FusionAxisConfiguration(
        autoRange: false,
        autoInterval: false,
      );
      expect(config.hasAnyAutomatic, isFalse);
    });

    test('hasLabelGenerator returns true when generator set', () {
      final config = FusionAxisConfiguration(labelGenerator: (_, _, _) => []);
      expect(config.hasLabelGenerator, isTrue);
    });

    test('hasLabelGenerator returns false when generator not set', () {
      const config = FusionAxisConfiguration();
      expect(config.hasLabelGenerator, isFalse);
    });

    test('getEffectivePosition returns position when set', () {
      const config = FusionAxisConfiguration(position: AxisPosition.right);
      expect(config.getEffectivePosition(isVertical: true), AxisPosition.right);
    });

    test('getEffectivePosition returns default for vertical axis', () {
      const config = FusionAxisConfiguration();
      expect(
        config.getEffectivePosition(isVertical: true),
        AxisPosition.defaultVertical,
      );
    });

    test('getEffectivePosition returns default for horizontal axis', () {
      const config = FusionAxisConfiguration();
      expect(
        config.getEffectivePosition(isVertical: false),
        AxisPosition.defaultHorizontal,
      );
    });
  });

  // ===========================================================================
  // FUSION AXIS CONFIGURATION - VALIDATION
  // ===========================================================================
  group('FusionAxisConfiguration - Validation', () {
    test('validate returns true for valid config', () {
      const config = FusionAxisConfiguration(min: 0, max: 100, interval: 10);
      expect(config.validate(), isTrue);
    });

    test('validate returns false when min >= max', () {
      const config = FusionAxisConfiguration(min: 100, max: 100);
      expect(config.validate(), isFalse);
    });

    test('validate returns false when min > max', () {
      const config = FusionAxisConfiguration(min: 100, max: 50);
      expect(config.validate(), isFalse);
    });

    test('validate returns false when interval <= 0', () {
      const config = FusionAxisConfiguration(interval: 0);
      expect(config.validate(), isFalse);
    });

    test('validate returns false when interval negative', () {
      const config = FusionAxisConfiguration(interval: -5);
      expect(config.validate(), isFalse);
    });

    test('validate returns false when desiredIntervals <= 0', () {
      const config = FusionAxisConfiguration(desiredIntervals: 0);
      expect(config.validate(), isFalse);
    });

    test('validate returns false when desiredTickCount <= 0', () {
      const config = FusionAxisConfiguration(desiredTickCount: 0);
      expect(config.validate(), isFalse);
    });

    test('validate returns false when rangePadding < 0', () {
      const config = FusionAxisConfiguration(rangePadding: -0.1);
      expect(config.validate(), isFalse);
    });

    test('validate returns false when rangePadding > 1', () {
      const config = FusionAxisConfiguration(rangePadding: 1.5);
      expect(config.validate(), isFalse);
    });

    test('getValidationError returns null for valid config', () {
      const config = FusionAxisConfiguration();
      expect(config.getValidationError(), isNull);
    });

    test('getValidationError returns message when min >= max', () {
      const config = FusionAxisConfiguration(min: 100, max: 50);
      expect(config.getValidationError(), contains('min'));
      expect(config.getValidationError(), contains('max'));
    });

    test('getValidationError returns message when interval <= 0', () {
      const config = FusionAxisConfiguration(interval: -1);
      expect(config.getValidationError(), contains('interval'));
    });
  });

  // ===========================================================================
  // FUSION AXIS CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionAxisConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionAxisConfiguration(min: 0, max: 100);

      final copy = original.copyWith(min: 10, max: 200);

      expect(copy.min, 10);
      expect(copy.max, 200);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionAxisConfiguration(
        min: 0,
        max: 100,
        interval: 10,
        title: 'Test',
        visible: false,
      );

      final copy = original.copyWith(min: 5);

      expect(copy.min, 5);
      expect(copy.max, 100);
      expect(copy.interval, 10);
      expect(copy.title, 'Test');
      expect(copy.visible, isFalse);
    });

    test('copyWith handles all parameters', () {
      const original = FusionAxisConfiguration();

      final copy = original.copyWith(
        min: 0,
        max: 100,
        interval: 10,
        title: 'Revenue',
        labelRotation: 45,
        labelAlignment: LabelAlignment.end,
        visible: false,
        autoRange: false,
        autoInterval: false,
        includeZero: true,
        desiredTickCount: 10,
        desiredIntervals: 10,
        useAbbreviation: false,
        useScientificNotation: true,
        showGrid: false,
        showMinorGrid: true,
        showMinorTicks: true,
        showTicks: true,
        showLabels: false,
        showAxisLine: false,
        position: AxisPosition.top,
        majorTickColor: Colors.red,
        majorTickWidth: 2.0,
        majorTickLength: 8.0,
        minorTickColor: Colors.blue,
        minorTickWidth: 1.0,
        minorTickLength: 4.0,
        majorGridColor: Colors.grey,
        majorGridWidth: 1.0,
        minorGridColor: Colors.black12,
        minorGridWidth: 0.5,
        axisLineColor: Colors.black,
        axisLineWidth: 2.0,
        rangePadding: 0.1,
      );

      expect(copy.min, 0);
      expect(copy.max, 100);
      expect(copy.interval, 10);
      expect(copy.title, 'Revenue');
      expect(copy.labelRotation, 45);
      expect(copy.labelAlignment, LabelAlignment.end);
      expect(copy.visible, isFalse);
      expect(copy.autoRange, isFalse);
      expect(copy.autoInterval, isFalse);
      expect(copy.includeZero, isTrue);
      expect(copy.desiredTickCount, 10);
      expect(copy.desiredIntervals, 10);
      expect(copy.useAbbreviation, isFalse);
      expect(copy.useScientificNotation, isTrue);
      expect(copy.showGrid, isFalse);
      expect(copy.showMinorGrid, isTrue);
      expect(copy.showMinorTicks, isTrue);
      expect(copy.showTicks, isTrue);
      expect(copy.showLabels, isFalse);
      expect(copy.showAxisLine, isFalse);
      expect(copy.position, AxisPosition.top);
      expect(copy.rangePadding, 0.1);
    });
  });

  // ===========================================================================
  // FUSION AXIS CONFIGURATION - EQUALITY
  // ===========================================================================
  group('FusionAxisConfiguration - Equality', () {
    test('equal configs are equal', () {
      const config1 = FusionAxisConfiguration(min: 0, max: 100, interval: 10);

      const config2 = FusionAxisConfiguration(min: 0, max: 100, interval: 10);

      expect(config1, equals(config2));
    });

    test('different configs are not equal', () {
      const config1 = FusionAxisConfiguration(min: 0);
      const config2 = FusionAxisConfiguration(min: 10);

      expect(config1, isNot(equals(config2)));
    });

    test('hashCode is consistent', () {
      const config1 = FusionAxisConfiguration(min: 0, max: 100);
      const config2 = FusionAxisConfiguration(min: 0, max: 100);

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('identical configs are equal', () {
      const config = FusionAxisConfiguration();
      expect(config == config, isTrue);
    });
  });

  // ===========================================================================
  // FUSION AXIS CONFIGURATION - TOSTRING
  // ===========================================================================
  group('FusionAxisConfiguration - toString', () {
    test('toString returns descriptive string', () {
      const config = FusionAxisConfiguration(
        min: 0,
        max: 100,
        interval: 20,
        autoRange: false,
        autoInterval: false,
      );

      final str = config.toString();

      expect(str, contains('FusionAxisConfiguration'));
      expect(str, contains('min: 0'));
      expect(str, contains('max: 100'));
      expect(str, contains('interval: 20'));
      expect(str, contains('autoRange: false'));
    });
  });

  // ===========================================================================
  // FUSION AXIS CONFIGURATION BUILDER
  // ===========================================================================
  group('FusionAxisConfigurationBuilder', () {
    test('builds config with range', () {
      final config = FusionAxisConfigurationBuilder().withRange(0, 100).build();

      expect(config.min, 0);
      expect(config.max, 100);
      expect(config.autoRange, isFalse);
    });

    test('builds config with interval', () {
      final config = FusionAxisConfigurationBuilder().withInterval(20).build();

      expect(config.interval, 20);
      expect(config.autoInterval, isFalse);
    });

    test('builds config with title', () {
      final config = FusionAxisConfigurationBuilder()
          .withTitle('Revenue')
          .build();

      expect(config.title, 'Revenue');
    });

    test('builds config with auto range', () {
      final config = FusionAxisConfigurationBuilder().withAutoRange(10).build();

      expect(config.autoRange, isTrue);
      expect(config.autoInterval, isTrue);
      expect(config.desiredIntervals, 10);
    });

    test('builds complete config with fluent API', () {
      final config = FusionAxisConfigurationBuilder()
          .withRange(0, 1000)
          .withInterval(100)
          .withTitle('Sales')
          .build();

      expect(config.min, 0);
      expect(config.max, 1000);
      expect(config.interval, 100);
      expect(config.title, 'Sales');
      expect(config.autoRange, isFalse);
      expect(config.autoInterval, isFalse);
    });
  });

  // ===========================================================================
  // LABEL ALIGNMENT ENUM
  // ===========================================================================
  group('LabelAlignment - Enum', () {
    test('has all expected values', () {
      expect(LabelAlignment.values, hasLength(3));
      expect(LabelAlignment.values, contains(LabelAlignment.start));
      expect(LabelAlignment.values, contains(LabelAlignment.center));
      expect(LabelAlignment.values, contains(LabelAlignment.end));
    });
  });

  // ===========================================================================
  // AXIS POSITION ENUM
  // ===========================================================================
  group('AxisPosition - Enum', () {
    test('has all expected values', () {
      expect(AxisPosition.values, hasLength(4));
      expect(AxisPosition.values, contains(AxisPosition.left));
      expect(AxisPosition.values, contains(AxisPosition.right));
      expect(AxisPosition.values, contains(AxisPosition.top));
      expect(AxisPosition.values, contains(AxisPosition.bottom));
    });

    test('defaultVertical returns left', () {
      expect(AxisPosition.defaultVertical, AxisPosition.left);
    });

    test('defaultHorizontal returns bottom', () {
      expect(AxisPosition.defaultHorizontal, AxisPosition.bottom);
    });
  });
}

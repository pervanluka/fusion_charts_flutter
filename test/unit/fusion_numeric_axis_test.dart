import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/axis/numeric/fusion_numeric_axis.dart';
import 'package:fusion_charts_flutter/src/core/enums/axis_range_padding.dart';
import 'package:fusion_charts_flutter/src/core/enums/label_alignment.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================
  group('FusionNumericAxis - Construction', () {
    test('creates with default values', () {
      const axis = FusionNumericAxis();

      expect(axis.name, isNull);
      expect(axis.title, isNull);
      expect(axis.titleStyle, isNull);
      expect(axis.opposedPosition, isFalse);
      expect(axis.isInversed, isFalse);
      expect(axis.min, isNull);
      expect(axis.max, isNull);
      expect(axis.interval, isNull);
      expect(axis.desiredIntervals, 5);
      expect(axis.labelFormatter, isNull);
      expect(axis.labelAlignment, LabelAlignment.center);
      expect(axis.decimalPlaces, 2);
      expect(axis.useScientificNotation, isFalse);
      expect(axis.rangePadding, AxisRangePadding.auto);
    });

    test('creates with custom values', () {
      const axis = FusionNumericAxis(
        name: 'primaryY',
        title: 'Revenue',
        titleStyle: TextStyle(fontSize: 14, color: Colors.blue),
        opposedPosition: true,
        isInversed: true,
        min: 0,
        max: 100,
        interval: 10,
        desiredIntervals: 10,
        labelAlignment: LabelAlignment.end,
        decimalPlaces: 0,
        useScientificNotation: true,
        rangePadding: AxisRangePadding.round,
      );

      expect(axis.name, 'primaryY');
      expect(axis.title, 'Revenue');
      expect(axis.titleStyle?.fontSize, 14);
      expect(axis.opposedPosition, isTrue);
      expect(axis.isInversed, isTrue);
      expect(axis.min, 0);
      expect(axis.max, 100);
      expect(axis.interval, 10);
      expect(axis.desiredIntervals, 10);
      expect(axis.labelAlignment, LabelAlignment.end);
      expect(axis.decimalPlaces, 0);
      expect(axis.useScientificNotation, isTrue);
      expect(axis.rangePadding, AxisRangePadding.round);
    });

    test('creates with label formatter', () {
      final axis = FusionNumericAxis(
        labelFormatter: (value) => '\$${value.toStringAsFixed(2)}',
      );

      expect(axis.labelFormatter, isNotNull);
      expect(axis.labelFormatter!(100), '\$100.00');
    });
  });

  // ===========================================================================
  // COPYWITH
  // ===========================================================================
  group('FusionNumericAxis - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionNumericAxis(min: 0, max: 100);

      final copy = original.copyWith(min: 10, max: 90);

      expect(copy.min, 10);
      expect(copy.max, 90);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionNumericAxis(
        name: 'yAxis',
        title: 'Values',
        min: 0,
        max: 100,
        interval: 10,
      );

      final copy = original.copyWith(min: 50);

      expect(copy.name, 'yAxis');
      expect(copy.title, 'Values');
      expect(copy.min, 50);
      expect(copy.max, 100);
      expect(copy.interval, 10);
    });

    test('copyWith handles all parameters', () {
      const original = FusionNumericAxis();

      final copy = original.copyWith(
        name: 'newAxis',
        title: 'New Title',
        titleStyle: const TextStyle(fontSize: 16),
        opposedPosition: true,
        isInversed: true,
        min: -100,
        max: 100,
        interval: 25,
        desiredIntervals: 8,
        labelAlignment: LabelAlignment.start,
        decimalPlaces: 1,
        useScientificNotation: true,
        rangePadding: AxisRangePadding.none,
      );

      expect(copy.name, 'newAxis');
      expect(copy.title, 'New Title');
      expect(copy.titleStyle?.fontSize, 16);
      expect(copy.opposedPosition, isTrue);
      expect(copy.isInversed, isTrue);
      expect(copy.min, -100);
      expect(copy.max, 100);
      expect(copy.interval, 25);
      expect(copy.desiredIntervals, 8);
      expect(copy.labelAlignment, LabelAlignment.start);
      expect(copy.decimalPlaces, 1);
      expect(copy.useScientificNotation, isTrue);
      expect(copy.rangePadding, AxisRangePadding.none);
    });

    test('copyWith with label formatter', () {
      const original = FusionNumericAxis();

      final copy = original.copyWith(
        labelFormatter: (value) => '${value.toInt()}K',
      );

      expect(copy.labelFormatter, isNotNull);
      expect(copy.labelFormatter!(50), '50K');
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================
  group('FusionNumericAxis - Equality', () {
    test('equal axes are equal', () {
      const axis1 = FusionNumericAxis(
        name: 'yAxis',
        min: 0,
        max: 100,
        interval: 10,
      );
      const axis2 = FusionNumericAxis(
        name: 'yAxis',
        min: 0,
        max: 100,
        interval: 10,
      );

      expect(axis1, equals(axis2));
    });

    test('different axes are not equal', () {
      const axis1 = FusionNumericAxis(min: 0, max: 100);
      const axis2 = FusionNumericAxis(min: 0, max: 50);

      expect(axis1, isNot(equals(axis2)));
    });

    test('hashCode is consistent', () {
      const axis1 = FusionNumericAxis(name: 'yAxis', min: 0, max: 100);
      const axis2 = FusionNumericAxis(name: 'yAxis', min: 0, max: 100);

      expect(axis1.hashCode, equals(axis2.hashCode));
    });

    test('identical axes are equal', () {
      const axis = FusionNumericAxis();
      expect(axis == axis, isTrue);
    });
  });

  // ===========================================================================
  // TOSTRING
  // ===========================================================================
  group('FusionNumericAxis - toString', () {
    test('toString returns descriptive string', () {
      const axis = FusionNumericAxis(
        min: 0,
        max: 100,
        interval: 10,
        desiredIntervals: 5,
        rangePadding: AxisRangePadding.normal,
      );

      final str = axis.toString();

      expect(str, contains('FusionNumericAxis'));
      expect(str, contains('min: 0'));
      expect(str, contains('max: 100'));
      expect(str, contains('interval: 10'));
      expect(str, contains('desiredIntervals: 5'));
      expect(str, contains('rangePadding'));
    });
  });

  // ===========================================================================
  // AXIS RANGE PADDING ENUM
  // ===========================================================================
  group('AxisRangePadding - Enum', () {
    test('has all expected values', () {
      expect(AxisRangePadding.values, hasLength(5));
      expect(AxisRangePadding.values, contains(AxisRangePadding.none));
      expect(AxisRangePadding.values, contains(AxisRangePadding.normal));
      expect(AxisRangePadding.values, contains(AxisRangePadding.round));
      expect(AxisRangePadding.values, contains(AxisRangePadding.additional));
      expect(AxisRangePadding.values, contains(AxisRangePadding.auto));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/charts/pie/pie_tooltip_data.dart';
import 'package:fusion_charts_flutter/src/data/fusion_pie_data_point.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION - Required Parameters
  // ===========================================================================

  group('PieTooltipData - Construction with Required Parameters', () {
    test('creates with all required parameters', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(100, 100),
      );

      expect(data.index, 0);
      expect(data.value, 100.0);
      expect(data.percentage, 25.0);
      expect(data.color, Colors.blue);
      expect(data.screenPosition, const Offset(150, 200));
      expect(data.segmentCenter, const Offset(100, 100));
    });

    test('creates with different index values', () {
      const data = PieTooltipData(
        index: 5,
        value: 50.0,
        percentage: 10.0,
        color: Colors.red,
        screenPosition: Offset.zero,
        segmentCenter: Offset(50, 50),
      );

      expect(data.index, 5);
    });

    test('creates with zero value', () {
      const data = PieTooltipData(
        index: 0,
        value: 0.0,
        percentage: 0.0,
        color: Colors.grey,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.value, 0.0);
      expect(data.percentage, 0.0);
    });

    test('creates with 100% percentage', () {
      const data = PieTooltipData(
        index: 0,
        value: 1000.0,
        percentage: 100.0,
        color: Colors.green,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.percentage, 100.0);
    });

    test('creates with large value', () {
      const data = PieTooltipData(
        index: 0,
        value: 1000000.0,
        percentage: 50.0,
        color: Colors.purple,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.value, 1000000.0);
    });

    test('creates with negative offset positions', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(-50, -50),
        segmentCenter: Offset(-25, -25),
      );

      expect(data.screenPosition, const Offset(-50, -50));
      expect(data.segmentCenter, const Offset(-25, -25));
    });
  });

  // ===========================================================================
  // CONSTRUCTION - Optional Parameters
  // ===========================================================================

  group('PieTooltipData - Optional Parameters', () {
    test('default optional parameters are correct', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(100, 100),
      );

      expect(data.label, isNull);
      expect(data.dataPoint, isNull);
      expect(data.isExploded, isFalse);
      expect(data.isSelected, isFalse);
    });

    test('creates with label', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(100, 100),
        label: 'Sales',
      );

      expect(data.label, 'Sales');
    });

    test('creates with empty label', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(100, 100),
        label: '',
      );

      expect(data.label, '');
    });

    test('creates with dataPoint', () {
      const dataPoint = FusionPieDataPoint(100, label: 'Revenue');
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(100, 100),
        dataPoint: dataPoint,
      );

      expect(data.dataPoint, isNotNull);
      expect(data.dataPoint?.value, 100);
      expect(data.dataPoint?.label, 'Revenue');
    });

    test('creates with isExploded true', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(100, 100),
        isExploded: true,
      );

      expect(data.isExploded, isTrue);
    });

    test('creates with isSelected true', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(100, 100),
        isSelected: true,
      );

      expect(data.isSelected, isTrue);
    });

    test('creates with all optional parameters', () {
      const dataPoint = FusionPieDataPoint(100, label: 'Test');
      const data = PieTooltipData(
        index: 2,
        value: 250.5,
        percentage: 33.3,
        color: Colors.orange,
        screenPosition: Offset(200, 300),
        segmentCenter: Offset(150, 150),
        label: 'Marketing',
        dataPoint: dataPoint,
        isExploded: true,
        isSelected: true,
      );

      expect(data.index, 2);
      expect(data.value, 250.5);
      expect(data.percentage, 33.3);
      expect(data.color, Colors.orange);
      expect(data.screenPosition, const Offset(200, 300));
      expect(data.segmentCenter, const Offset(150, 150));
      expect(data.label, 'Marketing');
      expect(data.dataPoint, dataPoint);
      expect(data.isExploded, isTrue);
      expect(data.isSelected, isTrue);
    });
  });

  // ===========================================================================
  // FORMATTED PERCENTAGE GETTER
  // ===========================================================================

  group('PieTooltipData - formattedPercentage', () {
    test('formats percentage with one decimal place', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '25.0%');
    });

    test('formats percentage with decimal values', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 33.333,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '33.3%');
    });

    test('formats zero percentage', () {
      const data = PieTooltipData(
        index: 0,
        value: 0.0,
        percentage: 0.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '0.0%');
    });

    test('formats 100 percentage', () {
      const data = PieTooltipData(
        index: 0,
        value: 1000.0,
        percentage: 100.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '100.0%');
    });

    test('rounds percentage correctly', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.456,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '25.5%');
    });

    test('rounds down when appropriate', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.444,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '25.4%');
    });

    test('formats small percentage values', () {
      const data = PieTooltipData(
        index: 0,
        value: 1.0,
        percentage: 0.123,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '0.1%');
    });
  });

  // ===========================================================================
  // FORMATTED VALUE METHOD
  // ===========================================================================

  group('PieTooltipData - formattedValue', () {
    test('formats value with default 2 decimal places', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedValue(), '100.00');
    });

    test('formats value with custom decimal places', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.12345,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedValue(0), '100');
      expect(data.formattedValue(1), '100.1');
      expect(data.formattedValue(2), '100.12');
      expect(data.formattedValue(3), '100.123');
      expect(data.formattedValue(4), '100.1235');
      expect(data.formattedValue(5), '100.12345');
    });

    test('formats zero value', () {
      const data = PieTooltipData(
        index: 0,
        value: 0.0,
        percentage: 0.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedValue(), '0.00');
      expect(data.formattedValue(0), '0');
    });

    test('formats large value', () {
      const data = PieTooltipData(
        index: 0,
        value: 1000000.0,
        percentage: 50.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedValue(), '1000000.00');
      expect(data.formattedValue(0), '1000000');
    });

    test('formats small decimal value', () {
      const data = PieTooltipData(
        index: 0,
        value: 0.00123,
        percentage: 0.1,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedValue(2), '0.00');
      expect(data.formattedValue(3), '0.001');
      expect(data.formattedValue(5), '0.00123');
    });

    test('rounds value correctly with different decimals', () {
      const data = PieTooltipData(
        index: 0,
        value: 99.999,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedValue(0), '100');
      expect(data.formattedValue(1), '100.0');
      expect(data.formattedValue(2), '100.00');
    });
  });

  // ===========================================================================
  // DISPLAY LABEL GETTER
  // ===========================================================================

  group('PieTooltipData - displayLabel', () {
    test('returns label when provided', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Sales',
      );

      expect(data.displayLabel, 'Sales');
    });

    test('returns fallback with index when label is null', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.displayLabel, 'Segment 0');
    });

    test('returns fallback for different indices', () {
      const data1 = PieTooltipData(
        index: 1,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 5,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data3 = PieTooltipData(
        index: 99,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data1.displayLabel, 'Segment 1');
      expect(data2.displayLabel, 'Segment 5');
      expect(data3.displayLabel, 'Segment 99');
    });

    test('returns empty label when provided empty string', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: '',
      );

      // Empty string is still a valid label, so it returns the empty string
      expect(data.displayLabel, '');
    });

    test('returns label with special characters', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Q1 2024 - Sales & Marketing',
      );

      expect(data.displayLabel, 'Q1 2024 - Sales & Marketing');
    });
  });

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  group('PieTooltipData - copyWith', () {
    test('creates copy with modified index', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final copy = original.copyWith(index: 5);

      expect(copy.index, 5);
      expect(copy.value, 100.0);
      expect(copy.percentage, 25.0);
      expect(copy.color, Colors.blue);
    });

    test('creates copy with modified value', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final copy = original.copyWith(value: 200.0);

      expect(copy.value, 200.0);
      expect(original.value, 100.0);
    });

    test('creates copy with modified percentage', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final copy = original.copyWith(percentage: 50.0);

      expect(copy.percentage, 50.0);
    });

    test('creates copy with modified label', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Original',
      );

      final copy = original.copyWith(label: 'Modified');

      expect(copy.label, 'Modified');
      expect(original.label, 'Original');
    });

    test('creates copy with modified color', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final copy = original.copyWith(color: Colors.red);

      expect(copy.color, Colors.red);
      expect(original.color, Colors.blue);
    });

    test('creates copy with modified screenPosition', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final copy = original.copyWith(screenPosition: const Offset(200, 200));

      expect(copy.screenPosition, const Offset(200, 200));
      expect(original.screenPosition, const Offset(100, 100));
    });

    test('creates copy with modified segmentCenter', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final copy = original.copyWith(segmentCenter: const Offset(75, 75));

      expect(copy.segmentCenter, const Offset(75, 75));
      expect(original.segmentCenter, const Offset(50, 50));
    });

    test('creates copy with modified dataPoint', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const newDataPoint = FusionPieDataPoint(200, label: 'New');
      final copy = original.copyWith(dataPoint: newDataPoint);

      expect(copy.dataPoint, newDataPoint);
      expect(original.dataPoint, isNull);
    });

    test('creates copy with modified isExploded', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        isExploded: false,
      );

      final copy = original.copyWith(isExploded: true);

      expect(copy.isExploded, isTrue);
      expect(original.isExploded, isFalse);
    });

    test('creates copy with modified isSelected', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        isSelected: false,
      );

      final copy = original.copyWith(isSelected: true);

      expect(copy.isSelected, isTrue);
      expect(original.isSelected, isFalse);
    });

    test('creates unchanged copy when no parameters', () {
      const original = PieTooltipData(
        index: 3,
        value: 150.0,
        percentage: 30.0,
        color: Colors.green,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Test',
        isExploded: true,
        isSelected: true,
      );

      final copy = original.copyWith();

      expect(copy.index, original.index);
      expect(copy.value, original.value);
      expect(copy.percentage, original.percentage);
      expect(copy.color, original.color);
      expect(copy.screenPosition, original.screenPosition);
      expect(copy.segmentCenter, original.segmentCenter);
      expect(copy.label, original.label);
      expect(copy.isExploded, original.isExploded);
      expect(copy.isSelected, original.isSelected);
    });

    test('creates copy with multiple modified properties', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final copy = original.copyWith(
        index: 5,
        value: 500.0,
        percentage: 75.0,
        color: Colors.red,
        label: 'New Label',
        isExploded: true,
        isSelected: true,
      );

      expect(copy.index, 5);
      expect(copy.value, 500.0);
      expect(copy.percentage, 75.0);
      expect(copy.color, Colors.red);
      expect(copy.label, 'New Label');
      expect(copy.isExploded, isTrue);
      expect(copy.isSelected, isTrue);
    });

    test('original remains immutable after copyWith', () {
      const original = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Original',
      );

      original.copyWith(index: 99, value: 999.0, label: 'Changed');

      expect(original.index, 0);
      expect(original.value, 100.0);
      expect(original.label, 'Original');
    });
  });

  // ===========================================================================
  // EQUALITY OPERATOR
  // ===========================================================================

  group('PieTooltipData - Equality', () {
    test('equal instances are equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Sales',
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Sales',
      );

      expect(data1, equals(data2));
    });

    test('instances with different index are not equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 1,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data1, isNot(equals(data2)));
    });

    test('instances with different value are not equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 200.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data1, isNot(equals(data2)));
    });

    test('instances with different percentage are not equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 50.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data1, isNot(equals(data2)));
    });

    test('instances with different label are not equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Sales',
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Revenue',
      );

      expect(data1, isNot(equals(data2)));
    });

    test('instances with different color are not equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.red,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data1, isNot(equals(data2)));
    });

    test('instances with different screenPosition are not equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(200, 200),
        segmentCenter: Offset(50, 50),
      );

      expect(data1, isNot(equals(data2)));
    });

    test('identical instances are equal', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data == data, isTrue);
    });

    test('instances with null vs non-null label are not equal', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: null,
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Test',
      );

      expect(data1, isNot(equals(data2)));
    });

    test('equality does not consider segmentCenter', () {
      // Note: Based on the implementation, segmentCenter is NOT included
      // in the equality check
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(75, 75), // Different segmentCenter
      );

      // They should be equal because segmentCenter is not in == operator
      expect(data1, equals(data2));
    });

    test('equality does not consider isExploded', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        isExploded: false,
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        isExploded: true,
      );

      // They should be equal because isExploded is not in == operator
      expect(data1, equals(data2));
    });

    test('equality does not consider isSelected', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        isSelected: false,
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        isSelected: true,
      );

      // They should be equal because isSelected is not in == operator
      expect(data1, equals(data2));
    });

    test('equality does not consider dataPoint', () {
      const dataPoint = FusionPieDataPoint(100, label: 'Test');
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        dataPoint: null,
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        dataPoint: dataPoint,
      );

      // They should be equal because dataPoint is not in == operator
      expect(data1, equals(data2));
    });
  });

  // ===========================================================================
  // HASH CODE
  // ===========================================================================

  group('PieTooltipData - hashCode', () {
    test('equal instances have equal hash codes', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Sales',
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Sales',
      );

      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('different instances likely have different hash codes', () {
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      const data2 = PieTooltipData(
        index: 1,
        value: 200.0,
        percentage: 50.0,
        color: Colors.red,
        screenPosition: Offset(200, 200),
        segmentCenter: Offset(100, 100),
      );

      // Hash codes might occasionally collide, but very unlikely for different data
      expect(data1.hashCode, isNot(equals(data2.hashCode)));
    });

    test('instances equal by == have same hashCode', () {
      // Testing consistency: instances equal by == must have same hashCode
      const data1 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        isExploded: true, // Not in equality
      );

      const data2 = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(75, 75), // Not in equality
        isExploded: false, // Not in equality
      );

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('hashCode is stable for same instance', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final hash1 = data.hashCode;
      final hash2 = data.hashCode;

      expect(hash1, equals(hash2));
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('PieTooltipData - toString', () {
    test('includes index in output', () {
      const data = PieTooltipData(
        index: 3,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final str = data.toString();
      expect(str, contains('index: 3'));
    });

    test('includes label in output', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Sales',
      );

      final str = data.toString();
      expect(str, contains('label: Sales'));
    });

    test('includes percentage in output', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final str = data.toString();
      expect(str, contains('percentage: 25.0%'));
    });

    test('formats percentage with one decimal in toString', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 33.333,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final str = data.toString();
      expect(str, contains('33.3%'));
    });

    test('includes null label in output', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final str = data.toString();
      expect(str, contains('label: null'));
    });

    test('starts with class name', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final str = data.toString();
      expect(str, startsWith('PieTooltipData('));
    });

    test('ends with closing parenthesis', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      final str = data.toString();
      expect(str, endsWith(')'));
    });
  });

  // ===========================================================================
  // BASE CLASS BEHAVIOR
  // ===========================================================================

  group('PieTooltipData - Base Class Behavior', () {
    test('screenPosition getter returns correct value', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(150, 200),
        segmentCenter: Offset(50, 50),
      );

      expect(data.screenPosition, const Offset(150, 200));
    });

    test('screenPosition is accessible from base class interface', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      // Access through the inherited getter
      final offset = data.screenPosition;
      expect(offset, isA<Offset>());
      expect(offset.dx, 100.0);
      expect(offset.dy, 100.0);
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================

  group('PieTooltipData - Edge Cases', () {
    test('handles very small percentage values', () {
      const data = PieTooltipData(
        index: 0,
        value: 0.001,
        percentage: 0.001,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedPercentage, '0.0%');
      expect(data.formattedValue(6), '0.001000');
    });

    test('handles very large values', () {
      const data = PieTooltipData(
        index: 0,
        value: 9999999999.99,
        percentage: 99.99,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data.formattedValue(), '9999999999.99');
      expect(data.formattedPercentage, '100.0%');
    });

    test('handles unicode in label', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        label: 'Vendas em Sao Paulo',
      );

      expect(data.label, 'Vendas em Sao Paulo');
      expect(data.displayLabel, 'Vendas em Sao Paulo');
    });

    test('handles very long label', () {
      final longLabel = 'A' * 1000;
      final data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: const Offset(100, 100),
        segmentCenter: const Offset(50, 50),
        label: longLabel,
      );

      expect(data.label, longLabel);
      expect(data.displayLabel.length, 1000);
    });

    test('handles const constructor', () {
      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
      );

      expect(data, isNotNull);
    });

    test('dataPoint can have complex configuration', () {
      const dataPoint = FusionPieDataPoint(
        100,
        label: 'Complex',
        color: Colors.green,
        borderColor: Colors.white,
        borderWidth: 2.0,
        explode: true,
        explodeOffset: 20.0,
      );

      const data = PieTooltipData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        color: Colors.blue,
        screenPosition: Offset(100, 100),
        segmentCenter: Offset(50, 50),
        dataPoint: dataPoint,
      );

      expect(data.dataPoint?.explode, isTrue);
      expect(data.dataPoint?.explodeOffset, 20.0);
      expect(data.dataPoint?.borderWidth, 2.0);
    });
  });
}

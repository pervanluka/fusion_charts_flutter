import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/axis/datetime/fusion_datetime_axis.dart';
import 'package:fusion_charts_flutter/src/core/enums/label_alignment.dart';
import 'package:intl/intl.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION - DEFAULT VALUES
  // ===========================================================================
  group('FusionDateTimeAxis - Construction with default values', () {
    test('creates with default values', () {
      const axis = FusionDateTimeAxis();

      expect(axis.name, isNull);
      expect(axis.title, isNull);
      expect(axis.titleStyle, isNull);
      expect(axis.opposedPosition, isFalse);
      expect(axis.isInversed, isFalse);
      expect(axis.min, isNull);
      expect(axis.max, isNull);
      expect(axis.interval, isNull);
      expect(axis.desiredIntervals, 5);
      expect(axis.dateFormat, isNull);
      expect(axis.labelAlignment, LabelAlignment.center);
    });

    test('creates with only min specified', () {
      final axis = FusionDateTimeAxis(min: DateTime(2024, 1, 1));

      expect(axis.min, DateTime(2024, 1, 1));
      expect(axis.max, isNull);
    });

    test('creates with only max specified', () {
      final axis = FusionDateTimeAxis(max: DateTime(2024, 12, 31));

      expect(axis.min, isNull);
      expect(axis.max, DateTime(2024, 12, 31));
    });
  });

  // ===========================================================================
  // CONSTRUCTION - CUSTOM VALUES
  // ===========================================================================
  group('FusionDateTimeAxis - Construction with custom values', () {
    test('creates with min and max dates', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );

      expect(axis.min, DateTime(2024, 1, 1));
      expect(axis.max, DateTime(2024, 12, 31));
    });

    test('creates with custom interval', () {
      final axis = FusionDateTimeAxis(interval: const Duration(days: 7));

      expect(axis.interval, const Duration(days: 7));
      expect(axis.interval?.inDays, 7);
    });

    test('creates with custom desiredIntervals', () {
      const axis = FusionDateTimeAxis(desiredIntervals: 10);

      expect(axis.desiredIntervals, 10);
    });

    test('creates with custom dateFormat', () {
      final axis = FusionDateTimeAxis(dateFormat: DateFormat('MMM yyyy'));

      expect(axis.dateFormat, isNotNull);
      expect(axis.dateFormat!.format(DateTime(2024, 6, 15)), 'Jun 2024');
    });

    test('creates with custom labelAlignment', () {
      const axis = FusionDateTimeAxis(labelAlignment: LabelAlignment.start);

      expect(axis.labelAlignment, LabelAlignment.start);
    });

    test('creates with all parameters', () {
      final axis = FusionDateTimeAxis(
        name: 'timeAxis',
        title: 'Date',
        titleStyle: const TextStyle(fontSize: 14, color: Colors.blue),
        opposedPosition: true,
        isInversed: true,
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(days: 30),
        desiredIntervals: 12,
        dateFormat: DateFormat('dd/MM/yyyy'),
        labelAlignment: LabelAlignment.end,
      );

      expect(axis.name, 'timeAxis');
      expect(axis.title, 'Date');
      expect(axis.titleStyle?.fontSize, 14);
      expect(axis.titleStyle?.color, Colors.blue);
      expect(axis.opposedPosition, isTrue);
      expect(axis.isInversed, isTrue);
      expect(axis.min, DateTime(2024, 1, 1));
      expect(axis.max, DateTime(2024, 12, 31));
      expect(axis.interval, const Duration(days: 30));
      expect(axis.desiredIntervals, 12);
      expect(axis.dateFormat, isNotNull);
      expect(axis.labelAlignment, LabelAlignment.end);
    });

    test('creates with various date format patterns', () {
      final hourFormat = FusionDateTimeAxis(dateFormat: DateFormat('HH:mm'));
      final dayFormat = FusionDateTimeAxis(dateFormat: DateFormat('MMM dd'));
      final monthFormat = FusionDateTimeAxis(
        dateFormat: DateFormat('MMM yyyy'),
      );
      final yearFormat = FusionDateTimeAxis(dateFormat: DateFormat('yyyy'));

      final testDate = DateTime(2024, 6, 15, 14, 30);

      expect(hourFormat.dateFormat!.format(testDate), '14:30');
      expect(dayFormat.dateFormat!.format(testDate), 'Jun 15');
      expect(monthFormat.dateFormat!.format(testDate), 'Jun 2024');
      expect(yearFormat.dateFormat!.format(testDate), '2024');
    });

    test('creates with various interval durations', () {
      final hourAxis = FusionDateTimeAxis(interval: const Duration(hours: 1));
      final dayAxis = FusionDateTimeAxis(interval: const Duration(days: 1));
      final weekAxis = FusionDateTimeAxis(interval: const Duration(days: 7));

      expect(hourAxis.interval?.inHours, 1);
      expect(dayAxis.interval?.inDays, 1);
      expect(weekAxis.interval?.inDays, 7);
    });
  });

  // ===========================================================================
  // DATETOVALUE METHOD
  // ===========================================================================
  group('FusionDateTimeAxis - dateToValue', () {
    test('converts DateTime to milliseconds since epoch', () {
      const axis = FusionDateTimeAxis();
      final date = DateTime(2024, 1, 1, 0, 0, 0);

      final value = axis.dateToValue(date);

      expect(value, date.millisecondsSinceEpoch.toDouble());
    });

    test('converts epoch DateTime correctly', () {
      const axis = FusionDateTimeAxis();
      final epochDate = DateTime.fromMillisecondsSinceEpoch(0);

      final value = axis.dateToValue(epochDate);

      expect(value, 0.0);
    });

    test('converts future date correctly', () {
      const axis = FusionDateTimeAxis();
      final futureDate = DateTime(2050, 12, 31, 23, 59, 59);

      final value = axis.dateToValue(futureDate);

      expect(value, futureDate.millisecondsSinceEpoch.toDouble());
    });

    test('converts date with time components correctly', () {
      const axis = FusionDateTimeAxis();
      final dateWithTime = DateTime(2024, 6, 15, 14, 30, 45, 123);

      final value = axis.dateToValue(dateWithTime);

      expect(value, dateWithTime.millisecondsSinceEpoch.toDouble());
    });

    test('returns double type', () {
      const axis = FusionDateTimeAxis();
      final date = DateTime(2024, 1, 1);

      final value = axis.dateToValue(date);

      expect(value, isA<double>());
    });

    test('maintains precision for dates far apart', () {
      const axis = FusionDateTimeAxis();
      final date1 = DateTime(1970, 1, 1);
      final date2 = DateTime(2024, 12, 31);

      final value1 = axis.dateToValue(date1);
      final value2 = axis.dateToValue(date2);

      expect(value2, greaterThan(value1));
      expect(value2 - value1, greaterThan(0));
    });

    test('handles dates close together', () {
      const axis = FusionDateTimeAxis();
      final date1 = DateTime(2024, 1, 1, 12, 0, 0, 0);
      final date2 = DateTime(2024, 1, 1, 12, 0, 0, 1);

      final value1 = axis.dateToValue(date1);
      final value2 = axis.dateToValue(date2);

      expect(value2 - value1, 1.0);
    });
  });

  // ===========================================================================
  // VALUETODATE METHOD
  // ===========================================================================
  group('FusionDateTimeAxis - valueToDate', () {
    test('converts milliseconds to DateTime', () {
      const axis = FusionDateTimeAxis();
      final originalDate = DateTime(2024, 1, 1);
      final milliseconds = originalDate.millisecondsSinceEpoch.toDouble();

      final convertedDate = axis.valueToDate(milliseconds);

      expect(convertedDate, originalDate);
    });

    test('converts zero to epoch DateTime', () {
      const axis = FusionDateTimeAxis();

      final date = axis.valueToDate(0);

      expect(date.millisecondsSinceEpoch, 0);
    });

    test('converts large values correctly', () {
      const axis = FusionDateTimeAxis();
      final futureDate = DateTime(2050, 12, 31);
      final milliseconds = futureDate.millisecondsSinceEpoch.toDouble();

      final convertedDate = axis.valueToDate(milliseconds);

      expect(convertedDate.year, 2050);
      expect(convertedDate.month, 12);
      expect(convertedDate.day, 31);
    });

    test('handles fractional milliseconds by truncating', () {
      const axis = FusionDateTimeAxis();
      final baseDate = DateTime(2024, 1, 1);
      final baseMillis = baseDate.millisecondsSinceEpoch.toDouble();

      final date1 = axis.valueToDate(baseMillis + 0.1);
      final date2 = axis.valueToDate(baseMillis + 0.9);

      expect(date1, baseDate);
      expect(date2, baseDate);
    });

    test('returns DateTime type', () {
      const axis = FusionDateTimeAxis();

      final date = axis.valueToDate(1000000000000);

      expect(date, isA<DateTime>());
    });

    test('roundtrip conversion preserves date', () {
      const axis = FusionDateTimeAxis();
      final originalDate = DateTime(2024, 6, 15, 10, 30, 45);

      final value = axis.dateToValue(originalDate);
      final convertedDate = axis.valueToDate(value);

      expect(convertedDate, originalDate);
    });

    test('roundtrip conversion for multiple dates', () {
      const axis = FusionDateTimeAxis();
      final dates = [
        DateTime(1990, 1, 1),
        DateTime(2000, 6, 15),
        DateTime(2024, 3, 20, 8, 45, 30),
        DateTime(2030, 12, 31, 23, 59, 59),
      ];

      for (final originalDate in dates) {
        final value = axis.dateToValue(originalDate);
        final convertedDate = axis.valueToDate(value);
        expect(convertedDate, originalDate);
      }
    });
  });

  // ===========================================================================
  // COPYWITH METHOD
  // ===========================================================================
  group('FusionDateTimeAxis - copyWith', () {
    test('copyWith creates copy with modified min', () {
      final original = FusionDateTimeAxis(min: DateTime(2024, 1, 1));

      final copy = original.copyWith(min: DateTime(2024, 6, 1));

      expect(copy.min, DateTime(2024, 6, 1));
    });

    test('copyWith creates copy with modified max', () {
      final original = FusionDateTimeAxis(max: DateTime(2024, 12, 31));

      final copy = original.copyWith(max: DateTime(2025, 12, 31));

      expect(copy.max, DateTime(2025, 12, 31));
    });

    test('copyWith creates copy with modified interval', () {
      final original = FusionDateTimeAxis(interval: const Duration(days: 7));

      final copy = original.copyWith(interval: const Duration(days: 30));

      expect(copy.interval, const Duration(days: 30));
    });

    test('copyWith creates copy with modified desiredIntervals', () {
      const original = FusionDateTimeAxis(desiredIntervals: 5);

      final copy = original.copyWith(desiredIntervals: 10);

      expect(copy.desiredIntervals, 10);
    });

    test('copyWith creates copy with modified dateFormat', () {
      final original = FusionDateTimeAxis(dateFormat: DateFormat('yyyy-MM-dd'));

      final copy = original.copyWith(dateFormat: DateFormat('dd/MM/yyyy'));

      expect(copy.dateFormat!.format(DateTime(2024, 6, 15)), '15/06/2024');
    });

    test('copyWith creates copy with modified labelAlignment', () {
      const original = FusionDateTimeAxis(
        labelAlignment: LabelAlignment.center,
      );

      final copy = original.copyWith(labelAlignment: LabelAlignment.end);

      expect(copy.labelAlignment, LabelAlignment.end);
    });

    test('copyWith preserves unchanged values', () {
      final original = FusionDateTimeAxis(
        name: 'dateAxis',
        title: 'Date',
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(days: 30),
        desiredIntervals: 12,
        labelAlignment: LabelAlignment.start,
      );

      final copy = original.copyWith(min: DateTime(2024, 6, 1));

      expect(copy.name, 'dateAxis');
      expect(copy.title, 'Date');
      expect(copy.min, DateTime(2024, 6, 1));
      expect(copy.max, DateTime(2024, 12, 31));
      expect(copy.interval, const Duration(days: 30));
      expect(copy.desiredIntervals, 12);
      expect(copy.labelAlignment, LabelAlignment.start);
    });

    test('copyWith handles all parameters', () {
      const original = FusionDateTimeAxis();

      final copy = original.copyWith(
        name: 'newAxis',
        title: 'New Title',
        titleStyle: const TextStyle(fontSize: 16),
        opposedPosition: true,
        isInversed: true,
        min: DateTime(2020, 1, 1),
        max: DateTime(2030, 12, 31),
        interval: const Duration(days: 365),
        desiredIntervals: 11,
        dateFormat: DateFormat('yyyy'),
        labelAlignment: LabelAlignment.end,
      );

      expect(copy.name, 'newAxis');
      expect(copy.title, 'New Title');
      expect(copy.titleStyle?.fontSize, 16);
      expect(copy.opposedPosition, isTrue);
      expect(copy.isInversed, isTrue);
      expect(copy.min, DateTime(2020, 1, 1));
      expect(copy.max, DateTime(2030, 12, 31));
      expect(copy.interval, const Duration(days: 365));
      expect(copy.desiredIntervals, 11);
      expect(copy.dateFormat, isNotNull);
      expect(copy.labelAlignment, LabelAlignment.end);
    });

    test('copyWith returns new instance', () {
      final original = FusionDateTimeAxis(min: DateTime(2024, 1, 1));

      final copy = original.copyWith(min: DateTime(2024, 6, 1));

      expect(identical(original, copy), isFalse);
    });

    test('copyWith with no arguments returns equivalent copy', () {
      final original = FusionDateTimeAxis(
        name: 'axis',
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );

      final copy = original.copyWith();

      expect(copy, equals(original));
      expect(identical(original, copy), isFalse);
    });
  });

  // ===========================================================================
  // EQUALITY OPERATOR
  // ===========================================================================
  group('FusionDateTimeAxis - Equality', () {
    test('equal axes are equal', () {
      final axis1 = FusionDateTimeAxis(
        name: 'dateAxis',
        title: 'Date',
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(days: 30),
        desiredIntervals: 12,
        labelAlignment: LabelAlignment.center,
      );
      final axis2 = FusionDateTimeAxis(
        name: 'dateAxis',
        title: 'Date',
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(days: 30),
        desiredIntervals: 12,
        labelAlignment: LabelAlignment.center,
      );

      expect(axis1, equals(axis2));
    });

    test('axes with different names are not equal', () {
      final axis1 = FusionDateTimeAxis(
        name: 'axis1',
        min: DateTime(2024, 1, 1),
      );
      final axis2 = FusionDateTimeAxis(
        name: 'axis2',
        min: DateTime(2024, 1, 1),
      );

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different titles are not equal', () {
      final axis1 = FusionDateTimeAxis(
        title: 'Title 1',
        min: DateTime(2024, 1, 1),
      );
      final axis2 = FusionDateTimeAxis(
        title: 'Title 2',
        min: DateTime(2024, 1, 1),
      );

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different min are not equal', () {
      final axis1 = FusionDateTimeAxis(min: DateTime(2024, 1, 1));
      final axis2 = FusionDateTimeAxis(min: DateTime(2024, 6, 1));

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different max are not equal', () {
      final axis1 = FusionDateTimeAxis(max: DateTime(2024, 12, 31));
      final axis2 = FusionDateTimeAxis(max: DateTime(2025, 12, 31));

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different intervals are not equal', () {
      final axis1 = FusionDateTimeAxis(interval: const Duration(days: 7));
      final axis2 = FusionDateTimeAxis(interval: const Duration(days: 30));

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different desiredIntervals are not equal', () {
      const axis1 = FusionDateTimeAxis(desiredIntervals: 5);
      const axis2 = FusionDateTimeAxis(desiredIntervals: 10);

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different labelAlignment are not equal', () {
      const axis1 = FusionDateTimeAxis(labelAlignment: LabelAlignment.start);
      const axis2 = FusionDateTimeAxis(labelAlignment: LabelAlignment.end);

      expect(axis1, isNot(equals(axis2)));
    });

    test('identical axes are equal', () {
      final axis = FusionDateTimeAxis(min: DateTime(2024, 1, 1));
      expect(axis == axis, isTrue);
    });

    test('axis is not equal to different type', () {
      final axis = FusionDateTimeAxis(min: DateTime(2024, 1, 1));
      // ignore: unrelated_type_equality_checks
      expect(axis == 'not an axis', isFalse);
    });

    test(
      'axes with same values but different dateFormat are equal (not in equality)',
      () {
        // Note: dateFormat is not included in equality check based on the implementation
        final axis1 = FusionDateTimeAxis(
          min: DateTime(2024, 1, 1),
          dateFormat: DateFormat('yyyy-MM-dd'),
        );
        final axis2 = FusionDateTimeAxis(
          min: DateTime(2024, 1, 1),
          dateFormat: DateFormat('dd/MM/yyyy'),
        );

        // Based on the equality implementation, dateFormat is NOT part of equality
        expect(axis1, equals(axis2));
      },
    );
  });

  // ===========================================================================
  // HASHCODE
  // ===========================================================================
  group('FusionDateTimeAxis - hashCode', () {
    test('hashCode is consistent for equal axes', () {
      final axis1 = FusionDateTimeAxis(
        name: 'dateAxis',
        title: 'Date',
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(days: 30),
        desiredIntervals: 12,
        labelAlignment: LabelAlignment.center,
      );
      final axis2 = FusionDateTimeAxis(
        name: 'dateAxis',
        title: 'Date',
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
        interval: const Duration(days: 30),
        desiredIntervals: 12,
        labelAlignment: LabelAlignment.center,
      );

      expect(axis1.hashCode, equals(axis2.hashCode));
    });

    test('hashCode differs for different axes', () {
      final axis1 = FusionDateTimeAxis(min: DateTime(2024, 1, 1));
      final axis2 = FusionDateTimeAxis(min: DateTime(2024, 6, 1));

      expect(axis1.hashCode, isNot(equals(axis2.hashCode)));
    });

    test('hashCode is stable across multiple calls', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );

      final hash1 = axis.hashCode;
      final hash2 = axis.hashCode;
      final hash3 = axis.hashCode;

      expect(hash1, equals(hash2));
      expect(hash2, equals(hash3));
    });

    test('hashCode for default axis is consistent', () {
      const axis1 = FusionDateTimeAxis();
      const axis2 = FusionDateTimeAxis();

      expect(axis1.hashCode, equals(axis2.hashCode));
    });
  });

  // ===========================================================================
  // TOSTRING METHOD
  // ===========================================================================
  group('FusionDateTimeAxis - toString', () {
    test('toString returns descriptive string with min and max', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );

      final str = axis.toString();

      expect(str, contains('FusionDateTimeAxis'));
      expect(str, contains('min:'));
      expect(str, contains('max:'));
    });

    test('toString shows null for unset min', () {
      final axis = FusionDateTimeAxis(max: DateTime(2024, 12, 31));

      final str = axis.toString();

      expect(str, contains('min: null'));
    });

    test('toString shows null for unset max', () {
      final axis = FusionDateTimeAxis(min: DateTime(2024, 1, 1));

      final str = axis.toString();

      expect(str, contains('max: null'));
    });

    test('toString for default axis shows both null', () {
      const axis = FusionDateTimeAxis();

      final str = axis.toString();

      expect(str, contains('FusionDateTimeAxis'));
      expect(str, contains('min: null'));
      expect(str, contains('max: null'));
    });

    test('toString includes date values', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 1, 1),
        max: DateTime(2024, 12, 31),
      );

      final str = axis.toString();

      expect(str, contains('2024'));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionDateTimeAxis - Edge Cases', () {
    test('handles same min and max', () {
      final date = DateTime(2024, 6, 15);
      final axis = FusionDateTimeAxis(min: date, max: date);

      expect(axis.min, axis.max);
    });

    test('handles min greater than max', () {
      final axis = FusionDateTimeAxis(
        min: DateTime(2024, 12, 31),
        max: DateTime(2024, 1, 1),
      );

      expect(axis.min!.isAfter(axis.max!), isTrue);
    });

    test('handles very small intervals', () {
      final axis = FusionDateTimeAxis(
        interval: const Duration(milliseconds: 1),
      );

      expect(axis.interval?.inMilliseconds, 1);
    });

    test('handles very large intervals', () {
      final axis = FusionDateTimeAxis(interval: const Duration(days: 365 * 10));

      expect(axis.interval?.inDays, 3650);
    });

    test('handles zero desiredIntervals', () {
      const axis = FusionDateTimeAxis(desiredIntervals: 0);

      expect(axis.desiredIntervals, 0);
    });

    test('handles negative desiredIntervals', () {
      const axis = FusionDateTimeAxis(desiredIntervals: -5);

      expect(axis.desiredIntervals, -5);
    });

    test('dateToValue handles dates before epoch', () {
      const axis = FusionDateTimeAxis();
      final dateBeforeEpoch = DateTime(1960, 1, 1);

      final value = axis.dateToValue(dateBeforeEpoch);

      expect(value, lessThan(0));
    });

    test('valueToDate handles negative values', () {
      const axis = FusionDateTimeAxis();
      const negativeValue = -1000000000000.0;

      final date = axis.valueToDate(negativeValue);

      expect(date.year, lessThan(1970));
    });
  });

  // ===========================================================================
  // LABEL ALIGNMENT ENUM
  // ===========================================================================
  group('LabelAlignment - Enum with FusionDateTimeAxis', () {
    test('supports all label alignment values', () {
      const axisStart = FusionDateTimeAxis(
        labelAlignment: LabelAlignment.start,
      );
      const axisCenter = FusionDateTimeAxis(
        labelAlignment: LabelAlignment.center,
      );
      const axisEnd = FusionDateTimeAxis(labelAlignment: LabelAlignment.end);

      expect(axisStart.labelAlignment, LabelAlignment.start);
      expect(axisCenter.labelAlignment, LabelAlignment.center);
      expect(axisEnd.labelAlignment, LabelAlignment.end);
    });
  });
}

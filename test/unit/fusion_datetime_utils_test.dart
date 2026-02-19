import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/utils/fusion_datetime_utils.dart';

void main() {
  // ===========================================================================
  // CALCULATE INTERVAL
  // ===========================================================================
  group('FusionDateTimeUtils - calculateInterval', () {
    test('returns seconds interval for short ranges', () {
      final start = DateTime(2024, 1, 1, 0, 0, 0);
      final end = DateTime(2024, 1, 1, 0, 0, 30);

      final interval = FusionDateTimeUtils.calculateInterval(start, end);

      expect(interval.inSeconds, lessThanOrEqualTo(30));
      expect(interval.inSeconds, greaterThan(0));
    });

    test('returns minutes interval for minute ranges', () {
      final start = DateTime(2024, 1, 1, 0, 0);
      final end = DateTime(2024, 1, 1, 0, 30);

      final interval = FusionDateTimeUtils.calculateInterval(start, end);

      expect(interval.inMinutes, greaterThan(0));
      expect(interval.inHours, lessThanOrEqualTo(1));
    });

    test('returns hours interval for hour ranges', () {
      final start = DateTime(2024, 1, 1, 0);
      final end = DateTime(2024, 1, 1, 12);

      final interval = FusionDateTimeUtils.calculateInterval(start, end);

      expect(interval.inHours, greaterThan(0));
    });

    test('returns days interval for day ranges', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 15);

      final interval = FusionDateTimeUtils.calculateInterval(start, end);

      expect(interval.inDays, greaterThan(0));
    });

    test('returns month-like interval for month ranges', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 6, 1);

      final interval = FusionDateTimeUtils.calculateInterval(start, end);

      expect(interval.inDays, greaterThanOrEqualTo(30));
    });

    test('uses desiredIntervals parameter', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 31);

      final interval3 = FusionDateTimeUtils.calculateInterval(
        start,
        end,
        desiredIntervals: 3,
      );
      final interval12 = FusionDateTimeUtils.calculateInterval(
        start,
        end,
        desiredIntervals: 12,
      );

      // More intervals = smaller interval
      expect(interval3.inDays, greaterThan(interval12.inDays));
    });
  });

  // ===========================================================================
  // GENERATE DATE RANGE
  // ===========================================================================
  group('FusionDateTimeUtils - generateDateRange', () {
    test('generates dates at interval', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 7);
      const interval = Duration(days: 1);

      final dates = FusionDateTimeUtils.generateDateRange(start, end, interval);

      expect(dates.length, 7);
      expect(dates.first, start);
      expect(dates[1], DateTime(2024, 1, 2));
    });

    test('includes end date if on interval', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 4);
      const interval = Duration(days: 1);

      final dates = FusionDateTimeUtils.generateDateRange(start, end, interval);

      expect(dates.last, end);
    });

    test('generates single date when start equals end', () {
      final date = DateTime(2024, 1, 1);
      const interval = Duration(days: 1);

      final dates = FusionDateTimeUtils.generateDateRange(date, date, interval);

      expect(dates.length, 1);
      expect(dates.first, date);
    });

    test('works with hour intervals', () {
      final start = DateTime(2024, 1, 1, 0);
      final end = DateTime(2024, 1, 1, 6);
      const interval = Duration(hours: 2);

      final dates = FusionDateTimeUtils.generateDateRange(start, end, interval);

      expect(dates.length, 4);
      expect(dates[1], DateTime(2024, 1, 1, 2));
    });
  });

  // ===========================================================================
  // SUGGEST FORMAT
  // ===========================================================================
  group('FusionDateTimeUtils - suggestFormat', () {
    test('suggests seconds format for ranges under 60 seconds', () {
      final start = DateTime(2024, 1, 1, 0, 0, 0);
      final end = DateTime(2024, 1, 1, 0, 0, 30);

      final format = FusionDateTimeUtils.suggestFormat(start, end);

      expect(format, 'HH:mm:ss');
    });

    test('suggests minutes format for ranges under 60 minutes', () {
      final start = DateTime(2024, 1, 1, 0, 0);
      final end = DateTime(2024, 1, 1, 0, 30);

      final format = FusionDateTimeUtils.suggestFormat(start, end);

      expect(format, 'HH:mm');
    });

    test('suggests hours format for ranges under 24 hours', () {
      final start = DateTime(2024, 1, 1, 0);
      final end = DateTime(2024, 1, 1, 12);

      final format = FusionDateTimeUtils.suggestFormat(start, end);

      expect(format, 'HH:mm');
    });

    test('suggests day format for ranges under 7 days', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 5);

      final format = FusionDateTimeUtils.suggestFormat(start, end);

      expect(format, 'E, MMM d');
    });

    test('suggests month-day format for ranges under 31 days', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 20);

      final format = FusionDateTimeUtils.suggestFormat(start, end);

      expect(format, 'MMM d');
    });

    test('suggests month-year format for ranges under a year', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 6, 1);

      final format = FusionDateTimeUtils.suggestFormat(start, end);

      expect(format, 'MMM yyyy');
    });

    test('suggests year format for multi-year ranges', () {
      final start = DateTime(2020, 1, 1);
      final end = DateTime(2024, 1, 1);

      final format = FusionDateTimeUtils.suggestFormat(start, end);

      expect(format, 'yyyy');
    });
  });

  // ===========================================================================
  // ROUND TO INTERVAL
  // ===========================================================================
  group('FusionDateTimeUtils - roundToInterval', () {
    test('rounds to nearest hour', () {
      final dateTime = DateTime(2024, 1, 1, 10, 30);
      const interval = Duration(hours: 1);

      final rounded = FusionDateTimeUtils.roundToInterval(dateTime, interval);

      expect(rounded, DateTime(2024, 1, 1, 11, 0)); // Rounds up
    });

    test('rounds to nearest day', () {
      final dateTime = DateTime(2024, 1, 1, 13);
      const interval = Duration(days: 1);

      final rounded = FusionDateTimeUtils.roundToInterval(dateTime, interval);

      expect(rounded.day, 2); // Rounds to next day
    });

    test('rounds to nearest minute', () {
      final dateTime = DateTime(2024, 1, 1, 10, 15, 40);
      const interval = Duration(minutes: 15);

      final rounded = FusionDateTimeUtils.roundToInterval(dateTime, interval);

      expect(rounded.minute, 15);
      expect(rounded.second, 0);
    });

    test('keeps exact value if already on interval', () {
      final dateTime = DateTime(2024, 1, 1, 10, 0, 0);
      const interval = Duration(hours: 1);

      final rounded = FusionDateTimeUtils.roundToInterval(dateTime, interval);

      expect(rounded, dateTime);
    });
  });

  // ===========================================================================
  // DATE COMPARISON METHODS
  // ===========================================================================
  group('FusionDateTimeUtils - isSameDay', () {
    test('returns true for same day', () {
      final a = DateTime(2024, 1, 15, 10, 30);
      final b = DateTime(2024, 1, 15, 22, 45);

      expect(FusionDateTimeUtils.isSameDay(a, b), isTrue);
    });

    test('returns false for different days', () {
      final a = DateTime(2024, 1, 15);
      final b = DateTime(2024, 1, 16);

      expect(FusionDateTimeUtils.isSameDay(a, b), isFalse);
    });

    test('returns false for same day different month', () {
      final a = DateTime(2024, 1, 15);
      final b = DateTime(2024, 2, 15);

      expect(FusionDateTimeUtils.isSameDay(a, b), isFalse);
    });
  });

  group('FusionDateTimeUtils - isSameMonth', () {
    test('returns true for same month', () {
      final a = DateTime(2024, 3, 1);
      final b = DateTime(2024, 3, 31);

      expect(FusionDateTimeUtils.isSameMonth(a, b), isTrue);
    });

    test('returns false for different months', () {
      final a = DateTime(2024, 3, 15);
      final b = DateTime(2024, 4, 15);

      expect(FusionDateTimeUtils.isSameMonth(a, b), isFalse);
    });

    test('returns false for same month different year', () {
      final a = DateTime(2024, 3, 15);
      final b = DateTime(2023, 3, 15);

      expect(FusionDateTimeUtils.isSameMonth(a, b), isFalse);
    });
  });

  group('FusionDateTimeUtils - isSameYear', () {
    test('returns true for same year', () {
      final a = DateTime(2024, 1, 1);
      final b = DateTime(2024, 12, 31);

      expect(FusionDateTimeUtils.isSameYear(a, b), isTrue);
    });

    test('returns false for different years', () {
      final a = DateTime(2024, 6, 15);
      final b = DateTime(2023, 6, 15);

      expect(FusionDateTimeUtils.isSameYear(a, b), isFalse);
    });
  });
}

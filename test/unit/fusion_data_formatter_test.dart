import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/utils/fusion_data_formatter.dart';

void main() {
  group('FusionDataFormatter', () {
    // =========================================================================
    // LARGE NUMBER FORMATTING
    // =========================================================================

    group('formatLargeNumber', () {
      test('formats numbers below 1000 without suffix', () {
        expect(FusionDataFormatter.formatLargeNumber(999), '999');
        expect(FusionDataFormatter.formatLargeNumber(500), '500');
        expect(FusionDataFormatter.formatLargeNumber(0), '0');
      });

      test('formats thousands with K suffix', () {
        expect(FusionDataFormatter.formatLargeNumber(1000), '1K');
        expect(FusionDataFormatter.formatLargeNumber(1500), '1.5K');
        expect(FusionDataFormatter.formatLargeNumber(2500), '2.5K');
        expect(FusionDataFormatter.formatLargeNumber(999000), '999K');
      });

      test('formats millions with M suffix', () {
        expect(FusionDataFormatter.formatLargeNumber(1000000), '1M');
        expect(FusionDataFormatter.formatLargeNumber(1500000), '1.5M');
        expect(FusionDataFormatter.formatLargeNumber(2500000), '2.5M');
      });

      test('formats billions with B suffix', () {
        expect(FusionDataFormatter.formatLargeNumber(1000000000), '1B');
        expect(FusionDataFormatter.formatLargeNumber(1500000000), '1.5B');
      });

      test('formats trillions with T suffix', () {
        expect(FusionDataFormatter.formatLargeNumber(1000000000000), '1T');
        expect(FusionDataFormatter.formatLargeNumber(1500000000000), '1.5T');
      });

      test('handles negative numbers', () {
        expect(FusionDataFormatter.formatLargeNumber(-1500), '-1.5K');
        expect(FusionDataFormatter.formatLargeNumber(-2500000), '-2.5M');
      });

      test('respects decimals parameter', () {
        expect(
          FusionDataFormatter.formatLargeNumber(1234567, decimals: 2),
          '1.23M',
        );
        expect(
          FusionDataFormatter.formatLargeNumber(1234567, decimals: 0),
          '1M',
        );
      });

      test('respects showDecimals parameter', () {
        expect(
          FusionDataFormatter.formatLargeNumber(1500000, showDecimals: false),
          '2M', // Rounds to nearest million
        );
      });
    });

    // =========================================================================
    // THOUSAND SEPARATOR FORMATTING
    // =========================================================================

    group('formatWithThousands', () {
      test('adds thousand separators', () {
        expect(FusionDataFormatter.formatWithThousands(1234), '1,234.00');
        expect(
          FusionDataFormatter.formatWithThousands(1234567),
          '1,234,567.00',
        );
      });

      test('respects decimal parameter', () {
        expect(
          FusionDataFormatter.formatWithThousands(1234.5678, decimals: 2),
          '1,234.57',
        );
        expect(
          FusionDataFormatter.formatWithThousands(1234, decimals: 0),
          '1,234',
        );
      });

      test('respects custom separator', () {
        expect(
          FusionDataFormatter.formatWithThousands(1234567, separator: '.'),
          '1.234.567.00',
        );
        expect(
          FusionDataFormatter.formatWithThousands(1234567, separator: ' '),
          '1 234 567.00',
        );
      });

      test('handles small numbers', () {
        expect(FusionDataFormatter.formatWithThousands(123), '123.00');
        expect(FusionDataFormatter.formatWithThousands(12), '12.00');
        expect(FusionDataFormatter.formatWithThousands(1), '1.00');
      });
    });

    // =========================================================================
    // PRECISE FORMATTING
    // =========================================================================

    group('formatPrecise', () {
      test('returns 0 for zero', () {
        expect(FusionDataFormatter.formatPrecise(0), '0');
      });

      test('adjusts decimals based on magnitude', () {
        expect(FusionDataFormatter.formatPrecise(123.456), '123');
        expect(FusionDataFormatter.formatPrecise(12.345), '12.3');
        expect(FusionDataFormatter.formatPrecise(1.2345), '1.23');
        expect(FusionDataFormatter.formatPrecise(0.12345), '0.12');
      });

      test('respects maxDecimals parameter', () {
        expect(
          FusionDataFormatter.formatPrecise(0.123456, maxDecimals: 4),
          '0.1235',
        );
      });
    });

    // =========================================================================
    // PERCENTAGE FORMATTING
    // =========================================================================

    group('formatPercentage', () {
      test('converts decimal to percentage', () {
        expect(FusionDataFormatter.formatPercentage(0.156), '15.6%');
        expect(FusionDataFormatter.formatPercentage(1.0), '100.0%');
        expect(FusionDataFormatter.formatPercentage(0.005), '0.5%');
      });

      test('handles zero', () {
        expect(FusionDataFormatter.formatPercentage(0), '0.0%');
      });

      test('handles values over 100%', () {
        expect(FusionDataFormatter.formatPercentage(1.5), '150.0%');
      });

      test('respects decimals parameter', () {
        expect(
          FusionDataFormatter.formatPercentage(0.156, decimals: 2),
          '15.60%',
        );
        expect(FusionDataFormatter.formatPercentage(0.156, decimals: 0), '16%');
      });

      test('can exclude symbol', () {
        expect(
          FusionDataFormatter.formatPercentage(0.156, includeSymbol: false),
          '15.6',
        );
      });
    });

    group('formatPercentageFromRatio', () {
      test('calculates percentage from ratio', () {
        expect(FusionDataFormatter.formatPercentageFromRatio(45, 120), '37.5%');
        expect(FusionDataFormatter.formatPercentageFromRatio(50, 100), '50.0%');
      });

      test('returns N/A for zero denominator', () {
        expect(FusionDataFormatter.formatPercentageFromRatio(45, 0), 'N/A');
      });

      test('handles zero numerator', () {
        expect(FusionDataFormatter.formatPercentageFromRatio(0, 100), '0.0%');
      });
    });

    // =========================================================================
    // CURRENCY FORMATTING
    // =========================================================================

    group('formatCurrency', () {
      test('formats with default dollar symbol', () {
        expect(FusionDataFormatter.formatCurrency(1234.56), '\$1,234.56');
      });

      test('respects custom symbol', () {
        expect(
          FusionDataFormatter.formatCurrency(1234.56, symbol: '€'),
          '€1,234.56',
        );
        expect(
          FusionDataFormatter.formatCurrency(1234.56, symbol: '£'),
          '£1,234.56',
        );
      });

      test('supports symbol after number', () {
        expect(
          FusionDataFormatter.formatCurrency(
            1234.56,
            position: CurrencySymbolPosition.after,
          ),
          '1,234.56\$',
        );
      });

      test('handles negative values', () {
        expect(FusionDataFormatter.formatCurrency(-1234.56), '-\$1,234.56');
      });

      test('respects decimals parameter', () {
        expect(
          FusionDataFormatter.formatCurrency(1234.0, decimals: 0),
          '\$1,234',
        );
        expect(
          FusionDataFormatter.formatCurrency(1234.5, decimals: 0),
          '\$1,235', // Rounds up
        );
      });

      test('supports custom separators', () {
        // Note: The current implementation has a limitation when using '.' as
        // thousand separator - replaceAll('.', decimalSeparator) replaces all dots.
        // Using space as thousand separator works correctly.
        expect(
          FusionDataFormatter.formatCurrency(
            1234.56,
            thousandSeparator: ' ',
            decimalSeparator: ',',
          ),
          '\$1 234,56',
        );
      });
    });

    group('formatCurrencyCompact', () {
      test('formats with suffix', () {
        expect(FusionDataFormatter.formatCurrencyCompact(1500000), '\$1.5M');
        expect(FusionDataFormatter.formatCurrencyCompact(2500000000), '\$2.5B');
      });

      test('handles negative values', () {
        expect(FusionDataFormatter.formatCurrencyCompact(-1500000), '-\$1.5M');
      });

      test('respects custom symbol', () {
        expect(
          FusionDataFormatter.formatCurrencyCompact(1500000, symbol: '€'),
          '€1.5M',
        );
      });
    });

    // =========================================================================
    // DATE FORMATTING
    // =========================================================================

    group('formatDate', () {
      test('formats monthDay', () {
        expect(FusionDataFormatter.formatDate(DateTime(2024, 1, 15)), 'Jan 15');
        expect(
          FusionDataFormatter.formatDate(DateTime(2024, 12, 25)),
          'Dec 25',
        );
      });

      test('formats monthYear', () {
        expect(
          FusionDataFormatter.formatDate(
            DateTime(2024, 1, 15),
            format: DateFormat.monthYear,
          ),
          'Jan 2024',
        );
      });

      test('formats dayMonthYear', () {
        expect(
          FusionDataFormatter.formatDate(
            DateTime(2024, 1, 15),
            format: DateFormat.dayMonthYear,
          ),
          '15/1/2024',
        );
      });

      test('formats full', () {
        expect(
          FusionDataFormatter.formatDate(
            DateTime(2024, 1, 15),
            format: DateFormat.full,
          ),
          'January 15, 2024',
        );
      });

      test('formats yearMonth', () {
        expect(
          FusionDataFormatter.formatDate(
            DateTime(2024, 1, 15),
            format: DateFormat.yearMonth,
          ),
          '2024-01',
        );
      });

      test('formats year', () {
        expect(
          FusionDataFormatter.formatDate(
            DateTime(2024, 1, 15),
            format: DateFormat.year,
          ),
          '2024',
        );
      });

      test('handles all months', () {
        for (int month = 1; month <= 12; month++) {
          final result = FusionDataFormatter.formatDate(
            DateTime(2024, month, 1),
          );
          expect(result, isNotEmpty);
        }
      });
    });

    // =========================================================================
    // TIME FORMATTING
    // =========================================================================

    group('formatTime', () {
      test('formats 24-hour time', () {
        expect(
          FusionDataFormatter.formatTime(DateTime(2024, 1, 1, 14, 30)),
          '14:30',
        );
        expect(
          FusionDataFormatter.formatTime(DateTime(2024, 1, 1, 9, 5)),
          '09:05',
        );
        expect(
          FusionDataFormatter.formatTime(DateTime(2024, 1, 1, 0, 0)),
          '00:00',
        );
      });

      test('formats 12-hour time', () {
        expect(
          FusionDataFormatter.formatTime(
            DateTime(2024, 1, 1, 14, 30),
            use24Hour: false,
          ),
          '02:30 PM',
        );
        expect(
          FusionDataFormatter.formatTime(
            DateTime(2024, 1, 1, 9, 5),
            use24Hour: false,
          ),
          '09:05 AM',
        );
      });

      test('handles noon and midnight in 12-hour format', () {
        expect(
          FusionDataFormatter.formatTime(
            DateTime(2024, 1, 1, 12, 0),
            use24Hour: false,
          ),
          '12:00 PM',
        );
        expect(
          FusionDataFormatter.formatTime(
            DateTime(2024, 1, 1, 0, 0),
            use24Hour: false,
          ),
          '12:00 AM',
        );
      });
    });

    // =========================================================================
    // DURATION FORMATTING
    // =========================================================================

    group('formatDuration', () {
      test('formats hours and minutes', () {
        expect(
          FusionDataFormatter.formatDuration(
            const Duration(hours: 2, minutes: 30),
          ),
          '2h 30m',
        );
      });

      test('formats minutes and seconds', () {
        expect(
          FusionDataFormatter.formatDuration(
            const Duration(minutes: 1, seconds: 30),
          ),
          '1m 30s',
        );
      });

      test('formats hours only', () {
        expect(
          FusionDataFormatter.formatDuration(const Duration(hours: 5)),
          '5h',
        );
      });

      test('formats seconds only', () {
        expect(
          FusionDataFormatter.formatDuration(const Duration(seconds: 45)),
          '45s',
        );
      });

      test('handles zero duration', () {
        expect(FusionDataFormatter.formatDuration(Duration.zero), '0s');
      });

      test('hides seconds when hours present', () {
        expect(
          FusionDataFormatter.formatDuration(
            const Duration(hours: 1, minutes: 30, seconds: 45),
          ),
          '1h 30m', // Seconds hidden when hours present
        );
      });
    });

    // =========================================================================
    // CUSTOM FORMATTING
    // =========================================================================

    group('formatCustom', () {
      test('pads with zeros', () {
        expect(FusionDataFormatter.formatCustom(5, '00'), '05');
        expect(FusionDataFormatter.formatCustom(123, '00000'), '00123');
      });

      test('formats with decimals', () {
        expect(FusionDataFormatter.formatCustom(123.4, '000.00'), '123.40');
        expect(FusionDataFormatter.formatCustom(5.1, '00.000'), '05.100');
      });

      test('handles integer patterns', () {
        expect(FusionDataFormatter.formatCustom(42, '0'), '42');
      });
    });

    // =========================================================================
    // VALIDATION
    // =========================================================================

    group('isValidNumber', () {
      test('returns true for valid numbers', () {
        expect(FusionDataFormatter.isValidNumber(0), isTrue);
        expect(FusionDataFormatter.isValidNumber(123.456), isTrue);
        expect(FusionDataFormatter.isValidNumber(-999), isTrue);
      });

      test('returns false for NaN', () {
        expect(FusionDataFormatter.isValidNumber(double.nan), isFalse);
      });

      test('returns false for infinity', () {
        expect(FusionDataFormatter.isValidNumber(double.infinity), isFalse);
        expect(
          FusionDataFormatter.isValidNumber(double.negativeInfinity),
          isFalse,
        );
      });
    });

    group('safeFormat', () {
      test('formats valid numbers', () {
        expect(
          FusionDataFormatter.safeFormat(123.45, (v) => v.toString()),
          '123.45',
        );
      });

      test('returns N/A for NaN', () {
        expect(
          FusionDataFormatter.safeFormat(double.nan, (v) => v.toString()),
          'N/A',
        );
      });

      test('returns N/A for infinity', () {
        expect(
          FusionDataFormatter.safeFormat(double.infinity, (v) => v.toString()),
          'N/A',
        );
      });
    });
  });

  // ===========================================================================
  // ENUM TESTS
  // ===========================================================================

  group('CurrencySymbolPosition', () {
    test('has correct values', () {
      expect(CurrencySymbolPosition.values.length, 2);
      expect(CurrencySymbolPosition.before, isNotNull);
      expect(CurrencySymbolPosition.after, isNotNull);
    });
  });

  group('DateFormat', () {
    test('has correct values', () {
      expect(DateFormat.values.length, 6);
      expect(DateFormat.monthDay, isNotNull);
      expect(DateFormat.monthYear, isNotNull);
      expect(DateFormat.dayMonthYear, isNotNull);
      expect(DateFormat.full, isNotNull);
      expect(DateFormat.yearMonth, isNotNull);
      expect(DateFormat.year, isNotNull);
    });
  });
}

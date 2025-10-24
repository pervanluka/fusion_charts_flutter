import 'dart:math' as math;

/// Data formatting utilities for charts.
///
/// Provides various formatters for displaying numbers, percentages,
/// currencies, and dates in a readable format.
///
/// Useful for:
/// - Axis labels
/// - Tooltip content
/// - Data labels
/// - Legend text
///
/// ## Usage
///
/// ```dart
/// // Format large numbers
/// final formatted = FusionDataFormatter.formatLargeNumber(1500000);
/// // Returns: "1.5M"
///
/// // Format as percentage
/// final percent = FusionDataFormatter.formatPercentage(0.156);
/// // Returns: "15.6%"
///
/// // Format as currency
/// final price = FusionDataFormatter.formatCurrency(1234.56);
/// // Returns: "$1,234.56"
/// ```
class FusionDataFormatter {
  // Private constructor - this is a utility class
  FusionDataFormatter._();

  // ==========================================================================
  // NUMBER FORMATTING
  // ==========================================================================

  /// Formats large numbers with K, M, B, T suffixes.
  ///
  /// Automatically chooses the appropriate suffix based on magnitude:
  /// - K = Thousands (1,000)
  /// - M = Millions (1,000,000)
  /// - B = Billions (1,000,000,000)
  /// - T = Trillions (1,000,000,000,000)
  ///
  /// Examples:
  /// ```dart
  /// formatLargeNumber(999);        // "999"
  /// formatLargeNumber(1500);       // "1.5K"
  /// formatLargeNumber(2500000);    // "2.5M"
  /// formatLargeNumber(1200000000); // "1.2B"
  /// ```
  static String formatLargeNumber(double number, {int decimals = 1, bool showDecimals = true}) {
    final abs = number.abs();
    String suffix = '';
    double value = abs;

    if (abs >= 1e12) {
      value = abs / 1e12;
      suffix = 'T';
    } else if (abs >= 1e9) {
      value = abs / 1e9;
      suffix = 'B';
    } else if (abs >= 1e6) {
      value = abs / 1e6;
      suffix = 'M';
    } else if (abs >= 1e3) {
      value = abs / 1e3;
      suffix = 'K';
    }

    final formatted = showDecimals && suffix.isNotEmpty
        ? value.toStringAsFixed(decimals)
        : value.toStringAsFixed(0);

    // Remove trailing zeros and decimal point if not needed
    final clean = formatted
        .replaceAll(RegExp(r'\.0+$'), '')
        .replaceAll(RegExp(r'(\.\d*?)0+$'), r'$1');

    return '${number < 0 ? '-' : ''}$clean$suffix';
  }

  /// Formats a number with thousand separators.
  ///
  /// Examples:
  /// ```dart
  /// formatWithThousands(1234);      // "1,234"
  /// formatWithThousands(1234567.89); // "1,234,567.89"
  /// ```
  static String formatWithThousands(double number, {int decimals = 2, String separator = ','}) {
    final parts = number.toStringAsFixed(decimals).split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(intPart[i]);
    }

    return decPart.isNotEmpty ? '$buffer.$decPart' : buffer.toString();
  }

  /// Formats a number with specified precision.
  ///
  /// Automatically adjusts decimal places based on magnitude.
  static String formatPrecise(double number, {int maxDecimals = 2}) {
    if (number == 0) return '0';

    final abs = number.abs();
    int decimals = maxDecimals;

    if (abs >= 100) {
      decimals = 0;
    } else if (abs >= 10) {
      decimals = 1;
    } else if (abs >= 1) {
      decimals = 2;
    } else {
      decimals = math.max(2, maxDecimals);
    }

    return number.toStringAsFixed(decimals);
  }

  // ==========================================================================
  // PERCENTAGE FORMATTING
  // ==========================================================================

  /// Formats a decimal as a percentage.
  ///
  /// Input should be in decimal form (0.156 = 15.6%).
  ///
  /// Examples:
  /// ```dart
  /// formatPercentage(0.156);  // "15.6%"
  /// formatPercentage(1.0);    // "100.0%"
  /// formatPercentage(0.005);  // "0.5%"
  /// ```
  static String formatPercentage(double value, {int decimals = 1, bool includeSymbol = true}) {
    final percent = value * 100;
    final formatted = percent.toStringAsFixed(decimals);
    return includeSymbol ? '$formatted%' : formatted;
  }

  /// Formats a percentage from a ratio (numerator/denominator).
  ///
  /// Example:
  /// ```dart
  /// formatPercentageFromRatio(45, 120); // "37.5%"
  /// ```
  static String formatPercentageFromRatio(
    double numerator,
    double denominator, {
    int decimals = 1,
  }) {
    if (denominator == 0) return 'N/A';
    return formatPercentage(numerator / denominator, decimals: decimals);
  }

  // ==========================================================================
  // CURRENCY FORMATTING
  // ==========================================================================

  /// Formats a number as currency.
  ///
  /// Examples:
  /// ```dart
  /// formatCurrency(1234.56);              // "$1,234.56"
  /// formatCurrency(1234.56, symbol: '€'); // "€1,234.56"
  /// formatCurrency(1234.56, position: CurrencySymbolPosition.after); // "1,234.56$"
  /// ```
  static String formatCurrency(
    double value, {
    String symbol = '\$',
    int decimals = 2,
    CurrencySymbolPosition position = CurrencySymbolPosition.before,
    String thousandSeparator = ',',
    String decimalSeparator = '.',
  }) {
    final abs = value.abs();
    final formatted = formatWithThousands(
      abs,
      decimals: decimals,
      separator: thousandSeparator,
    ).replaceAll('.', decimalSeparator);

    final withSymbol = position == CurrencySymbolPosition.before
        ? '$symbol$formatted'
        : '$formatted$symbol';

    return value < 0 ? '-$withSymbol' : withSymbol;
  }

  /// Formats currency with automatic scaling (K, M, B).
  ///
  /// Example:
  /// ```dart
  /// formatCurrencyCompact(1500000); // "$1.5M"
  /// ```
  static String formatCurrencyCompact(double value, {String symbol = '\$', int decimals = 1}) {
    final formatted = formatLargeNumber(value.abs(), decimals: decimals);
    final withSymbol = '$symbol$formatted';
    return value < 0 ? '-$withSymbol' : withSymbol;
  }

  // ==========================================================================
  // DATE/TIME FORMATTING
  // ==========================================================================

  /// Formats a date for axis labels.
  ///
  /// Returns a short, readable date format.
  ///
  /// Examples:
  /// ```dart
  /// formatDate(DateTime(2024, 1, 15));  // "Jan 15"
  /// formatDate(DateTime(2024, 12, 25)); // "Dec 25"
  /// ```
  static String formatDate(DateTime date, {DateFormat format = DateFormat.monthDay}) {
    switch (format) {
      case DateFormat.monthDay:
        return '${_getMonthAbbr(date.month)} ${date.day}';
      case DateFormat.monthYear:
        return '${_getMonthAbbr(date.month)} ${date.year}';
      case DateFormat.dayMonthYear:
        return '${date.day}/${date.month}/${date.year}';
      case DateFormat.full:
        return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
      case DateFormat.yearMonth:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      case DateFormat.year:
        return '${date.year}';
    }
  }

  /// Formats a time for axis labels.
  ///
  /// Examples:
  /// ```dart
  /// formatTime(DateTime(2024, 1, 1, 14, 30)); // "14:30"
  /// formatTime(DateTime(2024, 1, 1, 9, 5));   // "09:05"
  /// ```
  static String formatTime(DateTime time, {bool use24Hour = true}) {
    final hour = use24Hour ? time.hour : (time.hour % 12 == 0 ? 12 : time.hour % 12);
    final minute = time.minute.toString().padLeft(2, '0');
    final formatted = '${hour.toString().padLeft(2, '0')}:$minute';

    if (!use24Hour) {
      final period = time.hour < 12 ? 'AM' : 'PM';
      return '$formatted $period';
    }

    return formatted;
  }

  /// Formats a duration in human-readable form.
  ///
  /// Examples:
  /// ```dart
  /// formatDuration(Duration(hours: 2, minutes: 30)); // "2h 30m"
  /// formatDuration(Duration(seconds: 90));           // "1m 30s"
  /// ```
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0 && hours == 0) parts.add('${seconds}s');

    return parts.isEmpty ? '0s' : parts.join(' ');
  }

  // ==========================================================================
  // CUSTOM FORMATTING
  // ==========================================================================

  /// Formats a number using a custom pattern.
  ///
  /// Pattern placeholders:
  /// - `#` = digit (optional)
  /// - `0` = digit (required, shows 0 if not present)
  ///
  /// Example:
  /// ```dart
  /// formatCustom(123.4, '000.00');  // "123.40"
  /// formatCustom(5, '00');          // "05"
  /// ```
  static String formatCustom(double value, String pattern) {
    // Simple implementation - can be extended
    final parts = pattern.split('.');
    final intPattern = parts[0];
    final decPattern = parts.length > 1 ? parts[1] : '';

    final intPart = value.truncate().toString();
    final decPart = decPattern.isNotEmpty
        ? (value - value.truncate()).toStringAsFixed(decPattern.length).substring(2)
        : '';

    final formattedInt = intPart.padLeft(intPattern.replaceAll('#', '').length, '0');

    return decPattern.isNotEmpty ? '$formattedInt.$decPart' : formattedInt;
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  static String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // ==========================================================================
  // VALIDATION
  // ==========================================================================

  /// Checks if a number is valid (not NaN or infinite).
  static bool isValidNumber(double value) {
    return !value.isNaN && !value.isInfinite;
  }

  /// Returns a safe string representation, handling invalid numbers.
  static String safeFormat(double value, String Function(double) formatter) {
    if (!isValidNumber(value)) return 'N/A';
    return formatter(value);
  }
}

// ==========================================================================
// ENUMS
// ==========================================================================

/// Position of currency symbol.
enum CurrencySymbolPosition {
  /// Before the number (e.g., "$100")
  before,

  /// After the number (e.g., "100$")
  after,
}

/// Date format options.
enum DateFormat {
  /// Month abbreviation and day (e.g., "Jan 15")
  monthDay,

  /// Month abbreviation and year (e.g., "Jan 2024")
  monthYear,

  /// Day/Month/Year (e.g., "15/01/2024")
  dayMonthYear,

  /// Full date (e.g., "January 15, 2024")
  full,

  /// Year-Month (e.g., "2024-01")
  yearMonth,

  /// Year only (e.g., "2024")
  year,
}

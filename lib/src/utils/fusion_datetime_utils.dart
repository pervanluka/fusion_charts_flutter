/// DateTime utilities for chart axes.
///
/// Provides additional helpers for working with DateTime in charts,
/// including interval calculations and smart formatting.
class FusionDateTimeUtils {
  FusionDateTimeUtils._();

  /// Calculates appropriate DateTime interval based on data range.
  ///
  /// Automatically determines if intervals should be in:
  /// - Seconds
  /// - Minutes
  /// - Hours
  /// - Days
  /// - Months
  /// - Years
  ///
  /// Example:
  /// ```dart
  /// final start = DateTime(2024, 1, 1);
  /// final end = DateTime(2024, 12, 31);
  /// final interval = calculateInterval(start, end, desiredIntervals: 6);
  /// // Returns monthly interval
  /// ```
  static Duration calculateInterval(DateTime start, DateTime end, {int desiredIntervals = 5}) {
    final totalSeconds = end.difference(start).inSeconds;
    final intervalSeconds = totalSeconds / desiredIntervals;

    // Seconds
    if (intervalSeconds < 60) {
      return Duration(seconds: _roundToNice(intervalSeconds.round()));
    }

    // Minutes
    if (intervalSeconds < 3600) {
      final minutes = intervalSeconds / 60;
      return Duration(minutes: _roundToNice(minutes.round()));
    }

    // Hours
    if (intervalSeconds < 86400) {
      final hours = intervalSeconds / 3600;
      return Duration(hours: _roundToNice(hours.round()));
    }

    // Days
    if (intervalSeconds < 2592000) {
      // Less than 30 days
      final days = intervalSeconds / 86400;
      return Duration(days: _roundToNice(days.round()));
    }

    // Months (approximate as 30 days)
    final months = intervalSeconds / 2592000;
    return Duration(days: _roundToNice(months.round()) * 30);
  }

  /// Rounds a number to a "nice" value (1, 2, 5, 10, 15, 30, etc.)
  static int _roundToNice(int value) {
    if (value <= 1) return 1;
    if (value <= 2) return 2;
    if (value <= 5) return 5;
    if (value <= 10) return 10;
    if (value <= 15) return 15;
    if (value <= 30) return 30;
    if (value <= 60) return 60;
    return ((value / 60).ceil() * 60); // Round to next hour
  }

  /// Generates a list of DateTime values at regular intervals.
  ///
  /// Example:
  /// ```dart
  /// final start = DateTime(2024, 1, 1);
  /// final end = DateTime(2024, 1, 31);
  /// final dates = generateDateRange(
  ///   start,
  ///   end,
  ///   interval: Duration(days: 7),
  /// );
  /// // Returns dates every 7 days
  /// ```
  static List<DateTime> generateDateRange(DateTime start, DateTime end, Duration interval) {
    final dates = <DateTime>[];
    var current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(interval);
    }

    return dates;
  }

  /// Determines the best format based on data range.
  ///
  /// Returns appropriate format string for the time span.
  static String suggestFormat(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.inSeconds < 60) {
      return 'HH:mm:ss'; // Seconds precision
    } else if (duration.inMinutes < 60) {
      return 'HH:mm'; // Minutes precision
    } else if (duration.inHours < 24) {
      return 'HH:mm'; // Hours in a day
    } else if (duration.inDays < 7) {
      return 'E, MMM d'; // Days in a week
    } else if (duration.inDays < 31) {
      return 'MMM d'; // Days in a month
    } else if (duration.inDays < 365) {
      return 'MMM yyyy'; // Months in a year
    } else {
      return 'yyyy'; // Years
    }
  }

  /// Rounds DateTime to nearest interval.
  ///
  /// Useful for aligning data points to grid.
  static DateTime roundToInterval(DateTime dateTime, Duration interval) {
    final millisSinceEpoch = dateTime.millisecondsSinceEpoch;
    final intervalMillis = interval.inMilliseconds;
    final rounded = (millisSinceEpoch / intervalMillis).round() * intervalMillis;
    return DateTime.fromMillisecondsSinceEpoch(rounded);
  }

  /// Checks if two DateTimes are on the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if two DateTimes are in the same month.
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Checks if two DateTimes are in the same year.
  static bool isSameYear(DateTime a, DateTime b) {
    return a.year == b.year;
  }
}

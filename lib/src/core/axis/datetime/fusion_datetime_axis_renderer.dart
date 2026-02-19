import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../configuration/fusion_axis_configuration.dart';
import '../../../themes/fusion_chart_theme.dart';
import '../../models/axis_bounds.dart';
import '../../models/axis_label.dart';
import '../base/fusion_axis_renderer.dart';
import 'fusion_datetime_axis.dart';

/// Renders datetime axes with automatic date formatting.
///
/// ## Calendar-Aware Intervals (DST-Safe)
///
/// For day-level and above intervals, this renderer uses **calendar arithmetic**
/// instead of millisecond arithmetic. This ensures labels don't drift due to
/// Daylight Saving Time transitions.
///
/// - Sub-day intervals (hours, minutes, seconds): millisecond arithmetic
/// - Day+ intervals (days, weeks, months, years): calendar arithmetic
///
/// ## Configuration Priority (Option A Architecture)
///
/// `FusionAxisConfiguration` is the **single source of truth** for all axis properties.
/// The `FusionDateTimeAxis` provides type-specific defaults (date formatting, etc.).
///
/// Priority order:
/// 1. `configuration.property` (if set)
/// 2. `axis.property` (type-specific fallback)
/// 3. Calculated/default value
class DateTimeAxisRenderer extends FusionAxisRenderer {
  DateTimeAxisRenderer({
    required this.axis,
    required this.configuration,
    this.theme,
    this.isVertical = false,
  });

  /// The datetime axis type definition.
  final FusionDateTimeAxis axis;

  /// Axis configuration (PRIMARY source of truth).
  final FusionAxisConfiguration configuration;

  /// Theme for fallback styling.
  final FusionChartTheme? theme;

  /// Whether this is a vertical axis.
  final bool isVertical;

  static const double _epsilon = 1e-10;
  static const int _maxLabels = 1000;

  // ==========================================================================
  // CACHING
  // ==========================================================================

  AxisBounds? _cachedBounds;
  List<AxisLabel>? _cachedLabels;
  DateFormat? _cachedFormat;
  _IntervalUnit? _cachedIntervalUnit;

  // ==========================================================================
  // TIME CONSTANTS (milliseconds) - Used for interval detection
  // ==========================================================================

  static const double _msPerSecond = 1000.0;
  static const double _msPerMinute = 60000.0;
  static const double _msPerHour = 3600000.0;
  static const double _msPerDay = 86400000.0;
  static const double _msPerWeek = 604800000.0;
  static const double _msPerMonth = 2592000000.0; // ~30 days
  static const double _msPerYear = 31536000000.0; // 365 days

  // ==========================================================================
  // EFFECTIVE VALUE GETTERS
  // ==========================================================================

  /// Gets the effective desired interval count.
  int get _effectiveDesiredIntervals => configuration.desiredIntervals != 5
      ? configuration.desiredIntervals
      : axis.desiredIntervals;

  // ==========================================================================
  // BOUNDS CALCULATION
  // ==========================================================================

  @override
  AxisBounds calculateBounds(List<double> dataValues) {
    DateTime minDate;
    DateTime maxDate;

    // Priority: configuration → axis → data → default
    if (axis.min != null && axis.max != null) {
      minDate = axis.min!;
      maxDate = axis.max!;
    } else if (dataValues.isNotEmpty) {
      final minMs = dataValues.reduce((a, b) => a < b ? a : b);
      final maxMs = dataValues.reduce((a, b) => a > b ? a : b);

      minDate = axis.min ?? DateTime.fromMillisecondsSinceEpoch(minMs.toInt());
      maxDate = axis.max ?? DateTime.fromMillisecondsSinceEpoch(maxMs.toInt());
    } else {
      maxDate = DateTime.now();
      minDate = maxDate.subtract(const Duration(days: 30));
    }

    if (minDate.isAfter(maxDate)) {
      final temp = minDate;
      minDate = maxDate;
      maxDate = temp;
    }

    final rangeMs = maxDate.difference(minDate).inMilliseconds.toDouble();

    // Calculate interval and detect its calendar unit
    final intervalResult = axis.interval != null
        ? _detectIntervalUnit(axis.interval!.inMilliseconds.toDouble())
        : _calculateAutoIntervalWithUnit(rangeMs, _effectiveDesiredIntervals);

    _cachedIntervalUnit = intervalResult.unit;
    _cachedFormat = axis.dateFormat ?? _selectDateFormat(rangeMs);

    _cachedBounds = AxisBounds(
      min: minDate.millisecondsSinceEpoch.toDouble(),
      max: maxDate.millisecondsSinceEpoch.toDouble(),
      interval: intervalResult.intervalMs,
      decimalPlaces: 0,
    );

    return _cachedBounds!;
  }

  /// Calculates auto interval and returns both ms value and detected unit.
  _IntervalResult _calculateAutoIntervalWithUnit(
    double rangeMs,
    int desiredIntervals,
  ) {
    final roughInterval = rangeMs / desiredIntervals;

    if (roughInterval < _msPerMinute) {
      final ms = _findNiceInterval(
        roughInterval,
        [1, 5, 10, 15, 30].map((s) => s * _msPerSecond).toList(),
      );
      return _IntervalResult(ms, _IntervalUnit.second);
    } else if (roughInterval < _msPerHour) {
      final ms = _findNiceInterval(
        roughInterval,
        [1, 5, 10, 15, 30].map((m) => m * _msPerMinute).toList(),
      );
      return _IntervalResult(ms, _IntervalUnit.minute);
    } else if (roughInterval < _msPerDay) {
      final ms = _findNiceInterval(
        roughInterval,
        [1, 2, 3, 6, 12].map((h) => h * _msPerHour).toList(),
      );
      return _IntervalResult(ms, _IntervalUnit.hour);
    } else if (roughInterval < _msPerWeek) {
      final ms = _findNiceInterval(
        roughInterval,
        [1, 2, 3, 7].map((d) => d * _msPerDay).toList(),
      );
      return _IntervalResult(ms, _IntervalUnit.day);
    } else if (roughInterval < _msPerMonth) {
      final ms = _findNiceInterval(
        roughInterval,
        [1, 2, 4].map((w) => w * _msPerWeek).toList(),
      );
      return _IntervalResult(ms, _IntervalUnit.week);
    } else if (roughInterval < _msPerYear) {
      final ms = _findNiceInterval(
        roughInterval,
        [1, 2, 3, 6].map((m) => m * _msPerMonth).toList(),
      );
      return _IntervalResult(ms, _IntervalUnit.month);
    } else {
      final ms = _findNiceInterval(
        roughInterval,
        [1, 2, 5, 10].map((y) => y * _msPerYear).toList(),
      );
      return _IntervalResult(ms, _IntervalUnit.year);
    }
  }

  /// Detects the calendar unit from a millisecond interval.
  _IntervalResult _detectIntervalUnit(double intervalMs) {
    if (intervalMs >= _msPerYear * 0.9) {
      return _IntervalResult(intervalMs, _IntervalUnit.year);
    } else if (intervalMs >= _msPerMonth * 0.9) {
      return _IntervalResult(intervalMs, _IntervalUnit.month);
    } else if (intervalMs >= _msPerWeek * 0.9) {
      return _IntervalResult(intervalMs, _IntervalUnit.week);
    } else if (intervalMs >= _msPerDay * 0.9) {
      return _IntervalResult(intervalMs, _IntervalUnit.day);
    } else if (intervalMs >= _msPerHour * 0.9) {
      return _IntervalResult(intervalMs, _IntervalUnit.hour);
    } else if (intervalMs >= _msPerMinute * 0.9) {
      return _IntervalResult(intervalMs, _IntervalUnit.minute);
    } else {
      return _IntervalResult(intervalMs, _IntervalUnit.second);
    }
  }

  double _findNiceInterval(double target, List<double> options) {
    return options.reduce((closest, current) {
      return (current - target).abs() < (closest - target).abs()
          ? current
          : closest;
    });
  }

  DateFormat _selectDateFormat(double rangeMs) {
    if (rangeMs < _msPerDay) {
      return DateFormat('HH:mm');
    } else if (rangeMs < _msPerWeek) {
      return DateFormat('MMM dd HH:mm');
    } else if (rangeMs < _msPerMonth * 3) {
      return DateFormat('MMM dd');
    } else if (rangeMs < _msPerYear * 2) {
      return DateFormat('MMM yyyy');
    } else {
      return DateFormat('yyyy');
    }
  }

  // ==========================================================================
  // LABEL GENERATION (DST-SAFE)
  // ==========================================================================

  /// Stores the available size for the axis (set during measureAxisLabels).
  double _availableSize = 0;

  @override
  List<AxisLabel> generateLabels(AxisBounds bounds) {
    // Check if custom labelGenerator is provided
    if (configuration.hasLabelGenerator) {
      return _generateCustomLabels(bounds);
    }

    return _generateAutoLabels(bounds);
  }

  /// Generates labels using the custom labelGenerator callback.
  ///
  /// For DateTime axes, the callback receives millisecondsSinceEpoch values.
  /// The returned values should also be in millisecondsSinceEpoch.
  List<AxisLabel> _generateCustomLabels(AxisBounds bounds) {
    final generator = configuration.labelGenerator!;
    final customValues = generator(bounds, _availableSize, isVertical);
    final format = _cachedFormat ?? _selectDateFormat(bounds.range);

    final labels = <AxisLabel>[];

    for (final value in customValues) {
      // Skip values outside the axis range
      if (value < bounds.min - _epsilon || value > bounds.max + _epsilon) {
        continue;
      }

      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      final text = format.format(date);
      final position = _calculatePrecisePosition(value, bounds);

      labels.add(
        AxisLabel(value: value, text: text, position: position.clamp(0.0, 1.0)),
      );
    }

    _cachedLabels = labels;
    return labels;
  }

  /// Generates labels using the automatic algorithm (DST-safe).
  List<AxisLabel> _generateAutoLabels(AxisBounds bounds) {
    final format = _cachedFormat ?? _selectDateFormat(bounds.range);
    final unit = _cachedIntervalUnit ?? _IntervalUnit.day;

    final minDate = DateTime.fromMillisecondsSinceEpoch(bounds.min.toInt());
    final maxDate = DateTime.fromMillisecondsSinceEpoch(bounds.max.toInt());

    // Use calendar arithmetic for day+ intervals (DST-safe)
    // Use millisecond arithmetic for sub-day intervals
    if (unit.isDayOrAbove) {
      return _generateCalendarLabels(minDate, maxDate, bounds, format, unit);
    } else {
      return _generateMillisecondLabels(bounds, format);
    }
  }

  /// Generates labels using calendar arithmetic (DST-safe for day+ intervals).
  List<AxisLabel> _generateCalendarLabels(
    DateTime minDate,
    DateTime maxDate,
    AxisBounds bounds,
    DateFormat format,
    _IntervalUnit unit,
  ) {
    final labels = <AxisLabel>[];

    // Normalize start to midnight for day+ intervals
    DateTime current = DateTime(minDate.year, minDate.month, minDate.day);

    // Calculate interval value in calendar units
    final intervalValue = _getIntervalValue(bounds.interval, unit);

    int iterations = 0;
    while (!current.isAfter(maxDate) && iterations < _maxLabels) {
      final ms = current.millisecondsSinceEpoch.toDouble();
      final position = _calculatePrecisePosition(ms, bounds);

      // Only add label if within bounds
      if (position >= -_epsilon && position <= 1.0 + _epsilon) {
        labels.add(
          AxisLabel(
            value: ms,
            text: format.format(current),
            position: position.clamp(0.0, 1.0),
          ),
        );
      }

      // Advance using CALENDAR arithmetic (DST-safe)
      current = _addCalendarInterval(current, intervalValue, unit);
      iterations++;
    }

    _cachedLabels = labels;
    return labels;
  }

  /// Generates labels using millisecond arithmetic (for sub-day intervals).
  List<AxisLabel> _generateMillisecondLabels(
    AxisBounds bounds,
    DateFormat format,
  ) {
    final labels = <AxisLabel>[];

    final labelCount = _calculateLabelCount(bounds);

    for (int i = 0; i < labelCount; i++) {
      final currentMs = bounds.min + (bounds.interval * i);

      if (currentMs > bounds.max + _epsilon) break;

      final date = DateTime.fromMillisecondsSinceEpoch(currentMs.toInt());
      final text = format.format(date);
      final position = _calculatePrecisePosition(currentMs, bounds);

      labels.add(
        AxisLabel(
          value: currentMs,
          text: text,
          position: position.clamp(0.0, 1.0),
        ),
      );
    }

    _cachedLabels = labels;
    return labels;
  }

  /// Converts millisecond interval to calendar unit value.
  int _getIntervalValue(double intervalMs, _IntervalUnit unit) {
    switch (unit) {
      case _IntervalUnit.second:
        return (intervalMs / _msPerSecond).round();
      case _IntervalUnit.minute:
        return (intervalMs / _msPerMinute).round();
      case _IntervalUnit.hour:
        return (intervalMs / _msPerHour).round();
      case _IntervalUnit.day:
        return (intervalMs / _msPerDay).round();
      case _IntervalUnit.week:
        return (intervalMs / _msPerWeek).round();
      case _IntervalUnit.month:
        return (intervalMs / _msPerMonth).round();
      case _IntervalUnit.year:
        return (intervalMs / _msPerYear).round();
    }
  }

  /// Adds a calendar interval to a date (DST-safe).
  ///
  /// This is the key function that prevents DST drift.
  /// Instead of adding milliseconds, we manipulate calendar components directly.
  DateTime _addCalendarInterval(DateTime date, int value, _IntervalUnit unit) {
    switch (unit) {
      case _IntervalUnit.second:
      case _IntervalUnit.minute:
      case _IntervalUnit.hour:
        // Sub-day: Duration addition is fine
        return date.add(
          Duration(
            hours: unit == _IntervalUnit.hour ? value : 0,
            minutes: unit == _IntervalUnit.minute ? value : 0,
            seconds: unit == _IntervalUnit.second ? value : 0,
          ),
        );

      case _IntervalUnit.day:
        // Calendar day arithmetic - DST safe
        // Always normalize to midnight
        return DateTime(date.year, date.month, date.day + value);

      case _IntervalUnit.week:
        // 7 calendar days
        return DateTime(date.year, date.month, date.day + (value * 7));

      case _IntervalUnit.month:
        // Calendar month arithmetic with day clamping
        return _addMonths(date, value);

      case _IntervalUnit.year:
        // Calendar year arithmetic
        return _addMonths(date, value * 12);
    }
  }

  /// Adds months to a date, clamping day to valid range.
  ///
  /// Handles cases like Jan 31 + 1 month = Feb 28 (not Mar 2/3).
  DateTime _addMonths(DateTime date, int months) {
    final targetYear = date.year + (date.month + months - 1) ~/ 12;
    final targetMonth = (date.month + months - 1) % 12 + 1;

    // Find last day of target month
    final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;

    // Clamp day to valid range
    final clampedDay = date.day.clamp(1, lastDayOfMonth);

    return DateTime(targetYear, targetMonth, clampedDay);
  }

  int _calculateLabelCount(AxisBounds bounds) {
    if (bounds.range <= 0 || bounds.interval <= 0) return 1;

    final theoreticalCount = (bounds.range / bounds.interval).round() + 1;
    return theoreticalCount.clamp(1, _maxLabels);
  }

  double _calculatePrecisePosition(double value, AxisBounds bounds) {
    if (bounds.range <= _epsilon) return 0.5;

    final normalized = (value - bounds.min) / bounds.range;

    if (normalized.abs() < _epsilon) return 0.0;
    if ((1.0 - normalized).abs() < _epsilon) return 1.0;

    return normalized.clamp(0.0, 1.0);
  }

  // ==========================================================================
  // SIZE MEASUREMENT
  // ==========================================================================

  @override
  Size measureAxisLabels(List<AxisLabel> labels, Size availableSize) {
    // Store available size for labelGenerator callback
    _availableSize = isVertical ? availableSize.height : availableSize.width;

    // If axis is not visible, return zero size
    if (!configuration.visible) {
      return Size.zero;
    }

    if (labels.isEmpty) return Size.zero;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double maxWidth = 0;
    double maxHeight = 0;

    final labelStyle =
        configuration.labelStyle ??
        theme?.axisLabelStyle ??
        const TextStyle(fontSize: 12);

    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: labelStyle);
      textPainter.layout();

      maxWidth = math.max(maxWidth, textPainter.width);
      maxHeight = math.max(maxHeight, textPainter.height);
    }

    const padding = 8.0;

    if (isVertical) {
      return Size(maxWidth + padding, availableSize.height);
    } else {
      if (labels.length > 1) {
        final availableWidthPerLabel = availableSize.width / labels.length;
        if (maxWidth > availableWidthPerLabel * 0.9) {
          final rotation = configuration.labelRotation?.abs() ?? 45.0;
          final rotatedHeight =
              maxWidth * math.sin(rotation * math.pi / 180) +
              maxHeight * math.cos(rotation * math.pi / 180);
          return Size(availableSize.width, rotatedHeight + padding);
        }
      }

      return Size(availableSize.width, maxHeight + padding);
    }
  }

  // ==========================================================================
  // RENDERING
  // ==========================================================================

  @override
  void renderAxis(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    // CRITICAL: Check visibility first
    if (!configuration.visible) {
      return;
    }

    if (configuration.showAxisLine) {
      _drawAxisLine(canvas, axisArea);
    }

    if (configuration.showTicks) {
      _drawTicks(canvas, axisArea, bounds);
    }

    if (configuration.showLabels) {
      _drawLabels(canvas, axisArea, bounds);
    }
  }

  void _drawAxisLine(Canvas canvas, Rect axisArea) {
    final paint = Paint()
      ..color = configuration.axisLineColor ?? theme?.axisColor ?? Colors.grey
      ..strokeWidth = configuration.axisLineWidth ?? 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    if (isVertical) {
      canvas.drawLine(
        Offset(axisArea.right, axisArea.top),
        Offset(axisArea.right, axisArea.bottom),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(axisArea.left, axisArea.top),
        Offset(axisArea.right, axisArea.top),
        paint,
      );
    }
  }

  void _drawTicks(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    final paint = Paint()
      ..color = configuration.majorTickColor ?? theme?.axisColor ?? Colors.grey
      ..strokeWidth = configuration.majorTickWidth ?? 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final tickLength = configuration.majorTickLength ?? 6.0;
    final labels = _cachedLabels ?? generateLabels(bounds);

    for (final label in labels) {
      final position = label.position;

      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        final snappedY = y.roundToDouble();
        canvas.drawLine(
          Offset(axisArea.right, snappedY),
          Offset(axisArea.right + tickLength, snappedY),
          paint,
        );
      } else {
        final x = axisArea.left + (position * axisArea.width);
        final snappedX = x.roundToDouble();
        canvas.drawLine(
          Offset(snappedX, axisArea.top),
          Offset(snappedX, axisArea.top + tickLength),
          paint,
        );
      }
    }
  }

  void _drawLabels(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    final labels = _cachedLabels ?? generateLabels(bounds);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final labelStyle =
        configuration.labelStyle ??
        theme?.axisLabelStyle ??
        const TextStyle(fontSize: 12);

    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: labelStyle);
      textPainter.layout();

      final position = label.position;

      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        final snappedY = y.roundToDouble();
        final offset = Offset(
          axisArea.left - textPainter.width - 8,
          snappedY - (textPainter.height / 2),
        );
        textPainter.paint(canvas, offset);
      } else {
        final x = axisArea.left + (position * axisArea.width);
        final snappedX = x.roundToDouble();

        if (configuration.labelRotation != null &&
            configuration.labelRotation!.abs() > 0) {
          canvas.save();
          canvas.translate(snappedX, axisArea.top + 8);
          canvas.rotate(configuration.labelRotation! * (math.pi / 180));
          textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
          canvas.restore();
        } else {
          final offset = Offset(
            snappedX - (textPainter.width / 2),
            axisArea.top + 8,
          );
          textPainter.paint(canvas, offset);
        }
      }
    }
  }

  @override
  void renderGridLines(Canvas canvas, Rect plotArea, AxisBounds bounds) {
    if (!configuration.showGrid) return;

    final paint = Paint()
      ..color =
          configuration.majorGridColor ??
          theme?.gridColor ??
          Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = configuration.majorGridWidth ?? 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final labels = _cachedLabels ?? generateLabels(bounds);

    for (final label in labels) {
      final position = label.position;

      if (isVertical) {
        final y = plotArea.bottom - (position * plotArea.height);
        final snappedY = y.roundToDouble();
        canvas.drawLine(
          Offset(plotArea.left, snappedY),
          Offset(plotArea.right, snappedY),
          paint,
        );
      } else {
        final x = plotArea.left + (position * plotArea.width);
        final snappedX = x.roundToDouble();
        canvas.drawLine(
          Offset(snappedX, plotArea.top),
          Offset(snappedX, plotArea.bottom),
          paint,
        );
      }
    }
  }

  // ==========================================================================
  // DISPOSAL
  // ==========================================================================

  @override
  void dispose() {
    _cachedBounds = null;
    _cachedLabels = null;
    _cachedFormat = null;
    _cachedIntervalUnit = null;
  }

  @override
  String toString() {
    return 'DateTimeAxisRenderer('
        'visible: ${configuration.visible}, '
        'isVertical: $isVertical, '
        'intervalUnit: $_cachedIntervalUnit, '
        'bounds: $_cachedBounds'
        ')';
  }
}

// =============================================================================
// INTERNAL TYPES
// =============================================================================

/// Calendar unit for interval detection.
enum _IntervalUnit {
  second,
  minute,
  hour,
  day,
  week,
  month,
  year;

  /// Returns true for day-level and above intervals (need calendar arithmetic).
  bool get isDayOrAbove => index >= _IntervalUnit.day.index;
}

/// Result of interval calculation with detected unit.
class _IntervalResult {
  const _IntervalResult(this.intervalMs, this.unit);
  final double intervalMs;
  final _IntervalUnit unit;
}

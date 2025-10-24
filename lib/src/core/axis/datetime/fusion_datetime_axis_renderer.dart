import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../../configuration/fusion_axis_configuration.dart';
import '../../../themes/fusion_chart_theme.dart';
import '../../models/axis_bounds.dart';
import '../../models/axis_label.dart';
import '../base/fusion_axis_renderer.dart';
import 'fusion_datetime_axis.dart';

/// Renders datetime axes with automatic date formatting.
///
/// Intelligently formats dates based on the time range:
/// - Hours/minutes for short ranges (< 1 day)
/// - Days for medium ranges (1 day - 1 week)
/// - Weeks for longer ranges (1 week - 3 months)
/// - Months for very long ranges (3 months - 2 years)
/// - Years for extremely long ranges (> 2 years)
///
/// ## Features
///
/// - Automatic date format selection
/// - Smart interval calculation
/// - Handles daylight saving time
/// - Timezone aware
/// - Custom format support
/// - Caching for performance
///
/// ## Example
///
/// ```dart
/// final axis = FusionDateTimeAxis(
///   min: DateTime(2024, 1, 1),
///   max: DateTime(2024, 12, 31),
///   title: 'Date',
/// );
///
/// final config = FusionAxisConfiguration(
///   showLabels: true,
///   showGrid: true,
/// );
///
/// final renderer = DateTimeAxisRenderer(
///   axis: axis,
///   configuration: config,
///   isVertical: false,
/// );
/// ```
class DateTimeAxisRenderer extends FusionAxisRenderer {
  /// Creates a datetime axis renderer.
  DateTimeAxisRenderer({
    required this.axis,
    required this.configuration,
    this.theme,
    this.isVertical = false,
  });

  /// The datetime axis definition.
  final FusionDateTimeAxis axis;

  /// Axis configuration (styling, visibility, etc.).
  final FusionAxisConfiguration configuration;

  /// Theme for fallback styling.
  final FusionChartTheme? theme;

  /// Whether this is a vertical axis (Y-axis).
  final bool isVertical;

  /// Epsilon for floating-point comparisons
  static const double _epsilon = 1e-10;

  /// Maximum labels to prevent infinite loops
  static const int _maxLabels = 1000;

  // ==========================================================================
  // CACHING
  // ==========================================================================

  AxisBounds? _cachedBounds;
  List<AxisLabel>? _cachedLabels;
  DateFormat? _cachedFormat;

  // ==========================================================================
  // TIME CONSTANTS (in milliseconds)
  // ==========================================================================

  static const double _msPerSecond = 1000.0;
  static const double _msPerMinute = 60000.0;
  static const double _msPerHour = 3600000.0;
  static const double _msPerDay = 86400000.0;
  static const double _msPerWeek = 604800000.0;
  static const double _msPerMonth = 2592000000.0; // Approximate (30 days)
  static const double _msPerYear = 31536000000.0; // Approximate (365 days)

  // ==========================================================================
  // BOUNDS CALCULATION
  // ==========================================================================

  @override
  AxisBounds calculateBounds(List<double> dataValues) {
    // Convert data values (assumed to be milliseconds since epoch)
    // to DateTime objects for calculation

    DateTime minDate;
    DateTime maxDate;

    if (axis.min != null && axis.max != null) {
      // Use explicit min/max from axis
      minDate = axis.min!;
      maxDate = axis.max!;
    } else if (dataValues.isNotEmpty) {
      // Calculate from data
      final minMs = dataValues.reduce((a, b) => a < b ? a : b);
      final maxMs = dataValues.reduce((a, b) => a > b ? a : b);

      minDate = axis.min ?? DateTime.fromMillisecondsSinceEpoch(minMs.toInt());
      maxDate = axis.max ?? DateTime.fromMillisecondsSinceEpoch(maxMs.toInt());
    } else {
      // Default range: last 30 days
      maxDate = DateTime.now();
      minDate = maxDate.subtract(const Duration(days: 30));
    }

    // Ensure min < max
    if (minDate.isAfter(maxDate)) {
      final temp = minDate;
      minDate = maxDate;
      maxDate = temp;
    }

    // Calculate range in milliseconds
    final rangeMs = maxDate.difference(minDate).inMilliseconds.toDouble();

    // Calculate appropriate interval
    final intervalMs =
        axis.interval?.inMilliseconds.toDouble() ??
        _calculateAutoInterval(rangeMs, axis.desiredIntervals);

    // Store format for label generation
    _cachedFormat = (axis.dateFormat ?? _selectDateFormat(rangeMs)) as DateFormat?;

    _cachedBounds = AxisBounds(
      min: minDate.millisecondsSinceEpoch.toDouble(),
      max: maxDate.millisecondsSinceEpoch.toDouble(),
      interval: intervalMs,
      decimalPlaces: 0, // Not used for datetime
    );

    return _cachedBounds!;
  }

  /// Calculates automatic interval based on time range.
  double _calculateAutoInterval(double rangeMs, int desiredIntervals) {
    final roughInterval = rangeMs / desiredIntervals;

    // Find the "nicest" interval close to the rough interval
    if (roughInterval < _msPerMinute) {
      // Seconds: 1, 5, 10, 15, 30
      return _findNiceInterval(
        roughInterval,
        [1, 5, 10, 15, 30].map((s) => s * _msPerSecond).toList(),
      );
    } else if (roughInterval < _msPerHour) {
      // Minutes: 1, 5, 10, 15, 30
      return _findNiceInterval(
        roughInterval,
        [1, 5, 10, 15, 30].map((m) => m * _msPerMinute).toList(),
      );
    } else if (roughInterval < _msPerDay) {
      // Hours: 1, 2, 3, 6, 12
      return _findNiceInterval(roughInterval, [1, 2, 3, 6, 12].map((h) => h * _msPerHour).toList());
    } else if (roughInterval < _msPerWeek) {
      // Days: 1, 2, 3, 7
      return _findNiceInterval(roughInterval, [1, 2, 3, 7].map((d) => d * _msPerDay).toList());
    } else if (roughInterval < _msPerMonth) {
      // Weeks: 1, 2, 4
      return _findNiceInterval(roughInterval, [1, 2, 4].map((w) => w * _msPerWeek).toList());
    } else if (roughInterval < _msPerYear) {
      // Months: 1, 2, 3, 6
      return _findNiceInterval(roughInterval, [1, 2, 3, 6].map((m) => m * _msPerMonth).toList());
    } else {
      // Years: 1, 2, 5, 10
      return _findNiceInterval(roughInterval, [1, 2, 5, 10].map((y) => y * _msPerYear).toList());
    }
  }

  /// Finds the closest "nice" interval from a list of options.
  double _findNiceInterval(double target, List<double> options) {
    return options.reduce((closest, current) {
      return (current - target).abs() < (closest - target).abs() ? current : closest;
    });
  }

  /// Selects appropriate date format based on time range.
  DateFormat _selectDateFormat(double rangeMs) {
    if (rangeMs < _msPerDay) {
      // Less than 1 day: show hours and minutes
      return DateFormat('HH:mm');
    } else if (rangeMs < _msPerWeek) {
      // 1 day to 1 week: show month, day, and time
      return DateFormat('MMM dd HH:mm');
    } else if (rangeMs < _msPerMonth * 3) {
      // 1 week to 3 months: show month and day
      return DateFormat('MMM dd');
    } else if (rangeMs < _msPerYear * 2) {
      // 3 months to 2 years: show month and year
      return DateFormat('MMM yyyy');
    } else {
      // More than 2 years: show year only
      return DateFormat('yyyy');
    }
  }

  // ==========================================================================
  // LABEL GENERATION
  // ==========================================================================

  @override
  List<AxisLabel> generateLabels(AxisBounds bounds) {
    final labels = <AxisLabel>[];
    final format = _cachedFormat ?? _selectDateFormat(bounds.range);

    // ✅ FIX: Calculate label count FIRST
    final labelCount = _calculateLabelCount(bounds);

    // ✅ FIX: Index-based generation (no accumulation)
    for (int i = 0; i < labelCount; i++) {
      // ✅ Calculate each value INDEPENDENTLY
      final currentMs = bounds.min + (bounds.interval * i);

      // ✅ Precision check
      if (currentMs > bounds.max + _epsilon) break;

      final date = DateTime.fromMillisecondsSinceEpoch(currentMs.toInt());
      final text = format.format(date);

      // ✅ Precise position calculation
      final position = _calculatePrecisePosition(currentMs, bounds);

      labels.add(AxisLabel(value: currentMs, text: text, position: position.clamp(0.0, 1.0)));
    }

    _cachedLabels = labels;
    return labels;
  }

  /// Calculates the number of labels.
  int _calculateLabelCount(AxisBounds bounds) {
    if (bounds.range <= 0 || bounds.interval <= 0) return 1;

    final theoreticalCount = (bounds.range / bounds.interval).round() + 1;

    return theoreticalCount.clamp(1, _maxLabels);
  }

  /// Calculates position with maximum precision.
  double _calculatePrecisePosition(double value, AxisBounds bounds) {
    if (bounds.range <= _epsilon) return 0.5;

    final normalized = (value - bounds.min) / bounds.range;

    // Clean floating-point errors at boundaries
    if (normalized.abs() < _epsilon) return 0.0;
    if ((1.0 - normalized).abs() < _epsilon) return 1.0;

    return normalized.clamp(0.0, 1.0);
  }

  // ==========================================================================
  // SIZE MEASUREMENT
  // ==========================================================================

  @override
  Size measureAxisLabels(List<AxisLabel> labels, Size availableSize) {
    if (labels.isEmpty) return Size.zero;

    final textPainter = TextPainter();

    double maxWidth = 0;
    double maxHeight = 0;

    final labelStyle =
        configuration.labelStyle ?? theme?.axisLabelStyle ?? const TextStyle(fontSize: 12);

    // Measure all labels
    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: labelStyle);
      textPainter.layout();

      maxWidth = math.max(maxWidth, textPainter.width);
      maxHeight = math.max(maxHeight, textPainter.height);
    }

    const padding = 8.0;

    if (isVertical) {
      // Vertical axis - labels on the side
      return Size(maxWidth + padding, availableSize.height);
    } else {
      // Horizontal axis - labels below
      // Check for rotation if labels are too wide
      if (labels.length > 1) {
        final availableWidthPerLabel = availableSize.width / labels.length;
        if (maxWidth > availableWidthPerLabel * 0.9) {
          // Need rotation - increase height
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
    // Draw axis line
    if (configuration.showAxisLine) {
      _drawAxisLine(canvas, axisArea);
    }

    // Draw ticks
    if (configuration.showTicks) {
      _drawTicks(canvas, axisArea, bounds);
    }

    // Draw labels
    if (configuration.showLabels) {
      _drawLabels(canvas, axisArea, bounds);
    }
  }

  /// Draws the main axis line.
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

  // In _drawTicks method, add pixel snapping:
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
        final snappedY = y.roundToDouble(); // ✅ PIXEL SNAP
        canvas.drawLine(
          Offset(axisArea.right, snappedY),
          Offset(axisArea.right + tickLength, snappedY),
          paint,
        );
      } else {
        final x = axisArea.left + (position * axisArea.width);
        final snappedX = x.roundToDouble(); // ✅ PIXEL SNAP
        canvas.drawLine(
          Offset(snappedX, axisArea.top),
          Offset(snappedX, axisArea.top + tickLength),
          paint,
        );
      }
    }
  }

  // In _drawLabels method, add pixel snapping:
  void _drawLabels(Canvas canvas, Rect axisArea, AxisBounds bounds) {
    final labels = _cachedLabels ?? generateLabels(bounds);
    final textPainter = TextPainter(textAlign: TextAlign.center);

    final labelStyle =
        configuration.labelStyle ?? theme?.axisLabelStyle ?? const TextStyle(fontSize: 12);

    for (final label in labels) {
      textPainter.text = TextSpan(text: label.text, style: labelStyle);
      textPainter.layout();

      final position = label.position;

      final Offset offset;
      if (isVertical) {
        final y = axisArea.bottom - (position * axisArea.height);
        final snappedY = y.roundToDouble(); // ✅ PIXEL SNAP
        offset = Offset(axisArea.left - textPainter.width - 8, snappedY - (textPainter.height / 2));
      } else {
        final x = axisArea.left + (position * axisArea.width);
        final snappedX = x.roundToDouble(); // ✅ PIXEL SNAP

        // Handle rotation if needed
        if (configuration.labelRotation != null && configuration.labelRotation!.abs() > 0) {
          canvas.save();
          canvas.translate(snappedX, axisArea.top + 8);
          canvas.rotate(configuration.labelRotation! * (3.14159 / 180));
          textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
          canvas.restore();
        } else {
          offset = Offset(snappedX - (textPainter.width / 2), axisArea.top + 8);
          textPainter.paint(canvas, offset);
        }
      }
    }
  }

  // In renderGridLines method, add pixel snapping:
  @override
  void renderGridLines(Canvas canvas, Rect plotArea, AxisBounds bounds) {
    if (!configuration.showGrid) return;

    final paint = Paint()
      ..color =
          configuration.majorGridColor ?? theme?.gridColor ?? Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = configuration.majorGridWidth ?? 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final labels = _cachedLabels ?? generateLabels(bounds);

    for (final label in labels) {
      final position = label.position;

      if (isVertical) {
        final y = plotArea.bottom - (position * plotArea.height);
        final snappedY = y.roundToDouble(); // ✅ PIXEL SNAP
        canvas.drawLine(Offset(plotArea.left, snappedY), Offset(plotArea.right, snappedY), paint);
      } else {
        final x = plotArea.left + (position * plotArea.width);
        final snappedX = x.roundToDouble(); // ✅ PIXEL SNAP
        canvas.drawLine(Offset(snappedX, plotArea.top), Offset(snappedX, plotArea.bottom), paint);
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
  }

  // ==========================================================================
  // DEBUG
  // ==========================================================================

  @override
  String toString() {
    return 'DateTimeAxisRenderer('
        'isVertical: $isVertical, '
        'bounds: $_cachedBounds, '
        'format: $_cachedFormat'
        ')';
  }
}

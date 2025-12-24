import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart' hide TextDirection;
import '../../../configuration/fusion_axis_configuration.dart';
import '../../../themes/fusion_chart_theme.dart';
import '../../models/axis_bounds.dart';
import '../../models/axis_label.dart';
import '../base/fusion_axis_renderer.dart';
import 'fusion_datetime_axis.dart';

/// Renders datetime axes with automatic date formatting.
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

  // ==========================================================================
  // TIME CONSTANTS (milliseconds)
  // ==========================================================================

  static const double _msPerSecond = 1000.0;
  static const double _msPerMinute = 60000.0;
  static const double _msPerHour = 3600000.0;
  static const double _msPerDay = 86400000.0;
  static const double _msPerWeek = 604800000.0;
  static const double _msPerMonth = 2592000000.0;
  static const double _msPerYear = 31536000000.0;

  // ==========================================================================
  // EFFECTIVE VALUE GETTERS
  // ==========================================================================

  /// Gets the effective desired interval count.
  int get _effectiveDesiredIntervals =>
      configuration.desiredIntervals != 5
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

    final intervalMs =
        axis.interval?.inMilliseconds.toDouble() ??
        _calculateAutoInterval(rangeMs, _effectiveDesiredIntervals);

    _cachedFormat = axis.dateFormat ?? _selectDateFormat(rangeMs);

    _cachedBounds = AxisBounds(
      min: minDate.millisecondsSinceEpoch.toDouble(),
      max: maxDate.millisecondsSinceEpoch.toDouble(),
      interval: intervalMs,
      decimalPlaces: 0,
    );

    return _cachedBounds!;
  }

  double _calculateAutoInterval(double rangeMs, int desiredIntervals) {
    final roughInterval = rangeMs / desiredIntervals;

    if (roughInterval < _msPerMinute) {
      return _findNiceInterval(
        roughInterval,
        [1, 5, 10, 15, 30].map((s) => s * _msPerSecond).toList(),
      );
    } else if (roughInterval < _msPerHour) {
      return _findNiceInterval(
        roughInterval,
        [1, 5, 10, 15, 30].map((m) => m * _msPerMinute).toList(),
      );
    } else if (roughInterval < _msPerDay) {
      return _findNiceInterval(
        roughInterval,
        [1, 2, 3, 6, 12].map((h) => h * _msPerHour).toList(),
      );
    } else if (roughInterval < _msPerWeek) {
      return _findNiceInterval(
        roughInterval,
        [1, 2, 3, 7].map((d) => d * _msPerDay).toList(),
      );
    } else if (roughInterval < _msPerMonth) {
      return _findNiceInterval(
        roughInterval,
        [1, 2, 4].map((w) => w * _msPerWeek).toList(),
      );
    } else if (roughInterval < _msPerYear) {
      return _findNiceInterval(
        roughInterval,
        [1, 2, 3, 6].map((m) => m * _msPerMonth).toList(),
      );
    } else {
      return _findNiceInterval(
        roughInterval,
        [1, 2, 5, 10].map((y) => y * _msPerYear).toList(),
      );
    }
  }

  double _findNiceInterval(double target, List<double> options) {
    return options.reduce((closest, current) {
      return (current - target).abs() < (closest - target).abs() ? current : closest;
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
  // LABEL GENERATION
  // ==========================================================================

  @override
  List<AxisLabel> generateLabels(AxisBounds bounds) {
    final labels = <AxisLabel>[];
    final format = _cachedFormat ?? _selectDateFormat(bounds.range);

    final labelCount = _calculateLabelCount(bounds);

    for (int i = 0; i < labelCount; i++) {
      final currentMs = bounds.min + (bounds.interval * i);

      if (currentMs > bounds.max + _epsilon) break;

      final date = DateTime.fromMillisecondsSinceEpoch(currentMs.toInt());
      final text = format.format(date);
      final position = _calculatePrecisePosition(currentMs, bounds);

      labels.add(AxisLabel(
        value: currentMs,
        text: text,
        position: position.clamp(0.0, 1.0),
      ));
    }

    _cachedLabels = labels;
    return labels;
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
    // If axis is not visible, return zero size
    if (!configuration.visible) {
      return Size.zero;
    }

    if (labels.isEmpty) return Size.zero;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double maxWidth = 0;
    double maxHeight = 0;

    final labelStyle =
        configuration.labelStyle ?? theme?.axisLabelStyle ?? const TextStyle(fontSize: 12);

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
        configuration.labelStyle ?? theme?.axisLabelStyle ?? const TextStyle(fontSize: 12);

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

        if (configuration.labelRotation != null && configuration.labelRotation!.abs() > 0) {
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
      ..color = configuration.majorGridColor ??
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
  }

  @override
  String toString() {
    return 'DateTimeAxisRenderer('
        'visible: ${configuration.visible}, '
        'isVertical: $isVertical, '
        'bounds: $_cachedBounds'
        ')';
  }
}

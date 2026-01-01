import 'dart:math';

import 'package:flutter/material.dart';
import '../configuration/fusion_axis_configuration.dart';
import '../core/enums/axis_position.dart';

/// Utility class for calculating dynamic chart margins based on axis labels.
///
/// This ensures:
/// 1. Y-axis labels fit within left/right margin
/// 2. X-axis labels fit within top/bottom margin
/// 3. First/last X-axis labels don't overflow horizontally
class FusionMarginCalculator {
  const FusionMarginCalculator._();

  /// Calculate optimal chart area margins based on data bounds and axis configuration.
  ///
  /// [enableAxis] - Whether axes are enabled
  /// [xAxis] - X-axis configuration (for label style, formatter, position)
  /// [yAxis] - Y-axis configuration (for label style, formatter, position)
  /// [minX], [maxX] - X-axis data bounds
  /// [minY], [maxY] - Y-axis data bounds
  static EdgeInsets calculate({
    required bool enableAxis,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
    FusionAxisConfiguration? xAxis,
    FusionAxisConfiguration? yAxis,
  }) {
    // If axes are disabled, use minimal margins
    if (!enableAxis) {
      return const EdgeInsets.all(4.0);
    }

    // Determine axis positions
    final yAxisPosition = yAxis?.position ?? AxisPosition.left;
    final xAxisPosition = xAxis?.position ?? AxisPosition.bottom;

    // Calculate Y-axis label metrics
    final yLabelMetrics = _calculateYAxisLabelMetrics(
      minY: minY,
      maxY: maxY,
      yAxis: yAxis,
    );
    // Margin = label width + tick length (5) + small gap (2)
    final yAxisMargin = yLabelMetrics.maxWidth + 7;

    // Calculate X-axis label metrics (height + first/last label overflow)
    final xLabelMetrics = _calculateXAxisLabelMetrics(
      minX: minX,
      maxX: maxX,
      xAxis: xAxis,
    );
    // Margin = label height + tick length (5) + gap (7)
    final xAxisMargin = xLabelMetrics.maxHeight + 12;

    // Build margins based on axis positions
    double left = 4.0;
    double right = 4.0;
    double top = 4.0;
    double bottom = 4.0;

    // Y-axis margin goes on the side where Y-axis is positioned
    if (yAxisPosition == AxisPosition.left) {
      left = yAxisMargin;
    } else if (yAxisPosition == AxisPosition.right) {
      right = yAxisMargin;
    }

    // X-axis margin goes on the side where X-axis is positioned
    if (xAxisPosition == AxisPosition.bottom) {
      bottom = xAxisMargin;
    } else if (xAxisPosition == AxisPosition.top) {
      top = xAxisMargin;
    }

    // Add X-axis label overflow to left/right margins
    // First label's left half may extend beyond chart area
    // Last label's right half may extend beyond chart area
    final firstLabelOverflow = xLabelMetrics.firstLabelWidth / 2;
    final lastLabelOverflow = xLabelMetrics.lastLabelWidth / 2;

    // Only add overflow if it's larger than existing margin
    left = max(left, firstLabelOverflow + 2);
    right = max(right, lastLabelOverflow + 2);

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  /// Calculate Y-axis label metrics.
  static _AxisLabelMetrics _calculateYAxisLabelMetrics({
    required double minY,
    required double maxY,
    FusionAxisConfiguration? yAxis,
  }) {
    final range = maxY - minY;
    if (range <= 0) {
      return const _AxisLabelMetrics(
        maxWidth: 30.0,
        maxHeight: 14.0,
        firstLabelWidth: 30.0,
        lastLabelWidth: 30.0,
      );
    }

    // Get actual text style from configuration or use default
    final textStyle = yAxis?.labelStyle ?? const TextStyle(fontSize: 12);
    final labelFormatter = yAxis?.labelFormatter;
    final useAbbreviation = yAxis?.useAbbreviation ?? true;

    // Calculate nice interval
    final interval = _calculateNiceInterval(
      range,
      yAxis?.desiredTickCount ?? 5,
    );
    final decimalPlaces = _getDecimalPlaces(interval);

    // Generate all possible label values
    final labelValues = <double>[];
    double current = (minY / interval).floor() * interval;
    while (current <= maxY + interval * 0.01) {
      if (current >= minY - interval * 0.01) {
        labelValues.add(current);
      }
      current += interval;
      if (labelValues.length > 20) break;
    }

    // Measure each label
    double maxWidth = 0;
    double maxHeight = 0;
    for (final value in labelValues) {
      final labelText = _formatLabelValue(
        value: value,
        decimalPlaces: decimalPlaces,
        formatter: labelFormatter,
        useAbbreviation: useAbbreviation,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.width > maxWidth) maxWidth = textPainter.width;
      if (textPainter.height > maxHeight) maxHeight = textPainter.height;
    }

    return _AxisLabelMetrics(
      maxWidth: maxWidth.clamp(20.0, 100.0),
      maxHeight: maxHeight.clamp(10.0, 30.0),
      firstLabelWidth: maxWidth,
      lastLabelWidth: maxWidth,
    );
  }

  /// Calculate X-axis label metrics including first/last label widths for overflow.
  static _AxisLabelMetrics _calculateXAxisLabelMetrics({
    required double minX,
    required double maxX,
    FusionAxisConfiguration? xAxis,
  }) {
    final range = maxX - minX;
    if (range <= 0) {
      return const _AxisLabelMetrics(
        maxWidth: 30.0,
        maxHeight: 14.0,
        firstLabelWidth: 30.0,
        lastLabelWidth: 30.0,
      );
    }

    // Get actual text style from configuration or use default
    final textStyle = xAxis?.labelStyle ?? const TextStyle(fontSize: 12);
    final labelFormatter = xAxis?.labelFormatter;
    final useAbbreviation = xAxis?.useAbbreviation ?? true;

    // Calculate nice interval
    final interval = _calculateNiceInterval(
      range,
      xAxis?.desiredTickCount ?? 5,
    );
    final decimalPlaces = _getDecimalPlaces(interval);

    // Generate all possible label values
    final labelValues = <double>[];
    double current = (minX / interval).floor() * interval;
    while (current <= maxX + interval * 0.01) {
      if (current >= minX - interval * 0.01) {
        labelValues.add(current);
      }
      current += interval;
      if (labelValues.length > 20) break;
    }

    if (labelValues.isEmpty) {
      return const _AxisLabelMetrics(
        maxWidth: 30.0,
        maxHeight: 14.0,
        firstLabelWidth: 30.0,
        lastLabelWidth: 30.0,
      );
    }

    // Measure each label
    double maxWidth = 0;
    double maxHeight = 0;
    double firstLabelWidth = 0;
    double lastLabelWidth = 0;

    for (int i = 0; i < labelValues.length; i++) {
      final value = labelValues[i];
      final labelText = _formatLabelValue(
        value: value,
        decimalPlaces: decimalPlaces,
        formatter: labelFormatter,
        useAbbreviation: useAbbreviation,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.width > maxWidth) maxWidth = textPainter.width;
      if (textPainter.height > maxHeight) maxHeight = textPainter.height;

      // Track first and last label widths
      if (i == 0) firstLabelWidth = textPainter.width;
      if (i == labelValues.length - 1) lastLabelWidth = textPainter.width;
    }

    return _AxisLabelMetrics(
      maxWidth: maxWidth.clamp(20.0, 150.0),
      maxHeight: maxHeight.clamp(10.0, 30.0),
      firstLabelWidth: firstLabelWidth,
      lastLabelWidth: lastLabelWidth,
    );
  }

  /// Calculate a nice interval for the given range.
  static double _calculateNiceInterval(double range, int desiredTicks) {
    if (range <= 0) return 1.0;

    final roughInterval = range / desiredTicks;
    final magnitude = _calculateMagnitude(roughInterval);
    final normalized = roughInterval / magnitude;

    double niceFraction;
    if (normalized < 1.5) {
      niceFraction = 1.0;
    } else if (normalized < 3.0) {
      niceFraction = 2.0;
    } else if (normalized < 7.0) {
      niceFraction = 5.0;
    } else {
      niceFraction = 10.0;
    }

    return niceFraction * magnitude;
  }

  /// Calculate the magnitude (power of 10) for a value.
  static double _calculateMagnitude(double value) {
    if (value == 0) return 1.0;
    final absValue = value.abs();
    final exp = (log(absValue) / ln10).floor();
    return pow(10.0, exp).toDouble();
  }

  /// Get appropriate decimal places for an interval.
  static int _getDecimalPlaces(double interval) {
    if (interval >= 1) return 0;
    if (interval >= 0.1) return 1;
    if (interval >= 0.01) return 2;
    return 3;
  }

  /// Format a label value using formatter, abbreviation, or default formatting.
  static String _formatLabelValue({
    required double value,
    required int decimalPlaces,
    required bool useAbbreviation,
    String Function(double)? formatter,
  }) {
    // Custom formatter takes priority
    if (formatter != null) {
      return formatter(value);
    }

    // Use abbreviation for large numbers
    if (useAbbreviation) {
      final absValue = value.abs();
      if (absValue >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B';
      } else if (absValue >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (absValue >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
    }

    // Default formatting
    if (decimalPlaces == 0) {
      return value.round().toString();
    }
    return value.toStringAsFixed(decimalPlaces);
  }
}

/// Helper class to hold axis label measurements.
class _AxisLabelMetrics {
  const _AxisLabelMetrics({
    required this.maxWidth,
    required this.maxHeight,
    required this.firstLabelWidth,
    required this.lastLabelWidth,
  });

  /// Maximum width of any label (used for Y-axis margin).
  final double maxWidth;

  /// Maximum height of any label (used for X-axis margin).
  final double maxHeight;

  /// Width of the first label (for left overflow calculation).
  final double firstLabelWidth;

  /// Width of the last label (for right overflow calculation).
  final double lastLabelWidth;
}

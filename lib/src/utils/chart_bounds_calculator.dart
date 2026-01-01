// lib/src/utils/chart_bounds_calculator.dart

import '../configuration/fusion_axis_configuration.dart';
import 'axis_calculator.dart';

/// Centralized bounds calculation for all chart types.
///
/// Provides a single source of truth for calculating nice axis bounds
/// that align with axis labels across all chart types.
///
/// ## Usage
///
/// ```dart
/// // For bar charts (start from zero)
/// final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
///   dataMinY: 0,
///   dataMaxY: 95,
///   yAxisConfig: widget.yAxis,
///   startFromZero: true,
/// );
///
/// // For line charts (use data range)
/// final yBounds = ChartBoundsCalculator.calculateNiceYBounds(
///   dataMinY: 10,
///   dataMaxY: 95,
///   yAxisConfig: widget.yAxis,
/// );
///
/// // For X-axis (continuous data)
/// final xBounds = ChartBoundsCalculator.calculateNiceXBounds(
///   dataMinX: 0,
///   dataMaxX: 100,
///   xAxisConfig: widget.xAxis,
/// );
/// ```
class ChartBoundsCalculator {
  const ChartBoundsCalculator._();

  // ==========================================================================
  // Y-AXIS BOUNDS (Value Axis)
  // ==========================================================================

  /// Calculates nice Y-axis bounds that align with axis labels.
  ///
  /// [dataMinY] - Minimum Y value from data points
  /// [dataMaxY] - Maximum Y value from data points
  /// [yAxisConfig] - Optional Y-axis configuration
  /// [startFromZero] - If true, Y-axis starts from 0 when all data is positive
  ///                   (typical for bar charts). Default: false
  ///
  /// Returns a record with `minY` and `maxY` values that:
  /// - Are rounded to nice interval boundaries
  /// - Have adequate headroom above data max
  /// - Respect explicit min/max from configuration
  static ({double minY, double maxY}) calculateNiceYBounds({
    required double dataMinY,
    required double dataMaxY,
    FusionAxisConfiguration? yAxisConfig,
    bool startFromZero = false,
  }) {
    final config = yAxisConfig ?? const FusionAxisConfiguration();

    // Use explicit bounds from configuration if both are provided
    if (config.min != null && config.max != null) {
      return (minY: config.min!, maxY: config.max!);
    }

    // Determine effective min based on data and startFromZero flag
    double effectiveMinY;
    if (config.min != null) {
      effectiveMinY = config.min!;
    } else if (startFromZero && dataMinY >= 0) {
      effectiveMinY = 0.0;
    } else if (dataMinY >= 0) {
      // Common UX pattern: start from 0 for positive data
      effectiveMinY = 0.0;
    } else {
      effectiveMinY = dataMinY;
    }

    final effectiveMaxY = config.max ?? dataMaxY;

    // Calculate nice interval
    final yInterval = config.interval ??
        AxisCalculator.calculateNiceInterval(
          effectiveMinY,
          effectiveMaxY,
          config.desiredIntervals,
        );

    // Round to nice bounds
    final minY = config.min ?? _roundDownToInterval(effectiveMinY, yInterval);
    var maxY = config.max ?? _roundUpToInterval(effectiveMaxY, yInterval);

    // Ensure adequate headroom: if data max is too close to axis max,
    // add one more interval to prevent cramped appearance
    final headroom = maxY - dataMaxY;
    if (headroom < yInterval * 0.15 && config.max == null) {
      maxY += yInterval;
    }

    return (minY: minY, maxY: maxY);
  }

  // ==========================================================================
  // X-AXIS BOUNDS (Domain Axis - Continuous)
  // ==========================================================================

  /// Calculates nice X-axis bounds for continuous (numeric) axes.
  ///
  /// Unlike Y-axis, X-axis typically uses exact data bounds without
  /// extra padding, as users expect data points to span the full width.
  ///
  /// [dataMinX] - Minimum X value from data points
  /// [dataMaxX] - Maximum X value from data points
  /// [xAxisConfig] - Optional X-axis configuration
  /// [useNiceBounds] - If true, rounds to nice interval boundaries.
  ///                   Default: false (use exact data bounds)
  ///
  /// Returns a record with `minX` and `maxX` values.
  static ({double minX, double maxX}) calculateNiceXBounds({
    required double dataMinX,
    required double dataMaxX,
    FusionAxisConfiguration? xAxisConfig,
    bool useNiceBounds = false,
  }) {
    final config = xAxisConfig ?? const FusionAxisConfiguration();

    // Use explicit bounds from configuration if provided
    if (config.min != null && config.max != null) {
      return (minX: config.min!, maxX: config.max!);
    }

    // For X-axis, default to exact data bounds
    if (!useNiceBounds) {
      return (
        minX: config.min ?? dataMinX,
        maxX: config.max ?? dataMaxX,
      );
    }

    // If nice bounds requested, calculate similar to Y-axis
    final effectiveMinX = config.min ?? dataMinX;
    final effectiveMaxX = config.max ?? dataMaxX;

    final xInterval = config.interval ??
        AxisCalculator.calculateNiceInterval(
          effectiveMinX,
          effectiveMaxX,
          config.desiredIntervals,
        );

    final minX = config.min ?? _roundDownToInterval(effectiveMinX, xInterval);
    final maxX = config.max ?? _roundUpToInterval(effectiveMaxX, xInterval);

    return (minX: minX, maxX: maxX);
  }

  // ==========================================================================
  // CATEGORY AXIS BOUNDS (For Bar Charts)
  // ==========================================================================

  /// Calculates X-axis bounds for category (index-based) axes.
  ///
  /// For bar charts, X values represent category indices (0, 1, 2, ...),
  /// and bars are centered at each index. The bounds extend by 0.5 on
  /// each side to provide space for the first and last bars.
  ///
  /// [pointCount] - Number of data points (categories)
  ///
  /// Returns a record with `minX` = -0.5 and `maxX` = pointCount - 0.5
  static ({double minX, double maxX}) calculateCategoryXBounds({
    required int pointCount,
  }) {
    return (
      minX: -0.5,
      maxX: pointCount - 0.5,
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Rounds value down to nearest interval multiple.
  static double _roundDownToInterval(double value, double interval) {
    if (interval <= 0) return value;
    return (value / interval).floor() * interval;
  }

  /// Rounds value up to nearest interval multiple.
  static double _roundUpToInterval(double value, double interval) {
    if (interval <= 0) return value;
    return (value / interval).ceil() * interval;
  }
}

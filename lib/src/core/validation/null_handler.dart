import '../../data/fusion_data_point.dart';

/// Handles null and missing values in chart data.
///
/// Provides various strategies for dealing with null/missing data:
/// - Skip (remove nulls)
/// - Zero (replace with 0)
/// - Average (replace with average)
/// - Interpolate (linear interpolation)
/// - Forward fill (use previous value)
/// - Backward fill (use next value)
///
/// ## Example:
///
/// ```dart
/// final handler = NullHandler(strategy: NullStrategy.interpolate);
/// final cleanData = handler.handle(dataWithNulls);
/// ```
class NullHandler {
  /// Creates a null handler with specified strategy.
  NullHandler({
    this.strategy = NullStrategy.skip,
    this.defaultValue = 0,
    this.treatZeroAsNull = false,
  });

  /// Strategy for handling nulls.
  final NullStrategy strategy;

  /// Default value to use when replacing nulls.
  final double defaultValue;

  /// Whether to treat zero values as nulls.
  final bool treatZeroAsNull;

  /// Handles null values in a dataset.
  List<FusionDataPoint> handle(List<FusionDataPoint?> data) {
    // First pass: identify null positions
    final nullIndices = <int>{};
    final nonNullData = <FusionDataPoint>[];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      if (point == null ||
          point.x.isNaN ||
          point.y.isNaN ||
          (treatZeroAsNull && (point.x == 0 || point.y == 0))) {
        nullIndices.add(i);
      } else {
        nonNullData.add(point);
      }
    }

    // If no nulls, return original data
    if (nullIndices.isEmpty) {
      return nonNullData;
    }

    // Apply strategy
    switch (strategy) {
      case NullStrategy.skip:
        return _skipNulls(data);

      case NullStrategy.zero:
        return _replaceWithZero(data);

      case NullStrategy.defaultValue:
        return _replaceWithDefault(data);

      case NullStrategy.average:
        return _replaceWithAverage(data, nonNullData);

      case NullStrategy.interpolate:
        return _interpolateNulls(data);

      case NullStrategy.forwardFill:
        return _forwardFill(data);

      case NullStrategy.backwardFill:
        return _backwardFill(data);

      case NullStrategy.nearest:
        return _nearestFill(data);
    }
  }

  /// Skip null values (remove them).
  List<FusionDataPoint> _skipNulls(List<FusionDataPoint?> data) {
    return data
        .where(
          (point) =>
              point != null &&
              !point.x.isNaN &&
              !point.y.isNaN &&
              (!treatZeroAsNull || (point.x != 0 && point.y != 0)),
        )
        .map((point) => point!)
        .toList();
  }

  /// Replace nulls with zero.
  List<FusionDataPoint> _replaceWithZero(List<FusionDataPoint?> data) {
    final result = <FusionDataPoint>[];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      if (point == null || point.y.isNaN) {
        // Preserve X position if possible
        final x = point?.x ?? i.toDouble();
        result.add(FusionDataPoint(x, 0, label: 'Zero-filled'));
      } else {
        result.add(point);
      }
    }

    return result;
  }

  /// Replace nulls with default value.
  List<FusionDataPoint> _replaceWithDefault(List<FusionDataPoint?> data) {
    final result = <FusionDataPoint>[];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      if (point == null || point.y.isNaN) {
        final x = point?.x ?? i.toDouble();
        result.add(FusionDataPoint(x, defaultValue, label: 'Default-filled'));
      } else {
        result.add(point);
      }
    }

    return result;
  }

  /// Replace nulls with average of non-null values.
  List<FusionDataPoint> _replaceWithAverage(
    List<FusionDataPoint?> data,
    List<FusionDataPoint> nonNullData,
  ) {
    if (nonNullData.isEmpty) {
      return _replaceWithDefault(data);
    }

    // Calculate average
    double sum = 0;
    for (final point in nonNullData) {
      sum += point.y;
    }
    final average = sum / nonNullData.length;

    // Replace nulls with average
    final result = <FusionDataPoint>[];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      if (point == null || point.y.isNaN) {
        final x = point?.x ?? i.toDouble();
        result.add(FusionDataPoint(x, average, label: 'Average-filled'));
      } else {
        result.add(point);
      }
    }

    return result;
  }

  /// Interpolate null values using linear interpolation.
  List<FusionDataPoint> _interpolateNulls(List<FusionDataPoint?> data) {
    final result = <FusionDataPoint>[];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      if (point == null || point.y.isNaN) {
        // Find previous non-null
        FusionDataPoint? prev;
        for (int j = i - 1; j >= 0; j--) {
          if (data[j] != null && !data[j]!.y.isNaN) {
            prev = data[j];
            break;
          }
        }

        // Find next non-null
        FusionDataPoint? next;
        for (int j = i + 1; j < data.length; j++) {
          if (data[j] != null && !data[j]!.y.isNaN) {
            next = data[j];
            break;
          }
        }

        // Interpolate
        if (prev != null && next != null) {
          // Linear interpolation
          final t =
              (i - data.indexOf(prev)) /
              (data.indexOf(next) - data.indexOf(prev));
          final interpolatedY = prev.y + (next.y - prev.y) * t;
          final x = point?.x ?? (prev.x + (next.x - prev.x) * t);

          result.add(FusionDataPoint(x, interpolatedY, label: 'Interpolated'));
        } else if (prev != null) {
          // Use previous value
          final x = point?.x ?? i.toDouble();
          result.add(FusionDataPoint(x, prev.y, label: 'Forward-filled'));
        } else if (next != null) {
          // Use next value
          final x = point?.x ?? i.toDouble();
          result.add(FusionDataPoint(x, next.y, label: 'Backward-filled'));
        } else {
          // No non-null values, use default
          final x = point?.x ?? i.toDouble();
          result.add(FusionDataPoint(x, defaultValue, label: 'Default-filled'));
        }
      } else {
        result.add(point);
      }
    }

    return result;
  }

  /// Forward fill (use previous non-null value).
  List<FusionDataPoint> _forwardFill(List<FusionDataPoint?> data) {
    final result = <FusionDataPoint>[];
    FusionDataPoint? lastValid;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      if (point != null && !point.y.isNaN) {
        lastValid = point;
        result.add(point);
      } else if (lastValid != null) {
        final x = point?.x ?? i.toDouble();
        result.add(FusionDataPoint(x, lastValid.y, label: 'Forward-filled'));
      } else {
        // No previous value, use default
        final x = point?.x ?? i.toDouble();
        result.add(FusionDataPoint(x, defaultValue, label: 'Default-filled'));
      }
    }

    return result;
  }

  /// Backward fill (use next non-null value).
  List<FusionDataPoint> _backwardFill(List<FusionDataPoint?> data) {
    final result = List<FusionDataPoint>.filled(
      data.length,
      FusionDataPoint(0, defaultValue),
    );
    FusionDataPoint? nextValid;

    // Process in reverse
    for (int i = data.length - 1; i >= 0; i--) {
      final point = data[i];

      if (point != null && !point.y.isNaN) {
        nextValid = point;
        result[i] = point;
      } else if (nextValid != null) {
        final x = point?.x ?? i.toDouble();
        result[i] = FusionDataPoint(x, nextValid.y, label: 'Backward-filled');
      } else {
        // No next value, use default
        final x = point?.x ?? i.toDouble();
        result[i] = FusionDataPoint(x, defaultValue, label: 'Default-filled');
      }
    }

    return result;
  }

  /// Use nearest non-null value.
  List<FusionDataPoint> _nearestFill(List<FusionDataPoint?> data) {
    final result = <FusionDataPoint>[];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      if (point == null || point.y.isNaN) {
        // Find nearest non-null
        FusionDataPoint? nearest;
        int minDistance = data.length;

        for (int j = 0; j < data.length; j++) {
          if (data[j] != null && !data[j]!.y.isNaN) {
            final distance = (i - j).abs();
            if (distance < minDistance) {
              minDistance = distance;
              nearest = data[j];
            }
          }
        }

        if (nearest != null) {
          final x = point?.x ?? i.toDouble();
          result.add(FusionDataPoint(x, nearest.y, label: 'Nearest-filled'));
        } else {
          final x = point?.x ?? i.toDouble();
          result.add(FusionDataPoint(x, defaultValue, label: 'Default-filled'));
        }
      } else {
        result.add(point);
      }
    }

    return result;
  }
}

/// Strategy for handling null values.
enum NullStrategy {
  /// Skip null values (remove them).
  skip,

  /// Replace nulls with zero.
  zero,

  /// Replace nulls with a default value.
  defaultValue,

  /// Replace nulls with average of non-null values.
  average,

  /// Interpolate nulls using linear interpolation.
  interpolate,

  /// Forward fill (use previous non-null value).
  forwardFill,

  /// Backward fill (use next non-null value).
  backwardFill,

  /// Use nearest non-null value.
  nearest,
}

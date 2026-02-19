import '../data/fusion_data_point.dart';
import 'retention_policy.dart';

/// Downsampling utilities for reducing data point density while preserving
/// visual characteristics.
class Downsampler {
  Downsampler._();

  /// Downsample a list of data points to the target count using the specified method.
  ///
  /// Returns a new list with at most [targetCount] points.
  /// If [data] has fewer or equal points, returns it unchanged.
  ///
  /// Points are assumed to be sorted by x-coordinate.
  static List<FusionDataPoint> downsample(
    List<FusionDataPoint> data, {
    required int targetCount,
    required DownsampleMethod method,
  }) {
    if (data.length <= targetCount) return data;
    if (targetCount <= 2) {
      return targetCount == 2
          ? [data.first, data.last]
          : (targetCount == 1 ? [data.last] : []);
    }

    return switch (method) {
      DownsampleMethod.lttb => _downsampleLTTB(data, targetCount),
      DownsampleMethod.first => _downsampleFirst(data, targetCount),
      DownsampleMethod.last => _downsampleLast(data, targetCount),
      DownsampleMethod.average => _downsampleAverage(data, targetCount),
      DownsampleMethod.minMax => _downsampleMinMax(data, targetCount),
    };
  }

  /// Largest Triangle Three Buckets (LTTB) algorithm.
  ///
  /// This algorithm preserves the visual shape of the data by selecting points
  /// that form the largest triangles when connected. It produces visually
  /// excellent results for time series data.
  ///
  /// Algorithm:
  /// 1. Keep first and last points
  /// 2. Divide remaining points into buckets
  /// 3. For each bucket, select the point that forms the largest triangle
  ///    with the previous selected point and the average of the next bucket
  ///
  /// Reference: Sveinn Steinarsson, "Downsampling Time Series for Visual
  /// Representation" (2013)
  static List<FusionDataPoint> _downsampleLTTB(
    List<FusionDataPoint> data,
    int targetCount,
  ) {
    final result = <FusionDataPoint>[];

    // Always keep first point
    result.add(data.first);

    // Calculate bucket size
    final bucketSize = (data.length - 2) / (targetCount - 2);

    var prevSelectedIndex = 0;
    var nextBucketStart = 1.0 + bucketSize;

    for (var i = 0; i < targetCount - 2; i++) {
      // Calculate the bucket boundaries
      final currentBucketStart = (1 + i * bucketSize).floor();
      final currentBucketEnd = (1 + (i + 1) * bucketSize).floor().clamp(
        0,
        data.length - 1,
      );

      // Calculate the average of the next bucket (used as reference)
      final nextBucketEnd = (nextBucketStart + bucketSize).floor().clamp(
        0,
        data.length - 1,
      );

      var avgX = 0.0;
      var avgY = 0.0;
      var avgCount = 0;

      // If this is the last bucket before the end, use the last point as average
      if (i == targetCount - 3) {
        avgX = data.last.x;
        avgY = data.last.y;
        avgCount = 1;
      } else {
        for (
          var j = currentBucketEnd;
          j < nextBucketEnd && j < data.length;
          j++
        ) {
          avgX += data[j].x;
          avgY += data[j].y;
          avgCount++;
        }
        if (avgCount > 0) {
          avgX /= avgCount;
          avgY /= avgCount;
        }
      }

      // Find the point in current bucket that forms the largest triangle
      final prevPoint = data[prevSelectedIndex];
      var maxArea = -1.0;
      var selectedIndex = currentBucketStart;

      for (
        var j = currentBucketStart;
        j < currentBucketEnd && j < data.length;
        j++
      ) {
        final point = data[j];

        // Calculate triangle area using the cross product formula
        // Area = |x1(y2-y3) + x2(y3-y1) + x3(y1-y2)| / 2
        final area =
            ((prevPoint.x - avgX) * (point.y - prevPoint.y) -
                    (prevPoint.x - point.x) * (avgY - prevPoint.y))
                .abs() /
            2;

        if (area > maxArea) {
          maxArea = area;
          selectedIndex = j;
        }
      }

      result.add(data[selectedIndex]);
      prevSelectedIndex = selectedIndex;
      nextBucketStart += bucketSize;
    }

    // Always keep last point
    result.add(data.last);

    return result;
  }

  /// Keep the first point from each bucket.
  static List<FusionDataPoint> _downsampleFirst(
    List<FusionDataPoint> data,
    int targetCount,
  ) {
    final result = <FusionDataPoint>[];
    final bucketSize = data.length / targetCount;

    for (var i = 0; i < targetCount; i++) {
      final bucketStart = (i * bucketSize).floor();
      if (bucketStart < data.length) {
        result.add(data[bucketStart]);
      }
    }

    return result;
  }

  /// Keep the last point from each bucket.
  static List<FusionDataPoint> _downsampleLast(
    List<FusionDataPoint> data,
    int targetCount,
  ) {
    final result = <FusionDataPoint>[];
    final bucketSize = data.length / targetCount;

    for (var i = 0; i < targetCount; i++) {
      final bucketEnd = ((i + 1) * bucketSize - 1).floor();
      final index = bucketEnd.clamp(0, data.length - 1);
      result.add(data[index]);
    }

    return result;
  }

  /// Average all points in each bucket.
  static List<FusionDataPoint> _downsampleAverage(
    List<FusionDataPoint> data,
    int targetCount,
  ) {
    final result = <FusionDataPoint>[];
    final bucketSize = data.length / targetCount;

    for (var i = 0; i < targetCount; i++) {
      final bucketStart = (i * bucketSize).floor();
      final bucketEnd = ((i + 1) * bucketSize).floor().clamp(0, data.length);

      var sumX = 0.0;
      var sumY = 0.0;
      var count = 0;

      for (var j = bucketStart; j < bucketEnd; j++) {
        sumX += data[j].x;
        sumY += data[j].y;
        count++;
      }

      if (count > 0) {
        result.add(FusionDataPoint(sumX / count, sumY / count));
      }
    }

    return result;
  }

  /// Keep min and max points from each bucket.
  ///
  /// This results in up to 2x targetCount points, preserving peaks and valleys.
  /// Good for data where extremes are important.
  static List<FusionDataPoint> _downsampleMinMax(
    List<FusionDataPoint> data,
    int targetCount,
  ) {
    final result = <FusionDataPoint>[];
    // For min-max, we aim for targetCount/2 buckets, producing 2 points each
    final effectiveCount = (targetCount / 2).floor().clamp(1, data.length ~/ 2);
    final bucketSize = data.length / effectiveCount;

    for (var i = 0; i < effectiveCount; i++) {
      final bucketStart = (i * bucketSize).floor();
      final bucketEnd = ((i + 1) * bucketSize).floor().clamp(0, data.length);

      FusionDataPoint? minPoint;
      FusionDataPoint? maxPoint;

      for (var j = bucketStart; j < bucketEnd; j++) {
        final point = data[j];
        if (minPoint == null || point.y < minPoint.y) {
          minPoint = point;
        }
        if (maxPoint == null || point.y > maxPoint.y) {
          maxPoint = point;
        }
      }

      // Add points in chronological order
      if (minPoint != null && maxPoint != null) {
        if (minPoint.x <= maxPoint.x) {
          result.add(minPoint);
          if (minPoint != maxPoint) {
            result.add(maxPoint);
          }
        } else {
          result.add(maxPoint);
          if (minPoint != maxPoint) {
            result.add(minPoint);
          }
        }
      } else if (minPoint != null) {
        result.add(minPoint);
      }
    }

    return result;
  }
}

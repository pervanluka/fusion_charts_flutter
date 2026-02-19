/// How to handle multiple points with the same x-value (timestamp).
///
/// When a data point arrives with the same x-value as an existing point
/// in the buffer, this enum determines the behavior.
///
/// Example:
/// ```dart
/// controller.addPoint('s', FusionDataPoint(x: 100, y: 10));
/// controller.addPoint('s', FusionDataPoint(x: 100, y: 15)); // Same x!
/// ```
enum DuplicateTimestampBehavior {
  /// Replace existing point with new one (last write wins).
  ///
  /// Recommended for most cases. The latest value is typically
  /// the most relevant in real-time systems.
  ///
  /// Result: Single point at x=100 with y=15
  replace,

  /// Keep the original point, ignore duplicates.
  ///
  /// Use when you want to preserve the first reading and
  /// ignore subsequent updates at the same timestamp.
  ///
  /// Result: Single point at x=100 with y=10
  keepFirst,

  /// Keep both points.
  ///
  /// May cause visual artifacts at the same x-position.
  /// Use when you need to preserve all data points regardless
  /// of timestamp overlap.
  ///
  /// Result: Two points at x=100, one with y=10 and one with y=15
  keepBoth,

  /// Average the y-values of duplicate points.
  ///
  /// Useful for noisy sensors where you want smoothing.
  /// The resulting point has the same x-value and the average
  /// of all y-values seen at that timestamp.
  ///
  /// Result: Single point at x=100 with y=12.5 (average of 10 and 15)
  average,
}

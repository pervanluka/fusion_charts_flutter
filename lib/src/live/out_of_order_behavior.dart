/// How to handle data points that arrive out of chronological order.
///
/// Data points are expected to arrive with increasing x-values (timestamps).
/// When a point arrives with an x-value less than the previous point's x-value,
/// this enum determines the behavior.
///
/// Example:
/// ```dart
/// // Points arrive in order: (x=100, y=10), then (x=50, y=5)
/// // The second point is "out of order" because 50 < 100
/// ```
enum OutOfOrderBehavior {
  /// Accept all points regardless of order.
  ///
  /// May cause visual artifacts if rendering assumes sorted data.
  /// Use when:
  /// - Order doesn't matter for your use case
  /// - You're handling sorting elsewhere
  accept,

  /// Accept with debug warning.
  ///
  /// Recommended for most cases - handles network jitter gracefully
  /// while alerting developers to potential issues during development.
  ///
  /// In release builds, no warning is printed.
  acceptWithWarning,

  /// Reject out-of-order points.
  ///
  /// Use when data source guarantees ordering and out-of-order indicates
  /// a serious error that should not be silently ignored.
  ///
  /// The [FusionLiveChartController.addPoint] method returns false when
  /// a point is rejected.
  reject,

  /// Auto-sort buffer after insert.
  ///
  /// Performance cost O(n) but guarantees sorted output.
  /// Use only for low-frequency data (<10 Hz) where occasional
  /// out-of-order points are expected and must be displayed correctly.
  autoSort,
}

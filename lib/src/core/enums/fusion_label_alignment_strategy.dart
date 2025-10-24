enum FusionLabelAlignmentStrategy {
  /// Distribute labels evenly across data points.
  ///
  /// Best for: Most use cases.
  /// Result: Labels at positions 0, 30, 61, 91, ... (for 365 points, 12 labels)
  evenDistribution,

  /// Round label positions to "nice" numbers.
  ///
  /// Best for: When you want labels at round indices.
  /// Result: Labels at positions 0, 30, 60, 90, ... (multiples of 30)
  roundToNice,

  /// Align to start of natural periods.
  ///
  /// Best for: DateTime axes (start of month, week, etc.)
  /// Result: Labels at 1st day of each month
  ///
  /// **Now with smart period detection!**
  /// Automatically detects whether data is hourly, daily, weekly,
  /// monthly, quarterly, or yearly and adjusts accordingly.
  startOfPeriod,
}

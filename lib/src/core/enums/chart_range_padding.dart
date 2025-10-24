/// Defines how padding is applied to axis ranges.
///
/// Used by all axis types to add space around data for better visualization.
///
/// ## Example
///
/// ```dart
/// FusionNumericAxis(
///   rangePadding: ChartRangePadding.normal, // 5% padding on each side
/// )
/// ```
enum ChartRangePadding {
  /// Automatically determine padding based on data characteristics.
  ///
  /// Smart padding that adapts to your data range.
  auto,

  /// No padding applied.
  ///
  /// Data goes exactly from min to max.
  /// Use when you want precise control.
  none,

  /// Normal padding (5% on each side).
  ///
  /// Standard padding for most charts.
  /// Adds visual breathing room.
  normal,

  /// Round to nearest nice number.
  ///
  /// Example: If data is 3.7 to 47.3, round to 0 to 50.
  /// Creates cleaner axis bounds.
  round,

  /// Add one interval of padding on each side.
  ///
  /// Example: If interval is 10, add 10 on each side.
  /// Useful for discrete data.
  additional,
}

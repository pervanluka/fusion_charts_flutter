/// Display options for data labels on chart series.
///
/// Controls which data points show labels, allowing for cleaner charts
/// that highlight only the most important values.
///
/// ## Example
///
/// ```dart
/// FusionLineSeries(
///   name: 'Revenue',
///   dataPoints: data,
///   showDataLabels: true,
///   dataLabelDisplay: FusionDataLabelDisplay.maxAndMin, // Only extremes
/// )
/// ```
enum FusionDataLabelDisplay {
  /// Show labels for all data points (default).
  ///
  /// Can result in cluttered charts with many points.
  all,

  /// Show label only for the maximum value point.
  ///
  /// Highlights the peak value in the series.
  maxOnly,

  /// Show label only for the minimum value point.
  ///
  /// Highlights the lowest value in the series.
  minOnly,

  /// Show labels for both maximum and minimum points.
  ///
  /// Clean visualization showing the range extremes.
  /// Recommended for most use cases.
  ///
  /// ```
  ///     45 ← Max label
  ///    /  \
  ///   ●    ●    ●
  ///  /          \
  /// 20 ← Min label
  /// ```
  maxAndMin,

  /// Show labels for first and last data points only.
  ///
  /// Useful for showing start and end values in time series.
  firstAndLast,

  /// Don't show any data labels.
  ///
  /// Equivalent to setting `showDataLabels: false`.
  none,
}

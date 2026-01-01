/// Defines the type of data displayed on an axis.
///
/// Different axis types handle data differently:
/// - [numeric]: Continuous numeric values (e.g., 0, 1, 2, 3...)
/// - [category]: Discrete categorical labels (e.g., 'Jan', 'Feb', 'Mar')
/// - [datetime]: Date and time values with automatic formatting
///
/// ## Example
///
/// ```dart
/// // Numeric axis (default)
/// FusionAxisConfiguration(
///   type: FusionAxisType.numeric,
///   title: 'Value',
/// )
///
/// // Category axis for labels
/// FusionAxisConfiguration(
///   type: FusionAxisType.category,
///   categories: ['Q1', 'Q2', 'Q3', 'Q4'],
///   title: 'Quarter',
/// )
///
/// // DateTime axis for time series
/// FusionAxisConfiguration(
///   type: FusionAxisType.datetime,
///   title: 'Date',
/// )
/// ```
enum FusionAxisType {
  /// Numeric axis for continuous numerical data.
  ///
  /// Best for:
  /// - Measurements (temperature, price, count)
  /// - Continuous ranges
  /// - Scientific data
  ///
  /// The axis will automatically calculate nice intervals
  /// and format numbers appropriately.
  numeric,

  /// Category axis for discrete labeled data.
  ///
  /// Best for:
  /// - Named categories (products, countries, months)
  /// - Discrete groups
  /// - Qualitative data
  ///
  /// Requires `categories` list in [FusionAxisConfiguration].
  category,

  /// DateTime axis for time-based data.
  ///
  /// Best for:
  /// - Time series data
  /// - Historical trends
  /// - Date ranges
  ///
  /// The axis will automatically format dates based on
  /// the time range (days, months, years).
  datetime,
}

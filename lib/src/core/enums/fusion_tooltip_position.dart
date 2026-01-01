/// Position options for tooltip anchoring.
///
/// Controls where the tooltip is positioned relative to the chart area.
enum FusionTooltipPosition {
  /// Tooltip floats near the data point (default behavior).
  ///
  /// The tooltip is positioned above or below the data point,
  /// with smart collision detection to stay within chart bounds.
  floating,

  /// Tooltip anchored at the top of the chart area.
  ///
  /// A vertical trackball line connects the tooltip to the data point(s).
  /// Ideal for financial charts and time series where you don't want
  /// the tooltip to obscure the data.
  ///
  /// ```
  /// ┌───────────┐
  /// │ Value: 80 │  ← Fixed at top
  /// └─────┬─────┘
  ///       ┊ (trackball line)
  ///       ●
  /// ```
  top,

  /// Tooltip anchored at the bottom of the chart area.
  ///
  /// A vertical trackball line connects the tooltip to the data point(s).
  /// Useful when data tends to be at the top of the chart.
  ///
  /// ```
  ///       ●
  ///       ┊ (trackball line)
  /// ┌─────┴─────┐
  /// │ Value: 80 │  ← Fixed at bottom
  /// └───────────┘
  /// ```
  bottom,
}

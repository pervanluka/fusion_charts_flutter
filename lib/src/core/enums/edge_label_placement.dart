/// Controls how edge labels (first and last) are handled on chart axes.
///
/// When labels at the chart boundaries overflow the chart area, this
/// determines whether they are shifted inward, hidden, or left as-is.
///
/// ## Example
///
/// ```dart
/// FusionAxisConfiguration(
///   edgeLabelPlacement: EdgeLabelPlacement.shift,
/// )
/// ```
enum EdgeLabelPlacement {
  /// Labels render at their exact data position.
  /// The chart margin expands to fit overflow (default behavior).
  none,

  /// Edge labels are shifted inward so they don't overflow the chart area.
  /// The first label aligns to the left edge, the last to the right edge.
  shift,

  /// Edge labels that would overflow the chart area are hidden.
  hide,
}

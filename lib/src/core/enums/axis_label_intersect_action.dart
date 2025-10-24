/// Defines actions to take when axis labels intersect/overlap.
enum AxisLabelIntersectAction {
  /// Hide overlapping labels.
  hide,

  /// No action taken.
  none,

  /// Rotate labels by 45 degrees.
  rotate45,

  /// Rotate labels by 90 degrees.
  rotate90,

  /// Wrap text to multiple lines.
  wrap,

  /// Trim label text.
  trim,

  /// Automatically determine best action.
  auto,
}

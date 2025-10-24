/// Label alignment options for axis labels.
///
/// Determines how labels are positioned relative to their tick marks.
enum LabelAlignment {
  /// Align labels to the start (left for horizontal, top for vertical).
  ///
  /// Best for: Category axes where labels should start at tick position.
  start,

  /// Align labels to the center (default).
  ///
  /// Best for: Most numeric axes where labels should center on ticks.
  center,

  /// Align labels to the end (right for horizontal, bottom for vertical).
  ///
  /// Best for: Special cases where end alignment is needed.
  end,
}

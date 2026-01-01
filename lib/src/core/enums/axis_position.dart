/// Position of an axis relative to the chart area.
///
/// Used to control where axis lines and labels appear.
///
/// ## Examples
///
/// ```dart
/// // Y-axis on left (default)
/// FusionAxisConfiguration(
///   position: AxisPosition.left,
/// )
///
/// // Y-axis on right (for dual-axis charts)
/// FusionAxisConfiguration(
///   position: AxisPosition.right,
/// )
///
/// // X-axis on top (reversed chart)
/// FusionAxisConfiguration(
///   position: AxisPosition.top,
/// )
/// ```
enum AxisPosition {
  /// Left side of chart area (default for Y-axis).
  ///
  /// Axis line appears on the left edge.
  /// Labels appear to the left of the axis line.
  /// Ticks point left (outside chart area).
  left,

  /// Right side of chart area (for secondary Y-axis).
  ///
  /// Axis line appears on the right edge.
  /// Labels appear to the right of the axis line.
  /// Ticks point right (outside chart area).
  right,

  /// Top of chart area (for reversed X-axis).
  ///
  /// Axis line appears on the top edge.
  /// Labels appear above the axis line.
  /// Ticks point up (outside chart area).
  top,

  /// Bottom of chart area (default for X-axis).
  ///
  /// Axis line appears on the bottom edge.
  /// Labels appear below the axis line.
  /// Ticks point down (outside chart area).
  bottom;

  /// Whether this is a vertical position (left or right).
  bool get isVertical => this == left || this == right;

  /// Whether this is a horizontal position (top or bottom).
  bool get isHorizontal => this == top || this == bottom;

  /// Whether this is a default position.
  bool get isDefault => this == left || this == bottom;

  /// Gets the opposite position.
  ///
  /// - left ↔ right
  /// - top ↔ bottom
  AxisPosition get opposite {
    switch (this) {
      case AxisPosition.left:
        return AxisPosition.right;
      case AxisPosition.right:
        return AxisPosition.left;
      case AxisPosition.top:
        return AxisPosition.bottom;
      case AxisPosition.bottom:
        return AxisPosition.top;
    }
  }

  /// Gets default position for vertical axes.
  static AxisPosition get defaultVertical => AxisPosition.left;

  /// Gets default position for horizontal axes.
  static AxisPosition get defaultHorizontal => AxisPosition.bottom;
}

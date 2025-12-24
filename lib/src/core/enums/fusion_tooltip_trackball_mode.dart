/// Trackball modes for tooltip behavior during drag gestures.
///
/// Controls how the tooltip updates as the user drags across the chart.
enum FusionTooltipTrackballMode {
  /// No trackball - tooltip only appears on tap, doesn't follow drag.
  none,

  /// Tooltip follows finger and snaps to nearest point by Euclidean distance.
  ///
  /// Use for: scatter plots, bubble charts.
  follow,

  /// Snap to nearest data point by X-coordinate only.
  ///
  /// Use for: line charts, area charts, time series.
  /// This is the most common mode for line charts - as you drag
  /// horizontally, the tooltip jumps between points regardless of Y position.
  snapToX,

  /// Snap to nearest point only when within [trackballSnapRadius].
  ///
  /// When outside the radius, tooltip stays at last valid point.
  snap,

  /// Magnetic snap - smooth visual transition toward nearby points.
  ///
  /// Creates a "magnetic pull" effect where the marker moves
  /// smoothly toward data points as you get close.
  magnetic,

  /// Snap to nearest Y value at current X position.
  ///
  /// Use for: charts with multiple series where you want to
  /// compare Y values at the same X coordinate.
  snapToY,
}

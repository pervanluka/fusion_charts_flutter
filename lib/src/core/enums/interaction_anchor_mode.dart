/// Determines how interactive elements (crosshair, tooltip, data labels) are
/// anchored during chart interactions, especially in live/streaming charts.
///
/// This is particularly important for live charts where data is continuously
/// being added and the viewport is scrolling. When a user touches a data point,
/// this mode determines whether the interaction elements stay at the screen
/// position or follow the data point as it moves.
enum InteractionAnchorMode {
  /// Anchors interaction elements to the screen position.
  ///
  /// When the user touches the chart, the crosshair, tooltip, and data labels
  /// stay at the touched screen coordinates. As the chart scrolls (in live mode),
  /// different data points will pass under the interaction elements.
  ///
  /// This is the default behavior and works well for static charts or when
  /// users want to observe changing data at a fixed screen location.
  ///
  /// Example use case: Monitoring a live stock chart and wanting to see
  /// what values pass through a specific price level on screen.
  screenPosition,

  /// Anchors interaction elements to the data point coordinates.
  ///
  /// When the user touches a data point, the crosshair, tooltip, and data labels
  /// stay locked to that specific data point. As the chart scrolls (in live mode),
  /// the interaction elements move with the data point until it exits the viewport.
  ///
  /// This is ideal for live charts where users want to track a specific event
  /// or data point as new data arrives.
  ///
  /// Example use case: Touching a spike in a live sensor chart and watching
  /// that specific spike move left as new data comes in.
  ///
  /// When the anchored data point scrolls out of the visible area:
  /// - The interaction elements are automatically hidden
  /// - The user can touch again to anchor to a new point
  dataPoint,
}

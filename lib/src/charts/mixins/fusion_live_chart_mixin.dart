import 'package:flutter/material.dart';
import '../../data/fusion_data_point.dart';
import '../../rendering/fusion_coordinate_system.dart';

/// Mixin providing live chart functionality for streaming data visualization.
///
/// This mixin enables charts to:
/// - Track a "probe position" where interactions show data in live mode
/// - Update tooltips and crosshairs automatically as live data streams in
/// - Handle the distinction between live mode (X-only search) and static mode
///
/// ## Usage
///
/// Apply this mixin to any cartesian interactive state class:
///
/// ```dart
/// class MyChartInteractiveState extends FusionCartesianInteractiveStateBase<TooltipData>
///     with FusionLiveChartMixin<TooltipData> {
///
///   @override
///   bool get isLiveMode => true; // or from widget config
///
///   @override
///   FusionDataPoint? findPointAtScreenX(double screenX, {double? screenY}) {
///     // Implement chart-specific point finding
///   }
///
///   @override
///   void showLiveTooltipForPoint(FusionDataPoint point, double queryScreenX) {
///     // Implement chart-specific tooltip display
///   }
///
///   @override
///   void showLiveCrosshairForPoint(FusionDataPoint point, double queryScreenX) {
///     // Implement chart-specific crosshair display
///   }
/// }
/// ```
///
/// ## Probe Position
///
/// The probe position is a fixed screen coordinate where interactions should
/// display data. As live data streams in and the chart scrolls, the tooltip
/// and crosshair automatically update to show whatever data point is at the
/// probe position.
///
/// This is particularly useful for:
/// - Live streaming charts where data moves but interaction stays in place
/// - "dismissStrategy: never" tooltips/crosshairs that persist indefinitely
mixin FusionLiveChartMixin<TTooltipData> on ChangeNotifier {
  // ===========================================================================
  // PROBE POSITION STATE
  // ===========================================================================

  /// Fixed screen X position for live tooltip updates.
  ///
  /// When set, the tooltip will show data at this X position even as
  /// the chart scrolls with new data.
  double? _probeScreenX;

  /// Fixed screen Y position for multi-series selection.
  ///
  /// When multiple series have data at the same X, the Y position
  /// helps select the correct series (closest to where user tapped).
  double? _probeScreenY;

  /// The current probe X position, or null if not in probe mode.
  double? get probeScreenX => _probeScreenX;

  /// The current probe Y position, or null if not in probe mode.
  double? get probeScreenY => _probeScreenY;

  /// Whether probe mode is active.
  bool get isProbeActive => _probeScreenX != null;

  // ===========================================================================
  // ABSTRACT PROPERTIES - Implement in subclass
  // ===========================================================================

  /// Whether this chart is in live streaming mode.
  ///
  /// In live mode:
  /// - Tooltip finds nearest point by X only (vertical time slice)
  /// - Probe mode allows persistent tooltip at a fixed X position
  ///
  /// In static mode:
  /// - Tooltip finds nearest point by 2D distance (both X and Y)
  /// - Standard tooltip behavior
  bool get isLiveMode;

  /// The current coordinate system for bounds checking.
  FusionCoordinateSystem get currentCoordSystem;

  /// The current tooltip data, or null if no tooltip is shown.
  TTooltipData? get tooltipData;

  /// Whether the pointer is currently down (finger/mouse held).
  bool get isPointerDown;

  /// The last pointer position during interaction.
  Offset? get lastPointerPosition;

  /// The current crosshair position, or null if not shown.
  Offset? get crosshairPosition;

  /// The current crosshair data point, or null if not snapped to a point.
  FusionDataPoint? get crosshairPoint;

  /// Whether crosshair should snap to data points.
  bool get crosshairSnapToDataPoint;

  // ===========================================================================
  // ABSTRACT METHODS - Implement in subclass
  // ===========================================================================

  /// Finds the nearest data point at the given screen X position.
  ///
  /// This is the core method for live mode point finding. Unlike static mode
  /// which uses 2D distance, live mode finds points by X only (vertical slice).
  ///
  /// For multi-series charts, [screenY] helps select the correct series when
  /// multiple series have points at the same X coordinate.
  ///
  /// Returns null if no point is found or data is empty.
  FusionDataPoint? findPointAtScreenX(double screenX, {double? screenY});

  /// Shows the tooltip for a point found during live update.
  ///
  /// [point] is the data point to display in the tooltip.
  /// [queryScreenX] is the screen X position where the tooltip should appear.
  ///
  /// Implementations should:
  /// 1. Find the series info for the point
  /// 2. Calculate the tooltip screen position
  /// 3. Create and set the tooltip data
  void showLiveTooltipForPoint(FusionDataPoint point, double queryScreenX);

  /// Hides the tooltip.
  void hideTooltip();

  /// Shows the crosshair for a point found during live update.
  ///
  /// [point] is the data point to snap the crosshair to.
  /// [queryScreenX] is the screen X position where the crosshair should appear.
  ///
  /// Implementations should:
  /// 1. Calculate the crosshair screen position (snapped or at query position)
  /// 2. Update the crosshair position and point
  /// 3. Update any axis labels
  void showLiveCrosshairForPoint(FusionDataPoint point, double queryScreenX);

  /// Hides the crosshair.
  void hideCrosshair();

  // ===========================================================================
  // PROBE POSITION MANAGEMENT
  // ===========================================================================

  /// Sets the probe position for live tooltip tracking.
  ///
  /// When probe mode is active, the tooltip will show data at this fixed
  /// screen position even as the chart scrolls with new live data.
  ///
  /// Both X and Y are stored to maintain correct series selection in
  /// multi-series charts.
  void setProbePosition(Offset position) {
    _probeScreenX = position.dx;
    _probeScreenY = position.dy;
  }

  /// Sets only the probe X position.
  ///
  /// Use [setProbePosition] when you have both X and Y coordinates.
  set probeX(double x) => _probeScreenX = x;

  /// Sets only the probe Y position.
  set probeY(double y) => _probeScreenY = y;

  /// Clears the probe position, exiting probe mode.
  ///
  /// Call this when the tooltip is hidden or the user exits the chart area.
  void clearProbePosition() {
    _probeScreenX = null;
    _probeScreenY = null;
  }

  // ===========================================================================
  // LIVE TOOLTIP UPDATE
  // ===========================================================================

  /// Updates the tooltip when live data changes.
  ///
  /// Call this method after updating series data AND viewport to ensure
  /// the tooltip shows the current data at the probe/finger position.
  ///
  /// The tooltip will be updated if any of these conditions are true:
  /// 1. Probe mode is active (dismissStrategy: never)
  /// 2. Pointer is held down (user dragging)
  /// 3. A tooltip is visible (keeps it updated with fresh data)
  ///
  /// The tooltip will be hidden if the query position scrolls outside
  /// the visible chart area.
  void updateLiveTooltip() {
    // Only applies to live mode
    if (!isLiveMode) return;

    // Don't update tooltip while crosshair is active
    if (crosshairPosition != null) return;

    // No tooltip to update
    if (tooltipData == null) return;

    // Determine the screen X position to query (priority order)
    final double queryScreenX;

    if (_probeScreenX != null) {
      // 1. Probe mode: use fixed probe position
      queryScreenX = _probeScreenX!;
    } else if (isPointerDown && lastPointerPosition != null) {
      // 2. Pointer held down: use current finger position
      queryScreenX = lastPointerPosition!.dx;
    } else {
      // 3. Tooltip visible: use tooltip's current X position
      // This keeps the tooltip updated with live data at its position
      final tooltipPosition = _getTooltipScreenPosition();
      if (tooltipPosition == null) return;
      queryScreenX = tooltipPosition.dx;
    }

    // Check if query X is within chart area
    final chartArea = currentCoordSystem.chartArea;
    if (queryScreenX < chartArea.left || queryScreenX > chartArea.right) {
      // Position is outside visible area (scrolled off screen)
      // Hide tooltip cleanly to prevent visual drift
      clearProbePosition();
      hideTooltip();
      return;
    }

    // Find the nearest point at the query X position
    // Pass Y position to select correct series when multiple have same X
    final queryScreenY = _probeScreenY ?? lastPointerPosition?.dy;
    final nearestPoint = findPointAtScreenX(
      queryScreenX,
      screenY: queryScreenY,
    );

    if (nearestPoint != null) {
      showLiveTooltipForPoint(nearestPoint, queryScreenX);
    }
  }

  // ===========================================================================
  // LIVE CROSSHAIR UPDATE
  // ===========================================================================

  /// Updates the crosshair when live data changes.
  ///
  /// Call this method after updating series data AND viewport to ensure
  /// the crosshair shows the current data at the probe/finger position.
  ///
  /// The crosshair will be updated if any of these conditions are true:
  /// 1. Probe mode is active (dismissStrategy: never)
  /// 2. Pointer is held down (user dragging)
  /// 3. A crosshair is visible (keeps it updated with fresh data)
  ///
  /// The crosshair will be hidden if the query position scrolls outside
  /// the visible chart area.
  void updateLiveCrosshair() {
    // Only applies to live mode
    if (!isLiveMode) return;

    // No crosshair to update
    if (crosshairPosition == null) return;

    // Determine the screen X position to query (priority order)
    final double queryScreenX;

    if (_probeScreenX != null) {
      // 1. Probe mode: use fixed probe position
      queryScreenX = _probeScreenX!;
    } else if (isPointerDown && lastPointerPosition != null) {
      // 2. Pointer held down: use current finger position
      queryScreenX = lastPointerPosition!.dx;
    } else {
      // 3. Crosshair visible: use crosshair's current X position
      queryScreenX = crosshairPosition!.dx;
    }

    // Check if query X is within chart area
    final chartArea = currentCoordSystem.chartArea;
    if (queryScreenX < chartArea.left || queryScreenX > chartArea.right) {
      // Position is outside visible area (scrolled off screen)
      // Hide crosshair cleanly to prevent visual drift
      clearProbePosition();
      hideCrosshair();
      return;
    }

    // Find the nearest point at the query X position
    // Pass Y position to select correct series when multiple have same X
    final queryScreenY = _probeScreenY ?? lastPointerPosition?.dy;
    final nearestPoint = findPointAtScreenX(
      queryScreenX,
      screenY: queryScreenY,
    );

    if (nearestPoint != null) {
      showLiveCrosshairForPoint(nearestPoint, queryScreenX);
    }
  }

  // ===========================================================================
  // COMBINED LIVE INTERACTIONS UPDATE
  // ===========================================================================

  /// Updates all live interactions (tooltip and crosshair) when live data changes.
  ///
  /// This is a convenience method that calls both [updateLiveTooltip] and
  /// [updateLiveCrosshair]. Call this after updating series data to ensure
  /// all visible interactions show current data.
  ///
  /// Example:
  /// ```dart
  /// void onNewDataReceived(List<FusionDataPoint> newData) {
  ///   // Update series data
  ///   series = [updatedSeries];
  ///
  ///   // Update viewport if needed
  ///   updateCoordinateSystem(newCoordSystem);
  ///
  ///   // Refresh all live interactions
  ///   updateLiveInteractions();
  /// }
  /// ```
  void updateLiveInteractions() {
    if (!isLiveMode) return;

    updateLiveTooltip();
    updateLiveCrosshair();
  }

  /// Gets the screen position from the current tooltip data.
  ///
  /// Override this if your tooltip data stores position differently.
  Offset? _getTooltipScreenPosition() {
    final data = tooltipData;
    if (data == null) return null;

    // Try to access screenPosition via dynamic dispatch
    // This works because all tooltip data types have screenPosition
    try {
      return (data as dynamic).screenPosition as Offset?;
    } catch (_) {
      return null;
    }
  }
}

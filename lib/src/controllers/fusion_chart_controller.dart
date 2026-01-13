import 'package:flutter/foundation.dart';

import '../charts/base/fusion_interactive_state_base.dart';

/// Controller for programmatic control of Fusion Charts.
///
/// Provides methods to control zoom, pan, and reset operations on charts.
/// Similar to [ScrollController] or [TextEditingController] in Flutter.
///
/// ## Usage
///
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final _controller = FusionChartController();
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         Expanded(
///           child: FusionLineChart(
///             controller: _controller,
///             series: [...],
///           ),
///         ),
///         Row(
///           children: [
///             IconButton(
///               icon: Icon(Icons.zoom_in),
///               onPressed: _controller.zoomIn,
///             ),
///             IconButton(
///               icon: Icon(Icons.zoom_out),
///               onPressed: _controller.zoomOut,
///             ),
///             IconButton(
///               icon: Icon(Icons.refresh),
///               onPressed: _controller.resetZoom,
///             ),
///           ],
///         ),
///       ],
///     );
///   }
/// }
/// ```
class FusionChartController extends ChangeNotifier {
  FusionInteractiveStateBase? _interactiveState;

  /// Whether the controller is attached to a chart.
  bool get isAttached => _interactiveState != null;

  /// Current zoom level as a multiplier (1.0 = no zoom, 2.0 = 2x zoom, etc.).
  ///
  /// Note: Currently returns 1.0 as precise zoom level tracking would require
  /// storing original coordinate bounds. The [isZoomed] property can be used
  /// to check if the chart is currently zoomed.
  ///
  /// Returns 1.0 if not attached.
  double get zoomLevel {
    // Accurate zoom level tracking requires storing original coordinate bounds.
    return 1.0;
  }

  /// Whether the chart is currently zoomed (not at original bounds).
  bool get isZoomed => _interactiveState?.isInteracting ?? false;

  /// Attaches this controller to a chart's interactive state.
  ///
  /// This is called internally by the chart widget.
  /// Do not call this directly.
  void attach(FusionInteractiveStateBase state) {
    _interactiveState = state;
    notifyListeners();
  }

  /// Detaches this controller from its chart.
  ///
  /// This is called internally by the chart widget.
  /// Do not call this directly.
  void detach() {
    _interactiveState = null;
    notifyListeners();
  }

  /// Zooms in by a fixed factor (1.5x), centered on the chart.
  ///
  /// Does nothing if the controller is not attached to a chart.
  void zoomIn() {
    _interactiveState?.zoomIn();
  }

  /// Zooms out by a fixed factor (1.5x), centered on the chart.
  ///
  /// Does nothing if the controller is not attached to a chart.
  void zoomOut() {
    _interactiveState?.zoomOut();
  }

  /// Resets zoom and pan to original bounds with animation.
  ///
  /// Does nothing if the controller is not attached to a chart.
  void resetZoom() {
    _interactiveState?.reset();
  }

  /// Resets all interactions (zoom, pan, tooltips, crosshair).
  ///
  /// Does nothing if the controller is not attached to a chart.
  void reset() {
    _interactiveState?.reset();
  }

  @override
  void dispose() {
    _interactiveState = null;
    super.dispose();
  }
}

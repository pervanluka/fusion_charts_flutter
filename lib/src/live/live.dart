/// Live streaming and real-time data support for FusionCharts.
///
/// This module provides controllers and utilities for displaying
/// real-time data in charts with efficient buffering, retention
/// policies, and viewport management.
///
/// ## Basic Usage
///
/// ```dart
/// // Create a controller with retention policy
/// final controller = FusionLiveChartController(
///   retentionPolicy: RetentionPolicy.rollingCount(500),
/// );
///
/// // Add data from any source
/// websocket.onMessage((data) {
///   controller.addPoint('price', FusionDataPoint(now, data.price));
/// });
///
/// // Use with chart
/// FusionLineChart(
///   liveController: controller,
///   liveViewportMode: LiveViewportMode.autoScroll(
///     visibleDuration: Duration(minutes: 1),
///   ),
///   series: [FusionLineSeries(name: 'price')],
/// )
/// ```
library;

export 'downsampling.dart';
export 'duplicate_timestamp_behavior.dart';
export 'frame_coalescer.dart';
export 'fusion_live_chart_controller.dart';
export 'live_controller_statistics.dart';
export 'live_viewport_mode.dart';
export 'out_of_order_behavior.dart';
export 'retention_policy.dart';
export 'ring_buffer.dart';

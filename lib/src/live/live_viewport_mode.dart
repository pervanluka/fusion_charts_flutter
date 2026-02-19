import 'package:flutter/animation.dart';

/// Controls how the chart viewport behaves with live data.
///
/// Each mode defines a different strategy for updating the visible
/// portion of the chart as new data arrives.
///
/// Example:
/// ```dart
/// // Auto-scroll showing last 60 seconds
/// LiveViewportMode.autoScroll(
///   visibleDuration: Duration(seconds: 60),
///   leadingPadding: Duration(seconds: 5),
/// )
/// ```
sealed class LiveViewportMode {
  const LiveViewportMode();

  /// Viewport automatically scrolls to show latest data.
  ///
  /// [visibleDuration] - How much time range to show in viewport.
  /// [leadingPadding] - Empty space after latest point (anticipation space).
  /// [trailingPadding] - Empty space before oldest visible point.
  /// [animationCurve] - Curve for scroll animation.
  ///
  /// Example: Show last 60 seconds with 5 second padding:
  /// ```dart
  /// LiveViewportMode.autoScroll(
  ///   visibleDuration: Duration(seconds: 60),
  ///   leadingPadding: Duration(seconds: 5),
  /// )
  /// ```
  const factory LiveViewportMode.autoScroll({
    required Duration visibleDuration,
    Duration leadingPadding,
    Duration trailingPadding,
    Curve animationCurve,
  }) = AutoScrollViewport;

  /// Show a fixed number of points instead of duration.
  ///
  /// Useful when data arrives at variable rates.
  ///
  /// [visiblePoints] - Number of points to show in viewport.
  /// [leadingPoints] - Empty space after latest point (in point count).
  const factory LiveViewportMode.autoScrollPoints({
    required int visiblePoints,
    int leadingPoints,
    Curve animationCurve,
  }) = AutoScrollPointsViewport;

  /// Viewport is fixed. New data appears and may scroll out of view.
  ///
  /// User can manually pan/zoom.
  ///
  /// [initialRange] - Optional initial viewport range.
  /// If null, fits all data when first rendered.
  ///
  /// Useful when combined with controller.pause() for inspection.
  const factory LiveViewportMode.fixed({
    (double min, double max)? initialRange,
  }) = FixedViewport;

  /// Auto-scroll until user interacts (pan/zoom), then become fixed.
  ///
  /// Call controller.resume() to re-enable auto-scroll.
  ///
  /// [interactionTimeout] - If set, returns to auto-scroll after this duration
  /// of no interaction. If null, stays fixed until resume() is called.
  ///
  /// Best for: Monitoring that user may want to inspect.
  const factory LiveViewportMode.autoScrollUntilInteraction({
    required Duration visibleDuration,
    Duration leadingPadding,
    Duration? interactionTimeout,
    Curve animationCurve,
  }) = AutoScrollUntilInteractionViewport;

  /// Fill the viewport, expanding as needed up to max duration.
  ///
  /// Starts with whatever data is available, grows until maxDuration, then scrolls.
  ///
  /// Best for: Startup experience where you don't want empty space.
  const factory LiveViewportMode.fillThenScroll({
    required Duration maxDuration,
    Duration leadingPadding,
    Curve animationCurve,
  }) = FillThenScrollViewport;
}

/// Viewport automatically scrolls to show latest data (time-based).
class AutoScrollViewport extends LiveViewportMode {
  /// Creates an auto-scroll viewport mode.
  const AutoScrollViewport({
    required this.visibleDuration,
    this.leadingPadding = Duration.zero,
    this.trailingPadding = Duration.zero,
    this.animationCurve = Curves.linear,
  });

  /// How much time range to show in the viewport.
  final Duration visibleDuration;

  /// Empty space after the latest point (anticipation space).
  ///
  /// Creates room for new data to appear.
  final Duration leadingPadding;

  /// Empty space before the oldest visible point.
  final Duration trailingPadding;

  /// Animation curve for viewport transitions.
  final Curve animationCurve;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoScrollViewport &&
          runtimeType == other.runtimeType &&
          visibleDuration == other.visibleDuration &&
          leadingPadding == other.leadingPadding &&
          trailingPadding == other.trailingPadding &&
          animationCurve == other.animationCurve;

  @override
  int get hashCode => Object.hash(
    visibleDuration,
    leadingPadding,
    trailingPadding,
    animationCurve,
  );
}

/// Viewport automatically scrolls to show latest data (point-based).
class AutoScrollPointsViewport extends LiveViewportMode {
  /// Creates a point-count based auto-scroll viewport.
  const AutoScrollPointsViewport({
    required this.visiblePoints,
    this.leadingPoints = 0,
    this.animationCurve = Curves.linear,
  }) : assert(visiblePoints > 0, 'visiblePoints must be positive');

  /// Number of points to show in viewport.
  final int visiblePoints;

  /// Empty space after the latest point (in point count).
  final int leadingPoints;

  /// Animation curve for viewport transitions.
  final Curve animationCurve;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoScrollPointsViewport &&
          runtimeType == other.runtimeType &&
          visiblePoints == other.visiblePoints &&
          leadingPoints == other.leadingPoints &&
          animationCurve == other.animationCurve;

  @override
  int get hashCode => Object.hash(visiblePoints, leadingPoints, animationCurve);
}

/// Viewport is fixed and does not auto-scroll.
class FixedViewport extends LiveViewportMode {
  /// Creates a fixed viewport mode.
  const FixedViewport({this.initialRange});

  /// Optional initial viewport range (minX, maxX).
  ///
  /// If null, fits all data when first rendered.
  final (double min, double max)? initialRange;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedViewport &&
          runtimeType == other.runtimeType &&
          initialRange == other.initialRange;

  @override
  int get hashCode => initialRange.hashCode;
}

/// Auto-scroll until user interaction, then become fixed.
class AutoScrollUntilInteractionViewport extends LiveViewportMode {
  /// Creates an interaction-aware auto-scroll viewport.
  const AutoScrollUntilInteractionViewport({
    required this.visibleDuration,
    this.leadingPadding = Duration.zero,
    this.interactionTimeout,
    this.animationCurve = Curves.linear,
  });

  /// How much time range to show in the viewport.
  final Duration visibleDuration;

  /// Empty space after the latest point.
  final Duration leadingPadding;

  /// If set, returns to auto-scroll after this duration of no interaction.
  ///
  /// If null, stays fixed until resume() is called.
  final Duration? interactionTimeout;

  /// Animation curve for viewport transitions.
  final Curve animationCurve;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoScrollUntilInteractionViewport &&
          runtimeType == other.runtimeType &&
          visibleDuration == other.visibleDuration &&
          leadingPadding == other.leadingPadding &&
          interactionTimeout == other.interactionTimeout &&
          animationCurve == other.animationCurve;

  @override
  int get hashCode => Object.hash(
    visibleDuration,
    leadingPadding,
    interactionTimeout,
    animationCurve,
  );
}

/// Fill viewport up to max duration, then scroll.
class FillThenScrollViewport extends LiveViewportMode {
  /// Creates a fill-then-scroll viewport mode.
  const FillThenScrollViewport({
    required this.maxDuration,
    this.leadingPadding = Duration.zero,
    this.animationCurve = Curves.linear,
  });

  /// Maximum duration before scrolling begins.
  final Duration maxDuration;

  /// Empty space after the latest point.
  final Duration leadingPadding;

  /// Animation curve for viewport transitions.
  final Curve animationCurve;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FillThenScrollViewport &&
          runtimeType == other.runtimeType &&
          maxDuration == other.maxDuration &&
          leadingPadding == other.leadingPadding &&
          animationCurve == other.animationCurve;

  @override
  int get hashCode => Object.hash(maxDuration, leadingPadding, animationCurve);
}

import 'package:flutter/material.dart';
import '../core/enums/fusion_dismiss_strategy.dart';
import '../core/enums/fusion_tooltip_activation_mode.dart';
import '../core/enums/fusion_tooltip_position.dart';
import '../core/enums/fusion_tooltip_trackball_mode.dart';
import '../data/fusion_data_point.dart';

// ============================================================================
// 🏆 ENHANCED TOOLTIP BEHAVIOR
// ============================================================================

/// Tooltip behavior configuration for charts.
@immutable
class FusionTooltipBehavior {
  const FusionTooltipBehavior({
    // Basic configuration
    this.enable = true,

    // 🚀 POSITION CONTROL - NEW!
    this.position = FusionTooltipPosition.floating,
    this.showTrackballLine = true,
    this.trackballLineColor,
    this.trackballLineWidth = 1.0,
    this.trackballLineDashPattern,

    // 🚀 ACTIVATION CONTROL - Superior
    this.activationMode = FusionTooltipActivationMode.auto,
    this.activationDelay = Duration.zero,

    // 🚀 DISMISS CONTROL - Revolutionary!
    this.dismissStrategy = FusionDismissStrategy.onRelease,
    this.dismissDelay = const Duration(milliseconds: 300),
    this.duration = const Duration(milliseconds: 3000),

    // 🚀 TRACKBALL MODE - Enhanced
    this.trackballMode = FusionTooltipTrackballMode.none,
    this.trackballUpdateThreshold = 5.0,
    this.trackballSnapRadius = 20.0,

    // Animation
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.exitAnimationCurve = Curves.easeInCubic,

    // Appearance
    this.elevation = 2.5,
    this.canShowMarker = true,
    this.textAlignment = ChartAlignment.center,
    this.decimalPlaces = 2,
    this.shared = false,
    this.opacity = 0.9,
    this.borderWidth = 0,

    // Content
    this.format,
    this.builder,

    // Styling
    this.color,
    this.textStyle,
    this.borderColor,
    this.shadowColor,

    // Advanced
    this.hapticFeedback = true,
    this.fadeOutOnPanZoom = true,
  });

  // ========================================================================
  // CORE PROPERTIES
  // ========================================================================

  /// Enables or disables tooltip
  final bool enable;

  // ========================================================================
  // 🚀 POSITION CONTROL (NEW!)
  // ========================================================================

  /// Tooltip position relative to the chart area.
  ///
  /// - [FusionTooltipPosition.floating] (default) - Tooltip floats near data point
  /// - [FusionTooltipPosition.top] - Tooltip anchored at top with trackball line
  /// - [FusionTooltipPosition.bottom] - Tooltip anchored at bottom with trackball line
  ///
  /// Example:
  /// ```dart
  /// FusionTooltipBehavior(
  ///   position: FusionTooltipPosition.top,
  ///   trackballLineDashPattern: [4, 4], // Dashed line
  /// )
  /// ```
  final FusionTooltipPosition position;

  /// Whether to show the trackball line connecting tooltip to data point(s).
  ///
  /// Only applicable when [position] is [FusionTooltipPosition.top] or
  /// [FusionTooltipPosition.bottom]. The line will not be drawn if the
  /// data point is too close to the tooltip (to avoid visual clutter).
  ///
  /// Default: true
  final bool showTrackballLine;

  /// Color of the trackball line.
  ///
  /// If null, uses a semi-transparent version of the series color.
  final Color? trackballLineColor;

  /// Width of the trackball line in pixels.
  ///
  /// Default: 1.0
  final double trackballLineWidth;

  /// Dash pattern for the trackball line.
  ///
  /// - `null` - Solid line (default)
  /// - `[4, 4]` - Dashed line (4px dash, 4px gap)
  /// - `[2, 2]` - Dotted line
  /// - `[8, 4, 2, 4]` - Dash-dot pattern
  ///
  /// Example:
  /// ```dart
  /// FusionTooltipBehavior(
  ///   position: FusionTooltipPosition.top,
  ///   trackballLineDashPattern: [4, 4], // Dashed
  /// )
  /// ```
  final List<double>? trackballLineDashPattern;

  // ========================================================================
  // 🚀 ACTIVATION CONTROL
  // ========================================================================

  /// How to activate the tooltip
  ///
  /// **auto** (default) - Smart activation based on platform:
  /// - Mobile: singleTap
  /// - Desktop: hover
  final FusionTooltipActivationMode activationMode;

  /// Delay before showing tooltip after activation
  /// Useful for preventing accidental tooltips
  final Duration activationDelay;

  // ========================================================================
  // 🚀 DISMISS CONTROL (Revolutionary!)
  // ========================================================================

  /// Strategy for dismissing tooltip
  ///
  /// **onRelease** (default) - Best UX! Dismisses when finger lifts
  /// **onTimer** - Show for duration
  /// **onReleaseDelayed** - Brief delay after release
  /// **never** - Manual hide only
  /// **smart** - Adapts to interaction pattern
  final FusionDismissStrategy dismissStrategy;

  /// Additional delay before dismissing (only for onReleaseDelayed)
  final Duration dismissDelay;

  /// Duration to display tooltip (for onTimer strategy)
  final Duration duration;

  // ========================================================================
  // 🚀 TRACKBALL MODE
  // ========================================================================

  /// Trackball behavior
  ///
  /// **none** - No trackball (default)
  /// **follow** - Tooltip follows finger
  /// **snap** - Snaps to nearest point
  /// **magnetic** - Smooth magnetic snapping
  final FusionTooltipTrackballMode trackballMode;

  /// Minimum pixel movement to trigger trackball update
  /// Reduces update frequency for performance
  final double trackballUpdateThreshold;

  /// Radius for magnetic snapping in trackball mode
  final double trackballSnapRadius;

  // ========================================================================
  // ANIMATION PROPERTIES
  // ========================================================================

  /// Animation duration for show/hide
  final Duration animationDuration;

  /// Easing curve for enter animation
  final Curve animationCurve;

  /// Easing curve for exit animation
  final Curve exitAnimationCurve;

  // ========================================================================
  // APPEARANCE PROPERTIES
  // ========================================================================

  /// Elevation for tooltip shadow
  final double elevation;

  /// Show marker at data point
  final bool canShowMarker;

  /// Text alignment in tooltip
  final ChartAlignment textAlignment;

  /// Decimal places for values
  final int decimalPlaces;

  /// Show single tooltip for all series at x position
  final bool shared;

  /// Tooltip background opacity
  final double opacity;

  /// Border width
  final double borderWidth;

  // ========================================================================
  // CONTENT PROPERTIES
  // ========================================================================

  /// Custom format function
  final String Function(FusionDataPoint point, String seriesName)? format;

  /// Custom builder for complete tooltip
  final Widget Function(
    BuildContext context,
    FusionDataPoint point,
    String seriesName,
    Color seriesColor,
  )?
  builder;

  // ========================================================================
  // STYLING PROPERTIES
  // ========================================================================

  /// Tooltip background color
  final Color? color;

  /// Text style for tooltip
  final TextStyle? textStyle;

  /// Border color
  final Color? borderColor;

  /// Shadow color
  final Color? shadowColor;

  // ========================================================================
  // ADVANCED PROPERTIES
  // ========================================================================

  /// Provide haptic feedback on tooltip show
  final bool hapticFeedback;

  /// Fade out tooltip during pan/zoom gestures
  final bool fadeOutOnPanZoom;

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Get effective activation mode for current platform
  FusionTooltipActivationMode getEffectiveActivationMode(TargetPlatform platform) {
    if (activationMode != FusionTooltipActivationMode.auto) {
      return activationMode;
    }

    // Auto-detect based on platform
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return FusionTooltipActivationMode.singleTap;

      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return FusionTooltipActivationMode.hover;
    }
  }

  /// Should dismiss on pointer release?
  bool shouldDismissOnRelease() {
    return dismissStrategy == FusionDismissStrategy.onRelease ||
        dismissStrategy == FusionDismissStrategy.onReleaseDelayed ||
        dismissStrategy == FusionDismissStrategy.smart;
  }

  /// Should use timer for dismissal?
  bool shouldUseTimer() {
    return dismissStrategy == FusionDismissStrategy.onTimer ||
        dismissStrategy == FusionDismissStrategy.smart;
  }

  /// Get dismiss delay duration
  Duration getDismissDelay(bool wasLongPress) {
    switch (dismissStrategy) {
      case FusionDismissStrategy.onRelease:
        return Duration.zero;

      case FusionDismissStrategy.onReleaseDelayed:
        return dismissDelay;

      case FusionDismissStrategy.onTimer:
        return duration;

      case FusionDismissStrategy.never:
        return const Duration(days: 365); // Effectively never

      case FusionDismissStrategy.smart:
        // If it was a long press, keep it longer
        return wasLongPress ? duration : dismissDelay;
    }
  }

  // ========================================================================
  // COPY WITH
  // ========================================================================

  FusionTooltipBehavior copyWith({
    bool? enable,
    FusionTooltipPosition? position,
    bool? showTrackballLine,
    Color? trackballLineColor,
    double? trackballLineWidth,
    List<double>? trackballLineDashPattern,
    FusionTooltipActivationMode? activationMode,
    Duration? activationDelay,
    FusionDismissStrategy? dismissStrategy,
    Duration? dismissDelay,
    Duration? duration,
    FusionTooltipTrackballMode? trackballMode,
    double? trackballUpdateThreshold,
    double? trackballSnapRadius,
    Duration? animationDuration,
    Curve? animationCurve,
    Curve? exitAnimationCurve,
    double? elevation,
    bool? canShowMarker,
    ChartAlignment? textAlignment,
    int? decimalPlaces,
    bool? shared,
    double? opacity,
    double? borderWidth,
    String Function(FusionDataPoint, String)? format,
    Widget Function(BuildContext, FusionDataPoint, String, Color)? builder,
    Color? color,
    TextStyle? textStyle,
    Color? borderColor,
    Color? shadowColor,
    bool? hapticFeedback,
    bool? fadeOutOnPanZoom,
  }) {
    return FusionTooltipBehavior(
      enable: enable ?? this.enable,
      position: position ?? this.position,
      showTrackballLine: showTrackballLine ?? this.showTrackballLine,
      trackballLineColor: trackballLineColor ?? this.trackballLineColor,
      trackballLineWidth: trackballLineWidth ?? this.trackballLineWidth,
      trackballLineDashPattern: trackballLineDashPattern ?? this.trackballLineDashPattern,
      activationMode: activationMode ?? this.activationMode,
      activationDelay: activationDelay ?? this.activationDelay,
      dismissStrategy: dismissStrategy ?? this.dismissStrategy,
      dismissDelay: dismissDelay ?? this.dismissDelay,
      duration: duration ?? this.duration,
      trackballMode: trackballMode ?? this.trackballMode,
      trackballUpdateThreshold: trackballUpdateThreshold ?? this.trackballUpdateThreshold,
      trackballSnapRadius: trackballSnapRadius ?? this.trackballSnapRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      exitAnimationCurve: exitAnimationCurve ?? this.exitAnimationCurve,
      elevation: elevation ?? this.elevation,
      canShowMarker: canShowMarker ?? this.canShowMarker,
      textAlignment: textAlignment ?? this.textAlignment,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      shared: shared ?? this.shared,
      opacity: opacity ?? this.opacity,
      borderWidth: borderWidth ?? this.borderWidth,
      format: format ?? this.format,
      builder: builder ?? this.builder,
      color: color ?? this.color,
      textStyle: textStyle ?? this.textStyle,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      fadeOutOnPanZoom: fadeOutOnPanZoom ?? this.fadeOutOnPanZoom,
    );
  }
}

/// Alignment options for tooltip
enum ChartAlignment { near, center, far }

// ============================================================================
// BASE TOOLTIP DATA
// ============================================================================

/// Base class for all tooltip render data types.
///
/// This abstract class defines the common interface that all tooltip data
/// must implement, enabling polymorphic handling in the interactive state base.
///
/// ## Implementations
///
/// - [TooltipRenderData] - Single point tooltip (line/bar charts)
/// - [StackedTooltipData] - Multi-segment tooltip (stacked bar charts)
///
/// ## Usage
///
/// ```dart
/// // In interactive state base interface:
/// FusionTooltipDataBase? get tooltipData;
///
/// // Concrete implementations return their specific type:
/// TooltipRenderData? get tooltipData => _tooltipData;
/// StackedTooltipData? get tooltipData => _stackedTooltipData;
/// ```
abstract class FusionTooltipDataBase {
  /// Const constructor for subclasses.
  const FusionTooltipDataBase();

  /// Screen position where the tooltip should be rendered.
  ///
  /// This is typically the position of the data point or the center
  /// of the hovered element.
  Offset get screenPosition;
}

/// Single point tooltip render data (internal use)
class TooltipRenderData extends FusionTooltipDataBase {
  const TooltipRenderData({
    required this.point,
    required this.seriesName,
    required this.seriesColor,
    required this.screenPosition,
    this.wasLongPress = false,
    this.activationTime,
    this.sharedPoints,
  }) : super();

  final FusionDataPoint point;
  final String seriesName;
  final Color seriesColor;
  @override
  final Offset screenPosition;
  final bool wasLongPress;
  final DateTime? activationTime;
  
  /// Additional points at the same X position for shared tooltip
  final List<SharedTooltipPoint>? sharedPoints;

  TooltipRenderData copyWith({
    FusionDataPoint? point,
    String? seriesName,
    Color? seriesColor,
    Offset? screenPosition,
    bool? wasLongPress,
    DateTime? activationTime,
    List<SharedTooltipPoint>? sharedPoints,
  }) {
    return TooltipRenderData(
      point: point ?? this.point,
      seriesName: seriesName ?? this.seriesName,
      seriesColor: seriesColor ?? this.seriesColor,
      screenPosition: screenPosition ?? this.screenPosition,
      wasLongPress: wasLongPress ?? this.wasLongPress,
      activationTime: activationTime ?? this.activationTime,
      sharedPoints: sharedPoints ?? this.sharedPoints,
    );
  }
}

/// Point data for shared tooltip
class SharedTooltipPoint {
  const SharedTooltipPoint({
    required this.point,
    required this.seriesName,
    required this.seriesColor,
    required this.screenPosition,
  });

  final FusionDataPoint point;
  final String seriesName;
  final Color seriesColor;
  final Offset screenPosition;
}

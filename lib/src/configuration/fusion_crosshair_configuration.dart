import 'package:flutter/material.dart';
import '../core/enums/fusion_dismiss_strategy.dart';

/// Configuration for chart crosshair.
///
/// ## Example - Financial Chart
///
/// ```dart
/// final crosshairConfig = FusionCrosshairConfiguration(
///   enabled: true,
///   activationMode: FusionCrosshairActivationMode.longPress,
///
///   // Control how crosshair dismisses!
///   dismissStrategy: FusionDismissStrategy.onTimer,
///   duration: Duration(seconds: 5), // Persist 5s for analysis
///
///   lineColor: Colors.grey.withOpacity(0.8),
///   lineDashArray: [5, 5],
///   snapToDataPoint: true,
/// );
/// ```
///
/// ## Example - Desktop Analytics
///
/// ```dart
/// final crosshairConfig = FusionCrosshairConfiguration(
///   activationMode: FusionCrosshairActivationMode.hover,
///
///   // Brief linger after mouse moves away
///   dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
///   dismissDelay: Duration(milliseconds: 300),
/// );
/// ```
@immutable
class FusionCrosshairConfiguration {
  /// Creates a crosshair configuration.
  const FusionCrosshairConfiguration({
    // Core
    this.enabled = true,

    this.activationMode = FusionCrosshairActivationMode.longPress,
    this.dismissStrategy = FusionDismissStrategy.onRelease,
    this.dismissDelay = const Duration(milliseconds: 300),
    this.duration = const Duration(milliseconds: 3000),

    // Snapping
    this.snapToDataPoint = true,

    // Line appearance
    this.lineColor,
    this.lineWidth = 1.0,
    this.lineDashArray,
    this.showHorizontalLine = true,
    this.showVerticalLine = true,

    // Label appearance
    this.showLabel = true,
    this.labelBackgroundColor,
    this.labelTextStyle,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.labelBorderRadius = 4.0,

    // Animation
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.exitAnimationCurve = Curves.easeInCubic,

    // Advanced
    this.fadeOutOnPanZoom = true,
  });

  // ==========================================================================
  // VISIBILITY & INTERACTION
  // ==========================================================================

  /// Whether the crosshair is enabled.
  final bool enabled;

  /// How the crosshair is activated.
  final FusionCrosshairActivationMode activationMode;

  // ==========================================================================
  // DISMISS CONTROL
  // ==========================================================================

  /// Strategy for dismissing crosshair.
  ///
  /// **onRelease** (default) - Dismiss when finger/pointer lifts
  /// **onTimer** - Show for [duration] then dismiss
  /// **onReleaseDelayed** - Brief delay after release
  /// **never** - Manual hide only
  /// **smart** - Adapts to interaction (quick vs long press)
  final FusionDismissStrategy dismissStrategy;

  /// Additional delay before dismissing (for onReleaseDelayed).
  final Duration dismissDelay;

  /// Duration to display crosshair (for onTimer strategy).
  final Duration duration;

  // ==========================================================================
  // SNAPPING & POSITIONING
  // ==========================================================================

  /// Whether to snap crosshair to nearest data point.
  ///
  /// When true, crosshair locks to actual data points.
  /// When false, crosshair follows touch/mouse position freely.
  final bool snapToDataPoint;

  // ==========================================================================
  // LINE APPEARANCE
  // ==========================================================================

  /// Whether to show horizontal line.
  final bool showHorizontalLine;

  /// Whether to show vertical line.
  final bool showVerticalLine;

  /// Color of the crosshair lines.
  final Color? lineColor;

  /// Width of the crosshair lines.
  final double lineWidth;

  /// Dash pattern for the crosshair lines.
  ///
  /// Example: `[5, 5]` creates dashed lines (5px line, 5px gap).
  final List<double>? lineDashArray;

  // ==========================================================================
  // LABEL APPEARANCE
  // ==========================================================================

  /// Whether to show axis value labels.
  final bool showLabel;

  /// Background color of the crosshair labels.
  final Color? labelBackgroundColor;

  /// Text style for the crosshair labels.
  final TextStyle? labelTextStyle;

  /// Padding inside the crosshair labels.
  final EdgeInsets labelPadding;

  /// Corner radius of the crosshair labels.
  final double labelBorderRadius;

  // ==========================================================================
  // ANIMATION PROPERTIES
  // ==========================================================================

  /// Animation duration for show/hide.
  final Duration animationDuration;

  /// Easing curve for enter animation.
  final Curve animationCurve;

  /// Easing curve for exit animation.
  final Curve exitAnimationCurve;

  // ==========================================================================
  // ADVANCED PROPERTIES
  // ==========================================================================

  /// Fade out crosshair during pan/zoom gestures.
  final bool fadeOutOnPanZoom;

  // ==========================================================================
  // 🚀 HELPER METHODS (Matching Tooltip Pattern!)
  // ==========================================================================

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

  /// Get dismiss delay duration based on interaction type.
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
        // Smart behavior: long press = persist, quick tap = brief
        return wasLongPress ? duration : dismissDelay;
    }
  }

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Gets the effective line color.
  Color getEffectiveLineColor(BuildContext context, Color? themeColor) {
    return lineColor ?? themeColor ?? Colors.grey;
  }

  /// Gets the effective label background color.
  Color getEffectiveLabelBackgroundColor(BuildContext context) {
    return labelBackgroundColor ?? Colors.black87;
  }

  /// Gets the effective label text style.
  TextStyle getEffectiveLabelTextStyle(BuildContext context) {
    return labelTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
  }

  // ==========================================================================
  // METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionCrosshairConfiguration copyWith({
    bool? enabled,
    FusionCrosshairActivationMode? activationMode,
    FusionDismissStrategy? dismissStrategy,
    Duration? dismissDelay,
    Duration? duration,
    bool? snapToDataPoint,
    Color? lineColor,
    double? lineWidth,
    List<double>? lineDashArray,
    bool? showHorizontalLine,
    bool? showVerticalLine,
    bool? showLabel,
    Color? labelBackgroundColor,
    TextStyle? labelTextStyle,
    EdgeInsets? labelPadding,
    double? labelBorderRadius,
    Duration? animationDuration,
    Curve? animationCurve,
    Curve? exitAnimationCurve,
    bool? fadeOutOnPanZoom,
  }) {
    return FusionCrosshairConfiguration(
      enabled: enabled ?? this.enabled,
      activationMode: activationMode ?? this.activationMode,
      dismissStrategy: dismissStrategy ?? this.dismissStrategy,
      dismissDelay: dismissDelay ?? this.dismissDelay,
      duration: duration ?? this.duration,
      snapToDataPoint: snapToDataPoint ?? this.snapToDataPoint,
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineDashArray: lineDashArray ?? this.lineDashArray,
      showHorizontalLine: showHorizontalLine ?? this.showHorizontalLine,
      showVerticalLine: showVerticalLine ?? this.showVerticalLine,
      showLabel: showLabel ?? this.showLabel,
      labelBackgroundColor: labelBackgroundColor ?? this.labelBackgroundColor,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      labelPadding: labelPadding ?? this.labelPadding,
      labelBorderRadius: labelBorderRadius ?? this.labelBorderRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      exitAnimationCurve: exitAnimationCurve ?? this.exitAnimationCurve,
      fadeOutOnPanZoom: fadeOutOnPanZoom ?? this.fadeOutOnPanZoom,
    );
  }

  @override
  String toString() =>
      'FusionCrosshairConfiguration('
      'enabled: $enabled, '
      'activationMode: $activationMode, '
      'dismissStrategy: $dismissStrategy'
      ')';
}

/// How the crosshair is activated.
enum FusionCrosshairActivationMode {
  /// Activate on tap/click.
  tap,

  /// Activate oßn long press (default).
  longPress,

  /// Activate on hover (desktop/web only).
  hover,

  /// Always show crosshair.
  always,

  /// Never show crosshair.
  none,
}

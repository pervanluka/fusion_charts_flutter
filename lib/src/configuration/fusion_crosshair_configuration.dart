import 'package:flutter/material.dart';

/// Configuration for chart crosshair.
///
/// Controls appearance and behavior of the crosshair indicator
/// that shows when users interact with the chart.
///
/// Replaces:
/// - `CrosshairBehavior` from Syncfusion
/// - Custom crosshair implementations from fl_chart
///
/// ## Example
///
/// ```dart
/// final crosshairConfig = FusionCrosshairConfiguration(
///   enabled: true,
///   lineColor: Colors.grey,
///   lineWidth: 1.0,
///   lineDashArray: [5, 5],
///   showHorizontalLine: true,
///   showVerticalLine: true,
/// );
/// ```
@immutable
class FusionCrosshairConfiguration {
  /// Creates a crosshair configuration.
  const FusionCrosshairConfiguration({
    this.enabled = true,
    this.lineColor,
    this.lineWidth = 1.0,
    this.lineDashArray,
    this.showHorizontalLine = true,
    this.showVerticalLine = true,
    this.showLabel = true,
    this.labelBackgroundColor,
    this.labelTextStyle,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.labelBorderRadius = 4.0,
    this.snapToDataPoint = true,
    this.activationMode = FusionCrosshairActivationMode.longPress,
  });

  // ==========================================================================
  // VISIBILITY & INTERACTION
  // ==========================================================================

  /// Whether the crosshair is enabled.
  final bool enabled;

  /// How the crosshair is activated.
  final FusionCrosshairActivationMode activationMode;

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
  ///
  /// If null, uses theme's crosshair color.
  final Color? lineColor;

  /// Width of the crosshair lines.
  final double lineWidth;

  /// Dash pattern for the crosshair lines.
  ///
  /// Example: [5, 5] creates dashed lines (5px line, 5px gap).
  /// If null, lines are solid.
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
        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500);
  }

  // ==========================================================================
  // METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionCrosshairConfiguration copyWith({
    bool? enabled,
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
    bool? snapToDataPoint,
    FusionCrosshairActivationMode? activationMode,
  }) {
    return FusionCrosshairConfiguration(
      enabled: enabled ?? this.enabled,
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
      snapToDataPoint: snapToDataPoint ?? this.snapToDataPoint,
      activationMode: activationMode ?? this.activationMode,
    );
  }

  @override
  String toString() => 'FusionCrosshairConfiguration(enabled: $enabled)';
}

/// How the crosshair is activated.
enum FusionCrosshairActivationMode {
  /// Activate on tap/click.
  tap,

  /// Activate on long press (default).
  longPress,

  /// Activate on hover (desktop/web only).
  hover,

  /// Always show crosshair.
  always,

  /// Never show crosshair.
  none,
}

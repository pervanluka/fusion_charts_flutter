import 'package:flutter/material.dart';
import '../data/fusion_data_point.dart';

/// Tooltip behavior configuration for charts.
/// Based on Syncfusion's TooltipBehavior pattern.
@immutable
class FusionTooltipBehavior {
  const FusionTooltipBehavior({
    this.enable = true,
    this.duration = const Duration(milliseconds: 3000),
    this.animationDuration = const Duration(milliseconds: 200),
    this.shouldAlwaysShow = false,
    this.elevation = 2.5,
    this.canShowMarker = true,
    this.textAlignment = ChartAlignment.center,
    this.decimalPlaces = 2,
    this.shared = false,
    this.opacity = 0.9,
    this.borderWidth = 0,
    this.format,
    this.builder,
    this.color,
    this.textStyle,
    this.borderColor,
    this.shadowColor,
  });

  /// Enables or disables tooltip
  final bool enable;

  /// Duration to display tooltip
  final Duration duration;

  /// Animation duration for show/hide
  final Duration animationDuration;

  /// If true, tooltip always visible
  final bool shouldAlwaysShow;

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

  /// Custom format function
  /// Parameters: point, seriesName, seriesColor
  final String Function(FusionDataPoint point, String seriesName)? format;

  /// Custom builder for complete tooltip
  final Widget Function(
    BuildContext context,
    FusionDataPoint point,
    String seriesName,
    Color seriesColor,
  )?
  builder;

  /// Tooltip background color
  final Color? color;

  /// Text style for tooltip
  final TextStyle? textStyle;

  /// Border color
  final Color? borderColor;

  /// Shadow color
  final Color? shadowColor;

  FusionTooltipBehavior copyWith({
    bool? enable,
    Duration? duration,
    Duration? animationDuration,
    bool? shouldAlwaysShow,
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
  }) {
    return FusionTooltipBehavior(
      enable: enable ?? this.enable,
      duration: duration ?? this.duration,
      animationDuration: animationDuration ?? this.animationDuration,
      shouldAlwaysShow: shouldAlwaysShow ?? this.shouldAlwaysShow,
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
    );
  }
}

/// Alignment options for tooltip
enum ChartAlignment { near, center, far }

/// Tooltip render data (internal use)
class TooltipRenderData {
  const TooltipRenderData({
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

// lib/src/configuration/fusion_line_chart_configuration.dart

import 'package:flutter/material.dart';
import '../themes/fusion_chart_theme.dart';
import 'fusion_chart_configuration.dart';
import 'fusion_tooltip_configuration.dart';
import 'fusion_crosshair_configuration.dart';
import 'fusion_pan_configuration.dart';
import 'fusion_zoom_configuration.dart';

/// Configuration specifically for line charts.
///
/// Extends [FusionChartConfiguration] with line-specific settings:
/// - Line width
/// - Markers (visibility, size, shape)
/// - Area fill
/// - Curve smoothing
///
/// ## Example
///
/// ```dart
/// FusionLineChart(
///   config: FusionLineChartConfiguration(
///     // Base settings
///     theme: FusionDarkTheme(),
///     enableAnimation: true,
///     enableTooltip: true,
///     
///     // Line-specific settings
///     lineWidth: 2.5,
///     enableMarkers: true,
///     markerSize: 6.0,
///     enableAreaFill: true,
///     areaFillOpacity: 0.2,
///   ),
///   series: [...],
/// )
/// ```
@immutable
class FusionLineChartConfiguration extends FusionChartConfiguration {
  /// Creates a line chart configuration.
  const FusionLineChartConfiguration({
    // Base configuration
    super.theme,
    super.tooltipBehavior,
    super.crosshairBehavior,
    super.zoomBehavior,
    super.panBehavior,
    super.enableAnimation,
    super.enableTooltip,
    super.enableCrosshair,
    super.enableZoom,
    super.enablePanning,
    super.enableSelection,
    super.enableLegend,
    super.enableDataLabels,
    super.enableBorder,
    super.enableGrid,
    super.enableAxis,
    super.padding,
    super.animationDuration,
    super.animationCurve,

    // Line-specific settings
    this.lineWidth = 2.0,
    this.enableMarkers = false,
    this.markerSize = 6.0,
    this.enableAreaFill = false,
    this.areaFillOpacity = 0.3,
    this.enableCurveSmoothing = false,
    this.curveTension = 0.4,
  })  : assert(lineWidth > 0 && lineWidth <= 10, 'lineWidth must be between 0 and 10'),
        assert(markerSize > 0 && markerSize <= 20, 'markerSize must be between 0 and 20'),
        assert(areaFillOpacity >= 0 && areaFillOpacity <= 1, 'areaFillOpacity must be between 0 and 1'),
        assert(curveTension >= 0 && curveTension <= 1, 'curveTension must be between 0 and 1');

  // ==========================================================================
  // LINE-SPECIFIC SETTINGS
  // ==========================================================================

  /// Width of the line stroke.
  ///
  /// Range: 0.5 - 10.0
  /// Default: 2.0
  final double lineWidth;

  /// Whether to show markers at each data point.
  ///
  /// Markers help identify exact data point positions.
  ///
  /// Default: `false`
  final bool enableMarkers;

  /// Size of data point markers.
  ///
  /// Only applies when [enableMarkers] is `true`.
  ///
  /// Range: 2.0 - 20.0
  /// Default: 6.0
  final double markerSize;

  /// Whether to fill the area below the line.
  ///
  /// Creates an area chart effect.
  ///
  /// Default: `false`
  final bool enableAreaFill;

  /// Opacity of the area fill.
  ///
  /// Only applies when [enableAreaFill] is `true`.
  ///
  /// Range: 0.0 - 1.0
  /// Default: 0.3
  final double areaFillOpacity;

  /// Whether to apply curve smoothing (spline).
  ///
  /// When `true`, lines are rendered as smooth curves.
  /// When `false`, lines are straight between points.
  ///
  /// Default: `false`
  final bool enableCurveSmoothing;

  /// Tension of the curve smoothing.
  ///
  /// Only applies when [enableCurveSmoothing] is `true`.
  /// Higher values create tighter curves.
  ///
  /// Range: 0.0 - 1.0
  /// Default: 0.4
  final double curveTension;

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  /// Creates a copy with modified values.
  @override
  FusionLineChartConfiguration copyWith({
    // Base configuration
    FusionChartTheme? theme,
    FusionTooltipBehavior? tooltipBehavior,
    FusionCrosshairConfiguration? crosshairBehavior,
    FusionZoomConfiguration? zoomBehavior,
    FusionPanConfiguration? panBehavior,
    bool? enableAnimation,
    bool? enableTooltip,
    bool? enableCrosshair,
    bool? enableZoom,
    bool? enablePanning,
    bool? enableSelection,
    bool? enableLegend,
    bool? enableDataLabels,
    bool? enableBorder,
    bool? enableGrid,
    bool? enableAxis,
    EdgeInsets? padding,
    Duration? animationDuration,
    Curve? animationCurve,

    // Line-specific
    double? lineWidth,
    bool? enableMarkers,
    double? markerSize,
    bool? enableAreaFill,
    double? areaFillOpacity,
    bool? enableCurveSmoothing,
    double? curveTension,
  }) {
    return FusionLineChartConfiguration(
      theme: theme ?? this.theme,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
      crosshairBehavior: crosshairBehavior ?? this.crosshairBehavior,
      zoomBehavior: zoomBehavior ?? this.zoomBehavior,
      panBehavior: panBehavior ?? this.panBehavior,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      enableTooltip: enableTooltip ?? this.enableTooltip,
      enableCrosshair: enableCrosshair ?? this.enableCrosshair,
      enableZoom: enableZoom ?? this.enableZoom,
      enablePanning: enablePanning ?? this.enablePanning,
      enableSelection: enableSelection ?? this.enableSelection,
      enableLegend: enableLegend ?? this.enableLegend,
      enableDataLabels: enableDataLabels ?? this.enableDataLabels,
      enableBorder: enableBorder ?? this.enableBorder,
      enableGrid: enableGrid ?? this.enableGrid,
      enableAxis: enableAxis ?? this.enableAxis,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      lineWidth: lineWidth ?? this.lineWidth,
      enableMarkers: enableMarkers ?? this.enableMarkers,
      markerSize: markerSize ?? this.markerSize,
      enableAreaFill: enableAreaFill ?? this.enableAreaFill,
      areaFillOpacity: areaFillOpacity ?? this.areaFillOpacity,
      enableCurveSmoothing: enableCurveSmoothing ?? this.enableCurveSmoothing,
      curveTension: curveTension ?? this.curveTension,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionLineChartConfiguration &&
        super == other &&
        other.lineWidth == lineWidth &&
        other.enableMarkers == enableMarkers &&
        other.markerSize == markerSize &&
        other.enableAreaFill == enableAreaFill &&
        other.areaFillOpacity == areaFillOpacity &&
        other.enableCurveSmoothing == enableCurveSmoothing &&
        other.curveTension == curveTension;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      lineWidth,
      enableMarkers,
      markerSize,
      enableAreaFill,
      areaFillOpacity,
      enableCurveSmoothing,
      curveTension,
    );
  }

  @override
  String toString() {
    return 'FusionLineChartConfiguration('
        'theme: ${theme.runtimeType}, '
        'lineWidth: $lineWidth, '
        'enableMarkers: $enableMarkers, '
        'enableAreaFill: $enableAreaFill'
        ')';
  }
}

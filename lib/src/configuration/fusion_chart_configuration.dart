// lib/src/configuration/fusion_chart_configuration.dart

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import '../themes/fusion_chart_theme.dart';
import '../themes/fusion_light_theme.dart';
import 'fusion_crosshair_configuration.dart';
import 'fusion_zoom_configuration.dart';

/// Base configuration class for all Fusion Charts.
///
/// Contains settings that apply to ALL chart types:
/// - Theme
/// - Animation
/// - Tooltip behavior
/// - Zoom/Pan
/// - Grid/Axis visibility
/// - Legend
///
/// For chart-specific settings, use:
/// - [FusionLineChartConfiguration] for line charts
/// - [FusionBarChartConfiguration] for bar charts
/// - [FusionStackedBarChartConfiguration] for stacked bar charts
///
/// ## Example
///
/// ```dart
/// // For line charts
/// FusionLineChart(
///   config: FusionLineChartConfiguration(
///     theme: FusionDarkTheme(),
///     enableAnimation: true,
///     lineWidth: 2.5,        // Line-specific
///     enableMarkers: true,   // Line-specific
///   ),
///   series: [...],
/// )
///
/// // For bar charts
/// FusionBarChart(
///   config: FusionBarChartConfiguration(
///     theme: FusionDarkTheme(),
///     enableSideBySideSeriesPlacement: false,  // Bar-specific
///   ),
///   series: [...],
/// )
/// ```
@immutable
class FusionChartConfiguration {
  /// Creates a base chart configuration.
  const FusionChartConfiguration({
    FusionChartTheme? theme,
    this.tooltipBehavior = const FusionTooltipBehavior(),
    this.crosshairBehavior = const FusionCrosshairConfiguration(),
    this.zoomBehavior = const FusionZoomConfiguration(),
    this.enableAnimation = true,
    this.enableTooltip = true,
    this.enableCrosshair = true,
    this.enableZoom = false,
    this.enablePanning = false,
    this.enableSelection = true,
    this.enableLegend = true,
    this.enableDataLabels = false,
    this.enableGrid = true,
    this.enableAxis = true,
    this.padding = const EdgeInsets.all(16.0),
    this.animationDuration,
    this.animationCurve,
  }) : theme = theme ?? const FusionLightTheme();

  // ==========================================================================
  // THEME
  // ==========================================================================

  /// The theme controlling visual appearance.
  ///
  /// Defaults to [FusionLightTheme].
  final FusionChartTheme theme;

  // ==========================================================================
  // BEHAVIOR CONFIGURATIONS
  // ==========================================================================

  /// Tooltip behavior configuration.
  final FusionTooltipBehavior tooltipBehavior;

  /// Crosshair behavior configuration.
  final FusionCrosshairConfiguration crosshairBehavior;

  /// Zoom behavior configuration.
  final FusionZoomConfiguration zoomBehavior;

  // ==========================================================================
  // FEATURE FLAGS (Common to all charts)
  // ==========================================================================

  /// Whether to enable animations when chart loads or updates.
  ///
  /// Default: `true`
  final bool enableAnimation;

  /// Whether to show tooltips on hover/tap.
  ///
  /// Default: `true`
  final bool enableTooltip;

  /// Whether to show crosshair indicator on interaction.
  ///
  /// Default: `true`
  final bool enableCrosshair;

  /// Whether to enable pinch-to-zoom functionality.
  ///
  /// Default: `false`
  final bool enableZoom;

  /// Whether to enable drag-to-pan functionality.
  ///
  /// Default: `false`
  final bool enablePanning;

  /// Whether to enable data point/series selection.
  ///
  /// Default: `true`
  final bool enableSelection;

  /// Whether to show the legend.
  ///
  /// Default: `true`
  final bool enableLegend;

  /// Whether to show data labels on chart elements.
  ///
  /// Default: `false`
  final bool enableDataLabels;

  /// Whether to show grid lines.
  ///
  /// Default: `true`
  final bool enableGrid;

  /// Whether to show axis lines and labels.
  ///
  /// Default: `true`
  final bool enableAxis;

  // ==========================================================================
  // LAYOUT
  // ==========================================================================

  /// Padding around the chart content.
  ///
  /// Default: 16px on all sides
  final EdgeInsets padding;

  // ==========================================================================
  // ANIMATION OVERRIDES
  // ==========================================================================

  /// Custom animation duration.
  ///
  /// If `null`, uses the theme's default duration.
  final Duration? animationDuration;

  /// Custom animation curve.
  ///
  /// If `null`, uses the theme's default curve.
  final Curve? animationCurve;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Gets the effective animation duration.
  Duration get effectiveAnimationDuration =>
      animationDuration ?? theme.animationDuration;

  /// Gets the effective animation curve.
  Curve get effectiveAnimationCurve => animationCurve ?? theme.animationCurve;

  /// Whether any interaction is enabled.
  bool get hasAnyInteraction =>
      enableTooltip ||
      enableCrosshair ||
      enableZoom ||
      enablePanning ||
      enableSelection;

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionChartConfiguration copyWith({
    FusionChartTheme? theme,
    FusionTooltipBehavior? tooltipBehavior,
    FusionCrosshairConfiguration? crosshairBehavior,
    FusionZoomConfiguration? zoomBehavior,
    bool? enableAnimation,
    bool? enableTooltip,
    bool? enableCrosshair,
    bool? enableZoom,
    bool? enablePanning,
    bool? enableSelection,
    bool? enableLegend,
    bool? enableDataLabels,
    bool? enableGrid,
    bool? enableAxis,
    EdgeInsets? padding,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return FusionChartConfiguration(
      theme: theme ?? this.theme,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
      crosshairBehavior: crosshairBehavior ?? this.crosshairBehavior,
      zoomBehavior: zoomBehavior ?? this.zoomBehavior,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      enableTooltip: enableTooltip ?? this.enableTooltip,
      enableCrosshair: enableCrosshair ?? this.enableCrosshair,
      enableZoom: enableZoom ?? this.enableZoom,
      enablePanning: enablePanning ?? this.enablePanning,
      enableSelection: enableSelection ?? this.enableSelection,
      enableLegend: enableLegend ?? this.enableLegend,
      enableDataLabels: enableDataLabels ?? this.enableDataLabels,
      enableGrid: enableGrid ?? this.enableGrid,
      enableAxis: enableAxis ?? this.enableAxis,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionChartConfiguration &&
        other.theme == theme &&
        other.tooltipBehavior == tooltipBehavior &&
        other.crosshairBehavior == crosshairBehavior &&
        other.zoomBehavior == zoomBehavior &&
        other.enableAnimation == enableAnimation &&
        other.enableTooltip == enableTooltip &&
        other.enableCrosshair == enableCrosshair &&
        other.enableZoom == enableZoom &&
        other.enablePanning == enablePanning &&
        other.enableSelection == enableSelection &&
        other.enableLegend == enableLegend &&
        other.enableDataLabels == enableDataLabels &&
        other.enableGrid == enableGrid &&
        other.enableAxis == enableAxis &&
        other.padding == padding &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve;
  }

  @override
  int get hashCode {
    return Object.hash(
      theme,
      tooltipBehavior,
      crosshairBehavior,
      zoomBehavior,
      enableAnimation,
      enableTooltip,
      enableCrosshair,
      enableZoom,
      enablePanning,
      enableSelection,
      enableLegend,
      enableDataLabels,
      enableGrid,
      enableAxis,
      padding,
      animationDuration,
      animationCurve,
    );
  }

  @override
  String toString() {
    return 'FusionChartConfiguration('
        'theme: ${theme.runtimeType}, '
        'enableAnimation: $enableAnimation, '
        'enableTooltip: $enableTooltip'
        ')';
  }
}

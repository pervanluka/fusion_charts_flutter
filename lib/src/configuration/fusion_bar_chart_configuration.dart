// lib/src/configuration/fusion_bar_chart_configuration.dart

import 'package:flutter/material.dart';
import '../themes/fusion_chart_theme.dart';
import 'fusion_chart_configuration.dart';
import 'fusion_tooltip_configuration.dart';
import 'fusion_crosshair_configuration.dart';
import 'fusion_pan_configuration.dart';
import 'fusion_zoom_configuration.dart';

/// Configuration specifically for bar charts.
///
/// Extends [FusionChartConfiguration] with bar-specific settings:
/// - Bar placement (side-by-side vs overlapped)
/// - Bar width ratio
/// - Bar spacing
/// - Border radius
///
/// ## Example
///
/// ```dart
/// FusionBarChart(
///   config: FusionBarChartConfiguration(
///     // Base settings
///     theme: FusionDarkTheme(),
///     enableAnimation: true,
///     
///     // Bar-specific settings
///     enableSideBySideSeriesPlacement: true,  // Grouped bars
///     barWidthRatio: 0.8,
///     barSpacing: 0.2,
///     borderRadius: 4.0,
///   ),
///   series: [...],
/// )
/// ```
///
/// ## Grouped vs Overlapped Bars
///
/// ```dart
/// // Grouped bars (side-by-side)
/// FusionBarChartConfiguration(
///   enableSideBySideSeriesPlacement: true,
/// )
///
/// // Overlapped bars (target vs actual)
/// FusionBarChartConfiguration(
///   enableSideBySideSeriesPlacement: false,
/// )
/// ```
@immutable
class FusionBarChartConfiguration extends FusionChartConfiguration {
  /// Creates a bar chart configuration.
  const FusionBarChartConfiguration({
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
    super.enableGrid,
    super.enableAxis,
    super.padding,
    super.animationDuration,
    super.animationCurve,

    // Bar-specific settings
    this.enableSideBySideSeriesPlacement = true,
    this.barWidthRatio = 0.8,
    this.barSpacing = 0.2,
    this.borderRadius = 0.0,
    this.enableBarShadow = false,
  })  : assert(barWidthRatio > 0 && barWidthRatio <= 1, 'barWidthRatio must be between 0 and 1'),
        assert(barSpacing >= 0 && barSpacing <= 1, 'barSpacing must be between 0 and 1'),
        assert(borderRadius >= 0, 'borderRadius must be non-negative');

  // ==========================================================================
  // BAR-SPECIFIC SETTINGS
  // ==========================================================================

  /// Whether to place bar series side-by-side.
  ///
  /// When `true` (default), multiple bar series are rendered side-by-side
  /// within each category (grouped bars).
  ///
  /// When `false`, bar series are rendered on top of each other (overlapped).
  /// Useful for comparing two related metrics where one is typically
  /// smaller than the other (e.g., actual vs target).
  ///
  /// Default: `true`
  final bool enableSideBySideSeriesPlacement;

  /// Ratio of bar width to available category space.
  ///
  /// A value of 1.0 means bars take up all available space.
  /// A value of 0.5 means bars take up half the available space.
  ///
  /// Range: 0.1 - 1.0
  /// Default: 0.8
  final double barWidthRatio;

  /// Spacing between bars in grouped mode.
  ///
  /// Expressed as a ratio of the category width.
  /// Only applies when [enableSideBySideSeriesPlacement] is `true`.
  ///
  /// Range: 0.0 - 1.0
  /// Default: 0.2
  final double barSpacing;

  /// Border radius for bar corners.
  ///
  /// Creates rounded corners on bars.
  ///
  /// Default: 0.0 (sharp corners)
  final double borderRadius;

  /// Whether to show shadows under bars.
  ///
  /// Default: `false`
  final bool enableBarShadow;

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  /// Creates a copy with modified values.
  @override
  FusionBarChartConfiguration copyWith({
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
    bool? enableGrid,
    bool? enableAxis,
    EdgeInsets? padding,
    Duration? animationDuration,
    Curve? animationCurve,

    // Bar-specific
    bool? enableSideBySideSeriesPlacement,
    double? barWidthRatio,
    double? barSpacing,
    double? borderRadius,
    bool? enableBarShadow,
  }) {
    return FusionBarChartConfiguration(
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
      enableGrid: enableGrid ?? this.enableGrid,
      enableAxis: enableAxis ?? this.enableAxis,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement ?? this.enableSideBySideSeriesPlacement,
      barWidthRatio: barWidthRatio ?? this.barWidthRatio,
      barSpacing: barSpacing ?? this.barSpacing,
      borderRadius: borderRadius ?? this.borderRadius,
      enableBarShadow: enableBarShadow ?? this.enableBarShadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionBarChartConfiguration &&
        super == other &&
        other.enableSideBySideSeriesPlacement == enableSideBySideSeriesPlacement &&
        other.barWidthRatio == barWidthRatio &&
        other.barSpacing == barSpacing &&
        other.borderRadius == borderRadius &&
        other.enableBarShadow == enableBarShadow;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      enableSideBySideSeriesPlacement,
      barWidthRatio,
      barSpacing,
      borderRadius,
      enableBarShadow,
    );
  }

  @override
  String toString() {
    return 'FusionBarChartConfiguration('
        'theme: ${theme.runtimeType}, '
        'enableSideBySideSeriesPlacement: $enableSideBySideSeriesPlacement, '
        'barWidthRatio: $barWidthRatio'
        ')';
  }
}

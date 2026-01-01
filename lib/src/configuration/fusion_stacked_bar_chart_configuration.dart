import 'package:flutter/material.dart';

import '../themes/fusion_chart_theme.dart';
import 'fusion_chart_configuration.dart';
import 'fusion_crosshair_configuration.dart';
import 'fusion_pan_configuration.dart';
import 'fusion_stacked_tooltip_builder.dart';
import 'fusion_tooltip_configuration.dart';
import 'fusion_zoom_configuration.dart';

/// Configuration specifically for stacked bar charts.
///
/// Extends [FusionChartConfiguration] with stacked bar-specific settings:
/// - 100% stacking mode
/// - Custom tooltip builders and formatters
/// - Bar width and spacing
/// - Border radius
///
/// ## Example
///
/// ```dart
/// FusionStackedBarChart(
///   config: FusionStackedBarChartConfiguration(
///     // Base settings
///     theme: FusionDarkTheme(),
///     enableAnimation: true,
///
///     // Stacked bar-specific settings
///     isStacked100: true,  // 100% stacked mode
///     barWidthRatio: 0.7,
///     tooltipValueFormatter: (value, segment, info) {
///       return '\$${value.toStringAsFixed(0)}';
///     },
///   ),
///   series: [...],
/// )
/// ```
///
/// ## Custom Tooltips
///
/// ```dart
/// FusionStackedBarChartConfiguration(
///   // Complete control over tooltip widget
///   tooltipBuilder: (context, info) {
///     return MyCustomTooltip(
///       segments: info.segments,
///       total: info.totalValue,
///     );
///   },
///
///   // Or just customize formatting
///   tooltipValueFormatter: (value, segment, info) {
///     return '${segment.percentage.toStringAsFixed(1)}%';
///   },
///   tooltipTotalFormatter: (total, info) {
///     return 'Sum: \$${total.toStringAsFixed(0)}';
///   },
/// )
/// ```
@immutable
class FusionStackedBarChartConfiguration extends FusionChartConfiguration {
  /// Creates a stacked bar chart configuration.
  const FusionStackedBarChartConfiguration({
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

    // Stacked bar-specific settings
    this.isStacked100 = false,
    this.barWidthRatio = 0.8,
    this.borderRadius = 0.0,
    this.tooltipBuilder,
    this.tooltipValueFormatter,
    this.tooltipTotalFormatter,
  }) : assert(
         barWidthRatio > 0 && barWidthRatio <= 1,
         'barWidthRatio must be between 0 and 1',
       ),
       assert(borderRadius >= 0, 'borderRadius must be non-negative');

  // ==========================================================================
  // STACKED BAR-SPECIFIC SETTINGS
  // ==========================================================================

  /// Whether to use 100% stacking mode.
  ///
  /// When `true`, all stacks are normalized to 100%.
  /// Shows relative proportions instead of absolute values.
  ///
  /// Default: `false`
  final bool isStacked100;

  /// Ratio of bar width to available category space.
  ///
  /// Range: 0.1 - 1.0
  /// Default: 0.8
  final double barWidthRatio;

  /// Border radius for the top corners of the stack.
  ///
  /// Only the top segment of each stack will have rounded corners.
  ///
  /// Default: 0.0 (sharp corners)
  final double borderRadius;

  // ==========================================================================
  // TOOLTIP CUSTOMIZATION
  // ==========================================================================

  /// Custom builder for the tooltip widget.
  ///
  /// If provided, gives complete control over tooltip rendering.
  /// Return `null` from the builder to use default rendering.
  ///
  /// When set, [tooltipValueFormatter] and [tooltipTotalFormatter] are ignored.
  final FusionStackedTooltipBuilder? tooltipBuilder;

  /// Formatter for segment values in the default tooltip.
  ///
  /// Only used when [tooltipBuilder] is not provided.
  ///
  /// Example:
  /// ```dart
  /// tooltipValueFormatter: (value, segment, info) {
  ///   return '\$${value.toStringAsFixed(2)}';
  /// }
  /// ```
  final FusionStackedValueFormatter? tooltipValueFormatter;

  /// Formatter for the total line in the default tooltip.
  ///
  /// Only used when [tooltipBuilder] is not provided.
  /// Return `null` to hide the total line.
  ///
  /// Example:
  /// ```dart
  /// tooltipTotalFormatter: (total, info) {
  ///   return 'Total: \$${total.toStringAsFixed(0)}';
  /// }
  /// ```
  final FusionStackedTotalFormatter? tooltipTotalFormatter;

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  /// Creates a copy with modified values.
  @override
  FusionStackedBarChartConfiguration copyWith({
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

    // Stacked bar-specific
    bool? isStacked100,
    double? barWidthRatio,
    double? borderRadius,
    FusionStackedTooltipBuilder? tooltipBuilder,
    FusionStackedValueFormatter? tooltipValueFormatter,
    FusionStackedTotalFormatter? tooltipTotalFormatter,
  }) {
    return FusionStackedBarChartConfiguration(
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
      isStacked100: isStacked100 ?? this.isStacked100,
      barWidthRatio: barWidthRatio ?? this.barWidthRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      tooltipBuilder: tooltipBuilder ?? this.tooltipBuilder,
      tooltipValueFormatter:
          tooltipValueFormatter ?? this.tooltipValueFormatter,
      tooltipTotalFormatter:
          tooltipTotalFormatter ?? this.tooltipTotalFormatter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionStackedBarChartConfiguration &&
        super == other &&
        other.isStacked100 == isStacked100 &&
        other.barWidthRatio == barWidthRatio &&
        other.borderRadius == borderRadius &&
        other.tooltipBuilder == tooltipBuilder &&
        other.tooltipValueFormatter == tooltipValueFormatter &&
        other.tooltipTotalFormatter == tooltipTotalFormatter;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      isStacked100,
      barWidthRatio,
      borderRadius,
      tooltipBuilder,
      tooltipValueFormatter,
      tooltipTotalFormatter,
    );
  }

  @override
  String toString() {
    return 'FusionStackedBarChartConfiguration('
        'theme: ${theme.runtimeType}, '
        'isStacked100: $isStacked100, '
        'barWidthRatio: $barWidthRatio'
        ')';
  }
}

import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import '../themes/fusion_chart_theme.dart';
import '../themes/fusion_light_theme.dart';
import 'fusion_crosshair_configuration.dart';
import 'fusion_zoom_configuration.dart';

/// Configuration class for Fusion Charts.
///
/// Controls all aspects of chart behavior, appearance, and interactions.
/// Use [FusionChartConfigurationBuilder] to create instances.
///
/// Follows the **Builder Pattern** for easy, fluent configuration.
///
/// ## Example
///
/// ```dart
/// final config = FusionChartConfigurationBuilder()
///   .withTheme(FusionDarkTheme())
///   .withAnimation(true)
///   .withTooltip(true)
///   .withCrosshair(true)
///   .withZoom(true)
///   .withPanning(true)
///   .build();
///
/// FusionLineChart(
///   configuration: config,
///   series: [...],
/// )
/// ```
///
/// ## Immutability
///
/// This class is immutable. To create a modified version, use [copyWith]
/// or create a new configuration with [FusionChartConfigurationBuilder].
@immutable
class FusionChartConfiguration {
  /// Creates a chart configuration.
  ///
  /// Prefer using [FusionChartConfigurationBuilder] for a more fluent API.
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
    this.enableMarkers = false,
    this.enableGrid = true,
    this.enableAxis = true,
    this.enableSideBySideSeriesPlacement = true,
    this.lineWidth = 1.0,
    this.markerSize = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.animationDuration,
    this.animationCurve,
  }) : assert(lineWidth >= 0, 'lineWidth must be non-negative'),
       assert(markerSize >= 0, 'markerSize must be non-negative'),
       theme = theme ?? const FusionLightTheme();

  /// The theme controlling visual appearance.
  ///
  /// Defaults to [FusionLightTheme].
  final FusionChartTheme theme;

  /// Tooltip behavior configuration
  final FusionTooltipBehavior tooltipBehavior;

  /// Crosshair behavior configuration
  final FusionCrosshairConfiguration crosshairBehavior;

  /// Zoom behavior configuration
  final FusionZoomConfiguration zoomBehavior;

  // ==========================================================================
  // FEATURE FLAGS
  // ==========================================================================

  /// Whether to enable animations when chart loads or updates.
  ///
  /// When `true`, chart elements will animate smoothly.
  /// When `false`, changes will be instant (better for performance).
  ///
  /// Default: `true`
  final bool enableAnimation;

  /// Whether to show tooltips on hover/tap.
  ///
  /// When `true`, users can see detailed information about data points.
  ///
  /// Default: `true`
  final bool enableTooltip;

  /// Whether to show crosshair indicator on interaction.
  ///
  /// Crosshair is a visual guide showing the exact position of interaction.
  /// Works together with tooltip.
  ///
  /// Default: `true`
  final bool enableCrosshair;

  /// Whether to enable pinch-to-zoom functionality.
  ///
  /// When `true`, users can zoom in/out using pinch gestures (mobile)
  /// or scroll wheel (desktop).
  ///
  /// Default: `false` (opt-in for better UX)
  final bool enableZoom;

  /// Whether to enable drag-to-pan functionality.
  ///
  /// When `true`, users can pan the chart by dragging.
  /// Usually used together with zoom.
  ///
  /// Default: `false` (opt-in for better UX)
  final bool enablePanning;

  /// Whether to enable data point/series selection.
  ///
  /// When `true`, clicking on data points or series will highlight them.
  ///
  /// Default: `true`
  final bool enableSelection;

  /// Whether to show the legend.
  ///
  /// Legend helps identify different series in multi-series charts.
  ///
  /// Default: `true`
  final bool enableLegend;

  /// Whether to show data labels on chart elements.
  ///
  /// Data labels display values directly on the chart.
  /// Can make charts cluttered if there are many data points.
  ///
  /// Default: `false` (opt-in to avoid clutter)
  final bool enableDataLabels;

  /// Whether to show markers on data points.
  ///
  /// Markers are small dots/shapes at each data point.
  /// Useful for precise point identification.
  ///
  /// Default: `false` (cleaner look without markers)
  final bool enableMarkers;

  /// Whether to show grid lines.
  ///
  /// Grid lines help read values more accurately.
  ///
  /// Default: `true`
  final bool enableGrid;

  /// Whether to show axis lines and labels.
  ///
  /// Default: `true`
  final bool enableAxis;

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

  // ==========================================================================
  // DIMENSIONS
  // ==========================================================================

  /// Width of series lines.
  ///
  /// Overrides the theme's default line width if specified.
  ///
  /// Range: 1.0-5.0px
  /// Default: 3.0px
  final double lineWidth;

  /// Size of data point markers.
  ///
  /// Only applies when [enableMarkers] is `true`.
  ///
  /// Range: 4.0-10.0px
  /// Default: 6.0px
  final double markerSize;

  /// Padding around the chart content.
  ///
  /// Creates space between chart and its container edges.
  ///
  /// Default: 16px on all sides
  final EdgeInsets padding;

  // ==========================================================================
  // ANIMATION OVERRIDES
  // ==========================================================================

  /// Custom animation duration.
  ///
  /// If `null`, uses the theme's default duration (1500ms).
  ///
  /// Range: 0-3000ms
  final Duration? animationDuration;

  /// Custom animation curve.
  ///
  /// If `null`, uses the theme's default curve (easeInOutCubic).
  final Curve? animationCurve;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Gets the effective animation duration.
  ///
  /// Returns custom duration if set, otherwise theme's default.
  Duration get effectiveAnimationDuration => animationDuration ?? theme.animationDuration;

  /// Gets the effective animation curve.
  ///
  /// Returns custom curve if set, otherwise theme's default.
  Curve get effectiveAnimationCurve => animationCurve ?? theme.animationCurve;

  /// Whether any interaction is enabled.
  ///
  /// Returns `true` if any of tooltip, crosshair, zoom, pan, or selection
  /// is enabled.
  bool get hasAnyInteraction =>
      enableTooltip || enableCrosshair || enableZoom || enablePanning || enableSelection;

  // ==========================================================================
  // METHODS
  // ==========================================================================

  /// Creates a copy of this configuration with modified values.
  ///
  /// Any parameter not provided will keep its current value.
  ///
  /// Example:
  /// ```dart
  /// final newConfig = config.copyWith(
  ///   enableZoom: true,
  ///   enablePanning: true,
  /// );
  /// ```
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
    bool? enableMarkers,
    bool? enableGrid,
    bool? enableAxis,
    bool? enableSideBySideSeriesPlacement,
    double? lineWidth,
    double? markerSize,
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
      enableMarkers: enableMarkers ?? this.enableMarkers,
      enableGrid: enableGrid ?? this.enableGrid,
      enableAxis: enableAxis ?? this.enableAxis,
      enableSideBySideSeriesPlacement:
          enableSideBySideSeriesPlacement ?? this.enableSideBySideSeriesPlacement,
      lineWidth: lineWidth ?? this.lineWidth,
      markerSize: markerSize ?? this.markerSize,
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
        other.enableMarkers == enableMarkers &&
        other.enableGrid == enableGrid &&
        other.enableAxis == enableAxis &&
        other.enableSideBySideSeriesPlacement == enableSideBySideSeriesPlacement &&
        other.lineWidth == lineWidth &&
        other.markerSize == markerSize &&
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
      enableMarkers,
      enableGrid,
      enableAxis,
      lineWidth,
      markerSize,
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
        'enableTooltip: $enableTooltip, '
        'enableCrosshair: $enableCrosshair, '
        'enableZoom: $enableZoom, '
        'enablePanning: $enablePanning'
        ')';
  }
}

/// Builder for creating [FusionChartConfiguration] instances.
///
/// Provides a fluent API for configuring charts.
///
/// ## Example
///
/// ```dart
/// final config = FusionChartConfigurationBuilder()
///   .withTheme(FusionDarkTheme())
///   .withAnimation(true)
///   .withTooltip(true)
///   .withZoom(true)
///   .build();
/// ```
class FusionChartConfigurationBuilder {
  FusionChartTheme? _theme;
  bool _enableAnimation = true;
  bool _enableTooltip = true;
  bool _enableCrosshair = true;
  bool _enableZoom = false;
  bool _enablePanning = false;
  bool _enableSelection = true;
  bool _enableLegend = true;
  bool _enableDataLabels = false;
  bool _enableMarkers = false;
  bool _enableGrid = true;
  bool _enableAxis = true;
  double _lineWidth = 3.0;
  double _markerSize = 6.0;
  EdgeInsets _padding = const EdgeInsets.all(16.0);
  Duration? _animationDuration;
  Curve? _animationCurve;

  /// Sets the theme.
  FusionChartConfigurationBuilder withTheme(FusionChartTheme theme) {
    _theme = theme;
    return this;
  }

  /// Enables or disables animations.
  FusionChartConfigurationBuilder withAnimation(bool enable) {
    _enableAnimation = enable;
    return this;
  }

  /// Enables or disables tooltips.
  FusionChartConfigurationBuilder withTooltip(bool enable) {
    _enableTooltip = enable;
    return this;
  }

  /// Enables or disables crosshair.
  FusionChartConfigurationBuilder withCrosshair(bool enable) {
    _enableCrosshair = enable;
    return this;
  }

  /// Enables or disables zoom.
  FusionChartConfigurationBuilder withZoom(bool enable) {
    _enableZoom = enable;
    return this;
  }

  /// Enables or disables panning.
  FusionChartConfigurationBuilder withPanning(bool enable) {
    _enablePanning = enable;
    return this;
  }

  /// Enables or disables selection.
  FusionChartConfigurationBuilder withSelection(bool enable) {
    _enableSelection = enable;
    return this;
  }

  /// Enables or disables legend.
  FusionChartConfigurationBuilder withLegend(bool enable) {
    _enableLegend = enable;
    return this;
  }

  /// Enables or disables data labels.
  FusionChartConfigurationBuilder withDataLabels(bool enable) {
    _enableDataLabels = enable;
    return this;
  }

  /// Enables or disables markers.
  FusionChartConfigurationBuilder withMarkers(bool enable) {
    _enableMarkers = enable;
    return this;
  }

  /// Enables or disables grid.
  FusionChartConfigurationBuilder withGrid(bool enable) {
    _enableGrid = enable;
    return this;
  }

  /// Enables or disables axis.
  FusionChartConfigurationBuilder withAxis(bool enable) {
    _enableAxis = enable;
    return this;
  }

  /// Sets the line width.
  FusionChartConfigurationBuilder withLineWidth(double width) {
    assert(width > 0 && width <= 10, 'Line width must be between 0 and 10');
    _lineWidth = width;
    return this;
  }

  /// Sets the marker size.
  FusionChartConfigurationBuilder withMarkerSize(double size) {
    assert(size > 0 && size <= 20, 'Marker size must be between 0 and 20');
    _markerSize = size;
    return this;
  }

  /// Sets the padding.
  FusionChartConfigurationBuilder withPadding(EdgeInsets padding) {
    _padding = padding;
    return this;
  }

  /// Sets custom animation duration.
  FusionChartConfigurationBuilder withAnimationDuration(Duration duration) {
    _animationDuration = duration;
    return this;
  }

  /// Sets custom animation curve.
  FusionChartConfigurationBuilder withAnimationCurve(Curve curve) {
    _animationCurve = curve;
    return this;
  }

  /// Builds the configuration.
  FusionChartConfiguration build() {
    return FusionChartConfiguration(
      theme: _theme,
      enableAnimation: _enableAnimation,
      enableTooltip: _enableTooltip,
      enableCrosshair: _enableCrosshair,
      enableZoom: _enableZoom,
      enablePanning: _enablePanning,
      enableSelection: _enableSelection,
      enableLegend: _enableLegend,
      enableDataLabels: _enableDataLabels,
      enableMarkers: _enableMarkers,
      enableGrid: _enableGrid,
      enableAxis: _enableAxis,
      lineWidth: _lineWidth,
      markerSize: _markerSize,
      padding: _padding,
      animationDuration: _animationDuration,
      animationCurve: _animationCurve,
    );
  }
}

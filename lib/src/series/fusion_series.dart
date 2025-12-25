import 'package:flutter/material.dart';

import '../core/enums/fusion_data_label_display.dart';
import '../core/enums/marker_shape.dart';

/// Base abstract class for all chart series.
///
/// A series represents a collection of related data points that are
/// displayed together on a chart. Different chart types use different
/// series implementations.
///
/// Follows the **Liskov Substitution Principle** (SOLID):
/// - Any series type can be used wherever FusionSeries is expected
///
/// ## Series Types
///
/// - [FusionLineSeries] - For line charts
/// - [FusionBarSeries] - For bar charts
/// - [FusionAreaSeries] - For area charts
/// - [FusionPieSeries] - For pie charts
/// - [FusionScatterSeries] - For scatter charts
///
/// ## Properties
///
/// All series share these common properties:
/// - [name] - Display name for the series
/// - [color] - Primary color for the series
/// - [visible] - Whether the series is currently visible
@immutable
abstract class FusionSeries {
  /// Creates a base series.
  ///
  /// The [name] and [color] parameters are required.
  /// The [visible] parameter defaults to `true`.
  const FusionSeries({required this.name, required this.color, this.visible = true});

  /// The display name of this series.
  ///
  /// Used in:
  /// - Legend labels
  /// - Tooltips
  /// - Accessibility descriptions
  ///
  /// Example: "Revenue", "Profit", "Q1 Sales"
  final String name;

  /// The primary color for this series.
  ///
  /// This color is used for:
  /// - Line color (in line charts)
  /// - Bar fill color (in bar charts)
  /// - Area fill (in area charts)
  /// - Markers and data labels
  final Color color;

  /// Whether this series is visible on the chart.
  ///
  /// When `false`, the series is hidden but still exists in the data.
  /// Useful for:
  /// - Legend toggle functionality
  /// - Conditional visibility based on user preferences
  /// - Animation effects (fade in/out)
  ///
  /// Default: `true`
  final bool visible;

  /// Creates a copy of this series with modified values.
  ///
  /// Subclasses must implement this method to support immutability.
  FusionSeries copyWith({String? name, Color? color, bool? visible});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionSeries &&
        other.name == name &&
        other.color == color &&
        other.visible == visible;
  }

  @override
  int get hashCode => Object.hash(name, color, visible);

  @override
  String toString() => 'FusionSeries(name: $name, visible: $visible)';
}

/// Mixin for series that support gradients.
///
/// Provides gradient functionality that can be mixed into series classes.
mixin FusionGradientSupport {
  /// The gradient to apply to this series.
  ///
  /// If `null`, uses solid color instead.
  LinearGradient? get gradient;

  /// Creates a gradient from the series color.
  ///
  /// Generates a gradient from full opacity to [opacity] of the series color.
  LinearGradient createDefaultGradient(
    Color baseColor, {
    double opacity = 0.1,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [
        baseColor,
        baseColor.withValues(alpha: opacity),
      ],
      begin: begin,
      end: end,
    );
  }
}

/// Mixin for series that support markers.
///
/// Provides marker display functionality.
mixin FusionMarkerSupport {
  /// Whether to show markers at data points.
  bool get showMarkers => false;

  /// Size (radius) of the marker in logical pixels.
  ///
  /// Default: 6.0
  /// Range: 2.0 - 20.0 (recommended)
  double get markerSize => 6.0;

  /// Color of the marker.
  ///
  /// If null, uses the series color.
  Color? get markerColor => null;

  /// Shape of the marker.
  ///
  /// Default: [MarkerShape.circle]
  MarkerShape get markerShape => MarkerShape.circle;

  /// Border color around the marker.
  ///
  /// If null, no border is drawn.
  Color? get markerBorderColor => null;

  /// Width of the marker border.
  ///
  /// Only used if [markerBorderColor] is not null.
  ///
  /// Default: 1.0
  double get markerBorderWidth => 1.0;
}

/// Mixin for series that support shadows.
mixin FusionShadowSupport {
  /// Whether to show shadow on the series.
  bool get showShadow;

  /// The shadow configuration.
  BoxShadow? get shadow;
}

/// Mixin for series that support data labels.
mixin FusionDataLabelSupport {
  /// Whether to show data labels.
  bool get showDataLabels;

  /// Which data points should display labels.
  ///
  /// - [FusionDataLabelDisplay.all] - All points (default)
  /// - [FusionDataLabelDisplay.maxOnly] - Only maximum value
  /// - [FusionDataLabelDisplay.minOnly] - Only minimum value
  /// - [FusionDataLabelDisplay.maxAndMin] - Both extremes
  /// - [FusionDataLabelDisplay.firstAndLast] - First and last points
  /// - [FusionDataLabelDisplay.none] - No labels
  FusionDataLabelDisplay get dataLabelDisplay => FusionDataLabelDisplay.all;

  /// Text style for data labels.
  TextStyle? get dataLabelStyle;

  /// Custom formatter for data label text.
  String Function(double value)? get dataLabelFormatter;
}

/// Mixin for series with animation support.
mixin FusionAnimationSupport {
  /// Duration of the series animation.
  ///
  /// If `null`, uses the chart's default animation duration.
  Duration? get animationDuration;

  /// Animation curve for the series.
  ///
  /// If `null`, uses the chart's default animation curve.
  Curve? get animationCurve;

  /// Delay before starting the animation.
  ///
  /// Useful for staggered animations in multi-series charts.
  Duration get animationDelay => Duration.zero;
}

/// Configuration for series interaction behavior.
class FusionSeriesInteraction {
  /// Creates an interaction configuration.
  const FusionSeriesInteraction({
    this.selectable = true,
    this.highlightOnHover = true,
    this.showTooltip = true,
    this.enableSelection = true,
  });

  /// Whether this series can be selected.
  final bool selectable;

  /// Whether to highlight the series on hover.
  final bool highlightOnHover;

  /// Whether to show tooltip for this series.
  final bool showTooltip;

  /// Whether clicking enables selection.
  final bool enableSelection;

  /// Creates a copy with modified values.
  FusionSeriesInteraction copyWith({
    bool? selectable,
    bool? highlightOnHover,
    bool? showTooltip,
    bool? enableSelection,
  }) {
    return FusionSeriesInteraction(
      selectable: selectable ?? this.selectable,
      highlightOnHover: highlightOnHover ?? this.highlightOnHover,
      showTooltip: showTooltip ?? this.showTooltip,
      enableSelection: enableSelection ?? this.enableSelection,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionSeriesInteraction &&
        other.selectable == selectable &&
        other.highlightOnHover == highlightOnHover &&
        other.showTooltip == showTooltip &&
        other.enableSelection == enableSelection;
  }

  @override
  int get hashCode => Object.hash(selectable, highlightOnHover, showTooltip, enableSelection);
}

/// Extension methods for lists of series.
extension FusionSeriesListExtensions on List<FusionSeries> {
  /// Returns only visible series.
  List<FusionSeries> get visibleOnly {
    return where((series) => series.visible).toList();
  }

  /// Returns series with a specific name.
  FusionSeries? findByName(String name) {
    try {
      return firstWhere((series) => series.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Checks if all series are visible.
  bool get allVisible => every((series) => series.visible);

  /// Checks if any series is visible.
  bool get anyVisible => any((series) => series.visible);

  /// Count of visible series.
  int get visibleCount => where((series) => series.visible).length;

  /// Toggles visibility of a series by name.
  ///
  /// Returns a new list with the series visibility toggled.
  List<FusionSeries> toggleVisibility(String name) {
    return map((series) {
      if (series.name == name) {
        return series.copyWith(visible: !series.visible);
      }
      return series;
    }).toList();
  }
}

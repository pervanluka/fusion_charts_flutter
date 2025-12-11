import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/series/series_with_data_points.dart';
import '../core/enums/marker_shape.dart';
import '../data/fusion_data_point.dart';
import 'fusion_series.dart';

/// Line series for line charts.
///
/// Displays data as a series of points connected by straight or curved lines.
/// Perfect for showing trends, patterns, and changes over time.
///
/// ## Example
///
/// ```dart
/// FusionLineSeries(
///   name: 'Revenue',
///   dataPoints: [
///     FusionDataPoint(0, 10),
///     FusionDataPoint(1, 15),
///     FusionDataPoint(2, 12),
///     FusionDataPoint(3, 18),
///   ],
///   color: Colors.blue,
///   isCurved: true,
///   showArea: true,
/// )
/// ```
///
/// ## Features
///
/// - Straight or curved lines
/// - Optional area fill below the line
/// - Gradient support
/// - Markers on data points
/// - Shadows for depth
/// - Smooth animations
@immutable
class FusionLineSeries extends FusionSeries
    with
        FusionGradientSupport,
        FusionMarkerSupport,
        FusionShadowSupport,
        FusionDataLabelSupport,
        FusionAnimationSupport
    implements SeriesWithDataPoints {
  /// Creates a line series.
  const FusionLineSeries({
    required this.dataPoints,
    required super.name,
    required super.color,
    super.visible,
    this.lineWidth = 3.0,
    this.isCurved = true,
    this.smoothness = 0.35,
    this.lineDashArray,
    this.gradient,
    this.showMarkers = false,
    this.markerSize = 6.0,
    this.markerShape = MarkerShape.circle,
    this.showShadow = true,
    this.shadow,
    this.showArea = false,
    this.areaOpacity = 0.3,
    this.showDataLabels = false,
    this.dataLabelStyle,
    this.dataLabelFormatter,
    this.animationDuration,
    this.animationCurve,
    this.interaction = const FusionSeriesInteraction(),
  }) : assert(lineWidth > 0 && lineWidth <= 10, 'Line width must be between 0 and 10'),
       assert(smoothness >= 0 && smoothness <= 1, 'Curve smoothness must be between 0 and 1'),
       assert(markerSize > 0 && markerSize <= 20, 'Marker size must be between 0 and 20'),
       assert(areaOpacity >= 0 && areaOpacity <= 1, 'Area opacity must be between 0 and 1');

  /// The data points to be displayed in this series.
  ///
  /// Each point represents a position on the chart.
  /// Points are typically sorted by x value for best results.
  @override
  final List<FusionDataPoint> dataPoints;

  // ==========================================================================
  // LINE PROPERTIES
  // ==========================================================================

  /// Width of the line.
  ///
  /// Thicker lines are more prominent but can clutter dense data.
  ///
  /// Range: 1.0-10.0
  /// Default: 3.0
  final double lineWidth;

  /// Whether to draw curved lines between points.
  ///
  /// When `true`, uses smooth Bezier curves
  /// When `false`, uses straight lines
  ///
  /// Default: `true`
  final bool isCurved;

  /// Smoothness of the curve.
  ///
  /// Only applies when [isCurved] is `true`.
  ///
  /// - 0.0 = Almost straight lines
  /// - 0.35 = Balanced
  /// - 1.0 = Very smooth, flowing curves
  ///
  /// Range: 0.0-1.0
  /// Default: 0.35
  final double smoothness;

  /// Dash pattern for the line.
  ///
  /// ## Examples:
  ///
  /// ```dart
  /// // Dashed line
  /// lineDashArray: [10, 5]  // 10px dash, 5px gap
  ///
  /// // Dotted line
  /// lineDashArray: [2, 3]   // 2px dot, 3px gap
  ///
  /// // Complex pattern
  /// lineDashArray: [10, 5, 2, 5]  // Long dash, gap, dot, gap
  ///
  /// // Solid line (default)
  /// lineDashArray: null
  /// ```
  ///
  /// If null, line is solid.
  final List<double>? lineDashArray;

  // ==========================================================================
  // GRADIENT
  // ==========================================================================

  @override
  final LinearGradient? gradient;

  // ==========================================================================
  // MARKERS
  // ==========================================================================

  @override
  final bool showMarkers;

  @override
  final double markerSize;

  @override
  final MarkerShape markerShape;

  // ==========================================================================
  // SHADOW
  // ==========================================================================

  @override
  final bool showShadow;

  @override
  final BoxShadow? shadow;

  // ==========================================================================
  // AREA FILL
  // ==========================================================================

  /// Whether to fill the area below the line.
  ///
  /// When `true`, creates an area chart effect.
  /// The area uses the same color/gradient as the line but with reduced opacity.
  ///
  /// Default: `false`
  final bool showArea;

  /// Opacity of the area fill.
  ///
  /// Only applies when [showArea] is `true`.
  ///
  /// Range: 0.0 (transparent) - 1.0 (opaque)
  /// Default: 0.3
  final double areaOpacity;

  // ==========================================================================
  // DATA LABELS
  // ==========================================================================

  @override
  final bool showDataLabels;

  @override
  final TextStyle? dataLabelStyle;

  @override
  final String Function(double value)? dataLabelFormatter;

  // ==========================================================================
  // ANIMATION
  // ==========================================================================

  @override
  final Duration? animationDuration;

  @override
  final Curve? animationCurve;

  // ==========================================================================
  // INTERACTION
  // ==========================================================================

  /// Interaction configuration for this series.
  final FusionSeriesInteraction interaction;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Whether this series has any data points.
  bool get hasData => dataPoints.isNotEmpty;

  /// Number of data points in this series.
  int get pointCount => dataPoints.length;

  /// Minimum x value in this series.
  double? get minX => dataPoints.minX;

  /// Maximum x value in this series.
  double? get maxX => dataPoints.maxX;

  /// Minimum y value in this series.
  double? get minY => dataPoints.minY;

  /// Maximum y value in this series.
  double? get maxY => dataPoints.maxY;

  /// Average y value in this series.
  double? get averageY => dataPoints.averageY;

  // ==========================================================================
  // METHODS
  // ==========================================================================

  @override
  FusionLineSeries copyWith({
    List<FusionDataPoint>? dataPoints,
    String? name,
    Color? color,
    bool? visible,
    double? lineWidth,
    bool? isCurved,
    double? smoothness,
    List<double>? lineDashArray,
    LinearGradient? gradient,
    bool? showMarkers,
    double? markerSize,
    MarkerShape? markerShape,
    bool? showShadow,
    BoxShadow? shadow,
    bool? showArea,
    double? areaOpacity,
    bool? showDataLabels,
    TextStyle? dataLabelStyle,
    String Function(double)? dataLabelFormatter,
    Duration? animationDuration,
    Curve? animationCurve,
    FusionSeriesInteraction? interaction,
  }) {
    return FusionLineSeries(
      dataPoints: dataPoints ?? this.dataPoints,
      name: name ?? this.name,
      color: color ?? this.color,
      visible: visible ?? this.visible,
      lineWidth: lineWidth ?? this.lineWidth,
      isCurved: isCurved ?? this.isCurved,
      smoothness: smoothness ?? this.smoothness,
      lineDashArray: lineDashArray ?? this.lineDashArray,
      gradient: gradient ?? this.gradient,
      showMarkers: showMarkers ?? this.showMarkers,
      markerSize: markerSize ?? this.markerSize,
      markerShape: markerShape ?? this.markerShape,
      showShadow: showShadow ?? this.showShadow,
      shadow: shadow ?? this.shadow,
      showArea: showArea ?? this.showArea,
      areaOpacity: areaOpacity ?? this.areaOpacity,
      showDataLabels: showDataLabels ?? this.showDataLabels,
      dataLabelStyle: dataLabelStyle ?? this.dataLabelStyle,
      dataLabelFormatter: dataLabelFormatter ?? this.dataLabelFormatter,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      interaction: interaction ?? this.interaction,
    );
  }

  /// Filters data points within a range.
  ///
  /// Useful for viewport culling and zoom operations.
  FusionLineSeries filterByRange(double minX, double maxX) {
    final filtered = dataPoints.where((p) => p.x >= minX && p.x <= maxX).toList();
    return copyWith(dataPoints: filtered);
  }

  /// Sorts data points by x coordinate.
  FusionLineSeries sortByX() {
    return copyWith(dataPoints: dataPoints.sortByX());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionLineSeries &&
        listEquals(other.dataPoints, dataPoints) &&
        listEquals(other.lineDashArray, lineDashArray) &&
        other.name == name &&
        other.color == color &&
        other.visible == visible &&
        other.lineWidth == lineWidth &&
        other.isCurved == isCurved &&
        other.smoothness == smoothness &&
        other.gradient == gradient &&
        other.showMarkers == showMarkers &&
        other.markerSize == markerSize &&
        other.markerShape == markerShape &&
        other.showShadow == showShadow &&
        other.shadow == shadow &&
        other.showDataLabels == showDataLabels &&
        other.dataLabelStyle == dataLabelStyle &&
        other.dataLabelFormatter == dataLabelFormatter &&
        other.animationCurve == animationCurve &&
        other.animationDuration == animationDuration &&
        other.interaction == interaction &&
        other.showArea == showArea &&
        other.areaOpacity == areaOpacity;
  }

  @override
  int get hashCode => Object.hashAll([
    Object.hashAll(dataPoints),
    name,
    color,
    visible,
    lineWidth,
    isCurved,
    smoothness,
    Object.hashAll(lineDashArray ?? []),
    showMarkers,
    markerSize,
    markerShape,
    markerColor,
    showArea,
    areaOpacity,
    gradient,
    shadow,
    showShadow,
    showDataLabels,
    dataLabelStyle,
    dataLabelFormatter,
    animationDuration,
    animationCurve,
    interaction,
  ]);

  @override
  String toString() {
    return 'FusionLineSeries('
        'name: $name, '
        'points: ${dataPoints.length}, '
        'curved: $isCurved, '
        'visible: $visible'
        ')';
  }
}

import 'package:flutter/material.dart';
import '../data/fusion_data_point.dart';
import 'fusion_series.dart';
import 'series_with_data_points.dart';

/// Bar series for bar charts.
///
/// Displays data as vertical or horizontal bars.
/// Perfect for comparing values across categories.
///
/// ## Example
///
/// ```dart
/// FusionBarSeries(
///   name: 'Sales',
///   dataPoints: [
///     FusionDataPoint(0, 10, label: 'Q1'),
///     FusionDataPoint(1, 15, label: 'Q2'),
///     FusionDataPoint(2, 12, label: 'Q3'),
///     FusionDataPoint(3, 18, label: 'Q4'),
///   ],
///   color: Colors.blue,
///   barWidth: 0.6,
/// )
/// ```
///
/// ## Features
///
/// - Vertical or horizontal orientation
/// - Customizable bar width
/// - Rounded corners
/// - Gradient support
/// - Spacing control
/// - Border styling
/// - Shadows for depth
@immutable
class FusionBarSeries extends FusionSeries
    with FusionGradientSupport, FusionShadowSupport, FusionDataLabelSupport, FusionAnimationSupport
    implements SeriesWithDataPoints {
  /// Creates a bar series.
  const FusionBarSeries({
    required this.dataPoints,
    required super.color,
    super.name,
    super.visible,
    this.barWidth = 0.6,
    this.borderRadius = 4.0,
    this.spacing = 0.2,
    this.gradient,
    this.borderColor,
    this.borderWidth = 0.0,
    this.showShadow = true,
    this.shadow,
    this.showDataLabels = false,
    this.dataLabelStyle,
    this.dataLabelFormatter,
    this.animationDuration,
    this.animationCurve,
    this.isVertical = true,
    this.isTrackVisible = false,
    this.trackColor,
    this.trackBorderWidth = 0.0,
    this.trackBorderColor,
    this.trackPadding = 0.0,
    this.interaction = const FusionSeriesInteraction(),
  }) : assert(barWidth > 0 && barWidth <= 1.0, 'Bar width must be between 0 and 1'),
       assert(spacing >= 0 && spacing < 1.0, 'Spacing must be between 0 and 1'),
       assert(borderRadius >= 0, 'Border radius must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative'),
       assert(trackBorderWidth >= 0, 'Track border width must be non-negative'),
       assert(trackPadding >= 0, 'Track padding must be non-negative');

  /// The data points to be displayed in this series.
  @override
  final List<FusionDataPoint> dataPoints;

  // ==========================================================================
  // BAR PROPERTIES
  // ==========================================================================

  /// Width of bars as a fraction of available space.
  ///
  /// - 1.0 = bars touch each other (no gap)
  /// - 0.6 = bars use 60% of space (40% gap)
  /// - 0.4 = bars use 40% of space (60% gap)
  ///
  /// Range: 0.0-1.0
  /// Default: 0.6
  final double barWidth;

  /// Corner radius of the bars.
  ///
  /// Creates rounded corners at the top of vertical bars
  /// or at the end of horizontal bars.
  ///
  /// Range: 0.0-20.0
  /// Default: 4.0
  final double borderRadius;

  /// Spacing between bars in the same category.
  ///
  /// Only relevant when multiple series are shown.
  ///
  /// Range: 0.0-1.0
  /// Default: 0.2 (20% of bar width)
  final double spacing;

  /// Whether bars are vertical (column chart) or horizontal (bar chart).
  ///
  /// - `true`: Vertical bars (column chart)
  /// - `false`: Horizontal bars (bar chart)
  ///
  /// Default: `true`
  final bool isVertical;

  // ==========================================================================
  // TRACK (BACKGROUND BAR)
  // ==========================================================================

  /// Whether to show a track (background bar) behind each bar.
  ///
  /// Tracks are rectangular bars rendered from the start to the end of the axis.
  /// Useful for showing progress, capacity, or range.
  ///
  /// Default: `false`
  final bool isTrackVisible;

  /// Color of the track bar.
  ///
  /// Only visible when [isTrackVisible] is `true`.
  ///
  /// Default: `Colors.grey.withOpacity(0.2)`
  final Color? trackColor;

  /// Border width of the track bar.
  ///
  /// Default: `0.0` (no border)
  final double trackBorderWidth;

  /// Border color of the track bar.
  ///
  /// Only visible when [trackBorderWidth] > 0.
  final Color? trackBorderColor;

  /// Padding inside the track bar.
  ///
  /// Creates space between the track edges and the bar.
  ///
  /// Default: `0.0`
  final double trackPadding;

  // ==========================================================================
  // GRADIENT
  // ==========================================================================

  @override
  final LinearGradient? gradient;

  // ==========================================================================
  // BORDER
  // ==========================================================================

  /// Border color of the bars.
  ///
  /// If null, no border is drawn.
  final Color? borderColor;

  /// Width of the bar border.
  ///
  /// Range: 0.0-5.0
  /// Default: 0.0 (no border)
  final double borderWidth;

  // ==========================================================================
  // SHADOW
  // ==========================================================================

  @override
  final bool showShadow;

  @override
  final BoxShadow? shadow;

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

  /// Total sum of y values.
  double get sum => dataPoints.sumY;

  // ==========================================================================
  // METHODS
  // ==========================================================================

  @override
  FusionBarSeries copyWith({
    List<FusionDataPoint>? dataPoints,
    String? name,
    Color? color,
    bool? visible,
    double? barWidth,
    double? borderRadius,
    double? spacing,
    LinearGradient? gradient,
    Color? borderColor,
    double? borderWidth,
    bool? showShadow,
    BoxShadow? shadow,
    bool? showDataLabels,
    TextStyle? dataLabelStyle,
    String Function(double)? dataLabelFormatter,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? isVertical,
    bool? isTrackVisible,
    Color? trackColor,
    double? trackBorderWidth,
    Color? trackBorderColor,
    double? trackPadding,
    FusionSeriesInteraction? interaction,
  }) {
    return FusionBarSeries(
      dataPoints: dataPoints ?? this.dataPoints,
      name: name ?? this.name,
      color: color ?? this.color,
      visible: visible ?? this.visible,
      barWidth: barWidth ?? this.barWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      spacing: spacing ?? this.spacing,
      gradient: gradient ?? this.gradient,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showShadow: showShadow ?? this.showShadow,
      shadow: shadow ?? this.shadow,
      showDataLabels: showDataLabels ?? this.showDataLabels,
      dataLabelStyle: dataLabelStyle ?? this.dataLabelStyle,
      dataLabelFormatter: dataLabelFormatter ?? this.dataLabelFormatter,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      isVertical: isVertical ?? this.isVertical,
      isTrackVisible: isTrackVisible ?? this.isTrackVisible,
      trackColor: trackColor ?? this.trackColor,
      trackBorderWidth: trackBorderWidth ?? this.trackBorderWidth,
      trackBorderColor: trackBorderColor ?? this.trackBorderColor,
      trackPadding: trackPadding ?? this.trackPadding,
      interaction: interaction ?? this.interaction,
    );
  }

  /// Filters data points within a range.
  FusionBarSeries filterByRange(double minX, double maxX) {
    final filtered = dataPoints.where((p) => p.x >= minX && p.x <= maxX).toList();
    return copyWith(dataPoints: filtered);
  }

  /// Sorts data points by x coordinate.
  FusionBarSeries sortByX() {
    return copyWith(dataPoints: dataPoints.sortByX());
  }

  /// Sorts data points by y coordinate (value).
  FusionBarSeries sortByY({bool descending = false}) {
    final sorted = dataPoints.sortByY();
    return copyWith(dataPoints: descending ? sorted.reversed.toList() : sorted);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionBarSeries &&
        other.name == name &&
        other.color == color &&
        other.visible == visible &&
        other.barWidth == barWidth &&
        other.borderRadius == borderRadius &&
        other.spacing == spacing &&
        other.isVertical == isVertical;
  }

  @override
  int get hashCode =>
      Object.hash(name, color, visible, barWidth, borderRadius, spacing, isVertical);

  @override
  String toString() {
    return 'FusionBarSeries('
        'name: $name, '
        'points: ${dataPoints.length}, '
        'vertical: $isVertical, '
        'visible: $visible'
        ')';
  }
}

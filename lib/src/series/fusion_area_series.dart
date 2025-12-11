import 'package:flutter/material.dart';
import '../core/enums/marker_shape.dart';
import 'fusion_series.dart';
import 'series_with_data_points.dart';
import '../data/fusion_data_point.dart';

/// Area series for area charts.
///
/// Displays data as a filled area beneath a line.
/// Perfect for showing trends and cumulative values.
///
/// ## Features
///
/// - Smooth or linear curves
/// - Gradient fills
/// - Border customization
/// - Optional markers
/// - Optional data labels
///
/// ## Example
///
/// ```dart
/// FusionAreaSeries(
///   name: 'Revenue',
///   dataPoints: [
///     FusionDataPoint(0, 100),
///     FusionDataPoint(1, 150),
///     FusionDataPoint(2, 120),
///   ],
///   color: Colors.blue,
///   opacity: 0.3,
///   isCurved: true,
///   showMarkers: true,
/// )
/// ```
class FusionAreaSeries extends FusionSeries
    with FusionMarkerSupport, FusionDataLabelSupport
    implements SeriesWithDataPoints {
  const FusionAreaSeries({
    required super.name,
    required super.color,
    required this.dataPoints,
    super.visible = true,
    this.opacity = 0.5,
    this.isCurved = true,
    this.smoothness = 0.35,
    this.borderWidth = 2.0,
    this.borderColor,
    this.gradient,
    // Marker properties
    this.showMarkers = false,
    this.markerSize = 6.0,
    this.markerColor,
    this.markerShape = MarkerShape.circle,
    this.markerBorderColor,
    this.markerBorderWidth = 1.0,
    // Data label properties
    this.showDataLabels = false,
    this.dataLabelStyle,
    this.dataLabelFormatter,
  });

  @override
  final List<FusionDataPoint> dataPoints;

  /// Opacity of the area fill (0.0 - 1.0).
  final double opacity;

  /// Whether to use curved (smooth) lines.
  final bool isCurved;

  /// Smoothness of the curve (0.0 - 1.0).
  ///
  /// Only used when [isCurved] is true.
  /// - 0.0: Nearly linear
  /// - 0.35: Default smoothness
  /// - 1.0: Maximum smoothness
  final double smoothness;

  /// Width of the border line.
  final double borderWidth;

  /// Color of the border line.
  ///
  /// If null, uses the series color.
  final Color? borderColor;

  /// Gradient for area fill.
  ///
  /// If provided, overrides the solid [color] fill.
  final LinearGradient? gradient;

  // Marker properties (override mixin getters)
  @override
  final bool showMarkers;

  @override
  final double markerSize;

  @override
  final Color? markerColor;

  @override
  final MarkerShape markerShape;

  @override
  final Color? markerBorderColor;

  @override
  final double markerBorderWidth;

  // Data label properties (override mixin getters)
  @override
  final bool showDataLabels;

  @override
  final TextStyle? dataLabelStyle;

  @override
  final String Function(double)? dataLabelFormatter;

  @override
  FusionAreaSeries copyWith({
    String? name,
    Color? color,
    List<FusionDataPoint>? dataPoints,
    bool? visible,
    double? opacity,
    bool? isCurved,
    double? smoothness,
    double? borderWidth,
    Color? borderColor,
    LinearGradient? gradient,
    bool? showMarkers,
    double? markerSize,
    Color? markerColor,
    MarkerShape? markerShape,
    Color? markerBorderColor,
    double? markerBorderWidth,
    bool? showDataLabels,
    TextStyle? dataLabelStyle,
    String Function(double)? dataLabelFormatter,
  }) {
    return FusionAreaSeries(
      name: name ?? this.name,
      color: color ?? this.color,
      dataPoints: dataPoints ?? this.dataPoints,
      visible: visible ?? this.visible,
      opacity: opacity ?? this.opacity,
      isCurved: isCurved ?? this.isCurved,
      smoothness: smoothness ?? this.smoothness,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      gradient: gradient ?? this.gradient,
      showMarkers: showMarkers ?? this.showMarkers,
      markerSize: markerSize ?? this.markerSize,
      markerColor: markerColor ?? this.markerColor,
      markerShape: markerShape ?? this.markerShape,
      markerBorderColor: markerBorderColor ?? this.markerBorderColor,
      markerBorderWidth: markerBorderWidth ?? this.markerBorderWidth,
      showDataLabels: showDataLabels ?? this.showDataLabels,
      dataLabelStyle: dataLabelStyle ?? this.dataLabelStyle,
      dataLabelFormatter: dataLabelFormatter ?? this.dataLabelFormatter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionAreaSeries &&
        other.name == name &&
        other.color == color &&
        other.visible == visible &&
        other.dataPoints == dataPoints &&
        other.opacity == opacity &&
        other.isCurved == isCurved &&
        other.smoothness == smoothness &&
        other.borderWidth == borderWidth &&
        other.borderColor == borderColor &&
        other.gradient == gradient &&
        other.showMarkers == showMarkers &&
        other.markerSize == markerSize &&
        other.markerColor == markerColor &&
        other.markerShape == markerShape &&
        other.showDataLabels == showDataLabels;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      color,
      visible,
      dataPoints,
      opacity,
      isCurved,
      smoothness,
      borderWidth,
      borderColor,
      gradient,
      showMarkers,
      markerSize,
      markerColor,
      markerShape,
      showDataLabels,
    );
  }
}

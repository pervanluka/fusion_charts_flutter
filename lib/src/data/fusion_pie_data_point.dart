import 'package:flutter/material.dart';

/// A data point representing a single slice in a pie/donut chart.
///
/// ## Design Philosophy
///
/// Flat properties matching line/bar series patterns. No nested style objects.
/// Simple, predictable, easy to use.
///
/// ## Style Cascade
///
/// Colors are resolved in order (first non-null wins):
/// 1. DataPoint.color (per-slice)
/// 2. Series.colorPalette at index (auto-assigned)
/// 3. Theme.colorPalette at index (fallback)
///
/// ## Example
///
/// ```dart
/// // Simple slice
/// FusionPieDataPoint(35, label: 'Sales')
///
/// // Colored slice
/// FusionPieDataPoint(
///   35,
///   label: 'Sales',
///   color: Colors.blue,
/// )
///
/// // Fully styled slice
/// FusionPieDataPoint(
///   35,
///   label: 'Revenue',
///   color: Colors.blue,
///   gradient: RadialGradient(
///     colors: [Colors.blue.shade300, Colors.blue.shade800],
///   ),
///   borderColor: Colors.white,
///   borderWidth: 2.0,
///   cornerRadius: 8.0,
///   shadow: BoxShadow(
///     color: Colors.black26,
///     blurRadius: 8,
///     offset: Offset(2, 4),
///   ),
///   explode: true,
/// )
/// ```
@immutable
class FusionPieDataPoint {
  /// Creates a pie chart data point.
  const FusionPieDataPoint(
    this.value, {
    this.label,
    // === VISUAL (flat, like line/bar) ===
    this.color,
    this.gradient,
    this.borderColor,
    this.borderWidth = 0.0,
    this.cornerRadius = 0.0,
    this.shadow,
    // === EXPLODE ===
    this.explode = false,
    this.explodeOffset,
    // === STATE ===
    this.enabled = true,
    this.visible = true,
    // === CALLBACKS ===
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
    // === TOOLTIP ===
    this.tooltip,
    // === METADATA ===
    this.metadata,
  }) : assert(value >= 0, 'Value must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative'),
       assert(cornerRadius >= 0, 'Corner radius must be non-negative');

  // ===========================================================================
  // CORE DATA
  // ===========================================================================

  /// The numeric value of this slice.
  ///
  /// Percentage is calculated as: `value / sum(allValues) * 100`
  final double value;

  /// Optional label (e.g., "Sales", "Q1 2024").
  ///
  /// Used in tooltips, labels, and legends.
  final String? label;

  /// Optional metadata for custom data binding.
  ///
  /// Useful for storing original data objects, IDs, etc.
  /// Accessible in callbacks and tooltip builders.
  final Object? metadata;

  // ===========================================================================
  // VISUAL STYLE (FLAT - matches line/bar pattern)
  // ===========================================================================

  /// Solid fill color for this slice.
  ///
  /// If null, color is assigned from series palette.
  /// Ignored if [gradient] is provided.
  final Color? color;

  /// Gradient fill for this slice.
  ///
  /// Takes precedence over [color] if both are set.
  /// Use RadialGradient for pie-appropriate effect.
  final Gradient? gradient;

  /// Border/stroke color around the slice.
  ///
  /// Only visible when [borderWidth] > 0.
  final Color? borderColor;

  /// Border/stroke width in logical pixels.
  ///
  /// Default: 0.0 (no border)
  final double borderWidth;

  /// Corner radius for rounded slice edges.
  ///
  /// Applied to all corners of the slice uniformly.
  /// Default: 0.0 (sharp corners)
  final double cornerRadius;

  /// Shadow behind the slice.
  ///
  /// Uses Flutter's built-in BoxShadow for consistency.
  final BoxShadow? shadow;

  // ===========================================================================
  // EXPLODE
  // ===========================================================================

  /// Whether this slice is exploded (pulled out from center).
  ///
  /// Default: false
  final bool explode;

  /// Distance to explode in logical pixels.
  ///
  /// If null, uses series.explodeOffset or config.explodeOffset.
  final double? explodeOffset;

  // ===========================================================================
  // STATE
  // ===========================================================================

  /// Whether this slice responds to interactions.
  ///
  /// Disabled slices ignore taps and hover events.
  /// Default: true
  final bool enabled;

  /// Whether this slice is rendered.
  ///
  /// Hidden slices still contribute to total for percentage calculations
  /// but are not visible on the chart.
  /// Default: true
  final bool visible;

  // ===========================================================================
  // CALLBACKS
  // ===========================================================================

  /// Called when this slice is tapped.
  final void Function(FusionPieDataPoint point, int index)? onTap;

  /// Called when this slice is double-tapped.
  final void Function(FusionPieDataPoint point, int index)? onDoubleTap;

  /// Called when this slice is long-pressed.
  final void Function(FusionPieDataPoint point, int index)? onLongPress;

  /// Called when hover state changes (desktop/web).
  final void Function(FusionPieDataPoint point, int index, bool isHovered)?
  onHover;

  // ===========================================================================
  // TOOLTIP
  // ===========================================================================

  /// Custom tooltip content.
  ///
  /// If null, uses default tooltip formatting.
  /// Can be a String or Widget.
  final dynamic tooltip;

  // ===========================================================================
  // COMPUTED
  // ===========================================================================

  /// Whether this slice has a border.
  bool get hasBorder => borderWidth > 0 && borderColor != null;

  /// Whether this slice has a shadow.
  bool get hasShadow => shadow != null;

  /// Whether this slice uses gradient fill.
  bool get hasGradient => gradient != null;

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  /// Creates a copy with modified properties.
  FusionPieDataPoint copyWith({
    double? value,
    String? label,
    Color? color,
    Gradient? gradient,
    Color? borderColor,
    double? borderWidth,
    double? cornerRadius,
    BoxShadow? shadow,
    bool? explode,
    double? explodeOffset,
    bool? enabled,
    bool? visible,
    void Function(FusionPieDataPoint, int)? onTap,
    void Function(FusionPieDataPoint, int)? onDoubleTap,
    void Function(FusionPieDataPoint, int)? onLongPress,
    void Function(FusionPieDataPoint, int, bool)? onHover,
    dynamic tooltip,
    Object? metadata,
  }) {
    return FusionPieDataPoint(
      value ?? this.value,
      label: label ?? this.label,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      shadow: shadow ?? this.shadow,
      explode: explode ?? this.explode,
      explodeOffset: explodeOffset ?? this.explodeOffset,
      enabled: enabled ?? this.enabled,
      visible: visible ?? this.visible,
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onHover: onHover ?? this.onHover,
      tooltip: tooltip ?? this.tooltip,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionPieDataPoint &&
        other.value == value &&
        other.label == label &&
        other.color == color &&
        other.gradient == gradient &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.cornerRadius == cornerRadius &&
        other.explode == explode &&
        other.visible == visible;
  }

  @override
  int get hashCode => Object.hash(
    value,
    label,
    color,
    gradient,
    borderColor,
    borderWidth,
    cornerRadius,
    explode,
    visible,
  );

  @override
  String toString() => 'FusionPieDataPoint(value: $value, label: $label)';
}

import 'package:flutter/material.dart';

/// Configuration for chart legend.
///
/// Controls appearance, position, and behavior of the chart legend
/// that identifies different series.
///
/// ## Example
///
/// ```dart
/// final legendConfig = FusionLegendConfiguration(
///   visible: true,
///   position: FusionLegendPosition.bottom,
///   alignment: FusionLegendAlignment.center,
///   orientation: FusionLegendOrientation.horizontal,
///   itemBuilder: (series, index) => Text(series.name),
/// );
/// ```
@immutable
class FusionLegendConfiguration {
  /// Creates a legend configuration.
  const FusionLegendConfiguration({
    this.visible = true,
    this.position = FusionLegendPosition.bottom,
    this.alignment = FusionLegendAlignment.center,
    this.orientation = FusionLegendOrientation.horizontal,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.all(8.0),
    this.margin = const EdgeInsets.all(8.0),
    this.itemSpacing = 16.0,
    this.iconSize = 16.0,
    this.iconPadding = 8.0,
    this.textStyle,
    this.toggleSeriesOnTap = true,
    this.itemBuilder,
    this.maxWidth,
    this.maxHeight,
    this.scrollable = false,
  });

  // ==========================================================================
  // VISIBILITY & LAYOUT
  // ==========================================================================

  /// Whether the legend is visible.
  final bool visible;

  /// Position of the legend relative to the chart.
  final FusionLegendPosition position;

  /// Alignment of legend items within the legend area.
  final FusionLegendAlignment alignment;

  /// Orientation of legend items (horizontal or vertical).
  final FusionLegendOrientation orientation;

  // ==========================================================================
  // APPEARANCE
  // ==========================================================================

  /// Background color of the legend container.
  final Color? backgroundColor;

  /// Border color of the legend container.
  final Color? borderColor;

  /// Border width.
  final double borderWidth;

  /// Corner radius of the legend container.
  final double borderRadius;

  /// Internal padding of the legend container.
  final EdgeInsets padding;

  /// External margin of the legend container.
  final EdgeInsets margin;

  // ==========================================================================
  // ITEM STYLING
  // ==========================================================================

  /// Spacing between legend items.
  final double itemSpacing;

  /// Size of the series color icon.
  final double iconSize;

  /// Spacing between icon and text.
  final double iconPadding;

  /// Text style for legend item labels.
  final TextStyle? textStyle;

  // ==========================================================================
  // INTERACTION
  // ==========================================================================

  /// Whether tapping a legend item toggles series visibility.
  final bool toggleSeriesOnTap;

  // ==========================================================================
  // CUSTOM BUILDER
  // ==========================================================================

  /// Custom builder for legend items.
  ///
  /// If provided, overrides default legend item rendering.
  ///
  /// Example:
  /// ```dart
  /// itemBuilder: (item, index) => Container(
  ///   padding: EdgeInsets.all(8),
  ///   child: Row(
  ///     children: [
  ///       Container(
  ///         width: 20,
  ///         height: 20,
  ///         color: item.color,
  ///       ),
  ///       SizedBox(width: 8),
  ///       Text(item.name),
  ///     ],
  ///   ),
  /// )
  /// ```
  final Widget Function(FusionLegendItem item, int index)? itemBuilder;

  // ==========================================================================
  // SIZE CONSTRAINTS
  // ==========================================================================

  /// Maximum width of the legend.
  ///
  /// If null, legend takes as much width as needed.
  final double? maxWidth;

  /// Maximum height of the legend.
  ///
  /// If null, legend takes as much height as needed.
  final double? maxHeight;

  /// Whether the legend should be scrollable if content exceeds constraints.
  final bool scrollable;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Gets the effective text style.
  TextStyle getEffectiveTextStyle(BuildContext context) {
    return textStyle ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF666666));
  }

  // ==========================================================================
  // METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionLegendConfiguration copyWith({
    bool? visible,
    FusionLegendPosition? position,
    FusionLegendAlignment? alignment,
    FusionLegendOrientation? orientation,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? itemSpacing,
    double? iconSize,
    double? iconPadding,
    TextStyle? textStyle,
    bool? toggleSeriesOnTap,
    Widget Function(FusionLegendItem, int)? itemBuilder,
    double? maxWidth,
    double? maxHeight,
    bool? scrollable,
  }) {
    return FusionLegendConfiguration(
      visible: visible ?? this.visible,
      position: position ?? this.position,
      alignment: alignment ?? this.alignment,
      orientation: orientation ?? this.orientation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      iconSize: iconSize ?? this.iconSize,
      iconPadding: iconPadding ?? this.iconPadding,
      textStyle: textStyle ?? this.textStyle,
      toggleSeriesOnTap: toggleSeriesOnTap ?? this.toggleSeriesOnTap,
      itemBuilder: itemBuilder ?? this.itemBuilder,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      scrollable: scrollable ?? this.scrollable,
    );
  }

  @override
  String toString() => 'FusionLegendConfiguration(visible: $visible, position: $position)';
}

// ==========================================================================
// ENUMS
// ==========================================================================

/// Position of the legend relative to the chart.
enum FusionLegendPosition {
  /// Above the chart.
  top,

  /// Below the chart (default).
  bottom,

  /// Left of the chart.
  left,

  /// Right of the chart.
  right,
}

/// Alignment of legend items within the legend area.
enum FusionLegendAlignment {
  /// Align to start (left for horizontal, top for vertical).
  start,

  /// Align to center (default).
  center,

  /// Align to end (right for horizontal, bottom for vertical).
  end,

  /// Space items evenly.
  spaceBetween,

  /// Space items evenly with space at edges.
  spaceAround,

  /// Space items evenly with equal space.
  spaceEvenly,
}

/// Orientation of legend items.
enum FusionLegendOrientation {
  /// Items arranged horizontally.
  horizontal,

  /// Items arranged vertically.
  vertical,

  /// Automatically choose based on position.
  auto,
}

// ==========================================================================
// DATA MODELS
// ==========================================================================

/// Data for a single legend item.
@immutable
class FusionLegendItem {
  /// Creates a legend item.
  const FusionLegendItem({
    required this.name,
    required this.color,
    required this.visible,
    this.icon,
  });

  /// Display name of the series.
  final String name;

  /// Color of the series.
  final Color color;

  /// Whether the series is currently visible.
  final bool visible;

  /// Optional custom icon widget.
  final Widget? icon;

  @override
  String toString() => 'FusionLegendItem($name, visible: $visible)';
}

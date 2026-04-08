import 'package:flutter/material.dart';
import '../core/enums/fusion_annotation_overlap_strategy.dart';
import '../core/enums/fusion_label_position.dart';

/// A horizontal reference line annotation for charts.
///
/// Renders a dashed (or solid) horizontal line at a specific Y value
/// with an optional label badge. Commonly used for current price,
/// target price, stop loss, or any reference value.
///
/// ```dart
/// FusionReferenceLine(
///   value: 9642.24,
///   label: '9,642.24 €',
///   lineColor: Colors.green,
///   lineDashPattern: [4, 4],
///   labelPosition: FusionLabelPosition.right,
///   labelBackgroundColor: Colors.green,
/// )
/// ```
@immutable
class FusionReferenceLine {
  const FusionReferenceLine({
    required this.value,
    this.label,
    this.lineColor,
    this.lineWidth = 1.0,
    this.lineDashPattern = const [4, 4],
    this.extendToEdge = true,
    this.labelPosition = FusionLabelPosition.right,
    this.labelStyle,
    this.labelBackgroundColor,
    this.labelBorderRadius = 4.0,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.labelMaxWidth,
    this.overlapStrategy = FusionAnnotationOverlapStrategy.annotationWins,
    this.overlapThreshold = 0.02,
    this.visible = true,
  })  : assert(lineWidth > 0, 'lineWidth must be positive'),
        assert(labelBorderRadius >= 0, 'labelBorderRadius must be non-negative'),
        assert(
          overlapThreshold >= 0 && overlapThreshold <= 1,
          'overlapThreshold must be between 0 and 1',
        );

  // ==========================================================================
  // DATA
  // ==========================================================================

  /// The Y-axis data value where the line is drawn.
  final double value;

  /// Optional text label displayed as a badge.
  final String? label;

  // ==========================================================================
  // LINE APPEARANCE
  // ==========================================================================

  /// Color of the reference line. Falls back to theme grid color if null.
  final Color? lineColor;

  /// Width of the reference line in logical pixels.
  final double lineWidth;

  /// Dash pattern as [dashLength, gapLength]. Null for solid line.
  final List<double>? lineDashPattern;

  /// Whether the line extends to the full chart width.
  /// If false, the line only extends to the last data point X position.
  final bool extendToEdge;

  // ==========================================================================
  // LABEL APPEARANCE
  // ==========================================================================

  /// Position of the label badge relative to the line.
  final FusionLabelPosition labelPosition;

  /// Text style for the label. Falls back to theme axis label style if null.
  final TextStyle? labelStyle;

  /// Background color of the label badge. Falls back to line color if null.
  final Color? labelBackgroundColor;

  /// Border radius of the label badge.
  final double labelBorderRadius;

  /// Padding inside the label badge.
  final EdgeInsets labelPadding;

  /// Maximum width for the label text before ellipsis.
  final double? labelMaxWidth;

  // ==========================================================================
  // OVERLAP RESOLUTION
  // ==========================================================================

  /// Strategy for resolving overlap with data labels (max/min markers).
  final FusionAnnotationOverlapStrategy overlapStrategy;

  /// Threshold for detecting overlap as a fraction of the Y range.
  /// Values within this threshold of a data label are considered overlapping.
  final double overlapThreshold;

  // ==========================================================================
  // VISIBILITY
  // ==========================================================================

  /// Whether this reference line is rendered.
  final bool visible;

  /// Returns the effective line color, falling back to the provided theme color.
  Color getEffectiveLineColor(Color themeColor) {
    return lineColor ?? themeColor;
  }

  /// Returns the effective label background color.
  Color getEffectiveLabelBackgroundColor(Color themeColor) {
    return labelBackgroundColor ?? lineColor ?? themeColor;
  }

  /// Creates a copy with the given fields replaced.
  FusionReferenceLine copyWith({
    double? value,
    String? label,
    Color? lineColor,
    double? lineWidth,
    List<double>? lineDashPattern,
    bool? extendToEdge,
    FusionLabelPosition? labelPosition,
    TextStyle? labelStyle,
    Color? labelBackgroundColor,
    double? labelBorderRadius,
    EdgeInsets? labelPadding,
    double? labelMaxWidth,
    FusionAnnotationOverlapStrategy? overlapStrategy,
    double? overlapThreshold,
    bool? visible,
  }) {
    return FusionReferenceLine(
      value: value ?? this.value,
      label: label ?? this.label,
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineDashPattern: lineDashPattern ?? this.lineDashPattern,
      extendToEdge: extendToEdge ?? this.extendToEdge,
      labelPosition: labelPosition ?? this.labelPosition,
      labelStyle: labelStyle ?? this.labelStyle,
      labelBackgroundColor: labelBackgroundColor ?? this.labelBackgroundColor,
      labelBorderRadius: labelBorderRadius ?? this.labelBorderRadius,
      labelPadding: labelPadding ?? this.labelPadding,
      labelMaxWidth: labelMaxWidth ?? this.labelMaxWidth,
      overlapStrategy: overlapStrategy ?? this.overlapStrategy,
      overlapThreshold: overlapThreshold ?? this.overlapThreshold,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionReferenceLine &&
        other.value == value &&
        other.label == label &&
        other.lineColor == lineColor &&
        other.lineWidth == lineWidth &&
        other.visible == visible;
  }

  @override
  int get hashCode => Object.hash(value, label, lineColor, lineWidth, visible);
}

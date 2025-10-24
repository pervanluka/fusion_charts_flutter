import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/src/core/enums/text_anchor.dart';

/// Highlighted region on the chart
///
/// Use cases:
/// - Target zones (e.g., "Healthy range")
/// - Critical thresholds
/// - Weekend highlighting on time charts
class PlotBand {
  const PlotBand({
    this.start,
    this.end,
    this.color,
    this.borderColor,
    this.borderWidth = 0.0,
    this.opacity = 0.5,
    this.text,
    this.textStyle,
    this.textAngle = 0,
    this.horizontalTextAlignment = TextAnchor.middle,
    this.verticalTextAlignment = TextAnchor.middle,
  });

  /// Start value (can be num or DateTime)
  final dynamic start;
  final dynamic end;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double opacity;
  final String? text;
  final TextStyle? textStyle;
  final double textAngle;
  final TextAnchor horizontalTextAlignment;
  final TextAnchor verticalTextAlignment;
}

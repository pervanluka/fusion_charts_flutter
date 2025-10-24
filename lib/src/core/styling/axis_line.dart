import 'package:flutter/material.dart';

/// Customization for the main axis line
class AxisLine {
  const AxisLine({this.width = 1.0, this.color, this.dashArray});

  final double width;
  final Color? color;

  /// Dash pattern [dashLength, gapLength]
  /// Example: [5, 3] creates a dashed line
  final List<double>? dashArray;
}

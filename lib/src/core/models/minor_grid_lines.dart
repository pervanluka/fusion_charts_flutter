import 'package:flutter/material.dart';

/// Configuration for minor grid lines on chart axes.
class MinorGridLines {
  /// Creates minor grid lines configuration.
  const MinorGridLines({this.width = 0.25, this.color, this.dashArray});

  /// Width of minor grid lines.
  final double width;

  /// Color of minor grid lines.
  final Color? color;

  /// Dash array for dashed lines (e.g., [5, 5] for dashes).
  final List<double>? dashArray;
}

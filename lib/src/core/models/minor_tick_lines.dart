import 'package:flutter/material.dart';

/// Configuration for minor tick lines on chart axes.
class MinorTickLines {
  /// Creates minor tick lines configuration.
  const MinorTickLines({this.width = 0.5, this.size = 3, this.color});

  /// Width of minor tick lines.
  final double width;

  /// Size (length) of minor tick lines.
  final double size;

  /// Color of minor tick lines.
  final Color? color;
}

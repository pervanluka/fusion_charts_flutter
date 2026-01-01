import 'package:flutter/material.dart';

/// Represents axis label with position and text.
@immutable
class AxisLabel {
  const AxisLabel({
    required this.value,
    required this.text,
    required this.position,
  });

  /// Numeric value of this label.
  final double value;

  /// Display text for this label.
  final String text;

  /// Normalized position (0-1) along the axis.
  final double position;
}

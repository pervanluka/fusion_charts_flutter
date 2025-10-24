import 'package:flutter/material.dart';

/// Default values for axis customization
class AxisDefaults {
  AxisDefaults._(); // Private constructor for utility class

  // Axis Line
  static const double axisLineWidth = 1.0;
  static const Color? axisLineColor = null;

  // Major Ticks
  static const double majorTickSize = 8.0;
  static const double majorTickWidth = 1.0;

  // Minor Ticks
  static const double minorTickSize = 4.0;
  static const double minorTickWidth = 0.5;

  // Grid Lines
  static const double majorGridWidth = 0.5;
  static const double minorGridWidth = 0.3;

  // Labels
  static const int maximumLabels = 10;
  static const int desiredIntervals = 5;
  static const double labelRotation = 0.0;
}

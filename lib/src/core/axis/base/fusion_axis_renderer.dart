import 'package:flutter/material.dart';

import '../../models/axis_bounds.dart';
import '../../models/axis_label.dart';

/// Abstract base class for all axis renderers.
///
/// Defines the contract for rendering any type of axis (numeric, category, datetime).
/// Subclasses implement specific rendering logic for their axis type.
///
/// ## Responsibilities:
/// - Calculate axis bounds from data
/// - Generate axis labels
/// - Measure label sizes
/// - Render axis line, ticks, labels
/// - Render grid lines
///
/// ## Subclasses:
/// - NumericAxisRenderer
/// - CategoryAxisRenderer
/// - DateTimeAxisRenderer
/// - LogarithmicAxisRenderer
abstract class FusionAxisRenderer {
  /// Calculates axis bounds from data values.
  ///
  /// Takes raw data values and returns nice bounds with
  /// appropriate min, max, and intervals.
  AxisBounds calculateBounds(List<double> dataValues);

  /// Generates labels for the axis.
  ///
  /// Returns a list of labels with their positions and text.
  List<AxisLabel> generateLabels(AxisBounds bounds);

  /// Measures the space required for axis labels.
  ///
  /// Used by layout manager to determine margins.
  Size measureAxisLabels(List<AxisLabel> labels, Size availableSize);

  /// Renders the axis (line, ticks, labels).
  ///
  /// Called during paint phase to draw the axis.
  void renderAxis(Canvas canvas, Rect axisArea, AxisBounds bounds);

  /// Renders grid lines into the plot area.
  ///
  /// Called to draw grid lines behind the data series.
  void renderGridLines(Canvas canvas, Rect plotArea, AxisBounds bounds);

  /// Disposes of any resources.
  void dispose() {}
}

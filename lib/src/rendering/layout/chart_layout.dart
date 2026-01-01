import 'package:flutter/material.dart';
import '../../core/models/axis_bounds.dart';

/// Complete chart layout information.
///
/// Contains all positioning information needed to render a chart.
/// This is the OUTPUT of ChartLayoutManager and the INPUT to painters.
///
/// Layout Structure:
/// ```
/// ┌─────────────────────────────────────┐
/// │          Chart Title (if present)   │
/// ├────────┬─────────────────┬──────────┤
/// │ Y-Axis │                 │  Legend  │
/// │ Labels │    Plot Area    │   (opt)  │
/// │        │ (Series render) │          │
/// ├────────┼─────────────────┼──────────┤
/// │        │  X-Axis Labels  │          │
/// └────────┴─────────────────┴──────────┘
/// ```
@immutable
class ChartLayout {
  /// Creates a chart layout.
  const ChartLayout({
    required this.chartSize,
    required this.plotArea,
    required this.xAxisArea,
    required this.yAxisArea,
    required this.xBounds,
    required this.yBounds,
    required this.margins,
    this.legendArea,
    this.titleArea,
    this.xAxisLabelArea,
    this.yAxisLabelArea,
  });

  /// Total size of the chart widget.
  final Size chartSize;

  /// Rectangle where series are drawn (the main chart area).
  ///
  /// This is the area inside the axes where data is rendered.
  /// Grid lines are drawn in this area.
  final Rect plotArea;

  /// Rectangle for X-axis (including labels and ticks).
  final Rect xAxisArea;

  /// Rectangle for Y-axis (including labels and ticks).
  final Rect yAxisArea;

  /// Data bounds for X-axis.
  final AxisBounds xBounds;

  /// Data bounds for Y-axis.
  final AxisBounds yBounds;

  /// Chart margins (space around plot area).
  final EdgeInsets margins;

  /// Rectangle for legend (optional).
  final Rect? legendArea;

  /// Rectangle for title (optional).
  final Rect? titleArea;

  /// Rectangle specifically for X-axis labels.
  final Rect? xAxisLabelArea;

  /// Rectangle specifically for Y-axis labels.
  final Rect? yAxisLabelArea;

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Width of the plot area.
  double get plotWidth => plotArea.width;

  /// Height of the plot area.
  double get plotHeight => plotArea.height;

  /// Whether layout has a legend.
  bool get hasLegend => legendArea != null;

  /// Whether layout has a title.
  bool get hasTitle => titleArea != null;

  /// Total margin width (left + right).
  double get totalMarginWidth => margins.left + margins.right;

  /// Total margin height (top + bottom).
  double get totalMarginHeight => margins.top + margins.bottom;

  /// Available width for content (excluding margins).
  double get contentWidth => chartSize.width - totalMarginWidth;

  /// Available height for content (excluding margins).
  double get contentHeight => chartSize.height - totalMarginHeight;

  // ==========================================================================
  // COORDINATE CONVERSION
  // ==========================================================================

  /// Converts data X coordinate to screen X coordinate.
  double dataXToScreenX(double dataX) {
    final normalized = xBounds.normalize(dataX);
    return plotArea.left + (normalized * plotArea.width);
  }

  /// Converts data Y coordinate to screen Y coordinate.
  double dataYToScreenY(double dataY) {
    final normalized = yBounds.normalize(dataY);
    // Y is inverted (screen Y increases downward)
    return plotArea.bottom - (normalized * plotArea.height);
  }

  /// Converts screen X coordinate to data X coordinate.
  double screenXToDataX(double screenX) {
    final normalized = (screenX - plotArea.left) / plotArea.width;
    return xBounds.denormalize(normalized);
  }

  /// Converts screen Y coordinate to data Y coordinate.
  double screenYToDataY(double screenY) {
    // Y is inverted
    final normalized = (plotArea.bottom - screenY) / plotArea.height;
    return yBounds.denormalize(normalized);
  }

  /// Converts data point to screen coordinates.
  Offset dataToScreen(double x, double y) {
    return Offset(dataXToScreenX(x), dataYToScreenY(y));
  }

  /// Converts screen coordinates to data point.
  Offset screenToData(Offset screenPoint) {
    return Offset(
      screenXToDataX(screenPoint.dx),
      screenYToDataY(screenPoint.dy),
    );
  }

  // ==========================================================================
  // HIT TESTING
  // ==========================================================================

  /// Checks if a point is within the plot area.
  bool isInPlotArea(Offset point) {
    return plotArea.contains(point);
  }

  /// Checks if a point is within the X-axis area.
  bool isInXAxisArea(Offset point) {
    return xAxisArea.contains(point);
  }

  /// Checks if a point is within the Y-axis area.
  bool isInYAxisArea(Offset point) {
    return yAxisArea.contains(point);
  }

  /// Checks if a point is within the legend area.
  bool isInLegendArea(Offset point) {
    return legendArea?.contains(point) ?? false;
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  ChartLayout copyWith({
    Size? chartSize,
    Rect? plotArea,
    Rect? xAxisArea,
    Rect? yAxisArea,
    AxisBounds? xBounds,
    AxisBounds? yBounds,
    EdgeInsets? margins,
    Rect? legendArea,
    Rect? titleArea,
    Rect? xAxisLabelArea,
    Rect? yAxisLabelArea,
  }) {
    return ChartLayout(
      chartSize: chartSize ?? this.chartSize,
      plotArea: plotArea ?? this.plotArea,
      xAxisArea: xAxisArea ?? this.xAxisArea,
      yAxisArea: yAxisArea ?? this.yAxisArea,
      xBounds: xBounds ?? this.xBounds,
      yBounds: yBounds ?? this.yBounds,
      margins: margins ?? this.margins,
      legendArea: legendArea ?? this.legendArea,
      titleArea: titleArea ?? this.titleArea,
      xAxisLabelArea: xAxisLabelArea ?? this.xAxisLabelArea,
      yAxisLabelArea: yAxisLabelArea ?? this.yAxisLabelArea,
    );
  }

  @override
  String toString() {
    return 'ChartLayout('
        'chartSize: $chartSize, '
        'plotArea: $plotArea, '
        'xBounds: $xBounds, '
        'yBounds: $yBounds'
        ')';
  }
}

import 'package:flutter/material.dart';
import '../data/fusion_pie_data_point.dart';
import '../utils/fusion_color_palette.dart';

// =============================================================================
// ENUMS
// =============================================================================

/// Direction of pie rendering.
enum PieDirection {
  /// Segments flow clockwise from start angle.
  clockwise,

  /// Segments flow counter-clockwise from start angle.
  counterClockwise,
}

/// Sorting mode for slices.
enum PieSortMode {
  /// Keep original order.
  none,

  /// Sort smallest to largest.
  ascending,

  /// Sort largest to smallest.
  descending,
}

/// Selection mode for slices.
enum PieSelectionMode {
  /// No selection allowed.
  none,

  /// Single slice selection (clicking another deselects previous).
  single,

  /// Multiple slice selection (clicking toggles).
  multiple,
}

/// Position of slice labels.
enum PieLabelPosition {
  /// Auto-detect based on slice size.
  auto,

  /// Inside the slice.
  inside,

  /// Outside with connector line.
  outside,

  /// No labels.
  none,
}

// =============================================================================
// MAIN SERIES CLASS
// =============================================================================

/// A series for pie/donut charts.
///
/// ## Design Philosophy
///
/// Flat, predictable API matching line/bar series patterns.
/// No nested style objects - visual properties are on data points.
///
/// ## Example
///
/// ```dart
/// FusionPieSeries(
///   dataPoints: [
///     FusionPieDataPoint(35, label: 'Sales', color: Colors.blue),
///     FusionPieDataPoint(25, label: 'Marketing', color: Colors.green),
///     FusionPieDataPoint(20, label: 'R&D', color: Colors.orange),
///     FusionPieDataPoint(20, label: 'Other'),  // Auto-colored
///   ],
///   innerRadiusPercent: 0.5,  // Donut mode
///   startAngle: -90,
///   explodeOffset: 12,
/// )
/// ```
@immutable
class FusionPieSeries {
  const FusionPieSeries({
    required this.dataPoints,
    this.name = 'Series',
    // === GEOMETRY ===
    this.innerRadiusPercent = 0.0,
    this.outerRadiusPercent = 0.85,
    this.startAngle = -90.0,
    this.direction = PieDirection.clockwise,
    this.gapBetweenSlices = 0.0,
    this.cornerRadius = 0.0,
    // === COLORS ===
    this.colors,
    this.colorPalette,
    // === STROKE (default for all slices) ===
    this.strokeWidth = 0.0,
    this.strokeColor,
    // === EXPLODE ===
    this.explodeAll = false,
    this.explodeOffset = 10.0,
    // === SORTING / GROUPING ===
    this.sortMode = PieSortMode.none,
    this.groupSmallSegments = false,
    this.groupThreshold = 3.0,
    this.groupLabel = 'Other',
    this.groupColor,
    // === SELECTION ===
    this.selectionMode = PieSelectionMode.single,
    this.onSelectionChanged,
    // === LABELS ===
    this.showLabels = true,
    this.labelPosition = PieLabelPosition.auto,
    this.labelStyle,
    this.labelBuilder,
    // === CENTER WIDGET ===
    this.centerWidget,
    this.centerWidgetBuilder,
    // === VISIBILITY ===
    this.visible = true,
  }) : assert(dataPoints.length > 0, 'At least one data point required'),
       assert(innerRadiusPercent >= 0 && innerRadiusPercent < 1, 'Inner radius must be 0-1'),
       assert(outerRadiusPercent > 0 && outerRadiusPercent <= 1, 'Outer radius must be 0-1'),
       assert(innerRadiusPercent < outerRadiusPercent, 'Inner must be less than outer'),
       assert(gapBetweenSlices >= 0, 'Gap must be non-negative'),
       assert(cornerRadius >= 0, 'Corner radius must be non-negative'),
       assert(explodeOffset >= 0, 'Explode offset must be non-negative'),
       assert(groupThreshold > 0 && groupThreshold <= 100, 'Threshold must be 0-100%');

  // ===========================================================================
  // CORE DATA
  // ===========================================================================

  /// The data points (slices) in this series.
  final List<FusionPieDataPoint> dataPoints;

  /// Name of this series (for legends and tooltips).
  final String name;

  // ===========================================================================
  // GEOMETRY
  // ===========================================================================

  /// Inner radius as fraction of available radius.
  ///
  /// - 0.0 = Pie chart (no hole)
  /// - 0.5 = Donut with 50% hole
  /// - 0.7 = Thin ring
  ///
  /// Default: 0.0
  final double innerRadiusPercent;

  /// Outer radius as fraction of available radius.
  ///
  /// Default: 0.85 (leaves room for labels)
  final double outerRadiusPercent;

  /// Start angle in degrees.
  ///
  /// - -90 = 12 o'clock position
  /// - 0 = 3 o'clock position
  /// - 90 = 6 o'clock position
  ///
  /// Default: -90
  final double startAngle;

  /// Direction of segment layout.
  ///
  /// Default: clockwise
  final PieDirection direction;

  /// Gap between slices in degrees.
  ///
  /// Default: 0.0 (no gap)
  final double gapBetweenSlices;

  /// Corner radius for all slice edges.
  ///
  /// Applied uniformly to all corners.
  /// Individual slices can override via dataPoint.cornerRadius.
  ///
  /// Default: 0.0
  final double cornerRadius;

  // ===========================================================================
  // COLORS
  // ===========================================================================

  /// Explicit color list for slices.
  ///
  /// Colors are assigned by index (wraps if fewer colors than slices).
  /// Individual slice colors take precedence.
  final List<Color>? colors;

  /// Color palette for auto-coloring.
  ///
  /// Used when slice doesn't have explicit color and [colors] is null.
  /// Falls back to theme palette if null.
  final FusionColorPalette? colorPalette;

  // ===========================================================================
  // STROKE (applied to all slices)
  // ===========================================================================

  /// Default stroke width for all slices.
  ///
  /// Individual slices can override via dataPoint.borderWidth.
  /// Default: 0.0 (no stroke)
  final double strokeWidth;

  /// Default stroke color for all slices.
  ///
  /// Individual slices can override via dataPoint.borderColor.
  /// Falls back to theme.pieStrokeColor if null.
  final Color? strokeColor;

  // ===========================================================================
  // EXPLODE
  // ===========================================================================

  /// Whether all slices are exploded.
  ///
  /// Default: false
  final bool explodeAll;

  /// Distance to explode slices in logical pixels.
  ///
  /// Individual slices can override via dataPoint.explodeOffset.
  /// Default: 10.0
  final double explodeOffset;

  // ===========================================================================
  // SORTING / GROUPING
  // ===========================================================================

  /// How to sort slices before rendering.
  ///
  /// Default: none (original order)
  final PieSortMode sortMode;

  /// Whether to group small slices into "Other".
  ///
  /// Default: false
  final bool groupSmallSegments;

  /// Minimum percentage to avoid being grouped.
  ///
  /// Slices below this percentage are combined into "Other".
  /// Default: 3.0%
  final double groupThreshold;

  /// Label for the grouped "Other" slice.
  ///
  /// Default: 'Other'
  final String groupLabel;

  /// Color for the grouped "Other" slice.
  ///
  /// Falls back to theme.gridColor if null.
  final Color? groupColor;

  // ===========================================================================
  // SELECTION
  // ===========================================================================

  /// Selection behavior mode.
  ///
  /// Default: single
  final PieSelectionMode selectionMode;

  /// Called when selection changes.
  final void Function(Set<int> selectedIndices)? onSelectionChanged;

  // ===========================================================================
  // LABELS
  // ===========================================================================

  /// Whether to show labels on slices.
  ///
  /// Default: true
  final bool showLabels;

  /// Position of labels.
  ///
  /// Default: auto
  final PieLabelPosition labelPosition;

  /// Text style for labels.
  ///
  /// Falls back to theme.dataLabelStyle if null.
  final TextStyle? labelStyle;

  /// Custom label builder.
  ///
  /// If provided, overrides default label rendering.
  final Widget Function(BuildContext context, PieLabelData data)? labelBuilder;

  // ===========================================================================
  // CENTER WIDGET (Donut only)
  // ===========================================================================

  /// Static widget to display in donut center.
  ///
  /// Only visible when innerRadiusPercent > 0.
  final Widget? centerWidget;

  /// Dynamic center widget builder.
  ///
  /// Called with current state (selection, hover, totals).
  /// Takes precedence over [centerWidget] if both are set.
  final Widget Function(BuildContext context, PieCenterState state)? centerWidgetBuilder;

  // ===========================================================================
  // VISIBILITY
  // ===========================================================================

  /// Whether this series is visible.
  ///
  /// Default: true
  final bool visible;

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  /// Whether this is a donut chart.
  bool get isDonut => innerRadiusPercent > 0;

  /// Total of all slice values.
  double get total => dataPoints.fold(0.0, (sum, p) => sum + p.value);

  /// Number of slices.
  int get sliceCount => dataPoints.length;

  // ===========================================================================
  // METHODS
  // ===========================================================================

  /// Gets color for a slice at [index].
  ///
  /// Resolution order:
  /// 1. dataPoint.color (per-slice)
  /// 2. colors[index] (explicit list)
  /// 3. colorPalette.colorAt(index) (series palette)
  /// 4. defaultPalette.colorAt(index) (fallback)
  Color getColorForIndex(int index, [FusionColorPalette? defaultPalette]) {
    // 1. Per-slice color
    final point = dataPoints[index];
    if (point.color != null) return point.color!;

    // 2. Explicit colors list
    if (colors != null && colors!.isNotEmpty) {
      return colors![index % colors!.length];
    }

    // 3. Series palette
    if (colorPalette != null) {
      return colorPalette!.colorAt(index);
    }

    // 4. Default palette
    return (defaultPalette ?? FusionColorPalette.material).colorAt(index);
  }

  /// Returns data points sorted according to [sortMode].
  List<FusionPieDataPoint> getSortedDataPoints() {
    if (sortMode == PieSortMode.none) return dataPoints;

    final sorted = List<FusionPieDataPoint>.from(dataPoints);
    switch (sortMode) {
      case PieSortMode.ascending:
        sorted.sort((a, b) => a.value.compareTo(b.value));
        break;
      case PieSortMode.descending:
        sorted.sort((a, b) => b.value.compareTo(a.value));
        break;
      case PieSortMode.none:
        break;
    }
    return sorted;
  }

  /// Groups small segments if enabled.
  List<FusionPieDataPoint> getGroupedDataPoints() {
    if (!groupSmallSegments) return getSortedDataPoints();

    final sorted = getSortedDataPoints();
    final totalValue = total;
    if (totalValue <= 0) return sorted;

    final main = <FusionPieDataPoint>[];
    double otherValue = 0;

    for (final point in sorted) {
      final pct = (point.value / totalValue) * 100;
      if (pct >= groupThreshold) {
        main.add(point);
      } else {
        otherValue += point.value;
      }
    }

    if (otherValue > 0) {
      main.add(FusionPieDataPoint(
        otherValue,
        label: groupLabel,
        color: groupColor,
      ));
    }

    return main;
  }

  /// Creates a copy with modified properties.
  FusionPieSeries copyWith({
    List<FusionPieDataPoint>? dataPoints,
    String? name,
    double? innerRadiusPercent,
    double? outerRadiusPercent,
    double? startAngle,
    PieDirection? direction,
    double? gapBetweenSlices,
    double? cornerRadius,
    List<Color>? colors,
    FusionColorPalette? colorPalette,
    double? strokeWidth,
    Color? strokeColor,
    bool? explodeAll,
    double? explodeOffset,
    PieSortMode? sortMode,
    bool? groupSmallSegments,
    double? groupThreshold,
    String? groupLabel,
    Color? groupColor,
    PieSelectionMode? selectionMode,
    void Function(Set<int>)? onSelectionChanged,
    bool? showLabels,
    PieLabelPosition? labelPosition,
    TextStyle? labelStyle,
    Widget Function(BuildContext, PieLabelData)? labelBuilder,
    Widget? centerWidget,
    Widget Function(BuildContext, PieCenterState)? centerWidgetBuilder,
    bool? visible,
  }) {
    return FusionPieSeries(
      dataPoints: dataPoints ?? this.dataPoints,
      name: name ?? this.name,
      innerRadiusPercent: innerRadiusPercent ?? this.innerRadiusPercent,
      outerRadiusPercent: outerRadiusPercent ?? this.outerRadiusPercent,
      startAngle: startAngle ?? this.startAngle,
      direction: direction ?? this.direction,
      gapBetweenSlices: gapBetweenSlices ?? this.gapBetweenSlices,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      colors: colors ?? this.colors,
      colorPalette: colorPalette ?? this.colorPalette,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
      explodeAll: explodeAll ?? this.explodeAll,
      explodeOffset: explodeOffset ?? this.explodeOffset,
      sortMode: sortMode ?? this.sortMode,
      groupSmallSegments: groupSmallSegments ?? this.groupSmallSegments,
      groupThreshold: groupThreshold ?? this.groupThreshold,
      groupLabel: groupLabel ?? this.groupLabel,
      groupColor: groupColor ?? this.groupColor,
      selectionMode: selectionMode ?? this.selectionMode,
      onSelectionChanged: onSelectionChanged ?? this.onSelectionChanged,
      showLabels: showLabels ?? this.showLabels,
      labelPosition: labelPosition ?? this.labelPosition,
      labelStyle: labelStyle ?? this.labelStyle,
      labelBuilder: labelBuilder ?? this.labelBuilder,
      centerWidget: centerWidget ?? this.centerWidget,
      centerWidgetBuilder: centerWidgetBuilder ?? this.centerWidgetBuilder,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionPieSeries &&
        other.name == name &&
        other.dataPoints.length == dataPoints.length &&
        other.innerRadiusPercent == innerRadiusPercent &&
        other.visible == visible;
  }

  @override
  int get hashCode => Object.hash(name, dataPoints.length, innerRadiusPercent);

  @override
  String toString() => 'FusionPieSeries($name, ${dataPoints.length} slices)';
}

// =============================================================================
// STATE CLASSES (for center widget and labels)
// =============================================================================

/// State passed to center widget builder.
@immutable
class PieCenterState {
  const PieCenterState({
    required this.total,
    required this.selectedIndices,
    this.selectedSegment,
    this.hoveredSegment,
  });

  /// Total value of all slices.
  final double total;

  /// Currently selected slice indices.
  final Set<int> selectedIndices;

  /// Data for the most recently selected segment.
  final PieSegmentData? selectedSegment;

  /// Data for the currently hovered segment.
  final PieSegmentData? hoveredSegment;

  /// Whether any slice is selected.
  bool get hasSelection => selectedIndices.isNotEmpty;

  /// Whether a slice is hovered.
  bool get hasHover => hoveredSegment != null;
}

/// Data for a single segment (used in callbacks and builders).
@immutable
class PieSegmentData {
  const PieSegmentData({
    required this.index,
    required this.value,
    required this.percentage,
    required this.color,
    this.label,
    this.dataPoint,
  });

  /// Index in the data points list.
  final int index;

  /// Numeric value.
  final double value;

  /// Percentage of total (0-100).
  final double percentage;

  /// Resolved color.
  final Color color;

  /// Label text.
  final String? label;

  /// Reference to original data point.
  final FusionPieDataPoint? dataPoint;
}

/// Data passed to label builder.
@immutable
class PieLabelData {
  const PieLabelData({
    required this.index,
    required this.value,
    required this.percentage,
    required this.label,
    required this.color,
    required this.position,
    required this.isSelected,
    required this.isHovered,
  });

  /// Index in the data points list.
  final int index;

  /// Numeric value.
  final double value;

  /// Percentage of total (0-100).
  final double percentage;

  /// Label text.
  final String? label;

  /// Resolved color.
  final Color color;

  /// Screen position for the label.
  final Offset position;

  /// Whether this slice is selected.
  final bool isSelected;

  /// Whether this slice is hovered.
  final bool isHovered;
}

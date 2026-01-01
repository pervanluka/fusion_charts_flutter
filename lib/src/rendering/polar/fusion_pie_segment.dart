import 'package:flutter/material.dart';

import '../../configuration/fusion_pie_chart_configuration.dart';
import '../../data/fusion_pie_data_point.dart';
import '../../series/fusion_pie_series.dart';
import '../../utils/fusion_color_palette.dart';
import 'fusion_polar_math.dart';

/// Pre-computed segment data for efficient rendering and hit testing.
///
/// ## Performance Architecture
///
/// Computing angles, percentages, and paths for every frame is expensive.
/// Instead, we compute everything **once per layout** and cache it:
///
/// ```
/// Layout Phase (once):
///   FusionPieSeries → FusionPieSegmentComputer → List<ComputedPieSegment>
///
/// Paint Phase (every frame):
///   List<ComputedPieSegment> → Canvas (just draw cached paths)
///
/// Hit Test Phase:
///   Pointer position + List<ComputedPieSegment> → segment index
/// ```
///
/// ## Memory Efficiency
///
/// Each segment stores only what's needed for rendering:
/// - Pre-computed angles (no trigonometry at paint time)
/// - Cached path (no path building at paint time)
/// - Resolved colors (no palette lookups at paint time)
/// - Screen-space positions (no coordinate transforms at paint time)
@immutable
class ComputedPieSegment {
  /// Creates a computed segment.
  const ComputedPieSegment({
    required this.index,
    required this.originalIndex,
    required this.dataPoint,
    required this.value,
    required this.percentage,
    required this.startAngle,
    required this.sweepAngle,
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
    required this.color,
    required this.path,
    required this.centroid,
    required this.labelAnchor,
    required this.isExploded,
    required this.explodeOffset,
    this.isSelected = false,
    this.isHovered = false,
  });

  // ===========================================================================
  // IDENTITY
  // ===========================================================================

  /// Index in the computed (possibly sorted/grouped) list.
  final int index;

  /// Original index in the data points list (before sorting/grouping).
  final int originalIndex;

  /// Reference to the original data point.
  final FusionPieDataPoint dataPoint;

  // ===========================================================================
  // VALUES
  // ===========================================================================

  /// The numeric value of this segment.
  final double value;

  /// Percentage of total (0-100).
  final double percentage;

  // ===========================================================================
  // GEOMETRY
  // ===========================================================================

  /// Start angle in degrees.
  final double startAngle;

  /// Sweep angle in degrees (always positive).
  final double sweepAngle;

  /// Center point (may be offset if exploded).
  final Offset center;

  /// Inner radius in pixels (0 for pie, >0 for donut).
  final double innerRadius;

  /// Outer radius in pixels.
  final double outerRadius;

  /// Pre-computed path for this segment.
  final Path path;

  // ===========================================================================
  // POSITIONS
  // ===========================================================================

  /// Visual center of the segment (for labels, icons).
  final Offset centroid;

  /// Anchor point for outside labels.
  final ({Offset arcPoint, Offset labelPoint, TextAlign alignment}) labelAnchor;

  // ===========================================================================
  // VISUAL STATE
  // ===========================================================================

  /// Resolved color for this segment.
  final Color color;

  /// Whether this segment is exploded (pulled out).
  final bool isExploded;

  /// Explode offset vector (direction and distance).
  final Offset explodeOffset;

  /// Whether this segment is currently selected.
  final bool isSelected;

  /// Whether this segment is currently hovered (desktop/web).
  final bool isHovered;

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  /// Middle angle of this segment.
  double get midAngle => startAngle + sweepAngle / 2;

  /// End angle of this segment.
  double get endAngle => startAngle + sweepAngle;

  /// Label text from data point.
  String? get label => dataPoint.label;

  /// Ring width (outer - inner radius).
  double get ringWidth => outerRadius - innerRadius;

  // ===========================================================================
  // HIT TESTING
  // ===========================================================================

  /// Checks if a point is inside this segment.
  bool containsPoint(Offset point) {
    return FusionPolarMath.isPointInSegment(
      point: point,
      center: center,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
    );
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  /// Creates a copy with modified selection/hover state.
  ComputedPieSegment copyWith({
    bool? isSelected,
    bool? isHovered,
  }) {
    return ComputedPieSegment(
      index: index,
      originalIndex: originalIndex,
      dataPoint: dataPoint,
      value: value,
      percentage: percentage,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      center: center,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      color: color,
      path: path,
      centroid: centroid,
      labelAnchor: labelAnchor,
      isExploded: isExploded,
      explodeOffset: explodeOffset,
      isSelected: isSelected ?? this.isSelected,
      isHovered: isHovered ?? this.isHovered,
    );
  }

  @override
  String toString() => 'ComputedPieSegment(index: $index, '
      'label: $label, '
      'percentage: ${percentage.toStringAsFixed(1)}%)';
}

// =============================================================================
// SEGMENT COMPUTER
// =============================================================================

/// Computes all segment data from a pie series.
///
/// This is the core layout engine for pie charts. It transforms raw data
/// into renderable segments with all geometry pre-calculated.
///
/// ## Usage
///
/// ```dart
/// final computer = FusionPieSegmentComputer(
///   series: myPieSeries,
///   config: myConfig,
///   center: Offset(200, 200),
///   availableRadius: 150,
///   defaultPalette: FusionColorPalette.material,
///   labelConnectorLength: 20,
/// );
///
/// final segments = computer.compute();
/// // Now use segments for rendering and hit testing
/// ```
class FusionPieSegmentComputer {
  /// Creates a segment computer.
  const FusionPieSegmentComputer({
    required this.series,
    required this.config,
    required this.center,
    required this.availableRadius,
    required this.defaultPalette,
    this.labelConnectorLength = 20.0,
    this.explodedIndices = const {},
    this.selectedIndices = const {},
    this.hoveredIndex,
  });

  /// The pie series to compute.
  final FusionPieSeries series;

  /// The chart configuration (provides resolved values).
  final FusionPieChartConfiguration? config;

  /// Center point of the pie.
  final Offset center;

  /// Maximum available radius.
  final double availableRadius;

  /// Default color palette if series doesn't specify colors.
  final FusionColorPalette defaultPalette;

  /// Length of label connector lines.
  final double labelConnectorLength;

  /// Indices of currently exploded segments.
  final Set<int> explodedIndices;

  /// Indices of currently selected segments.
  final Set<int> selectedIndices;

  /// Index of currently hovered segment (null if none).
  final int? hoveredIndex;

  /// Computes all segments.
  List<ComputedPieSegment> compute() {
    if (!series.visible || series.dataPoints.isEmpty) {
      return const [];
    }

    // Get processed data points using CONFIG values (not series directly)
    final dataPoints = _getProcessedDataPoints();
    final total = dataPoints.fold(0.0, (sum, p) => sum + p.value);

    if (total <= 0) return const [];

    // Cache config for null-safe access
    final cfg = config;

    // Resolve geometry values from config
    final double resolvedOuterRadius = cfg != null
        ? cfg.resolveOuterRadius(series)
        : series.outerRadiusPercent;
    final double resolvedInnerRadius = cfg != null
        ? cfg.resolveInnerRadius(series)
        : series.innerRadiusPercent;
    final double resolvedStartAngle = cfg != null
        ? cfg.resolveStartAngle(series)
        : series.startAngle;
    final double resolvedGap = cfg != null
        ? cfg.resolveGapBetweenSlices(series)
        : series.gapBetweenSlices;
    final double resolvedCornerRadius = cfg != null
        ? cfg.resolveCornerRadius(series)
        : series.cornerRadius;
    final double resolvedExplodeOffset = cfg != null
        ? cfg.resolveExplodeOffset(series)
        : series.explodeOffset;

    // Calculate radii using resolved values
    final outerRadius = availableRadius * resolvedOuterRadius;
    final innerRadius = availableRadius * resolvedInnerRadius;

    // Calculate gap in degrees per segment
    final gapPerSegment = resolvedGap;
    final totalGap = gapPerSegment * dataPoints.length;
    final availableSweep = 360.0 - totalGap;

    // Resolve direction once (outside loop)
    final PieDirection resolvedDirection = cfg != null
        ? cfg.resolveDirection(series)
        : series.direction;
    final directionMultiplier = resolvedDirection == PieDirection.counterClockwise ? -1.0 : 1.0;

    // Build segments
    final segments = <ComputedPieSegment>[];
    double currentAngle = resolvedStartAngle;

    for (int i = 0; i < dataPoints.length; i++) {
      final dataPoint = dataPoints[i];
      final percentage = (dataPoint.value / total) * 100;
      final sweepAngle = (dataPoint.value / total) * availableSweep * directionMultiplier;

      // Determine if exploded
      final isExploded = series.explodeAll ||
          dataPoint.explode ||
          explodedIndices.contains(i);

      // Calculate explode offset - uniform radial offset for all exploded segments
      final explodeDistance = isExploded
          ? (dataPoint.explodeOffset ?? resolvedExplodeOffset)
          : 0.0;
      
      final midAngle = currentAngle + sweepAngle / 2;
      final explodeOffset = isExploded
          ? FusionPolarMath.pointOnCircle(Offset.zero, explodeDistance, midAngle)
          : Offset.zero;

      // Adjust center for exploded segments
      final segmentCenter = center + explodeOffset;

      // Get color
      final color = series.getColorForIndex(i, defaultPalette);

      // Create path using resolved corner radius
      final path = FusionPolarMath.createSegmentPath(
        center: segmentCenter,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        startAngle: currentAngle,
        sweepAngle: sweepAngle.abs(), // Path needs positive sweep
        cornerRadius: resolvedCornerRadius,
      );

      // Calculate centroid
      final centroid = FusionPolarMath.segmentCentroid(
        center: segmentCenter,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        startAngle: currentAngle,
        sweepAngle: sweepAngle.abs(),
      );

      // Calculate label anchor
      final labelAnchor = FusionPolarMath.labelAnchor(
        center: segmentCenter,
        outerRadius: outerRadius,
        connectorLength: labelConnectorLength,
        startAngle: currentAngle,
        sweepAngle: sweepAngle.abs(),
      );

      segments.add(ComputedPieSegment(
        index: i,
        originalIndex: i,
        dataPoint: dataPoint,
        value: dataPoint.value,
        percentage: percentage,
        startAngle: currentAngle,
        sweepAngle: sweepAngle.abs(),
        center: segmentCenter,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        color: color,
        path: path,
        centroid: centroid,
        labelAnchor: labelAnchor,
        isExploded: isExploded,
        explodeOffset: explodeOffset,
        isSelected: selectedIndices.contains(i),
        isHovered: hoveredIndex == i,
      ));

      // Move to next segment
      currentAngle += sweepAngle + (gapPerSegment * directionMultiplier);
    }

    return segments;
  }

  /// Gets data points processed according to CONFIG values.
  /// 
  /// This is the critical method that wires config → data processing.
  /// Config values override series values.
  List<FusionPieDataPoint> _getProcessedDataPoints() {
    final data = List<FusionPieDataPoint>.from(series.dataPoints);

    // Cache config for null-safe access
    final cfg = config;

    // 1. Apply sorting from CONFIG (not series)
    final PieSortMode sortMode = cfg != null
        ? cfg.resolveSortMode(series)
        : series.sortMode;

    switch (sortMode) {
      case PieSortMode.ascending:
        data.sort((a, b) => a.value.compareTo(b.value));
      case PieSortMode.descending:
        data.sort((a, b) => b.value.compareTo(a.value));
      case PieSortMode.none:
        break;
    }

    // 2. Apply grouping from CONFIG (not series)
    final bool shouldGroup = cfg != null
        ? cfg.resolveGroupSmallSegments(series)
        : series.groupSmallSegments;

    if (!shouldGroup) return data;

    final double threshold = cfg != null
        ? cfg.resolveGroupThreshold(series)
        : series.groupThreshold;

    final String groupLabel = cfg != null
        ? cfg.resolveGroupLabel(series)
        : series.groupLabel;

    final total = data.fold(0.0, (sum, p) => sum + p.value);
    if (total <= 0) return data;

    final mainSegments = <FusionPieDataPoint>[];
    var otherValue = 0.0;

    for (final point in data) {
      final percentage = (point.value / total) * 100;
      if (percentage >= threshold) {
        mainSegments.add(point);
      } else {
        otherValue += point.value;
      }
    }

    // Add "Other" segment if we grouped anything
    if (otherValue > 0) {
      // Resolve group color: config.groupColor > series.groupColor > fallback gray
      final Color groupColor = cfg?.groupColor ?? series.groupColor ?? const Color(0xFF9CA3AF);
      
      mainSegments.add(FusionPieDataPoint(
        otherValue,
        label: groupLabel,
        color: groupColor,
      ));
    }

    return mainSegments;
  }

  /// Finds the segment at a given point.
  ///
  /// Returns segment index or -1 if not found.
  int findSegmentAt(Offset point, List<ComputedPieSegment> segments) {
    // Check in reverse order (top segments first for proper z-order)
    for (int i = segments.length - 1; i >= 0; i--) {
      if (segments[i].containsPoint(point)) {
        return i;
      }
    }
    return -1;
  }
}

// =============================================================================
// SEGMENT CACHE
// =============================================================================

/// Cache for computed segments to avoid recalculation.
///
/// Segments are invalidated when:
/// - Series data changes
/// - Layout size changes
/// - Selection/hover state changes (partial invalidation)
class FusionPieSegmentCache {
  FusionPieSegmentCache();

  List<ComputedPieSegment>? _segments;
  int? _seriesHash;
  Size? _layoutSize;
  Offset? _center;

  /// Gets cached segments or computes new ones.
  List<ComputedPieSegment> getOrCompute({
    required FusionPieSeries series,
    required FusionPieChartConfiguration? config,
    required Size layoutSize,
    required Offset center,
    required double availableRadius,
    required FusionColorPalette palette,
    required double labelConnectorLength,
    required Set<int> explodedIndices,
    required Set<int> selectedIndices,
    required int? hoveredIndex,
  }) {
    final newHash = series.hashCode;

    // Check if we can reuse cached segments
    if (_segments != null &&
        _seriesHash == newHash &&
        _layoutSize == layoutSize &&
        _center == center) {
      // Update selection/hover state without full recompute
      return _updateInteractiveState(
        selectedIndices,
        hoveredIndex,
      );
    }

    // Full recompute
    final computer = FusionPieSegmentComputer(
      series: series,
      config: config,
      center: center,
      availableRadius: availableRadius,
      defaultPalette: palette,
      labelConnectorLength: labelConnectorLength,
      explodedIndices: explodedIndices,
      selectedIndices: selectedIndices,
      hoveredIndex: hoveredIndex,
    );

    _segments = computer.compute();
    _seriesHash = newHash;
    _layoutSize = layoutSize;
    _center = center;

    return _segments!;
  }

  List<ComputedPieSegment> _updateInteractiveState(
    Set<int> selectedIndices,
    int? hoveredIndex,
  ) {
    if (_segments == null) return const [];

    return _segments!.map((segment) {
      final newSelected = selectedIndices.contains(segment.index);
      final newHovered = hoveredIndex == segment.index;

      if (segment.isSelected == newSelected && segment.isHovered == newHovered) {
        return segment;
      }

      return segment.copyWith(
        isSelected: newSelected,
        isHovered: newHovered,
      );
    }).toList();
  }

  /// Invalidates the cache.
  void invalidate() {
    _segments = null;
    _seriesHash = null;
    _layoutSize = null;
    _center = null;
  }
}

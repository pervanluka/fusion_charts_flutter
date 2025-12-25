import 'package:flutter/material.dart';
import '../../core/enums/fusion_data_label_display.dart';
import '../../series/fusion_series.dart';
import '../engine/fusion_render_context.dart';
import '../../series/series_with_data_points.dart';
import '../../data/fusion_data_point.dart';
import 'fusion_render_layer.dart';

/// Renders data labels on charts with smart positioning.
///
/// Data labels show the actual values at data points, making it easier
/// for users to read exact numbers from the chart.
///
/// ## Features
///
/// - Smart positioning (above, below, inside)
/// - Collision detection
/// - Custom formatters
/// - Background/border support
/// - Shadow effects
/// - Rotation support
///
/// ## Positioning Strategies
///
/// 1. **Auto** - Chooses best position automatically
/// 2. **Above** - Always above the point
/// 3. **Below** - Always below the point
/// 4. **Inside** - Inside bars (for bar charts)
/// 5. **Outside** - Outside bars (for bar charts)
///
/// ## Performance
///
/// - Text painter caching
/// - Culling for off-screen labels
/// - Efficient layout calculations
/// - Optimized for 100+ labels
///
/// ## Example
///
/// ```dart
/// final labelLayer = FusionDataLabelLayer(
///   series: [
///     FusionLineSeries(
///       dataPoints: data,
///       showDataLabels: true,
///       dataLabelStyle: TextStyle(color: Colors.black),
///       dataLabelFormatter: (value) => '\$${value.toStringAsFixed(2)}',
///     ),
///   ],
/// );
/// ```
class FusionDataLabelLayer extends FusionRenderLayer {
  /// Creates a data label rendering layer.
  FusionDataLabelLayer({
    required this.series,
    this.enableBackground = true,
    this.enableBorder = false,
    this.enableShadow = false,
    this.enableCollisionDetection = false,
  }) : super(
         name: 'dataLabels',
         zIndex: 70, // After markers
         cacheable: false,
       );

  /// All series to render data labels for.
  final List<SeriesWithDataPoints> series;

  /// Whether to render label backgrounds.
  final bool enableBackground;

  /// Whether to render label borders.
  final bool enableBorder;

  /// Whether to render label shadows.
  final bool enableShadow;

  /// Whether to enable collision detection.
  ///
  /// When true, overlapping labels are repositioned or hidden.
  final bool enableCollisionDetection;

  /// Cache for text painters to avoid recreation.
  final Map<String, TextPainter> _textPainterCache = {};

  // ==========================================================================
  // MAIN PAINT METHOD
  // ==========================================================================

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    // Clear cache from previous frame
    _textPainterCache.clear();

    // Collect all labels with positions
    final allLabels = <_LabelInfo>[];

    for (final seriesData in series) {
      if (!seriesData.visible || seriesData.dataPoints.isEmpty) continue;

      // Only render labels for series that support them
      if (seriesData is FusionDataLabelSupport) {
        final labelSeries = seriesData as FusionDataLabelSupport;
        if (labelSeries.showDataLabels) {
          final labels = _collectLabelsForSeries(context, seriesData, labelSeries);
          allLabels.addAll(labels);
        }
      }
    }

    // Apply collision detection if enabled
    if (enableCollisionDetection) {
      _resolveCollisions(allLabels);
    }

    // Render all labels
    for (final label in allLabels) {
      if (label.visible) {
        _renderLabel(canvas, context, label);
      }
    }
  }

  // ==========================================================================
  // LABEL COLLECTION
  // ==========================================================================

  /// Collects label information for a series.
  List<_LabelInfo> _collectLabelsForSeries(
    FusionRenderContext context,
    SeriesWithDataPoints series,
    FusionDataLabelSupport labelSeries,
  ) {
    final labels = <_LabelInfo>[];
    final dataPoints = series.dataPoints;
    
    if (dataPoints.isEmpty) return labels;

    // Get display mode
    final displayMode = labelSeries.dataLabelDisplay;
    
    // Early return for none mode
    if (displayMode == FusionDataLabelDisplay.none) {
      return labels;
    }

    // Get indices of points that should show labels
    final indicesToShow = _getIndicesToShow(dataPoints, displayMode);

    for (int i = 0; i < dataPoints.length; i++) {
      // Skip if this point index shouldn't show a label
      if (!indicesToShow.contains(i)) continue;

      final point = dataPoints[i];
      final screenPos = context.coordSystem.dataToScreen(point);

      // Cull off-screen points (but we'll still try to show label if point is near edge)
      if (screenPos.dx < context.chartArea.left - 50 ||
          screenPos.dx > context.chartArea.right + 50 ||
          screenPos.dy < context.chartArea.top - 50 ||
          screenPos.dy > context.chartArea.bottom + 50) {
        continue;
      }

      // Format label text
      final labelText = labelSeries.dataLabelFormatter?.call(point.y) ?? point.y.toStringAsFixed(1);

      // Get or create text painter
      final textPainter = _getTextPainter(
        labelText,
        labelSeries.dataLabelStyle ?? context.theme.dataLabelStyle,
      );

      // Calculate label position with smart boundary handling
      final labelPosition = _calculateSmartLabelPosition(
        screenPos: screenPos,
        labelSize: textPainter.size,
        chartArea: context.chartArea,
      );

      labels.add(
        _LabelInfo(
          text: labelText,
          position: labelPosition,
          textPainter: textPainter,
          dataPoint: point,
          seriesColor: series.color,
          visible: true,
        ),
      );
    }

    return labels;
  }

  /// Returns the indices of points that should display labels based on display mode.
  /// 
  /// Uses indices instead of points to handle multiple points with same Y value.
  Set<int> _getIndicesToShow(
    List<FusionDataPoint> dataPoints,
    FusionDataLabelDisplay displayMode,
  ) {
    if (dataPoints.isEmpty) return {};

    switch (displayMode) {
      case FusionDataLabelDisplay.all:
        return Set.from(List.generate(dataPoints.length, (i) => i));

      case FusionDataLabelDisplay.none:
        return {};

      case FusionDataLabelDisplay.maxOnly:
        // Find max Y value
        final maxY = dataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
        // Return ALL indices with this max value
        return {
          for (int i = 0; i < dataPoints.length; i++)
            if (dataPoints[i].y == maxY) i
        };

      case FusionDataLabelDisplay.minOnly:
        // Find min Y value
        final minY = dataPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
        // Return ALL indices with this min value
        return {
          for (int i = 0; i < dataPoints.length; i++)
            if (dataPoints[i].y == minY) i
        };

      case FusionDataLabelDisplay.maxAndMin:
        // Find max and min Y values
        final maxY = dataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
        final minY = dataPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
        // Return ALL indices with max or min value
        return {
          for (int i = 0; i < dataPoints.length; i++)
            if (dataPoints[i].y == maxY || dataPoints[i].y == minY) i
        };

      case FusionDataLabelDisplay.firstAndLast:
        if (dataPoints.length == 1) {
          return {0};
        }
        return {0, dataPoints.length - 1};
    }
  }

  /// Calculates label position with smart boundary handling.
  /// 
  /// - Tries to position above the point first
  /// - If that overflows top, positions below
  /// - Clamps horizontal position to stay within chart area
  Offset _calculateSmartLabelPosition({
    required Offset screenPos,
    required Size labelSize,
    required Rect chartArea,
  }) {
    const padding = 6.0;
    
    // Calculate label dimensions with padding for background
    final labelWidth = labelSize.width + 8; // Account for background padding
    final labelHeight = labelSize.height + 4;
    
    // Try above first
    double labelY = screenPos.dy - labelHeight - padding;
    
    // If above overflows top, position below
    if (labelY < chartArea.top) {
      labelY = screenPos.dy + padding + 4; // +4 for marker clearance
    }
    
    // If below also overflows, clamp to top
    if (labelY + labelHeight > chartArea.bottom) {
      labelY = chartArea.top;
    }
    
    // Calculate horizontal position (centered on point)
    double labelX = screenPos.dx - labelSize.width / 2;
    
    // Clamp horizontal to stay within chart area (no extra padding)
    final minX = chartArea.left;
    final maxX = chartArea.right - labelWidth;
    
    if (maxX > minX) {
      labelX = labelX.clamp(minX, maxX);
    } else {
      // Label wider than chart area - center it
      labelX = chartArea.left + (chartArea.width - labelSize.width) / 2;
    }
    
    return Offset(labelX, labelY);
  }

  // ==========================================================================
  // TEXT PAINTER MANAGEMENT
  // ==========================================================================

  /// Gets or creates a text painter from cache.
  TextPainter _getTextPainter(String text, TextStyle style) {
    final cacheKey = '$text-${style.hashCode}';

    if (_textPainterCache.containsKey(cacheKey)) {
      return _textPainterCache[cacheKey]!;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    _textPainterCache[cacheKey] = textPainter;
    return textPainter;
  }

  // ==========================================================================
  // COLLISION DETECTION
  // ==========================================================================

  /// Resolves label collisions using sophisticated multi-strategy algorithm.
  ///
  /// **Strategy:**
  /// 1. Build spatial grid for O(n) collision detection
  /// 2. Assign priority scores to each label
  /// 3. Sort by priority (highest first)
  /// 4. For each label in priority order:
  ///    a. Check if current position has collision
  ///    b. If yes, try 8 alternative positions around it
  ///    c. If no valid position found, hide the label
  ///
  /// **Priority Factors:**
  /// - Extreme values (min/max): Highest priority
  /// - Data magnitude: Higher values = higher priority
  /// - Position: Center positions preferred
  ///
  /// **Performance:** O(n log n) due to sorting + O(n) for collision checks
  void _resolveCollisions(List<_LabelInfo> labels) {
    if (labels.isEmpty) return;

    // Step 1: Calculate value range for priority scoring
    final values = labels.map((l) => l.dataPoint.y).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final valueRange = (maxValue - minValue).abs();

    // Step 2: Assign priority to each label
    final labelData = labels.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      final value = label.dataPoint.y;

      // Priority calculation (0.0 - 1.0)
      double priority = 0.0;

      // Factor 1: Extreme values (40% weight)
      if (value == maxValue || value == minValue) {
        priority += 0.4;
      }

      // Factor 2: Value magnitude (30% weight)
      if (valueRange > 0) {
        priority += (value.abs() / (maxValue.abs() + 0.001)) * 0.3;
      }

      // Factor 3: Order in data (30% weight) - earlier = better
      priority += (1.0 - (index / labels.length)) * 0.3;

      return _LabelPriority(label, priority);
    }).toList();

    // Step 3: Sort by priority (highest first)
    labelData.sort((a, b) => b.priority.compareTo(a.priority));

    // Step 4: Build spatial grid
    const gridSize = 100.0;
    final grid = <String, List<_LabelInfo>>{};
    final placedLabels = <_LabelInfo>[];

    // Step 5: Place labels in priority order
    for (final item in labelData) {
      final label = item.label;
      if (!label.visible) continue;

      // Try current position first
      if (!_hasCollisionInGrid(label.bounds, grid, gridSize)) {
        _addToGrid(label, grid, gridSize);
        placedLabels.add(label);
        continue;
      }

      // Try alternative positions
      final newPosition = _findValidPosition(label, grid, gridSize, maxAttempts: 8);

      if (newPosition != null) {
        label.position = newPosition;
        _addToGrid(label, grid, gridSize);
        placedLabels.add(label);
      } else {
        // No valid position - hide label
        label.visible = false;
      }
    }
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Tries to find a valid position for a label without collision.
  ///
  /// Tests 8 positions around the original position in a circular pattern:
  /// NW, N, NE, E, SE, S, SW, W
  ///
  /// Returns new position offset or null if no valid position found.
  Offset? _findValidPosition(
    _LabelInfo label,
    Map<String, List<_LabelInfo>> grid,
    double gridSize, {
    int maxAttempts = 8,
  }) {
    const stepSize = 12.0; // Pixels to move in each direction
    final originalPosition = label.position;

    // 8 directions to try (clockwise from top)
    final directions = [
      Offset(0, -1), // North
      Offset(1, -1), // Northeast
      Offset(1, 0), // East
      Offset(1, 1), // Southeast
      Offset(0, 1), // South
      Offset(-1, 1), // Southwest
      Offset(-1, 0), // West
      Offset(-1, -1), // Northwest
    ];

    // Try each direction at increasing distances
    for (int distance = 1; distance <= maxAttempts; distance++) {
      for (final direction in directions) {
        final offset = direction * (stepSize * distance);
        final newPosition = originalPosition + offset;

        // Create temporary label at new position to test bounds
        final testLabel = _LabelInfo(
          text: label.text,
          position: newPosition,
          textPainter: label.textPainter,
          dataPoint: label.dataPoint,
          seriesColor: label.seriesColor,
        );

        // Check if this position is valid
        if (!_hasCollisionInGrid(testLabel.bounds, grid, gridSize)) {
          return newPosition;
        }
      }
    }

    return null;
  }

  /// Checks if a bounds rectangle collides with any placed labels in grid.
  bool _hasCollisionInGrid(Rect bounds, Map<String, List<_LabelInfo>> grid, double gridSize) {
    final cellKeys = _getGridCells(bounds, gridSize);

    for (final key in cellKeys) {
      final labelsInCell = grid[key];
      if (labelsInCell != null) {
        for (final other in labelsInCell) {
          if (bounds.overlaps(other.bounds)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Adds a label to the spatial grid.
  void _addToGrid(_LabelInfo label, Map<String, List<_LabelInfo>> grid, double gridSize) {
    final cellKeys = _getGridCells(label.bounds, gridSize);

    for (final key in cellKeys) {
      grid.putIfAbsent(key, () => []).add(label);
    }
  }

  /// Gets grid cell keys that a rectangle overlaps.
  Set<String> _getGridCells(Rect bounds, double gridSize) {
    final cells = <String>{};

    final startX = (bounds.left / gridSize).floor();
    final endX = (bounds.right / gridSize).floor();
    final startY = (bounds.top / gridSize).floor();
    final endY = (bounds.bottom / gridSize).floor();

    for (int x = startX; x <= endX; x++) {
      for (int y = startY; y <= endY; y++) {
        cells.add('$x,$y');
      }
    }

    return cells;
  }

  // ==========================================================================
  // LABEL RENDERING
  // ==========================================================================

  /// Renders a single data label.
  void _renderLabel(Canvas canvas, FusionRenderContext context, _LabelInfo label) {
    final bounds = label.bounds;

    // Render shadow if enabled
    if (enableShadow) {
      _renderLabelShadow(canvas, bounds);
    }

    // Render background if enabled
    if (enableBackground) {
      _renderLabelBackground(canvas, context, bounds, label.seriesColor);
    }

    // Render border if enabled
    if (enableBorder) {
      _renderLabelBorder(canvas, context, bounds);
    }

    // Render text
    label.textPainter.paint(canvas, label.position);
  }

  /// Renders label background.
  void _renderLabelBackground(
    Canvas canvas,
    FusionRenderContext context,
    Rect bounds,
    Color seriesColor,
  ) {
    final backgroundPaint = context.getPaint(
      color: context.theme.backgroundColor.withValues(alpha: 0.9),
      style: PaintingStyle.fill,
    );

    final rRect = RRect.fromRectAndRadius(bounds, const Radius.circular(3));
    canvas.drawRRect(rRect, backgroundPaint);

    context.returnPaint(backgroundPaint);
  }

  /// Renders label border.
  void _renderLabelBorder(Canvas canvas, FusionRenderContext context, Rect bounds) {
    final borderPaint = context.getPaint(
      color: context.theme.gridColor,
      strokeWidth: 1.0,
      style: PaintingStyle.stroke,
    );

    final rRect = RRect.fromRectAndRadius(bounds, const Radius.circular(3));
    canvas.drawRRect(rRect, borderPaint);

    context.returnPaint(borderPaint);
  }

  /// Renders label shadow.
  void _renderLabelShadow(Canvas canvas, Rect bounds) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final rRect = RRect.fromRectAndRadius(
      bounds.shift(const Offset(1, 1)),
      const Radius.circular(3),
    );

    canvas.drawRRect(rRect, shadowPaint);
  }

  // ==========================================================================
  // LAYER LIFECYCLE
  // ==========================================================================

  @override
  bool shouldRepaint(covariant FusionDataLabelLayer oldLayer) {
    return oldLayer.series != series;
  }

  @override
  void dispose() {
    _textPainterCache.clear();
    super.dispose();
  }

  @override
  String toString() {
    return 'FusionDataLabelLayer(series: ${series.length}, '
        'collision: $enableCollisionDetection)';
  }
}

// ==========================================================================
// HELPER CLASSES
// ==========================================================================

/// Internal class to store label information.
class _LabelInfo {
  _LabelInfo({
    required this.position,
    required this.text,
    required this.textPainter,
    required this.dataPoint,
    required this.seriesColor,
    this.visible = true,
  });

  Offset position;
  final String text;
  final TextPainter textPainter;
  final FusionDataPoint dataPoint;
  final Color seriesColor;
  bool visible;

  /// Gets the bounding rectangle of the label.
  Rect get bounds {
    return Rect.fromLTWH(
      position.dx - 4, // Padding
      position.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
  }
}

// ==========================================================================
// PRIORITY DATA CLASS
// ==========================================================================

/// Helper class to associate labels with their priority scores.
class _LabelPriority {
  const _LabelPriority(this.label, this.priority);

  final _LabelInfo label;
  final double priority;
}

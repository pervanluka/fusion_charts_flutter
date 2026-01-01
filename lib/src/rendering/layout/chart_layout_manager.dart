import 'package:flutter/material.dart';

import '../../configuration/fusion_legend_configuration.dart';
import '../../core/axis/base/fusion_axis_renderer.dart';
import '../../data/fusion_data_point.dart';
import '../../themes/fusion_chart_theme.dart';
import 'chart_layout.dart';

/// Manages chart layout calculation.
///
/// This is the "brain" that determines where everything goes on the chart.
/// It calculates margins, plot area, axis areas, and legend positioning.
///
/// ## Process:
/// 1. Calculate axis bounds from data
/// 2. Generate axis labels
/// 3. Measure label sizes
/// 4. Calculate margins
/// 5. Calculate plot area
/// 6. Position all elements
///
/// ## Example:
///
/// ```dart
/// final manager = ChartLayoutManager(
///   xAxisRenderer: NumericAxisRenderer(...),
///   yAxisRenderer: NumericAxisRenderer(...),
/// );
///
/// final layout = manager.calculateLayout(
///   chartSize: size,
///   series: chartSeries,
/// );
/// ```
class ChartLayoutManager {
  /// Creates a chart layout manager.
  ChartLayoutManager({
    required this.xAxisRenderer,
    required this.yAxisRenderer,
    this.theme,
    this.title,
    this.legend,
    this.padding = const EdgeInsets.all(4),
    this.enableCaching = true,
  });

  /// X-axis renderer for measurements and rendering.
  final FusionAxisRenderer xAxisRenderer;

  /// Y-axis renderer for measurements and rendering.
  final FusionAxisRenderer yAxisRenderer;

  /// Chart theme for styling and spacing.
  final FusionChartTheme? theme;

  /// Chart title (if present).
  final String? title;

  /// Legend configuration (if present).
  final ChartLegend? legend;

  /// Padding around the entire chart.
  final EdgeInsets padding;

  /// Whether to cache layout calculations.
  final bool enableCaching;

  /// Cached layout (for performance).
  ChartLayout? _cachedLayout;

  /// Cached size for cache validation.
  Size? _cachedSize;

  /// Cached data hash for cache validation.
  int? _cachedDataHash;

  // ==========================================================================
  // MAIN LAYOUT CALCULATION
  // ==========================================================================

  /// Calculates complete chart layout.
  ///
  /// This is the main entry point. Call this once per render frame.
  ChartLayout calculateLayout({
    required Size chartSize,
    required List<List<FusionDataPoint>> series,
  }) {
    // Check cache
    if (enableCaching && _canUseCache(chartSize, series)) {
      return _cachedLayout!;
    }

    // Step 1: Extract data ranges from all series
    final xValues = <double>[];
    final yValues = <double>[];

    for (final seriesData in series) {
      for (final point in seriesData) {
        xValues.add(point.x);
        yValues.add(point.y);
      }
    }

    // Step 2: Calculate axis bounds
    final xBounds = xAxisRenderer.calculateBounds(xValues);
    final yBounds = yAxisRenderer.calculateBounds(yValues);

    // Step 3: Generate axis labels
    final xLabels = xAxisRenderer.generateLabels(xBounds);
    final yLabels = yAxisRenderer.generateLabels(yBounds);

    // Step 4: Measure label sizes
    final xLabelSize = xAxisRenderer.measureAxisLabels(xLabels, chartSize);
    final yLabelSize = yAxisRenderer.measureAxisLabels(yLabels, chartSize);

    // Step 5: Calculate component sizes
    final titleHeight = _calculateTitleHeight();
    final legendSize = _calculateLegendSize(series);

    // Step 6: Calculate margins
    final margins = EdgeInsets.only(
      left: padding.left + yLabelSize.width,
      top: padding.top + titleHeight,
      right: padding.right + (legendSize?.width ?? 0),
      bottom: padding.bottom + xLabelSize.height,
    );

    // Step 7: Calculate plot area (remaining space after margins)
    final plotArea = Rect.fromLTRB(
      margins.left,
      margins.top,
      chartSize.width - margins.right,
      chartSize.height - margins.bottom,
    );

    // Step 8: Calculate axis areas
    final xAxisArea = Rect.fromLTRB(
      plotArea.left,
      plotArea.bottom,
      plotArea.right,
      chartSize.height - padding.bottom,
    );

    final yAxisArea = Rect.fromLTRB(
      padding.left,
      plotArea.top,
      plotArea.left,
      plotArea.bottom,
    );

    // Step 9: Calculate optional areas
    Rect? titleArea;
    if (title != null) {
      titleArea = Rect.fromLTRB(
        padding.left,
        padding.top,
        chartSize.width - padding.right,
        margins.top,
      );
    }

    Rect? legendArea;
    if (legend != null && legendSize != null) {
      legendArea = Rect.fromLTRB(
        plotArea.right,
        plotArea.top,
        chartSize.width - padding.right,
        plotArea.bottom,
      );
    }

    // Step 10: Create layout
    final layout = ChartLayout(
      chartSize: chartSize,
      plotArea: plotArea,
      xAxisArea: xAxisArea,
      yAxisArea: yAxisArea,
      xBounds: xBounds,
      yBounds: yBounds,
      margins: margins,
      titleArea: titleArea,
      legendArea: legendArea,
      xAxisLabelArea: xAxisArea,
      yAxisLabelArea: yAxisArea,
    );

    // Cache the result
    if (enableCaching) {
      _cachedLayout = layout;
      _cachedSize = chartSize;
      _cachedDataHash = _calculateDataHash(series);
    }

    return layout;
  }

  // ==========================================================================
  // SIZE CALCULATIONS
  // ==========================================================================

  /// Calculates title height.
  double _calculateTitleHeight() {
    if (title == null) return 0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style:
            theme?.titleStyle ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    return textPainter.height + 12; // Add spacing
  }

  /// Calculates legend size.
  Size? _calculateLegendSize(List<List<FusionDataPoint>> series) {
    if (legend == null || series.isEmpty) return null;

    // Calculate based on series count and legend style
    const itemHeight = 24.0;
    const itemWidth = 120.0;

    switch (legend!.position) {
      case FusionLegendPosition.right:
      case FusionLegendPosition.left:
        // Vertical legend
        return Size(itemWidth, series.length * itemHeight);

      case FusionLegendPosition.top:
      case FusionLegendPosition.bottom:
        // Horizontal legend
        return Size(series.length * itemWidth, itemHeight);
    }
  }

  // ==========================================================================
  // CACHING
  // ==========================================================================

  /// Checks if cached layout can be used.
  bool _canUseCache(Size chartSize, List<List<FusionDataPoint>> series) {
    if (_cachedLayout == null) return false;
    if (_cachedSize != chartSize) return false;

    final currentHash = _calculateDataHash(series);
    return _cachedDataHash == currentHash;
  }

  /// Calculates hash of data for cache validation.
  int _calculateDataHash(List<List<FusionDataPoint>> series) {
    int hash = series.length;

    for (final seriesData in series) {
      hash = hash * 31 + seriesData.length;

      // Sample a few points for hash (not all for performance)
      if (seriesData.isNotEmpty) {
        hash = hash * 31 + seriesData.first.x.hashCode;
        hash = hash * 31 + seriesData.first.y.hashCode;
        hash = hash * 31 + seriesData.last.x.hashCode;
        hash = hash * 31 + seriesData.last.y.hashCode;

        if (seriesData.length > 2) {
          final middle = seriesData[seriesData.length ~/ 2];
          hash = hash * 31 + middle.x.hashCode;
          hash = hash * 31 + middle.y.hashCode;
        }
      }
    }

    return hash;
  }

  // ==========================================================================
  // UTILITIES
  // ==========================================================================

  /// Clears the layout cache.
  void clearCache() {
    _cachedLayout = null;
    _cachedSize = null;
    _cachedDataHash = null;
  }

  /// Disposes of resources.
  void dispose() {
    clearCache();
  }
}

// =============================================================================
// SUPPORTING CLASSES
// =============================================================================

/// Legend configuration.
class ChartLegend {
  const ChartLegend({
    this.position = FusionLegendPosition.right,
    this.alignment = LegendAlignment.center,
    this.showTitle = false,
    this.title = 'Legend',
  });

  /// Position of the legend relative to chart.
  final FusionLegendPosition position;

  /// Alignment within the legend area.
  final LegendAlignment alignment;

  /// Whether to show legend title.
  final bool showTitle;

  /// Legend title text.
  final String title;
}

/// Legend alignment options.
enum LegendAlignment { start, center, end }

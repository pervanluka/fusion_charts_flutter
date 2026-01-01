import 'package:flutter/material.dart';

import '../../configuration/fusion_legend_configuration.dart';
import '../../series/series_with_data_points.dart';
import '../engine/fusion_render_context.dart';
import 'fusion_render_layer.dart';

/// Renders chart legend showing all series.
///
/// The legend provides visual identification of series in the chart,
/// typically showing the series color/marker and name.
///
/// ## Features
///
/// - Multiple positions (top, bottom, left, right)
/// - Horizontal/vertical layouts
/// - Interactive (toggle series visibility - coming soon)
/// - Custom styling
/// - Scrollable for many series
/// - Icon/marker shapes
///
/// ## Layout Positions
///
/// ```
/// ┌─────────────────────────┐
/// │     Top Legend          │
/// ├────┬──────────────┬─────┤
/// │Left│              │Right│
/// │    │   Chart      │     │
/// │    │              │     │
/// ├────┴──────────────┴─────┤
/// │    Bottom Legend        │
/// └─────────────────────────┘
/// ```
///
/// ## Example
///
/// ```dart
/// final legendLayer = FusionLegendLayer(
///   series: allSeries,
///   configuration: FusionLegendConfiguration(
///     position: LegendPosition.bottom,
///     alignment: LegendAlignment.center,
///     showMarkers: true,
///   ),
/// );
/// ```
class FusionLegendLayer extends FusionRenderLayer {
  /// Creates a legend rendering layer.
  FusionLegendLayer({required this.series, required this.configuration})
    : super(
        name: 'legend',
        zIndex: 80, // Before axes
        cacheable: true, // Legend rarely changes
      );

  /// All series to show in legend.
  final List<SeriesWithDataPoints> series;

  /// Legend configuration.
  final FusionLegendConfiguration configuration;

  /// Cache for text painters.
  final Map<String, TextPainter> _textPainterCache = {};

  // ==========================================================================
  // MAIN PAINT METHOD
  // ==========================================================================

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    if (!configuration.visible || series.isEmpty) return;

    // Calculate legend area
    final legendArea = _calculateLegendArea(size, context);

    // Render legend background
    if (configuration.backgroundColor != null) {
      _renderBackground(canvas, context, legendArea);
    }

    // Render legend items
    _renderLegendItems(canvas, context, legendArea);

    // Render border if enabled
    if (configuration.borderColor != null && configuration.borderWidth > 0) {
      _renderBorder(canvas, context, legendArea);
    }
  }

  // ==========================================================================
  // LAYOUT CALCULATION
  // ==========================================================================

  /// Calculates the legend area based on position and content.
  Rect _calculateLegendArea(Size size, FusionRenderContext context) {
    final itemHeight = configuration.iconSize + configuration.iconPadding * 2;
    final itemSpacing = configuration.itemSpacing;
    final padding = configuration.padding;

    // Calculate total legend size based on series count
    final isVertical =
        configuration.position == FusionLegendPosition.left ||
        configuration.position == FusionLegendPosition.right;

    if (isVertical) {
      final legendHeight =
          (series.length * itemHeight) +
          ((series.length - 1) * itemSpacing) +
          padding.top +
          padding.bottom;

      const legendWidth = 150.0; // Fixed width for vertical legends

      switch (configuration.position) {
        case FusionLegendPosition.left:
          return Rect.fromLTWH(10, (size.height - legendHeight) / 2, legendWidth, legendHeight);

        case FusionLegendPosition.right:
          return Rect.fromLTWH(
            size.width - legendWidth - 10,
            (size.height - legendHeight) / 2,
            legendWidth,
            legendHeight,
          );

        default:
          return Rect.zero;
      }
    } else {
      // Horizontal layout
      final legendHeight = itemHeight + padding.top + padding.bottom;
      final legendWidth = size.width * 0.8; // 80% of chart width

      switch (configuration.position) {
        case FusionLegendPosition.top:
          return Rect.fromLTWH((size.width - legendWidth) / 2, 10, legendWidth, legendHeight);

        case FusionLegendPosition.bottom:
          return Rect.fromLTWH(
            (size.width - legendWidth) / 2,
            size.height - legendHeight - 10,
            legendWidth,
            legendHeight,
          );

        default:
          return Rect.zero;
      }
    }
  }

  // ==========================================================================
  // BACKGROUND & BORDER
  // ==========================================================================

  /// Renders legend background.
  void _renderBackground(Canvas canvas, FusionRenderContext context, Rect legendArea) {
    final backgroundPaint = context.getPaint(
      color: configuration.backgroundColor ?? context.theme.backgroundColor.withValues(alpha: 0.95),
      style: PaintingStyle.fill,
    );

    final rRect = RRect.fromRectAndRadius(legendArea, Radius.circular(configuration.borderRadius));

    canvas.drawRRect(rRect, backgroundPaint);
    context.returnPaint(backgroundPaint);
  }

  /// Renders legend border.
  void _renderBorder(Canvas canvas, FusionRenderContext context, Rect legendArea) {
    final borderPaint = context.getPaint(
      color: configuration.borderColor ?? context.theme.gridColor,
      strokeWidth: configuration.borderWidth,
      style: PaintingStyle.stroke,
    );

    final rRect = RRect.fromRectAndRadius(legendArea, Radius.circular(configuration.borderRadius));

    canvas.drawRRect(rRect, borderPaint);
    context.returnPaint(borderPaint);
  }

  // ==========================================================================
  // LEGEND ITEMS
  // ==========================================================================

  /// Renders all legend items.
  void _renderLegendItems(Canvas canvas, FusionRenderContext context, Rect legendArea) {
    final isVertical =
        configuration.position == FusionLegendPosition.left ||
        configuration.position == FusionLegendPosition.right;

    final padding = configuration.padding;
    final itemHeight = configuration.iconSize + configuration.iconPadding * 2;
    var currentOffset = Offset(legendArea.left + padding.left, legendArea.top + padding.top);

    for (final seriesData in series) {
      if (isVertical) {
        _renderVerticalLegendItem(canvas, context, seriesData, currentOffset);
        currentOffset = currentOffset.translate(0, itemHeight + configuration.itemSpacing);
      } else {
        final itemWidth = _renderHorizontalLegendItem(canvas, context, seriesData, currentOffset);
        currentOffset = currentOffset.translate(itemWidth + configuration.itemSpacing, 0);
      }
    }
  }

  /// Renders a single vertical legend item.
  void _renderVerticalLegendItem(
    Canvas canvas,
    FusionRenderContext context,
    SeriesWithDataPoints series,
    Offset position,
  ) {
    // Render marker
    final markerSize = configuration.iconSize;
    final markerCenter = position.translate(markerSize / 2, markerSize / 2);

    final markerPaint = context.getPaint(color: series.color, style: PaintingStyle.fill);

    canvas.drawCircle(markerCenter, markerSize / 2, markerPaint);
    context.returnPaint(markerPaint);

    // Render text
    final textOffset = position.translate(configuration.iconSize + 8, 0);

    final textPainter = _getTextPainter(
      series.name,
      configuration.textStyle ?? context.theme.legendStyle,
    );

    textPainter.paint(canvas, textOffset);
  }

  /// Renders a single horizontal legend item and returns its width.
  double _renderHorizontalLegendItem(
    Canvas canvas,
    FusionRenderContext context,
    SeriesWithDataPoints series,
    Offset position,
  ) {
    var currentX = position.dx;

    // Render marker
    final markerSize = configuration.iconSize;
    final markerCenter = Offset(currentX + markerSize / 2, position.dy + markerSize / 2);

    final markerPaint = context.getPaint(color: series.color, style: PaintingStyle.fill);

    canvas.drawCircle(markerCenter, markerSize / 2, markerPaint);
    context.returnPaint(markerPaint);

    currentX += markerSize + 8;

    // Render text
    final textPainter = _getTextPainter(
      series.name,
      configuration.textStyle ?? context.theme.legendStyle,
    );

    textPainter.paint(canvas, Offset(currentX, position.dy));

    return (currentX - position.dx) + textPainter.width;
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
      maxLines: 1,
      ellipsis: '...',
    )..layout();

    _textPainterCache[cacheKey] = textPainter;
    return textPainter;
  }

  // ==========================================================================
  // LAYER LIFECYCLE
  // ==========================================================================

  @override
  bool shouldRepaint(covariant FusionLegendLayer oldLayer) {
    return oldLayer.series != series || oldLayer.configuration != configuration;
  }

  @override
  void dispose() {
    _textPainterCache.clear();
    super.dispose();
  }

  @override
  String toString() {
    return 'FusionLegendLayer(series: ${series.length}, '
        'position: ${configuration.position})';
  }
}

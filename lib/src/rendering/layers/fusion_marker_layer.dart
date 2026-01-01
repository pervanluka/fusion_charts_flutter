import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/enums/marker_shape.dart';
import '../../series/fusion_series.dart';
import '../../series/series_with_data_points.dart';
import '../engine/fusion_render_context.dart';
import 'fusion_render_layer.dart';

/// Renders data point markers on charts.
///
/// Markers are visual indicators that highlight individual data points.
/// This layer supports multiple marker shapes and customization options.
///
/// ## Supported Marker Shapes
///
/// - **Circle** - Classic round markers
/// - **Square** - Box markers
/// - **Triangle** - Triangular markers
/// - **Diamond** - Diamond-shaped markers
/// - **Cross** - Plus/cross markers
/// - **Star** - Star-shaped markers (5-pointed)
///
/// ## Features
///
/// - Multiple shapes
/// - Custom colors per series
/// - Size control
/// - Border/stroke support
/// - Shadow effects
/// - Animation support
///
/// ## Performance
///
/// - Efficient batch rendering
/// - Paint pooling
/// - Culling for off-screen markers
/// - Optimized for 1000+ markers
///
/// ## Example
///
/// ```dart
/// final markerLayer = FusionMarkerLayer(
///   series: [
///     FusionLineSeries(
///       dataPoints: data,
///       showMarkers: true,
///       markerSize: 8.0,
///       markerShape: MarkerShape.circle,
///       markerColor: Colors.blue,
///     ),
///   ],
/// );
/// ```
class FusionMarkerLayer extends FusionRenderLayer {
  /// Creates a marker rendering layer.
  FusionMarkerLayer({required this.series, this.enableBorders = true, this.enableShadows = false})
    : super(
        name: 'markers',
        zIndex: 60, // After series, before data labels
        cacheable: false, // Markers change with animation
      );

  /// All series to render markers for.
  final List<SeriesWithDataPoints> series;

  /// Whether to render marker borders.
  final bool enableBorders;

  /// Whether to render marker shadows.
  final bool enableShadows;

  // ==========================================================================
  // MAIN PAINT METHOD
  // ==========================================================================

  @override
  void paint(Canvas canvas, Size size, FusionRenderContext context) {
    for (final seriesData in series) {
      if (!seriesData.visible || seriesData.dataPoints.isEmpty) continue;

      // Only render markers for series that support them
      if (seriesData is FusionMarkerSupport) {
        final markerSeries = seriesData as FusionMarkerSupport;
        if (markerSeries.showMarkers) {
          _renderMarkersForSeries(canvas, context, seriesData, markerSeries);
        }
      }
    }
  }

  /// Renders markers for a single series.
  void _renderMarkersForSeries(
    Canvas canvas,
    FusionRenderContext context,
    SeriesWithDataPoints series,
    FusionMarkerSupport markerSeries,
  ) {
    final markerColor = markerSeries.markerColor ?? series.color;
    final markerSize = markerSeries.markerSize;
    final markerShape = markerSeries.markerShape;

    // Apply animation scaling
    final animatedSize = markerSize * context.animationProgress;

    for (final point in series.dataPoints) {
      final screenPos = context.coordSystem.dataToScreen(point);

      // Cull off-screen markers for performance
      if (!context.chartArea.contains(screenPos)) continue;

      // Render shadow if enabled
      if (enableShadows) {
        _renderMarkerShadow(canvas, context, screenPos, animatedSize);
      }

      // Render marker fill
      _renderMarker(canvas, context, screenPos, animatedSize, markerColor, markerShape);

      // Render marker border if enabled
      if (enableBorders) {
        _renderMarkerBorder(canvas, context, screenPos, animatedSize, markerColor, markerShape);
      }
    }
  }

  // ==========================================================================
  // MARKER RENDERING
  // ==========================================================================

  /// Renders a single marker.
  void _renderMarker(
    Canvas canvas,
    FusionRenderContext context,
    Offset position,
    double size,
    Color color,
    MarkerShape shape,
  ) {
    final paint = context.getPaint(color: color, style: PaintingStyle.fill);

    _drawMarkerShape(canvas, position, size, shape, paint);

    context.returnPaint(paint);
  }

  /// Renders marker border.
  void _renderMarkerBorder(
    Canvas canvas,
    FusionRenderContext context,
    Offset position,
    double size,
    Color color,
    MarkerShape shape,
  ) {
    final borderPaint = context.getPaint(
      color: context.theme.backgroundColor, // Contrast with background
      strokeWidth: 1.5,
      style: PaintingStyle.stroke,
    );

    _drawMarkerShape(canvas, position, size, shape, borderPaint);

    context.returnPaint(borderPaint);
  }

  /// Renders marker shadow.
  void _renderMarkerShadow(
    Canvas canvas,
    FusionRenderContext context,
    Offset position,
    double size,
  ) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawCircle(position.translate(1, 1), size / 2, shadowPaint);
  }

  // ==========================================================================
  // MARKER SHAPES
  // ==========================================================================

  /// Draws marker shape based on type.
  void _drawMarkerShape(
    Canvas canvas,
    Offset position,
    double size,
    MarkerShape shape,
    Paint paint,
  ) {
    final radius = size / 2;

    switch (shape) {
      case MarkerShape.circle:
        canvas.drawCircle(position, radius, paint);

      case MarkerShape.square:
        final rect = Rect.fromCenter(center: position, width: size, height: size);
        canvas.drawRect(rect, paint);

      case MarkerShape.triangle:
        _drawTriangle(canvas, position, radius, paint);

      case MarkerShape.diamond:
        _drawDiamond(canvas, position, radius, paint);

      case MarkerShape.cross:
        _drawCross(canvas, position, radius, paint);

      case MarkerShape.x:
        _drawStar(canvas, position, radius, paint);
    }
  }

  /// Draws triangle marker.
  void _drawTriangle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    // Equilateral triangle pointing up
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius, center.dy + radius * 0.5);
    path.lineTo(center.dx - radius, center.dy + radius * 0.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Draws diamond marker.
  void _drawDiamond(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    path.moveTo(center.dx, center.dy - radius); // Top
    path.lineTo(center.dx + radius, center.dy); // Right
    path.lineTo(center.dx, center.dy + radius); // Bottom
    path.lineTo(center.dx - radius, center.dy); // Left
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Draws cross/plus marker.
  void _drawCross(Canvas canvas, Offset center, double radius, Paint paint) {
    final strokePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      strokePaint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      strokePaint,
    );
  }

  /// Draws 5-pointed star marker.
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const pointCount = 5;
    final outerRadius = radius;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < pointCount * 2; i++) {
      final angle = (i * math.pi / pointCount) - (math.pi / 2);
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  // ==========================================================================
  // LAYER LIFECYCLE
  // ==========================================================================

  @override
  bool shouldRepaint(covariant FusionMarkerLayer oldLayer) {
    return oldLayer.series != series;
  }

  @override
  String toString() {
    return 'FusionMarkerLayer(series: ${series.length}, '
        'borders: $enableBorders, shadows: $enableShadows)';
  }
}

import 'package:flutter/material.dart';

import '../configuration/fusion_axis_configuration.dart';
import '../data/fusion_data_point.dart';
import '../themes/fusion_chart_theme.dart';

/// Base class for all Fusion chart painters.
///
/// This is the rock-solid foundation that ensures pixel-perfect rendering
/// across all chart types. Follows the Template Method pattern (SOLID).
///
/// ## Design Principles
///
/// - **Precision**: All calculations use double precision
/// - **Performance**: Cached computations, efficient clipping
/// - **Quality**: Anti-aliasing, proper stroke caps
/// - **Flexibility**: Extensible for all chart types
///
/// ## Architecture
///
/// ```
/// FusionChartPainterBase (abstract)
///     ↓
///     ├─ FusionLineChartPainter
///     ├─ FusionBarChartPainter
///     ├─ FusionAreaChartPainter
///     └─ FusionPieChartPainter
/// ```
abstract class FusionChartPainterBase extends CustomPainter {
  /// Creates a base chart painter.
  FusionChartPainterBase({
    required this.theme,
    required this.xAxis,
    required this.yAxis,
    this.enableGrid = true,
    this.enableAxis = true,
    this.animation = 1.0,
  }) : assert(animation >= 0.0 && animation <= 1.0);

  /// The theme controlling visual appearance.
  final FusionChartTheme theme;

  /// X-axis configuration.
  final FusionAxisConfiguration? xAxis;

  /// Y-axis configuration.
  final FusionAxisConfiguration? yAxis;

  /// Whether to draw grid lines.
  final bool enableGrid;

  /// Whether to draw axis lines and labels.
  final bool enableAxis;

  /// Animation progress (0.0 to 1.0).
  final double animation;

  // ==========================================================================
  // COORDINATE SYSTEM
  // ==========================================================================

  /// Cached chart area (content area without margins).
  late Rect _chartArea;

  /// Cached data bounds.
  Rect _dataBounds = Rect.zero;

  /// Gets the chart drawing area (excludes margins for axes and labels).
  Rect get chartArea => _chartArea;

  /// Gets the data coordinate bounds.
  Rect get dataBounds => _dataBounds;

  /// Protected setter allowing subclasses to update data bounds.
  @protected
  set dataBounds(Rect bounds) {
    _dataBounds = bounds;
  }

  // ==========================================================================
  // TRANSFORMATION
  // ==========================================================================

  /// Converts data X coordinate to screen X coordinate.
  ///
  /// This is the CRITICAL function for pixel-perfect alignment.
  /// Uses linear interpolation with high precision.
  ///
  /// Formula: screenX = chartArea.left + (dataX - minX) / (maxX - minX) * chartArea.width
  double dataXToScreenX(double dataX) {
    final range = _dataBounds.width;
    if (range == 0) return _chartArea.left;

    final normalized = (dataX - _dataBounds.left) / range;
    return _chartArea.left + (normalized * _chartArea.width);
  }

  /// Converts data Y coordinate to screen Y coordinate.
  ///
  /// Note: Y-axis is inverted (screen Y increases downward).
  ///
  /// Formula: screenY = chartArea.bottom - (dataY - minY) / (maxY - minY) * chartArea.height
  double dataYToScreenY(double dataY) {
    final range = _dataBounds.height;
    if (range == 0) return _chartArea.bottom;

    final normalized = (dataY - _dataBounds.top) / range;
    return _chartArea.bottom - (normalized * _chartArea.height);
  }

  /// Converts screen X coordinate back to data X coordinate.
  double screenXToDataX(double screenX) {
    final range = _chartArea.width;
    if (range == 0) return _dataBounds.left;

    final normalized = (screenX - _chartArea.left) / range;
    return _dataBounds.left + (normalized * _dataBounds.width);
  }

  /// Converts screen Y coordinate back to data Y coordinate.
  double screenYToDataY(double screenY) {
    final range = _chartArea.height;
    if (range == 0) return _dataBounds.top;

    final normalized = (_chartArea.bottom - screenY) / range;
    return _dataBounds.top + (normalized * _dataBounds.height);
  }

  /// Converts a data point to screen coordinates.
  Offset dataToScreen(FusionDataPoint point) {
    return Offset(dataXToScreenX(point.x), dataYToScreenY(point.y));
  }

  /// Converts screen coordinates to data point.
  FusionDataPoint screenToData(Offset screenPoint) {
    return FusionDataPoint(
      screenXToDataX(screenPoint.dx),
      screenYToDataY(screenPoint.dy),
    );
  }

  // ==========================================================================
  // PAINTING TEMPLATE METHOD (SOLID: Open/Closed Principle)
  // ==========================================================================

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Calculate layout
    _calculateLayout(size);

    // 2. Clip to chart area (performance optimization)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 3. Draw background
    _drawBackground(canvas, size);

    // 4. Draw grid (if enabled)
    if (enableGrid) {
      _drawGrid(canvas);
    }

    // 5. Save state for chart content
    canvas.save();
    canvas.clipRect(_chartArea);

    // 6. Draw chart-specific content (TEMPLATE METHOD)
    paintChartContent(canvas, size);

    // 7. Restore state
    canvas.restore();

    // 8. Draw axes (if enabled)
    if (enableAxis) {
      _drawAxes(canvas);
    }

    // 9. Draw axis labels
    if (enableAxis) {
      _drawAxisLabels(canvas);
    }

    // 10. Restore state
    canvas.restore();
  }

  /// Template method: Subclasses implement chart-specific rendering.
  ///
  /// This is where line charts draw lines, bar charts draw bars, etc.
  void paintChartContent(Canvas canvas, Size size);

  // ==========================================================================
  // LAYOUT CALCULATION
  // ==========================================================================

  /// Calculates the layout and coordinate system.
  void _calculateLayout(Size size) {
    // Calculate margins for axes and labels
    final leftMargin = enableAxis ? 60.0 : 10.0;
    const rightMargin = 10.0;
    const topMargin = 10.0;
    final bottomMargin = enableAxis ? 40.0 : 10.0;

    // Chart area is the drawing area minus margins
    _chartArea = Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );

    // Calculate data bounds from axis configuration
    final minX = xAxis?.effectiveMin ?? 0.0;
    final maxX = xAxis?.effectiveMax ?? 10.0;
    final minY = yAxis?.effectiveMin ?? 0.0;
    final maxY = yAxis?.effectiveMax ?? 100.0;

    _dataBounds = Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // ==========================================================================
  // BACKGROUND
  // ==========================================================================

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  // ==========================================================================
  // GRID RENDERING (Pixel-Perfect)
  // ==========================================================================

  void _drawGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = theme.gridColor
      ..strokeWidth = theme.gridLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square; // Crisp grid lines

    // Get effective intervals
    final xInterval = xAxis?.interval ?? xAxis?.effectiveInterval ?? 1.0;

    final yInterval = yAxis?.interval ?? yAxis?.effectiveInterval ?? 10.0;

    // Draw vertical grid lines (X-axis)
    double currentX = _dataBounds.left;
    while (currentX <= _dataBounds.right) {
      final screenX = dataXToScreenX(currentX);

      // Snap to pixel boundary for crisp lines
      final snappedX = screenX.roundToDouble();

      canvas.drawLine(
        Offset(snappedX, _chartArea.top),
        Offset(snappedX, _chartArea.bottom),
        gridPaint,
      );

      currentX += xInterval;
    }

    // Draw horizontal grid lines (Y-axis)
    double currentY = _dataBounds.top;
    while (currentY <= _dataBounds.bottom) {
      final screenY = dataYToScreenY(currentY);

      // Snap to pixel boundary for crisp lines
      final snappedY = screenY.roundToDouble();

      canvas.drawLine(
        Offset(_chartArea.left, snappedY),
        Offset(_chartArea.right, snappedY),
        gridPaint,
      );

      currentY += yInterval;
    }
  }

  // ==========================================================================
  // AXIS RENDERING
  // ==========================================================================

  void _drawAxes(Canvas canvas) {
    final axisPaint = Paint()
      ..color = theme.axisColor
      ..strokeWidth = theme.axisLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // X-axis line
    canvas.drawLine(
      Offset(_chartArea.left, _chartArea.bottom),
      Offset(_chartArea.right, _chartArea.bottom),
      axisPaint,
    );

    // Y-axis line
    canvas.drawLine(
      Offset(_chartArea.left, _chartArea.top),
      Offset(_chartArea.left, _chartArea.bottom),
      axisPaint,
    );
  }

  // ==========================================================================
  // AXIS LABELS (Pixel-Perfect Text Rendering)
  // ==========================================================================

  void _drawAxisLabels(Canvas canvas) {
    if (xAxis != null) {
      _drawXAxisLabels(canvas);
    }

    if (yAxis != null) {
      _drawYAxisLabels(canvas);
    }
  }

  void _drawXAxisLabels(Canvas canvas) {
    final labelStyle = xAxis!.labelStyle ?? theme.axisLabelStyle;

    final xInterval = xAxis!.interval ?? xAxis!.effectiveInterval;

    double currentX = _dataBounds.left;
    while (currentX <= _dataBounds.right) {
      final screenX = dataXToScreenX(currentX);

      // Format label
      final labelText =
          xAxis!.labelFormatter?.call(currentX) ?? currentX.toStringAsFixed(0);

      // Create text painter
      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      // Draw label centered below axis
      final offset = Offset(
        screenX - (textPainter.width / 2),
        _chartArea.bottom + 8,
      );

      textPainter.paint(canvas, offset);

      currentX += xInterval;
    }
  }

  void _drawYAxisLabels(Canvas canvas) {
    final labelStyle = yAxis!.labelStyle ?? theme.axisLabelStyle;

    final yInterval = yAxis!.interval ?? yAxis!.effectiveInterval;

    double currentY = _dataBounds.top;
    while (currentY <= _dataBounds.bottom) {
      final screenY = dataYToScreenY(currentY);

      // Format label
      final labelText =
          yAxis!.labelFormatter?.call(currentY) ?? currentY.toStringAsFixed(0);

      // Create text painter
      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      // Draw label to the left of axis
      final offset = Offset(
        _chartArea.left - textPainter.width - 8,
        screenY - (textPainter.height / 2),
      );

      textPainter.paint(canvas, offset);

      currentY += yInterval;
    }
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Creates a high-quality paint for series rendering.
  Paint createSeriesPaint({
    required Color color,
    double strokeWidth = 3.0,
    PaintingStyle style = PaintingStyle.stroke,
    bool enableAntiAlias = true,
  }) {
    return Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = style
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = enableAntiAlias;
  }

  /// Creates a gradient shader for series.
  Shader? createGradientShader(LinearGradient gradient, Rect bounds) {
    return gradient.createShader(bounds);
  }

  // ==========================================================================
  // CUSTOM PAINTER OVERRIDES
  // ==========================================================================

  @override
  bool shouldRepaint(covariant FusionChartPainterBase oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.theme != theme ||
        oldDelegate.enableGrid != enableGrid ||
        oldDelegate.enableAxis != enableAxis;
  }

  @override
  bool hitTest(Offset position) => true;
}

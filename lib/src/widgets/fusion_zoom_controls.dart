import 'package:flutter/material.dart';

/// Zoom control buttons overlay for charts.
///
/// Provides +, -, and reset buttons for zoom control.
/// Typically positioned in a corner of the chart.
///
/// ## Example
///
/// ```dart
/// Stack(
///   children: [
///     FusionLineChart(...),
///     Positioned(
///       right: 8,
///       bottom: 8,
///       child: FusionZoomControls(
///         onZoomIn: () => state.zoomIn(),
///         onZoomOut: () => state.zoomOut(),
///         onReset: () => state.reset(),
///       ),
///     ),
///   ],
/// )
/// ```
class FusionZoomControls extends StatelessWidget {
  const FusionZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    super.key,
    this.showResetButton = true,
    this.direction = Axis.vertical,
    this.buttonSize = 32.0,
    this.iconSize = 18.0,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 8.0,
    this.spacing = 4.0,
    this.elevation = 2.0,
  });

  /// Callback when zoom in button is pressed.
  final VoidCallback onZoomIn;

  /// Callback when zoom out button is pressed.
  final VoidCallback onZoomOut;

  /// Callback when reset button is pressed.
  final VoidCallback onReset;

  /// Whether to show the reset button.
  final bool showResetButton;

  /// Direction of button layout (vertical or horizontal).
  final Axis direction;

  /// Size of each button.
  final double buttonSize;

  /// Size of icons in buttons.
  final double iconSize;

  /// Background color of buttons. Defaults to surface color.
  final Color? backgroundColor;

  /// Color of icons. Defaults to onSurface color.
  final Color? iconColor;

  /// Border radius of button group.
  final double borderRadius;

  /// Spacing between buttons.
  final double spacing;

  /// Elevation of button group.
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final fgColor = iconColor ?? theme.colorScheme.onSurface;

    final buttons = <Widget>[
      _ZoomButton(
        icon: Icons.add,
        onPressed: onZoomIn,
        size: buttonSize,
        iconSize: iconSize,
        color: fgColor,
        tooltip: 'Zoom in',
      ),
      SizedBox(
        width: direction == Axis.horizontal ? spacing : 0,
        height: direction == Axis.vertical ? spacing : 0,
      ),
      _ZoomButton(
        icon: Icons.remove,
        onPressed: onZoomOut,
        size: buttonSize,
        iconSize: iconSize,
        color: fgColor,
        tooltip: 'Zoom out',
      ),
      if (showResetButton) ...[
        SizedBox(
          width: direction == Axis.horizontal ? spacing : 0,
          height: direction == Axis.vertical ? spacing : 0,
        ),
        _ZoomButton(
          icon: Icons.fit_screen,
          onPressed: onReset,
          size: buttonSize,
          iconSize: iconSize,
          color: fgColor,
          tooltip: 'Reset zoom',
        ),
      ],
    ];

    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: direction == Axis.vertical
            ? Column(mainAxisSize: MainAxisSize.min, children: buttons)
            : Row(mainAxisSize: MainAxisSize.min, children: buttons),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    required this.iconSize,
    required this.color,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }
}

/// Selection zoom overlay that draws the selection rectangle.
///
/// Shows a semi-transparent rectangle while user is dragging
/// to select an area for zooming.
class FusionSelectionZoomOverlay extends StatelessWidget {
  const FusionSelectionZoomOverlay({
    required this.selectionRect,
    super.key,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  /// The selection rectangle to draw.
  final Rect selectionRect;

  /// Fill color of selection. Defaults to primary color with low opacity.
  final Color? fillColor;

  /// Border color of selection. Defaults to primary color.
  final Color? borderColor;

  /// Border width.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill = fillColor ?? theme.colorScheme.primary.withValues(alpha: 0.15);
    final border = borderColor ?? theme.colorScheme.primary;

    return CustomPaint(
      painter: _SelectionZoomPainter(
        rect: selectionRect,
        fillColor: fill,
        borderColor: border,
        borderWidth: borderWidth,
      ),
    );
  }
}

class _SelectionZoomPainter extends CustomPainter {
  _SelectionZoomPainter({
    required this.rect,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final Rect rect;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRect(rect, borderPaint);

    // Draw corner handles
    const handleSize = 8.0;
    final handlePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    // Top-left
    canvas.drawRect(
      Rect.fromCenter(
        center: rect.topLeft,
        width: handleSize,
        height: handleSize,
      ),
      handlePaint,
    );
    // Top-right
    canvas.drawRect(
      Rect.fromCenter(
        center: rect.topRight,
        width: handleSize,
        height: handleSize,
      ),
      handlePaint,
    );
    // Bottom-left
    canvas.drawRect(
      Rect.fromCenter(
        center: rect.bottomLeft,
        width: handleSize,
        height: handleSize,
      ),
      handlePaint,
    );
    // Bottom-right
    canvas.drawRect(
      Rect.fromCenter(
        center: rect.bottomRight,
        width: handleSize,
        height: handleSize,
      ),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(_SelectionZoomPainter oldDelegate) {
    return rect != oldDelegate.rect ||
        fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth;
  }
}

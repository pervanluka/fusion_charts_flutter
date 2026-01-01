import 'package:flutter/material.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'dart:async';

/// Internal tooltip renderer widget
/// Handles animation, positioning, and rendering
class FusionTooltipRenderer extends StatefulWidget {
  const FusionTooltipRenderer({
    super.key,
    required this.behavior,
    required this.renderData,
    required this.chartSize,
  });

  final FusionTooltipBehavior behavior;
  final TooltipRenderData? renderData;
  final Size chartSize;

  @override
  State<FusionTooltipRenderer> createState() => _FusionTooltipRendererState();
}

class _FusionTooltipRendererState extends State<FusionTooltipRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.behavior.animationDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    if (widget.renderData != null) {
      _showTooltip();
    }
  }

  @override
  void didUpdateWidget(FusionTooltipRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.renderData != oldWidget.renderData) {
      if (widget.renderData != null) {
        _showTooltip();
      } else {
        _hideTooltip();
      }
    }
  }

  void _showTooltip() {
    _hideTimer?.cancel();
    _animationController.forward();

    // Auto-hide based on dismiss strategy
    if (widget.behavior.dismissStrategy != FusionDismissStrategy.never) {
      _hideTimer = Timer(widget.behavior.duration, () {
        if (mounted) {
          _hideTooltip();
        }
      });
    }
  }

  void _hideTooltip() {
    _animationController.reverse();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.renderData == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(opacity: _fadeAnimation, child: _buildTooltip(context));
  }

  Widget _buildTooltip(BuildContext context) {
    final data = widget.renderData!;

    // Use custom builder if provided
    if (widget.behavior.builder != null) {
      return _positionTooltip(
        widget.behavior.builder!(context, data.point, data.seriesName, data.seriesColor),
        data.screenPosition,
      );
    }

    // Default tooltip
    return _positionTooltip(_buildDefaultTooltip(data), data.screenPosition);
  }

  Widget _positionTooltip(Widget tooltip, Offset position) {
    // Calculate optimal position (above or below point)
    final chartHeight = widget.chartSize.height;
    final shouldShowBelow = position.dy < chartHeight * 0.3;

    return Positioned(
      left: position.dx - 60, // Center horizontally (approx)
      top: shouldShowBelow ? position.dy + 15 : null,
      bottom: shouldShowBelow ? null : chartHeight - position.dy + 15,
      child: IgnorePointer(child: tooltip),
    );
  }

  Widget _buildDefaultTooltip(TooltipRenderData data) {
    final backgroundColor = widget.behavior.color ?? Colors.black;
    final textColor = _getContrastColor(backgroundColor);

    String content;
    if (widget.behavior.format != null) {
      content = widget.behavior.format!(data.point, data.seriesName);
    } else {
      final value = data.point.y.toStringAsFixed(widget.behavior.decimalPlaces);
      content = '${data.seriesName}\n$value';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: widget.behavior.opacity),
            borderRadius: BorderRadius.circular(4),
            border: widget.behavior.borderWidth > 0
                ? Border.all(
                    color: widget.behavior.borderColor ?? Colors.white.withValues(alpha: 0.2),
                    width: widget.behavior.borderWidth,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: (widget.behavior.shadowColor ?? Colors.black).withValues(alpha: 0.3),
                blurRadius: widget.behavior.elevation * 2,
                offset: Offset(0, widget.behavior.elevation),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: _getCrossAxisAlignment(),
            children: [
              if (widget.behavior.canShowMarker)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: data.seriesColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              Text(
                content,
                style:
                    widget.behavior.textStyle ??
                    TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: _getTextAlign(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CrossAxisAlignment _getCrossAxisAlignment() {
    switch (widget.behavior.textAlignment) {
      case ChartAlignment.near:
        return CrossAxisAlignment.start;
      case ChartAlignment.far:
        return CrossAxisAlignment.end;
      case ChartAlignment.center:
        return CrossAxisAlignment.center;
    }
  }

  TextAlign _getTextAlign() {
    switch (widget.behavior.textAlignment) {
      case ChartAlignment.near:
        return TextAlign.left;
      case ChartAlignment.far:
        return TextAlign.right;
      case ChartAlignment.center:
        return TextAlign.center;
    }
  }

  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

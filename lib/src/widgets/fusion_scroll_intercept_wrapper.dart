import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils/fusion_desktop_helper.dart';

/// A wrapper widget that intercepts scroll events when modifier keys are pressed.
///
/// This prevents the page from scrolling when the user is trying to zoom
/// the chart using Ctrl/Cmd + scroll on desktop/web.
class FusionScrollInterceptWrapper extends StatelessWidget {
  const FusionScrollInterceptWrapper({
    required this.child,
    required this.chartArea,
    required this.enableZoom,
    required this.requireModifier,
    required this.onScrollZoom,
    super.key,
  });

  /// The chart widget to wrap.
  final Widget child;

  /// The chart area rect (used to check if pointer is over chart).
  final Rect chartArea;

  /// Whether zoom is enabled.
  final bool enableZoom;

  /// Whether modifier key is required for wheel zoom.
  final bool requireModifier;

  /// Callback when scroll zoom should occur.
  final void Function(PointerScrollEvent event) onScrollZoom;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (!enableZoom) return;
        if (event is! PointerScrollEvent) return;

        // Check if pointer is within chart area
        if (!chartArea.contains(event.localPosition)) return;

        // Check for modifier key if required
        if (requireModifier) {
          final hasModifier = FusionDesktopHelper.isControlPressed ||
              FusionDesktopHelper.isMetaPressed;
          if (!hasModifier) return;
        }

        // Consume the event by resolving the pointer signal
        // This prevents the scroll from propagating to parent scrollables
        GestureBinding.instance.pointerSignalResolver.register(
          event,
          (event) {
            if (event is PointerScrollEvent) {
              onScrollZoom(event);
            }
          },
        );
      },
      child: child,
    );
  }
}

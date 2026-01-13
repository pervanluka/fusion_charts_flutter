import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// Helper class for detecting desktop environment and modifier keys.
///
/// Used for desktop-only features like selection zoom (Shift+drag).
class FusionDesktopHelper {
  FusionDesktopHelper._();

  /// Returns true if the current platform supports selection zoom.
  ///
  /// Selection zoom is available on:
  /// - Web (all platforms)
  /// - Desktop (macOS, Windows, Linux)
  ///
  /// NOT available on:
  /// - Mobile (iOS, Android) - pinch zoom is superior
  static bool get supportsSelectionZoom {
    if (kIsWeb) return true;

    // Check for desktop platforms
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Returns true if the Shift key is currently pressed.
  static bool get isShiftPressed {
    return HardwareKeyboard.instance.isShiftPressed;
  }

  /// Returns true if the Control key is currently pressed.
  static bool get isControlPressed {
    return HardwareKeyboard.instance.isControlPressed;
  }

  /// Returns true if the Meta key (Cmd on Mac, Win on Windows) is pressed.
  static bool get isMetaPressed {
    return HardwareKeyboard.instance.isMetaPressed;
  }

  /// Returns true if the Alt key is currently pressed.
  static bool get isAltPressed {
    return HardwareKeyboard.instance.isAltPressed;
  }

  /// Returns true if the given pointer event is from a mouse device.
  static bool isMouseEvent(PointerEvent event) {
    return event.kind == PointerDeviceKind.mouse;
  }

  /// Returns true if the given pointer event is from a touch device.
  static bool isTouchEvent(PointerEvent event) {
    return event.kind == PointerDeviceKind.touch;
  }

  /// Returns true if the given pointer event is from a stylus.
  static bool isStylusEvent(PointerEvent event) {
    return event.kind == PointerDeviceKind.stylus || event.kind == PointerDeviceKind.invertedStylus;
  }

  /// Returns true if selection zoom should be activated for the given event.
  ///
  /// Selection zoom activates when:
  /// 1. Platform supports selection zoom (desktop/web)
  /// 2. Event is from a mouse (not touch)
  /// 3. Shift key is held
  static bool shouldStartSelectionZoom(PointerEvent event) {
    if (!supportsSelectionZoom) return false;
    if (!isMouseEvent(event)) return false;
    if (!isShiftPressed) return false;
    return true;
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/utils/fusion_desktop_helper.dart';

void main() {
  // Initialize the test binding to enable HardwareKeyboard access
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FusionDesktopHelper', () {
    // =========================================================================
    // PLATFORM DETECTION
    // =========================================================================

    group('supportsSelectionZoom', () {
      test('returns a boolean value', () {
        // supportsSelectionZoom should always return a boolean
        expect(FusionDesktopHelper.supportsSelectionZoom, isA<bool>());
      });

      test('getter is consistent across multiple calls', () {
        // The value should be consistent since platform doesn't change at runtime
        final firstCall = FusionDesktopHelper.supportsSelectionZoom;
        final secondCall = FusionDesktopHelper.supportsSelectionZoom;
        final thirdCall = FusionDesktopHelper.supportsSelectionZoom;

        expect(firstCall, equals(secondCall));
        expect(secondCall, equals(thirdCall));
      });

      // Note: We cannot directly test platform-specific behavior since kIsWeb
      // is a compile-time constant and defaultTargetPlatform cannot be reliably
      // overridden in all Flutter test environments. The implementation is:
      // - Returns true on Web (all platforms)
      // - Returns true on macOS, Windows, Linux
      // - Returns false on iOS, Android
    });

    // =========================================================================
    // MODIFIER KEY STATES
    // =========================================================================

    group('isShiftPressed', () {
      test('returns a boolean value', () {
        // In a test environment, no physical keys are pressed
        expect(FusionDesktopHelper.isShiftPressed, isA<bool>());
      });

      test('returns false when no keys are pressed (test environment)', () {
        // In test environment, HardwareKeyboard should report no keys pressed
        expect(FusionDesktopHelper.isShiftPressed, isFalse);
      });
    });

    group('isControlPressed', () {
      test('returns a boolean value', () {
        expect(FusionDesktopHelper.isControlPressed, isA<bool>());
      });

      test('returns false when no keys are pressed (test environment)', () {
        expect(FusionDesktopHelper.isControlPressed, isFalse);
      });
    });

    group('isMetaPressed', () {
      test('returns a boolean value', () {
        expect(FusionDesktopHelper.isMetaPressed, isA<bool>());
      });

      test('returns false when no keys are pressed (test environment)', () {
        expect(FusionDesktopHelper.isMetaPressed, isFalse);
      });
    });

    group('isAltPressed', () {
      test('returns a boolean value', () {
        expect(FusionDesktopHelper.isAltPressed, isA<bool>());
      });

      test('returns false when no keys are pressed (test environment)', () {
        expect(FusionDesktopHelper.isAltPressed, isFalse);
      });
    });

    // =========================================================================
    // POINTER EVENT TYPE DETECTION - isMouseEvent
    // =========================================================================

    group('isMouseEvent', () {
      test('returns true for mouse pointer events', () {
        final mouseEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isMouseEvent(mouseEvent), isTrue);
      });

      test('returns false for touch pointer events', () {
        final touchEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isMouseEvent(touchEvent), isFalse);
      });

      test('returns false for stylus pointer events', () {
        final stylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        expect(FusionDesktopHelper.isMouseEvent(stylusEvent), isFalse);
      });

      test('returns false for inverted stylus pointer events', () {
        final invertedStylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.invertedStylus,
        );

        expect(FusionDesktopHelper.isMouseEvent(invertedStylusEvent), isFalse);
      });

      test('returns false for trackpad pointer events', () {
        // PointerDownEvent cannot use trackpad kind (Flutter assertion).
        // Use PointerHoverEvent instead which is the typical trackpad event.
        final trackpadEvent = PointerHoverEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.trackpad,
        );

        expect(FusionDesktopHelper.isMouseEvent(trackpadEvent), isFalse);
      });

      test('returns false for unknown pointer events', () {
        final unknownEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.unknown,
        );

        expect(FusionDesktopHelper.isMouseEvent(unknownEvent), isFalse);
      });

      test('works with different pointer event types - PointerMoveEvent', () {
        final mouseMoveEvent = PointerMoveEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isMouseEvent(mouseMoveEvent), isTrue);
      });

      test('works with different pointer event types - PointerUpEvent', () {
        final mouseUpEvent = PointerUpEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isMouseEvent(mouseUpEvent), isTrue);
      });

      test('works with different pointer event types - PointerHoverEvent', () {
        final mouseHoverEvent = PointerHoverEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isMouseEvent(mouseHoverEvent), isTrue);
      });

      test('works with PointerCancelEvent', () {
        final mouseCancelEvent = PointerCancelEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isMouseEvent(mouseCancelEvent), isTrue);
      });

      test('works with PointerScrollEvent', () {
        final mouseScrollEvent = PointerScrollEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
          scrollDelta: const Offset(0, -10),
        );

        expect(FusionDesktopHelper.isMouseEvent(mouseScrollEvent), isTrue);
      });
    });

    // =========================================================================
    // POINTER EVENT TYPE DETECTION - isTouchEvent
    // =========================================================================

    group('isTouchEvent', () {
      test('returns true for touch pointer events', () {
        final touchEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isTouchEvent(touchEvent), isTrue);
      });

      test('returns false for mouse pointer events', () {
        final mouseEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isTouchEvent(mouseEvent), isFalse);
      });

      test('returns false for stylus pointer events', () {
        final stylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        expect(FusionDesktopHelper.isTouchEvent(stylusEvent), isFalse);
      });

      test('returns false for inverted stylus pointer events', () {
        final invertedStylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.invertedStylus,
        );

        expect(FusionDesktopHelper.isTouchEvent(invertedStylusEvent), isFalse);
      });

      test('returns false for trackpad pointer events', () {
        // PointerDownEvent cannot use trackpad kind (Flutter assertion).
        // Use PointerHoverEvent instead which is the typical trackpad event.
        final trackpadEvent = PointerHoverEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.trackpad,
        );

        expect(FusionDesktopHelper.isTouchEvent(trackpadEvent), isFalse);
      });

      test('returns false for unknown pointer events', () {
        final unknownEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.unknown,
        );

        expect(FusionDesktopHelper.isTouchEvent(unknownEvent), isFalse);
      });

      test('works with different pointer event types - PointerMoveEvent', () {
        final touchMoveEvent = PointerMoveEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isTouchEvent(touchMoveEvent), isTrue);
      });

      test('works with different pointer event types - PointerUpEvent', () {
        final touchUpEvent = PointerUpEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isTouchEvent(touchUpEvent), isTrue);
      });

      test('works with PointerCancelEvent', () {
        final touchCancelEvent = PointerCancelEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isTouchEvent(touchCancelEvent), isTrue);
      });
    });

    // =========================================================================
    // POINTER EVENT TYPE DETECTION - isStylusEvent
    // =========================================================================

    group('isStylusEvent', () {
      test('returns true for stylus pointer events', () {
        final stylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        expect(FusionDesktopHelper.isStylusEvent(stylusEvent), isTrue);
      });

      test('returns true for inverted stylus pointer events', () {
        final invertedStylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.invertedStylus,
        );

        expect(FusionDesktopHelper.isStylusEvent(invertedStylusEvent), isTrue);
      });

      test('returns false for mouse pointer events', () {
        final mouseEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isStylusEvent(mouseEvent), isFalse);
      });

      test('returns false for touch pointer events', () {
        final touchEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isStylusEvent(touchEvent), isFalse);
      });

      test('returns false for trackpad pointer events', () {
        // PointerDownEvent cannot use trackpad kind (Flutter assertion).
        // Use PointerHoverEvent instead which is the typical trackpad event.
        final trackpadEvent = PointerHoverEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.trackpad,
        );

        expect(FusionDesktopHelper.isStylusEvent(trackpadEvent), isFalse);
      });

      test('returns false for unknown pointer events', () {
        final unknownEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.unknown,
        );

        expect(FusionDesktopHelper.isStylusEvent(unknownEvent), isFalse);
      });

      test('works with different pointer event types - PointerMoveEvent', () {
        final stylusMoveEvent = PointerMoveEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        expect(FusionDesktopHelper.isStylusEvent(stylusMoveEvent), isTrue);
      });

      test('works with inverted stylus PointerMoveEvent', () {
        final invertedStylusMoveEvent = PointerMoveEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.invertedStylus,
        );

        expect(
          FusionDesktopHelper.isStylusEvent(invertedStylusMoveEvent),
          isTrue,
        );
      });

      test('works with different pointer event types - PointerUpEvent', () {
        final stylusUpEvent = PointerUpEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        expect(FusionDesktopHelper.isStylusEvent(stylusUpEvent), isTrue);
      });

      test('works with PointerCancelEvent', () {
        final stylusCancelEvent = PointerCancelEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        expect(FusionDesktopHelper.isStylusEvent(stylusCancelEvent), isTrue);
      });
    });

    // =========================================================================
    // SELECTION ZOOM ACTIVATION - shouldStartSelectionZoom
    // =========================================================================

    group('shouldStartSelectionZoom', () {
      test('returns false for touch events regardless of platform', () {
        final touchEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        // Touch events should never start selection zoom
        // (they use pinch-to-zoom instead)
        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(touchEvent),
          isFalse,
        );
      });

      test('returns false for stylus events', () {
        final stylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(stylusEvent),
          isFalse,
        );
      });

      test('returns false for inverted stylus events', () {
        final invertedStylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.invertedStylus,
        );

        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(invertedStylusEvent),
          isFalse,
        );
      });

      test('returns false for trackpad events', () {
        // PointerDownEvent cannot use trackpad kind (Flutter assertion).
        // Use PointerHoverEvent instead which is the typical trackpad event.
        final trackpadEvent = PointerHoverEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.trackpad,
        );

        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(trackpadEvent),
          isFalse,
        );
      });

      test('returns false for unknown device events', () {
        final unknownEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.unknown,
        );

        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(unknownEvent),
          isFalse,
        );
      });

      test('returns false for mouse events when shift is not pressed', () {
        // In test environment, shift is not pressed
        final mouseEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        // Even with mouse on desktop, shift must be pressed
        // In test environment shift is not pressed, so this should return false
        // unless we're on a non-desktop platform
        final result = FusionDesktopHelper.shouldStartSelectionZoom(mouseEvent);

        // The result depends on both platform and shift state
        // In test env: shift is false, so result is always false
        expect(result, isFalse);
      });

      test('works with PointerMoveEvent', () {
        final mouseMoveEvent = PointerMoveEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        // Should return false since shift is not pressed
        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(mouseMoveEvent),
          isFalse,
        );
      });

      test('behavior is consistent across multiple calls', () {
        final mouseEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        final result1 = FusionDesktopHelper.shouldStartSelectionZoom(
          mouseEvent,
        );
        final result2 = FusionDesktopHelper.shouldStartSelectionZoom(
          mouseEvent,
        );
        final result3 = FusionDesktopHelper.shouldStartSelectionZoom(
          mouseEvent,
        );

        expect(result1, equals(result2));
        expect(result2, equals(result3));
      });
    });

    // =========================================================================
    // COMPREHENSIVE DEVICE KIND TESTS
    // =========================================================================

    group('Comprehensive device kind handling', () {
      // Note: PointerDownEvent cannot be created with trackpad kind (Flutter assertion).
      // We use PointerHoverEvent for trackpad tests instead.
      PointerEvent createEventForKind(PointerDeviceKind kind) {
        if (kind == PointerDeviceKind.trackpad) {
          return PointerHoverEvent(
            position: const Offset(100, 100),
            kind: kind,
          );
        }
        return PointerDownEvent(position: const Offset(100, 100), kind: kind);
      }

      const allDeviceKinds = PointerDeviceKind.values;

      test('all device kinds are handled by isMouseEvent', () {
        for (final kind in allDeviceKinds) {
          final event = createEventForKind(kind);

          final result = FusionDesktopHelper.isMouseEvent(event);
          expect(result, isA<bool>());

          // Only mouse should return true
          expect(result, equals(kind == PointerDeviceKind.mouse));
        }
      });

      test('all device kinds are handled by isTouchEvent', () {
        for (final kind in allDeviceKinds) {
          final event = createEventForKind(kind);

          final result = FusionDesktopHelper.isTouchEvent(event);
          expect(result, isA<bool>());

          // Only touch should return true
          expect(result, equals(kind == PointerDeviceKind.touch));
        }
      });

      test('all device kinds are handled by isStylusEvent', () {
        for (final kind in allDeviceKinds) {
          final event = createEventForKind(kind);

          final result = FusionDesktopHelper.isStylusEvent(event);
          expect(result, isA<bool>());

          // Both stylus and invertedStylus should return true
          expect(
            result,
            equals(
              kind == PointerDeviceKind.stylus ||
                  kind == PointerDeviceKind.invertedStylus,
            ),
          );
        }
      });

      test('device type detectors are mutually exclusive for primary types', () {
        // Test that a single event is detected by at most one primary detector
        // (mouse, touch, stylus are primary; trackpad and unknown are special)
        for (final kind in allDeviceKinds) {
          final event = createEventForKind(kind);

          final isMouse = FusionDesktopHelper.isMouseEvent(event);
          final isTouch = FusionDesktopHelper.isTouchEvent(event);
          final isStylus = FusionDesktopHelper.isStylusEvent(event);

          // Count how many detectors return true
          final trueCount = [
            isMouse,
            isTouch,
            isStylus,
          ].where((v) => v == true).length;

          // Should be at most 1 (or 0 for trackpad/unknown)
          expect(
            trueCount,
            lessThanOrEqualTo(1),
            reason: 'Device kind $kind should match at most one detector',
          );
        }
      });
    });

    // =========================================================================
    // POINTER EVENTS WITH DIFFERENT PROPERTIES
    // =========================================================================

    group('Pointer events with various properties', () {
      test('isMouseEvent handles events with buttons', () {
        final mouseWithButtons = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
          buttons: kPrimaryButton,
        );

        expect(FusionDesktopHelper.isMouseEvent(mouseWithButtons), isTrue);
      });

      test('isMouseEvent handles events with secondary button', () {
        final mouseWithSecondaryButton = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
          buttons: kSecondaryButton,
        );

        expect(
          FusionDesktopHelper.isMouseEvent(mouseWithSecondaryButton),
          isTrue,
        );
      });

      test('isMouseEvent handles events with multiple buttons', () {
        final mouseWithMultipleButtons = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
          buttons: kPrimaryButton | kSecondaryButton,
        );

        expect(
          FusionDesktopHelper.isMouseEvent(mouseWithMultipleButtons),
          isTrue,
        );
      });

      test('isTouchEvent handles events with pressure', () {
        final touchWithPressure = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
          pressure: 0.8,
        );

        expect(FusionDesktopHelper.isTouchEvent(touchWithPressure), isTrue);
      });

      test('isStylusEvent handles events with tilt', () {
        final stylusWithTilt = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
          tilt: 0.5,
        );

        expect(FusionDesktopHelper.isStylusEvent(stylusWithTilt), isTrue);
      });

      test('isStylusEvent handles events with pressure and tilt', () {
        final stylusWithPressureAndTilt = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
          pressure: 0.5,
          tilt: 0.3,
        );

        expect(
          FusionDesktopHelper.isStylusEvent(stylusWithPressureAndTilt),
          isTrue,
        );
      });

      test('handles events at origin position', () {
        final eventAtOrigin = PointerDownEvent(
          position: Offset.zero,
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isMouseEvent(eventAtOrigin), isTrue);
      });

      test('handles events at negative coordinates', () {
        final eventAtNegative = PointerDownEvent(
          position: const Offset(-100, -100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isTouchEvent(eventAtNegative), isTrue);
      });

      test('handles events at large coordinates', () {
        final eventAtLarge = PointerDownEvent(
          position: const Offset(10000, 10000),
          kind: PointerDeviceKind.stylus,
        );

        expect(FusionDesktopHelper.isStylusEvent(eventAtLarge), isTrue);
      });

      test('handles events with different pointer IDs', () {
        for (int pointerId = 0; pointerId < 10; pointerId++) {
          final event = PointerDownEvent(
            position: const Offset(100, 100),
            kind: PointerDeviceKind.touch,
            pointer: pointerId,
          );

          expect(FusionDesktopHelper.isTouchEvent(event), isTrue);
        }
      });
    });

    // =========================================================================
    // CLASS DESIGN TESTS
    // =========================================================================

    group('Class design', () {
      test('static methods are accessible without instance', () {
        // FusionDesktopHelper uses a private constructor FusionDesktopHelper._()
        // This test verifies that the class is designed as a utility class
        // with only static members, which is the correct pattern for such helpers.

        // We can verify this by checking that all public APIs are static
        // (if they weren't static, we'd need an instance to call them)

        // These should all be callable without an instance
        FusionDesktopHelper.supportsSelectionZoom;
        FusionDesktopHelper.isShiftPressed;
        FusionDesktopHelper.isControlPressed;
        FusionDesktopHelper.isMetaPressed;
        FusionDesktopHelper.isAltPressed;

        final dummyEvent = PointerDownEvent(
          position: Offset.zero,
          kind: PointerDeviceKind.mouse,
        );
        FusionDesktopHelper.isMouseEvent(dummyEvent);
        FusionDesktopHelper.isTouchEvent(dummyEvent);
        FusionDesktopHelper.isStylusEvent(dummyEvent);
        FusionDesktopHelper.shouldStartSelectionZoom(dummyEvent);

        // If we reach here, all static methods are accessible
        expect(true, isTrue);
      });
    });

    // =========================================================================
    // EDGE CASES
    // =========================================================================

    group('Edge cases', () {
      test('handles PointerAddedEvent', () {
        final addedEvent = PointerAddedEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        expect(FusionDesktopHelper.isMouseEvent(addedEvent), isTrue);
        expect(FusionDesktopHelper.isTouchEvent(addedEvent), isFalse);
        expect(FusionDesktopHelper.isStylusEvent(addedEvent), isFalse);
      });

      test('handles PointerRemovedEvent', () {
        final removedEvent = PointerRemovedEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(FusionDesktopHelper.isMouseEvent(removedEvent), isFalse);
        expect(FusionDesktopHelper.isTouchEvent(removedEvent), isTrue);
        expect(FusionDesktopHelper.isStylusEvent(removedEvent), isFalse);
      });

      test('handles PointerPanZoomStartEvent', () {
        // PointerPanZoomStartEvent defaults to trackpad kind
        final panZoomEvent = PointerPanZoomStartEvent(
          position: const Offset(100, 100),
        );

        expect(FusionDesktopHelper.isMouseEvent(panZoomEvent), isFalse);
        expect(FusionDesktopHelper.isTouchEvent(panZoomEvent), isFalse);
        expect(FusionDesktopHelper.isStylusEvent(panZoomEvent), isFalse);
      });

      test('handles PointerPanZoomUpdateEvent', () {
        // PointerPanZoomUpdateEvent defaults to trackpad kind
        final panZoomUpdateEvent = PointerPanZoomUpdateEvent(
          position: const Offset(100, 100),
        );

        expect(FusionDesktopHelper.isMouseEvent(panZoomUpdateEvent), isFalse);
        expect(FusionDesktopHelper.isTouchEvent(panZoomUpdateEvent), isFalse);
        expect(FusionDesktopHelper.isStylusEvent(panZoomUpdateEvent), isFalse);
      });

      test('handles PointerPanZoomEndEvent', () {
        // PointerPanZoomEndEvent defaults to trackpad kind
        final panZoomEndEvent = PointerPanZoomEndEvent(
          position: const Offset(100, 100),
        );

        expect(FusionDesktopHelper.isMouseEvent(panZoomEndEvent), isFalse);
        expect(FusionDesktopHelper.isTouchEvent(panZoomEndEvent), isFalse);
        expect(FusionDesktopHelper.isStylusEvent(panZoomEndEvent), isFalse);
      });

      test('handles PointerSignalEvent (scroll)', () {
        final scrollEvent = PointerScrollEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
          scrollDelta: const Offset(0, -100),
        );

        expect(FusionDesktopHelper.isMouseEvent(scrollEvent), isTrue);
        expect(FusionDesktopHelper.isTouchEvent(scrollEvent), isFalse);
        expect(FusionDesktopHelper.isStylusEvent(scrollEvent), isFalse);
      });

      test('shouldStartSelectionZoom with PointerMoveEvent (touch)', () {
        final moveEvent = PointerMoveEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(moveEvent),
          isFalse,
        );
      });

      test('shouldStartSelectionZoom with PointerHoverEvent', () {
        final hoverEvent = PointerHoverEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.mouse,
        );

        // Should be false since shift is not pressed in test environment
        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(hoverEvent),
          isFalse,
        );
      });
    });

    // =========================================================================
    // MULTIPLE MODIFIER KEYS STATE
    // =========================================================================

    group('Multiple modifier keys state', () {
      test('all modifier keys return false in test environment', () {
        // In a standard test environment, no physical keys are pressed
        expect(FusionDesktopHelper.isShiftPressed, isFalse);
        expect(FusionDesktopHelper.isControlPressed, isFalse);
        expect(FusionDesktopHelper.isMetaPressed, isFalse);
        expect(FusionDesktopHelper.isAltPressed, isFalse);
      });

      test('modifier key getters are independent', () {
        // Each getter should be callable independently
        final shift = FusionDesktopHelper.isShiftPressed;
        final control = FusionDesktopHelper.isControlPressed;
        final meta = FusionDesktopHelper.isMetaPressed;
        final alt = FusionDesktopHelper.isAltPressed;

        // All should be booleans
        expect(shift, isA<bool>());
        expect(control, isA<bool>());
        expect(meta, isA<bool>());
        expect(alt, isA<bool>());
      });
    });

    // =========================================================================
    // INTEGRATION-STYLE TESTS
    // =========================================================================

    group('Integration scenarios', () {
      test('shouldStartSelectionZoom logic flow for non-mouse events', () {
        // Test the complete logic flow:
        // 1. Check platform support
        // 2. Check if mouse event
        // 3. Check if shift is pressed

        // Non-mouse events should fail at step 2
        final touchEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.touch,
        );

        final stylusEvent = PointerDownEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        );

        // PointerDownEvent cannot use trackpad kind (Flutter assertion).
        // Use PointerHoverEvent instead which is the typical trackpad event.
        final trackpadEvent = PointerHoverEvent(
          position: const Offset(100, 100),
          kind: PointerDeviceKind.trackpad,
        );

        // All non-mouse events should return false
        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(touchEvent),
          isFalse,
        );
        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(stylusEvent),
          isFalse,
        );
        expect(
          FusionDesktopHelper.shouldStartSelectionZoom(trackpadEvent),
          isFalse,
        );
      });

      test('device kind classification is complete', () {
        // Helper to create event based on kind
        // (PointerDownEvent cannot use trackpad kind - Flutter assertion)
        PointerEvent createEventForKind(PointerDeviceKind kind) {
          if (kind == PointerDeviceKind.trackpad) {
            return PointerHoverEvent(
              position: const Offset(100, 100),
              kind: kind,
            );
          }
          return PointerDownEvent(position: const Offset(100, 100), kind: kind);
        }

        // Every device kind should be classifiable
        for (final kind in PointerDeviceKind.values) {
          final event = createEventForKind(kind);

          // At least one of these checks should succeed without throwing
          final isMouse = FusionDesktopHelper.isMouseEvent(event);
          final isTouch = FusionDesktopHelper.isTouchEvent(event);
          final isStylus = FusionDesktopHelper.isStylusEvent(event);

          // Verify the logic is consistent with expected values
          if (kind == PointerDeviceKind.mouse) {
            expect(isMouse, isTrue);
            expect(isTouch, isFalse);
            expect(isStylus, isFalse);
          } else if (kind == PointerDeviceKind.touch) {
            expect(isMouse, isFalse);
            expect(isTouch, isTrue);
            expect(isStylus, isFalse);
          } else if (kind == PointerDeviceKind.stylus ||
              kind == PointerDeviceKind.invertedStylus) {
            expect(isMouse, isFalse);
            expect(isTouch, isFalse);
            expect(isStylus, isTrue);
          } else {
            // trackpad, unknown
            expect(isMouse, isFalse);
            expect(isTouch, isFalse);
            expect(isStylus, isFalse);
          }
        }
      });
    });
  });
}

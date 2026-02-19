import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/charts/base/fusion_interactive_state_base.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';

// =============================================================================
// TEST IMPLEMENTATIONS
// =============================================================================

/// Concrete implementation of FusionInteractiveStateBase for testing.
///
/// Provides a minimal implementation that tracks method calls and allows
/// controlled testing of the abstract class contract.
class TestInteractiveState extends FusionInteractiveStateBase {
  TestInteractiveState({FusionCoordinateSystem? coordSystem})
    : _coordSystem =
          coordSystem ??
          FusionCoordinateSystem(
            chartArea: const Rect.fromLTWH(0, 0, 400, 300),
            dataXMin: 0,
            dataXMax: 100,
            dataYMin: 0,
            dataYMax: 100,
          );

  FusionCoordinateSystem _coordSystem;

  // Track method calls for verification
  int initializeCallCount = 0;
  int updateCoordinateSystemCallCount = 0;
  int handlePointerDownCallCount = 0;
  int handlePointerMoveCallCount = 0;
  int handlePointerUpCallCount = 0;
  int handlePointerCancelCallCount = 0;
  int handlePointerHoverCallCount = 0;
  int handlePointerExitCallCount = 0;
  int handlePointerSignalCallCount = 0;
  int zoomInCallCount = 0;
  int zoomOutCallCount = 0;
  int resetCallCount = 0;

  // Last received events
  PointerDownEvent? lastPointerDownEvent;
  PointerMoveEvent? lastPointerMoveEvent;
  PointerUpEvent? lastPointerUpEvent;
  PointerCancelEvent? lastPointerCancelEvent;
  PointerHoverEvent? lastPointerHoverEvent;
  PointerExitEvent? lastPointerExitEvent;
  PointerSignalEvent? lastPointerSignalEvent;
  FusionCoordinateSystem? lastUpdatedCoordSystem;

  // Controllable state
  FusionTooltipDataBase? _tooltipData;
  double _tooltipOpacity = 0.0;
  Offset? _crosshairPosition;
  FusionDataPoint? _crosshairPoint;
  bool _isInteracting = false;
  bool _isPointerDown = false;
  bool _isAnimatingZoom = false;
  double _zoomAnimationProgress = 1.0;
  bool _isSelectionZoomActive = false;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  // Setters for test control
  set tooltipData(FusionTooltipDataBase? value) {
    _tooltipData = value;
    notifyListeners();
  }

  set tooltipOpacity(double value) {
    _tooltipOpacity = value;
    notifyListeners();
  }

  set crosshairPosition(Offset? value) {
    _crosshairPosition = value;
    notifyListeners();
  }

  set crosshairPoint(FusionDataPoint? value) {
    _crosshairPoint = value;
    notifyListeners();
  }

  set isInteracting(bool value) {
    _isInteracting = value;
    notifyListeners();
  }

  set isPointerDown(bool value) {
    _isPointerDown = value;
    notifyListeners();
  }

  void setAnimatingZoom(bool value) {
    _isAnimatingZoom = value;
    notifyListeners();
  }

  void setZoomAnimationProgress(double value) {
    _zoomAnimationProgress = value;
    notifyListeners();
  }

  void setSelectionZoomActive(bool value) {
    _isSelectionZoomActive = value;
    notifyListeners();
  }

  void setSelectionStart(Offset? value) {
    _selectionStart = value;
    notifyListeners();
  }

  void setSelectionCurrent(Offset? value) {
    _selectionCurrent = value;
    notifyListeners();
  }

  @override
  FusionCoordinateSystem get coordSystem => _coordSystem;

  @override
  FusionTooltipDataBase? get tooltipData => _tooltipData;

  @override
  double get tooltipOpacity => _tooltipOpacity;

  @override
  Offset? get crosshairPosition => _crosshairPosition;

  @override
  FusionDataPoint? get crosshairPoint => _crosshairPoint;

  @override
  bool get isInteracting => _isInteracting;

  @override
  bool get isPointerDown => _isPointerDown;

  @override
  bool get isAnimatingZoom => _isAnimatingZoom;

  @override
  double get zoomAnimationProgress => _zoomAnimationProgress;

  @override
  bool get isSelectionZoomActive => _isSelectionZoomActive;

  @override
  Offset? get selectionStart => _selectionStart;

  @override
  Offset? get selectionCurrent => _selectionCurrent;

  @override
  void initialize() {
    initializeCallCount++;
  }

  @override
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {
    updateCoordinateSystemCallCount++;
    lastUpdatedCoordSystem = newCoordSystem;
    _coordSystem = newCoordSystem;
  }

  @override
  void handlePointerDown(PointerDownEvent event) {
    handlePointerDownCallCount++;
    lastPointerDownEvent = event;
  }

  @override
  void handlePointerMove(PointerMoveEvent event) {
    handlePointerMoveCallCount++;
    lastPointerMoveEvent = event;
  }

  @override
  void handlePointerUp(PointerUpEvent event) {
    handlePointerUpCallCount++;
    lastPointerUpEvent = event;
  }

  @override
  void handlePointerCancel(PointerCancelEvent event) {
    handlePointerCancelCallCount++;
    lastPointerCancelEvent = event;
  }

  @override
  void handlePointerHover(PointerHoverEvent event) {
    handlePointerHoverCallCount++;
    lastPointerHoverEvent = event;
  }

  @override
  void handlePointerExit(PointerExitEvent event) {
    handlePointerExitCallCount++;
    lastPointerExitEvent = event;
  }

  @override
  void handlePointerSignal(PointerSignalEvent event) {
    handlePointerSignalCallCount++;
    lastPointerSignalEvent = event;
  }

  @override
  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    return {};
  }

  @override
  void zoomIn() {
    zoomInCallCount++;
  }

  @override
  void zoomOut() {
    zoomOutCallCount++;
  }

  @override
  void reset() {
    resetCallCount++;
  }

  // ignore: unreachable_from_main
  void resetCallCounts() {
    initializeCallCount = 0;
    updateCoordinateSystemCallCount = 0;
    handlePointerDownCallCount = 0;
    handlePointerMoveCallCount = 0;
    handlePointerUpCallCount = 0;
    handlePointerCancelCallCount = 0;
    handlePointerHoverCallCount = 0;
    handlePointerExitCallCount = 0;
    handlePointerSignalCallCount = 0;
    zoomInCallCount = 0;
    zoomOutCallCount = 0;
    resetCallCount = 0;
  }
}

/// Test implementation that uses the FusionInteractiveTimersMixin.
class TestInteractiveStateWithTimers extends ChangeNotifier
    with FusionInteractiveTimersMixin {
  // Track callback invocations
  int tooltipHideCallCount = 0;
  int crosshairHideCallCount = 0;
  int debounceCallCount = 0;

  // ignore: unreachable_from_main
  void resetCallCounts() {
    tooltipHideCallCount = 0;
    crosshairHideCallCount = 0;
    debounceCallCount = 0;
  }
}

/// Simple tooltip data for testing.
class TestTooltipData extends FusionTooltipDataBase {
  const TestTooltipData(this.screenPosition);

  @override
  final Offset screenPosition;
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  // ===========================================================================
  // FusionInteractiveStateBase - CONSTRUCTION & INHERITANCE
  // ===========================================================================

  group('FusionInteractiveStateBase - Construction', () {
    test('extends ChangeNotifier', () {
      final state = TestInteractiveState();

      expect(state, isA<ChangeNotifier>());
    });

    test('can add and notify listeners', () {
      final state = TestInteractiveState();
      var notificationCount = 0;

      state.addListener(() => notificationCount++);
      state.tooltipOpacity = 0.5;

      expect(notificationCount, 1);
    });

    test('can remove listeners', () {
      final state = TestInteractiveState();
      var notificationCount = 0;
      void listener() => notificationCount++;

      state.addListener(listener);
      state.tooltipOpacity = 0.5;
      state.removeListener(listener);
      state.tooltipOpacity = 1.0;

      expect(notificationCount, 1);
    });

    test('can be disposed', () {
      final state = TestInteractiveState();
      var notificationCount = 0;

      state.addListener(() => notificationCount++);
      state.dispose();

      // After dispose, setting values should not notify (would throw in real impl)
      // We can't test this directly as dispose breaks the state
      expect(notificationCount, 0);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - COORDINATE SYSTEM
  // ===========================================================================

  group('FusionInteractiveStateBase - Coordinate System', () {
    test('provides access to coordinate system', () {
      final coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(10, 20, 300, 200),
        dataXMin: -50,
        dataXMax: 50,
        dataYMin: 0,
        dataYMax: 100,
      );
      final state = TestInteractiveState(coordSystem: coordSystem);

      expect(state.coordSystem, equals(coordSystem));
      expect(state.coordSystem.chartArea.width, 300);
      expect(state.coordSystem.dataXMin, -50);
    });

    test('updateCoordinateSystem updates the system', () {
      final state = TestInteractiveState();
      final newCoordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 500, 400),
        dataXMin: 0,
        dataXMax: 200,
        dataYMin: 0,
        dataYMax: 150,
      );

      state.updateCoordinateSystem(newCoordSystem);

      expect(state.updateCoordinateSystemCallCount, 1);
      expect(state.lastUpdatedCoordSystem, equals(newCoordSystem));
      expect(state.coordSystem, equals(newCoordSystem));
    });

    test('updateCoordinateSystem can be called multiple times', () {
      final state = TestInteractiveState();

      for (var i = 0; i < 5; i++) {
        state.updateCoordinateSystem(
          FusionCoordinateSystem(
            chartArea: Rect.fromLTWH(0, 0, 400 + i * 10, 300),
            dataXMin: 0,
            dataXMax: 100,
            dataYMin: 0,
            dataYMax: 100,
          ),
        );
      }

      expect(state.updateCoordinateSystemCallCount, 5);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - TOOLTIP STATE
  // ===========================================================================

  group('FusionInteractiveStateBase - Tooltip State', () {
    test('tooltipData defaults to null', () {
      final state = TestInteractiveState();

      expect(state.tooltipData, isNull);
    });

    test('tooltipData can be set', () {
      final state = TestInteractiveState();
      const tooltip = TestTooltipData(Offset(100, 50));

      state.tooltipData = tooltip;

      expect(state.tooltipData, equals(tooltip));
      expect(state.tooltipData!.screenPosition, const Offset(100, 50));
    });

    test('tooltipOpacity defaults to 0.0', () {
      final state = TestInteractiveState();

      expect(state.tooltipOpacity, 0.0);
    });

    test('tooltipOpacity can be set', () {
      final state = TestInteractiveState();

      state.tooltipOpacity = 0.75;

      expect(state.tooltipOpacity, 0.75);
    });

    test('tooltipOpacity notifies listeners', () {
      final state = TestInteractiveState();
      var notified = false;

      state.addListener(() => notified = true);
      state.tooltipOpacity = 1.0;

      expect(notified, isTrue);
    });

    test('setting tooltipData notifies listeners', () {
      final state = TestInteractiveState();
      var notified = false;

      state.addListener(() => notified = true);
      state.tooltipData = const TestTooltipData(Offset.zero);

      expect(notified, isTrue);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - CROSSHAIR STATE
  // ===========================================================================

  group('FusionInteractiveStateBase - Crosshair State', () {
    test('crosshairPosition defaults to null', () {
      final state = TestInteractiveState();

      expect(state.crosshairPosition, isNull);
    });

    test('crosshairPosition can be set', () {
      final state = TestInteractiveState();

      state.crosshairPosition = const Offset(200, 150);

      expect(state.crosshairPosition, const Offset(200, 150));
    });

    test('crosshairPoint defaults to null', () {
      final state = TestInteractiveState();

      expect(state.crosshairPoint, isNull);
    });

    test('crosshairPoint can be set', () {
      final state = TestInteractiveState();
      final point = FusionDataPoint(50, 75);

      state.crosshairPoint = point;

      expect(state.crosshairPoint, equals(point));
      expect(state.crosshairPoint!.x, 50);
      expect(state.crosshairPoint!.y, 75);
    });

    test('crosshairPosition notifies listeners', () {
      final state = TestInteractiveState();
      var notified = false;

      state.addListener(() => notified = true);
      state.crosshairPosition = const Offset(100, 100);

      expect(notified, isTrue);
    });

    test('crosshairPoint notifies listeners', () {
      final state = TestInteractiveState();
      var notified = false;

      state.addListener(() => notified = true);
      state.crosshairPoint = FusionDataPoint(25, 50);

      expect(notified, isTrue);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - INTERACTION STATE
  // ===========================================================================

  group('FusionInteractiveStateBase - Interaction State', () {
    test('isInteracting defaults to false', () {
      final state = TestInteractiveState();

      expect(state.isInteracting, isFalse);
    });

    test('isInteracting can be set', () {
      final state = TestInteractiveState();

      state.isInteracting = true;

      expect(state.isInteracting, isTrue);
    });

    test('isPointerDown defaults to false', () {
      final state = TestInteractiveState();

      expect(state.isPointerDown, isFalse);
    });

    test('isPointerDown can be set', () {
      final state = TestInteractiveState();

      state.isPointerDown = true;

      expect(state.isPointerDown, isTrue);
    });

    test('isAnimatingZoom defaults to false', () {
      final state = TestInteractiveState();

      expect(state.isAnimatingZoom, isFalse);
    });

    test('zoomAnimationProgress defaults to 1.0', () {
      final state = TestInteractiveState();

      expect(state.zoomAnimationProgress, 1.0);
    });

    test('isAnimatingZoom can be overridden', () {
      final state = TestInteractiveState();

      state.setAnimatingZoom(true);

      expect(state.isAnimatingZoom, isTrue);
    });

    test('zoomAnimationProgress can be overridden', () {
      final state = TestInteractiveState();

      state.setZoomAnimationProgress(0.5);

      expect(state.zoomAnimationProgress, 0.5);
    });

    test('isInteracting notifies listeners', () {
      final state = TestInteractiveState();
      var notified = false;

      state.addListener(() => notified = true);
      state.isInteracting = true;

      expect(notified, isTrue);
    });

    test('isPointerDown notifies listeners', () {
      final state = TestInteractiveState();
      var notified = false;

      state.addListener(() => notified = true);
      state.isPointerDown = true;

      expect(notified, isTrue);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - SELECTION ZOOM STATE
  // ===========================================================================

  group('FusionInteractiveStateBase - Selection Zoom State', () {
    test('isSelectionZoomActive defaults to false', () {
      final state = TestInteractiveState();

      expect(state.isSelectionZoomActive, isFalse);
    });

    test('selectionStart defaults to null', () {
      final state = TestInteractiveState();

      expect(state.selectionStart, isNull);
    });

    test('selectionCurrent defaults to null', () {
      final state = TestInteractiveState();

      expect(state.selectionCurrent, isNull);
    });

    test('selectionRect returns null when start is null', () {
      final state = TestInteractiveState();
      state.setSelectionCurrent(const Offset(200, 200));

      expect(state.selectionRect, isNull);
    });

    test('selectionRect returns null when current is null', () {
      final state = TestInteractiveState();
      state.setSelectionStart(const Offset(100, 100));

      expect(state.selectionRect, isNull);
    });

    test('selectionRect returns Rect when both start and current are set', () {
      final state = TestInteractiveState();
      state.setSelectionStart(const Offset(100, 100));
      state.setSelectionCurrent(const Offset(200, 200));

      final rect = state.selectionRect;

      expect(rect, isNotNull);
      expect(rect!.left, 100);
      expect(rect.top, 100);
      expect(rect.right, 200);
      expect(rect.bottom, 200);
    });

    test(
      'selectionRect handles reversed selection (bottom-left to top-right)',
      () {
        final state = TestInteractiveState();
        state.setSelectionStart(const Offset(200, 200));
        state.setSelectionCurrent(const Offset(100, 100));

        final rect = state.selectionRect;

        expect(rect, isNotNull);
        // Rect.fromPoints normalizes the rectangle
        expect(rect!.left, 100);
        expect(rect.top, 100);
        expect(rect.right, 200);
        expect(rect.bottom, 200);
      },
    );

    test('selectionRect handles same start and current', () {
      final state = TestInteractiveState();
      state.setSelectionStart(const Offset(150, 150));
      state.setSelectionCurrent(const Offset(150, 150));

      final rect = state.selectionRect;

      expect(rect, isNotNull);
      expect(rect!.width, 0);
      expect(rect.height, 0);
    });

    test('isSelectionZoomActive can be set', () {
      final state = TestInteractiveState();

      state.setSelectionZoomActive(true);

      expect(state.isSelectionZoomActive, isTrue);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - LIFECYCLE
  // ===========================================================================

  group('FusionInteractiveStateBase - Lifecycle', () {
    test('initialize can be called', () {
      final state = TestInteractiveState();

      state.initialize();

      expect(state.initializeCallCount, 1);
    });

    test('initialize can be called multiple times', () {
      final state = TestInteractiveState();

      state.initialize();
      state.initialize();
      state.initialize();

      expect(state.initializeCallCount, 3);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - POINTER HANDLERS
  // ===========================================================================

  group('FusionInteractiveStateBase - Pointer Handlers', () {
    test('handlePointerDown receives event', () {
      final state = TestInteractiveState();
      const event = PointerDownEvent(position: Offset(100, 100));

      state.handlePointerDown(event);

      expect(state.handlePointerDownCallCount, 1);
      expect(state.lastPointerDownEvent, equals(event));
    });

    test('handlePointerMove receives event', () {
      final state = TestInteractiveState();
      const event = PointerMoveEvent(position: Offset(150, 150));

      state.handlePointerMove(event);

      expect(state.handlePointerMoveCallCount, 1);
      expect(state.lastPointerMoveEvent, equals(event));
    });

    test('handlePointerUp receives event', () {
      final state = TestInteractiveState();
      const event = PointerUpEvent(position: Offset(200, 200));

      state.handlePointerUp(event);

      expect(state.handlePointerUpCallCount, 1);
      expect(state.lastPointerUpEvent, equals(event));
    });

    test('handlePointerCancel receives event', () {
      final state = TestInteractiveState();
      const event = PointerCancelEvent(position: Offset(50, 50));

      state.handlePointerCancel(event);

      expect(state.handlePointerCancelCallCount, 1);
      expect(state.lastPointerCancelEvent, equals(event));
    });

    test('handlePointerHover receives event', () {
      final state = TestInteractiveState();
      const event = PointerHoverEvent(position: Offset(75, 75));

      state.handlePointerHover(event);

      expect(state.handlePointerHoverCallCount, 1);
      expect(state.lastPointerHoverEvent, equals(event));
    });

    test('handlePointerExit receives event', () {
      final state = TestInteractiveState();
      const event = PointerExitEvent(position: Offset.zero);

      state.handlePointerExit(event);

      expect(state.handlePointerExitCallCount, 1);
      expect(state.lastPointerExitEvent, equals(event));
    });

    test('handlePointerSignal receives event', () {
      final state = TestInteractiveState();
      const event = PointerScrollEvent(
        position: Offset(100, 100),
        scrollDelta: Offset(0, -100),
      );

      state.handlePointerSignal(event);

      expect(state.handlePointerSignalCallCount, 1);
      expect(state.lastPointerSignalEvent, equals(event));
    });

    test('pointer events with different positions are tracked', () {
      final state = TestInteractiveState();

      state.handlePointerDown(const PointerDownEvent(position: Offset(10, 20)));
      state.handlePointerMove(const PointerMoveEvent(position: Offset(30, 40)));
      state.handlePointerUp(const PointerUpEvent(position: Offset(50, 60)));

      expect(state.lastPointerDownEvent!.position, const Offset(10, 20));
      expect(state.lastPointerMoveEvent!.position, const Offset(30, 40));
      expect(state.lastPointerUpEvent!.position, const Offset(50, 60));
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - GESTURE RECOGNIZERS
  // ===========================================================================

  group('FusionInteractiveStateBase - Gesture Recognizers', () {
    test('getGestureRecognizers returns Map', () {
      final state = TestInteractiveState();

      final recognizers = state.getGestureRecognizers();

      expect(recognizers, isA<Map<Type, GestureRecognizerFactory>>());
    });

    test('getGestureRecognizers can return empty map', () {
      final state = TestInteractiveState();

      final recognizers = state.getGestureRecognizers();

      expect(recognizers, isEmpty);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - ZOOM CONTROLS
  // ===========================================================================

  group('FusionInteractiveStateBase - Zoom Controls', () {
    test('zoomIn can be called', () {
      final state = TestInteractiveState();

      state.zoomIn();

      expect(state.zoomInCallCount, 1);
    });

    test('zoomOut can be called', () {
      final state = TestInteractiveState();

      state.zoomOut();

      expect(state.zoomOutCallCount, 1);
    });

    test('reset can be called', () {
      final state = TestInteractiveState();

      state.reset();

      expect(state.resetCallCount, 1);
    });

    test('zoom controls can be called multiple times', () {
      final state = TestInteractiveState();

      for (var i = 0; i < 3; i++) {
        state.zoomIn();
        state.zoomOut();
      }
      state.reset();

      expect(state.zoomInCallCount, 3);
      expect(state.zoomOutCallCount, 3);
      expect(state.resetCallCount, 1);
    });

    test('default zoom methods do nothing (base class)', () {
      // The base class provides no-op implementations
      // This test verifies the contract is satisfied
      final state = TestInteractiveState();

      // These should not throw
      expect(state.zoomIn, returnsNormally);
      expect(state.zoomOut, returnsNormally);
      expect(state.reset, returnsNormally);
    });
  });

  // ===========================================================================
  // FusionInteractiveTimersMixin - TIMER MANAGEMENT
  // ===========================================================================

  group('FusionInteractiveTimersMixin - Timer Management', () {
    test('all timers default to null', () {
      final state = TestInteractiveStateWithTimers();

      expect(state.tooltipShowTimer, isNull);
      expect(state.tooltipHideTimer, isNull);
      expect(state.debounceTimer, isNull);
      expect(state.crosshairHideTimer, isNull);
    });

    test('cancelAllTimers cancels and nullifies all timers', () async {
      final state = TestInteractiveStateWithTimers();

      // Set up some timers
      state.tooltipShowTimer = Timer(const Duration(seconds: 10), () {});
      state.tooltipHideTimer = Timer(const Duration(seconds: 10), () {});
      state.debounceTimer = Timer(const Duration(seconds: 10), () {});
      state.crosshairHideTimer = Timer(const Duration(seconds: 10), () {});

      expect(state.tooltipShowTimer, isNotNull);
      expect(state.tooltipHideTimer, isNotNull);
      expect(state.debounceTimer, isNotNull);
      expect(state.crosshairHideTimer, isNotNull);

      state.cancelAllTimers();

      expect(state.tooltipShowTimer, isNull);
      expect(state.tooltipHideTimer, isNull);
      expect(state.debounceTimer, isNull);
      expect(state.crosshairHideTimer, isNull);
    });

    test('cancelAllTimers handles null timers gracefully', () {
      final state = TestInteractiveStateWithTimers();

      // All timers are null, this should not throw
      expect(state.cancelAllTimers, returnsNormally);
    });

    test('cancelAllTimers handles mixed null and active timers', () {
      final state = TestInteractiveStateWithTimers();

      state.tooltipShowTimer = Timer(const Duration(seconds: 10), () {});
      // Leave others null

      expect(state.cancelAllTimers, returnsNormally);
      expect(state.tooltipShowTimer, isNull);
    });
  });

  // ===========================================================================
  // FusionInteractiveTimersMixin - TOOLTIP HIDE TIMER
  // ===========================================================================

  group('FusionInteractiveTimersMixin - Tooltip Hide Timer', () {
    test('scheduleTooltipHide creates timer', () {
      final state = TestInteractiveStateWithTimers();

      state.scheduleTooltipHide(const Duration(milliseconds: 100), () {
        state.tooltipHideCallCount++;
      });

      expect(state.tooltipHideTimer, isNotNull);

      state.cancelAllTimers();
    });

    test('scheduleTooltipHide invokes callback after duration', () async {
      final state = TestInteractiveStateWithTimers();

      state.scheduleTooltipHide(const Duration(milliseconds: 50), () {
        state.tooltipHideCallCount++;
      });

      expect(state.tooltipHideCallCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(state.tooltipHideCallCount, 1);
      expect(state.tooltipHideTimer, isNull);
    });

    test('scheduleTooltipHide cancels previous timer', () async {
      final state = TestInteractiveStateWithTimers();

      // Schedule first timer
      state.scheduleTooltipHide(const Duration(milliseconds: 50), () {
        state.tooltipHideCallCount++;
      });

      // Schedule second timer before first completes
      await Future<void>.delayed(const Duration(milliseconds: 20));
      state.scheduleTooltipHide(const Duration(milliseconds: 100), () {
        state.tooltipHideCallCount += 10;
      });

      // Wait for both durations to pass
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Only second callback should have fired
      expect(state.tooltipHideCallCount, 10);
    });

    test('scheduleTooltipHide nullifies timer after callback', () async {
      final state = TestInteractiveStateWithTimers();

      state.scheduleTooltipHide(const Duration(milliseconds: 10), () {});

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(state.tooltipHideTimer, isNull);
    });
  });

  // ===========================================================================
  // FusionInteractiveTimersMixin - CROSSHAIR HIDE TIMER
  // ===========================================================================

  group('FusionInteractiveTimersMixin - Crosshair Hide Timer', () {
    test('scheduleCrosshairHide creates timer', () {
      final state = TestInteractiveStateWithTimers();

      state.scheduleCrosshairHide(const Duration(milliseconds: 100), () {
        state.crosshairHideCallCount++;
      });

      expect(state.crosshairHideTimer, isNotNull);

      state.cancelAllTimers();
    });

    test('scheduleCrosshairHide invokes callback after duration', () async {
      final state = TestInteractiveStateWithTimers();

      state.scheduleCrosshairHide(const Duration(milliseconds: 50), () {
        state.crosshairHideCallCount++;
      });

      expect(state.crosshairHideCallCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(state.crosshairHideCallCount, 1);
      expect(state.crosshairHideTimer, isNull);
    });

    test('scheduleCrosshairHide cancels previous timer', () async {
      final state = TestInteractiveStateWithTimers();

      // Schedule first timer
      state.scheduleCrosshairHide(const Duration(milliseconds: 50), () {
        state.crosshairHideCallCount++;
      });

      // Schedule second timer before first completes
      await Future<void>.delayed(const Duration(milliseconds: 20));
      state.scheduleCrosshairHide(const Duration(milliseconds: 100), () {
        state.crosshairHideCallCount += 10;
      });

      // Wait for both durations to pass
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Only second callback should have fired
      expect(state.crosshairHideCallCount, 10);
    });

    test('scheduleCrosshairHide nullifies timer after callback', () async {
      final state = TestInteractiveStateWithTimers();

      state.scheduleCrosshairHide(const Duration(milliseconds: 10), () {});

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(state.crosshairHideTimer, isNull);
    });
  });

  // ===========================================================================
  // FusionInteractiveTimersMixin - DEBOUNCE TIMER
  // ===========================================================================

  group('FusionInteractiveTimersMixin - Debounce Timer', () {
    test('debounce creates timer', () {
      final state = TestInteractiveStateWithTimers();

      state.debounce(const Duration(milliseconds: 100), () {
        state.debounceCallCount++;
      });

      expect(state.debounceTimer, isNotNull);

      state.cancelAllTimers();
    });

    test('debounce invokes callback after duration', () async {
      final state = TestInteractiveStateWithTimers();

      state.debounce(const Duration(milliseconds: 50), () {
        state.debounceCallCount++;
      });

      expect(state.debounceCallCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(state.debounceCallCount, 1);
      expect(state.debounceTimer, isNull);
    });

    test('debounce cancels previous timer (debouncing behavior)', () async {
      final state = TestInteractiveStateWithTimers();

      // Simulate rapid calls
      for (var i = 0; i < 5; i++) {
        state.debounce(const Duration(milliseconds: 50), () {
          state.debounceCallCount++;
        });
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      // Wait for final timer to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Only the last debounced callback should have fired
      expect(state.debounceCallCount, 1);
    });

    test('debounce nullifies timer after callback', () async {
      final state = TestInteractiveStateWithTimers();

      state.debounce(const Duration(milliseconds: 10), () {});

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(state.debounceTimer, isNull);
    });

    test('multiple rapid debounce calls only trigger once', () async {
      final state = TestInteractiveStateWithTimers();
      var finalValue = 0;

      // Simulate rapid updates (like during pan/drag)
      for (var i = 1; i <= 10; i++) {
        final capturedI = i;
        state.debounce(const Duration(milliseconds: 30), () {
          finalValue = capturedI;
        });
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Only the last value should be set
      expect(finalValue, 10);
    });
  });

  // ===========================================================================
  // FusionInteractiveTimersMixin - TIMER INDEPENDENCE
  // ===========================================================================

  group('FusionInteractiveTimersMixin - Timer Independence', () {
    test('different timer types operate independently', () async {
      final state = TestInteractiveStateWithTimers();

      // Schedule all timer types
      state.scheduleTooltipHide(const Duration(milliseconds: 30), () {
        state.tooltipHideCallCount++;
      });
      state.scheduleCrosshairHide(const Duration(milliseconds: 60), () {
        state.crosshairHideCallCount++;
      });
      state.debounce(const Duration(milliseconds: 90), () {
        state.debounceCallCount++;
      });

      // Wait for tooltip hide
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(state.tooltipHideCallCount, 1);
      expect(state.crosshairHideCallCount, 0);
      expect(state.debounceCallCount, 0);

      // Wait for crosshair hide
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(state.tooltipHideCallCount, 1);
      expect(state.crosshairHideCallCount, 1);
      expect(state.debounceCallCount, 0);

      // Wait for debounce
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(state.tooltipHideCallCount, 1);
      expect(state.crosshairHideCallCount, 1);
      expect(state.debounceCallCount, 1);
    });

    test('canceling one timer does not affect others', () async {
      final state = TestInteractiveStateWithTimers();

      state.scheduleTooltipHide(const Duration(milliseconds: 50), () {
        state.tooltipHideCallCount++;
      });
      state.scheduleCrosshairHide(const Duration(milliseconds: 50), () {
        state.crosshairHideCallCount++;
      });

      // Cancel only tooltip timer
      state.tooltipHideTimer?.cancel();
      state.tooltipHideTimer = null;

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Crosshair should still fire
      expect(state.tooltipHideCallCount, 0);
      expect(state.crosshairHideCallCount, 1);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - EDGE CASES
  // ===========================================================================

  group('FusionInteractiveStateBase - Edge Cases', () {
    test('handles zero-dimension coordinate system', () {
      final state = TestInteractiveState(
        coordSystem: FusionCoordinateSystem(
          chartArea: Rect.zero,
          dataXMin: 0,
          dataXMax: 0,
          dataYMin: 0,
          dataYMax: 0,
        ),
      );

      expect(state.coordSystem.chartArea.width, 0);
      expect(state.coordSystem.chartArea.height, 0);
    });

    test('handles very large coordinate values', () {
      final state = TestInteractiveState(
        coordSystem: FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 10000, 10000),
          dataXMin: -1e10,
          dataXMax: 1e10,
          dataYMin: -1e10,
          dataYMax: 1e10,
        ),
      );

      expect(state.coordSystem.dataXMin, -1e10);
      expect(state.coordSystem.dataXMax, 1e10);
    });

    test('handles rapid state changes', () {
      final state = TestInteractiveState();
      var notificationCount = 0;

      state.addListener(() => notificationCount++);

      // Rapid state changes
      for (var i = 0; i < 100; i++) {
        state.tooltipOpacity = i / 100;
      }

      expect(notificationCount, 100);
    });

    test('pointer events with extreme coordinates', () {
      final state = TestInteractiveState();

      state.handlePointerDown(
        const PointerDownEvent(position: Offset(-1000, -1000)),
      );
      state.handlePointerMove(
        const PointerMoveEvent(position: Offset(double.maxFinite, 0)),
      );
      state.handlePointerUp(
        const PointerUpEvent(position: Offset(0, double.maxFinite)),
      );

      expect(state.handlePointerDownCallCount, 1);
      expect(state.handlePointerMoveCallCount, 1);
      expect(state.handlePointerUpCallCount, 1);
    });

    test('selection rect with negative coordinates', () {
      final state = TestInteractiveState();
      state.setSelectionStart(const Offset(-100, -100));
      state.setSelectionCurrent(const Offset(-50, -50));

      final rect = state.selectionRect;

      expect(rect, isNotNull);
      expect(rect!.left, -100);
      expect(rect.top, -100);
      expect(rect.right, -50);
      expect(rect.bottom, -50);
    });
  });

  // ===========================================================================
  // FusionInteractiveTimersMixin - EDGE CASES
  // ===========================================================================

  group('FusionInteractiveTimersMixin - Edge Cases', () {
    test('handles zero duration', () async {
      final state = TestInteractiveStateWithTimers();

      state.debounce(Duration.zero, () {
        state.debounceCallCount++;
      });

      // Even with zero duration, callback should fire after microtask
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(state.debounceCallCount, 1);
    });

    test('handles very long durations', () {
      final state = TestInteractiveStateWithTimers();

      state.scheduleTooltipHide(const Duration(days: 365), () {
        state.tooltipHideCallCount++;
      });

      expect(state.tooltipHideTimer, isNotNull);

      // Cancel immediately - don't wait
      state.cancelAllTimers();

      expect(state.tooltipHideCallCount, 0);
    });

    test('can reschedule timer immediately after cancel', () async {
      final state = TestInteractiveStateWithTimers();

      state.scheduleTooltipHide(const Duration(milliseconds: 100), () {
        state.tooltipHideCallCount++;
      });

      state.cancelAllTimers();

      state.scheduleTooltipHide(const Duration(milliseconds: 20), () {
        state.tooltipHideCallCount += 10;
      });

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(state.tooltipHideCallCount, 10);
    });

    test('callback captures correct closure variables', () async {
      final state = TestInteractiveStateWithTimers();
      var capturedValue = 0;

      for (var i = 1; i <= 3; i++) {
        final captured = i;
        state.debounce(const Duration(milliseconds: 10), () {
          capturedValue = captured;
        });
      }

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Last captured value should be used
      expect(capturedValue, 3);
    });
  });

  // ===========================================================================
  // FusionInteractiveStateBase - NOTIFICATION BEHAVIOR
  // ===========================================================================

  group('FusionInteractiveStateBase - Notification Behavior', () {
    test('multiple listeners all receive notifications', () {
      final state = TestInteractiveState();
      var listener1Count = 0;
      var listener2Count = 0;
      var listener3Count = 0;

      state.addListener(() => listener1Count++);
      state.addListener(() => listener2Count++);
      state.addListener(() => listener3Count++);

      state.tooltipOpacity = 0.5;

      expect(listener1Count, 1);
      expect(listener2Count, 1);
      expect(listener3Count, 1);
    });

    test('listeners receive notifications in order added', () {
      final state = TestInteractiveState();
      final order = <int>[];

      state.addListener(() => order.add(1));
      state.addListener(() => order.add(2));
      state.addListener(() => order.add(3));

      state.tooltipOpacity = 0.5;

      expect(order, [1, 2, 3]);
    });

    test('same listener can be added multiple times', () {
      final state = TestInteractiveState();
      var count = 0;
      void listener() => count++;

      state.addListener(listener);
      state.addListener(listener);

      state.tooltipOpacity = 0.5;

      // Both listeners are called
      expect(count, 2);
    });
  });
}

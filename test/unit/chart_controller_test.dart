import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/charts/base/fusion_interactive_state_base.dart';

/// Mock implementation of FusionInteractiveStateBase for testing.
class MockInteractiveState extends ChangeNotifier
    implements FusionInteractiveStateBase {
  int zoomInCallCount = 0;
  int zoomOutCallCount = 0;
  int resetCallCount = 0;
  bool _isInteracting = false;

  void setIsInteracting(bool value) {
    _isInteracting = value;
    notifyListeners();
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

  @override
  void initialize() {}

  @override
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {}

  // Required interface implementations
  @override
  FusionCoordinateSystem get coordSystem => FusionCoordinateSystem(
    chartArea: const Rect.fromLTWH(0, 0, 300, 200),
    dataXMin: 0,
    dataXMax: 100,
    dataYMin: 0,
    dataYMax: 50,
  );

  @override
  Offset? get crosshairPosition => null;

  @override
  FusionDataPoint? get crosshairPoint => null;

  @override
  bool get isInteracting => _isInteracting;

  @override
  double get tooltipOpacity => 0;

  @override
  bool get isPointerDown => false;

  @override
  FusionTooltipDataBase? get tooltipData => null;

  @override
  bool get isAnimatingZoom => false;

  @override
  double get zoomAnimationProgress => 1.0;

  @override
  bool get isSelectionZoomActive => false;

  @override
  Offset? get selectionStart => null;

  @override
  Offset? get selectionCurrent => null;

  @override
  Rect? get selectionRect => null;

  @override
  void handlePointerDown(PointerDownEvent event) {}

  @override
  void handlePointerMove(PointerMoveEvent event) {}

  @override
  void handlePointerUp(PointerUpEvent event) {}

  @override
  void handlePointerCancel(PointerCancelEvent event) {}

  @override
  void handlePointerHover(PointerHoverEvent event) {}

  @override
  void handlePointerSignal(PointerSignalEvent event) {}

  @override
  void handlePointerExit(PointerExitEvent event) {}

  @override
  Map<Type, GestureRecognizerFactory> getGestureRecognizers() => {};
}

void main() {
  group('FusionChartController', () {
    late FusionChartController controller;
    late MockInteractiveState mockState;

    setUp(() {
      controller = FusionChartController();
      mockState = MockInteractiveState();
    });

    tearDown(() {
      controller.dispose();
      mockState.dispose();
    });

    group('Initial State', () {
      test('isAttached returns false when not attached', () {
        expect(controller.isAttached, false);
      });

      test('zoomLevel returns 1.0 when not attached', () {
        expect(controller.zoomLevel, 1.0);
      });

      test('isZoomed returns false when not attached', () {
        expect(controller.isZoomed, false);
      });
    });

    group('Attach/Detach', () {
      test('isAttached returns true after attach', () {
        controller.attach(mockState);
        expect(controller.isAttached, true);
      });

      test('isAttached returns false after detach', () {
        controller.attach(mockState);
        controller.detach();
        expect(controller.isAttached, false);
      });

      test('attach notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.attach(mockState);
        expect(notified, true);
      });

      test('detach notifies listeners', () {
        controller.attach(mockState);

        var notified = false;
        controller.addListener(() => notified = true);

        controller.detach();
        expect(notified, true);
      });

      test('can reattach after detach', () {
        controller.attach(mockState);
        controller.detach();
        controller.attach(mockState);
        expect(controller.isAttached, true);
      });
    });

    group('Zoom Controls - When Attached', () {
      setUp(() {
        controller.attach(mockState);
      });

      test('zoomIn calls state.zoomIn()', () {
        controller.zoomIn();
        expect(mockState.zoomInCallCount, 1);
      });

      test('zoomIn can be called multiple times', () {
        controller.zoomIn();
        controller.zoomIn();
        controller.zoomIn();
        expect(mockState.zoomInCallCount, 3);
      });

      test('zoomOut calls state.zoomOut()', () {
        controller.zoomOut();
        expect(mockState.zoomOutCallCount, 1);
      });

      test('zoomOut can be called multiple times', () {
        controller.zoomOut();
        controller.zoomOut();
        expect(mockState.zoomOutCallCount, 2);
      });

      test('resetZoom calls state.reset()', () {
        controller.resetZoom();
        expect(mockState.resetCallCount, 1);
      });

      test('reset calls state.reset()', () {
        controller.reset();
        expect(mockState.resetCallCount, 1);
      });

      test('sequential zoom operations work correctly', () {
        controller.zoomIn();
        controller.zoomIn();
        controller.zoomOut();
        controller.resetZoom();

        expect(mockState.zoomInCallCount, 2);
        expect(mockState.zoomOutCallCount, 1);
        expect(mockState.resetCallCount, 1);
      });
    });

    group('Zoom Controls - When Not Attached', () {
      test('zoomIn does nothing when not attached', () {
        // Should not throw
        controller.zoomIn();
        expect(controller.isAttached, false);
      });

      test('zoomOut does nothing when not attached', () {
        // Should not throw
        controller.zoomOut();
        expect(controller.isAttached, false);
      });

      test('resetZoom does nothing when not attached', () {
        // Should not throw
        controller.resetZoom();
        expect(controller.isAttached, false);
      });

      test('reset does nothing when not attached', () {
        // Should not throw
        controller.reset();
        expect(controller.isAttached, false);
      });
    });

    group('Zoom Controls - After Detach', () {
      test('zoomIn does nothing after detach', () {
        controller.attach(mockState);
        controller.detach();

        controller.zoomIn();
        // Should not have been called after detach
        expect(mockState.zoomInCallCount, 0);
      });

      test('zoomOut does nothing after detach', () {
        controller.attach(mockState);
        controller.detach();

        controller.zoomOut();
        expect(mockState.zoomOutCallCount, 0);
      });

      test('resetZoom does nothing after detach', () {
        controller.attach(mockState);
        controller.detach();

        controller.resetZoom();
        expect(mockState.resetCallCount, 0);
      });
    });

    group('Dispose', () {
      test('dispose clears attachment', () {
        // Use a separate controller for this test to avoid double-dispose
        final disposeController = FusionChartController();
        final disposeState = MockInteractiveState();

        disposeController.attach(disposeState);
        disposeController.dispose();

        // After dispose, isAttached should return false
        expect(disposeController.isAttached, false);

        disposeState.dispose();
      });

      test('can safely call zoom methods after dispose', () {
        // Use a separate controller for this test to avoid double-dispose
        final disposeController = FusionChartController();
        final disposeState = MockInteractiveState();

        disposeController.attach(disposeState);
        disposeController.dispose();

        // These should not throw
        expect(disposeController.zoomIn, returnsNormally);
        expect(disposeController.zoomOut, returnsNormally);
        expect(disposeController.resetZoom, returnsNormally);

        disposeState.dispose();
      });
    });

    group('Multiple Controllers', () {
      test('two controllers can exist independently', () {
        final controller1 = FusionChartController();
        final controller2 = FusionChartController();
        final state1 = MockInteractiveState();
        final state2 = MockInteractiveState();

        controller1.attach(state1);
        controller2.attach(state2);

        controller1.zoomIn();
        controller2.zoomOut();

        expect(state1.zoomInCallCount, 1);
        expect(state1.zoomOutCallCount, 0);
        expect(state2.zoomInCallCount, 0);
        expect(state2.zoomOutCallCount, 1);

        controller1.dispose();
        controller2.dispose();
        state1.dispose();
        state2.dispose();
      });
    });

    group('State Reflection', () {
      test('isZoomed reflects state.isInteracting when false', () {
        controller.attach(mockState);
        expect(controller.isZoomed, false);
      });

      test('isZoomed reflects state.isInteracting when true', () {
        mockState.setIsInteracting(true);
        controller.attach(mockState);
        expect(controller.isZoomed, true);
      });
    });
  });
}

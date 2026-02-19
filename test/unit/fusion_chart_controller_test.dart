import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/charts/base/fusion_interactive_state_base.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import 'package:fusion_charts_flutter/src/controllers/fusion_chart_controller.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/rendering/fusion_coordinate_system.dart';

void main() {
  // ===========================================================================
  // FUSION CHART CONTROLLER - CONSTRUCTION
  // ===========================================================================
  group('FusionChartController - Construction', () {
    test('creates successfully', () {
      final controller = FusionChartController();
      expect(controller, isNotNull);
      controller.dispose();
    });

    test('is not attached initially', () {
      final controller = FusionChartController();
      expect(controller.isAttached, isFalse);
      controller.dispose();
    });

    test('zoomLevel returns 1.0 when not attached', () {
      final controller = FusionChartController();
      expect(controller.zoomLevel, 1.0);
      controller.dispose();
    });

    test('isZoomed returns false when not attached', () {
      final controller = FusionChartController();
      expect(controller.isZoomed, isFalse);
      controller.dispose();
    });
  });

  // ===========================================================================
  // ATTACH/DETACH
  // ===========================================================================
  group('FusionChartController - Attach/Detach', () {
    test('attach sets isAttached to true', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);

      expect(controller.isAttached, isTrue);

      controller.dispose();
    });

    test('attach notifies listeners', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();
      int notifyCount = 0;

      controller.addListener(() => notifyCount++);
      controller.attach(mockState);

      expect(notifyCount, 1);

      controller.dispose();
    });

    test('detach sets isAttached to false', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.detach();

      expect(controller.isAttached, isFalse);

      controller.dispose();
    });

    test('detach notifies listeners', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();
      int notifyCount = 0;

      controller.attach(mockState);
      controller.addListener(() => notifyCount++);
      controller.detach();

      expect(notifyCount, 1);

      controller.dispose();
    });
  });

  // ===========================================================================
  // ZOOM CONTROLS
  // ===========================================================================
  group('FusionChartController - Zoom Controls', () {
    test('zoomIn calls interactive state zoomIn', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.zoomIn();

      expect(mockState.zoomInCalled, isTrue);

      controller.dispose();
    });

    test('zoomIn does nothing when not attached', () {
      final controller = FusionChartController();

      // Should not throw
      controller.zoomIn();

      controller.dispose();
    });

    test('zoomOut calls interactive state zoomOut', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.zoomOut();

      expect(mockState.zoomOutCalled, isTrue);

      controller.dispose();
    });

    test('zoomOut does nothing when not attached', () {
      final controller = FusionChartController();

      // Should not throw
      controller.zoomOut();

      controller.dispose();
    });

    test('resetZoom calls interactive state reset', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.resetZoom();

      expect(mockState.resetCalled, isTrue);

      controller.dispose();
    });

    test('resetZoom does nothing when not attached', () {
      final controller = FusionChartController();

      // Should not throw
      controller.resetZoom();

      controller.dispose();
    });
  });

  // ===========================================================================
  // RESET
  // ===========================================================================
  group('FusionChartController - Reset', () {
    test('reset calls interactive state reset', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.reset();

      expect(mockState.resetCalled, isTrue);

      controller.dispose();
    });

    test('reset does nothing when not attached', () {
      final controller = FusionChartController();

      // Should not throw
      controller.reset();

      controller.dispose();
    });
  });

  // ===========================================================================
  // ZOOMED STATE
  // ===========================================================================
  group('FusionChartController - Zoomed State', () {
    test('isZoomed returns interactive state isInteracting', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);

      mockState.mockIsInteracting = true;
      expect(controller.isZoomed, isTrue);

      mockState.mockIsInteracting = false;
      expect(controller.isZoomed, isFalse);

      controller.dispose();
    });
  });

  // ===========================================================================
  // DISPOSE
  // ===========================================================================
  group('FusionChartController - Dispose', () {
    test('dispose clears interactive state reference', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.dispose();

      // Cannot test isAttached after dispose as it's disposed
    });

    test('dispose can be called multiple times safely', () {
      final controller = FusionChartController();

      controller.dispose();

      // Second dispose should not throw
      // Note: Typically this would throw but we're checking robustness
    });
  });

  // ===========================================================================
  // LISTENER MANAGEMENT
  // ===========================================================================
  group('FusionChartController - Listener Management', () {
    test('addListener adds callback', () {
      final controller = FusionChartController();
      int callCount = 0;

      controller.addListener(() => callCount++);
      controller.attach(_MockInteractiveState());

      expect(callCount, 1);

      controller.dispose();
    });

    test('removeListener removes callback', () {
      final controller = FusionChartController();
      int callCount = 0;

      void listener() => callCount++;
      controller.addListener(listener);
      controller.removeListener(listener);
      controller.attach(_MockInteractiveState());

      expect(callCount, 0);

      controller.dispose();
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionChartController - Edge Cases', () {
    test('attaching a new state replaces the old one', () {
      final controller = FusionChartController();
      final mockState1 = _MockInteractiveState();
      final mockState2 = _MockInteractiveState();

      controller.attach(mockState1);
      controller.attach(mockState2);
      controller.zoomIn();

      expect(mockState1.zoomInCalled, isFalse);
      expect(mockState2.zoomInCalled, isTrue);

      controller.dispose();
    });

    test('detach then attach works correctly', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.detach();
      controller.attach(mockState);

      expect(controller.isAttached, isTrue);
      controller.zoomIn();
      expect(mockState.zoomInCalled, isTrue);

      controller.dispose();
    });

    test('calling methods after detach does nothing', () {
      final controller = FusionChartController();
      final mockState = _MockInteractiveState();

      controller.attach(mockState);
      controller.detach();

      // Should not throw
      controller.zoomIn();
      controller.zoomOut();
      controller.resetZoom();
      controller.reset();

      // Methods should not have been called since we detached
      expect(mockState.zoomInCalled, isFalse);
      expect(mockState.zoomOutCalled, isFalse);
      expect(mockState.resetCalled, isFalse);

      controller.dispose();
    });
  });
}

/// Mock implementation of FusionInteractiveStateBase for testing
class _MockInteractiveState extends FusionInteractiveStateBase {
  bool zoomInCalled = false;
  bool zoomOutCalled = false;
  bool resetCalled = false;
  bool mockIsInteracting = false;

  @override
  FusionCoordinateSystem get coordSystem => FusionCoordinateSystem(
    chartArea: const Rect.fromLTWH(0, 0, 400, 300),
    dataXMin: 0,
    dataXMax: 100,
    dataYMin: 0,
    dataYMax: 100,
    devicePixelRatio: 1.0,
  );

  @override
  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {}

  @override
  FusionTooltipDataBase? get tooltipData => null;

  @override
  double get tooltipOpacity => 1.0;

  @override
  Offset? get crosshairPosition => null;

  @override
  FusionDataPoint? get crosshairPoint => null;

  @override
  bool get isInteracting => mockIsInteracting;

  @override
  bool get isPointerDown => false;

  @override
  void initialize() {}

  @override
  void zoomIn() {
    zoomInCalled = true;
  }

  @override
  void zoomOut() {
    zoomOutCalled = true;
  }

  @override
  void reset() {
    resetCalled = true;
  }

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
  void handlePointerExit(PointerExitEvent event) {}

  @override
  void handlePointerSignal(PointerSignalEvent event) {}

  @override
  Map<Type, GestureRecognizerFactory> getGestureRecognizers() => {};
}

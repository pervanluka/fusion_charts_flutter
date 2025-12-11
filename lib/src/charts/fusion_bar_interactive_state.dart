import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import '../rendering/fusion_bar_hit_tester.dart';

/// Specialized interactive state for bar charts.
///
/// Unlike the generic interactive state that finds nearest points by distance,
/// this uses rectangle-based hit testing for accurate bar selection.
class FusionBarInteractiveState extends ChangeNotifier {
  FusionBarInteractiveState({
    required this.config,
    required FusionCoordinateSystem initialCoordSystem,
    required this.series,
    this.enableSideBySideSeriesPlacement = true,
  }) : _currentCoordSystem = initialCoordSystem;

  final FusionChartConfiguration config;
  final List<FusionBarSeries> series;
  final bool enableSideBySideSeriesPlacement;

  FusionCoordinateSystem _currentCoordSystem;
  final FusionBarHitTester _hitTester = const FusionBarHitTester();

  // Tooltip state
  TooltipRenderData? _tooltipData;
  double _tooltipOpacity = 0.0;

  // Crosshair state
  Offset? _crosshairPosition;
  FusionDataPoint? _crosshairPoint;

  // Pointer state
  bool _isPointerDown = false;
  DateTime? _pointerDownTime;

  // Timers
  Timer? _tooltipHideTimer;
  Timer? _crosshairHideTimer;

  // Getters
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;
  TooltipRenderData? get tooltipData => _tooltipData;
  double get tooltipOpacity => _tooltipOpacity;
  Offset? get crosshairPosition => _crosshairPosition;
  FusionDataPoint? get crosshairPoint => _crosshairPoint;

  void initialize() {
    // Nothing special needed for initialization
  }

  void updateCoordinateSystem(FusionCoordinateSystem newCoordSystem) {
    if (_currentCoordSystem != newCoordSystem) {
      _currentCoordSystem = newCoordSystem;
    }
  }

  // ========================================================================
  // POINTER EVENT HANDLERS
  // ========================================================================

  void handlePointerDown(PointerDownEvent event) {
    _isPointerDown = true;
    _pointerDownTime = DateTime.now();
    _tooltipHideTimer?.cancel();

    if (!config.enableTooltip) return;

    final hitResult = _hitTester.hitTest(
      screenPosition: event.localPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null) {
      _showTooltip(hitResult, event.localPosition);
    } else {
      _hideTooltip();
    }
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (!_isPointerDown || !config.enableTooltip) return;

    final hitResult = _hitTester.hitTest(
      screenPosition: event.localPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null) {
      _showTooltip(hitResult, event.localPosition);
    } else {
      _hideTooltip();
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    _isPointerDown = false;

    final pressDuration = _pointerDownTime != null
        ? DateTime.now().difference(_pointerDownTime!)
        : Duration.zero;
    final wasLongPress = pressDuration.inMilliseconds > 500;

    if (config.enableTooltip && _tooltipData != null) {
      final delay = config.tooltipBehavior.getDismissDelay(wasLongPress);
      if (delay == Duration.zero) {
        _hideTooltip();
      } else {
        _startHideTimer(delay);
      }
    }

    if (config.enableCrosshair && _crosshairPosition != null) {
      _hideCrosshair();
    }

    _pointerDownTime = null;
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _hideTooltip();
    _hideCrosshair();
  }

  void handlePointerHover(PointerHoverEvent event) {
    if (!config.enableTooltip) return;

    final hitResult = _hitTester.hitTest(
      screenPosition: event.localPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null) {
      _showTooltip(hitResult, event.localPosition);
    } else {
      _hideTooltip();
    }
  }

  // ========================================================================
  // TOOLTIP MANAGEMENT
  // ========================================================================

  void _showTooltip(BarHitTestResult hitResult, Offset pointerPosition) {
    _tooltipHideTimer?.cancel();

    if (config.tooltipBehavior.hapticFeedback && _tooltipData == null) {
      HapticFeedback.selectionClick();
    }

    // Calculate tooltip position at the top center of the bar
    final tooltipPosition = Offset(hitResult.barRect.center.dx, hitResult.barRect.top);

    _tooltipData = TooltipRenderData(
      point: hitResult.point,
      seriesName: hitResult.seriesName,
      seriesColor: hitResult.seriesColor,
      screenPosition: tooltipPosition,
      wasLongPress: false,
      activationTime: DateTime.now(),
    );

    _tooltipOpacity = 1.0;
    notifyListeners();
  }

  void _hideTooltip() {
    if (_tooltipData != null) {
      _tooltipHideTimer?.cancel();
      _tooltipData = null;
      _tooltipOpacity = 0.0;
      notifyListeners();
    }
  }

  void _startHideTimer(Duration delay) {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = Timer(delay, () {
      if (!_isPointerDown) {
        _hideTooltip();
      }
    });
  }

  // ========================================================================
  // CROSSHAIR MANAGEMENT
  // ========================================================================

  void _showCrosshair(Offset position, FusionDataPoint? snappedPoint) {
    _crosshairHideTimer?.cancel();
    _crosshairPosition = position;
    _crosshairPoint = snappedPoint;
    notifyListeners();
  }

  void _hideCrosshair() {
    _crosshairHideTimer?.cancel();
    if (_crosshairPosition != null) {
      _crosshairPosition = null;
      _crosshairPoint = null;
      notifyListeners();
    }
  }

  // ========================================================================
  // GESTURE RECOGNIZERS
  // ========================================================================

  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    final recognizers = <Type, GestureRecognizerFactory>{};

    if (config.enableTooltip || config.enableSelection) {
      recognizers[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(() => TapGestureRecognizer(), (
            recognizer,
          ) {
            recognizer.onTapDown = (details) {
              final hitResult = _hitTester.hitTest(
                screenPosition: details.localPosition,
                allSeries: series,
                coordSystem: _currentCoordSystem,
                enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
              );

              if (hitResult != null && config.enableTooltip) {
                _showTooltip(hitResult, details.localPosition);
              }
            };
          });
    }

    if (config.enableCrosshair) {
      recognizers[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(),
            (recognizer) {
              recognizer.onLongPressStart = (details) {
                final hitResult = _hitTester.hitTest(
                  screenPosition: details.localPosition,
                  allSeries: series,
                  coordSystem: _currentCoordSystem,
                  enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
                );

                if (hitResult != null) {
                  _showCrosshair(details.localPosition, hitResult.point);
                }
              };
            },
          );
    }

    return recognizers;
  }

  @override
  void dispose() {
    _tooltipHideTimer?.cancel();
    _crosshairHideTimer?.cancel();
    super.dispose();
  }
}

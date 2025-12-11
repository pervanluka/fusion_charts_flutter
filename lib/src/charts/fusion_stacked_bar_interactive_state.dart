import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../configuration/fusion_chart_configuration.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_stacked_bar_hit_tester.dart';
import '../series/fusion_stacked_bar_series.dart';

/// Tooltip data specifically for stacked bars.
///
/// Contains all segment information for rich multi-line tooltips.
class StackedTooltipData {
  const StackedTooltipData({
    required this.categoryLabel,
    required this.segments,
    required this.totalValue,
    required this.screenPosition,
    required this.isStacked100,
    this.hitSegmentIndex = -1,
  });

  final String? categoryLabel;
  final List<StackedSegmentInfo> segments;
  final double totalValue;
  final Offset screenPosition;
  final bool isStacked100;
  final int hitSegmentIndex;
}

/// Specialized interactive state for stacked bar charts.
///
/// Shows a multi-line tooltip with all segments in the stack.
class FusionStackedBarInteractiveState extends ChangeNotifier {
  FusionStackedBarInteractiveState({
    required this.config,
    required FusionCoordinateSystem initialCoordSystem,
    required this.series,
    required this.isStacked100,
  }) : _currentCoordSystem = initialCoordSystem;

  final FusionChartConfiguration config;
  final List<FusionStackedBarSeries> series;
  final bool isStacked100;

  FusionCoordinateSystem _currentCoordSystem;
  final FusionStackedBarHitTester _hitTester = const FusionStackedBarHitTester();

  // Tooltip state
  StackedTooltipData? _tooltipData;
  double _tooltipOpacity = 0.0;

  // Pointer state
  bool _isPointerDown = false;
  DateTime? _pointerDownTime;

  // Timers
  Timer? _tooltipHideTimer;

  // Getters
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;
  StackedTooltipData? get tooltipData => _tooltipData;
  double get tooltipOpacity => _tooltipOpacity;

  void initialize() {}

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
      isStacked100: isStacked100,
    );

    if (hitResult != null) {
      _showTooltip(hitResult);
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
      isStacked100: isStacked100,
    );

    if (hitResult != null) {
      _showTooltip(hitResult);
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

    _pointerDownTime = null;
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _hideTooltip();
  }

  void handlePointerHover(PointerHoverEvent event) {
    if (!config.enableTooltip) return;

    final hitResult = _hitTester.hitTest(
      screenPosition: event.localPosition,
      allSeries: series,
      coordSystem: _currentCoordSystem,
      isStacked100: isStacked100,
    );

    if (hitResult != null) {
      _showTooltip(hitResult);
    } else {
      _hideTooltip();
    }
  }

  // ========================================================================
  // TOOLTIP MANAGEMENT
  // ========================================================================

  void _showTooltip(StackedBarHitTestResult hitResult) {
    _tooltipHideTimer?.cancel();

    if (config.tooltipBehavior.hapticFeedback && _tooltipData == null) {
      HapticFeedback.selectionClick();
    }

    // Position tooltip at the top center of the stack (arrow will point here)
    final tooltipPosition = Offset(
      hitResult.stackRect.center.dx,
      hitResult.stackRect.top, // Exact top of the bar
    );

    _tooltipData = StackedTooltipData(
      categoryLabel: hitResult.categoryLabel,
      segments: hitResult.segments,
      totalValue: hitResult.totalValue,
      screenPosition: tooltipPosition,
      isStacked100: isStacked100,
      hitSegmentIndex: hitResult.hitSegmentIndex,
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
                isStacked100: isStacked100,
              );

              if (hitResult != null && config.enableTooltip) {
                _showTooltip(hitResult);
              }
            };
          });
    }

    return recognizers;
  }

  @override
  void dispose() {
    _tooltipHideTimer?.cancel();
    super.dispose();
  }
}

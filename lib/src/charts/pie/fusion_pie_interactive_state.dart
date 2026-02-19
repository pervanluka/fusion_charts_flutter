// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../configuration/fusion_pie_chart_configuration.dart';
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../core/enums/fusion_tooltip_activation_mode.dart';
import '../../data/fusion_data_point.dart';
import '../../data/fusion_pie_data_point.dart';
import '../../rendering/fusion_coordinate_system.dart';
import '../../rendering/polar/fusion_pie_segment.dart';
import '../../series/fusion_pie_series.dart';
import '../../utils/fusion_color_palette.dart';
import '../base/fusion_interactive_state_base.dart';
import 'pie_tooltip_data.dart';

/// Interactive state manager for pie charts.
///
/// Fully integrates with [FusionTooltipBehavior] for professional tooltip handling:
/// - Activation modes (tap, hover, longPress, auto)
/// - Dismiss strategies (onRelease, onTimer, onReleaseDelayed, never, smart)
/// - Activation delays
/// - Haptic feedback
/// - Opacity animation
class FusionPieInteractiveState extends ChangeNotifier
    implements FusionInteractiveStateBase {
  FusionPieInteractiveState({
    required this.config,
    required this.series,
    required this.palette,
    this.onSegmentTap,
    this.onSegmentLongPress,
    this.onSelectionChanged,
  });

  final FusionPieChartConfiguration config;
  final FusionPieSeries series;
  final FusionColorPalette palette;

  /// Gets the tooltip behavior from config.
  FusionTooltipBehavior get _tooltipBehavior => config.tooltipBehavior;

  // ===========================================================================
  // EXTERNAL CALLBACKS (from widget)
  // ===========================================================================

  final void Function(int index, FusionPieSeries series)? onSegmentTap;
  final void Function(int index, FusionPieSeries series)? onSegmentLongPress;
  final void Function(Set<int> selectedIndices)? onSelectionChanged;

  // ===========================================================================
  // LAYOUT STATE
  // ===========================================================================

  Offset _center = Offset.zero;
  Offset get center => _center;

  double _availableRadius = 100;
  double get availableRadius => _availableRadius;

  Size _size = Size.zero;
  Size get size => _size;

  List<ComputedPieSegment> _segments = const [];
  List<ComputedPieSegment> get segments => _segments;

  final _segmentCache = FusionPieSegmentCache();

  // ===========================================================================
  // INTERACTION STATE
  // ===========================================================================

  final Set<int> _selectedIndices = {};
  Set<int> get selectedIndices => Set.unmodifiable(_selectedIndices);

  final Set<int> _explodedIndices = {};
  Set<int> get explodedIndices => Set.unmodifiable(_explodedIndices);

  int? _hoveredIndex;
  int? get hoveredIndex => _hoveredIndex;

  // ===========================================================================
  // TOOLTIP STATE (Enhanced)
  // ===========================================================================

  PieTooltipData? _tooltipData;
  double _tooltipOpacity = 0.0;
  bool _isPointerDown = false;
  DateTime? _pointerDownTime;
  bool _wasLongPress = false;

  // Timer management
  Timer? _tooltipShowTimer;
  Timer? _tooltipHideTimer;
  Timer? _selectionClearTimer;

  /// Default delay for auto-clearing selection when tooltip is disabled.
  static const _defaultSelectionClearDelay = Duration(milliseconds: 1500);

  // ===========================================================================
  // COORDINATE SYSTEM (Required by interface)
  // ===========================================================================

  FusionCoordinateSystem? _coordSystem;

  @override
  FusionCoordinateSystem get coordSystem {
    return _coordSystem ??
        FusionCoordinateSystem(
          chartArea: Rect.fromCenter(
            center: _center,
            width: _availableRadius * 2,
            height: _availableRadius * 2,
          ),
          dataXMin: 0,
          dataXMax: 360,
          dataYMin: 0,
          dataYMax: _availableRadius,
        );
  }

  @override
  void updateCoordinateSystem(FusionCoordinateSystem coordSystem) {
    _coordSystem = coordSystem;
  }

  // ===========================================================================
  // INTERFACE IMPLEMENTATION
  // ===========================================================================

  @override
  FusionTooltipDataBase? get tooltipData => _tooltipData;

  @override
  double get tooltipOpacity => _tooltipOpacity;

  @override
  Offset? get crosshairPosition => null; // N/A for pie

  @override
  FusionDataPoint? get crosshairPoint => null; // N/A for pie

  @override
  bool get isInteracting => _isPointerDown;

  @override
  bool get isPointerDown => _isPointerDown;

  @override
  void initialize() {
    _explodedIndices.clear();
    if (series.explodeAll) {
      for (int i = 0; i < series.dataPoints.length; i++) {
        _explodedIndices.add(i);
      }
    } else {
      for (int i = 0; i < series.dataPoints.length; i++) {
        if (series.dataPoints[i].explode) {
          _explodedIndices.add(i);
        }
      }
    }
  }

  // ===========================================================================
  // LAYOUT UPDATE
  // ===========================================================================

  void updateLayout({
    required Offset center,
    required double availableRadius,
    required Size size,
  }) {
    _center = center;
    _availableRadius = availableRadius;
    _size = size;

    _segments = _segmentCache.getOrCompute(
      series: series,
      config: config,
      layoutSize: size,
      center: center,
      availableRadius: availableRadius,
      palette: palette,
      labelConnectorLength: config.labelConnectorLength,
      explodedIndices: _explodedIndices,
      selectedIndices: _selectedIndices,
      hoveredIndex: _hoveredIndex,
    );
  }

  // ===========================================================================
  // HIT TESTING
  // ===========================================================================

  int? hitTest(Offset position) {
    if (_segments.isEmpty) return null;

    for (int i = _segments.length - 1; i >= 0; i--) {
      if (_segments[i].containsPoint(position)) {
        return i;
      }
    }
    return null;
  }

  // ===========================================================================
  // POINTER HANDLERS
  // ===========================================================================

  @override
  void handlePointerDown(PointerDownEvent event) {
    _isPointerDown = true;
    _pointerDownTime = DateTime.now();
    _wasLongPress = false;

    // Cancel any pending timers
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();

    final hitIndex = hitTest(event.localPosition);

    if (hitIndex != null) {
      // Check activation mode
      final effectiveMode = _tooltipBehavior.getEffectiveActivationMode(
        TargetPlatform.android, // Will be overridden by platform detection
      );

      if (effectiveMode == FusionTooltipActivationMode.singleTap ||
          effectiveMode == FusionTooltipActivationMode.auto) {
        _handleTap(hitIndex, event.localPosition);
      }
    }

    notifyListeners();
  }

  @override
  void handlePointerMove(PointerMoveEvent event) {
    if (!_isPointerDown) return;

    final hitIndex = hitTest(event.localPosition);

    if (hitIndex != null) {
      final currentIndex = _tooltipData?.index;

      // Segment changed - update selection highlight
      if (hitIndex != currentIndex) {
        // Update selection to current segment (scrubbing behavior)
        if (config.enableSelection &&
            config.selectionMode == PieSelectionMode.single) {
          _selectedIndices.clear();
          _selectedIndices.add(hitIndex);

          // Handle explode on selection during drag
          if (config.explodeOnSelection) {
            // Collapse previous
            if (currentIndex != null) {
              final prevDataPoint = currentIndex < series.dataPoints.length
                  ? series.dataPoints[currentIndex]
                  : null;
              if (!series.explodeAll &&
                  (prevDataPoint == null || !prevDataPoint.explode)) {
                _explodedIndices.remove(currentIndex);
              }
            }
            // Explode current
            _explodedIndices.add(hitIndex);
          }

          _recomputeSegments();
        }
      }

      // Always update tooltip position to follow finger
      if (config.enableTooltip) {
        _updateTooltipForSegment(hitIndex, event.localPosition);
      }
    } else {
      // Moved outside all segments - clear highlight but keep last tooltip briefly
      if (_selectedIndices.isNotEmpty &&
          config.selectionMode == PieSelectionMode.single) {
        // Don't clear immediately - feels jarring. Let pointer up handle it.
      }
    }

    notifyListeners();
  }

  @override
  void handlePointerUp(PointerUpEvent event) {
    _isPointerDown = false;

    final pressDuration = _pointerDownTime != null
        ? DateTime.now().difference(_pointerDownTime!)
        : Duration.zero;

    _wasLongPress = pressDuration.inMilliseconds > 500;

    // Handle dismiss based on strategy
    if (_tooltipData != null && config.enableTooltip) {
      if (_tooltipBehavior.shouldDismissOnRelease()) {
        final delay = _tooltipBehavior.getDismissDelay(_wasLongPress);
        if (delay == Duration.zero) {
          _hideTooltipAnimated();
        } else {
          _startHideTimer(delay);
        }
      } else if (_tooltipBehavior.shouldUseTimer()) {
        _startHideTimer(_tooltipBehavior.duration);
      }
      // dismissStrategy.never - don't hide
    }

    _pointerDownTime = null;
    notifyListeners();
  }

  @override
  void handlePointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _pointerDownTime = null;
    _wasLongPress = false;

    _hideTooltipAnimated();
    notifyListeners();
  }

  @override
  void handlePointerExit(PointerExitEvent event) {
    // Clear hover state when mouse leaves chart area
    if (_hoveredIndex != null) {
      final previousIndex = _hoveredIndex;
      _hoveredIndex = null;

      // Collapse exploded segment if it was hover-exploded
      if (config.explodeOnHover && previousIndex != null) {
        if (!series.explodeAll &&
            (previousIndex >= series.dataPoints.length ||
                !series.dataPoints[previousIndex].explode) &&
            !_selectedIndices.contains(previousIndex)) {
          _explodedIndices.remove(previousIndex);
        }
      }
    }

    // Hide tooltip
    _hideTooltipAnimated();
    notifyListeners();
  }

  @override
  void handlePointerHover(PointerHoverEvent event) {
    if (!config.enableHover) return;

    final hitIndex = hitTest(event.localPosition);
    final previousIndex = _hoveredIndex;

    if (hitIndex != null) {
      // Check if hover activation is enabled
      final effectiveMode = _tooltipBehavior.getEffectiveActivationMode(
        TargetPlatform.macOS, // Desktop platform for hover
      );

      final showTooltip =
          effectiveMode == FusionTooltipActivationMode.hover ||
          effectiveMode == FusionTooltipActivationMode.auto;

      if (hitIndex != previousIndex) {
        // Segment changed
        _hoveredIndex = hitIndex;

        // Handle explode transitions
        if (config.explodeOnHover) {
          // Collapse previous
          if (previousIndex != null) {
            if (!series.explodeAll &&
                (previousIndex >= series.dataPoints.length ||
                    !series.dataPoints[previousIndex].explode) &&
                !_selectedIndices.contains(previousIndex)) {
              _explodedIndices.remove(previousIndex);
            }
          }
          // Explode current
          _explodedIndices.add(hitIndex);
        }

        _recomputeSegments();
      }

      // Always update tooltip position to follow cursor (like mobile drag)
      if (showTooltip && config.enableTooltip) {
        _updateTooltipForSegment(hitIndex, event.localPosition);
      }
    } else {
      // Mouse left all segments
      if (previousIndex != null) {
        _hoveredIndex = null;
        _hideTooltipAnimated();

        if (config.explodeOnHover) {
          _explodedIndices.removeWhere(
            (i) =>
                !series.explodeAll &&
                (i >= series.dataPoints.length ||
                    !series.dataPoints[i].explode) &&
                !_selectedIndices.contains(i),
          );
        }

        _recomputeSegments();
      }
    }

    notifyListeners();
  }

  @override
  void handlePointerSignal(PointerSignalEvent event) {
    // Pie charts don't handle scroll/zoom
  }

  @override
  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    return {
      LongPressGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(),
            (recognizer) {
              recognizer.onLongPressStart = (details) {
                _wasLongPress = true;
                _handleLongPress(details.localPosition);
              };
            },
          ),
    };
  }

  // ===========================================================================
  // TAP / LONG PRESS HANDLERS
  // ===========================================================================

  void _handleTap(int index, Offset position) {
    final segment = _segments[index];
    final dataPoint = segment.dataPoint;

    // 1. Fire external widget callback
    onSegmentTap?.call(index, series);

    // 2. Fire data point callback
    dataPoint.onTap?.call(dataPoint, index);

    // 3. Show tooltip with delay
    if (config.enableTooltip) {
      _showTooltipWithDelay(index, position, false);
    }

    // 4. Handle selection if enabled
    if (config.enableSelection) {
      _handleSelection(index, dataPoint);

      // If tooltip is disabled, start auto-clear timer for selection
      if (!config.enableTooltip) {
        _startSelectionClearTimer();
      }
    }
  }

  void _handleLongPress(Offset position) {
    final hitIndex = hitTest(position);
    if (hitIndex == null) return;

    final segment = _segments[hitIndex];
    final dataPoint = segment.dataPoint;

    // 1. Fire external widget callback
    onSegmentLongPress?.call(hitIndex, series);

    // 2. Fire data point callback
    dataPoint.onLongPress?.call(dataPoint, hitIndex);

    // 3. Show tooltip (long press activation)
    final effectiveMode = _tooltipBehavior.getEffectiveActivationMode(
      TargetPlatform.android,
    );

    if (effectiveMode == FusionTooltipActivationMode.longPress ||
        config.enableTooltip) {
      _showTooltipEnhanced(hitIndex, position, true);
    }

    notifyListeners();
  }

  void _handleSelection(int index, FusionPieDataPoint dataPoint) {
    switch (config.selectionMode) {
      case PieSelectionMode.none:
        break;

      case PieSelectionMode.single:
        _selectedIndices.clear();
        _selectedIndices.add(index);

      case PieSelectionMode.multiple:
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
    }

    // Handle explode on selection
    if (config.explodeOnSelection) {
      if (_selectedIndices.contains(index)) {
        _explodedIndices.add(index);
      } else {
        if (!series.explodeAll && !dataPoint.explode) {
          _explodedIndices.remove(index);
        }
      }
    }

    _notifySelectionChanged();
    _recomputeSegments();
  }

  // ===========================================================================
  // TOOLTIP MANAGEMENT (Enhanced)
  // ===========================================================================

  void _showTooltipWithDelay(int index, Offset position, bool wasLongPress) {
    if (!config.enableTooltip) return;

    final delay = _tooltipBehavior.activationDelay;

    if (delay == Duration.zero) {
      _showTooltipEnhanced(index, position, wasLongPress);
    } else {
      _tooltipShowTimer?.cancel();
      _tooltipShowTimer = Timer(delay, () {
        if (_isPointerDown || _hoveredIndex == index) {
          _showTooltipEnhanced(index, position, wasLongPress);
        }
      });
    }
  }

  void _showTooltipEnhanced(int index, Offset position, bool wasLongPress) {
    if (index < 0 || index >= _segments.length) return;

    _tooltipHideTimer?.cancel();

    // Haptic feedback
    if (_tooltipBehavior.hapticFeedback) {
      HapticFeedback.selectionClick();
    }

    final segment = _segments[index];

    _tooltipData = PieTooltipData(
      index: index,
      value: segment.value,
      percentage: segment.percentage,
      label: segment.label,
      color: segment.color,
      screenPosition: position,
      segmentCenter: segment.centroid,
      dataPoint: segment.dataPoint,
      isExploded: segment.isExploded,
      isSelected: _selectedIndices.contains(index),
    );

    _tooltipOpacity = 1.0;
    _wasLongPress = wasLongPress;

    notifyListeners();

    // Start timer if not pointer down and using timer strategy
    if (!_isPointerDown && _tooltipBehavior.shouldUseTimer()) {
      _startHideTimer(_tooltipBehavior.getDismissDelay(wasLongPress));
    }
  }

  void _updateTooltipForSegment(int index, Offset position) {
    if (index < 0 || index >= _segments.length) return;

    final segment = _segments[index];

    _tooltipData = PieTooltipData(
      index: index,
      value: segment.value,
      percentage: segment.percentage,
      label: segment.label,
      color: segment.color,
      screenPosition: position,
      segmentCenter: segment.centroid,
      dataPoint: segment.dataPoint,
      isExploded: segment.isExploded,
      isSelected: _selectedIndices.contains(index),
    );

    // Ensure tooltip is visible (handles drag-into-segment case)
    _tooltipOpacity = 1.0;

    notifyListeners();
  }

  void _hideTooltipAnimated() {
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();

    if (_tooltipData != null) {
      _tooltipData = null;
      _tooltipOpacity = 0.0;

      // Clear selection when tooltip dismisses (unified lifecycle)
      if (_selectedIndices.isNotEmpty) {
        _clearSelectionInternal();
      }

      notifyListeners();
    }
  }

  /// Clears selection without notifying listeners (internal use).
  void _clearSelectionInternal() {
    if (_selectedIndices.isEmpty) return;

    // Remove exploded state for selected segments (unless permanently exploded)
    if (config.explodeOnSelection) {
      for (final index in _selectedIndices) {
        if (!series.explodeAll &&
            (index >= series.dataPoints.length ||
                !series.dataPoints[index].explode)) {
          _explodedIndices.remove(index);
        }
      }
    }

    _selectedIndices.clear();
    _notifySelectionChanged();
    _recomputeSegments();
  }

  /// Starts auto-clear selection timer (used when tooltip is disabled).
  void _startSelectionClearTimer() {
    _selectionClearTimer?.cancel();
    _selectionClearTimer = Timer(_defaultSelectionClearDelay, () {
      if (_selectedIndices.isNotEmpty && !_isPointerDown) {
        _clearSelectionInternal();
        notifyListeners();
      }
    });
  }

  void _startHideTimer(Duration delay) {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = Timer(delay, () {
      if (!_isPointerDown) {
        _hideTooltipAnimated();
      }
    });
  }

  /// Hides tooltip programmatically.
  void hideTooltip() {
    _hideTooltipAnimated();
  }

  // ===========================================================================
  // SELECTION HELPERS
  // ===========================================================================

  void _notifySelectionChanged() {
    series.onSelectionChanged?.call(_selectedIndices);
    onSelectionChanged?.call(_selectedIndices);
  }

  // ===========================================================================
  // SEGMENT RECOMPUTATION
  // ===========================================================================

  void _recomputeSegments() {
    if (_center == Offset.zero) return;

    _segments = _segmentCache.getOrCompute(
      series: series,
      config: config,
      layoutSize: _size,
      center: _center,
      availableRadius: _availableRadius,
      palette: palette,
      labelConnectorLength: config.labelConnectorLength,
      explodedIndices: _explodedIndices,
      selectedIndices: _selectedIndices,
      hoveredIndex: _hoveredIndex,
    );
  }

  // ===========================================================================
  // PUBLIC API
  // ===========================================================================

  void selectSegment(int index) {
    if (index < 0 || index >= _segments.length) return;

    switch (config.selectionMode) {
      case PieSelectionMode.none:
        return;
      case PieSelectionMode.single:
        _selectedIndices.clear();
        _selectedIndices.add(index);
      case PieSelectionMode.multiple:
        _selectedIndices.add(index);
    }

    _notifySelectionChanged();
    _recomputeSegments();
    notifyListeners();
  }

  void deselectSegment(int index) {
    _selectedIndices.remove(index);
    _notifySelectionChanged();
    _recomputeSegments();
    notifyListeners();
  }

  void clearSelection() {
    _selectedIndices.clear();
    _notifySelectionChanged();
    _recomputeSegments();
    notifyListeners();
  }

  void explodeSegment(int index) {
    if (index < 0 || index >= _segments.length) return;
    _explodedIndices.add(index);
    _recomputeSegments();
    notifyListeners();
  }

  void collapseSegment(int index) {
    if (series.explodeAll) return;
    if (index < series.dataPoints.length && series.dataPoints[index].explode) {
      return;
    }

    _explodedIndices.remove(index);
    _recomputeSegments();
    notifyListeners();
  }

  void toggleExplode(int index) {
    if (_explodedIndices.contains(index)) {
      collapseSegment(index);
    } else {
      explodeSegment(index);
    }
  }

  @override
  void dispose() {
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();
    _selectionClearTimer?.cancel();
    _segmentCache.invalidate();
    super.dispose();
  }

  @override
  bool get isAnimatingZoom => false;

  @override
  bool get isSelectionZoomActive => false;

  @override
  Offset? get selectionCurrent => null;

  @override
  Rect? get selectionRect => null;

  @override
  Offset? get selectionStart => null;

  @override
  double get zoomAnimationProgress => 1.0;

  @override
  void reset() {}

  @override
  void zoomIn() {}

  @override
  void zoomOut() {}
}

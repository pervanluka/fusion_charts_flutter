import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../configuration/fusion_tooltip_configuration.dart';
import '../../data/fusion_data_point.dart';
import 'fusion_cartesian_interactive_state_base.dart';

/// Abstract base class for bar-type chart interactive states.
///
/// Extends [FusionCartesianInteractiveStateBase] with bar-specific behavior:
/// - Rectangle-based hit testing
/// - Bar-specific tooltip positioning
/// - Bar-specific crosshair behavior
///
/// Type parameters:
/// - [TSeries] - The series type (e.g., FusionBarSeries, FusionStackedBarSeries)
/// - [THitResult] - The hit test result type
/// - [TTooltipData] - The tooltip data type (must extend FusionTooltipDataBase)
abstract class FusionBarInteractiveStateBase<
  TSeries,
  THitResult,
  TTooltipData extends FusionTooltipDataBase
>
    extends FusionCartesianInteractiveStateBase<TTooltipData> {
  FusionBarInteractiveStateBase({
    required super.config,
    required super.initialCoordSystem,
    required this.series,
  });

  final List<TSeries> series;

  // ===========================================================================
  // ABSTRACT METHODS - Implement in subclasses
  // ===========================================================================

  /// Performs hit testing at the given screen position.
  /// Returns null if no hit.
  THitResult? performHitTest(Offset screenPosition);

  /// Creates tooltip data from a hit result and shows the tooltip.
  void showTooltipForHitResult(THitResult hitResult, Offset pointerPosition);

  /// Shows crosshair at the given position with optional hit result.
  void showCrosshairAtPosition(Offset position, THitResult? hitResult);

  /// Updates crosshair position during drag.
  void updateCrosshairDuringDrag(Offset position);

  /// Returns the crosshair data point, or null if not applicable.
  @override
  FusionDataPoint? get crosshairPoint;

  // ===========================================================================
  // POINTER EVENT IMPLEMENTATIONS
  // ===========================================================================

  @override
  void onPointerDown(Offset position) {
    if (!config.enableTooltip) return;

    final hitResult = performHitTest(position);
    if (hitResult != null) {
      showTooltipForHitResult(hitResult, position);
    } else {
      hideTooltip();
    }
  }

  @override
  void onPointerMove(Offset position) {
    if (!config.enableTooltip) return;

    final hitResult = performHitTest(position);
    if (hitResult != null) {
      showTooltipForHitResult(hitResult, position);
    } else {
      hideTooltip();
    }
  }

  @override
  void onPointerHover(Offset position) {
    if (!config.enableTooltip) return;

    final hitResult = performHitTest(position);
    if (hitResult != null) {
      showTooltipForHitResult(hitResult, position);
    } else {
      hideTooltip();
    }
  }

  // ===========================================================================
  // GESTURE HANDLERS
  // ===========================================================================

  @override
  void onTapDown(Offset position) {
    final hitResult = performHitTest(position);
    if (hitResult != null && config.enableTooltip) {
      showTooltipForHitResult(hitResult, position);
    }
  }

  @override
  void onLongPressStart(Offset position) {
    final hitResult = performHitTest(position);
    showCrosshairAtPosition(position, hitResult);
  }

  @override
  void onLongPressMoveUpdate(Offset position) {
    if (crosshairPosition != null) {
      updateCrosshairDuringDrag(position);
    }
  }

  // ===========================================================================
  // TOOLTIP MANAGEMENT
  // ===========================================================================

  /// Shows tooltip with the given data.
  /// Called by subclass implementations of showTooltipForHitResult.
  void setBarTooltipData(TTooltipData data) {
    cancelTooltipHideTimer();

    if (config.tooltipBehavior.hapticFeedback && tooltipData == null) {
      HapticFeedback.selectionClick();
    }

    setTooltipData(data);
    notifyListeners();
  }

  @override
  void hideTooltip() {
    if (tooltipData != null) {
      cancelTooltipHideTimer();
      setTooltipData(null);
      notifyListeners();
    }
  }

  // ===========================================================================
  // CROSSHAIR MANAGEMENT
  // ===========================================================================

  /// Sets the crosshair position and notifies listeners.
  void setBarCrosshairPosition(Offset position) {
    cancelCrosshairHideTimer();
    crosshairPosition = position;
    notifyListeners();
  }

  @override
  void hideCrosshair() {
    cancelCrosshairHideTimer();
    if (crosshairPosition != null) {
      crosshairPosition = null;
      onCrosshairHidden();
      notifyListeners();
    }
  }

  /// Called when crosshair is hidden. Override to clear additional state.
  @protected
  void onCrosshairHidden() {}
}

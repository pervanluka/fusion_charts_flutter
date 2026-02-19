import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import '../rendering/fusion_bar_hit_tester.dart';
import 'base/fusion_bar_interactive_state_base.dart';

/// Specialized interactive state for bar charts.
///
/// Unlike the generic interactive state that finds nearest points by distance,
/// this uses rectangle-based hit testing for accurate bar selection.
/// Also supports zoom and pan with configuration-aware constraints.
class FusionBarInteractiveState
    extends
        FusionBarInteractiveStateBase<
          FusionBarSeries,
          BarHitTestResult,
          TooltipRenderData
        > {
  FusionBarInteractiveState({
    required super.config,
    required super.initialCoordSystem,
    required super.series,
    this.enableSideBySideSeriesPlacement = true,
  });

  final bool enableSideBySideSeriesPlacement;
  final FusionBarHitTester _hitTester = const FusionBarHitTester();

  // Crosshair point state (bar charts track this for label display)
  FusionDataPoint? _crosshairPoint;

  @override
  FusionDataPoint? get crosshairPoint => _crosshairPoint;

  // ===========================================================================
  // ABSTRACT METHOD IMPLEMENTATIONS
  // ===========================================================================

  @override
  BarHitTestResult? performHitTest(Offset screenPosition) {
    return _hitTester.hitTest(
      screenPosition: screenPosition,
      allSeries: series,
      coordSystem: coordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );
  }

  @override
  void showTooltipForHitResult(
    BarHitTestResult hitResult,
    Offset pointerPosition,
  ) {
    final tooltipPosition = Offset(
      hitResult.barRect.center.dx,
      hitResult.barRect.top,
    );

    setBarTooltipData(
      TooltipRenderData(
        point: hitResult.point,
        seriesName: hitResult.seriesName,
        seriesColor: hitResult.seriesColor,
        screenPosition: tooltipPosition,
        wasLongPress: false,
        activationTime: DateTime.now(),
      ),
    );
  }

  @override
  void showCrosshairAtPosition(Offset position, BarHitTestResult? hitResult) {
    // For bar charts, create a synthetic point with index as X for correct
    // crosshair positioning. The crosshair layer uses point.x for screen
    // position calculation.
    if (hitResult != null) {
      _crosshairPoint = FusionDataPoint(
        hitResult.pointIndex.toDouble(),
        hitResult.point.y,
        label: hitResult.point.label ?? _formatXLabel(hitResult.point.x),
      );
    } else {
      _crosshairPoint = null;
    }
    setBarCrosshairPosition(position);
  }

  @override
  void updateCrosshairDuringDrag(Offset position) {
    final clampedPosition = clampPositionToCoordSystem(position);

    // Find hit at clamped position
    final hitResult = _hitTester.hitTest(
      screenPosition: clampedPosition,
      allSeries: series,
      coordSystem: coordSystem,
      enableSideBySideSeriesPlacement: enableSideBySideSeriesPlacement,
    );

    if (hitResult != null && config.crosshairBehavior.snapToDataPoint) {
      // Snap to bar center
      final snappedPosition = Offset(
        hitResult.barRect.center.dx,
        hitResult.barRect.top,
      );
      _crosshairPoint = FusionDataPoint(
        hitResult.pointIndex.toDouble(),
        hitResult.point.y,
        label: hitResult.point.label ?? _formatXLabel(hitResult.point.x),
      );
      setBarCrosshairPosition(snappedPosition);
    } else {
      // Follow finger (clamped to coordinate system bounds)
      if (hitResult != null) {
        _crosshairPoint = FusionDataPoint(
          hitResult.pointIndex.toDouble(),
          hitResult.point.y,
          label: hitResult.point.label ?? _formatXLabel(hitResult.point.x),
        );
      } else {
        _crosshairPoint = null;
      }
      setBarCrosshairPosition(clampedPosition);
    }
  }

  @override
  void onCrosshairHidden() {
    _crosshairPoint = null;
  }

  /// Formats X value as label string.
  String _formatXLabel(double x) {
    return x == x.roundToDouble() ? x.round().toString() : x.toString();
  }
}

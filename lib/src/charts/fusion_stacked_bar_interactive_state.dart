import 'package:flutter/material.dart';
import '../configuration/fusion_tooltip_configuration.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_stacked_bar_hit_tester.dart';
import '../series/fusion_stacked_bar_series.dart';
import 'base/fusion_bar_interactive_state_base.dart';

/// Tooltip data specifically for stacked bars.
///
/// Contains all segment information for rich multi-line tooltips.
/// Extends [FusionTooltipDataBase] for compatibility with
/// [FusionInteractiveStateBase].
class StackedTooltipData extends FusionTooltipDataBase {
  const StackedTooltipData({
    required this.categoryLabel,
    required this.segments,
    required this.totalValue,
    required this.screenPosition,
    required this.isStacked100,
    this.hitSegmentIndex = -1,
  }) : super();

  final String? categoryLabel;
  final List<StackedSegmentInfo> segments;
  final double totalValue;
  @override
  final Offset screenPosition;
  final bool isStacked100;
  final int hitSegmentIndex;
}

/// Specialized interactive state for stacked bar charts.
///
/// Shows a multi-line tooltip with all segments in the stack.
/// Supports zoom and pan with configuration-aware constraints.
///
/// Implements [FusionInteractiveStateBase] for compatibility with
/// the base chart widget architecture.
class FusionStackedBarInteractiveState
    extends
        FusionBarInteractiveStateBase<
          FusionStackedBarSeries,
          StackedBarHitTestResult,
          StackedTooltipData
        > {
  FusionStackedBarInteractiveState({
    required super.config,
    required super.initialCoordSystem,
    required super.series,
    required this.isStacked100,
  });

  final bool isStacked100;
  final FusionStackedBarHitTester _hitTester =
      const FusionStackedBarHitTester();

  // Stacked bars don't use crosshair points
  @override
  FusionDataPoint? get crosshairPoint => null;

  // ===========================================================================
  // ABSTRACT METHOD IMPLEMENTATIONS
  // ===========================================================================

  @override
  StackedBarHitTestResult? performHitTest(Offset screenPosition) {
    return _hitTester.hitTest(
      screenPosition: screenPosition,
      allSeries: series,
      coordSystem: coordSystem,
      isStacked100: isStacked100,
    );
  }

  @override
  void showTooltipForHitResult(
    StackedBarHitTestResult hitResult,
    Offset pointerPosition,
  ) {
    // Position tooltip at the top center of the stack
    final tooltipPosition = Offset(
      hitResult.stackRect.center.dx,
      hitResult.stackRect.top,
    );

    setBarTooltipData(
      StackedTooltipData(
        categoryLabel: hitResult.categoryLabel,
        segments: hitResult.segments,
        totalValue: hitResult.totalValue,
        screenPosition: tooltipPosition,
        isStacked100: isStacked100,
        hitSegmentIndex: hitResult.hitSegmentIndex,
      ),
    );
  }

  @override
  void showCrosshairAtPosition(
    Offset position,
    StackedBarHitTestResult? hitResult,
  ) {
    setBarCrosshairPosition(position);
  }

  @override
  void updateCrosshairDuringDrag(Offset position) {
    final clampedPosition = clampPositionToCoordSystem(position);
    setBarCrosshairPosition(clampedPosition);
  }
}

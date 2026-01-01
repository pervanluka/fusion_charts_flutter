import 'package:flutter/material.dart';

import '../core/enums/fusion_pan_edge_behavior.dart';
import '../core/enums/fusion_pan_mode.dart';

@immutable
class FusionPanConfiguration {
  const FusionPanConfiguration({
    this.enabled = false,
    this.panMode = FusionPanMode.both,
    this.enableInertia = true,
    this.inertiaDuration = const Duration(milliseconds: 500),
    this.inertiaDecay = 0.95,
    this.edgeBehavior = FusionPanEdgeBehavior.bounce,
  });

  /// Whether panning is enabled.
  final bool enabled;

  /// Which axes can be panned.
  final FusionPanMode panMode;

  /// Enable inertia/momentum scrolling.
  final bool enableInertia;

  /// Duration of inertia animation.
  final Duration inertiaDuration;

  /// Inertia decay rate (0-1, higher = longer momentum).
  final double inertiaDecay;

  /// Behavior when panning reaches edge.
  final FusionPanEdgeBehavior edgeBehavior;
}

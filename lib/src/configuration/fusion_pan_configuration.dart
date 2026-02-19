import 'package:flutter/material.dart';

import '../core/enums/fusion_pan_edge_behavior.dart';
import '../core/enums/fusion_pan_mode.dart';

@immutable
class FusionPanConfiguration {
  const FusionPanConfiguration({
    this.panMode = FusionPanMode.both,
    this.enableInertia = true,
    this.inertiaDuration = const Duration(milliseconds: 500),
    this.inertiaDecay = 0.95,
    this.edgeBehavior = FusionPanEdgeBehavior.bounce,
  }) : assert(
         inertiaDecay >= 0 && inertiaDecay <= 1,
         'inertiaDecay must be between 0 and 1. Got: $inertiaDecay',
       );

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

  // ==========================================================================
  // CONFIGURATION VALIDATION
  // ==========================================================================

  /// Validates the pan configuration and returns warnings for potentially
  /// confusing or suboptimal combinations.
  ///
  /// Call this method during development to check for configuration issues.
  /// Returns a list of warning messages. An empty list means the configuration
  /// is fully optimal.
  List<String> validateConfiguration() {
    final warnings = <String>[];

    // Check inertia settings when inertia is disabled
    if (!enableInertia) {
      if (inertiaDuration != const Duration(milliseconds: 500)) {
        warnings.add(
          'enableInertia is false but inertiaDuration is set. '
          'Duration will be ignored since inertia is disabled.',
        );
      }
      if (inertiaDecay != 0.95) {
        warnings.add(
          'enableInertia is false but inertiaDecay is set. '
          'Decay will be ignored since inertia is disabled.',
        );
      }
    }

    // Check inertia decay extremes
    if (enableInertia) {
      if (inertiaDecay < 0.5) {
        warnings.add(
          'inertiaDecay ($inertiaDecay) is very low. '
          'Inertia will stop almost immediately.',
        );
      } else if (inertiaDecay > 0.99) {
        warnings.add(
          'inertiaDecay ($inertiaDecay) is very high. '
          'Inertia may feel like it never stops.',
        );
      }
    }

    // Check inertia duration extremes
    if (enableInertia) {
      if (inertiaDuration.inMilliseconds < 100) {
        warnings.add(
          'inertiaDuration is very short (${inertiaDuration.inMilliseconds}ms). '
          'Inertia effect may not be noticeable.',
        );
      } else if (inertiaDuration.inMilliseconds > 2000) {
        warnings.add(
          'inertiaDuration is very long (${inertiaDuration.inMilliseconds}ms). '
          'Scrolling may feel sluggish to stop.',
        );
      }
    }

    return warnings;
  }

  /// Asserts that the configuration is valid for development builds.
  ///
  /// Constructor assertions handle most validation. This method is for
  /// additional runtime checks if needed.
  void assertValid() {
    // All critical validations are in constructor assertions
  }

  /// Returns documentation of all supported configuration combinations.
  static String get configurationGuide => '''
FusionPanConfiguration Guide
=============================

## Pan Mode
- FusionPanMode.both (default): Pan in any direction
- FusionPanMode.horizontal: Only pan horizontally
- FusionPanMode.vertical: Only pan vertically
- FusionPanMode.none: Disable panning

## Inertia (Momentum Scrolling)
- enableInertia: Enable momentum after releasing
- inertiaDuration: How long inertia animation lasts
- inertiaDecay: Rate of slowdown (0-1, higher = longer momentum)

## Edge Behavior
- FusionPanEdgeBehavior.bounce: Rubber band effect at edges
- FusionPanEdgeBehavior.clamp: Hard stop at edges
- FusionPanEdgeBehavior.infinite: Allow panning beyond data

## Recommended Configurations

### Standard Chart
```dart
FusionPanConfiguration(
  panMode: FusionPanMode.both,
  enableInertia: true,
  edgeBehavior: FusionPanEdgeBehavior.bounce,
)
```

### Time Series (Horizontal Only)
```dart
FusionPanConfiguration(
  panMode: FusionPanMode.horizontal,
  enableInertia: true,
  inertiaDecay: 0.92,
)
```

### Precise Analysis (No Inertia)
```dart
FusionPanConfiguration(
  enableInertia: false,
  edgeBehavior: FusionPanEdgeBehavior.clamp,
)
```
''';

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  FusionPanConfiguration copyWith({
    FusionPanMode? panMode,
    bool? enableInertia,
    Duration? inertiaDuration,
    double? inertiaDecay,
    FusionPanEdgeBehavior? edgeBehavior,
  }) {
    return FusionPanConfiguration(
      panMode: panMode ?? this.panMode,
      enableInertia: enableInertia ?? this.enableInertia,
      inertiaDuration: inertiaDuration ?? this.inertiaDuration,
      inertiaDecay: inertiaDecay ?? this.inertiaDecay,
      edgeBehavior: edgeBehavior ?? this.edgeBehavior,
    );
  }
}

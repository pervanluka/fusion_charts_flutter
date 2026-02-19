import 'package:flutter/material.dart';

import '../core/enums/fusion_zoom_mode.dart';

@immutable
class FusionZoomConfiguration {
  const FusionZoomConfiguration({
    this.enablePinchZoom = true,
    this.enableMouseWheelZoom = true,
    this.requireModifierForWheelZoom = true,
    this.enableSelectionZoom = true,
    this.enableDoubleTapZoom = true,
    this.minZoomLevel = 0.5,
    this.maxZoomLevel = 5.0,
    this.zoomSpeed = 1.0,
    this.enableZoomControls = false,
    this.zoomMode = FusionZoomMode.both,
    this.animateZoom = true,
    this.zoomAnimationDuration = const Duration(milliseconds: 300),
    this.zoomAnimationCurve = Curves.easeInOut,
  }) : assert(
         minZoomLevel > 0,
         'minZoomLevel must be positive. Got: $minZoomLevel',
       ),
       assert(
         maxZoomLevel > 0,
         'maxZoomLevel must be positive. Got: $maxZoomLevel',
       ),
       assert(
         maxZoomLevel >= minZoomLevel,
         'maxZoomLevel ($maxZoomLevel) must be >= minZoomLevel ($minZoomLevel)',
       ),
       assert(zoomSpeed > 0, 'zoomSpeed must be positive. Got: $zoomSpeed');

  /// Enable pinch-to-zoom gesture (mobile).
  final bool enablePinchZoom;

  /// Enable mouse wheel zoom (desktop/web).
  final bool enableMouseWheelZoom;

  /// Require Ctrl/Cmd key to be held for mouse wheel zoom.
  ///
  /// When `true` (default), users must hold Ctrl (Windows/Linux) or
  /// Cmd (macOS) while scrolling to zoom. This prevents accidental
  /// zooming when scrolling the page on web/desktop.
  ///
  /// When `false`, scrolling over the chart area will zoom directly
  /// (legacy behavior).
  ///
  /// This setting is recommended to be `true` for web applications
  /// to match standard behavior (Google Maps, Figma, etc).
  final bool requireModifierForWheelZoom;

  /// Enable rectangular selection zoom (Shift + drag).
  ///
  /// When enabled, users can hold Shift and drag to select a
  /// rectangular area to zoom into. Only works on desktop/web
  /// with mouse input.
  final bool enableSelectionZoom;

  /// Enable double-tap to zoom in.
  final bool enableDoubleTapZoom;

  /// Minimum zoom level (0.5 = 50% zoomed out).
  final double minZoomLevel;

  /// Maximum zoom level (5.0 = 5x zoomed in).
  final double maxZoomLevel;

  /// Zoom speed multiplier (higher = faster zoom).
  final double zoomSpeed;

  /// Show zoom in/out buttons overlay.
  final bool enableZoomControls;

  /// Which axes can be zoomed.
  final FusionZoomMode zoomMode;

  /// Animate zoom transitions.
  final bool animateZoom;

  /// Duration of zoom animation.
  final Duration zoomAnimationDuration;

  /// Curve of zoom animation.
  final Curve zoomAnimationCurve;

  // ==========================================================================
  // CONFIGURATION VALIDATION
  // ==========================================================================

  /// Validates the zoom configuration and returns warnings for potentially
  /// confusing or suboptimal combinations.
  ///
  /// Call this method during development to check for configuration issues.
  /// Returns a list of warning messages. An empty list means the configuration
  /// is fully optimal.
  List<String> validateConfiguration() {
    final warnings = <String>[];

    // Check if all zoom methods are disabled
    if (!enablePinchZoom &&
        !enableMouseWheelZoom &&
        !enableSelectionZoom &&
        !enableDoubleTapZoom &&
        !enableZoomControls) {
      warnings.add(
        'All zoom methods are disabled. Users will not be able to zoom. '
        'If this is intentional, consider not using zoom configuration at all.',
      );
    }

    // Check animation settings when animation is disabled
    if (!animateZoom) {
      if (zoomAnimationDuration != const Duration(milliseconds: 300)) {
        warnings.add(
          'animateZoom is false but zoomAnimationDuration is set. '
          'Duration will be ignored since animations are disabled.',
        );
      }
    }

    // Check zoom level range
    if (maxZoomLevel - minZoomLevel < 0.5) {
      warnings.add(
        'Zoom range is very small (${minZoomLevel}x - ${maxZoomLevel}x). '
        'Consider widening the range for better user experience.',
      );
    }

    // Check requireModifierForWheelZoom with enableMouseWheelZoom
    if (!enableMouseWheelZoom && requireModifierForWheelZoom) {
      warnings.add(
        'requireModifierForWheelZoom is set but enableMouseWheelZoom is false. '
        'The modifier setting will be ignored.',
      );
    }

    // Check zoomSpeed extremes
    if (zoomSpeed < 0.1) {
      warnings.add(
        'zoomSpeed ($zoomSpeed) is very low. Zooming will feel sluggish.',
      );
    } else if (zoomSpeed > 5.0) {
      warnings.add(
        'zoomSpeed ($zoomSpeed) is very high. Zooming may feel too sensitive.',
      );
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
FusionZoomConfiguration Guide
==============================

## Zoom Methods
- enablePinchZoom: Pinch-to-zoom gesture (mobile)
- enableMouseWheelZoom: Mouse wheel zoom (desktop/web)
- requireModifierForWheelZoom: Require Ctrl/Cmd for wheel zoom
- enableSelectionZoom: Shift+drag rectangular selection zoom
- enableDoubleTapZoom: Double-tap to zoom in
- enableZoomControls: Show +/- button overlay

## Zoom Levels
- minZoomLevel: Minimum zoom (0.5 = 50% zoomed out)
- maxZoomLevel: Maximum zoom (5.0 = 5x zoomed in)
- zoomSpeed: Zoom speed multiplier

## Zoom Mode
- FusionZoomMode.both: Zoom both X and Y axes
- FusionZoomMode.horizontal: Zoom X axis only
- FusionZoomMode.vertical: Zoom Y axis only

## Animation
- animateZoom: Enable smooth zoom transitions
- zoomAnimationDuration: Duration of zoom animation
- zoomAnimationCurve: Easing curve for animation

## Recommended Configurations

### Standard Interactive Chart
```dart
FusionZoomConfiguration(
  enablePinchZoom: true,
  enableDoubleTapZoom: true,
  minZoomLevel: 0.5,
  maxZoomLevel: 10.0,
)
```

### Financial Time Series
```dart
FusionZoomConfiguration(
  zoomMode: FusionZoomMode.horizontal,
  enableSelectionZoom: true,
  minZoomLevel: 1.0, // Don't zoom out
  maxZoomLevel: 20.0,
)
```

### Desktop with Wheel Zoom
```dart
FusionZoomConfiguration(
  enableMouseWheelZoom: true,
  requireModifierForWheelZoom: false, // Zoom without Ctrl
  zoomSpeed: 1.5,
)
```

### Read-Only Chart (No Zoom)
```dart
FusionZoomConfiguration(
  enablePinchZoom: false,
  enableMouseWheelZoom: false,
  enableSelectionZoom: false,
  enableDoubleTapZoom: false,
)
```
''';

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  FusionZoomConfiguration copyWith({
    bool? enablePinchZoom,
    bool? enableMouseWheelZoom,
    bool? requireModifierForWheelZoom,
    bool? enableSelectionZoom,
    bool? enableDoubleTapZoom,
    double? minZoomLevel,
    double? maxZoomLevel,
    double? zoomSpeed,
    bool? enableZoomControls,
    FusionZoomMode? zoomMode,
    bool? animateZoom,
    Duration? zoomAnimationDuration,
    Curve? zoomAnimationCurve,
  }) {
    return FusionZoomConfiguration(
      enablePinchZoom: enablePinchZoom ?? this.enablePinchZoom,
      enableMouseWheelZoom: enableMouseWheelZoom ?? this.enableMouseWheelZoom,
      requireModifierForWheelZoom:
          requireModifierForWheelZoom ?? this.requireModifierForWheelZoom,
      enableSelectionZoom: enableSelectionZoom ?? this.enableSelectionZoom,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      zoomSpeed: zoomSpeed ?? this.zoomSpeed,
      enableZoomControls: enableZoomControls ?? this.enableZoomControls,
      zoomMode: zoomMode ?? this.zoomMode,
      animateZoom: animateZoom ?? this.animateZoom,
      zoomAnimationDuration:
          zoomAnimationDuration ?? this.zoomAnimationDuration,
      zoomAnimationCurve: zoomAnimationCurve ?? this.zoomAnimationCurve,
    );
  }
}

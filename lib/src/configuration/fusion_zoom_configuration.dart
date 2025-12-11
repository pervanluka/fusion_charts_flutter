import 'package:flutter/material.dart';

import '../core/enums/fusion_zoom_mode.dart';

@immutable
class FusionZoomConfiguration {
  const FusionZoomConfiguration({
    this.enabled = false,
    this.enablePinchZoom = true,
    this.enableMouseWheelZoom = true,
    this.enableSelectionZoom = false,
    this.enableDoubleTapZoom = true,
    this.minZoomLevel = 0.5,
    this.maxZoomLevel = 5.0,
    this.zoomSpeed = 1.0,
    this.enableZoomControls = false,
    this.zoomMode = FusionZoomMode.both,
    this.animateZoom = true,
    this.zoomAnimationDuration = const Duration(milliseconds: 300),
    this.zoomAnimationCurve = Curves.easeInOut,
  });

  /// Whether zoom is enabled globally.
  final bool enabled;

  /// Enable pinch-to-zoom gesture (mobile).
  final bool enablePinchZoom;

  /// Enable mouse wheel zoom (desktop).
  final bool enableMouseWheelZoom;

  /// Enable rectangular selection zoom.
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

  FusionZoomConfiguration copyWith({
    bool? enabled,
    bool? enablePinchZoom,
    bool? enableMouseWheelZoom,
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
      enabled: enabled ?? this.enabled,
      enablePinchZoom: enablePinchZoom ?? this.enablePinchZoom,
      enableMouseWheelZoom: enableMouseWheelZoom ?? this.enableMouseWheelZoom,
      enableSelectionZoom: enableSelectionZoom ?? this.enableSelectionZoom,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      zoomSpeed: zoomSpeed ?? this.zoomSpeed,
      enableZoomControls: enableZoomControls ?? this.enableZoomControls,
      zoomMode: zoomMode ?? this.zoomMode,
      animateZoom: animateZoom ?? this.animateZoom,
      zoomAnimationDuration: zoomAnimationDuration ?? this.zoomAnimationDuration,
      zoomAnimationCurve: zoomAnimationCurve ?? this.zoomAnimationCurve,
    );
  }
}

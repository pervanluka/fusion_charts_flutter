import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Gradient configuration for chart elements.
///
/// Provides rich gradient options for series, areas, and backgrounds.
/// Supports linear, radial, and sweep gradients with multiple stops.
///
@immutable
class FusionGradient {
  /// Creates a gradient configuration.
  const FusionGradient({
    required this.colors,
    this.stops,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.type = FusionGradientType.linear,
    this.center = Alignment.center,
    this.radius = 0.5,
    this.focal,
    this.focalRadius = 0.0,
    this.startAngle = 0.0,
    this.endAngle = math.pi * 2,
    this.tileMode = TileMode.clamp,
  }) : assert(colors.length >= 2, 'At least 2 colors required');

  /// Creates a horizontal linear gradient.
  factory FusionGradient.horizontal({
    required List<Color> colors,
    List<double>? stops,
  }) {
    return FusionGradient(
      colors: colors,
      stops: stops,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  // ==========================================================================
  // FACTORY CONSTRUCTORS
  // ==========================================================================

  /// Creates a simple vertical linear gradient.
  ///
  /// Most common gradient type - colors from top to bottom.
  factory FusionGradient.vertical({
    required List<Color> colors,
    List<double>? stops,
  }) {
    return FusionGradient(
      colors: colors,
      stops: stops,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// Creates a diagonal linear gradient.
  factory FusionGradient.diagonal({
    required List<Color> colors,
    List<double>? stops,
  }) {
    return FusionGradient(
      colors: colors,
      stops: stops,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Creates a radial gradient from center.
  factory FusionGradient.radial({
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
  }) {
    return FusionGradient(
      colors: colors,
      stops: stops,
      type: FusionGradientType.radial,
      center: center,
      radius: radius,
    );
  }

  /// Creates a sweep (angular) gradient.
  factory FusionGradient.sweep({
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0.0,
    double endAngle = math.pi * 2,
  }) {
    return FusionGradient(
      colors: colors,
      stops: stops,
      type: FusionGradientType.sweep,
      center: center,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  /// Colors in the gradient.
  ///
  /// Must have at least 2 colors.
  final List<Color> colors;

  /// Optional stops for color positions.
  ///
  /// If provided, must have same length as [colors].
  /// Values should be between 0.0 and 1.0.
  ///
  /// Example:
  /// ```dart
  /// colors: [Colors.red, Colors.yellow, Colors.green]
  /// stops: [0.0, 0.3, 1.0]  // Red at start, yellow at 30%, green at end
  /// ```
  final List<double>? stops;

  /// Start alignment for linear gradient.
  final AlignmentGeometry begin;

  /// End alignment for linear gradient.
  final AlignmentGeometry end;

  /// Type of gradient.
  final FusionGradientType type;

  /// Center point for radial/sweep gradients.
  final AlignmentGeometry center;

  /// Radius for radial gradient (0.0 to 1.0).
  final double radius;

  /// Focal point for radial gradient.
  final AlignmentGeometry? focal;

  /// Focal radius for radial gradient.
  final double focalRadius;

  /// Start angle for sweep gradient (radians).
  final double startAngle;

  /// End angle for sweep gradient (radians).
  final double endAngle;

  /// How to tile the gradient outside bounds.
  final TileMode tileMode;

  // ==========================================================================
  // PRESET GRADIENTS
  // ==========================================================================

  static final fusionDefault = FusionGradient.vertical(
    colors: [const Color(0xFF6C63FF), const Color(0xFF4CAF50)],
  );

  /// Blue ocean gradient.
  static final ocean = FusionGradient.vertical(
    colors: [const Color(0xFF2E3192), const Color(0xFF1BFFFF)],
  );

  /// Sunset gradient.
  static final sunset = FusionGradient.vertical(
    colors: [const Color(0xFFFF512F), const Color(0xFFDD2476)],
  );

  /// Forest gradient.
  static final forest = FusionGradient.vertical(
    colors: [const Color(0xFF134E5E), const Color(0xFF71B280)],
  );

  /// Fire gradient.
  static final fire = FusionGradient.vertical(
    colors: [const Color(0xFFf12711), const Color(0xFFf5af19)],
  );

  /// Purple dream gradient.
  static final purpleDream = FusionGradient.vertical(
    colors: [const Color(0xFFc471f5), const Color(0xFFfa71cd)],
  );

  // ==========================================================================
  // CONVERSION METHODS
  // ==========================================================================

  /// Converts to Flutter's LinearGradient.
  LinearGradient toLinearGradient() {
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
      tileMode: tileMode,
    );
  }

  /// Converts to Flutter's RadialGradient.
  RadialGradient toRadialGradient() {
    return RadialGradient(
      colors: colors,
      stops: stops,
      center: center,
      radius: radius,
      focal: focal,
      focalRadius: focalRadius,
      tileMode: tileMode,
    );
  }

  /// Converts to Flutter's SweepGradient.
  SweepGradient toSweepGradient() {
    return SweepGradient(
      colors: colors,
      stops: stops,
      center: center,
      startAngle: startAngle,
      endAngle: endAngle,
      tileMode: tileMode,
    );
  }

  /// Converts to appropriate Flutter gradient based on type.
  Gradient toGradient() {
    switch (type) {
      case FusionGradientType.linear:
        return toLinearGradient();
      case FusionGradientType.radial:
        return toRadialGradient();
      case FusionGradientType.sweep:
        return toSweepGradient();
    }
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionGradient copyWith({
    List<Color>? colors,
    List<double>? stops,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    FusionGradientType? type,
    AlignmentGeometry? center,
    double? radius,
    AlignmentGeometry? focal,
    double? focalRadius,
    double? startAngle,
    double? endAngle,
    TileMode? tileMode,
  }) {
    return FusionGradient(
      colors: colors ?? this.colors,
      stops: stops ?? this.stops,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      type: type ?? this.type,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      focal: focal ?? this.focal,
      focalRadius: focalRadius ?? this.focalRadius,
      startAngle: startAngle ?? this.startAngle,
      endAngle: endAngle ?? this.endAngle,
      tileMode: tileMode ?? this.tileMode,
    );
  }

  /// Creates gradient with adjusted opacity.
  FusionGradient withOpacity(double opacity) {
    return copyWith(
      colors: colors.map((c) => c.withValues(alpha: opacity)).toList(),
    );
  }

  /// Reverses the gradient direction.
  FusionGradient reversed() {
    return copyWith(
      colors: colors.reversed.toList(),
      stops: stops?.reversed.toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionGradient &&
        listEquals(other.colors, colors) &&
        listEquals(other.stops, stops) &&
        other.begin == begin &&
        other.end == end &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(colors),
    Object.hashAll(stops ?? []),
    begin,
    end,
    type,
  );
}

/// Type of gradient.
enum FusionGradientType {
  /// Linear gradient (straight line).
  linear,

  /// Radial gradient (circular).
  radial,

  /// Sweep gradient (angular/conical).
  sweep,
}

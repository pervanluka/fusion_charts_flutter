import 'package:flutter/material.dart';

/// Orchestrates multiple staggered animations for chart elements.
///
/// **Architecture:**
/// ```
/// Orchestrator
///   ├─> Series Animation (0.0 - 0.7)
///   ├─> Marker Animation (0.5 - 0.9)
///   └─> Label Animation (0.7 - 1.0)
/// ```
///
/// Each element animates in sequence with overlap for smooth transitions.
///
/// ## Example
///
/// ```dart
/// class MyChartState extends State<MyChart> with SingleTickerProviderStateMixin {
///   late FusionAnimationOrchestrator _orchestrator;
///
///   @override
///   void initState() {
///     super.initState();
///     _orchestrator = FusionAnimationOrchestrator(
///       vsync: this,
///       duration: Duration(milliseconds: 1500),
///     );
///     _orchestrator.forward();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return AnimatedBuilder(
///       animation: _orchestrator.controller,
///       builder: (context, child) {
///         return CustomPaint(
///           painter: MyChartPainter(
///             seriesProgress: _orchestrator.seriesAnimation.value,
///             markerProgress: _orchestrator.markerAnimation.value,
///             labelProgress: _orchestrator.labelAnimation.value,
///           ),
///         );
///       },
///     );
///   }
/// }
/// ```
class FusionAnimationOrchestrator {
  FusionAnimationOrchestrator({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1500),
    Curve curve = Curves.easeInOutCubic,
  }) : controller = AnimationController(duration: duration, vsync: vsync) {
    // Series animation: 0.0 - 0.7 (first 70% of timeline)
    seriesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.7, curve: curve),
      ),
    );

    // Marker animation: 0.5 - 0.9 (overlaps with series)
    markerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.5, 0.9, curve: Curves.elasticOut),
      ),
    );

    // Label animation: 0.7 - 1.0 (final 30%)
    labelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Grid animation: 0.0 - 0.3 (first, quick)
    gridAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Axis animation: 0.2 - 0.5 (early)
    axisAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  /// Main animation controller.
  final AnimationController controller;

  /// Animation for series (lines, bars, areas).
  late final Animation<double> seriesAnimation;

  /// Animation for markers.
  late final Animation<double> markerAnimation;

  /// Animation for data labels.
  late final Animation<double> labelAnimation;

  /// Animation for grid lines.
  late final Animation<double> gridAnimation;

  /// Animation for axes.
  late final Animation<double> axisAnimation;

  // ==========================================================================
  // CONTROL METHODS
  // ==========================================================================

  /// Starts the animation forward.
  TickerFuture forward({double? from}) => controller.forward(from: from);

  /// Reverses the animation.
  TickerFuture reverse({double? from}) => controller.reverse(from: from);

  /// Resets the animation to beginning.
  void reset() => controller.reset();

  /// Stops the animation.
  void stop() => controller.stop();

  /// Animates to a specific value.
  TickerFuture animateTo(double target, {Duration? duration, Curve curve = Curves.linear}) {
    return controller.animateTo(target, duration: duration, curve: curve);
  }

  // ==========================================================================
  // STATE QUERIES
  // ==========================================================================

  /// Whether animation is currently running.
  bool get isAnimating => controller.isAnimating;

  /// Whether animation is completed.
  bool get isCompleted => controller.isCompleted;

  /// Whether animation is dismissed.
  bool get isDismissed => controller.isDismissed;

  /// Current overall progress (0.0 - 1.0).
  double get value => controller.value;

  // ==========================================================================
  // CALLBACKS
  // ==========================================================================

  /// Adds a listener that's called whenever animation value changes.
  void addListener(VoidCallback listener) => controller.addListener(listener);

  /// Removes a listener.
  void removeListener(VoidCallback listener) => controller.removeListener(listener);

  /// Adds a status listener.
  void addStatusListener(AnimationStatusListener listener) {
    controller.addStatusListener(listener);
  }

  /// Removes a status listener.
  void removeStatusListener(AnimationStatusListener listener) {
    controller.removeStatusListener(listener);
  }

  // ==========================================================================
  // ELEMENT-SPECIFIC PROGRESS
  // ==========================================================================

  /// Gets current series animation progress.
  double get seriesProgress => seriesAnimation.value;

  /// Gets current marker animation progress.
  double get markerProgress => markerAnimation.value;

  /// Gets current label animation progress.
  double get labelProgress => labelAnimation.value;

  /// Gets current grid animation progress.
  double get gridProgress => gridAnimation.value;

  /// Gets current axis animation progress.
  double get axisProgress => axisAnimation.value;

  // ==========================================================================
  // ADVANCED ANIMATION CONTROLS
  // ==========================================================================

  /// Repeats the animation.
  TickerFuture repeat({double? min, double? max, bool reverse = false, Duration? period}) {
    return controller.repeat(min: min, max: max, reverse: reverse, period: period);
  }

  /// Animates with spring physics.
  TickerFuture fling({double velocity = 1.0}) {
    return controller.fling(velocity: velocity);
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  /// Disposes the animation controller.
  void dispose() {
    controller.dispose();
  }

  @override
  String toString() {
    return 'FusionAnimationOrchestrator('
        'progress: ${(value * 100).toStringAsFixed(1)}%, '
        'isAnimating: $isAnimating'
        ')';
  }
}

// ==========================================================================
// ANIMATION PRESETS
// ==========================================================================

/// Preset animation configurations.
class FusionAnimationPresets {
  FusionAnimationPresets._();

  /// Fast animation (750ms).
  static Duration get fast => const Duration(milliseconds: 750);

  /// Normal animation (1500ms)
  static Duration get normal => const Duration(milliseconds: 1500);

  /// Slow animation (2500ms).
  static Duration get slow => const Duration(milliseconds: 2500);

  /// Elastic bounce effect.
  static Curve get elastic => Curves.elasticOut;

  /// Smooth cubic easing
  static Curve get smooth => Curves.easeInOutCubic;

  /// Fast start, slow end.
  static Curve get decelerate => Curves.decelerate;

  /// Slow start, fast end.
  static Curve get accelerate => Curves.easeIn;

  /// Material Design standard.
  static Curve get material => Curves.fastOutSlowIn;
}

// ==========================================================================
// STAGGER ANIMATION BUILDER
// ==========================================================================

/// Builder for creating custom staggered animations.
///
/// ## Example
///
/// ```dart
/// final builder = FusionStaggerAnimationBuilder(controller)
///   .addAnimation('fadeIn', 0.0, 0.3, Curves.easeIn)
///   .addAnimation('slideIn', 0.2, 0.6, Curves.easeOut)
///   .addAnimation('scale', 0.5, 1.0, Curves.elasticOut);
///
/// final animations = builder.build();
///
/// // Use in rendering
/// final fadeProgress = animations['fadeIn']!.value;
/// ```
class FusionStaggerAnimationBuilder {
  FusionStaggerAnimationBuilder(this.controller);

  final AnimationController controller;
  final Map<String, _AnimationSpec> _specs = {};

  /// Adds an animation to the stagger.
  FusionStaggerAnimationBuilder addAnimation(
    String name,
    double startInterval,
    double endInterval,
    Curve curve,
  ) {
    assert(startInterval >= 0.0 && startInterval <= 1.0);
    assert(endInterval >= 0.0 && endInterval <= 1.0);
    assert(startInterval < endInterval);

    _specs[name] = _AnimationSpec(
      startInterval: startInterval,
      endInterval: endInterval,
      curve: curve,
    );

    return this;
  }

  /// Builds the animations.
  Map<String, Animation<double>> build() {
    final animations = <String, Animation<double>>{};

    for (final entry in _specs.entries) {
      final spec = entry.value;

      animations[entry.key] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(spec.startInterval, spec.endInterval, curve: spec.curve),
        ),
      );
    }

    return animations;
  }
}

class _AnimationSpec {
  const _AnimationSpec({
    required this.startInterval,
    required this.endInterval,
    required this.curve,
  });

  final double startInterval;
  final double endInterval;
  final Curve curve;
}

// ==========================================================================
// SERIES-SPECIFIC ANIMATION
// ==========================================================================

/// Animation configuration for a single series.
///
/// Allows per-series animation customization.
class FusionSeriesAnimationConfig {
  const FusionSeriesAnimationConfig({
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOutCubic,
    this.animationType = FusionSeriesAnimationType.default_,
  });

  /// Delay before this series starts animating.
  final Duration delay;

  /// Duration of this series animation.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Type of animation effect.
  final FusionSeriesAnimationType animationType;
}

/// Types of series animation effects.
enum FusionSeriesAnimationType {
  /// Default: animate from left to right.
  default_,

  /// Fade in.
  fadeIn,

  /// Scale up from center.
  scaleUp,

  /// Grow from bottom.
  growFromBottom,

  /// Draw path progressively.
  drawPath,
}

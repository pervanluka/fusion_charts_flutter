import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/rendering/animation/fusion_animation_orchestrator.dart';

void main() {
  // ===========================================================================
  // FUSION ANIMATION ORCHESTRATOR - CONSTRUCTION
  // ===========================================================================
  group('FusionAnimationOrchestrator - Construction', () {
    testWidgets('creates with default values', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.controller, isNotNull);
      expect(
        orchestrator.controller.duration,
        const Duration(milliseconds: 1500),
      );
      expect(orchestrator.seriesAnimation, isNotNull);
      expect(orchestrator.markerAnimation, isNotNull);
      expect(orchestrator.labelAnimation, isNotNull);
      expect(orchestrator.gridAnimation, isNotNull);
      expect(orchestrator.axisAnimation, isNotNull);

      orchestrator.dispose();
    });

    testWidgets('creates with custom duration', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 2000),
              );
            },
          ),
        ),
      );

      expect(
        orchestrator.controller.duration,
        const Duration(milliseconds: 2000),
      );

      orchestrator.dispose();
    });

    testWidgets('creates with custom curve', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                curve: Curves.bounceOut,
              );
            },
          ),
        ),
      );

      expect(orchestrator.controller, isNotNull);

      orchestrator.dispose();
    });
  });

  // ===========================================================================
  // STATE QUERIES
  // ===========================================================================
  group('FusionAnimationOrchestrator - State Queries', () {
    testWidgets('isAnimating returns false when not started', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.isAnimating, isFalse);

      orchestrator.dispose();
    });

    testWidgets('isDismissed returns true initially', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.isDismissed, isTrue);

      orchestrator.dispose();
    });

    testWidgets('isCompleted returns false initially', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.isCompleted, isFalse);

      orchestrator.dispose();
    });

    testWidgets('value returns 0 initially', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.value, 0.0);

      orchestrator.dispose();
    });
  });

  // ===========================================================================
  // CONTROL METHODS
  // ===========================================================================
  group('FusionAnimationOrchestrator - Control Methods', () {
    testWidgets('forward starts animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.forward());
      await tester.pump(const Duration(milliseconds: 10));

      expect(orchestrator.isAnimating, isTrue);

      orchestrator.dispose();
    });

    testWidgets('forward completes animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.forward());
      await tester.pumpAndSettle();

      expect(orchestrator.isCompleted, isTrue);
      expect(orchestrator.value, 1.0);

      orchestrator.dispose();
    });

    testWidgets('forward from custom start', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.forward(from: 0.5));
      await tester.pump();

      expect(orchestrator.value, 0.5);

      orchestrator.dispose();
    });

    testWidgets('reverse reverses animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      orchestrator.controller.value = 1.0;
      unawaited(orchestrator.reverse());
      await tester.pumpAndSettle();

      expect(orchestrator.isDismissed, isTrue);
      expect(orchestrator.value, 0.0);

      orchestrator.dispose();
    });

    testWidgets('reset resets animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      orchestrator.controller.value = 0.5;
      orchestrator.reset();

      expect(orchestrator.value, 0.0);
      expect(orchestrator.isDismissed, isTrue);

      orchestrator.dispose();
    });

    testWidgets('stop stops animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 1000),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.forward());
      await tester.pump(const Duration(milliseconds: 100));
      orchestrator.stop();

      final stoppedValue = orchestrator.value;
      await tester.pump(const Duration(milliseconds: 100));

      expect(orchestrator.value, stoppedValue);
      expect(orchestrator.isAnimating, isFalse);

      orchestrator.dispose();
    });

    testWidgets('animateTo animates to specific value', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.animateTo(0.5));
      await tester.pumpAndSettle();

      expect(orchestrator.value, 0.5);

      orchestrator.dispose();
    });
  });

  // ===========================================================================
  // ELEMENT-SPECIFIC PROGRESS
  // ===========================================================================
  group('FusionAnimationOrchestrator - Element Progress', () {
    testWidgets('seriesProgress starts at 0', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.seriesProgress, 0.0);

      orchestrator.dispose();
    });

    testWidgets('markerProgress starts at 0', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.markerProgress, 0.0);

      orchestrator.dispose();
    });

    testWidgets('labelProgress starts at 0', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.labelProgress, 0.0);

      orchestrator.dispose();
    });

    testWidgets('gridProgress starts at 0', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.gridProgress, 0.0);

      orchestrator.dispose();
    });

    testWidgets('axisProgress starts at 0', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      expect(orchestrator.axisProgress, 0.0);

      orchestrator.dispose();
    });

    testWidgets('element progress updates during animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.forward());
      await tester.pumpAndSettle();

      // After animation completes
      expect(orchestrator.seriesProgress, 1.0);
      expect(orchestrator.markerProgress, 1.0);
      expect(orchestrator.labelProgress, 1.0);
      expect(orchestrator.gridProgress, 1.0);
      expect(orchestrator.axisProgress, 1.0);

      orchestrator.dispose();
    });
  });

  // ===========================================================================
  // CALLBACKS
  // ===========================================================================
  group('FusionAnimationOrchestrator - Callbacks', () {
    testWidgets('addListener is called during animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      orchestrator.addListener(() => callCount++);
      unawaited(orchestrator.forward());
      await tester.pumpAndSettle();

      expect(callCount, greaterThan(0));

      orchestrator.dispose();
    });

    testWidgets('removeListener stops callbacks', (tester) async {
      late FusionAnimationOrchestrator orchestrator;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      void listener() => callCount++;
      orchestrator.addListener(listener);
      orchestrator.removeListener(listener);
      unawaited(orchestrator.forward());
      await tester.pumpAndSettle();

      expect(callCount, 0);

      orchestrator.dispose();
    });

    testWidgets('addStatusListener is called on status change', (tester) async {
      late FusionAnimationOrchestrator orchestrator;
      final statuses = <AnimationStatus>[];

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      orchestrator.addStatusListener(statuses.add);
      unawaited(orchestrator.forward());
      await tester.pumpAndSettle();

      expect(statuses, contains(AnimationStatus.forward));
      expect(statuses, contains(AnimationStatus.completed));

      orchestrator.dispose();
    });

    testWidgets('removeStatusListener stops status callbacks', (tester) async {
      late FusionAnimationOrchestrator orchestrator;
      final statuses = <AnimationStatus>[];

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      void listener(AnimationStatus status) => statuses.add(status);
      orchestrator.addStatusListener(listener);
      orchestrator.removeStatusListener(listener);
      unawaited(orchestrator.forward());
      await tester.pumpAndSettle();

      expect(statuses, isEmpty);

      orchestrator.dispose();
    });
  });

  // ===========================================================================
  // ADVANCED CONTROLS
  // ===========================================================================
  group('FusionAnimationOrchestrator - Advanced Controls', () {
    testWidgets('repeat creates repeating animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.repeat());
      await tester.pump(const Duration(milliseconds: 150));

      expect(orchestrator.isAnimating, isTrue);

      orchestrator.stop();
      orchestrator.dispose();
    });

    testWidgets('repeat with reverse', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.repeat(reverse: true));
      await tester.pump(const Duration(milliseconds: 150));

      expect(orchestrator.isAnimating, isTrue);

      orchestrator.stop();
      orchestrator.dispose();
    });

    testWidgets('fling runs spring animation', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      unawaited(orchestrator.fling());
      await tester.pump(const Duration(milliseconds: 10));

      expect(orchestrator.isAnimating, isTrue);

      await tester.pumpAndSettle();
      orchestrator.dispose();
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================
  group('FusionAnimationOrchestrator - toString', () {
    testWidgets('toString returns formatted string', (tester) async {
      late FusionAnimationOrchestrator orchestrator;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              orchestrator = FusionAnimationOrchestrator(vsync: vsync);
            },
          ),
        ),
      );

      final str = orchestrator.toString();

      expect(str, contains('FusionAnimationOrchestrator'));
      expect(str, contains('progress'));
      expect(str, contains('isAnimating'));

      orchestrator.dispose();
    });
  });

  // ===========================================================================
  // ANIMATION PRESETS
  // ===========================================================================
  group('FusionAnimationPresets', () {
    test('fast returns 750ms duration', () {
      expect(FusionAnimationPresets.fast, const Duration(milliseconds: 750));
    });

    test('normal returns 1500ms duration', () {
      expect(FusionAnimationPresets.normal, const Duration(milliseconds: 1500));
    });

    test('slow returns 2500ms duration', () {
      expect(FusionAnimationPresets.slow, const Duration(milliseconds: 2500));
    });

    test('elastic returns elasticOut curve', () {
      expect(FusionAnimationPresets.elastic, Curves.elasticOut);
    });

    test('smooth returns easeInOutCubic curve', () {
      expect(FusionAnimationPresets.smooth, Curves.easeInOutCubic);
    });

    test('decelerate returns decelerate curve', () {
      expect(FusionAnimationPresets.decelerate, Curves.decelerate);
    });

    test('accelerate returns easeIn curve', () {
      expect(FusionAnimationPresets.accelerate, Curves.easeIn);
    });

    test('material returns fastOutSlowIn curve', () {
      expect(FusionAnimationPresets.material, Curves.fastOutSlowIn);
    });
  });

  // ===========================================================================
  // STAGGER ANIMATION BUILDER
  // ===========================================================================
  group('FusionStaggerAnimationBuilder', () {
    testWidgets('creates animations correctly', (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              controller = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      final builder = FusionStaggerAnimationBuilder(controller)
          .addAnimation('fadeIn', 0.0, 0.3, Curves.easeIn)
          .addAnimation('slideIn', 0.2, 0.6, Curves.easeOut)
          .addAnimation('scale', 0.5, 1.0, Curves.elasticOut);

      final animations = builder.build();

      expect(animations, hasLength(3));
      expect(animations['fadeIn'], isNotNull);
      expect(animations['slideIn'], isNotNull);
      expect(animations['scale'], isNotNull);

      controller.dispose();
    });

    testWidgets('animations have correct initial values', (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              controller = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      final builder = FusionStaggerAnimationBuilder(
        controller,
      ).addAnimation('fadeIn', 0.0, 0.5, Curves.linear);

      final animations = builder.build();

      expect(animations['fadeIn']!.value, 0.0);

      controller.dispose();
    });

    testWidgets('animations update during controller animation', (
      tester,
    ) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: _OrchestratorTestWidget(
            onBuild: (vsync) {
              controller = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ),
      );

      final builder = FusionStaggerAnimationBuilder(
        controller,
      ).addAnimation('test', 0.0, 1.0, Curves.linear);

      final animations = builder.build();

      unawaited(controller.forward());
      await tester.pumpAndSettle();

      expect(animations['test']!.value, 1.0);

      controller.dispose();
    });
  });

  // ===========================================================================
  // SERIES ANIMATION CONFIG
  // ===========================================================================
  group('FusionSeriesAnimationConfig', () {
    test('creates with default values', () {
      const config = FusionSeriesAnimationConfig();

      expect(config.delay, Duration.zero);
      expect(config.duration, const Duration(milliseconds: 1000));
      expect(config.curve, Curves.easeInOutCubic);
      expect(config.animationType, FusionSeriesAnimationType.default_);
    });

    test('creates with custom values', () {
      const config = FusionSeriesAnimationConfig(
        delay: Duration(milliseconds: 500),
        duration: Duration(milliseconds: 2000),
        curve: Curves.bounceOut,
        animationType: FusionSeriesAnimationType.fadeIn,
      );

      expect(config.delay, const Duration(milliseconds: 500));
      expect(config.duration, const Duration(milliseconds: 2000));
      expect(config.curve, Curves.bounceOut);
      expect(config.animationType, FusionSeriesAnimationType.fadeIn);
    });
  });

  // ===========================================================================
  // SERIES ANIMATION TYPE ENUM
  // ===========================================================================
  group('FusionSeriesAnimationType', () {
    test('has all expected values', () {
      expect(
        FusionSeriesAnimationType.values,
        containsAll([
          FusionSeriesAnimationType.default_,
          FusionSeriesAnimationType.fadeIn,
          FusionSeriesAnimationType.scaleUp,
          FusionSeriesAnimationType.growFromBottom,
          FusionSeriesAnimationType.drawPath,
        ]),
      );
    });

    test('has 5 values', () {
      expect(FusionSeriesAnimationType.values.length, 5);
    });
  });
}

/// Test widget that provides a TickerProvider
class _OrchestratorTestWidget extends StatefulWidget {
  const _OrchestratorTestWidget({required this.onBuild});

  final void Function(TickerProvider vsync) onBuild;

  @override
  State<_OrchestratorTestWidget> createState() =>
      _OrchestratorTestWidgetState();
}

class _OrchestratorTestWidgetState extends State<_OrchestratorTestWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.onBuild(this);
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

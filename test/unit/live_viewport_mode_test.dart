import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/live/live_viewport_mode.dart';

void main() {
  // ===========================================================================
  // AUTO SCROLL VIEWPORT
  // ===========================================================================
  group('AutoScrollViewport', () {
    test('creates with required visibleDuration', () {
      const mode = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 60),
      );

      expect(mode, isA<AutoScrollViewport>());
      const autoScroll = mode as AutoScrollViewport;
      expect(autoScroll.visibleDuration, const Duration(seconds: 60));
      expect(autoScroll.leadingPadding, Duration.zero);
      expect(autoScroll.trailingPadding, Duration.zero);
      expect(autoScroll.animationCurve, Curves.linear);
    });

    test('creates with all parameters', () {
      const mode = LiveViewportMode.autoScroll(
        visibleDuration: Duration(minutes: 5),
        leadingPadding: Duration(seconds: 10),
        trailingPadding: Duration(seconds: 5),
        animationCurve: Curves.easeInOut,
      );

      const autoScroll = mode as AutoScrollViewport;
      expect(autoScroll.visibleDuration, const Duration(minutes: 5));
      expect(autoScroll.leadingPadding, const Duration(seconds: 10));
      expect(autoScroll.trailingPadding, const Duration(seconds: 5));
      expect(autoScroll.animationCurve, Curves.easeInOut);
    });

    test('equal modes are equal', () {
      const mode1 = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 60),
        leadingPadding: Duration(seconds: 5),
      );
      const mode2 = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 60),
        leadingPadding: Duration(seconds: 5),
      );

      expect(mode1, equals(mode2));
      expect(mode1.hashCode, equals(mode2.hashCode));
    });

    test('different modes are not equal', () {
      const mode1 = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 60),
      );
      const mode2 = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 30),
      );

      expect(mode1, isNot(equals(mode2)));
    });

    test('identical modes are equal', () {
      const mode = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 60),
      );
      expect(mode == mode, isTrue);
    });
  });

  // ===========================================================================
  // AUTO SCROLL POINTS VIEWPORT
  // ===========================================================================
  group('AutoScrollPointsViewport', () {
    test('creates with required visiblePoints', () {
      const mode = LiveViewportMode.autoScrollPoints(visiblePoints: 100);

      expect(mode, isA<AutoScrollPointsViewport>());
      const pointsViewport = mode as AutoScrollPointsViewport;
      expect(pointsViewport.visiblePoints, 100);
      expect(pointsViewport.leadingPoints, 0);
      expect(pointsViewport.animationCurve, Curves.linear);
    });

    test('creates with all parameters', () {
      const mode = LiveViewportMode.autoScrollPoints(
        visiblePoints: 50,
        leadingPoints: 10,
        animationCurve: Curves.bounceOut,
      );

      const pointsViewport = mode as AutoScrollPointsViewport;
      expect(pointsViewport.visiblePoints, 50);
      expect(pointsViewport.leadingPoints, 10);
      expect(pointsViewport.animationCurve, Curves.bounceOut);
    });

    test('throws assertion for zero visiblePoints', () {
      expect(
        () => LiveViewportMode.autoScrollPoints(visiblePoints: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion for negative visiblePoints', () {
      expect(
        () => LiveViewportMode.autoScrollPoints(visiblePoints: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('equal modes are equal', () {
      const mode1 = LiveViewportMode.autoScrollPoints(
        visiblePoints: 100,
        leadingPoints: 5,
      );
      const mode2 = LiveViewportMode.autoScrollPoints(
        visiblePoints: 100,
        leadingPoints: 5,
      );

      expect(mode1, equals(mode2));
      expect(mode1.hashCode, equals(mode2.hashCode));
    });

    test('different modes are not equal', () {
      const mode1 = LiveViewportMode.autoScrollPoints(visiblePoints: 100);
      const mode2 = LiveViewportMode.autoScrollPoints(visiblePoints: 50);

      expect(mode1, isNot(equals(mode2)));
    });
  });

  // ===========================================================================
  // FIXED VIEWPORT
  // ===========================================================================
  group('FixedViewport', () {
    test('creates without initial range', () {
      const mode = LiveViewportMode.fixed();

      expect(mode, isA<FixedViewport>());
      const fixed = mode as FixedViewport;
      expect(fixed.initialRange, isNull);
    });

    test('creates with initial range', () {
      const mode = LiveViewportMode.fixed(initialRange: (0.0, 100.0));

      const fixed = mode as FixedViewport;
      expect(fixed.initialRange, (0.0, 100.0));
      expect(fixed.initialRange!.$1, 0.0);
      expect(fixed.initialRange!.$2, 100.0);
    });

    test('equal modes are equal', () {
      const mode1 = LiveViewportMode.fixed(initialRange: (0.0, 100.0));
      const mode2 = LiveViewportMode.fixed(initialRange: (0.0, 100.0));

      expect(mode1, equals(mode2));
      expect(mode1.hashCode, equals(mode2.hashCode));
    });

    test('modes with different ranges are not equal', () {
      const mode1 = LiveViewportMode.fixed(initialRange: (0.0, 100.0));
      const mode2 = LiveViewportMode.fixed(initialRange: (0.0, 50.0));

      expect(mode1, isNot(equals(mode2)));
    });

    test('mode with range is not equal to mode without range', () {
      const mode1 = LiveViewportMode.fixed(initialRange: (0.0, 100.0));
      const mode2 = LiveViewportMode.fixed();

      expect(mode1, isNot(equals(mode2)));
    });
  });

  // ===========================================================================
  // AUTO SCROLL UNTIL INTERACTION VIEWPORT
  // ===========================================================================
  group('AutoScrollUntilInteractionViewport', () {
    test('creates with required visibleDuration', () {
      const mode = LiveViewportMode.autoScrollUntilInteraction(
        visibleDuration: Duration(minutes: 1),
      );

      expect(mode, isA<AutoScrollUntilInteractionViewport>());
      const interactionMode = mode as AutoScrollUntilInteractionViewport;
      expect(interactionMode.visibleDuration, const Duration(minutes: 1));
      expect(interactionMode.leadingPadding, Duration.zero);
      expect(interactionMode.interactionTimeout, isNull);
      expect(interactionMode.animationCurve, Curves.linear);
    });

    test('creates with all parameters', () {
      const mode = LiveViewportMode.autoScrollUntilInteraction(
        visibleDuration: Duration(seconds: 30),
        leadingPadding: Duration(seconds: 5),
        interactionTimeout: Duration(seconds: 10),
        animationCurve: Curves.fastOutSlowIn,
      );

      const interactionMode = mode as AutoScrollUntilInteractionViewport;
      expect(interactionMode.visibleDuration, const Duration(seconds: 30));
      expect(interactionMode.leadingPadding, const Duration(seconds: 5));
      expect(interactionMode.interactionTimeout, const Duration(seconds: 10));
      expect(interactionMode.animationCurve, Curves.fastOutSlowIn);
    });

    test('equal modes are equal', () {
      const mode1 = LiveViewportMode.autoScrollUntilInteraction(
        visibleDuration: Duration(seconds: 60),
        interactionTimeout: Duration(seconds: 5),
      );
      const mode2 = LiveViewportMode.autoScrollUntilInteraction(
        visibleDuration: Duration(seconds: 60),
        interactionTimeout: Duration(seconds: 5),
      );

      expect(mode1, equals(mode2));
      expect(mode1.hashCode, equals(mode2.hashCode));
    });

    test('different modes are not equal', () {
      const mode1 = LiveViewportMode.autoScrollUntilInteraction(
        visibleDuration: Duration(seconds: 60),
        interactionTimeout: Duration(seconds: 5),
      );
      const mode2 = LiveViewportMode.autoScrollUntilInteraction(
        visibleDuration: Duration(seconds: 60),
        interactionTimeout: Duration(seconds: 10),
      );

      expect(mode1, isNot(equals(mode2)));
    });
  });

  // ===========================================================================
  // FILL THEN SCROLL VIEWPORT
  // ===========================================================================
  group('FillThenScrollViewport', () {
    test('creates with required maxDuration', () {
      const mode = LiveViewportMode.fillThenScroll(
        maxDuration: Duration(minutes: 2),
      );

      expect(mode, isA<FillThenScrollViewport>());
      const fillMode = mode as FillThenScrollViewport;
      expect(fillMode.maxDuration, const Duration(minutes: 2));
      expect(fillMode.leadingPadding, Duration.zero);
      expect(fillMode.animationCurve, Curves.linear);
    });

    test('creates with all parameters', () {
      const mode = LiveViewportMode.fillThenScroll(
        maxDuration: Duration(seconds: 90),
        leadingPadding: Duration(seconds: 15),
        animationCurve: Curves.decelerate,
      );

      const fillMode = mode as FillThenScrollViewport;
      expect(fillMode.maxDuration, const Duration(seconds: 90));
      expect(fillMode.leadingPadding, const Duration(seconds: 15));
      expect(fillMode.animationCurve, Curves.decelerate);
    });

    test('equal modes are equal', () {
      const mode1 = LiveViewportMode.fillThenScroll(
        maxDuration: Duration(minutes: 1),
        leadingPadding: Duration(seconds: 5),
      );
      const mode2 = LiveViewportMode.fillThenScroll(
        maxDuration: Duration(minutes: 1),
        leadingPadding: Duration(seconds: 5),
      );

      expect(mode1, equals(mode2));
      expect(mode1.hashCode, equals(mode2.hashCode));
    });

    test('different modes are not equal', () {
      const mode1 = LiveViewportMode.fillThenScroll(
        maxDuration: Duration(minutes: 1),
      );
      const mode2 = LiveViewportMode.fillThenScroll(
        maxDuration: Duration(minutes: 2),
      );

      expect(mode1, isNot(equals(mode2)));
    });
  });

  // ===========================================================================
  // TYPE CHECKS
  // ===========================================================================
  group('LiveViewportMode - Type Checks', () {
    test('sealed class has all expected subtypes', () {
      const autoScroll = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 60),
      );
      const autoScrollPoints = LiveViewportMode.autoScrollPoints(
        visiblePoints: 100,
      );
      const fixed = LiveViewportMode.fixed();
      const autoScrollUntilInteraction =
          LiveViewportMode.autoScrollUntilInteraction(
            visibleDuration: Duration(seconds: 60),
          );
      const fillThenScroll = LiveViewportMode.fillThenScroll(
        maxDuration: Duration(minutes: 1),
      );

      expect(autoScroll, isA<LiveViewportMode>());
      expect(autoScrollPoints, isA<LiveViewportMode>());
      expect(fixed, isA<LiveViewportMode>());
      expect(autoScrollUntilInteraction, isA<LiveViewportMode>());
      expect(fillThenScroll, isA<LiveViewportMode>());
    });

    test('can use switch on sealed class', () {
      const mode = LiveViewportMode.autoScroll(
        visibleDuration: Duration(seconds: 60),
      );

      final result = switch (mode) {
        AutoScrollViewport() => 'autoScroll',
        AutoScrollPointsViewport() => 'autoScrollPoints',
        FixedViewport() => 'fixed',
        AutoScrollUntilInteractionViewport() => 'autoScrollUntilInteraction',
        FillThenScrollViewport() => 'fillThenScroll',
      };

      expect(result, 'autoScroll');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_tooltip_configuration.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_dismiss_strategy.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_activation_mode.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_position.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_trackball_mode.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';

void main() {
  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - CONSTRUCTION
  // ===========================================================================
  group('FusionTooltipBehavior - Construction', () {
    test('creates with default values', () {
      const behavior = FusionTooltipBehavior();

      expect(behavior.position, FusionTooltipPosition.floating);
      expect(behavior.showTrackballLine, isTrue);
      expect(behavior.trackballLineColor, isNull);
      expect(behavior.trackballLineWidth, 1.0);
      expect(behavior.trackballLineDashPattern, isNull);
      expect(behavior.activationMode, FusionTooltipActivationMode.auto);
      expect(behavior.activationDelay, Duration.zero);
      expect(behavior.dismissStrategy, FusionDismissStrategy.onRelease);
      expect(behavior.dismissDelay, const Duration(milliseconds: 300));
      expect(behavior.duration, const Duration(milliseconds: 3000));
      expect(behavior.trackballMode, FusionTooltipTrackballMode.none);
      expect(behavior.trackballUpdateThreshold, 5.0);
      expect(behavior.trackballSnapRadius, 20.0);
      expect(behavior.animationDuration, const Duration(milliseconds: 200));
      expect(behavior.animationCurve, Curves.easeOutCubic);
      expect(behavior.exitAnimationCurve, Curves.easeInCubic);
      expect(behavior.elevation, 2.5);
      expect(behavior.canShowMarker, isTrue);
      expect(behavior.textAlignment, ChartAlignment.center);
      expect(behavior.decimalPlaces, 2);
      expect(behavior.shared, isFalse);
      expect(behavior.opacity, 0.9);
      expect(behavior.borderWidth, 0);
      expect(behavior.format, isNull);
      expect(behavior.builder, isNull);
      expect(behavior.color, isNull);
      expect(behavior.textStyle, isNull);
      expect(behavior.borderColor, isNull);
      expect(behavior.shadowColor, isNull);
      expect(behavior.hapticFeedback, isTrue);
    });

    test('creates with custom values', () {
      const behavior = FusionTooltipBehavior(
        position: FusionTooltipPosition.top,
        showTrackballLine: false,
        trackballLineColor: Colors.red,
        trackballLineWidth: 2.0,
        trackballLineDashPattern: [4, 4],
        activationMode: FusionTooltipActivationMode.longPress,
        activationDelay: Duration(milliseconds: 100),
        dismissStrategy: FusionDismissStrategy.onTimer,
        dismissDelay: Duration(milliseconds: 500),
        duration: Duration(milliseconds: 5000),
        trackballMode: FusionTooltipTrackballMode.follow,
        trackballUpdateThreshold: 10.0,
        trackballSnapRadius: 30.0,
        animationDuration: Duration(milliseconds: 300),
        animationCurve: Curves.bounceIn,
        exitAnimationCurve: Curves.bounceOut,
        elevation: 5.0,
        canShowMarker: false,
        textAlignment: ChartAlignment.near,
        decimalPlaces: 4,
        shared: true,
        opacity: 0.8,
        borderWidth: 2.0,
        color: Colors.blue,
        textStyle: TextStyle(fontSize: 14),
        borderColor: Colors.green,
        shadowColor: Colors.grey,
        hapticFeedback: false,
      );

      expect(behavior.position, FusionTooltipPosition.top);
      expect(behavior.showTrackballLine, isFalse);
      expect(behavior.trackballLineColor, Colors.red);
      expect(behavior.trackballLineWidth, 2.0);
      expect(behavior.trackballLineDashPattern, [4, 4]);
      expect(behavior.activationMode, FusionTooltipActivationMode.longPress);
      expect(behavior.activationDelay, const Duration(milliseconds: 100));
      expect(behavior.dismissStrategy, FusionDismissStrategy.onTimer);
      expect(behavior.dismissDelay, const Duration(milliseconds: 500));
      expect(behavior.duration, const Duration(milliseconds: 5000));
      expect(behavior.trackballMode, FusionTooltipTrackballMode.follow);
      expect(behavior.trackballUpdateThreshold, 10.0);
      expect(behavior.trackballSnapRadius, 30.0);
      expect(behavior.animationDuration, const Duration(milliseconds: 300));
      expect(behavior.animationCurve, Curves.bounceIn);
      expect(behavior.exitAnimationCurve, Curves.bounceOut);
      expect(behavior.elevation, 5.0);
      expect(behavior.canShowMarker, isFalse);
      expect(behavior.textAlignment, ChartAlignment.near);
      expect(behavior.decimalPlaces, 4);
      expect(behavior.shared, isTrue);
      expect(behavior.opacity, 0.8);
      expect(behavior.borderWidth, 2.0);
      expect(behavior.color, Colors.blue);
      expect(behavior.textStyle, const TextStyle(fontSize: 14));
      expect(behavior.borderColor, Colors.green);
      expect(behavior.shadowColor, Colors.grey);
      expect(behavior.hapticFeedback, isFalse);
    });

    test('creates with format function', () {
      String formatter(FusionDataPoint point, String name) =>
          '\$name: \${point.y}';
      final behavior = FusionTooltipBehavior(format: formatter);

      expect(behavior.format, isNotNull);
    });

    test('creates with builder function', () {
      Widget builder(
        BuildContext context,
        FusionDataPoint point,
        String name,
        Color color,
      ) {
        return const SizedBox();
      }

      final behavior = FusionTooltipBehavior(builder: builder);

      expect(behavior.builder, isNotNull);
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - ASSERTIONS
  // ===========================================================================
  group('FusionTooltipBehavior - Assertions', () {
    test('throws on invalid trackballSnapRadius', () {
      expect(
        () => FusionTooltipBehavior(trackballSnapRadius: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionTooltipBehavior(trackballSnapRadius: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid trackballUpdateThreshold', () {
      expect(
        () => FusionTooltipBehavior(trackballUpdateThreshold: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid opacity', () {
      expect(
        () => FusionTooltipBehavior(opacity: -0.1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionTooltipBehavior(opacity: 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid trackballLineWidth', () {
      expect(
        () => FusionTooltipBehavior(trackballLineWidth: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionTooltipBehavior(trackballLineWidth: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid borderWidth', () {
      expect(
        () => FusionTooltipBehavior(borderWidth: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid decimalPlaces', () {
      expect(
        () => FusionTooltipBehavior(decimalPlaces: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid elevation', () {
      expect(
        () => FusionTooltipBehavior(elevation: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - GET EFFECTIVE ACTIVATION MODE
  // ===========================================================================
  group('FusionTooltipBehavior - getEffectiveActivationMode', () {
    test('returns specified mode when not auto', () {
      const behavior = FusionTooltipBehavior(
        activationMode: FusionTooltipActivationMode.longPress,
      );

      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.iOS),
        FusionTooltipActivationMode.longPress,
      );
      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.macOS),
        FusionTooltipActivationMode.longPress,
      );
    });

    test('returns singleTap for mobile platforms in auto mode', () {
      const behavior = FusionTooltipBehavior(
        activationMode: FusionTooltipActivationMode.auto,
      );

      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.iOS),
        FusionTooltipActivationMode.singleTap,
      );
      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.android),
        FusionTooltipActivationMode.singleTap,
      );
      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.fuchsia),
        FusionTooltipActivationMode.singleTap,
      );
    });

    test('returns hover for desktop platforms in auto mode', () {
      const behavior = FusionTooltipBehavior(
        activationMode: FusionTooltipActivationMode.auto,
      );

      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.macOS),
        FusionTooltipActivationMode.hover,
      );
      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.windows),
        FusionTooltipActivationMode.hover,
      );
      expect(
        behavior.getEffectiveActivationMode(TargetPlatform.linux),
        FusionTooltipActivationMode.hover,
      );
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - DISMISS HELPER METHODS
  // ===========================================================================
  group('FusionTooltipBehavior - Dismiss Helper Methods', () {
    test('shouldDismissOnRelease returns correct values', () {
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onRelease,
        ).shouldDismissOnRelease(),
        isTrue,
      );
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
        ).shouldDismissOnRelease(),
        isTrue,
      );
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.smart,
        ).shouldDismissOnRelease(),
        isTrue,
      );
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onTimer,
        ).shouldDismissOnRelease(),
        isFalse,
      );
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.never,
        ).shouldDismissOnRelease(),
        isFalse,
      );
    });

    test('shouldUseTimer returns correct values', () {
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onTimer,
        ).shouldUseTimer(),
        isTrue,
      );
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.smart,
        ).shouldUseTimer(),
        isTrue,
      );
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onRelease,
        ).shouldUseTimer(),
        isFalse,
      );
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.never,
        ).shouldUseTimer(),
        isFalse,
      );
    });

    test('getDismissDelay returns correct values for each strategy', () {
      // onRelease
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onRelease,
        ).getDismissDelay(false),
        Duration.zero,
      );

      // onReleaseDelayed
      const delayedBehavior = FusionTooltipBehavior(
        dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
        dismissDelay: Duration(milliseconds: 500),
      );
      expect(
        delayedBehavior.getDismissDelay(false),
        const Duration(milliseconds: 500),
      );

      // onTimer
      const timerBehavior = FusionTooltipBehavior(
        dismissStrategy: FusionDismissStrategy.onTimer,
        duration: Duration(milliseconds: 5000),
      );
      expect(
        timerBehavior.getDismissDelay(false),
        const Duration(milliseconds: 5000),
      );

      // never
      expect(
        const FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.never,
        ).getDismissDelay(false),
        const Duration(days: 365),
      );

      // smart - not long press
      const smartBehavior = FusionTooltipBehavior(
        dismissStrategy: FusionDismissStrategy.smart,
        dismissDelay: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 3000),
      );
      expect(
        smartBehavior.getDismissDelay(false),
        const Duration(milliseconds: 300),
      );

      // smart - long press
      expect(
        smartBehavior.getDismissDelay(true),
        const Duration(milliseconds: 3000),
      );
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - VALIDATE CONFIGURATION
  // ===========================================================================
  group('FusionTooltipBehavior - validateConfiguration', () {
    test('returns warning for shared with single series', () {
      const behavior = FusionTooltipBehavior(shared: true);
      final warnings = behavior.validateConfiguration(seriesCount: 1);

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('shared: true has no effect')),
        isTrue,
      );
    });

    test('returns warning for trackballLine with floating position', () {
      const behavior = FusionTooltipBehavior(
        position: FusionTooltipPosition.floating,
        showTrackballLine: true,
      );
      final warnings = behavior.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('showTrackballLine is ignored')),
        isTrue,
      );
    });

    test('returns warning for trackballSnapRadius with trackballMode none', () {
      const behavior = FusionTooltipBehavior(
        trackballMode: FusionTooltipTrackballMode.none,
        trackballSnapRadius: 50.0,
      );
      final warnings = behavior.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('trackballSnapRadius is ignored')),
        isTrue,
      );
    });

    test(
      'returns warning for trackballUpdateThreshold with trackballMode none',
      () {
        const behavior = FusionTooltipBehavior(
          trackballMode: FusionTooltipTrackballMode.none,
          trackballUpdateThreshold: 10.0,
        );
        final warnings = behavior.validateConfiguration();

        expect(warnings, isNotEmpty);
        expect(
          warnings.any(
            (w) => w.contains('trackballUpdateThreshold is ignored'),
          ),
          isTrue,
        );
      },
    );

    test('returns warning for never dismiss with follow trackball', () {
      const behavior = FusionTooltipBehavior(
        dismissStrategy: FusionDismissStrategy.never,
        trackballMode: FusionTooltipTrackballMode.follow,
      );
      final warnings = behavior.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('dismissStrategy: never with trackballMode'),
        ),
        isTrue,
      );
    });

    test('returns warning for none activation with never dismiss', () {
      const behavior = FusionTooltipBehavior(
        activationMode: FusionTooltipActivationMode.none,
        dismissStrategy: FusionDismissStrategy.never,
      );
      final warnings = behavior.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('activationMode: none with dismissStrategy: never'),
        ),
        isTrue,
      );
    });

    test(
      'returns warning for live mode with inappropriate dismiss strategy',
      () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onTimer,
        );
        final warnings = behavior.validateConfiguration(isLiveMode: true);

        expect(warnings, isNotEmpty);
        expect(warnings.any((w) => w.contains('Live mode charts')), isTrue);
      },
    );

    test('returns warning for shared with follow trackball', () {
      const behavior = FusionTooltipBehavior(
        shared: true,
        trackballMode: FusionTooltipTrackballMode.follow,
      );
      final warnings = behavior.validateConfiguration(seriesCount: 2);

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('shared: true with trackballMode: follow'),
        ),
        isTrue,
      );
    });

    test('returns warning for dismissDelay with wrong strategy', () {
      const behavior = FusionTooltipBehavior(
        dismissStrategy: FusionDismissStrategy.never,
        dismissDelay: Duration(milliseconds: 500),
      );
      final warnings = behavior.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('dismissDelay is only used')),
        isTrue,
      );
    });

    test('returns warning for duration with wrong strategy', () {
      const behavior = FusionTooltipBehavior(
        dismissStrategy: FusionDismissStrategy.never,
        duration: Duration(milliseconds: 5000),
      );
      final warnings = behavior.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('duration is only used')), isTrue);
    });

    test('returns empty for valid configuration', () {
      const behavior = FusionTooltipBehavior(
        position: FusionTooltipPosition.top,
        showTrackballLine: true,
        trackballMode: FusionTooltipTrackballMode.snap,
        trackballSnapRadius: 30.0,
        dismissStrategy: FusionDismissStrategy.onRelease,
      );
      final warnings = behavior.validateConfiguration(seriesCount: 3);

      expect(warnings, isEmpty);
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - ASSERT VALID
  // ===========================================================================
  group('FusionTooltipBehavior - assertValid', () {
    test('passes for valid configuration', () {
      const behavior = FusionTooltipBehavior();

      expect(() => behavior.assertValid(), returnsNormally);
    });

    test('throws for negative seriesCount', () {
      const behavior = FusionTooltipBehavior();

      expect(
        () => behavior.assertValid(seriesCount: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for empty trackballLineDashPattern', () {
      const behavior = FusionTooltipBehavior(trackballLineDashPattern: []);

      expect(() => behavior.assertValid(), throwsA(isA<AssertionError>()));
    });

    test('throws for negative values in trackballLineDashPattern', () {
      const behavior = FusionTooltipBehavior(trackballLineDashPattern: [4, -2]);

      expect(() => behavior.assertValid(), throwsA(isA<AssertionError>()));
    });

    test('throws for zero values in trackballLineDashPattern', () {
      const behavior = FusionTooltipBehavior(trackballLineDashPattern: [4, 0]);

      expect(() => behavior.assertValid(), throwsA(isA<AssertionError>()));
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - CONFIGURATION GUIDE
  // ===========================================================================
  group('FusionTooltipBehavior - configurationGuide', () {
    test('returns non-empty guide', () {
      expect(FusionTooltipBehavior.configurationGuide, isNotEmpty);
      expect(
        FusionTooltipBehavior.configurationGuide,
        contains('Position Options'),
      );
      expect(
        FusionTooltipBehavior.configurationGuide,
        contains('Activation Modes'),
      );
      expect(
        FusionTooltipBehavior.configurationGuide,
        contains('Dismiss Strategies'),
      );
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP BEHAVIOR - COPYWITH
  // ===========================================================================
  group('FusionTooltipBehavior - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionTooltipBehavior(
        position: FusionTooltipPosition.floating,
        opacity: 0.9,
      );

      final copy = original.copyWith(
        position: FusionTooltipPosition.top,
        opacity: 0.5,
      );

      expect(copy.position, FusionTooltipPosition.top);
      expect(copy.opacity, 0.5);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionTooltipBehavior(
        position: FusionTooltipPosition.top,
        showTrackballLine: false,
        trackballLineWidth: 2.0,
        elevation: 5.0,
      );

      final copy = original.copyWith(position: FusionTooltipPosition.bottom);

      expect(copy.position, FusionTooltipPosition.bottom);
      expect(copy.showTrackballLine, isFalse);
      expect(copy.trackballLineWidth, 2.0);
      expect(copy.elevation, 5.0);
    });

    test('copyWith handles all parameters', () {
      const original = FusionTooltipBehavior();

      final copy = original.copyWith(
        position: FusionTooltipPosition.bottom,
        showTrackballLine: false,
        trackballLineColor: Colors.red,
        trackballLineWidth: 3.0,
        trackballLineDashPattern: [2, 2],
        activationMode: FusionTooltipActivationMode.doubleTap,
        activationDelay: const Duration(milliseconds: 50),
        dismissStrategy: FusionDismissStrategy.smart,
        dismissDelay: const Duration(milliseconds: 400),
        duration: const Duration(milliseconds: 4000),
        trackballMode: FusionTooltipTrackballMode.magnetic,
        trackballUpdateThreshold: 15.0,
        trackballSnapRadius: 25.0,
        animationDuration: const Duration(milliseconds: 250),
        animationCurve: Curves.linear,
        exitAnimationCurve: Curves.easeOut,
        elevation: 3.0,
        canShowMarker: false,
        textAlignment: ChartAlignment.far,
        decimalPlaces: 3,
        shared: true,
        opacity: 0.7,
        borderWidth: 1.5,
        color: Colors.amber,
        textStyle: const TextStyle(color: Colors.white),
        borderColor: Colors.orange,
        shadowColor: Colors.black,
        hapticFeedback: false,
      );

      expect(copy.position, FusionTooltipPosition.bottom);
      expect(copy.showTrackballLine, isFalse);
      expect(copy.trackballLineColor, Colors.red);
      expect(copy.trackballLineWidth, 3.0);
      expect(copy.trackballLineDashPattern, [2, 2]);
      expect(copy.activationMode, FusionTooltipActivationMode.doubleTap);
      expect(copy.activationDelay, const Duration(milliseconds: 50));
      expect(copy.dismissStrategy, FusionDismissStrategy.smart);
      expect(copy.dismissDelay, const Duration(milliseconds: 400));
      expect(copy.duration, const Duration(milliseconds: 4000));
      expect(copy.trackballMode, FusionTooltipTrackballMode.magnetic);
      expect(copy.trackballUpdateThreshold, 15.0);
      expect(copy.trackballSnapRadius, 25.0);
      expect(copy.animationDuration, const Duration(milliseconds: 250));
      expect(copy.animationCurve, Curves.linear);
      expect(copy.exitAnimationCurve, Curves.easeOut);
      expect(copy.elevation, 3.0);
      expect(copy.canShowMarker, isFalse);
      expect(copy.textAlignment, ChartAlignment.far);
      expect(copy.decimalPlaces, 3);
      expect(copy.shared, isTrue);
      expect(copy.opacity, 0.7);
      expect(copy.borderWidth, 1.5);
      expect(copy.color, Colors.amber);
      expect(copy.textStyle, const TextStyle(color: Colors.white));
      expect(copy.borderColor, Colors.orange);
      expect(copy.shadowColor, Colors.black);
      expect(copy.hapticFeedback, isFalse);
    });
  });

  // ===========================================================================
  // TOOLTIP RENDER DATA - CONSTRUCTION
  // ===========================================================================
  group('TooltipRenderData - Construction', () {
    test('creates with required parameters', () {
      const data = TooltipRenderData(
        point: FusionDataPoint(1, 10),
        seriesName: 'Series A',
        seriesColor: Colors.blue,
        screenPosition: Offset(100, 200),
      );

      expect(data.point, const FusionDataPoint(1, 10));
      expect(data.seriesName, 'Series A');
      expect(data.seriesColor, Colors.blue);
      expect(data.screenPosition, const Offset(100, 200));
      expect(data.wasLongPress, isFalse);
      expect(data.activationTime, isNull);
      expect(data.sharedPoints, isNull);
    });

    test('creates with all parameters', () {
      final now = DateTime.now();
      final sharedPoints = [
        const SharedTooltipPoint(
          point: FusionDataPoint(1, 20),
          seriesName: 'Series B',
          seriesColor: Colors.red,
          screenPosition: Offset(100, 150),
        ),
      ];

      final data = TooltipRenderData(
        point: const FusionDataPoint(1, 10),
        seriesName: 'Series A',
        seriesColor: Colors.blue,
        screenPosition: const Offset(100, 200),
        wasLongPress: true,
        activationTime: now,
        sharedPoints: sharedPoints,
      );

      expect(data.wasLongPress, isTrue);
      expect(data.activationTime, now);
      expect(data.sharedPoints, sharedPoints);
    });
  });

  // ===========================================================================
  // TOOLTIP RENDER DATA - COPYWITH
  // ===========================================================================
  group('TooltipRenderData - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = TooltipRenderData(
        point: FusionDataPoint(1, 10),
        seriesName: 'Series A',
        seriesColor: Colors.blue,
        screenPosition: Offset(100, 200),
      );

      final copy = original.copyWith(
        seriesName: 'Series B',
        screenPosition: const Offset(150, 250),
      );

      expect(copy.seriesName, 'Series B');
      expect(copy.screenPosition, const Offset(150, 250));
      expect(copy.point, original.point);
      expect(copy.seriesColor, original.seriesColor);
    });

    test('copyWith preserves unchanged values', () {
      final now = DateTime.now();
      final original = TooltipRenderData(
        point: const FusionDataPoint(1, 10),
        seriesName: 'Series A',
        seriesColor: Colors.blue,
        screenPosition: const Offset(100, 200),
        wasLongPress: true,
        activationTime: now,
      );

      final copy = original.copyWith(seriesName: 'Series B');

      expect(copy.wasLongPress, isTrue);
      expect(copy.activationTime, now);
    });
  });

  // ===========================================================================
  // SHARED TOOLTIP POINT - CONSTRUCTION
  // ===========================================================================
  group('SharedTooltipPoint - Construction', () {
    test('creates with required parameters', () {
      const point = SharedTooltipPoint(
        point: FusionDataPoint(1, 10),
        seriesName: 'Series A',
        seriesColor: Colors.blue,
        screenPosition: Offset(100, 200),
      );

      expect(point.point, const FusionDataPoint(1, 10));
      expect(point.seriesName, 'Series A');
      expect(point.seriesColor, Colors.blue);
      expect(point.screenPosition, const Offset(100, 200));
    });
  });

  // ===========================================================================
  // CHART ALIGNMENT ENUM
  // ===========================================================================
  group('ChartAlignment - Enum', () {
    test('has all expected values', () {
      expect(ChartAlignment.values, hasLength(3));
      expect(ChartAlignment.values, contains(ChartAlignment.near));
      expect(ChartAlignment.values, contains(ChartAlignment.center));
      expect(ChartAlignment.values, contains(ChartAlignment.far));
    });
  });
}

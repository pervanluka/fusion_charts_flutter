import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
import 'package:fusion_charts_flutter/src/charts/fusion_interactive_chart.dart';

void main() {
  group('FusionTooltipBehavior Configuration Tests', () {
    late FusionCoordinateSystem coordSystem;

    setUp(() {
      coordSystem = FusionCoordinateSystem(
        chartArea: const Rect.fromLTWH(0, 0, 400, 300),
        dataXMin: 0,
        dataXMax: 100,
        dataYMin: 0,
        dataYMax: 100,
        devicePixelRatio: 1.0,
      );
    });

    group('Constructor Assertions', () {
      test('throws when trackballSnapRadius is zero', () {
        expect(
          () => FusionTooltipBehavior(trackballSnapRadius: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when trackballSnapRadius is negative', () {
        expect(
          () => FusionTooltipBehavior(trackballSnapRadius: -5),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when trackballUpdateThreshold is negative', () {
        expect(
          () => FusionTooltipBehavior(trackballUpdateThreshold: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows trackballUpdateThreshold of zero', () {
        expect(
          () => FusionTooltipBehavior(trackballUpdateThreshold: 0),
          returnsNormally,
        );
      });

      test('throws when opacity is greater than 1', () {
        expect(
          () => FusionTooltipBehavior(opacity: 1.5),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when opacity is negative', () {
        expect(
          () => FusionTooltipBehavior(opacity: -0.5),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows opacity at boundaries', () {
        expect(() => FusionTooltipBehavior(opacity: 0), returnsNormally);
        expect(() => FusionTooltipBehavior(opacity: 1), returnsNormally);
      });

      test('throws when trackballLineWidth is zero', () {
        expect(
          () => FusionTooltipBehavior(trackballLineWidth: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when trackballLineWidth is negative', () {
        expect(
          () => FusionTooltipBehavior(trackballLineWidth: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when borderWidth is negative', () {
        expect(
          () => FusionTooltipBehavior(borderWidth: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows borderWidth of zero', () {
        expect(() => FusionTooltipBehavior(borderWidth: 0), returnsNormally);
      });

      test('throws when decimalPlaces is negative', () {
        expect(
          () => FusionTooltipBehavior(decimalPlaces: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when elevation is negative', () {
        expect(
          () => FusionTooltipBehavior(elevation: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('assertValid Method', () {
      test('shared with single series is allowed (warning only)', () {
        final config = FusionTooltipBehavior(shared: true);

        // Should not throw - it's allowed but triggers a warning
        expect(() => config.assertValid(seriesCount: 1), returnsNormally);

        // Warning should be present in validateConfiguration
        final warnings = config.validateConfiguration(seriesCount: 1);
        expect(warnings, contains(contains('shared: true has no effect')));
      });

      test('shared with multiple series works without warning', () {
        final config = FusionTooltipBehavior(shared: true);

        expect(() => config.assertValid(seriesCount: 2), returnsNormally);

        // No warning for multi-series
        final warnings = config.validateConfiguration(seriesCount: 2);
        expect(
          warnings.where((w) => w.contains('shared: true has no effect')),
          isEmpty,
        );
      });

      test('throws when seriesCount is negative', () {
        final config = FusionTooltipBehavior();

        expect(
          () => config.assertValid(seriesCount: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows empty series', () {
        final config = FusionTooltipBehavior();

        expect(() => config.assertValid(seriesCount: 0), returnsNormally);
      });

      test('throws when trackballLineDashPattern is empty', () {
        final config = FusionTooltipBehavior(trackballLineDashPattern: []);

        expect(config.assertValid, throwsA(isA<AssertionError>()));
      });

      test('throws when trackballLineDashPattern has non-positive values', () {
        final config = FusionTooltipBehavior(
          trackballLineDashPattern: [4, 0, 4],
        );

        expect(config.assertValid, throwsA(isA<AssertionError>()));
      });

      test('allows valid trackballLineDashPattern', () {
        final config = FusionTooltipBehavior(trackballLineDashPattern: [4, 4]);

        expect(config.assertValid, returnsNormally);
      });
    });

    group('validateConfiguration Method', () {
      test('warns when showTrackballLine true with floating position', () {
        final config = FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          showTrackballLine: true,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('showTrackballLine is ignored')));
      });

      test('no warning when showTrackballLine with top position', () {
        final config = FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          showTrackballLine: true,
        );

        final warnings = config.validateConfiguration();

        expect(warnings.where((w) => w.contains('showTrackballLine')), isEmpty);
      });

      test('warns when trackballSnapRadius set with trackballMode none', () {
        final config = FusionTooltipBehavior(
          trackballMode: FusionTooltipTrackballMode.none,
          trackballSnapRadius: 50.0, // Non-default value
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('trackballSnapRadius is ignored')));
      });

      test(
        'warns when trackballUpdateThreshold set with trackballMode none',
        () {
          final config = FusionTooltipBehavior(
            trackballMode: FusionTooltipTrackballMode.none,
            trackballUpdateThreshold: 10.0, // Non-default value
          );

          final warnings = config.validateConfiguration();

          expect(
            warnings,
            contains(contains('trackballUpdateThreshold is ignored')),
          );
        },
      );

      test('warns for dismissStrategy never with trackballMode follow', () {
        final config = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.never,
          trackballMode: FusionTooltipTrackballMode.follow,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('follow')));
        expect(warnings, contains(contains('never')));
      });

      test('warns for activationMode none with dismissStrategy never', () {
        final config = FusionTooltipBehavior(
          activationMode: FusionTooltipActivationMode.none,
          dismissStrategy: FusionDismissStrategy.never,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('programmatically')));
      });

      test('warns for non-recommended dismiss strategy in live mode', () {
        final config = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onTimer,
        );

        final warnings = config.validateConfiguration(isLiveMode: true);

        expect(warnings, contains(contains('Live mode')));
      });

      test('no warning for dismissStrategy never in live mode', () {
        final config = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.never,
        );

        final warnings = config.validateConfiguration(isLiveMode: true);

        expect(warnings.where((w) => w.contains('Live mode')), isEmpty);
      });

      test('warns for shared tooltip with trackballMode follow', () {
        final config = FusionTooltipBehavior(
          shared: true,
          trackballMode: FusionTooltipTrackballMode.follow,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('shared: true')));
        expect(warnings, contains(contains('follow')));
      });

      test('warns when dismissDelay set with incompatible strategy', () {
        final config = FusionTooltipBehavior(
          dismissDelay: const Duration(milliseconds: 500),
          dismissStrategy: FusionDismissStrategy.onRelease,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('dismissDelay is only used')));
      });

      test('no warning when dismissDelay with onReleaseDelayed', () {
        final config = FusionTooltipBehavior(
          dismissDelay: const Duration(milliseconds: 500),
          dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
        );

        final warnings = config.validateConfiguration();

        expect(
          warnings.where((w) => w.contains('dismissDelay is only used')),
          isEmpty,
        );
      });

      test('warns when duration set with incompatible strategy', () {
        final config = FusionTooltipBehavior(
          duration: const Duration(milliseconds: 5000),
          dismissStrategy: FusionDismissStrategy.onRelease,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('duration is only used')));
      });

      test('no warning when duration with onTimer', () {
        final config = FusionTooltipBehavior(
          duration: const Duration(milliseconds: 5000),
          dismissStrategy: FusionDismissStrategy.onTimer,
        );

        final warnings = config.validateConfiguration();

        expect(
          warnings.where((w) => w.contains('duration is only used')),
          isEmpty,
        );
      });
    });

    group('Configuration Guide', () {
      test('configurationGuide contains documentation', () {
        final guide = FusionTooltipBehavior.configurationGuide;

        expect(guide, contains('Position Options'));
        expect(guide, contains('Activation Modes'));
        expect(guide, contains('Dismiss Strategies'));
        expect(guide, contains('Trackball Modes'));
        expect(guide, contains('Multi-Series Behavior'));
        expect(guide, contains('Live Chart Mode'));
        expect(guide, contains('Recommended Configurations'));
      });
    });

    group('Position and Shared Combinations', () {
      test('floating position with shared true works', () {
        final series1 = FusionLineSeries(
          name: 'Line 1',
          dataPoints: [FusionDataPoint(50, 80)],
          color: Colors.blue,
        );
        final series2 = FusionLineSeries(
          name: 'Line 2',
          dataPoints: [FusionDataPoint(50, 20)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            position: FusionTooltipPosition.floating,
            shared: true,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
      });

      test('top position with shared true works', () {
        final series1 = FusionLineSeries(
          name: 'Line 1',
          dataPoints: [FusionDataPoint(50, 80)],
          color: Colors.blue,
        );
        final series2 = FusionLineSeries(
          name: 'Line 2',
          dataPoints: [FusionDataPoint(50, 20)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            position: FusionTooltipPosition.top,
            shared: true,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
      });

      test('bottom position with shared false works', () {
        final series = FusionLineSeries(
          name: 'Line 1',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            position: FusionTooltipPosition.bottom,
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(50));
      });
    });

    group('Trackball Mode Combinations', () {
      test('trackballMode snapToX works with multi-series', () {
        final series1 = FusionLineSeries(
          name: 'Line 1',
          dataPoints: [FusionDataPoint(0, 80), FusionDataPoint(100, 80)],
          color: Colors.blue,
        );
        final series2 = FusionLineSeries(
          name: 'Line 2',
          dataPoints: [FusionDataPoint(0, 20), FusionDataPoint(100, 20)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballMode: FusionTooltipTrackballMode.snapToX,
            trackballSnapRadius: 50.0,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap near top line
        final screenX = coordSystem.dataXToScreenX(50);
        final screenY = coordSystem.dataYToScreenY(80);
        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        expect(point, isNotNull);
        expect(point!.y, equals(80));
      });

      test('trackballMode snap with small radius', () {
        final series = FusionLineSeries(
          name: 'Line',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballMode: FusionTooltipTrackballMode.snap,
            trackballSnapRadius: 5.0, // Very small
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
      });
    });

    group('Dismiss Strategy Combinations', () {
      test('dismissStrategy never with live mode works', () {
        final series = FusionLineSeries(
          name: 'Live',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: true,
        );
        state.initialize();

        expect(state.isLiveMode, isTrue);
        expect(state.probeScreenX, isNull); // Initially null

        // Set probe position
        state.setProbePosition(const Offset(200, 150));
        expect(state.isProbeActive, isTrue);
      });

      test('dismissStrategy onRelease with static mode works', () {
        final series = FusionLineSeries(
          name: 'Static',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onRelease,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series],
          isLiveMode: false,
        );
        state.initialize();

        expect(state.isLiveMode, isFalse);
      });

      test('dismissStrategy smart adapts correctly', () {
        final behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.smart,
          dismissDelay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 3000),
        );

        // Quick tap should use dismissDelay
        expect(
          behavior.getDismissDelay(false),
          equals(const Duration(milliseconds: 300)),
        );

        // Long press should use duration
        expect(
          behavior.getDismissDelay(true),
          equals(const Duration(milliseconds: 3000)),
        );
      });
    });

    group('Activation Mode Combinations', () {
      test('activationMode auto resolves to singleTap on mobile', () {
        final behavior = FusionTooltipBehavior(
          activationMode: FusionTooltipActivationMode.auto,
        );

        expect(
          behavior.getEffectiveActivationMode(TargetPlatform.iOS),
          equals(FusionTooltipActivationMode.singleTap),
        );
        expect(
          behavior.getEffectiveActivationMode(TargetPlatform.android),
          equals(FusionTooltipActivationMode.singleTap),
        );
      });

      test('activationMode auto resolves to hover on desktop', () {
        final behavior = FusionTooltipBehavior(
          activationMode: FusionTooltipActivationMode.auto,
        );

        expect(
          behavior.getEffectiveActivationMode(TargetPlatform.macOS),
          equals(FusionTooltipActivationMode.hover),
        );
        expect(
          behavior.getEffectiveActivationMode(TargetPlatform.windows),
          equals(FusionTooltipActivationMode.hover),
        );
        expect(
          behavior.getEffectiveActivationMode(TargetPlatform.linux),
          equals(FusionTooltipActivationMode.hover),
        );
      });

      test('explicit activationMode overrides platform detection', () {
        final behavior = FusionTooltipBehavior(
          activationMode: FusionTooltipActivationMode.longPress,
        );

        expect(
          behavior.getEffectiveActivationMode(TargetPlatform.iOS),
          equals(FusionTooltipActivationMode.longPress),
        );
        expect(
          behavior.getEffectiveActivationMode(TargetPlatform.macOS),
          equals(FusionTooltipActivationMode.longPress),
        );
      });
    });

    group('Dynamic Threshold with Shared Mode', () {
      test('shared mode bypasses threshold', () {
        // Two series far apart
        final series1 = FusionLineSeries(
          name: 'Far Top',
          dataPoints: [FusionDataPoint(50, 95)],
          color: Colors.blue,
        );
        final series2 = FusionLineSeries(
          name: 'Far Bottom',
          dataPoints: [FusionDataPoint(50, 5)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 5.0, // Very small
            shared: true, // But shared mode
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap in the middle - far from both
        final screenX = coordSystem.dataXToScreenX(50);
        final screenY = coordSystem.dataYToScreenY(50);
        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        // Should still find a point because shared mode bypasses threshold
        expect(point, isNotNull);
      });

      test('non-shared mode respects threshold', () {
        // Two series far apart
        final series1 = FusionLineSeries(
          name: 'Far Top',
          dataPoints: [FusionDataPoint(50, 95)],
          color: Colors.blue,
        );
        final series2 = FusionLineSeries(
          name: 'Far Bottom',
          dataPoints: [FusionDataPoint(50, 5)],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            trackballSnapRadius: 5.0, // Very small
            shared: false,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
        );
        state.initialize();

        // Tap in the middle - far from both
        final screenX = coordSystem.dataXToScreenX(50);
        final screenY = coordSystem.dataYToScreenY(50);
        final point = state.findPointAtScreenX(screenX, screenY: screenY);

        // Should NOT find a point because outside threshold
        expect(point, isNull);
      });
    });

    group('Live Mode Specific Combinations', () {
      test('live mode with probe position and shared tooltip', () {
        final series1 = FusionLineSeries(
          name: 'Line 1',
          dataPoints: [
            FusionDataPoint(0, 80),
            FusionDataPoint(50, 80),
            FusionDataPoint(100, 80),
          ],
          color: Colors.blue,
        );
        final series2 = FusionLineSeries(
          name: 'Line 2',
          dataPoints: [
            FusionDataPoint(0, 20),
            FusionDataPoint(50, 20),
            FusionDataPoint(100, 20),
          ],
          color: Colors.red,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
            shared: true,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1, series2],
          isLiveMode: true,
        );
        state.initialize();

        // Set probe position
        final probeX = coordSystem.dataXToScreenX(50);
        final probeY = coordSystem.dataYToScreenY(50);
        state.setProbePosition(Offset(probeX, probeY));

        // Query should work
        final point = state.findPointAtScreenX(probeX, screenY: probeY);
        expect(point, isNotNull);
      });

      test('live mode updates series correctly', () {
        final series1 = FusionLineSeries(
          name: 'Live',
          dataPoints: [FusionDataPoint(0, 50)],
          color: Colors.blue,
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
          ),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: [series1],
          isLiveMode: true,
        );
        state.initialize();

        // Update series with new data
        final series2 = FusionLineSeries(
          name: 'Live',
          dataPoints: [
            FusionDataPoint(0, 50),
            FusionDataPoint(50, 75),
            FusionDataPoint(100, 25),
          ],
          color: Colors.blue,
        );

        state.series = [series2];

        // Query new point
        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
        expect(point!.x, equals(50));
        expect(point.y, equals(75));
      });
    });

    group('copyWith Preserves Configuration', () {
      test('copyWith preserves all values', () {
        final original = FusionTooltipBehavior(
          position: FusionTooltipPosition.top,
          showTrackballLine: true,
          trackballLineColor: Colors.red,
          trackballLineWidth: 2.0,
          trackballLineDashPattern: [4, 4],
          activationMode: FusionTooltipActivationMode.longPress,
          activationDelay: const Duration(milliseconds: 100),
          dismissStrategy: FusionDismissStrategy.never,
          dismissDelay: const Duration(milliseconds: 500),
          duration: const Duration(seconds: 5),
          trackballMode: FusionTooltipTrackballMode.snapToX,
          trackballUpdateThreshold: 10.0,
          trackballSnapRadius: 30.0,
          animationDuration: const Duration(milliseconds: 300),
          elevation: 5.0,
          canShowMarker: false,
          textAlignment: ChartAlignment.near,
          decimalPlaces: 3,
          shared: true,
          opacity: 0.8,
          borderWidth: 2.0,
          color: Colors.black,
          textStyle: const TextStyle(fontSize: 14),
          borderColor: Colors.grey,
          shadowColor: Colors.black54,
          hapticFeedback: false,
        );

        final copied = original.copyWith();

        expect(copied.position, equals(original.position));
        expect(copied.showTrackballLine, equals(original.showTrackballLine));
        expect(copied.trackballLineColor, equals(original.trackballLineColor));
        expect(copied.trackballLineWidth, equals(original.trackballLineWidth));
        expect(
          copied.trackballLineDashPattern,
          equals(original.trackballLineDashPattern),
        );
        expect(copied.activationMode, equals(original.activationMode));
        expect(copied.activationDelay, equals(original.activationDelay));
        expect(copied.dismissStrategy, equals(original.dismissStrategy));
        expect(copied.dismissDelay, equals(original.dismissDelay));
        expect(copied.duration, equals(original.duration));
        expect(copied.trackballMode, equals(original.trackballMode));
        expect(
          copied.trackballUpdateThreshold,
          equals(original.trackballUpdateThreshold),
        );
        expect(
          copied.trackballSnapRadius,
          equals(original.trackballSnapRadius),
        );
        expect(copied.animationDuration, equals(original.animationDuration));
        expect(copied.elevation, equals(original.elevation));
        expect(copied.canShowMarker, equals(original.canShowMarker));
        expect(copied.textAlignment, equals(original.textAlignment));
        expect(copied.decimalPlaces, equals(original.decimalPlaces));
        expect(copied.shared, equals(original.shared));
        expect(copied.opacity, equals(original.opacity));
        expect(copied.borderWidth, equals(original.borderWidth));
        expect(copied.color, equals(original.color));
        expect(copied.textStyle, equals(original.textStyle));
        expect(copied.borderColor, equals(original.borderColor));
        expect(copied.shadowColor, equals(original.shadowColor));
        expect(copied.hapticFeedback, equals(original.hapticFeedback));
      });

      test('copyWith overrides specific values', () {
        final original = FusionTooltipBehavior(
          position: FusionTooltipPosition.floating,
          shared: false,
        );

        final modified = original.copyWith(
          position: FusionTooltipPosition.top,
          shared: true,
        );

        expect(modified.position, equals(FusionTooltipPosition.top));
        expect(modified.shared, isTrue);
      });
    });

    group('Helper Methods', () {
      test('shouldDismissOnRelease returns correct value', () {
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onRelease,
          ).shouldDismissOnRelease(),
          isTrue,
        );
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
          ).shouldDismissOnRelease(),
          isTrue,
        );
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.smart,
          ).shouldDismissOnRelease(),
          isTrue,
        );
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onTimer,
          ).shouldDismissOnRelease(),
          isFalse,
        );
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
          ).shouldDismissOnRelease(),
          isFalse,
        );
      });

      test('shouldUseTimer returns correct value', () {
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onTimer,
          ).shouldUseTimer(),
          isTrue,
        );
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.smart,
          ).shouldUseTimer(),
          isTrue,
        );
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onRelease,
          ).shouldUseTimer(),
          isFalse,
        );
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
          ).shouldUseTimer(),
          isFalse,
        );
      });

      test('getDismissDelay returns correct values', () {
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onRelease,
          ).getDismissDelay(false),
          equals(Duration.zero),
        );

        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
            dismissDelay: const Duration(milliseconds: 500),
          ).getDismissDelay(false),
          equals(const Duration(milliseconds: 500)),
        );

        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.onTimer,
            duration: const Duration(seconds: 3),
          ).getDismissDelay(false),
          equals(const Duration(seconds: 3)),
        );

        // Never strategy returns a very long duration
        expect(
          FusionTooltipBehavior(
            dismissStrategy: FusionDismissStrategy.never,
          ).getDismissDelay(false).inDays,
          greaterThan(0),
        );
      });
    });

    group('Edge Cases and Stress Tests', () {
      test('handles all series hidden', () {
        final series = FusionLineSeries(
          name: 'Hidden',
          dataPoints: [FusionDataPoint(50, 50)],
          color: Colors.blue,
          visible: false,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        final point = state.findPointAtScreenX(200);
        expect(point, isNull);
      });

      test('handles empty data points', () {
        final series = FusionLineSeries(
          name: 'Empty',
          dataPoints: [],
          color: Colors.blue,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: coordSystem,
          series: [series],
        );
        state.initialize();

        final point = state.findPointAtScreenX(200);
        expect(point, isNull);
      });

      test('handles many series', () {
        final seriesList = List.generate(
          20,
          (i) => FusionLineSeries(
            name: 'Series $i',
            dataPoints: [FusionDataPoint(50, i * 5.0)],
            color: Colors.primaries[i % Colors.primaries.length],
          ),
        );

        final config = FusionChartConfiguration(
          tooltipBehavior: const FusionTooltipBehavior(shared: true),
        );

        final state = FusionInteractiveChartState(
          config: config,
          initialCoordSystem: coordSystem,
          series: seriesList,
        );
        state.initialize();

        final screenX = coordSystem.dataXToScreenX(50);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
      });

      test('handles extreme coordinate values', () {
        final series = FusionLineSeries(
          name: 'Extreme',
          dataPoints: [
            FusionDataPoint(-1000000, -1000000),
            FusionDataPoint(1000000, 1000000),
          ],
          color: Colors.blue,
        );

        final extremeCoordSystem = FusionCoordinateSystem(
          chartArea: const Rect.fromLTWH(0, 0, 400, 300),
          dataXMin: -1000000,
          dataXMax: 1000000,
          dataYMin: -1000000,
          dataYMax: 1000000,
          devicePixelRatio: 1.0,
        );

        final state = FusionInteractiveChartState(
          config: FusionChartConfiguration(),
          initialCoordSystem: extremeCoordSystem,
          series: [series],
        );
        state.initialize();

        final screenX = extremeCoordSystem.dataXToScreenX(0);
        final point = state.findPointAtScreenX(screenX);

        expect(point, isNotNull);
      });
    });
  });
}

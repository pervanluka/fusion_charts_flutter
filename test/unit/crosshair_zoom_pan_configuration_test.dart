import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('FusionCrosshairConfiguration Tests', () {
    group('Constructor Assertions', () {
      test('throws when lineWidth is zero', () {
        expect(
          () => FusionCrosshairConfiguration(lineWidth: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when lineWidth is negative', () {
        expect(
          () => FusionCrosshairConfiguration(lineWidth: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows positive lineWidth', () {
        expect(
          () => FusionCrosshairConfiguration(lineWidth: 2.5),
          returnsNormally,
        );
      });

      test('throws when labelBorderRadius is negative', () {
        expect(
          () => FusionCrosshairConfiguration(labelBorderRadius: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows zero labelBorderRadius', () {
        expect(
          () => FusionCrosshairConfiguration(labelBorderRadius: 0),
          returnsNormally,
        );
      });
    });

    group('assertValid Method', () {
      test('throws when lineDashArray is empty', () {
        final config = FusionCrosshairConfiguration(lineDashArray: []);

        expect(config.assertValid, throwsA(isA<AssertionError>()));
      });

      test('throws when lineDashArray has non-positive values', () {
        final config = FusionCrosshairConfiguration(lineDashArray: [5, 0, 5]);

        expect(config.assertValid, throwsA(isA<AssertionError>()));
      });

      test('allows valid lineDashArray', () {
        final config = FusionCrosshairConfiguration(lineDashArray: [5, 5]);

        expect(config.assertValid, returnsNormally);
      });

      test('allows null lineDashArray', () {
        final config = FusionCrosshairConfiguration(lineDashArray: null);

        expect(config.assertValid, returnsNormally);
      });
    });

    group('validateConfiguration Method', () {
      test('warns when both lines are hidden', () {
        final config = FusionCrosshairConfiguration(
          showHorizontalLine: false,
          showVerticalLine: false,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('will not display any lines')));
      });

      test('no warning when at least one line is shown', () {
        final config = FusionCrosshairConfiguration(
          showHorizontalLine: true,
          showVerticalLine: false,
        );

        final warnings = config.validateConfiguration();

        expect(
          warnings.where((w) => w.contains('will not display any lines')),
          isEmpty,
        );
      });

      test('warns when labelBuilder and formatters are both set', () {
        final config = FusionCrosshairConfiguration(
          showLabel: true,
          labelBuilder: (context, point, isXAxis) => null,
          xLabelFormatter: (value, point) => value.toString(),
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('labelBuilder takes precedence')));
      });

      test('warns when lineDashArray is empty', () {
        // Note: This would fail assertValid, but validateConfiguration catches it too
        final config = FusionCrosshairConfiguration(lineDashArray: []);

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('lineDashArray is empty')));
      });

      test('warns when dismissDelay set with incompatible strategy', () {
        final config = FusionCrosshairConfiguration(
          dismissDelay: const Duration(milliseconds: 500),
          dismissStrategy: FusionDismissStrategy.onRelease,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('dismissDelay is only used')));
      });

      test('no warning when dismissDelay with onReleaseDelayed', () {
        final config = FusionCrosshairConfiguration(
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
        final config = FusionCrosshairConfiguration(
          duration: const Duration(seconds: 5),
          dismissStrategy: FusionDismissStrategy.onRelease,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('duration is only used')));
      });

      test('warns for activationMode none with dismissStrategy never', () {
        final config = FusionCrosshairConfiguration(
          activationMode: FusionCrosshairActivationMode.none,
          dismissStrategy: FusionDismissStrategy.never,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('programmatically')));
      });

      test('warns when showLabel false with label customizations', () {
        final config = FusionCrosshairConfiguration(
          showLabel: false,
          labelBackgroundColor: Colors.red,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('showLabel is false')));
      });
    });

    group('Helper Methods', () {
      test('shouldDismissOnRelease returns correct values', () {
        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.onRelease,
          ).shouldDismissOnRelease(),
          isTrue,
        );
        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.onTimer,
          ).shouldDismissOnRelease(),
          isFalse,
        );
        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.never,
          ).shouldDismissOnRelease(),
          isFalse,
        );
      });

      test('shouldUseTimer returns correct values', () {
        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.onTimer,
          ).shouldUseTimer(),
          isTrue,
        );
        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.smart,
          ).shouldUseTimer(),
          isTrue,
        );
        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.onRelease,
          ).shouldUseTimer(),
          isFalse,
        );
      });

      test('getDismissDelay returns correct values', () {
        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.onRelease,
          ).getDismissDelay(false),
          equals(Duration.zero),
        );

        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
            dismissDelay: const Duration(milliseconds: 500),
          ).getDismissDelay(false),
          equals(const Duration(milliseconds: 500)),
        );

        expect(
          FusionCrosshairConfiguration(
            dismissStrategy: FusionDismissStrategy.never,
          ).getDismissDelay(false).inDays,
          greaterThan(0),
        );
      });

      test('getFormattedXLabel uses formatter when provided', () {
        final config = FusionCrosshairConfiguration(
          xLabelFormatter: (value, point) => 'X: ${value.toInt()}',
        );

        expect(config.getFormattedXLabel(42.5, null), equals('X: 42'));
      });

      test('getFormattedYLabel uses formatter when provided', () {
        final config = FusionCrosshairConfiguration(
          yLabelFormatter: (value, point) => '\$${value.toStringAsFixed(2)}',
        );

        expect(config.getFormattedYLabel(123.456, null), equals('\$123.46'));
      });
    });

    group('Configuration Guide', () {
      test('configurationGuide contains documentation', () {
        final guide = FusionCrosshairConfiguration.configurationGuide;

        expect(guide, contains('Activation Modes'));
        expect(guide, contains('Dismiss Strategies'));
        expect(guide, contains('Line Configuration'));
        expect(guide, contains('Label Configuration'));
        expect(guide, contains('Recommended Configurations'));
      });
    });

    group('copyWith', () {
      test('preserves all values', () {
        final original = FusionCrosshairConfiguration(
          activationMode: FusionCrosshairActivationMode.hover,
          dismissStrategy: FusionDismissStrategy.never,
          lineWidth: 2.0,
          lineDashArray: [5, 5],
          showHorizontalLine: false,
          showLabel: false,
          labelBorderRadius: 8.0,
          fadeOutOnPanZoom: false,
        );

        final copied = original.copyWith();

        expect(copied.activationMode, equals(original.activationMode));
        expect(copied.dismissStrategy, equals(original.dismissStrategy));
        expect(copied.lineWidth, equals(original.lineWidth));
        expect(copied.lineDashArray, equals(original.lineDashArray));
        expect(copied.showHorizontalLine, equals(original.showHorizontalLine));
        expect(copied.showLabel, equals(original.showLabel));
        expect(copied.labelBorderRadius, equals(original.labelBorderRadius));
        expect(copied.fadeOutOnPanZoom, equals(original.fadeOutOnPanZoom));
      });

      test('overrides specific values', () {
        final original = FusionCrosshairConfiguration();
        final modified = original.copyWith(lineWidth: 3.0, showLabel: false);

        expect(modified.lineWidth, equals(3.0));
        expect(modified.showLabel, isFalse);
        expect(modified.activationMode, equals(original.activationMode));
      });
    });
  });

  group('FusionZoomConfiguration Tests', () {
    group('Constructor Assertions', () {
      test('throws when minZoomLevel is zero', () {
        expect(
          () => FusionZoomConfiguration(minZoomLevel: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when minZoomLevel is negative', () {
        expect(
          () => FusionZoomConfiguration(minZoomLevel: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when maxZoomLevel is zero', () {
        expect(
          () => FusionZoomConfiguration(maxZoomLevel: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when maxZoomLevel < minZoomLevel', () {
        expect(
          () => FusionZoomConfiguration(minZoomLevel: 2.0, maxZoomLevel: 1.0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows maxZoomLevel == minZoomLevel', () {
        expect(
          () => FusionZoomConfiguration(minZoomLevel: 1.0, maxZoomLevel: 1.0),
          returnsNormally,
        );
      });

      test('throws when zoomSpeed is zero', () {
        expect(
          () => FusionZoomConfiguration(zoomSpeed: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when zoomSpeed is negative', () {
        expect(
          () => FusionZoomConfiguration(zoomSpeed: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('validateConfiguration Method', () {
      test('warns when all zoom methods are disabled', () {
        final config = FusionZoomConfiguration(
          enablePinchZoom: false,
          enableMouseWheelZoom: false,
          enableSelectionZoom: false,
          enableDoubleTapZoom: false,
          enableZoomControls: false,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('All zoom methods are disabled')));
      });

      test('no warning when at least one zoom method is enabled', () {
        final config = FusionZoomConfiguration(
          enablePinchZoom: false,
          enableMouseWheelZoom: false,
          enableSelectionZoom: false,
          enableDoubleTapZoom: true,
          enableZoomControls: false,
        );

        final warnings = config.validateConfiguration();

        expect(
          warnings.where((w) => w.contains('All zoom methods are disabled')),
          isEmpty,
        );
      });

      test('warns when animation disabled but duration set', () {
        final config = FusionZoomConfiguration(
          animateZoom: false,
          zoomAnimationDuration: const Duration(milliseconds: 500),
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('animateZoom is false')));
      });

      test('warns when zoom range is very small', () {
        final config = FusionZoomConfiguration(
          minZoomLevel: 1.0,
          maxZoomLevel: 1.2,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('Zoom range is very small')));
      });

      test('warns when requireModifierForWheelZoom but wheel disabled', () {
        final config = FusionZoomConfiguration(
          enableMouseWheelZoom: false,
          requireModifierForWheelZoom: true,
        );

        final warnings = config.validateConfiguration();

        expect(
          warnings,
          contains(contains('requireModifierForWheelZoom is set')),
        );
      });

      test('warns when zoomSpeed is very low', () {
        final config = FusionZoomConfiguration(zoomSpeed: 0.05);

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('very low')));
      });

      test('warns when zoomSpeed is very high', () {
        final config = FusionZoomConfiguration(zoomSpeed: 10.0);

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('very high')));
      });
    });

    group('Configuration Guide', () {
      test('configurationGuide contains documentation', () {
        final guide = FusionZoomConfiguration.configurationGuide;

        expect(guide, contains('Zoom Methods'));
        expect(guide, contains('Zoom Levels'));
        expect(guide, contains('Zoom Mode'));
        expect(guide, contains('Animation'));
        expect(guide, contains('Recommended Configurations'));
      });
    });

    group('copyWith', () {
      test('preserves all values', () {
        final original = FusionZoomConfiguration(
          enablePinchZoom: false,
          enableMouseWheelZoom: false,
          requireModifierForWheelZoom: false,
          enableSelectionZoom: false,
          enableDoubleTapZoom: false,
          minZoomLevel: 0.25,
          maxZoomLevel: 10.0,
          zoomSpeed: 2.0,
          enableZoomControls: true,
          zoomMode: FusionZoomMode.x,
          animateZoom: false,
          zoomAnimationDuration: const Duration(milliseconds: 500),
          zoomAnimationCurve: Curves.bounceOut,
        );

        final copied = original.copyWith();

        expect(copied.enablePinchZoom, equals(original.enablePinchZoom));
        expect(
          copied.enableMouseWheelZoom,
          equals(original.enableMouseWheelZoom),
        );
        expect(copied.minZoomLevel, equals(original.minZoomLevel));
        expect(copied.maxZoomLevel, equals(original.maxZoomLevel));
        expect(copied.zoomSpeed, equals(original.zoomSpeed));
        expect(copied.zoomMode, equals(original.zoomMode));
        expect(copied.animateZoom, equals(original.animateZoom));
      });

      test('overrides specific values', () {
        final original = FusionZoomConfiguration();
        final modified = original.copyWith(
          minZoomLevel: 0.25,
          maxZoomLevel: 20.0,
        );

        expect(modified.minZoomLevel, equals(0.25));
        expect(modified.maxZoomLevel, equals(20.0));
        expect(modified.enablePinchZoom, equals(original.enablePinchZoom));
      });
    });
  });

  group('FusionPanConfiguration Tests', () {
    group('Constructor Assertions', () {
      test('throws when inertiaDecay is negative', () {
        expect(
          () => FusionPanConfiguration(inertiaDecay: -0.1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when inertiaDecay is greater than 1', () {
        expect(
          () => FusionPanConfiguration(inertiaDecay: 1.1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows inertiaDecay at boundaries', () {
        expect(() => FusionPanConfiguration(inertiaDecay: 0), returnsNormally);
        expect(() => FusionPanConfiguration(inertiaDecay: 1), returnsNormally);
      });
    });

    group('validateConfiguration Method', () {
      test('warns when inertia disabled but duration set', () {
        final config = FusionPanConfiguration(
          enableInertia: false,
          inertiaDuration: const Duration(seconds: 1),
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('enableInertia is false')));
        expect(warnings, contains(contains('inertiaDuration')));
      });

      test('warns when inertia disabled but decay set', () {
        final config = FusionPanConfiguration(
          enableInertia: false,
          inertiaDecay: 0.8,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('enableInertia is false')));
        expect(warnings, contains(contains('inertiaDecay')));
      });

      test('warns when inertiaDecay is very low', () {
        final config = FusionPanConfiguration(
          enableInertia: true,
          inertiaDecay: 0.3,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('very low')));
      });

      test('warns when inertiaDecay is very high', () {
        final config = FusionPanConfiguration(
          enableInertia: true,
          inertiaDecay: 0.995,
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('very high')));
      });

      test('warns when inertiaDuration is very short', () {
        final config = FusionPanConfiguration(
          enableInertia: true,
          inertiaDuration: const Duration(milliseconds: 50),
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('very short')));
      });

      test('warns when inertiaDuration is very long', () {
        final config = FusionPanConfiguration(
          enableInertia: true,
          inertiaDuration: const Duration(seconds: 5),
        );

        final warnings = config.validateConfiguration();

        expect(warnings, contains(contains('very long')));
      });

      test('no warnings for default configuration', () {
        final config = FusionPanConfiguration();

        final warnings = config.validateConfiguration();

        expect(warnings, isEmpty);
      });
    });

    group('Configuration Guide', () {
      test('configurationGuide contains documentation', () {
        final guide = FusionPanConfiguration.configurationGuide;

        expect(guide, contains('Pan Mode'));
        expect(guide, contains('Inertia'));
        expect(guide, contains('Edge Behavior'));
        expect(guide, contains('Recommended Configurations'));
      });
    });

    group('copyWith', () {
      test('preserves all values', () {
        final original = FusionPanConfiguration(
          panMode: FusionPanMode.x,
          enableInertia: false,
          inertiaDuration: const Duration(seconds: 1),
          inertiaDecay: 0.8,
          edgeBehavior: FusionPanEdgeBehavior.clamp,
        );

        final copied = original.copyWith();

        expect(copied.panMode, equals(original.panMode));
        expect(copied.enableInertia, equals(original.enableInertia));
        expect(copied.inertiaDuration, equals(original.inertiaDuration));
        expect(copied.inertiaDecay, equals(original.inertiaDecay));
        expect(copied.edgeBehavior, equals(original.edgeBehavior));
      });

      test('overrides specific values', () {
        final original = FusionPanConfiguration();
        final modified = original.copyWith(
          panMode: FusionPanMode.y,
          enableInertia: false,
        );

        expect(modified.panMode, equals(FusionPanMode.y));
        expect(modified.enableInertia, isFalse);
        expect(modified.edgeBehavior, equals(original.edgeBehavior));
      });
    });
  });

  group('Configuration Combinations', () {
    test('crosshair with zoom and pan configs work together', () {
      // Create all configs with custom values
      final crosshairConfig = FusionCrosshairConfiguration(
        activationMode: FusionCrosshairActivationMode.longPress,
        fadeOutOnPanZoom: true,
      );

      final zoomConfig = FusionZoomConfiguration(
        enablePinchZoom: true,
        minZoomLevel: 0.5,
        maxZoomLevel: 10.0,
      );

      final panConfig = FusionPanConfiguration(
        panMode: FusionPanMode.both,
        enableInertia: true,
      );

      // Validate all configurations
      expect(crosshairConfig.validateConfiguration(), isEmpty);
      expect(zoomConfig.validateConfiguration(), isEmpty);
      expect(panConfig.validateConfiguration(), isEmpty);

      // Assert all are valid
      crosshairConfig.assertValid();
      zoomConfig.assertValid();
      panConfig.assertValid();
    });

    test('financial chart recommended configuration', () {
      final crosshairConfig = FusionCrosshairConfiguration(
        activationMode: FusionCrosshairActivationMode.longPress,
        dismissStrategy: FusionDismissStrategy.onTimer,
        duration: const Duration(seconds: 5),
        snapToDataPoint: true,
        lineDashArray: [5, 5],
      );

      final zoomConfig = FusionZoomConfiguration(
        zoomMode: FusionZoomMode.x,
        enableSelectionZoom: true,
        minZoomLevel: 1.0,
        maxZoomLevel: 20.0,
      );

      final panConfig = FusionPanConfiguration(
        panMode: FusionPanMode.x,
        enableInertia: true,
      );

      crosshairConfig.assertValid();
      zoomConfig.assertValid();
      panConfig.assertValid();

      expect(crosshairConfig.validateConfiguration(), isEmpty);
      expect(zoomConfig.validateConfiguration(), isEmpty);
      expect(panConfig.validateConfiguration(), isEmpty);
    });

    test('read-only chart configuration', () {
      final crosshairConfig = FusionCrosshairConfiguration(
        activationMode: FusionCrosshairActivationMode.hover,
      );

      final zoomConfig = FusionZoomConfiguration(
        enablePinchZoom: false,
        enableMouseWheelZoom: false,
        requireModifierForWheelZoom:
            false, // Set to false to avoid extra warning
        enableSelectionZoom: false,
        enableDoubleTapZoom: false,
        enableZoomControls: false,
      );

      // Pan disabled would be done at chart level

      crosshairConfig.assertValid();
      zoomConfig.assertValid();

      // Zoom config will warn about all methods disabled
      final zoomWarnings = zoomConfig.validateConfiguration();
      expect(zoomWarnings.length, equals(1));
      expect(zoomWarnings.first, contains('All zoom methods are disabled'));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_crosshair_configuration.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_dismiss_strategy.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';

void main() {
  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionCrosshairConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionCrosshairConfiguration();

      expect(config.activationMode, FusionCrosshairActivationMode.longPress);
      expect(config.dismissStrategy, FusionDismissStrategy.onRelease);
      expect(config.dismissDelay, const Duration(milliseconds: 300));
      expect(config.duration, const Duration(milliseconds: 3000));
      expect(config.snapToDataPoint, isTrue);
      expect(config.lineColor, isNull);
      expect(config.lineWidth, 1.0);
      expect(config.lineDashArray, isNull);
      expect(config.showHorizontalLine, isTrue);
      expect(config.showVerticalLine, isTrue);
      expect(config.showLabel, isTrue);
      expect(config.labelBackgroundColor, isNull);
      expect(config.labelTextStyle, isNull);
      expect(
        config.labelPadding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
      expect(config.labelBorderRadius, 4.0);
      expect(config.xLabelFormatter, isNull);
      expect(config.yLabelFormatter, isNull);
      expect(config.labelBuilder, isNull);
      expect(config.animationDuration, const Duration(milliseconds: 200));
      expect(config.animationCurve, Curves.easeOutCubic);
      expect(config.exitAnimationCurve, Curves.easeInCubic);
      expect(config.fadeOutOnPanZoom, isTrue);
    });

    test('creates with custom values', () {
      const config = FusionCrosshairConfiguration(
        activationMode: FusionCrosshairActivationMode.hover,
        dismissStrategy: FusionDismissStrategy.onTimer,
        dismissDelay: Duration(milliseconds: 500),
        duration: Duration(milliseconds: 5000),
        snapToDataPoint: false,
        lineColor: Colors.red,
        lineWidth: 2.0,
        lineDashArray: [5, 5],
        showHorizontalLine: false,
        showVerticalLine: true,
        showLabel: false,
        labelBackgroundColor: Colors.black,
        labelTextStyle: TextStyle(color: Colors.white),
        labelPadding: EdgeInsets.all(8),
        labelBorderRadius: 8.0,
        animationDuration: Duration(milliseconds: 300),
        animationCurve: Curves.linear,
        exitAnimationCurve: Curves.easeOut,
        fadeOutOnPanZoom: false,
      );

      expect(config.activationMode, FusionCrosshairActivationMode.hover);
      expect(config.dismissStrategy, FusionDismissStrategy.onTimer);
      expect(config.dismissDelay, const Duration(milliseconds: 500));
      expect(config.duration, const Duration(milliseconds: 5000));
      expect(config.snapToDataPoint, isFalse);
      expect(config.lineColor, Colors.red);
      expect(config.lineWidth, 2.0);
      expect(config.lineDashArray, [5, 5]);
      expect(config.showHorizontalLine, isFalse);
      expect(config.showVerticalLine, isTrue);
      expect(config.showLabel, isFalse);
      expect(config.labelBackgroundColor, Colors.black);
      expect(config.labelTextStyle, const TextStyle(color: Colors.white));
      expect(config.labelPadding, const EdgeInsets.all(8));
      expect(config.labelBorderRadius, 8.0);
      expect(config.animationDuration, const Duration(milliseconds: 300));
      expect(config.animationCurve, Curves.linear);
      expect(config.exitAnimationCurve, Curves.easeOut);
      expect(config.fadeOutOnPanZoom, isFalse);
    });

    test('creates with label formatters', () {
      String xFormatter(double value, FusionDataPoint? point) => 'X: $value';
      String yFormatter(double value, FusionDataPoint? point) => 'Y: $value';

      final config = FusionCrosshairConfiguration(
        xLabelFormatter: xFormatter,
        yLabelFormatter: yFormatter,
      );

      expect(config.xLabelFormatter, isNotNull);
      expect(config.yLabelFormatter, isNotNull);
    });

    test('creates with label builder', () {
      Widget? builder(
        BuildContext context,
        FusionDataPoint? point,
        bool isXAxis,
      ) {
        return const SizedBox();
      }

      final config = FusionCrosshairConfiguration(labelBuilder: builder);

      expect(config.labelBuilder, isNotNull);
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - ASSERTIONS
  // ===========================================================================
  group('FusionCrosshairConfiguration - Assertions', () {
    test('throws on invalid lineWidth', () {
      expect(
        () => FusionCrosshairConfiguration(lineWidth: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionCrosshairConfiguration(lineWidth: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid labelBorderRadius', () {
      expect(
        () => FusionCrosshairConfiguration(labelBorderRadius: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - DISMISS HELPER METHODS
  // ===========================================================================
  group('FusionCrosshairConfiguration - Dismiss Helper Methods', () {
    test('shouldDismissOnRelease returns correct values', () {
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onRelease,
        ).shouldDismissOnRelease(),
        isTrue,
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
        ).shouldDismissOnRelease(),
        isTrue,
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.smart,
        ).shouldDismissOnRelease(),
        isTrue,
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onTimer,
        ).shouldDismissOnRelease(),
        isFalse,
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.never,
        ).shouldDismissOnRelease(),
        isFalse,
      );
    });

    test('shouldUseTimer returns correct values', () {
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onTimer,
        ).shouldUseTimer(),
        isTrue,
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.smart,
        ).shouldUseTimer(),
        isTrue,
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onRelease,
        ).shouldUseTimer(),
        isFalse,
      );
    });

    test('getDismissDelay returns correct values', () {
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onRelease,
        ).getDismissDelay(false),
        Duration.zero,
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
          dismissDelay: Duration(milliseconds: 500),
        ).getDismissDelay(false),
        const Duration(milliseconds: 500),
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.onTimer,
          duration: Duration(milliseconds: 5000),
        ).getDismissDelay(false),
        const Duration(milliseconds: 5000),
      );
      expect(
        const FusionCrosshairConfiguration(
          dismissStrategy: FusionDismissStrategy.never,
        ).getDismissDelay(false),
        const Duration(days: 365),
      );

      const smartConfig = FusionCrosshairConfiguration(
        dismissStrategy: FusionDismissStrategy.smart,
        dismissDelay: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 3000),
      );
      expect(
        smartConfig.getDismissDelay(false),
        const Duration(milliseconds: 300),
      );
      expect(
        smartConfig.getDismissDelay(true),
        const Duration(milliseconds: 3000),
      );
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionCrosshairConfiguration - Computed Properties', () {
    testWidgets('getEffectiveLineColor returns correct color', (tester) async {
      const config = FusionCrosshairConfiguration();
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(config.getEffectiveLineColor(capturedContext, null), Colors.grey);
      expect(
        config.getEffectiveLineColor(capturedContext, Colors.blue),
        Colors.blue,
      );

      const configWithColor = FusionCrosshairConfiguration(
        lineColor: Colors.red,
      );
      expect(
        configWithColor.getEffectiveLineColor(capturedContext, Colors.blue),
        Colors.red,
      );
    });

    testWidgets('getEffectiveLabelBackgroundColor returns correct color', (
      tester,
    ) async {
      const config = FusionCrosshairConfiguration();
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        config.getEffectiveLabelBackgroundColor(capturedContext),
        Colors.black87,
      );

      const configWithColor = FusionCrosshairConfiguration(
        labelBackgroundColor: Colors.blue,
      );
      expect(
        configWithColor.getEffectiveLabelBackgroundColor(capturedContext),
        Colors.blue,
      );
    });

    testWidgets('getEffectiveLabelTextStyle returns correct style', (
      tester,
    ) async {
      const config = FusionCrosshairConfiguration();
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      final style = config.getEffectiveLabelTextStyle(capturedContext);
      expect(style.color, Colors.white);
      expect(style.fontSize, 11);

      const customStyle = TextStyle(color: Colors.red, fontSize: 14);
      const configWithStyle = FusionCrosshairConfiguration(
        labelTextStyle: customStyle,
      );
      expect(
        configWithStyle.getEffectiveLabelTextStyle(capturedContext),
        customStyle,
      );
    });

    test('getFormattedXLabel returns correct text', () {
      const config = FusionCrosshairConfiguration();
      expect(config.getFormattedXLabel(10.5, null), '10.5');
      expect(
        config.getFormattedXLabel(
          10.5,
          const FusionDataPoint(10.5, 20, label: 'Custom'),
        ),
        'Custom',
      );

      final configWithFormatter = FusionCrosshairConfiguration(
        xLabelFormatter: (value, point) => 'X: \${value.toInt()}',
      );
      expect(
        configWithFormatter.getFormattedXLabel(10.5, null),
        'X: \${value.toInt()}',
      );
    });

    test('getFormattedYLabel returns correct text', () {
      const config = FusionCrosshairConfiguration();
      expect(config.getFormattedYLabel(10.5, null), '10.5');

      final configWithFormatter = FusionCrosshairConfiguration(
        yLabelFormatter: (value, point) => '\$${value.toStringAsFixed(2)}',
      );
      expect(configWithFormatter.getFormattedYLabel(10.5, null), '\$10.50');
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - VALIDATE CONFIGURATION
  // ===========================================================================
  group('FusionCrosshairConfiguration - validateConfiguration', () {
    test('returns warning when both lines hidden', () {
      const config = FusionCrosshairConfiguration(
        showHorizontalLine: false,
        showVerticalLine: false,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('will not display any lines')),
        isTrue,
      );
    });

    test('returns warning for labelBuilder with formatters', () {
      final config = FusionCrosshairConfiguration(
        showLabel: true,
        labelBuilder: (ctx, point, isX) => null,
        xLabelFormatter: (v, p) => 'X',
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('labelBuilder takes precedence')),
        isTrue,
      );
    });

    test('returns warning for empty lineDashArray', () {
      const config = FusionCrosshairConfiguration(lineDashArray: []);
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('lineDashArray is empty')), isTrue);
    });

    test('returns warning for dismissDelay with wrong strategy', () {
      const config = FusionCrosshairConfiguration(
        dismissStrategy: FusionDismissStrategy.never,
        dismissDelay: Duration(milliseconds: 500),
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('dismissDelay is only used')),
        isTrue,
      );
    });

    test('returns warning for duration with wrong strategy', () {
      const config = FusionCrosshairConfiguration(
        dismissStrategy: FusionDismissStrategy.never,
        duration: Duration(milliseconds: 5000),
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('duration is only used')), isTrue);
    });

    test('returns warning for none activation with never dismiss', () {
      const config = FusionCrosshairConfiguration(
        activationMode: FusionCrosshairActivationMode.none,
        dismissStrategy: FusionDismissStrategy.never,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('activationMode: none with dismissStrategy: never'),
        ),
        isTrue,
      );
    });

    test('returns warning for showLabel false with customizations', () {
      const config = FusionCrosshairConfiguration(
        showLabel: false,
        labelBackgroundColor: Colors.blue,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('showLabel is false but label customizations'),
        ),
        isTrue,
      );
    });

    test('returns empty for valid configuration', () {
      const config = FusionCrosshairConfiguration(
        showHorizontalLine: true,
        showVerticalLine: true,
        showLabel: true,
        dismissStrategy: FusionDismissStrategy.onRelease,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isEmpty);
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - ASSERT VALID
  // ===========================================================================
  group('FusionCrosshairConfiguration - assertValid', () {
    test('passes for valid configuration', () {
      const config = FusionCrosshairConfiguration();
      expect(() => config.assertValid(), returnsNormally);
    });

    test('throws for empty lineDashArray', () {
      const config = FusionCrosshairConfiguration(lineDashArray: []);
      expect(() => config.assertValid(), throwsA(isA<AssertionError>()));
    });

    test('throws for negative values in lineDashArray', () {
      const config = FusionCrosshairConfiguration(lineDashArray: [5, -2]);
      expect(() => config.assertValid(), throwsA(isA<AssertionError>()));
    });

    test('throws for zero values in lineDashArray', () {
      const config = FusionCrosshairConfiguration(lineDashArray: [5, 0]);
      expect(() => config.assertValid(), throwsA(isA<AssertionError>()));
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - CONFIGURATION GUIDE
  // ===========================================================================
  group('FusionCrosshairConfiguration - configurationGuide', () {
    test('returns non-empty guide', () {
      expect(FusionCrosshairConfiguration.configurationGuide, isNotEmpty);
      expect(
        FusionCrosshairConfiguration.configurationGuide,
        contains('Activation Modes'),
      );
      expect(
        FusionCrosshairConfiguration.configurationGuide,
        contains('Dismiss Strategies'),
      );
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionCrosshairConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionCrosshairConfiguration(
        lineWidth: 1.0,
        showLabel: true,
      );

      final copy = original.copyWith(lineWidth: 2.0, showLabel: false);

      expect(copy.lineWidth, 2.0);
      expect(copy.showLabel, isFalse);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionCrosshairConfiguration(
        lineWidth: 2.0,
        showLabel: false,
        labelBorderRadius: 8.0,
      );

      final copy = original.copyWith(lineWidth: 3.0);

      expect(copy.lineWidth, 3.0);
      expect(copy.showLabel, isFalse);
      expect(copy.labelBorderRadius, 8.0);
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR CONFIGURATION - TOSTRING
  // ===========================================================================
  group('FusionCrosshairConfiguration - toString', () {
    test('toString returns descriptive string', () {
      const config = FusionCrosshairConfiguration(
        activationMode: FusionCrosshairActivationMode.hover,
        dismissStrategy: FusionDismissStrategy.onTimer,
      );

      final str = config.toString();

      expect(str, contains('FusionCrosshairConfiguration'));
      expect(str, contains('activationMode'));
      expect(str, contains('dismissStrategy'));
    });
  });

  // ===========================================================================
  // FUSION CROSSHAIR ACTIVATION MODE ENUM
  // ===========================================================================
  group('FusionCrosshairActivationMode - Enum', () {
    test('has all expected values', () {
      expect(FusionCrosshairActivationMode.values, hasLength(5));
      expect(
        FusionCrosshairActivationMode.values,
        contains(FusionCrosshairActivationMode.tap),
      );
      expect(
        FusionCrosshairActivationMode.values,
        contains(FusionCrosshairActivationMode.longPress),
      );
      expect(
        FusionCrosshairActivationMode.values,
        contains(FusionCrosshairActivationMode.hover),
      );
      expect(
        FusionCrosshairActivationMode.values,
        contains(FusionCrosshairActivationMode.always),
      );
      expect(
        FusionCrosshairActivationMode.values,
        contains(FusionCrosshairActivationMode.none),
      );
    });
  });
}

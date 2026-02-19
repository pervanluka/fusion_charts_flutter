import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  // ===========================================================================
  // FUSION ZOOM CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionZoomConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionZoomConfiguration();

      expect(config.enablePinchZoom, isTrue);
      expect(config.enableMouseWheelZoom, isTrue);
      expect(config.requireModifierForWheelZoom, isTrue);
      expect(config.enableSelectionZoom, isTrue);
      expect(config.enableDoubleTapZoom, isTrue);
      expect(config.minZoomLevel, 0.5);
      expect(config.maxZoomLevel, 5.0);
      expect(config.zoomSpeed, 1.0);
      expect(config.enableZoomControls, isFalse);
      expect(config.zoomMode, FusionZoomMode.both);
      expect(config.animateZoom, isTrue);
      expect(config.zoomAnimationDuration, const Duration(milliseconds: 300));
      expect(config.zoomAnimationCurve, Curves.easeInOut);
    });

    test('creates with custom values', () {
      const config = FusionZoomConfiguration(
        enablePinchZoom: false,
        enableMouseWheelZoom: false,
        requireModifierForWheelZoom: false,
        enableSelectionZoom: false,
        enableDoubleTapZoom: false,
        minZoomLevel: 1.0,
        maxZoomLevel: 20.0,
        zoomSpeed: 2.0,
        enableZoomControls: true,
        zoomMode: FusionZoomMode.x,
        animateZoom: false,
        zoomAnimationDuration: Duration(milliseconds: 500),
        zoomAnimationCurve: Curves.bounceOut,
      );

      expect(config.enablePinchZoom, isFalse);
      expect(config.enableMouseWheelZoom, isFalse);
      expect(config.requireModifierForWheelZoom, isFalse);
      expect(config.enableSelectionZoom, isFalse);
      expect(config.enableDoubleTapZoom, isFalse);
      expect(config.minZoomLevel, 1.0);
      expect(config.maxZoomLevel, 20.0);
      expect(config.zoomSpeed, 2.0);
      expect(config.enableZoomControls, isTrue);
      expect(config.zoomMode, FusionZoomMode.x);
      expect(config.animateZoom, isFalse);
      expect(config.zoomAnimationDuration, const Duration(milliseconds: 500));
      expect(config.zoomAnimationCurve, Curves.bounceOut);
    });
  });

  // ===========================================================================
  // FUSION ZOOM CONFIGURATION - ASSERTIONS
  // ===========================================================================
  group('FusionZoomConfiguration - Assertions', () {
    test('throws on invalid minZoomLevel', () {
      expect(
        () => FusionZoomConfiguration(minZoomLevel: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionZoomConfiguration(minZoomLevel: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid maxZoomLevel', () {
      expect(
        () => FusionZoomConfiguration(maxZoomLevel: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionZoomConfiguration(maxZoomLevel: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws when maxZoomLevel < minZoomLevel', () {
      expect(
        () => FusionZoomConfiguration(minZoomLevel: 5.0, maxZoomLevel: 2.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid zoomSpeed', () {
      expect(
        () => FusionZoomConfiguration(zoomSpeed: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionZoomConfiguration(zoomSpeed: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ===========================================================================
  // FUSION ZOOM CONFIGURATION - VALIDATE CONFIGURATION
  // ===========================================================================
  group('FusionZoomConfiguration - validateConfiguration', () {
    test('returns warning when all zoom methods disabled', () {
      const config = FusionZoomConfiguration(
        enablePinchZoom: false,
        enableMouseWheelZoom: false,
        enableSelectionZoom: false,
        enableDoubleTapZoom: false,
        enableZoomControls: false,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('All zoom methods are disabled')),
        isTrue,
      );
    });

    test('returns warning for animation duration with animation disabled', () {
      const config = FusionZoomConfiguration(
        animateZoom: false,
        zoomAnimationDuration: Duration(milliseconds: 500),
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('animateZoom is false but zoomAnimationDuration'),
        ),
        isTrue,
      );
    });

    test('returns warning for small zoom range', () {
      const config = FusionZoomConfiguration(
        minZoomLevel: 1.0,
        maxZoomLevel: 1.3,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any((w) => w.contains('Zoom range is very small')),
        isTrue,
      );
    });

    test('returns warning for requireModifier with mouseWheel disabled', () {
      const config = FusionZoomConfiguration(
        enableMouseWheelZoom: false,
        requireModifierForWheelZoom: true,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('requireModifierForWheelZoom is set but'),
        ),
        isTrue,
      );
    });

    test('returns warning for very low zoomSpeed', () {
      const config = FusionZoomConfiguration(zoomSpeed: 0.05);
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('is very low')), isTrue);
    });

    test('returns warning for very high zoomSpeed', () {
      const config = FusionZoomConfiguration(zoomSpeed: 10.0);
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('is very high')), isTrue);
    });

    test('returns empty for valid configuration', () {
      const config = FusionZoomConfiguration(
        enablePinchZoom: true,
        minZoomLevel: 0.5,
        maxZoomLevel: 5.0,
        zoomSpeed: 1.0,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isEmpty);
    });
  });

  // ===========================================================================
  // FUSION ZOOM CONFIGURATION - ASSERT VALID
  // ===========================================================================
  group('FusionZoomConfiguration - assertValid', () {
    test('passes for valid configuration', () {
      const config = FusionZoomConfiguration();
      expect(() => config.assertValid(), returnsNormally);
    });
  });

  // ===========================================================================
  // FUSION ZOOM CONFIGURATION - CONFIGURATION GUIDE
  // ===========================================================================
  group('FusionZoomConfiguration - configurationGuide', () {
    test('returns non-empty guide', () {
      expect(FusionZoomConfiguration.configurationGuide, isNotEmpty);
      expect(
        FusionZoomConfiguration.configurationGuide,
        contains('Zoom Methods'),
      );
      expect(
        FusionZoomConfiguration.configurationGuide,
        contains('Zoom Levels'),
      );
      expect(FusionZoomConfiguration.configurationGuide, contains('Zoom Mode'));
    });
  });

  // ===========================================================================
  // FUSION ZOOM CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionZoomConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionZoomConfiguration(
        minZoomLevel: 0.5,
        maxZoomLevel: 5.0,
      );

      final copy = original.copyWith(minZoomLevel: 1.0, maxZoomLevel: 10.0);

      expect(copy.minZoomLevel, 1.0);
      expect(copy.maxZoomLevel, 10.0);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionZoomConfiguration(
        minZoomLevel: 0.5,
        maxZoomLevel: 5.0,
        zoomSpeed: 2.0,
        enablePinchZoom: false,
      );

      final copy = original.copyWith(minZoomLevel: 1.0);

      expect(copy.minZoomLevel, 1.0);
      expect(copy.maxZoomLevel, 5.0);
      expect(copy.zoomSpeed, 2.0);
      expect(copy.enablePinchZoom, isFalse);
    });

    test('copyWith handles all parameters', () {
      const original = FusionZoomConfiguration();

      final copy = original.copyWith(
        enablePinchZoom: false,
        enableMouseWheelZoom: false,
        requireModifierForWheelZoom: false,
        enableSelectionZoom: false,
        enableDoubleTapZoom: false,
        minZoomLevel: 1.0,
        maxZoomLevel: 15.0,
        zoomSpeed: 1.5,
        enableZoomControls: true,
        zoomMode: FusionZoomMode.y,
        animateZoom: false,
        zoomAnimationDuration: const Duration(milliseconds: 400),
        zoomAnimationCurve: Curves.linear,
      );

      expect(copy.enablePinchZoom, isFalse);
      expect(copy.enableMouseWheelZoom, isFalse);
      expect(copy.requireModifierForWheelZoom, isFalse);
      expect(copy.enableSelectionZoom, isFalse);
      expect(copy.enableDoubleTapZoom, isFalse);
      expect(copy.minZoomLevel, 1.0);
      expect(copy.maxZoomLevel, 15.0);
      expect(copy.zoomSpeed, 1.5);
      expect(copy.enableZoomControls, isTrue);
      expect(copy.zoomMode, FusionZoomMode.y);
      expect(copy.animateZoom, isFalse);
      expect(copy.zoomAnimationDuration, const Duration(milliseconds: 400));
      expect(copy.zoomAnimationCurve, Curves.linear);
    });
  });

  // ===========================================================================
  // FUSION ZOOM MODE ENUM
  // ===========================================================================
  group('FusionZoomMode - Enum', () {
    test('has all expected values', () {
      expect(FusionZoomMode.values, hasLength(4));
      expect(FusionZoomMode.values, contains(FusionZoomMode.both));
      expect(FusionZoomMode.values, contains(FusionZoomMode.x));
      expect(FusionZoomMode.values, contains(FusionZoomMode.y));
      expect(FusionZoomMode.values, contains(FusionZoomMode.none));
    });
  });

  // ===========================================================================
  // FUSION PAN CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionPanConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionPanConfiguration();

      expect(config.panMode, FusionPanMode.both);
      expect(config.enableInertia, isTrue);
      expect(config.inertiaDuration, const Duration(milliseconds: 500));
      expect(config.inertiaDecay, 0.95);
      expect(config.edgeBehavior, FusionPanEdgeBehavior.bounce);
    });

    test('creates with custom values', () {
      const config = FusionPanConfiguration(
        panMode: FusionPanMode.x,
        enableInertia: false,
        inertiaDuration: Duration(milliseconds: 1000),
        inertiaDecay: 0.9,
        edgeBehavior: FusionPanEdgeBehavior.clamp,
      );

      expect(config.panMode, FusionPanMode.x);
      expect(config.enableInertia, isFalse);
      expect(config.inertiaDuration, const Duration(milliseconds: 1000));
      expect(config.inertiaDecay, 0.9);
      expect(config.edgeBehavior, FusionPanEdgeBehavior.clamp);
    });
  });

  // ===========================================================================
  // FUSION PAN CONFIGURATION - ASSERTIONS
  // ===========================================================================
  group('FusionPanConfiguration - Assertions', () {
    test('throws on invalid inertiaDecay (< 0)', () {
      expect(
        () => FusionPanConfiguration(inertiaDecay: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on invalid inertiaDecay (> 1)', () {
      expect(
        () => FusionPanConfiguration(inertiaDecay: 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts valid inertiaDecay boundary values', () {
      expect(() => FusionPanConfiguration(inertiaDecay: 0), returnsNormally);
      expect(() => FusionPanConfiguration(inertiaDecay: 1), returnsNormally);
    });
  });

  // ===========================================================================
  // FUSION PAN CONFIGURATION - VALIDATE CONFIGURATION
  // ===========================================================================
  group('FusionPanConfiguration - validateConfiguration', () {
    test('returns warning for inertiaDuration with inertia disabled', () {
      const config = FusionPanConfiguration(
        enableInertia: false,
        inertiaDuration: Duration(milliseconds: 1000),
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('enableInertia is false but inertiaDuration'),
        ),
        isTrue,
      );
    });

    test('returns warning for inertiaDecay with inertia disabled', () {
      const config = FusionPanConfiguration(
        enableInertia: false,
        inertiaDecay: 0.8,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(
        warnings.any(
          (w) => w.contains('enableInertia is false but inertiaDecay'),
        ),
        isTrue,
      );
    });

    test('returns warning for very low inertiaDecay', () {
      const config = FusionPanConfiguration(
        enableInertia: true,
        inertiaDecay: 0.3,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('is very low')), isTrue);
    });

    test('returns warning for very high inertiaDecay', () {
      const config = FusionPanConfiguration(
        enableInertia: true,
        inertiaDecay: 0.995,
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('is very high')), isTrue);
    });

    test('returns warning for very short inertiaDuration', () {
      const config = FusionPanConfiguration(
        enableInertia: true,
        inertiaDuration: Duration(milliseconds: 50),
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('is very short')), isTrue);
    });

    test('returns warning for very long inertiaDuration', () {
      const config = FusionPanConfiguration(
        enableInertia: true,
        inertiaDuration: Duration(milliseconds: 3000),
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isNotEmpty);
      expect(warnings.any((w) => w.contains('is very long')), isTrue);
    });

    test('returns empty for valid configuration', () {
      const config = FusionPanConfiguration(
        panMode: FusionPanMode.both,
        enableInertia: true,
        inertiaDecay: 0.95,
        inertiaDuration: Duration(milliseconds: 500),
      );
      final warnings = config.validateConfiguration();

      expect(warnings, isEmpty);
    });
  });

  // ===========================================================================
  // FUSION PAN CONFIGURATION - ASSERT VALID
  // ===========================================================================
  group('FusionPanConfiguration - assertValid', () {
    test('passes for valid configuration', () {
      const config = FusionPanConfiguration();
      expect(() => config.assertValid(), returnsNormally);
    });
  });

  // ===========================================================================
  // FUSION PAN CONFIGURATION - CONFIGURATION GUIDE
  // ===========================================================================
  group('FusionPanConfiguration - configurationGuide', () {
    test('returns non-empty guide', () {
      expect(FusionPanConfiguration.configurationGuide, isNotEmpty);
      expect(FusionPanConfiguration.configurationGuide, contains('Pan Mode'));
      expect(FusionPanConfiguration.configurationGuide, contains('Inertia'));
      expect(
        FusionPanConfiguration.configurationGuide,
        contains('Edge Behavior'),
      );
    });
  });

  // ===========================================================================
  // FUSION PAN CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionPanConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionPanConfiguration(
        panMode: FusionPanMode.both,
        enableInertia: true,
      );

      final copy = original.copyWith(
        panMode: FusionPanMode.x,
        enableInertia: false,
      );

      expect(copy.panMode, FusionPanMode.x);
      expect(copy.enableInertia, isFalse);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionPanConfiguration(
        panMode: FusionPanMode.x,
        enableInertia: false,
        inertiaDecay: 0.9,
        edgeBehavior: FusionPanEdgeBehavior.clamp,
      );

      final copy = original.copyWith(panMode: FusionPanMode.y);

      expect(copy.panMode, FusionPanMode.y);
      expect(copy.enableInertia, isFalse);
      expect(copy.inertiaDecay, 0.9);
      expect(copy.edgeBehavior, FusionPanEdgeBehavior.clamp);
    });

    test('copyWith handles all parameters', () {
      const original = FusionPanConfiguration();

      final copy = original.copyWith(
        panMode: FusionPanMode.y,
        enableInertia: false,
        inertiaDuration: const Duration(milliseconds: 800),
        inertiaDecay: 0.85,
        edgeBehavior: FusionPanEdgeBehavior.free,
      );

      expect(copy.panMode, FusionPanMode.y);
      expect(copy.enableInertia, isFalse);
      expect(copy.inertiaDuration, const Duration(milliseconds: 800));
      expect(copy.inertiaDecay, 0.85);
      expect(copy.edgeBehavior, FusionPanEdgeBehavior.free);
    });
  });

  // ===========================================================================
  // FUSION PAN MODE ENUM
  // ===========================================================================
  group('FusionPanMode - Enum', () {
    test('has all expected values', () {
      expect(FusionPanMode.values, hasLength(4));
      expect(FusionPanMode.values, contains(FusionPanMode.both));
      expect(FusionPanMode.values, contains(FusionPanMode.x));
      expect(FusionPanMode.values, contains(FusionPanMode.y));
      expect(FusionPanMode.values, contains(FusionPanMode.none));
    });
  });

  // ===========================================================================
  // FUSION PAN EDGE BEHAVIOR ENUM
  // ===========================================================================
  group('FusionPanEdgeBehavior - Enum', () {
    test('has all expected values', () {
      expect(FusionPanEdgeBehavior.values, hasLength(3));
      expect(
        FusionPanEdgeBehavior.values,
        contains(FusionPanEdgeBehavior.bounce),
      );
      expect(
        FusionPanEdgeBehavior.values,
        contains(FusionPanEdgeBehavior.clamp),
      );
      expect(
        FusionPanEdgeBehavior.values,
        contains(FusionPanEdgeBehavior.free),
      );
    });
  });
}

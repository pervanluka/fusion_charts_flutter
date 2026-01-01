import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('AxisCalculator', () {
    group('calculateNiceInterval', () {
      test('returns nice interval for typical range', () {
        // Import the internal utility via ChartBoundsCalculator
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 0,
          dataMaxY: 100,
        );
        
        // Should produce nice intervals like 20, 25, etc.
        final interval = bounds.maxY / 5; // Rough estimate
        expect(interval, greaterThan(0));
      });

      test('handles very small ranges', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 0.001,
          dataMaxY: 0.005,
        );
        
        expect(bounds.maxY, greaterThan(bounds.minY));
        expect((bounds.maxY - bounds.minY), greaterThan(0));
      });

      test('handles very large ranges', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 0,
          dataMaxY: 1000000000,
        );
        
        expect(bounds.maxY.isFinite, true);
        expect(bounds.maxY, greaterThanOrEqualTo(1000000000));
      });
    });
  });

  group('FusionAxisConfiguration', () {
    group('validation', () {
      test('validates correct configuration', () {
        const config = FusionAxisConfiguration(
          min: 0,
          max: 100,
          interval: 20,
        );
        
        expect(config.validate(), true);
        expect(config.getValidationError(), isNull);
      });

      test('rejects min >= max', () {
        const config = FusionAxisConfiguration(
          min: 100,
          max: 50,
        );
        
        expect(config.validate(), false);
        expect(config.getValidationError(), contains('min'));
      });

      test('rejects zero interval', () {
        const config = FusionAxisConfiguration(
          min: 0,
          max: 100,
          interval: 0,
        );
        
        expect(config.validate(), false);
        expect(config.getValidationError(), contains('interval'));
      });

      test('rejects negative interval', () {
        const config = FusionAxisConfiguration(
          min: 0,
          max: 100,
          interval: -10,
        );
        
        expect(config.validate(), false);
      });

      test('rejects invalid range padding', () {
        const config = FusionAxisConfiguration(
          rangePadding: 1.5, // > 1.0
        );
        
        expect(config.validate(), false);
        expect(config.getValidationError(), contains('rangePadding'));
      });

      test('rejects negative range padding', () {
        const config = FusionAxisConfiguration(
          rangePadding: -0.1,
        );
        
        expect(config.validate(), false);
      });
    });

    group('computed properties', () {
      test('effectiveMin returns min when set', () {
        const config = FusionAxisConfiguration(min: 10);
        expect(config.effectiveMin, 10);
      });

      test('effectiveMin returns default when not set', () {
        const config = FusionAxisConfiguration();
        expect(config.effectiveMin, 0.0);
      });

      test('effectiveMax returns max when set', () {
        const config = FusionAxisConfiguration(max: 200);
        expect(config.effectiveMax, 200);
      });

      test('effectiveMax returns default when not set', () {
        const config = FusionAxisConfiguration();
        expect(config.effectiveMax, 10.0);
      });

      test('effectiveInterval returns interval when set', () {
        const config = FusionAxisConfiguration(interval: 25);
        expect(config.effectiveInterval, 25);
      });

      test('hasExplicitBounds is true when both min and max set', () {
        const config = FusionAxisConfiguration(min: 0, max: 100);
        expect(config.hasExplicitBounds, true);
      });

      test('hasExplicitBounds is false when only min set', () {
        const config = FusionAxisConfiguration(min: 0);
        expect(config.hasExplicitBounds, false);
      });

      test('hasExplicitInterval is true when interval set', () {
        const config = FusionAxisConfiguration(interval: 20);
        expect(config.hasExplicitInterval, true);
      });

      test('isFullyAutomatic is true by default', () {
        const config = FusionAxisConfiguration();
        expect(config.isFullyAutomatic, true);
      });

      test('isFullyAutomatic is false when autoRange is false', () {
        const config = FusionAxisConfiguration(autoRange: false);
        expect(config.isFullyAutomatic, false);
      });
    });

    group('copyWith', () {
      test('creates copy with modified values', () {
        const original = FusionAxisConfiguration(
          min: 0,
          max: 100,
          interval: 20,
        );
        
        final copy = original.copyWith(max: 200);
        
        expect(copy.min, 0);
        expect(copy.max, 200);
        expect(copy.interval, 20);
      });

      test('preserves unmodified values', () {
        const original = FusionAxisConfiguration(
          min: 10,
          max: 90,
          showGrid: false,
          showLabels: true,
        );
        
        final copy = original.copyWith(min: 0);
        
        expect(copy.min, 0);
        expect(copy.max, 90);
        expect(copy.showGrid, false);
        expect(copy.showLabels, true);
      });
    });

    group('equality', () {
      test('equal configurations are equal', () {
        const config1 = FusionAxisConfiguration(min: 0, max: 100);
        const config2 = FusionAxisConfiguration(min: 0, max: 100);
        
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('different configurations are not equal', () {
        const config1 = FusionAxisConfiguration(min: 0, max: 100);
        const config2 = FusionAxisConfiguration(min: 0, max: 200);
        
        expect(config1, isNot(equals(config2)));
      });
    });
  });

  group('FusionTooltipBehavior', () {
    group('dismiss strategy helpers', () {
      test('shouldDismissOnRelease returns true for onRelease', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onRelease,
        );
        
        expect(behavior.shouldDismissOnRelease(), true);
      });

      test('shouldDismissOnRelease returns true for onReleaseDelayed', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
        );
        
        expect(behavior.shouldDismissOnRelease(), true);
      });

      test('shouldDismissOnRelease returns false for never', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.never,
        );
        
        expect(behavior.shouldDismissOnRelease(), false);
      });

      test('shouldUseTimer returns true for onTimer', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onTimer,
        );
        
        expect(behavior.shouldUseTimer(), true);
      });

      test('shouldUseTimer returns false for onRelease', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onRelease,
        );
        
        expect(behavior.shouldUseTimer(), false);
      });
    });

    group('getDismissDelay', () {
      test('returns zero for onRelease strategy', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onRelease,
        );
        
        expect(behavior.getDismissDelay(false), Duration.zero);
      });

      test('returns dismissDelay for onReleaseDelayed strategy', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
          dismissDelay: Duration(milliseconds: 500),
        );
        
        expect(behavior.getDismissDelay(false), const Duration(milliseconds: 500));
      });

      test('returns duration for onTimer strategy', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.onTimer,
          duration: Duration(seconds: 3),
        );
        
        expect(behavior.getDismissDelay(false), const Duration(seconds: 3));
      });

      test('returns long duration for never strategy', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.never,
        );
        
        final delay = behavior.getDismissDelay(false);
        expect(delay.inDays, greaterThanOrEqualTo(365));
      });

      test('smart strategy uses duration for long press', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.smart,
          duration: Duration(seconds: 3),
          dismissDelay: Duration(milliseconds: 300),
        );
        
        expect(behavior.getDismissDelay(true), const Duration(seconds: 3));
      });

      test('smart strategy uses dismissDelay for tap', () {
        const behavior = FusionTooltipBehavior(
          dismissStrategy: FusionDismissStrategy.smart,
          duration: Duration(seconds: 3),
          dismissDelay: Duration(milliseconds: 300),
        );
        
        expect(behavior.getDismissDelay(false), const Duration(milliseconds: 300));
      });
    });

    group('copyWith', () {
      test('creates copy with modified values', () {
        const original = FusionTooltipBehavior(
          enable: true,
          dismissStrategy: FusionDismissStrategy.onRelease,
        );
        
        final copy = original.copyWith(
          dismissStrategy: FusionDismissStrategy.never,
        );
        
        expect(copy.enable, true);
        expect(copy.dismissStrategy, FusionDismissStrategy.never);
      });
    });
  });

  group('FusionChartConfiguration', () {
    group('hasAnyInteraction', () {
      test('returns true when tooltip enabled', () {
        const config = FusionChartConfiguration(
          enableTooltip: true,
          enableCrosshair: false,
          enableZoom: false,
          enablePanning: false,
          enableSelection: false,
        );
        
        expect(config.hasAnyInteraction, true);
      });

      test('returns true when crosshair enabled', () {
        const config = FusionChartConfiguration(
          enableTooltip: false,
          enableCrosshair: true,
          enableZoom: false,
          enablePanning: false,
          enableSelection: false,
        );
        
        expect(config.hasAnyInteraction, true);
      });

      test('returns true when zoom enabled', () {
        const config = FusionChartConfiguration(
          enableTooltip: false,
          enableCrosshair: false,
          enableZoom: true,
          enablePanning: false,
          enableSelection: false,
        );
        
        expect(config.hasAnyInteraction, true);
      });

      test('returns false when all interactions disabled', () {
        const config = FusionChartConfiguration(
          enableTooltip: false,
          enableCrosshair: false,
          enableZoom: false,
          enablePanning: false,
          enableSelection: false,
        );
        
        expect(config.hasAnyInteraction, false);
      });
    });

    group('effectiveAnimationDuration', () {
      test('returns custom duration when set', () {
        const config = FusionChartConfiguration(
          animationDuration: Duration(seconds: 2),
        );
        
        expect(config.effectiveAnimationDuration, const Duration(seconds: 2));
      });

      test('returns default when not set', () {
        const config = FusionChartConfiguration();
        
        // Default from FusionLightTheme is 1500ms
        expect(config.effectiveAnimationDuration, const Duration(milliseconds: 1500));
      });
    });

    group('effectiveAnimationCurve', () {
      test('returns custom curve when set', () {
        const config = FusionChartConfiguration(
          animationCurve: Curves.linear,
        );
        
        expect(config.effectiveAnimationCurve, Curves.linear);
      });

      test('returns default when not set', () {
        const config = FusionChartConfiguration();
        
        // Default from FusionLightTheme is Curves.easeInOutCubic
        expect(config.effectiveAnimationCurve, Curves.easeInOutCubic);
      });
    });
  });

  group('FusionDataPoint', () {
    test('creates point with x and y', () {
      final point = FusionDataPoint(10, 20);
      
      expect(point.x, 10);
      expect(point.y, 20);
      expect(point.label, isNull);
    });

    test('creates point with label', () {
      final point = FusionDataPoint(10, 20, label: 'Test');
      
      expect(point.x, 10);
      expect(point.y, 20);
      expect(point.label, 'Test');
    });

    test('equality works correctly', () {
      final point1 = FusionDataPoint(10, 20);
      final point2 = FusionDataPoint(10, 20);
      final point3 = FusionDataPoint(10, 30);
      
      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });

    test('hashCode is consistent', () {
      final point1 = FusionDataPoint(10, 20);
      final point2 = FusionDataPoint(10, 20);
      
      expect(point1.hashCode, equals(point2.hashCode));
    });

    test('toString returns readable string', () {
      final point = FusionDataPoint(10, 20, label: 'A');
      final str = point.toString();
      
      expect(str, contains('10'));
      expect(str, contains('20'));
    });
  });

  group('FusionLineSeries', () {
    test('creates series with required parameters', () {
      final series = FusionLineSeries(
        name: 'Test',
        dataPoints: [FusionDataPoint(0, 10)],
        color: const Color(0xFF0000FF),
      );
      
      expect(series.name, 'Test');
      expect(series.dataPoints.length, 1);
      expect(series.visible, true);
    });

    test('defaults to visible true', () {
      final series = FusionLineSeries(
        name: 'Test',
        dataPoints: [],
        color: const Color(0xFF0000FF),
      );
      
      expect(series.visible, true);
    });

    test('can be set to invisible', () {
      final series = FusionLineSeries(
        name: 'Test',
        dataPoints: [],
        color: const Color(0xFF0000FF),
        visible: false,
      );
      
      expect(series.visible, false);
    });

    test('supports curved lines', () {
      final series = FusionLineSeries(
        name: 'Curved',
        dataPoints: [FusionDataPoint(0, 10)],
        color: const Color(0xFF0000FF),
        isCurved: true,
        smoothness: 0.5,
      );
      
      expect(series.isCurved, true);
      expect(series.smoothness, 0.5);
    });

    test('supports area fill', () {
      final series = FusionLineSeries(
        name: 'Area',
        dataPoints: [FusionDataPoint(0, 10)],
        color: const Color(0xFF0000FF),
        showArea: true,
        areaOpacity: 0.3,
      );
      
      expect(series.showArea, true);
      expect(series.areaOpacity, 0.3);
    });
  });

  group('FusionBarSeries', () {
    test('creates series with required parameters', () {
      final series = FusionBarSeries(
        name: 'Test',
        dataPoints: [FusionDataPoint(0, 30, label: 'A')],
        color: const Color(0xFF0000FF),
      );
      
      expect(series.name, 'Test');
      expect(series.dataPoints.length, 1);
    });

    test('supports border radius', () {
      final series = FusionBarSeries(
        name: 'Rounded',
        dataPoints: [FusionDataPoint(0, 30)],
        color: const Color(0xFF0000FF),
        borderRadius: 8.0,
      );
      
      expect(series.borderRadius, 8.0);
    });

    test('supports gradient', () {
      final series = FusionBarSeries(
        name: 'Gradient',
        dataPoints: [FusionDataPoint(0, 30)],
        color: const Color(0xFF0000FF),
        gradient: const LinearGradient(
          colors: [Color(0xFF0000FF), Color(0xFFFF0000)],
        ),
      );
      
      expect(series.gradient, isNotNull);
    });
  });

  group('FusionPieDataPoint', () {
    test('creates point with value and label', () {
      final point = FusionPieDataPoint(
        30,
        label: 'Slice A',
        color: const Color(0xFF0000FF),
      );
      
      expect(point.value, 30);
      expect(point.label, 'Slice A');
    });

    test('supports explode', () {
      final point = FusionPieDataPoint(
        30,
        label: 'Exploded',
        color: const Color(0xFF0000FF),
        explode: true,
      );
      
      expect(point.explode, true);
    });
  });
}

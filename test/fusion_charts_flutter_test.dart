import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('FusionDataPoint', () {
    test('creates point with x and y', () {
      final point = FusionDataPoint(1.0, 2.0);
      expect(point.x, 1.0);
      expect(point.y, 2.0);
    });

    test('creates point with label and metadata', () {
      final point = FusionDataPoint(
        1.0,
        2.0,
        label: 'Point 1',
        metadata: {'category': 'A'},
      );
      expect(point.label, 'Point 1');
      expect(point.metadata?['category'], 'A');
    });

    test('copyWith creates new point with modified values', () {
      final point = FusionDataPoint(1.0, 2.0, label: 'Original');
      final copy = point.copyWith(y: 3.0, label: 'Modified');

      expect(copy.x, 1.0);
      expect(copy.y, 3.0);
      expect(copy.label, 'Modified');
      expect(point.label, 'Original'); // Original unchanged
    });

    test('equality works correctly', () {
      final point1 = FusionDataPoint(1.0, 2.0);
      final point2 = FusionDataPoint(1.0, 2.0);
      final point3 = FusionDataPoint(1.0, 3.0);

      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });
  });

  group('DataValidator', () {
    test('removes NaN values and reports them', () {
      final validator = DataValidator();
      final data = [
        FusionDataPoint(0, 10),
        FusionDataPoint(1, double.nan),
        FusionDataPoint(2, 30),
      ];

      final result = validator.validate(data);

      // Data is cleaned (2 valid points)
      expect(result.validCount, 2);
      expect(result.validData.length, 2);
      expect(result.validData[0].y, 10);
      expect(result.validData[1].y, 30);

      // Errors list contains warning about NaN
      expect(result.hasErrors, true); // NaN warning is added to errors list
      expect(result.errors.length, 1);
      expect(result.errors[0].code, 'NAN_VALUES');
      expect(result.errors[0].severity, ErrorSeverity.warning);

      // Data is still usable despite warning
      expect(result.isUsable, true);
      expect(result.hasCriticalErrors, false);
    });

    test('removes Infinity values and reports them', () {
      final validator = DataValidator();
      final data = [
        FusionDataPoint(0, 10),
        FusionDataPoint(1, double.infinity),
        FusionDataPoint(2, 30),
      ];

      final result = validator.validate(data);

      expect(result.validCount, 2);
      expect(result.hasErrors, true); // Infinity warning
      expect(result.errors[0].code, 'INFINITY_VALUES');
      expect(result.isUsable, true);
    });

    test('handles empty data', () {
      final validator = DataValidator();
      final result = validator.validate([]);

      expect(result.validCount, 0);
      expect(result.hasErrors, true);
      expect(result.hasCriticalErrors, true);
      expect(result.errors[0].code, 'EMPTY_DATA');
      expect(result.isUsable, false);
    });

    test('validates clean data without errors', () {
      final validator = DataValidator();
      final data = [
        FusionDataPoint(0, 10),
        FusionDataPoint(1, 20),
        FusionDataPoint(2, 30),
      ];

      final result = validator.validate(data);

      expect(result.validCount, 3);
      expect(result.hasErrors, false); // No errors for clean data
      expect(result.isUsable, true);
    });

    test('removes duplicate X values when enabled', () {
      final validator = DataValidator(removeDuplicates: true);
      final data = [
        FusionDataPoint(0, 10),
        FusionDataPoint(1, 20),
        FusionDataPoint(1, 25), // Duplicate X
        FusionDataPoint(2, 30),
      ];

      final result = validator.validate(data);

      expect(result.validCount, 3); // One duplicate removed
      expect(result.hasWarnings, true);
      expect(result.warnings[0].code, 'DUPLICATES_REMOVED');
    });

    test('sorts data by X when enabled', () {
      final validator = DataValidator(sortByX: true);
      final data = [
        FusionDataPoint(2, 30),
        FusionDataPoint(0, 10),
        FusionDataPoint(1, 20),
      ];

      final result = validator.validate(data);

      expect(result.validData[0].x, 0);
      expect(result.validData[1].x, 1);
      expect(result.validData[2].x, 2);
    });

    test('calculates statistics correctly', () {
      final validator = DataValidator();
      final data = [
        FusionDataPoint(0, 10),
        FusionDataPoint(1, 20),
        FusionDataPoint(2, 30),
      ];

      final result = validator.validate(data);

      expect(result.statistics, isNotNull);
      expect(result.statistics!.count, 3);
      expect(result.statistics!.minX, 0);
      expect(result.statistics!.maxX, 2);
      expect(result.statistics!.minY, 10);
      expect(result.statistics!.maxY, 30);
      expect(result.statistics!.meanY, 20);
    });

    test('clamps values to range when enabled', () {
      final validator = DataValidator(
        clampToRange: true,
        minValue: 15,
        maxValue: 85,
      );
      final data = [
        FusionDataPoint(0, 10), // Below min
        FusionDataPoint(1, 50), // Within range
        FusionDataPoint(2, 100), // Above max
      ];

      final result = validator.validate(data);

      expect(result.validData[0].y, 15); // Clamped to min
      expect(result.validData[1].y, 50); // Unchanged
      expect(result.validData[2].y, 85); // Clamped to max
      expect(result.hasWarnings, true);
      expect(result.warnings[0].code, 'VALUES_CLAMPED');
    });
  });

  group('AxisBounds', () {
    test('creates bounds with valid values', () {
      final bounds = AxisBounds(
        min: 0,
        max: 100,
        interval: 20,
        decimalPlaces: 0,
      );

      expect(bounds.min, 0);
      expect(bounds.max, 100);
      expect(bounds.interval, 20);
      expect(bounds.range, 100);
      expect(bounds.majorTickCount, 6); // 0, 20, 40, 60, 80, 100
    });

    test('calculates correct tick count', () {
      final bounds = AxisBounds(min: 0, max: 10, interval: 2);
      expect(bounds.majorTickCount, 6); // 0, 2, 4, 6, 8, 10
    });
  });

  group('FusionChartConfiguration', () {
    test('creates default configuration', () {
      const config = FusionChartConfiguration();

      expect(config.enableAnimation, true);
      expect(config.enableTooltip, true);
      expect(config.enableCrosshair, true);
      expect(config.enableZoom, false);
      expect(config.enablePanning, false);
      expect(config.enableSelection, true);
      expect(config.enableLegend, true);
      expect(config.enableDataLabels, false);
      expect(config.enableGrid, true);
      expect(config.enableAxis, true);
    });

    test('copyWith creates modified configuration', () {
      const config = FusionChartConfiguration();
      final modified = config.copyWith(
        enableZoom: true,
        enablePanning: true,
        enableCrosshair: false,
      );

      expect(modified.enableZoom, true);
      expect(modified.enablePanning, true);
      expect(modified.enableCrosshair, false); // Changed to false
      expect(modified.enableAnimation, true); // Unchanged
    });
  });

  group('FusionLineChartConfiguration', () {
    test('creates default line chart configuration', () {
      const config = FusionLineChartConfiguration();

      expect(config.enableAnimation, true);
      expect(config.enableMarkers, false);
      expect(config.lineWidth, 2.0);
      expect(config.markerSize, 6.0);
      expect(config.enableAreaFill, false);
    });

    test('copyWith creates modified line chart configuration', () {
      const config = FusionLineChartConfiguration();
      final modified = config.copyWith(enableMarkers: true, lineWidth: 3.5);

      expect(modified.enableMarkers, true);
      expect(modified.lineWidth, 3.5);
      expect(modified.enableAnimation, true); // Unchanged
    });
  });
}

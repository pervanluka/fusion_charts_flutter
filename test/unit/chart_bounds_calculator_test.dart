import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('ChartBoundsCalculator', () {
    group('calculateNiceYBounds', () {
      test('returns nice bounds for typical positive data', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 0,
          dataMaxY: 95,
        );

        expect(bounds.minY, equals(0));
        expect(bounds.maxY, greaterThanOrEqualTo(95));
        // Should be a nice round number like 100
        expect(bounds.maxY % 10, equals(0));
      });

      test('respects explicit min/max from config', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 0,
          dataMaxY: 95,
          yAxisConfig: const FusionAxisConfiguration(min: 0, max: 200),
        );

        expect(bounds.minY, equals(0));
        expect(bounds.maxY, equals(200));
      });

      test('starts from zero when startFromZero is true', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 50,
          dataMaxY: 100,
          startFromZero: true,
        );

        expect(bounds.minY, equals(0));
      });

      test('handles negative data ranges', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: -50,
          dataMaxY: 50,
        );

        expect(bounds.minY, lessThanOrEqualTo(-50));
        expect(bounds.maxY, greaterThanOrEqualTo(50));
      });

      test('adds headroom when data is close to axis max', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 0,
          dataMaxY: 99, // Very close to 100
        );

        // Should add headroom beyond 100
        expect(bounds.maxY, greaterThan(100));
      });

      test('handles zero range data', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 50,
          dataMaxY: 50,
        );

        expect(bounds.minY, lessThanOrEqualTo(50));
        expect(bounds.maxY, greaterThanOrEqualTo(50));
        expect(bounds.maxY - bounds.minY, greaterThan(0));
      });

      test('handles very small values', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 0.001,
          dataMaxY: 0.005,
        );

        expect(bounds.minY, lessThanOrEqualTo(0.001));
        expect(bounds.maxY, greaterThanOrEqualTo(0.005));
      });

      test('handles very large values', () {
        final bounds = ChartBoundsCalculator.calculateNiceYBounds(
          dataMinY: 1000000,
          dataMaxY: 5000000,
        );

        expect(bounds.minY.isFinite, true);
        expect(bounds.maxY.isFinite, true);
        expect(bounds.maxY, greaterThanOrEqualTo(5000000));
      });
    });

    group('calculateNiceXBounds', () {
      test('returns exact data bounds by default', () {
        final bounds = ChartBoundsCalculator.calculateNiceXBounds(
          dataMinX: 10,
          dataMaxX: 90,
        );

        expect(bounds.minX, equals(10));
        expect(bounds.maxX, equals(90));
      });

      test('respects explicit config bounds', () {
        final bounds = ChartBoundsCalculator.calculateNiceXBounds(
          dataMinX: 10,
          dataMaxX: 90,
          xAxisConfig: const FusionAxisConfiguration(min: 0, max: 100),
        );

        expect(bounds.minX, equals(0));
        expect(bounds.maxX, equals(100));
      });

      test('applies nice bounds when useNiceBounds is true', () {
        final bounds = ChartBoundsCalculator.calculateNiceXBounds(
          dataMinX: 3,
          dataMaxX: 97,
          useNiceBounds: true,
        );

        // Should round to nice numbers
        expect(bounds.minX, lessThanOrEqualTo(3));
        expect(bounds.maxX, greaterThanOrEqualTo(97));
      });
    });

    group('calculateCategoryXBounds', () {
      test('returns correct bounds for category axis', () {
        final bounds = ChartBoundsCalculator.calculateCategoryXBounds(
          pointCount: 5,
        );

        expect(bounds.minX, equals(-0.5));
        expect(bounds.maxX, equals(4.5)); // pointCount - 0.5
      });

      test('handles single category', () {
        final bounds = ChartBoundsCalculator.calculateCategoryXBounds(
          pointCount: 1,
        );

        expect(bounds.minX, equals(-0.5));
        expect(bounds.maxX, equals(0.5));
      });

      test('handles many categories', () {
        final bounds = ChartBoundsCalculator.calculateCategoryXBounds(
          pointCount: 100,
        );

        expect(bounds.minX, equals(-0.5));
        expect(bounds.maxX, equals(99.5));
      });
    });
  });
}

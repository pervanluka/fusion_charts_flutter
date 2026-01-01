import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('LTTBDownsampler', () {
    const downsampler = LTTBDownsampler();

    group('Basic Functionality', () {
      test('returns original data when below target', () {
        final data = List.generate(
          50,
          (i) => FusionDataPoint(i.toDouble(), i * 2.0),
        );

        final result = downsampler.downsample(data: data, targetPoints: 100);

        expect(result.length, 50);
        expect(result, equals(data));
      });

      test('reduces to exact target count', () {
        final data = List.generate(
          1000,
          (i) => FusionDataPoint(i.toDouble(), (i % 100).toDouble()),
        );

        final result = downsampler.downsample(data: data, targetPoints: 100);

        expect(result.length, 100);
      });

      test('preserves first and last points always', () {
        final data = List.generate(
          1000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1) * 100),
        );

        final result = downsampler.downsample(data: data, targetPoints: 50);

        expect(result.first.x, equals(data.first.x));
        expect(result.first.y, equals(data.first.y));
        expect(result.last.x, equals(data.last.x));
        expect(result.last.y, equals(data.last.y));
      });

      test('maintains sorted order', () {
        final data = List.generate(
          1000,
          (i) =>
              FusionDataPoint(i.toDouble(), math.Random(42).nextDouble() * 100),
        );

        final result = downsampler.downsample(data: data, targetPoints: 100);

        for (int i = 0; i < result.length - 1; i++) {
          expect(
            result[i].x,
            lessThanOrEqualTo(result[i + 1].x),
            reason: 'Points should remain sorted by X',
          );
        }
      });
    });

    group('Edge Cases', () {
      test('handles empty data', () {
        final result = downsampler.downsample(data: [], targetPoints: 100);
        expect(result, isEmpty);
      });

      test('handles single point', () {
        final data = [FusionDataPoint(0, 50)];
        final result = downsampler.downsample(data: data, targetPoints: 100);

        expect(result.length, 1);
        expect(result.first.y, 50);
      });

      test('handles two points', () {
        final data = [FusionDataPoint(0, 10), FusionDataPoint(1, 20)];

        final result = downsampler.downsample(data: data, targetPoints: 100);

        expect(result.length, 2);
        expect(result[0].y, 10);
        expect(result[1].y, 20);
      });

      test('handles three points', () {
        final data = [
          FusionDataPoint(0, 10),
          FusionDataPoint(1, 20),
          FusionDataPoint(2, 15),
        ];

        final result = downsampler.downsample(data: data, targetPoints: 100);

        expect(result.length, 3);
      });

      test('handles exactly target points', () {
        final data = List.generate(
          100,
          (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
        );
        final result = downsampler.downsample(data: data, targetPoints: 100);

        expect(result.length, 100);
        expect(result, equals(data));
      });
    });

    group('Visual Fidelity', () {
      test('preserves peaks in sine wave', () {
        // Create sine wave with clear peaks at 90° and 270°
        final data = List.generate(
          360,
          (i) =>
              FusionDataPoint(i.toDouble(), math.sin(i * math.pi / 180) * 100),
        );

        final result = downsampler.downsample(data: data, targetPoints: 36);

        // Should have points near the peaks
        final hasPeak = result.any((p) => p.y > 90);
        final hasTrough = result.any((p) => p.y < -90);

        expect(hasPeak, true, reason: 'Should preserve peak near y=100');
        expect(hasTrough, true, reason: 'Should preserve trough near y=-100');
      });

      test('preserves spike in flat data', () {
        // Flat data with a spike in the middle
        final data = List.generate(1000, (i) {
          if (i == 500) return FusionDataPoint(i.toDouble(), 1000.0);
          return FusionDataPoint(i.toDouble(), 10.0);
        });

        final result = downsampler.downsample(data: data, targetPoints: 50);

        // The spike should be preserved because it forms the largest triangle
        final hasSpike = result.any((p) => p.y == 1000.0);
        expect(hasSpike, true, reason: 'Prominent spike should be preserved');
      });

      test('preserves valley in elevated data', () {
        // Elevated data with a valley in the middle
        final data = List.generate(1000, (i) {
          if (i == 500) return FusionDataPoint(i.toDouble(), 0.0);
          return FusionDataPoint(i.toDouble(), 100.0);
        });

        final result = downsampler.downsample(data: data, targetPoints: 50);

        // The valley should be preserved
        final hasValley = result.any((p) => p.y == 0.0);
        expect(hasValley, true, reason: 'Prominent valley should be preserved');
      });

      test('preserves step function transitions', () {
        // Step function: 0 for first half, 100 for second half
        final data = List.generate(1000, (i) {
          return FusionDataPoint(i.toDouble(), i < 500 ? 0.0 : 100.0);
        });

        final result = downsampler.downsample(data: data, targetPoints: 20);

        // Should have both 0 and 100 values
        final hasLow = result.any((p) => p.y == 0.0);
        final hasHigh = result.any((p) => p.y == 100.0);

        expect(hasLow, true);
        expect(hasHigh, true);
      });
    });

    group('Performance', () {
      test('handles large datasets efficiently', () {
        final data = List.generate(
          100000,
          (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.001) * 100),
        );

        final stopwatch = Stopwatch()..start();
        final result = downsampler.downsample(data: data, targetPoints: 1000);
        stopwatch.stop();

        expect(result.length, 1000);
        // Should complete in reasonable time (< 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Data Integrity', () {
      test('does not modify original data', () {
        final data = List.generate(
          1000,
          (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
        );
        final originalLength = data.length;
        final originalFirst = data.first;
        final originalLast = data.last;

        downsampler.downsample(data: data, targetPoints: 100);

        expect(data.length, originalLength);
        expect(data.first, originalFirst);
        expect(data.last, originalLast);
      });

      test('preserves point labels and metadata', () {
        final data = [
          FusionDataPoint(0, 10, label: 'Start', metadata: {'key': 'value1'}),
          FusionDataPoint(1, 20, label: 'Middle'),
          FusionDataPoint(2, 30, label: 'End', metadata: {'key': 'value2'}),
        ];

        final result = downsampler.downsample(data: data, targetPoints: 10);

        // First and last should preserve their labels/metadata
        expect(result.first.label, 'Start');
        expect(result.first.metadata, {'key': 'value1'});
        expect(result.last.label, 'End');
        expect(result.last.metadata, {'key': 'value2'});
      });
    });
  });
}

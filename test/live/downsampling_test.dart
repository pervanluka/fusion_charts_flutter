import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/live/downsampling.dart';
import 'package:fusion_charts_flutter/src/live/retention_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Downsampler', () {
    group('basic behavior', () {
      test('returns original data when already at or below target count', () {
        final data = [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 15),
        ];

        final result = Downsampler.downsample(
          data,
          targetCount: 5,
          method: DownsampleMethod.lttb,
        );

        expect(result, equals(data));
      });

      test('returns first and last when target is 2', () {
        final data = [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
          const FusionDataPoint(3, 40),
          const FusionDataPoint(4, 50),
        ];

        final result = Downsampler.downsample(
          data,
          targetCount: 2,
          method: DownsampleMethod.lttb,
        );

        expect(result.length, 2);
        expect(result.first, equals(data.first));
        expect(result.last, equals(data.last));
      });

      test('returns last when target is 1', () {
        final data = [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
          const FusionDataPoint(2, 30),
        ];

        final result = Downsampler.downsample(
          data,
          targetCount: 1,
          method: DownsampleMethod.lttb,
        );

        expect(result.length, 1);
        expect(result.first, equals(data.last));
      });

      test('returns empty list when target is 0', () {
        final data = [
          const FusionDataPoint(0, 10),
          const FusionDataPoint(1, 20),
        ];

        final result = Downsampler.downsample(
          data,
          targetCount: 0,
          method: DownsampleMethod.lttb,
        );

        expect(result.isEmpty, isTrue);
      });
    });

    group('LTTB (Largest Triangle Three Buckets)', () {
      test('always keeps first and last points', () {
        final data = List.generate(
          100,
          (i) => FusionDataPoint(i.toDouble(), i * 2.0),
        );

        final result = Downsampler.downsample(
          data,
          targetCount: 10,
          method: DownsampleMethod.lttb,
        );

        expect(result.first, equals(data.first));
        expect(result.last, equals(data.last));
      });

      test('produces correct number of points', () {
        final data = List.generate(
          1000,
          (i) => FusionDataPoint(i.toDouble(), i * 1.0),
        );

        final result = Downsampler.downsample(
          data,
          targetCount: 50,
          method: DownsampleMethod.lttb,
        );

        expect(result.length, 50);
      });

      test('preserves peaks in data', () {
        // Create data with a clear peak in the middle
        final data = <FusionDataPoint>[];
        for (var i = 0; i < 50; i++) {
          data.add(FusionDataPoint(i.toDouble(), 10.0));
        }
        data.add(const FusionDataPoint(50, 100)); // Clear peak
        for (var i = 51; i < 100; i++) {
          data.add(FusionDataPoint(i.toDouble(), 10.0));
        }

        final result = Downsampler.downsample(
          data,
          targetCount: 10,
          method: DownsampleMethod.lttb,
        );

        // The peak should be preserved
        final maxY = result.map((p) => p.y).reduce((a, b) => a > b ? a : b);
        expect(maxY, equals(100.0));
      });

      test('preserves valleys in data', () {
        // Create data with a clear valley in the middle
        final data = <FusionDataPoint>[];
        for (var i = 0; i < 50; i++) {
          data.add(FusionDataPoint(i.toDouble(), 100.0));
        }
        data.add(const FusionDataPoint(50, 0)); // Clear valley
        for (var i = 51; i < 100; i++) {
          data.add(FusionDataPoint(i.toDouble(), 100.0));
        }

        final result = Downsampler.downsample(
          data,
          targetCount: 10,
          method: DownsampleMethod.lttb,
        );

        // The valley should be preserved
        final minY = result.map((p) => p.y).reduce((a, b) => a < b ? a : b);
        expect(minY, equals(0.0));
      });

      test('maintains sorted order by x', () {
        final data = List.generate(
          100,
          (i) => FusionDataPoint(i.toDouble(), (i % 10) * 5.0),
        );

        final result = Downsampler.downsample(
          data,
          targetCount: 20,
          method: DownsampleMethod.lttb,
        );

        for (var i = 1; i < result.length; i++) {
          expect(result[i].x, greaterThan(result[i - 1].x));
        }
      });
    });

    group('First method', () {
      test('keeps first point from each bucket', () {
        final data = List.generate(
          100,
          (i) => FusionDataPoint(i.toDouble(), i * 2.0),
        );

        final result = Downsampler.downsample(
          data,
          targetCount: 10,
          method: DownsampleMethod.first,
        );

        expect(result.length, 10);
        // First point should be the first from the original data
        expect(result.first.x, equals(0.0));
      });
    });

    group('Last method', () {
      test('keeps last point from each bucket', () {
        final data = List.generate(
          100,
          (i) => FusionDataPoint(i.toDouble(), i * 2.0),
        );

        final result = Downsampler.downsample(
          data,
          targetCount: 10,
          method: DownsampleMethod.last,
        );

        expect(result.length, 10);
        // Last point should be the last from the original data
        expect(result.last.x, equals(99.0));
      });
    });

    group('Average method', () {
      test('averages points in each bucket', () {
        // Create data where averages are easy to verify
        final data = List.generate(
          100,
          (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
        );

        final result = Downsampler.downsample(
          data,
          targetCount: 10,
          method: DownsampleMethod.average,
        );

        expect(result.length, 10);
        // Each bucket has 10 points, average should be at bucket center
        // First bucket (0-9): average = 4.5
        expect(result[0].x, closeTo(4.5, 0.5));
        expect(result[0].y, closeTo(4.5, 0.5));
      });
    });

    group('MinMax method', () {
      test('keeps min and max points from each bucket', () {
        // Create data with clear min/max in buckets
        final data = [
          const FusionDataPoint(0, 50),
          const FusionDataPoint(1, 10), // min
          const FusionDataPoint(2, 90), // max
          const FusionDataPoint(3, 50),
          const FusionDataPoint(4, 50),
          const FusionDataPoint(5, 50),
          const FusionDataPoint(6, 5), // min
          const FusionDataPoint(7, 95), // max
          const FusionDataPoint(8, 50),
          const FusionDataPoint(9, 50),
        ];

        final result = Downsampler.downsample(
          data,
          targetCount: 4,
          method: DownsampleMethod.minMax,
        );

        // Should preserve the extremes
        final yValues = result.map((p) => p.y).toList();
        expect(yValues.contains(10.0), isTrue);
        expect(yValues.contains(90.0), isTrue);
        expect(yValues.contains(5.0), isTrue);
        expect(yValues.contains(95.0), isTrue);
      });

      test('maintains chronological order within buckets', () {
        final data = [
          const FusionDataPoint(0, 100), // max first
          const FusionDataPoint(1, 10), // min second
          const FusionDataPoint(2, 50),
          const FusionDataPoint(3, 50),
        ];

        final result = Downsampler.downsample(
          data,
          targetCount: 2,
          method: DownsampleMethod.minMax,
        );

        // Check that min/max are in chronological order
        for (var i = 1; i < result.length; i++) {
          expect(result[i].x, greaterThanOrEqualTo(result[i - 1].x));
        }
      });
    });

    group('performance', () {
      test('handles large datasets efficiently', () {
        final data = List.generate(
          100000,
          (i) => FusionDataPoint(i.toDouble(), (i * 1.5) % 100),
        );

        final stopwatch = Stopwatch()..start();
        final result = Downsampler.downsample(
          data,
          targetCount: 1000,
          method: DownsampleMethod.lttb,
        );
        stopwatch.stop();

        expect(result.length, 1000);
        // Should complete in reasonable time (< 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}

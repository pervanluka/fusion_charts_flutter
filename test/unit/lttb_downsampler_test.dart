import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/utils/lttb_downsampler.dart';

void main() {
  const downsampler = LTTBDownsampler();

  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================
  group('LTTBDownsampler - Construction', () {
    test('creates instance', () {
      expect(downsampler, isNotNull);
      expect(downsampler, isA<LTTBDownsampler>());
    });
  });

  // ===========================================================================
  // DOWNSAMPLE - EDGE CASES
  // ===========================================================================
  group('LTTBDownsampler - Downsample Edge Cases', () {
    test('returns empty list for empty data', () {
      final result = downsampler.downsample(data: [], targetPoints: 10);

      expect(result, isEmpty);
    });

    test('returns empty list for zero target points', () {
      final result = downsampler.downsample(
        data: [const FusionDataPoint(1, 10), const FusionDataPoint(2, 20)],
        targetPoints: 0,
      );

      expect(result, isEmpty);
    });

    test('returns empty list for negative target points', () {
      final result = downsampler.downsample(
        data: [const FusionDataPoint(1, 10)],
        targetPoints: -5,
      );

      expect(result, isEmpty);
    });

    test('returns original data when length <= targetPoints', () {
      final data = [
        const FusionDataPoint(1, 10),
        const FusionDataPoint(2, 20),
        const FusionDataPoint(3, 30),
      ];

      final result = downsampler.downsample(data: data, targetPoints: 5);

      expect(result, data);
    });

    test('returns first and last for targetPoints < 3', () {
      final data = [
        const FusionDataPoint(1, 10),
        const FusionDataPoint(2, 20),
        const FusionDataPoint(3, 30),
        const FusionDataPoint(4, 40),
      ];

      final result = downsampler.downsample(data: data, targetPoints: 2);

      expect(result.length, 2);
      expect(result.first, data.first);
      expect(result.last, data.last);
    });
  });

  // ===========================================================================
  // DOWNSAMPLE - BASIC FUNCTIONALITY
  // ===========================================================================
  group('LTTBDownsampler - Downsample Basic', () {
    test('preserves first and last points', () {
      final data = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.downsample(data: data, targetPoints: 10);

      expect(result.first, data.first);
      expect(result.last, data.last);
    });

    test('returns correct number of points', () {
      final data = List.generate(
        1000,
        (i) => FusionDataPoint(i.toDouble(), (i * 2).toDouble()),
      );

      final result = downsampler.downsample(data: data, targetPoints: 100);

      expect(result.length, 100);
    });

    test('preserves data range', () {
      final data = List.generate(
        500,
        (i) => FusionDataPoint(i.toDouble(), (i % 50).toDouble()),
      );

      final result = downsampler.downsample(data: data, targetPoints: 50);

      // First and last X values preserved
      expect(result.first.x, 0);
      expect(result.last.x, 499);
    });

    test('handles small reductions', () {
      final data = [
        const FusionDataPoint(0, 0),
        const FusionDataPoint(1, 10),
        const FusionDataPoint(2, 5),
        const FusionDataPoint(3, 15),
        const FusionDataPoint(4, 8),
      ];

      final result = downsampler.downsample(data: data, targetPoints: 4);

      expect(result.length, 4);
      expect(result.first, data.first);
      expect(result.last, data.last);
    });
  });

  // ===========================================================================
  // DOWNSAMPLE - VISUAL PRESERVATION
  // ===========================================================================
  group('LTTBDownsampler - Visual Preservation', () {
    test('preserves peaks', () {
      // Create data with a clear peak
      final data = <FusionDataPoint>[];
      for (int i = 0; i < 100; i++) {
        double y;
        if (i == 50) {
          y = 1000; // Clear peak
        } else {
          y = i.toDouble();
        }
        data.add(FusionDataPoint(i.toDouble(), y));
      }

      final result = downsampler.downsample(data: data, targetPoints: 10);

      // The peak should be preserved
      final maxY = result.map((p) => p.y).reduce((a, b) => a > b ? a : b);
      expect(maxY, 1000);
    });

    test('preserves valleys', () {
      // Create data with a clear valley
      final data = <FusionDataPoint>[];
      for (int i = 0; i < 100; i++) {
        double y;
        if (i == 50) {
          y = -1000; // Clear valley
        } else {
          y = 100 - (i - 50).abs().toDouble();
        }
        data.add(FusionDataPoint(i.toDouble(), y));
      }

      final result = downsampler.downsample(data: data, targetPoints: 10);

      // The valley should be preserved
      final minY = result.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      expect(minY, -1000);
    });
  });

  // ===========================================================================
  // ADAPTIVE DOWNSAMPLE
  // ===========================================================================
  group('LTTBDownsampler - Adaptive Downsample', () {
    test('calculates target points based on pixel width', () {
      final data = List.generate(
        10000,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.adaptiveDownsample(
        data: data,
        pixelWidth: 100,
        pointsPerPixel: 2.0,
      );

      // Should be around 200 points (100 * 2.0)
      expect(result.length, 200);
    });

    test('respects minimum points', () {
      final data = List.generate(
        10000,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.adaptiveDownsample(
        data: data,
        pixelWidth: 10, // Very small
        pointsPerPixel: 1.0,
      );

      // Should be at least 50 (minPoints)
      expect(result.length, 50);
    });

    test('respects maximum points', () {
      final data = List.generate(
        50000,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.adaptiveDownsample(
        data: data,
        pixelWidth: 5000, // Very large
        pointsPerPixel: 2.0,
      );

      // Should be at most 2000 (maxPoints)
      expect(result.length, 2000);
    });
  });

  // ===========================================================================
  // PROGRESSIVE DOWNSAMPLE
  // ===========================================================================
  group('LTTBDownsampler - Progressive Downsample', () {
    test('creates multiple levels of detail', () {
      final data = List.generate(
        10000,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.progressiveDownsample(
        data: data,
        levels: [100, 500, 1000],
      );

      expect(result.length, 3);
      expect(result[100]!.length, 100);
      expect(result[500]!.length, 500);
      expect(result[1000]!.length, 1000);
    });

    test('uses original data for levels >= data length', () {
      final data = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.progressiveDownsample(
        data: data,
        levels: [50, 100, 500],
      );

      expect(result[50]!.length, 50);
      expect(result[100], data); // Same as original
      expect(result[500], data); // Same as original
    });

    test('uses default levels when none provided', () {
      final data = List.generate(
        10000,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.progressiveDownsample(data: data);

      // Default levels: [100, 500, 1000, 5000]
      expect(result.containsKey(100), isTrue);
      expect(result.containsKey(500), isTrue);
      expect(result.containsKey(1000), isTrue);
      expect(result.containsKey(5000), isTrue);
    });
  });

  // ===========================================================================
  // ERROR ESTIMATION
  // ===========================================================================
  group('LTTBDownsampler - Error Estimation', () {
    test('returns 0 for empty original data', () {
      final error = downsampler.estimateError(
        original: [],
        downsampled: [const FusionDataPoint(0, 0)],
      );

      expect(error, 0);
    });

    test('returns 0 for empty downsampled data', () {
      final error = downsampler.estimateError(
        original: [const FusionDataPoint(0, 0)],
        downsampled: [],
      );

      expect(error, 0);
    });

    test('returns low error for good downsampling', () {
      // Linear data - downsampling should have low error
      final original = List.generate(
        1000,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final downsampled = downsampler.downsample(
        data: original,
        targetPoints: 100,
      );

      final error = downsampler.estimateError(
        original: original,
        downsampled: downsampled,
      );

      // Error should be small for linear data
      expect(error, lessThan(0.1));
    });

    test('returns higher error for aggressive downsampling', () {
      // Non-linear data with many variations
      final original = List.generate(
        1000,
        (i) => FusionDataPoint(
          i.toDouble(),
          (i % 10).toDouble() * 100, // Oscillating data
        ),
      );

      final downsampled = downsampler.downsample(
        data: original,
        targetPoints: 10, // Very aggressive
      );

      final error = downsampler.estimateError(
        original: original,
        downsampled: downsampled,
      );

      // Error should be between 0 and 1
      expect(error, greaterThanOrEqualTo(0));
      expect(error, lessThanOrEqualTo(1));
    });
  });

  // ===========================================================================
  // SPECIAL DATA PATTERNS
  // ===========================================================================
  group('LTTBDownsampler - Special Patterns', () {
    test('handles constant data', () {
      final data = List.generate(100, (i) => FusionDataPoint(i.toDouble(), 50));

      final result = downsampler.downsample(data: data, targetPoints: 10);

      expect(result.length, 10);
      // All Y values should be the same
      for (final point in result) {
        expect(point.y, 50);
      }
    });

    test('handles ascending data', () {
      final data = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), i.toDouble()),
      );

      final result = downsampler.downsample(data: data, targetPoints: 10);

      expect(result.length, 10);
      expect(result.first.y, 0);
      expect(result.last.y, 99);
    });

    test('handles descending data', () {
      final data = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), (100 - i).toDouble()),
      );

      final result = downsampler.downsample(data: data, targetPoints: 10);

      expect(result.length, 10);
      expect(result.first.y, 100);
      expect(result.last.y, 1);
    });

    test('handles negative values', () {
      final data = List.generate(
        100,
        (i) => FusionDataPoint(i.toDouble(), (i - 50).toDouble()),
      );

      final result = downsampler.downsample(data: data, targetPoints: 10);

      expect(result.length, 10);
      expect(result.first.y, -50);
      expect(result.last.y, 49);
    });
  });
}

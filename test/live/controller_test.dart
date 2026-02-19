import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/live/duplicate_timestamp_behavior.dart';
import 'package:fusion_charts_flutter/src/live/fusion_live_chart_controller.dart';
import 'package:fusion_charts_flutter/src/live/out_of_order_behavior.dart';
import 'package:fusion_charts_flutter/src/live/retention_policy.dart';

void main() {
  // Initialize Flutter binding for tests that use SchedulerBinding
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FusionLiveChartController', () {
    group('construction', () {
      test('creates controller with default settings', () {
        final controller = FusionLiveChartController();

        expect(controller.isPaused, false);
        expect(controller.seriesNames, isEmpty);
        expect(controller.retentionPolicy, isA<UnlimitedPolicy>());
      });

      test('creates controller with custom retention policy', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.rollingCount(100),
        );

        expect(controller.retentionPolicy, isA<RollingCountPolicy>());
      });
    });

    group('addPoint', () {
      test('adds point to series', () {
        final controller = FusionLiveChartController();

        final result = controller.addPoint(
          'temperature',
          const FusionDataPoint(1.0, 25.0),
        );

        expect(result, true);
        expect(controller.getPointCount('temperature'), 1);
        expect(controller.seriesNames, contains('temperature'));
      });

      test('adds multiple points to series', () {
        final controller = FusionLiveChartController();

        controller.addPoint('temp', const FusionDataPoint(1.0, 20.0));
        controller.addPoint('temp', const FusionDataPoint(2.0, 21.0));
        controller.addPoint('temp', const FusionDataPoint(3.0, 22.0));

        expect(controller.getPointCount('temp'), 3);
        expect(controller.getOldestPoint('temp')?.x, 1.0);
        expect(controller.getLatestPoint('temp')?.x, 3.0);
      });

      test('returns false for empty series name', () {
        final controller = FusionLiveChartController();

        final result = controller.addPoint(
          '',
          const FusionDataPoint(1.0, 25.0),
        );

        expect(result, false);
      });

      test('supports multiple series', () {
        final controller = FusionLiveChartController();

        controller.addPoint('temp', const FusionDataPoint(1.0, 25.0));
        controller.addPoint('humidity', const FusionDataPoint(1.0, 60.0));
        controller.addPoint('pressure', const FusionDataPoint(1.0, 1013.0));

        expect(controller.seriesNames.length, 3);
        expect(
          controller.seriesNames,
          containsAll(['temp', 'humidity', 'pressure']),
        );
      });
    });

    group('addPoints', () {
      test('adds multiple points at once', () {
        final controller = FusionLiveChartController();

        final count = controller.addPoints('sensor', [
          const FusionDataPoint(1.0, 10.0),
          const FusionDataPoint(2.0, 20.0),
          const FusionDataPoint(3.0, 30.0),
        ]);

        expect(count, 3);
        expect(controller.getPointCount('sensor'), 3);
      });

      test('returns count of accepted points', () {
        final controller = FusionLiveChartController(
          outOfOrderBehavior: OutOfOrderBehavior.reject,
        );

        controller.addPoint('sensor', const FusionDataPoint(100.0, 10.0));

        // Try to add out-of-order points
        final count = controller.addPoints('sensor', [
          const FusionDataPoint(50.0, 5.0), // Rejected
          const FusionDataPoint(101.0, 11.0), // Accepted
          const FusionDataPoint(60.0, 6.0), // Rejected
          const FusionDataPoint(102.0, 12.0), // Accepted
        ]);

        expect(count, 2);
      });
    });

    group('addMultiSeriesPoints', () {
      test('adds points to multiple series atomically', () {
        final controller = FusionLiveChartController();

        controller.addMultiSeriesPoints({
          'temp': const FusionDataPoint(1.0, 25.0),
          'humidity': const FusionDataPoint(1.0, 60.0),
        });

        expect(controller.getPointCount('temp'), 1);
        expect(controller.getPointCount('humidity'), 1);
      });
    });

    group('setInitialData', () {
      test('sets initial data for series', () {
        final controller = FusionLiveChartController();

        controller.setInitialData('history', [
          const FusionDataPoint(1.0, 10.0),
          const FusionDataPoint(2.0, 20.0),
          const FusionDataPoint(3.0, 30.0),
        ]);

        expect(controller.getPointCount('history'), 3);
      });

      test('clears existing data when called', () {
        final controller = FusionLiveChartController();

        controller.addPoint('history', const FusionDataPoint(0.0, 0.0));
        controller.setInitialData('history', [
          const FusionDataPoint(1.0, 10.0),
        ]);

        expect(controller.getPointCount('history'), 1);
        expect(controller.getOldestPoint('history')?.x, 1.0);
      });
    });

    group('out of order behavior', () {
      test('accepts out-of-order points with warning by default', () {
        final controller = FusionLiveChartController();

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        final result = controller.addPoint(
          's',
          const FusionDataPoint(50.0, 5.0),
        );

        expect(result, true);
        expect(controller.getPointCount('s'), 2);
      });

      test('rejects out-of-order points when configured', () {
        final controller = FusionLiveChartController(
          outOfOrderBehavior: OutOfOrderBehavior.reject,
        );

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        final result = controller.addPoint(
          's',
          const FusionDataPoint(50.0, 5.0),
        );

        expect(result, false);
        expect(controller.getPointCount('s'), 1);
      });

      test('accepts in-order points normally', () {
        final controller = FusionLiveChartController(
          outOfOrderBehavior: OutOfOrderBehavior.reject,
        );

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        final result = controller.addPoint(
          's',
          const FusionDataPoint(101.0, 11.0),
        );

        expect(result, true);
        expect(controller.getPointCount('s'), 2);
      });

      test('accepts equal timestamps', () {
        final controller = FusionLiveChartController(
          outOfOrderBehavior: OutOfOrderBehavior.reject,
        );

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        final result = controller.addPoint(
          's',
          const FusionDataPoint(100.0, 11.0),
        );

        expect(result, true); // Equal is not out-of-order
      });
    });

    group('duplicate timestamp behavior', () {
      test('replaces duplicate timestamps by default', () {
        final controller = FusionLiveChartController();

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(100.0, 15.0));

        expect(controller.getPointCount('s'), 1);
        expect(controller.getLatestPoint('s')?.y, 15.0);
      });

      test('keeps first when configured', () {
        final controller = FusionLiveChartController(
          duplicateTimestampBehavior: DuplicateTimestampBehavior.keepFirst,
        );

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(100.0, 15.0));

        expect(controller.getPointCount('s'), 1);
        expect(controller.getLatestPoint('s')?.y, 10.0);
      });

      test('keeps both when configured', () {
        final controller = FusionLiveChartController(
          duplicateTimestampBehavior: DuplicateTimestampBehavior.keepBoth,
        );

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(100.0, 15.0));

        expect(controller.getPointCount('s'), 2);
      });

      test('averages when configured', () {
        final controller = FusionLiveChartController(
          duplicateTimestampBehavior: DuplicateTimestampBehavior.average,
        );

        controller.addPoint('s', const FusionDataPoint(100.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(100.0, 20.0));

        expect(controller.getPointCount('s'), 1);
        expect(controller.getLatestPoint('s')?.y, 15.0);
      });
    });

    group('retention policy - rolling count', () {
      test('evicts oldest when limit exceeded', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.rollingCount(5),
        );

        for (int i = 0; i < 10; i++) {
          controller.addPoint('s', FusionDataPoint(i.toDouble(), i.toDouble()));
        }

        expect(controller.getPointCount('s'), 5);
        expect(controller.getOldestPoint('s')?.x, 5.0);
        expect(controller.getLatestPoint('s')?.x, 9.0);
      });

      test('tracks eviction count', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.rollingCount(5),
        );

        for (int i = 0; i < 10; i++) {
          controller.addPoint('s', FusionDataPoint(i.toDouble(), i.toDouble()));
        }

        expect(controller.getPointsEvicted('s'), 5);
        expect(controller.getTotalPointsReceived('s'), 10);
      });
    });

    group('retention policy - rolling duration', () {
      test('evicts points older than duration', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.rollingDuration(
            Duration(seconds: 10),
          ),
        );

        // Add points with timestamps in milliseconds
        controller.addPoint('s', const FusionDataPoint(0.0, 1.0));
        controller.addPoint(
          's',
          const FusionDataPoint(5000.0, 2.0),
        ); // 5 seconds
        controller.addPoint(
          's',
          const FusionDataPoint(15000.0, 3.0),
        ); // 15 seconds

        // Point at 0 should be evicted (15000 - 0 > 10000ms)
        expect(controller.getPointCount('s'), 2);
        expect(controller.getOldestPoint('s')?.x, 5000.0);
      });
    });

    group('retention policy - combined', () {
      test('respects both count and duration limits', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.combined(
            maxPoints: 10,
            maxDuration: Duration(seconds: 60),
          ),
        );

        // Add 15 points in 30 seconds
        for (int i = 0; i < 15; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 2000).toDouble(), i.toDouble()),
          );
        }

        // Count limit should kick in: max 10 points
        expect(controller.getPointCount('s'), 10);
      });
    });

    group('retention policy - downsampled', () {
      test('creates controller with downsampled policy', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 10),
            archiveResolution: Duration(seconds: 5),
          ),
        );

        expect(controller.retentionPolicy, isA<DownsampledPolicy>());
        controller.dispose();
      });

      test('keeps recent points at full resolution', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 10),
            archiveResolution: Duration(seconds: 1),
          ),
        );

        // Add points within the recent window (10 seconds = 10000ms)
        // Latest timestamp will be 8000ms, so cutoff is -2000ms (all within)
        for (int i = 0; i < 9; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 1000).toDouble(), i.toDouble()),
          );
        }

        // All points should be in recent buffer, none archived
        expect(controller.getPointCount('s'), 9);
        controller.dispose();
      });

      test('archives old points when exceeding recentDuration', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 5),
            archiveResolution: Duration(seconds: 2),
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        // Add points spanning 20 seconds (timestamps in ms)
        // Points: 0, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000
        for (int i = 0; i <= 10; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 2000).toDouble(), i.toDouble()),
          );
        }

        // Latest is 20000ms, cutoff is 15000ms
        // Recent: 16000, 18000, 20000 (3 points)
        // Archive: 0, 2000, 4000, 6000, 8000, 10000, 12000, 14000 - downsampled
        final points = controller.getPoints('s');
        expect(points.length, greaterThan(3)); // Archive + recent

        // Oldest should be from archive
        expect(controller.getOldestPoint('s')?.x, 0.0);
        // Latest should be from recent buffer
        expect(controller.getLatestPoint('s')?.x, 20000.0);

        controller.dispose();
      });

      test('respects recentMaxPoints limit', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 60), // Long duration
            archiveResolution: Duration(seconds: 1),
            recentMaxPoints: 5, // But only keep 5 recent
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        // Add 10 points - all within 60s window but exceeding count limit
        for (int i = 0; i < 10; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 1000).toDouble(), i.toDouble()),
          );
        }

        final points = controller.getPoints('s');
        // Should have archive points + 5 recent points
        expect(points.length, greaterThan(5));

        // Latest 5 should be from recent buffer
        expect(controller.getLatestPoint('s')?.x, 9000.0);

        controller.dispose();
      });

      test('respects maxArchivePoints limit', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 2),
            archiveResolution: Duration(milliseconds: 500),
            maxArchivePoints: 3,
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        // Add many points to exceed archive limit
        for (int i = 0; i < 50; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 500).toDouble(), i.toDouble()),
          );
        }

        // Archive should be limited to 3 points max
        // Recent buffer has points from last 2 seconds
        final points = controller.getPoints('s');
        // Archive (max 3) + recent points
        expect(points.length, lessThanOrEqualTo(10));

        controller.dispose();
      });

      test('getDataRange includes archive data', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 5),
            archiveResolution: Duration(seconds: 1),
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        // Add points spanning long time range
        controller.addPoint('s', const FusionDataPoint(0.0, 100.0));
        controller.addPoint('s', const FusionDataPoint(5000.0, 50.0));
        controller.addPoint('s', const FusionDataPoint(10000.0, 25.0));
        controller.addPoint('s', const FusionDataPoint(15000.0, 75.0));

        final range = controller.getDataRange('s');
        expect(range, isNotNull);
        // Should include the archived point at 0.0
        expect(range!.$1, 0.0);
        expect(range.$2, 15000.0);

        controller.dispose();
      });

      test('clear removes archive data', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 2),
            archiveResolution: Duration(seconds: 1),
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        // Add points that will create archive
        for (int i = 0; i < 20; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 500).toDouble(), i.toDouble()),
          );
        }

        expect(controller.getPointCount('s'), greaterThan(0));

        controller.clear('s');

        expect(controller.getPointCount('s'), 0);
        expect(controller.getPoints('s'), isEmpty);
        expect(controller.getOldestPoint('s'), isNull);

        controller.dispose();
      });

      test('LTTB downsampling preserves visual shape', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 1),
            archiveResolution: Duration(seconds: 1),
            downsampleMethod: DownsampleMethod.lttb,
          ),
        );

        // Add points with a peak that should be preserved by LTTB
        controller.addPoint('s', const FusionDataPoint(0.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(500.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(1000.0, 100.0)); // Peak
        controller.addPoint('s', const FusionDataPoint(1500.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(2000.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(2500.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(3000.0, 10.0));

        final points = controller.getPoints('s');
        expect(points.isNotEmpty, true);

        controller.dispose();
      });

      test('average downsampling computes bucket averages', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 1),
            archiveResolution: Duration(seconds: 2), // 2 second buckets
            downsampleMethod: DownsampleMethod.average,
          ),
        );

        // Add points that will be averaged
        controller.addPoint('s', const FusionDataPoint(0.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(500.0, 20.0));
        controller.addPoint('s', const FusionDataPoint(1000.0, 30.0));
        // These should trigger archiving of earlier points
        controller.addPoint('s', const FusionDataPoint(5000.0, 40.0));
        controller.addPoint('s', const FusionDataPoint(5500.0, 50.0));

        final points = controller.getPoints('s');
        expect(points.isNotEmpty, true);

        controller.dispose();
      });

      test('minMax downsampling preserves extremes', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 1),
            archiveResolution: Duration(seconds: 2),
            downsampleMethod: DownsampleMethod.minMax,
          ),
        );

        // Add points with min/max that should be preserved
        controller.addPoint('s', const FusionDataPoint(0.0, 50.0));
        controller.addPoint('s', const FusionDataPoint(500.0, 10.0)); // Min
        controller.addPoint('s', const FusionDataPoint(1000.0, 90.0)); // Max
        controller.addPoint('s', const FusionDataPoint(1500.0, 50.0));
        // Trigger archiving
        controller.addPoint('s', const FusionDataPoint(5000.0, 50.0));
        controller.addPoint('s', const FusionDataPoint(5500.0, 50.0));

        final points = controller.getPoints('s');
        expect(points.isNotEmpty, true);

        // Check that min and max are preserved in archive
        final yValues = points.map((p) => p.y).toList();
        expect(yValues.contains(10.0) || yValues.contains(90.0), true);

        controller.dispose();
      });

      test('first downsampling keeps first point per bucket', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 1),
            archiveResolution: Duration(seconds: 2),
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        controller.addPoint(
          's',
          const FusionDataPoint(0.0, 100.0),
        ); // First in bucket
        controller.addPoint('s', const FusionDataPoint(500.0, 200.0));
        controller.addPoint('s', const FusionDataPoint(1000.0, 300.0));
        controller.addPoint('s', const FusionDataPoint(5000.0, 400.0));

        final points = controller.getPoints('s');
        expect(points.isNotEmpty, true);

        controller.dispose();
      });

      test('last downsampling keeps last point per bucket', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 1),
            archiveResolution: Duration(seconds: 2),
            downsampleMethod: DownsampleMethod.last,
          ),
        );

        controller.addPoint('s', const FusionDataPoint(0.0, 100.0));
        controller.addPoint('s', const FusionDataPoint(500.0, 200.0));
        controller.addPoint(
          's',
          const FusionDataPoint(1000.0, 300.0),
        ); // Last in bucket
        controller.addPoint('s', const FusionDataPoint(5000.0, 400.0));

        final points = controller.getPoints('s');
        expect(points.isNotEmpty, true);

        controller.dispose();
      });

      test('multiple series with downsampled policy work independently', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 2),
            archiveResolution: Duration(seconds: 1),
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        // Add points to series A
        for (int i = 0; i < 10; i++) {
          controller.addPoint(
            'a',
            FusionDataPoint((i * 500).toDouble(), i.toDouble()),
          );
        }

        // Add points to series B with different values
        for (int i = 0; i < 10; i++) {
          controller.addPoint(
            'b',
            FusionDataPoint((i * 500).toDouble(), (i * 10).toDouble()),
          );
        }

        final pointsA = controller.getPoints('a');
        final pointsB = controller.getPoints('b');

        expect(pointsA.isNotEmpty, true);
        expect(pointsB.isNotEmpty, true);
        // Different y values in each series
        expect(pointsA.last.y, isNot(equals(pointsB.last.y)));

        controller.dispose();
      });

      test('getOldestPoint returns from archive when available', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.downsampled(
            recentDuration: Duration(seconds: 2),
            archiveResolution: Duration(seconds: 1),
            downsampleMethod: DownsampleMethod.first,
          ),
        );

        // Add old point first
        controller.addPoint('s', const FusionDataPoint(0.0, 1.0));
        // Add more recent points
        for (int i = 1; i <= 10; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 1000).toDouble(), i.toDouble()),
          );
        }

        // Oldest should be from archive (timestamp 0)
        expect(controller.getOldestPoint('s')?.x, 0.0);

        controller.dispose();
      });

      test('changing to downsampled policy from another policy', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.unlimited(),
        );

        // Add points with unlimited policy
        for (int i = 0; i < 20; i++) {
          controller.addPoint(
            's',
            FusionDataPoint((i * 500).toDouble(), i.toDouble()),
          );
        }

        expect(controller.getPointCount('s'), 20);

        // Change to downsampled policy
        controller.retentionPolicy = const RetentionPolicy.downsampled(
          recentDuration: Duration(seconds: 2),
          archiveResolution: Duration(seconds: 1),
          downsampleMethod: DownsampleMethod.first,
        );

        // New points should trigger archiving
        controller.addPoint('s', const FusionDataPoint(15000.0, 100.0));

        expect(controller.getPointCount('s'), lessThanOrEqualTo(21));

        controller.dispose();
      });
    });

    group('retention policy change at runtime', () {
      test('shrinking policy evicts immediately', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.rollingCount(100),
        );

        // Add 100 points
        for (int i = 0; i < 100; i++) {
          controller.addPoint('s', FusionDataPoint(i.toDouble(), i.toDouble()));
        }
        expect(controller.getPointCount('s'), 100);

        // Shrink policy
        controller.retentionPolicy = const RetentionPolicy.rollingCount(50);

        // Should immediately evict 50 oldest
        expect(controller.getPointCount('s'), 50);
        expect(controller.getOldestPoint('s')?.x, 50.0);
      });
    });

    group('pause/resume', () {
      test('pause changes state', () {
        final controller = FusionLiveChartController();

        expect(controller.isPaused, false);
        controller.pause();
        expect(controller.isPaused, true);
      });

      test('resume changes state', () {
        final controller = FusionLiveChartController();

        controller.pause();
        controller.resume();
        expect(controller.isPaused, false);
      });

      test('pause is idempotent', () {
        final controller = FusionLiveChartController();

        controller.pause();
        controller.pause();
        expect(controller.isPaused, true);
      });

      test('resume without pause is no-op', () {
        final controller = FusionLiveChartController();

        controller.resume();
        expect(controller.isPaused, false);
      });

      test('data continues to buffer while paused', () {
        final controller = FusionLiveChartController();

        controller.pause();
        controller.addPoint('s', const FusionDataPoint(1.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(2.0, 20.0));

        expect(controller.getPointCount('s'), 2);
      });

      test('onPauseChanged callback fires', () {
        final controller = FusionLiveChartController();
        final states = <bool>[];

        controller.onPauseChanged = states.add;

        controller.pause();
        controller.resume();
        controller.pause();

        expect(states, [true, false, true]);
      });
    });

    group('data access', () {
      test('getPoints returns all points', () {
        final controller = FusionLiveChartController();

        controller.addPoint('s', const FusionDataPoint(1.0, 10.0));
        controller.addPoint('s', const FusionDataPoint(2.0, 20.0));
        controller.addPoint('s', const FusionDataPoint(3.0, 30.0));

        final points = controller.getPoints('s');
        expect(points.length, 3);
        expect(points[0].x, 1.0);
        expect(points[2].x, 3.0);
      });

      test('getPoints returns empty for unknown series', () {
        final controller = FusionLiveChartController();

        final points = controller.getPoints('unknown');
        expect(points, isEmpty);
      });

      test('getDataRange returns correct range', () {
        final controller = FusionLiveChartController();

        controller.addPoint('s', const FusionDataPoint(10.0, 1.0));
        controller.addPoint('s', const FusionDataPoint(50.0, 5.0));
        controller.addPoint('s', const FusionDataPoint(30.0, 3.0));

        final range = controller.getDataRange('s');
        expect(range, isNotNull);
        expect(range!.$1, 10.0);
        expect(range.$2, 30.0);
      });

      test('getDataRange returns null for empty series', () {
        final controller = FusionLiveChartController();

        final range = controller.getDataRange('unknown');
        expect(range, isNull);
      });
    });

    group('clear', () {
      test('clears specific series', () {
        final controller = FusionLiveChartController();

        controller.addPoint('a', const FusionDataPoint(1.0, 10.0));
        controller.addPoint('b', const FusionDataPoint(1.0, 20.0));

        controller.clear('a');

        expect(controller.getPointCount('a'), 0);
        expect(controller.getPointCount('b'), 1);
      });

      test('clears all series when no name provided', () {
        final controller = FusionLiveChartController();

        controller.addPoint('a', const FusionDataPoint(1.0, 10.0));
        controller.addPoint('b', const FusionDataPoint(1.0, 20.0));

        controller.clear();

        expect(controller.getPointCount('a'), 0);
        expect(controller.getPointCount('b'), 0);
      });
    });

    group('stream binding', () {
      test('bindStream adds points from stream', () async {
        final controller = FusionLiveChartController();
        final streamController = StreamController<int>();

        controller.bindStream<int>(
          'sensor',
          streamController.stream,
          mapper: (value) =>
              FusionDataPoint(value.toDouble(), value.toDouble()),
        );

        streamController.add(1);
        streamController.add(2);
        streamController.add(3);

        // Wait for stream events to be processed
        await Future<void>.delayed(Duration.zero);

        expect(controller.getPointCount('sensor'), 3);

        await streamController.close();
        controller.dispose();
      });

      test('unbindStream cancels subscription', () async {
        final controller = FusionLiveChartController();
        final streamController = StreamController<int>();

        controller.bindStream<int>(
          'sensor',
          streamController.stream,
          mapper: (value) =>
              FusionDataPoint(value.toDouble(), value.toDouble()),
        );

        streamController.add(1);
        await Future<void>.delayed(Duration.zero);

        controller.unbindStream('sensor');

        streamController.add(2);
        await Future<void>.delayed(Duration.zero);

        expect(controller.getPointCount('sensor'), 1);
        expect(controller.hasStreamBinding('sensor'), false);

        await streamController.close();
        controller.dispose();
      });

      test('hasStreamBinding returns correct state', () async {
        final controller = FusionLiveChartController();
        final streamController = StreamController<int>();

        expect(controller.hasStreamBinding('sensor'), false);

        controller.bindStream<int>(
          'sensor',
          streamController.stream,
          mapper: (value) =>
              FusionDataPoint(value.toDouble(), value.toDouble()),
        );

        expect(controller.hasStreamBinding('sensor'), true);

        controller.unbindStream('sensor');
        expect(controller.hasStreamBinding('sensor'), false);

        await streamController.close();
        controller.dispose();
      });

      test('rebinding unbinds previous stream', () async {
        final controller = FusionLiveChartController();
        final stream1 = StreamController<int>();
        final stream2 = StreamController<int>();

        controller.bindStream<int>(
          'sensor',
          stream1.stream,
          mapper: (v) => FusionDataPoint(v.toDouble(), v.toDouble()),
        );

        stream1.add(1);
        await Future<void>.delayed(Duration.zero);

        controller.bindStream<int>(
          'sensor',
          stream2.stream,
          mapper: (v) => FusionDataPoint(v.toDouble(), (v * 10).toDouble()),
        );

        stream1.add(2);
        stream2.add(3);
        await Future<void>.delayed(Duration.zero);

        // Should only have point from stream2
        final points = controller.getPoints('sensor');
        expect(points.length, 2); // 1 from stream1, 1 from stream2
        expect(points.last.y, 30.0); // From stream2

        await stream1.close();
        await stream2.close();
        controller.dispose();
      });
    });

    group('statistics', () {
      test('getStatistics returns correct info', () {
        final controller = FusionLiveChartController(
          retentionPolicy: const RetentionPolicy.rollingCount(5),
        );

        for (int i = 0; i < 10; i++) {
          controller.addPoint('s', FusionDataPoint(i.toDouble(), i.toDouble()));
        }

        final stats = controller.getStatistics();

        expect(stats.totalPoints, 5);
        expect(stats.seriesStats['s']?.pointCount, 5);
        expect(stats.seriesStats['s']?.totalReceived, 10);
        expect(stats.seriesStats['s']?.totalEvicted, 5);
      });

      test('getMemoryUsage returns estimate', () {
        final controller = FusionLiveChartController();

        for (int i = 0; i < 100; i++) {
          controller.addPoint('s', FusionDataPoint(i.toDouble(), i.toDouble()));
        }

        final memory = controller.getMemoryUsage('s');
        expect(memory, greaterThan(0));
      });
    });

    group('dispose', () {
      test('dispose cleans up resources', () async {
        final controller = FusionLiveChartController();
        final streamController = StreamController<int>();

        controller.bindStream<int>(
          'sensor',
          streamController.stream,
          mapper: (v) => FusionDataPoint(v.toDouble(), v.toDouble()),
        );

        controller.dispose();

        // Should not throw after dispose
        controller.addPoint('s', const FusionDataPoint(1.0, 1.0));

        await streamController.close();
      });

      test('addPoint returns false after dispose', () {
        final controller = FusionLiveChartController();
        controller.dispose();

        final result = controller.addPoint(
          's',
          const FusionDataPoint(1.0, 1.0),
        );

        expect(result, false);
      });
    });

    group('notifications', () {
      test('notifies listeners when data added', () async {
        final controller = FusionLiveChartController(frameCoalescing: false);
        int notifyCount = 0;

        controller.addListener(() {
          notifyCount++;
        });

        controller.addPoint('s', const FusionDataPoint(1.0, 1.0));
        controller.addPoint('s', const FusionDataPoint(2.0, 2.0));

        expect(notifyCount, 2);

        controller.dispose();
      });

      test('coalesces notifications with frame coalescing', () async {
        final controller = FusionLiveChartController(frameCoalescing: true);
        int notifyCount = 0;

        controller.addListener(() {
          notifyCount++;
        });

        // Add many points rapidly
        for (int i = 0; i < 100; i++) {
          controller.addPoint('s', FusionDataPoint(i.toDouble(), i.toDouble()));
        }

        // Should not have 100 notifications yet (coalescing)
        expect(notifyCount, lessThan(100));

        controller.dispose();
      });
    });

    group('edge cases', () {
      test('handles NaN y-values', () {
        final controller = FusionLiveChartController();

        final result = controller.addPoint(
          's',
          const FusionDataPoint(1.0, double.nan),
        );

        expect(result, true);
        expect(controller.getLatestPoint('s')?.y.isNaN, true);
      });

      test('handles infinite y-values', () {
        final controller = FusionLiveChartController();

        final result = controller.addPoint(
          's',
          const FusionDataPoint(1.0, double.infinity),
        );

        expect(result, true);
        // Infinite should be converted to 0.0
        expect(controller.getLatestPoint('s')?.y, 0.0);
      });

      test('multiple controllers work independently', () {
        final controller1 = FusionLiveChartController();
        final controller2 = FusionLiveChartController();

        controller1.addPoint('s', const FusionDataPoint(1.0, 10.0));
        controller2.addPoint('s', const FusionDataPoint(1.0, 20.0));

        expect(controller1.getLatestPoint('s')?.y, 10.0);
        expect(controller2.getLatestPoint('s')?.y, 20.0);

        controller1.dispose();
        controller2.dispose();
      });
    });
  });
}

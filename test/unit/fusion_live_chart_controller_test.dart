import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';
import 'package:fusion_charts_flutter/src/live/duplicate_timestamp_behavior.dart';
import 'package:fusion_charts_flutter/src/live/fusion_live_chart_controller.dart';
import 'package:fusion_charts_flutter/src/live/out_of_order_behavior.dart';
import 'package:fusion_charts_flutter/src/live/retention_policy.dart';

void main() {
  // Ensure Flutter binding is initialized for SchedulerBinding access
  TestWidgetsFlutterBinding.ensureInitialized();
  // ===========================================================================
  // RETENTION POLICY - ROLLING COUNT
  // ===========================================================================
  group('RetentionPolicy - RollingCount', () {
    test('creates with maxPoints', () {
      const policy = RetentionPolicy.rollingCount(500);
      expect(policy, isA<RollingCountPolicy>());
      expect((policy as RollingCountPolicy).maxPoints, 500);
    });

    test('equality works correctly', () {
      const policy1 = RollingCountPolicy(500);
      const policy2 = RollingCountPolicy(500);
      const policy3 = RollingCountPolicy(100);

      expect(policy1, equals(policy2));
      expect(policy1, isNot(equals(policy3)));
    });

    test('hashCode is consistent', () {
      const policy1 = RollingCountPolicy(500);
      const policy2 = RollingCountPolicy(500);

      expect(policy1.hashCode, equals(policy2.hashCode));
    });

    test('toString returns descriptive string', () {
      const policy = RollingCountPolicy(500);
      expect(policy.toString(), contains('RollingCountPolicy'));
      expect(policy.toString(), contains('500'));
    });
  });

  // ===========================================================================
  // RETENTION POLICY - ROLLING DURATION
  // ===========================================================================
  group('RetentionPolicy - RollingDuration', () {
    test('creates with duration', () {
      const policy = RetentionPolicy.rollingDuration(Duration(minutes: 5));
      expect(policy, isA<RollingDurationPolicy>());
      expect(
        (policy as RollingDurationPolicy).duration,
        const Duration(minutes: 5),
      );
    });

    test('equality works correctly', () {
      const policy1 = RollingDurationPolicy(Duration(minutes: 5));
      const policy2 = RollingDurationPolicy(Duration(minutes: 5));
      const policy3 = RollingDurationPolicy(Duration(minutes: 10));

      expect(policy1, equals(policy2));
      expect(policy1, isNot(equals(policy3)));
    });

    test('hashCode is consistent', () {
      const policy1 = RollingDurationPolicy(Duration(minutes: 5));
      const policy2 = RollingDurationPolicy(Duration(minutes: 5));

      expect(policy1.hashCode, equals(policy2.hashCode));
    });

    test('toString returns descriptive string', () {
      const policy = RollingDurationPolicy(Duration(minutes: 5));
      expect(policy.toString(), contains('RollingDurationPolicy'));
    });
  });

  // ===========================================================================
  // RETENTION POLICY - UNLIMITED
  // ===========================================================================
  group('RetentionPolicy - Unlimited', () {
    test('creates unlimited policy', () {
      const policy = RetentionPolicy.unlimited();
      expect(policy, isA<UnlimitedPolicy>());
    });

    test('equality works correctly', () {
      const policy1 = UnlimitedPolicy();
      const policy2 = UnlimitedPolicy();

      expect(policy1, equals(policy2));
    });

    test('hashCode is consistent', () {
      const policy1 = UnlimitedPolicy();
      const policy2 = UnlimitedPolicy();

      expect(policy1.hashCode, equals(policy2.hashCode));
    });

    test('toString returns descriptive string', () {
      const policy = UnlimitedPolicy();
      expect(policy.toString(), contains('UnlimitedPolicy'));
    });
  });

  // ===========================================================================
  // RETENTION POLICY - COMBINED
  // ===========================================================================
  group('RetentionPolicy - Combined', () {
    test('creates with count and duration', () {
      const policy = RetentionPolicy.combined(
        maxPoints: 1000,
        maxDuration: Duration(minutes: 5),
      );
      expect(policy, isA<CombinedPolicy>());
      expect((policy as CombinedPolicy).maxPoints, 1000);
      expect(policy.maxDuration, const Duration(minutes: 5));
    });

    test('equality works correctly', () {
      const policy1 = CombinedPolicy(
        maxPoints: 1000,
        maxDuration: Duration(minutes: 5),
      );
      const policy2 = CombinedPolicy(
        maxPoints: 1000,
        maxDuration: Duration(minutes: 5),
      );
      const policy3 = CombinedPolicy(
        maxPoints: 500,
        maxDuration: Duration(minutes: 5),
      );

      expect(policy1, equals(policy2));
      expect(policy1, isNot(equals(policy3)));
    });

    test('hashCode is consistent', () {
      const policy1 = CombinedPolicy(
        maxPoints: 1000,
        maxDuration: Duration(minutes: 5),
      );
      const policy2 = CombinedPolicy(
        maxPoints: 1000,
        maxDuration: Duration(minutes: 5),
      );

      expect(policy1.hashCode, equals(policy2.hashCode));
    });

    test('toString returns descriptive string', () {
      const policy = CombinedPolicy(
        maxPoints: 1000,
        maxDuration: Duration(minutes: 5),
      );
      expect(policy.toString(), contains('CombinedPolicy'));
      expect(policy.toString(), contains('1000'));
    });
  });

  // ===========================================================================
  // RETENTION POLICY - DOWNSAMPLED
  // ===========================================================================
  group('RetentionPolicy - Downsampled', () {
    test('creates with default method', () {
      const policy = RetentionPolicy.downsampled(
        recentDuration: Duration(minutes: 5),
        archiveResolution: Duration(seconds: 30),
      );
      expect(policy, isA<DownsampledPolicy>());
      expect(
        (policy as DownsampledPolicy).recentDuration,
        const Duration(minutes: 5),
      );
      expect(policy.archiveResolution, const Duration(seconds: 30));
      expect(policy.downsampleMethod, DownsampleMethod.lttb);
    });

    test('creates with all options', () {
      const policy = DownsampledPolicy(
        recentDuration: Duration(minutes: 5),
        recentMaxPoints: 500,
        archiveResolution: Duration(seconds: 30),
        maxArchivePoints: 1000,
        downsampleMethod: DownsampleMethod.average,
      );

      expect(policy.recentDuration, const Duration(minutes: 5));
      expect(policy.recentMaxPoints, 500);
      expect(policy.archiveResolution, const Duration(seconds: 30));
      expect(policy.maxArchivePoints, 1000);
      expect(policy.downsampleMethod, DownsampleMethod.average);
    });

    test('equality works correctly', () {
      const policy1 = DownsampledPolicy(
        recentDuration: Duration(minutes: 5),
        archiveResolution: Duration(seconds: 30),
      );
      const policy2 = DownsampledPolicy(
        recentDuration: Duration(minutes: 5),
        archiveResolution: Duration(seconds: 30),
      );
      const policy3 = DownsampledPolicy(
        recentDuration: Duration(minutes: 10),
        archiveResolution: Duration(seconds: 30),
      );

      expect(policy1, equals(policy2));
      expect(policy1, isNot(equals(policy3)));
    });

    test('hashCode is consistent', () {
      const policy1 = DownsampledPolicy(
        recentDuration: Duration(minutes: 5),
        archiveResolution: Duration(seconds: 30),
      );
      const policy2 = DownsampledPolicy(
        recentDuration: Duration(minutes: 5),
        archiveResolution: Duration(seconds: 30),
      );

      expect(policy1.hashCode, equals(policy2.hashCode));
    });

    test('toString returns descriptive string', () {
      const policy = DownsampledPolicy(
        recentDuration: Duration(minutes: 5),
        archiveResolution: Duration(seconds: 30),
      );
      expect(policy.toString(), contains('DownsampledPolicy'));
    });
  });

  // ===========================================================================
  // DOWNSAMPLE METHOD ENUM
  // ===========================================================================
  group('DownsampleMethod', () {
    test('has all expected values', () {
      expect(
        DownsampleMethod.values,
        containsAll([
          DownsampleMethod.first,
          DownsampleMethod.last,
          DownsampleMethod.average,
          DownsampleMethod.minMax,
          DownsampleMethod.lttb,
        ]),
      );
    });

    test('has 5 values', () {
      expect(DownsampleMethod.values.length, 5);
    });
  });

  // ===========================================================================
  // LIVE CHART CONTROLLER - CONSTRUCTION
  // ===========================================================================
  group('FusionLiveChartController - Construction', () {
    test('creates with default values', () {
      final controller = FusionLiveChartController();

      expect(controller.retentionPolicy, isA<UnlimitedPolicy>());
      expect(controller.frameCoalescing, isTrue);
      expect(
        controller.outOfOrderBehavior,
        OutOfOrderBehavior.acceptWithWarning,
      );
      expect(
        controller.duplicateTimestampBehavior,
        DuplicateTimestampBehavior.replace,
      );

      controller.dispose();
    });

    test('creates with custom retention policy', () {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(500),
      );

      expect(controller.retentionPolicy, isA<RollingCountPolicy>());
      expect((controller.retentionPolicy as RollingCountPolicy).maxPoints, 500);

      controller.dispose();
    });

    test('creates with frame coalescing disabled', () {
      final controller = FusionLiveChartController(frameCoalescing: false);

      expect(controller.frameCoalescing, isFalse);

      controller.dispose();
    });

    test('creates with custom out-of-order behavior', () {
      final controller = FusionLiveChartController(
        outOfOrderBehavior: OutOfOrderBehavior.reject,
      );

      expect(controller.outOfOrderBehavior, OutOfOrderBehavior.reject);

      controller.dispose();
    });

    test('creates with custom duplicate behavior', () {
      final controller = FusionLiveChartController(
        duplicateTimestampBehavior: DuplicateTimestampBehavior.keepBoth,
      );

      expect(
        controller.duplicateTimestampBehavior,
        DuplicateTimestampBehavior.keepBoth,
      );

      controller.dispose();
    });
  });

  // ===========================================================================
  // DATA INGESTION - ADDPOINT
  // ===========================================================================
  group('FusionLiveChartController - addPoint', () {
    test('adds point to series', () {
      final controller = FusionLiveChartController();

      final result = controller.addPoint('test', const FusionDataPoint(1, 10));

      expect(result, isTrue);
      expect(controller.getPointCount('test'), 1);

      controller.dispose();
    });

    test('adds multiple points sequentially', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(2, 20));
      controller.addPoint('test', const FusionDataPoint(3, 30));

      expect(controller.getPointCount('test'), 3);

      controller.dispose();
    });

    test('returns false for empty series name', () {
      final controller = FusionLiveChartController();

      final result = controller.addPoint('', const FusionDataPoint(1, 10));

      expect(result, isFalse);

      controller.dispose();
    });

    test('returns false after dispose', () {
      final controller = FusionLiveChartController();
      controller.dispose();

      final result = controller.addPoint('test', const FusionDataPoint(1, 10));

      expect(result, isFalse);
    });

    test('handles NaN values', () {
      final controller = FusionLiveChartController();

      final result = controller.addPoint(
        'test',
        const FusionDataPoint(1, double.nan),
      );

      expect(result, isTrue);

      controller.dispose();
    });

    test('handles infinity values', () {
      final controller = FusionLiveChartController();

      final result = controller.addPoint(
        'test',
        const FusionDataPoint(1, double.infinity),
      );

      expect(result, isTrue);
      // Should be replaced with 0.0
      expect(controller.getLatestPoint('test')?.y, 0.0);

      controller.dispose();
    });
  });

  // ===========================================================================
  // DATA INGESTION - ADDPOINTS
  // ===========================================================================
  group('FusionLiveChartController - addPoints', () {
    test('adds batch of points', () {
      final controller = FusionLiveChartController();

      final accepted = controller.addPoints('test', [
        const FusionDataPoint(1, 10),
        const FusionDataPoint(2, 20),
        const FusionDataPoint(3, 30),
      ]);

      expect(accepted, 3);
      expect(controller.getPointCount('test'), 3);

      controller.dispose();
    });

    test('returns 0 for empty list', () {
      final controller = FusionLiveChartController();

      final accepted = controller.addPoints('test', []);

      expect(accepted, 0);

      controller.dispose();
    });

    test('returns 0 for empty series name', () {
      final controller = FusionLiveChartController();

      final accepted = controller.addPoints('', [const FusionDataPoint(1, 10)]);

      expect(accepted, 0);

      controller.dispose();
    });

    test('returns 0 after dispose', () {
      final controller = FusionLiveChartController();
      controller.dispose();

      final accepted = controller.addPoints('test', [
        const FusionDataPoint(1, 10),
      ]);

      expect(accepted, 0);
    });
  });

  // ===========================================================================
  // DATA INGESTION - ADD MULTI SERIES
  // ===========================================================================
  group('FusionLiveChartController - addMultiSeriesPoints', () {
    test('adds points to multiple series', () {
      final controller = FusionLiveChartController();

      controller.addMultiSeriesPoints({
        'temp': const FusionDataPoint(1, 25),
        'humidity': const FusionDataPoint(1, 60),
      });

      expect(controller.getPointCount('temp'), 1);
      expect(controller.getPointCount('humidity'), 1);

      controller.dispose();
    });

    test('does nothing for empty map', () {
      final controller = FusionLiveChartController();

      controller.addMultiSeriesPoints({});

      expect(controller.seriesNames, isEmpty);

      controller.dispose();
    });

    test('does nothing after dispose', () {
      final controller = FusionLiveChartController();
      controller.dispose();

      controller.addMultiSeriesPoints({'temp': const FusionDataPoint(1, 25)});
    });
  });

  // ===========================================================================
  // SET INITIAL DATA
  // ===========================================================================
  group('FusionLiveChartController - setInitialData', () {
    test('sets initial data for series', () {
      final controller = FusionLiveChartController();

      controller.setInitialData('test', [
        const FusionDataPoint(1, 10),
        const FusionDataPoint(2, 20),
        const FusionDataPoint(3, 30),
      ]);

      expect(controller.getPointCount('test'), 3);

      controller.dispose();
    });

    test('replaces existing data', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test', const FusionDataPoint(100, 100));
      controller.setInitialData('test', [
        const FusionDataPoint(1, 10),
        const FusionDataPoint(2, 20),
      ]);

      expect(controller.getPointCount('test'), 2);
      expect(controller.getOldestPoint('test')?.x, 1);

      controller.dispose();
    });

    test('does nothing for empty series name', () {
      final controller = FusionLiveChartController();

      controller.setInitialData('', [const FusionDataPoint(1, 10)]);

      expect(controller.seriesNames, isEmpty);

      controller.dispose();
    });
  });

  // ===========================================================================
  // DATA ACCESS
  // ===========================================================================
  group('FusionLiveChartController - Data Access', () {
    test('getPoints returns all points', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(2, 20));

      final points = controller.getPoints('test');

      expect(points.length, 2);
      expect(points[0].x, 1);
      expect(points[1].x, 2);

      controller.dispose();
    });

    test('getPoints returns empty list for unknown series', () {
      final controller = FusionLiveChartController();

      final points = controller.getPoints('unknown');

      expect(points, isEmpty);

      controller.dispose();
    });

    test('getLatestPoint returns most recent point', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(2, 20));

      final latest = controller.getLatestPoint('test');

      expect(latest?.x, 2);
      expect(latest?.y, 20);

      controller.dispose();
    });

    test('getLatestPoint returns null for empty series', () {
      final controller = FusionLiveChartController();

      final latest = controller.getLatestPoint('unknown');

      expect(latest, isNull);

      controller.dispose();
    });

    test('getOldestPoint returns oldest point', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(2, 20));

      final oldest = controller.getOldestPoint('test');

      expect(oldest?.x, 1);
      expect(oldest?.y, 10);

      controller.dispose();
    });

    test('getOldestPoint returns null for empty series', () {
      final controller = FusionLiveChartController();

      final oldest = controller.getOldestPoint('unknown');

      expect(oldest, isNull);

      controller.dispose();
    });

    test('getPointCount returns correct count', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(2, 20));

      expect(controller.getPointCount('test'), 2);

      controller.dispose();
    });

    test('getPointCount returns 0 for unknown series', () {
      final controller = FusionLiveChartController();

      expect(controller.getPointCount('unknown'), 0);

      controller.dispose();
    });

    test('seriesNames returns all series with data', () {
      final controller = FusionLiveChartController();

      controller.addPoint('temp', const FusionDataPoint(1, 25));
      controller.addPoint('humidity', const FusionDataPoint(1, 60));

      expect(controller.seriesNames, containsAll(['temp', 'humidity']));

      controller.dispose();
    });

    test('getDataRange returns min and max', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test', const FusionDataPoint(10, 100));
      controller.addPoint('test', const FusionDataPoint(20, 200));
      controller.addPoint('test', const FusionDataPoint(30, 300));

      final range = controller.getDataRange('test');

      expect(range?.$1, 10);
      expect(range?.$2, 30);

      controller.dispose();
    });

    test('getDataRange returns null for empty series', () {
      final controller = FusionLiveChartController();

      final range = controller.getDataRange('unknown');

      expect(range, isNull);

      controller.dispose();
    });
  });

  // ===========================================================================
  // CLEAR
  // ===========================================================================
  group('FusionLiveChartController - clear', () {
    test('clears specific series', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test1', const FusionDataPoint(1, 10));
      controller.addPoint('test2', const FusionDataPoint(1, 20));
      controller.clear('test1');

      expect(controller.getPointCount('test1'), 0);
      expect(controller.getPointCount('test2'), 1);

      controller.dispose();
    });

    test('clears all series when no name provided', () {
      final controller = FusionLiveChartController();

      controller.addPoint('test1', const FusionDataPoint(1, 10));
      controller.addPoint('test2', const FusionDataPoint(1, 20));
      controller.clear();

      expect(controller.getPointCount('test1'), 0);
      expect(controller.getPointCount('test2'), 0);

      controller.dispose();
    });
  });

  // ===========================================================================
  // PAUSE/RESUME
  // ===========================================================================
  group('FusionLiveChartController - Pause/Resume', () {
    test('pause sets isPaused to true', () {
      final controller = FusionLiveChartController();

      controller.pause();

      expect(controller.isPaused, isTrue);

      controller.dispose();
    });

    test('pause is idempotent', () {
      final controller = FusionLiveChartController();

      controller.pause();
      controller.pause();

      expect(controller.isPaused, isTrue);

      controller.dispose();
    });

    test('resume sets isPaused to false', () {
      final controller = FusionLiveChartController();

      controller.pause();
      controller.resume();

      expect(controller.isPaused, isFalse);

      controller.dispose();
    });

    test('resume is idempotent', () {
      final controller = FusionLiveChartController();

      controller.resume();
      controller.resume();

      expect(controller.isPaused, isFalse);

      controller.dispose();
    });

    test('onPauseChanged is called on pause', () {
      final controller = FusionLiveChartController();
      bool? pauseState;

      controller.onPauseChanged = (isPaused) => pauseState = isPaused;
      controller.pause();

      expect(pauseState, isTrue);

      controller.dispose();
    });

    test('onPauseChanged is called on resume', () {
      final controller = FusionLiveChartController();
      bool? pauseState;

      controller.onPauseChanged = (isPaused) => pauseState = isPaused;
      controller.pause();
      controller.resume();

      expect(pauseState, isFalse);

      controller.dispose();
    });

    test('resumeAnimationDuration uses provided duration', () {
      final controller = FusionLiveChartController();

      controller.pause();
      controller.resume(animationDuration: const Duration(milliseconds: 500));

      expect(
        controller.resumeAnimationDuration,
        const Duration(milliseconds: 500),
      );

      controller.dispose();
    });
  });

  // ===========================================================================
  // RETENTION POLICY APPLICATION
  // ===========================================================================
  group('FusionLiveChartController - Retention Policy', () {
    test('applies rolling count policy', () {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(3),
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(2, 20));
      controller.addPoint('test', const FusionDataPoint(3, 30));
      controller.addPoint('test', const FusionDataPoint(4, 40));
      controller.addPoint('test', const FusionDataPoint(5, 50));

      expect(controller.getPointCount('test'), 3);
      expect(controller.getOldestPoint('test')?.x, 3);
      expect(controller.getLatestPoint('test')?.x, 5);

      controller.dispose();
    });

    test('changing retention policy applies immediately', () {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.unlimited(),
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(2, 20));
      controller.addPoint('test', const FusionDataPoint(3, 30));
      controller.addPoint('test', const FusionDataPoint(4, 40));
      controller.addPoint('test', const FusionDataPoint(5, 50));

      expect(controller.getPointCount('test'), 5);

      controller.retentionPolicy = const RetentionPolicy.rollingCount(2);

      expect(controller.getPointCount('test'), 2);

      controller.dispose();
    });

    test('same policy does not trigger reapplication', () {
      final controller = FusionLiveChartController(
        retentionPolicy: const RetentionPolicy.rollingCount(3),
      );
      int notifyCount = 0;

      controller.addListener(() => notifyCount++);
      controller.retentionPolicy = const RetentionPolicy.rollingCount(3);

      expect(notifyCount, 0);

      controller.dispose();
    });
  });

  // ===========================================================================
  // OUT OF ORDER BEHAVIOR
  // ===========================================================================
  group('FusionLiveChartController - Out of Order', () {
    test('accept behavior accepts out-of-order points', () {
      final controller = FusionLiveChartController(
        outOfOrderBehavior: OutOfOrderBehavior.accept,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(10, 100));
      final result = controller.addPoint('test', const FusionDataPoint(5, 50));

      expect(result, isTrue);
      expect(controller.getPointCount('test'), 2);

      controller.dispose();
    });

    test('reject behavior rejects out-of-order points', () {
      final controller = FusionLiveChartController(
        outOfOrderBehavior: OutOfOrderBehavior.reject,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(10, 100));
      final result = controller.addPoint('test', const FusionDataPoint(5, 50));

      expect(result, isFalse);
      expect(controller.getPointCount('test'), 1);

      controller.dispose();
    });

    test('acceptWithWarning behavior accepts out-of-order points', () {
      final controller = FusionLiveChartController(
        outOfOrderBehavior: OutOfOrderBehavior.acceptWithWarning,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(10, 100));
      final result = controller.addPoint('test', const FusionDataPoint(5, 50));

      expect(result, isTrue);
      expect(controller.getPointCount('test'), 2);

      controller.dispose();
    });

    test('autoSort behavior accepts out-of-order points', () {
      final controller = FusionLiveChartController(
        outOfOrderBehavior: OutOfOrderBehavior.autoSort,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(10, 100));
      final result = controller.addPoint('test', const FusionDataPoint(5, 50));

      expect(result, isTrue);
      expect(controller.getPointCount('test'), 2);

      controller.dispose();
    });
  });

  // ===========================================================================
  // DUPLICATE TIMESTAMP BEHAVIOR
  // ===========================================================================
  group('FusionLiveChartController - Duplicate Timestamp', () {
    test('replace behavior replaces duplicate', () {
      final controller = FusionLiveChartController(
        duplicateTimestampBehavior: DuplicateTimestampBehavior.replace,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(1, 20));

      expect(controller.getPointCount('test'), 1);
      expect(controller.getLatestPoint('test')?.y, 20);

      controller.dispose();
    });

    test('keepFirst behavior keeps first', () {
      final controller = FusionLiveChartController(
        duplicateTimestampBehavior: DuplicateTimestampBehavior.keepFirst,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(1, 10));
      final result = controller.addPoint('test', const FusionDataPoint(1, 20));

      expect(result, isFalse);
      expect(controller.getPointCount('test'), 1);
      expect(controller.getLatestPoint('test')?.y, 10);

      controller.dispose();
    });

    test('keepBoth behavior keeps both', () {
      final controller = FusionLiveChartController(
        duplicateTimestampBehavior: DuplicateTimestampBehavior.keepBoth,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(1, 20));

      expect(controller.getPointCount('test'), 2);

      controller.dispose();
    });

    test('average behavior averages duplicates', () {
      final controller = FusionLiveChartController(
        duplicateTimestampBehavior: DuplicateTimestampBehavior.average,
        frameCoalescing: false,
      );

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.addPoint('test', const FusionDataPoint(1, 30));

      expect(controller.getPointCount('test'), 1);
      expect(controller.getLatestPoint('test')?.y, 20);

      controller.dispose();
    });
  });

  // ===========================================================================
  // STREAM BINDING
  // ===========================================================================
  group('FusionLiveChartController - Stream Binding', () {
    test('bindStream adds data from stream', () async {
      final controller = FusionLiveChartController(frameCoalescing: false);
      final streamController = StreamController<int>.broadcast();

      controller.bindStream<int>(
        'test',
        streamController.stream,
        mapper: (value) => FusionDataPoint(value.toDouble(), value.toDouble()),
      );

      streamController.add(1);
      streamController.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.getPointCount('test'), 2);

      await streamController.close();
      controller.dispose();
    });

    test('hasStreamBinding returns true for bound stream', () {
      final controller = FusionLiveChartController();
      final streamController = StreamController<int>.broadcast();

      controller.bindStream<int>(
        'test',
        streamController.stream,
        mapper: (value) => FusionDataPoint(value.toDouble(), value.toDouble()),
      );

      expect(controller.hasStreamBinding('test'), isTrue);
      expect(controller.hasStreamBinding('other'), isFalse);

      streamController.close();
      controller.dispose();
    });

    test('unbindStream cancels stream', () async {
      final controller = FusionLiveChartController(frameCoalescing: false);
      final streamController = StreamController<int>.broadcast();

      controller.bindStream<int>(
        'test',
        streamController.stream,
        mapper: (value) => FusionDataPoint(value.toDouble(), value.toDouble()),
      );

      streamController.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      controller.unbindStream('test');
      expect(controller.hasStreamBinding('test'), isFalse);

      await streamController.close();
      controller.dispose();
    });

    test('unbindAllStreams cancels all streams', () {
      final controller = FusionLiveChartController();
      final stream1 = StreamController<int>.broadcast();
      final stream2 = StreamController<int>.broadcast();

      controller.bindStream<int>(
        'test1',
        stream1.stream,
        mapper: (value) => FusionDataPoint(value.toDouble(), value.toDouble()),
      );
      controller.bindStream<int>(
        'test2',
        stream2.stream,
        mapper: (value) => FusionDataPoint(value.toDouble(), value.toDouble()),
      );

      controller.unbindAllStreams();

      expect(controller.hasStreamBinding('test1'), isFalse);
      expect(controller.hasStreamBinding('test2'), isFalse);

      stream1.close();
      stream2.close();
      controller.dispose();
    });

    test('throws when binding to disposed controller', () {
      final controller = FusionLiveChartController();
      final streamController = StreamController<int>.broadcast();
      controller.dispose();

      expect(
        () => controller.bindStream<int>(
          'test',
          streamController.stream,
          mapper: (value) =>
              FusionDataPoint(value.toDouble(), value.toDouble()),
        ),
        throwsStateError,
      );

      streamController.close();
    });
  });

  // ===========================================================================
  // STATISTICS
  // ===========================================================================
  group('FusionLiveChartController - Statistics', () {
    test('getStatistics returns aggregate data', () {
      final controller = FusionLiveChartController(frameCoalescing: false);

      controller.addPoint('test1', const FusionDataPoint(1, 10));
      controller.addPoint('test1', const FusionDataPoint(2, 20));
      controller.addPoint('test2', const FusionDataPoint(1, 100));

      final stats = controller.getStatistics();

      expect(stats.totalPoints, 3);
      expect(stats.seriesStats.length, 2);
      expect(stats.seriesStats['test1']?.pointCount, 2);
      expect(stats.seriesStats['test2']?.pointCount, 1);

      controller.dispose();
    });

    test('getMemoryUsage returns estimate', () {
      final controller = FusionLiveChartController(frameCoalescing: false);

      controller.addPoint('test', const FusionDataPoint(1, 10));

      final memoryUsage = controller.getMemoryUsage('test');

      expect(memoryUsage, 100); // ~100 bytes per point

      controller.dispose();
    });
  });

  // ===========================================================================
  // NOTIFIER BEHAVIOR
  // ===========================================================================
  group('FusionLiveChartController - Notifier', () {
    test('notifies listeners when data added', () async {
      final controller = FusionLiveChartController(frameCoalescing: false);
      int notifyCount = 0;

      controller.addListener(() => notifyCount++);
      controller.addPoint('test', const FusionDataPoint(1, 10));

      // Give time for the notification to be processed
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifyCount, greaterThan(0));

      controller.dispose();
    });
  });

  // ===========================================================================
  // DISPOSE
  // ===========================================================================
  group('FusionLiveChartController - Dispose', () {
    test('dispose cleans up resources', () {
      final controller = FusionLiveChartController(frameCoalescing: false);

      controller.addPoint('test', const FusionDataPoint(1, 10));
      controller.dispose();

      // Should not throw when calling methods after dispose
      expect(
        controller.addPoint('test', const FusionDataPoint(2, 20)),
        isFalse,
      );
    });

    test('dispose unbinds all streams', () async {
      final controller = FusionLiveChartController(frameCoalescing: false);
      final streamController = StreamController<int>.broadcast();

      controller.bindStream<int>(
        'test',
        streamController.stream,
        mapper: (value) => FusionDataPoint(value.toDouble(), value.toDouble()),
      );

      controller.dispose();

      // Stream should be cancelled
      expect(controller.hasStreamBinding('test'), isFalse);

      await streamController.close();
    });
  });
}

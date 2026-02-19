import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/live/frame_coalescer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // FRAME COALESCER
  // ===========================================================================
  group('FrameCoalescer', () {
    // =========================================================================
    // Construction
    // =========================================================================
    group('construction', () {
      test('creates with required onFlush callback', () {
        final coalescer = FrameCoalescer(onFlush: () {});

        expect(coalescer.enabled, isTrue);
        expect(coalescer.isDirty, isFalse);
        expect(coalescer.isScheduled, isFalse);
      });

      test('creates with enabled = false', () {
        final coalescer = FrameCoalescer(onFlush: () {}, enabled: false);

        expect(coalescer.enabled, isFalse);
      });
    });

    // =========================================================================
    // mark() method
    // =========================================================================
    group('mark()', () {
      test('sets isDirty to true when enabled', () {
        final coalescer = FrameCoalescer(onFlush: () {});

        coalescer.mark();

        expect(coalescer.isDirty, isTrue);
        expect(coalescer.isScheduled, isTrue);

        coalescer.dispose();
      });

      test('calls onFlush immediately when disabled', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(
          onFlush: () => callCount++,
          enabled: false,
        );

        coalescer.mark();

        expect(callCount, 1);
        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });

      test('multiple marks within same frame coalesce', () {
        final coalescer = FrameCoalescer(onFlush: () {});

        coalescer.mark();
        coalescer.mark();
        coalescer.mark();

        expect(coalescer.isDirty, isTrue);
        expect(coalescer.isScheduled, isTrue);

        coalescer.dispose();
      });

      test('does nothing when disposed', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.dispose();
        coalescer.mark();

        expect(callCount, 0);
        expect(coalescer.isDirty, isFalse);
      });
    });

    // =========================================================================
    // flush() method
    // =========================================================================
    group('flush()', () {
      test('calls onFlush when dirty', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.mark();
        coalescer.flush();

        expect(callCount, 1);
        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });

      test('does not call onFlush when not dirty', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.flush();

        expect(callCount, 0);

        coalescer.dispose();
      });

      test('does nothing when disposed', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.mark();
        coalescer.dispose();
        coalescer.flush();

        expect(callCount, 0);
      });
    });

    // =========================================================================
    // cancel() method
    // =========================================================================
    group('cancel()', () {
      test('clears dirty state', () {
        final coalescer = FrameCoalescer(onFlush: () {});

        coalescer.mark();
        expect(coalescer.isDirty, isTrue);

        coalescer.cancel();
        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });

      test('prevents onFlush on frame callback', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.mark();
        coalescer.cancel();
        coalescer.flush();

        expect(callCount, 0);

        coalescer.dispose();
      });
    });

    // =========================================================================
    // dispose() method
    // =========================================================================
    group('dispose()', () {
      test('clears dirty state', () {
        final coalescer = FrameCoalescer(onFlush: () {});

        coalescer.mark();
        expect(coalescer.isDirty, isTrue);

        coalescer.dispose();
        expect(coalescer.isDirty, isFalse);
      });

      test('prevents future marks from having effect', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(
          onFlush: () => callCount++,
          enabled: false,
        );

        coalescer.dispose();
        coalescer.mark();

        expect(callCount, 0);
      });
    });

    // =========================================================================
    // enabled property
    // =========================================================================
    group('enabled property', () {
      test('can be toggled', () {
        final coalescer = FrameCoalescer(onFlush: () {});

        expect(coalescer.enabled, isTrue);

        coalescer.enabled = false;
        expect(coalescer.enabled, isFalse);

        coalescer.enabled = true;
        expect(coalescer.enabled, isTrue);

        coalescer.dispose();
      });

      test('immediate call when changed to disabled', () {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.enabled = false;
        coalescer.mark();

        expect(callCount, 1);

        coalescer.dispose();
      });
    });

    // =========================================================================
    // Frame callback integration
    // =========================================================================
    group('frame callback integration', () {
      testWidgets('calls onFlush at frame boundary', (tester) async {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.mark();
        expect(callCount, 0);

        await tester.pump();

        expect(callCount, 1);
        expect(coalescer.isDirty, isFalse);
        expect(coalescer.isScheduled, isFalse);

        coalescer.dispose();
      });

      testWidgets('coalesces multiple marks into single callback', (
        tester,
      ) async {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.mark();
        coalescer.mark();
        coalescer.mark();

        await tester.pump();

        expect(callCount, 1);

        coalescer.dispose();
      });

      testWidgets('allows multiple flushes across frames', (tester) async {
        var callCount = 0;
        final coalescer = FrameCoalescer(onFlush: () => callCount++);

        coalescer.mark();
        await tester.pump();
        expect(callCount, 1);

        coalescer.mark();
        await tester.pump();
        expect(callCount, 2);

        coalescer.dispose();
      });
    });
  });

  // ===========================================================================
  // SERIES FRAME COALESCER
  // ===========================================================================
  group('SeriesFrameCoalescer', () {
    // =========================================================================
    // Construction
    // =========================================================================
    group('construction', () {
      test('creates with required onFlush callback', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        expect(coalescer.enabled, isTrue);
        expect(coalescer.isDirty, isFalse);
        expect(coalescer.isScheduled, isFalse);
        expect(coalescer.dirtySeries, isEmpty);
      });

      test('creates with enabled = false', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {}, enabled: false);

        expect(coalescer.enabled, isFalse);
      });
    });

    // =========================================================================
    // markSeries() method
    // =========================================================================
    group('markSeries()', () {
      test('adds series to dirty set when enabled', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');

        expect(coalescer.isDirty, isTrue);
        expect(coalescer.isScheduled, isTrue);
        expect(coalescer.dirtySeries, contains('series1'));

        coalescer.dispose();
      });

      test('calls onFlush immediately when disabled', () {
        Set<String>? receivedSeries;
        final coalescer = SeriesFrameCoalescer(
          onFlush: (series) => receivedSeries = series,
          enabled: false,
        );

        coalescer.markSeries('series1');

        expect(receivedSeries, {'series1'});
        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });

      test('accumulates multiple series', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');
        coalescer.markSeries('series2');
        coalescer.markSeries('series3');

        expect(coalescer.dirtySeries, {'series1', 'series2', 'series3'});

        coalescer.dispose();
      });

      test('deduplicates same series marked multiple times', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');
        coalescer.markSeries('series1');
        coalescer.markSeries('series1');

        expect(coalescer.dirtySeries.length, 1);
        expect(coalescer.dirtySeries, contains('series1'));

        coalescer.dispose();
      });

      test('does nothing when disposed', () {
        var callCount = 0;
        final coalescer = SeriesFrameCoalescer(onFlush: (_) => callCount++);

        coalescer.dispose();
        coalescer.markSeries('series1');

        expect(callCount, 0);
        expect(coalescer.isDirty, isFalse);
      });
    });

    // =========================================================================
    // markAllSeries() method
    // =========================================================================
    group('markAllSeries()', () {
      test('adds all series to dirty set when enabled', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markAllSeries(['series1', 'series2', 'series3']);

        expect(coalescer.isDirty, isTrue);
        expect(coalescer.dirtySeries, {'series1', 'series2', 'series3'});

        coalescer.dispose();
      });

      test('calls onFlush immediately when disabled', () {
        Set<String>? receivedSeries;
        final coalescer = SeriesFrameCoalescer(
          onFlush: (series) => receivedSeries = series,
          enabled: false,
        );

        coalescer.markAllSeries(['series1', 'series2']);

        expect(receivedSeries, {'series1', 'series2'});

        coalescer.dispose();
      });

      test('merges with existing dirty series', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');
        coalescer.markAllSeries(['series2', 'series3']);

        expect(coalescer.dirtySeries, {'series1', 'series2', 'series3'});

        coalescer.dispose();
      });

      test('does nothing when disposed', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.dispose();
        coalescer.markAllSeries(['series1', 'series2']);

        expect(coalescer.isDirty, isFalse);
      });

      test('handles empty iterable', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markAllSeries([]);

        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });
    });

    // =========================================================================
    // flush() method
    // =========================================================================
    group('flush()', () {
      test('calls onFlush with dirty series when dirty', () {
        Set<String>? receivedSeries;
        final coalescer = SeriesFrameCoalescer(
          onFlush: (series) => receivedSeries = series,
        );

        coalescer.markSeries('series1');
        coalescer.markSeries('series2');
        coalescer.flush();

        expect(receivedSeries, {'series1', 'series2'});
        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });

      test('does not call onFlush when not dirty', () {
        var callCount = 0;
        final coalescer = SeriesFrameCoalescer(onFlush: (_) => callCount++);

        coalescer.flush();

        expect(callCount, 0);

        coalescer.dispose();
      });

      test('clears dirty series after flush', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');
        coalescer.flush();

        expect(coalescer.dirtySeries, isEmpty);

        coalescer.dispose();
      });

      test('does nothing when disposed', () {
        var callCount = 0;
        final coalescer = SeriesFrameCoalescer(onFlush: (_) => callCount++);

        coalescer.markSeries('series1');
        coalescer.dispose();
        coalescer.flush();

        expect(callCount, 0);
      });
    });

    // =========================================================================
    // cancel() method
    // =========================================================================
    group('cancel()', () {
      test('clears dirty series', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');
        coalescer.markSeries('series2');
        expect(coalescer.dirtySeries, isNotEmpty);

        coalescer.cancel();
        expect(coalescer.dirtySeries, isEmpty);
        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });
    });

    // =========================================================================
    // dispose() method
    // =========================================================================
    group('dispose()', () {
      test('clears dirty series', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');
        coalescer.markSeries('series2');
        expect(coalescer.dirtySeries, isNotEmpty);

        coalescer.dispose();
        expect(coalescer.dirtySeries, isEmpty);
      });
    });

    // =========================================================================
    // dirtySeries getter
    // =========================================================================
    group('dirtySeries getter', () {
      test('returns unmodifiable view', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        coalescer.markSeries('series1');

        expect(
          () => coalescer.dirtySeries.add('series2'),
          throwsA(isA<UnsupportedError>()),
        );

        coalescer.dispose();
      });

      test('reflects current dirty state', () {
        final coalescer = SeriesFrameCoalescer(onFlush: (_) {});

        expect(coalescer.dirtySeries, isEmpty);

        coalescer.markSeries('series1');
        expect(coalescer.dirtySeries, {'series1'});

        coalescer.markSeries('series2');
        expect(coalescer.dirtySeries, {'series1', 'series2'});

        coalescer.dispose();
      });
    });

    // =========================================================================
    // Frame callback integration
    // =========================================================================
    group('frame callback integration', () {
      testWidgets('calls onFlush at frame boundary with dirty series', (
        tester,
      ) async {
        Set<String>? receivedSeries;
        final coalescer = SeriesFrameCoalescer(
          onFlush: (series) => receivedSeries = series,
        );

        coalescer.markSeries('series1');
        coalescer.markSeries('series2');

        expect(receivedSeries, isNull);

        await tester.pump();

        expect(receivedSeries, {'series1', 'series2'});
        expect(coalescer.isDirty, isFalse);

        coalescer.dispose();
      });

      testWidgets('coalesces multiple marks into single callback', (
        tester,
      ) async {
        var callCount = 0;
        final coalescer = SeriesFrameCoalescer(onFlush: (_) => callCount++);

        coalescer.markSeries('series1');
        coalescer.markSeries('series2');
        coalescer.markSeries('series1');

        await tester.pump();

        expect(callCount, 1);

        coalescer.dispose();
      });

      testWidgets('allows multiple flushes across frames', (tester) async {
        final receivedSeries = <Set<String>>[];
        final coalescer = SeriesFrameCoalescer(
          onFlush: (series) => receivedSeries.add(Set.from(series)),
        );

        coalescer.markSeries('series1');
        await tester.pump();

        coalescer.markSeries('series2');
        await tester.pump();

        expect(receivedSeries.length, 2);
        expect(receivedSeries[0], {'series1'});
        expect(receivedSeries[1], {'series2'});

        coalescer.dispose();
      });
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Coalesces multiple data updates into a single frame callback.
///
/// Prevents excessive repaints when data arrives faster than frame rate.
/// Multiple calls to [mark] within the same frame result in a single [onFlush] call.
///
/// Example:
/// ```dart
/// final coalescer = FrameCoalescer(
///   onFlush: () => setState(() {}),
/// );
///
/// // These all happen within one frame
/// coalescer.mark(); // Data point 1
/// coalescer.mark(); // Data point 2
/// coalescer.mark(); // Data point 3
///
/// // onFlush called only once at frame boundary
/// ```
class FrameCoalescer {
  /// Creates a frame coalescer.
  ///
  /// [onFlush] is called when accumulated updates should be processed.
  /// [enabled] controls whether coalescing is active (default: true).
  FrameCoalescer({required this.onFlush, this.enabled = true});

  /// Called when accumulated updates should be flushed.
  final VoidCallback onFlush;

  /// Whether coalescing is enabled.
  ///
  /// When disabled, [onFlush] is called immediately on each [mark].
  bool enabled;

  bool _isDirty = false;
  bool _isScheduled = false;
  bool _isDisposed = false;

  /// Whether there are pending updates.
  bool get isDirty => _isDirty;

  /// Whether a frame callback is scheduled.
  bool get isScheduled => _isScheduled;

  /// Mark that an update is pending.
  ///
  /// If coalescing is enabled, the update is batched until the next frame.
  /// If disabled, [onFlush] is called immediately.
  void mark() {
    if (_isDisposed) {
      assert(() {
        debugPrint('Warning: FrameCoalescer.mark() called after dispose');
        return true;
      }());
      return;
    }

    if (!enabled) {
      onFlush();
      return;
    }

    _isDirty = true;

    if (!_isScheduled) {
      _isScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
    }
  }

  void _onFrame(Duration timestamp) {
    _isScheduled = false;

    if (_isDisposed) return;

    if (_isDirty) {
      _isDirty = false;
      onFlush();
    }
  }

  /// Flush any pending updates immediately.
  ///
  /// Useful when you need to force an update before the next frame.
  void flush() {
    if (_isDisposed) return;

    if (_isDirty) {
      _isDirty = false;
      onFlush();
    }
  }

  /// Cancel any pending frame callback.
  ///
  /// Does not call [onFlush].
  void cancel() {
    _isDirty = false;
    // Note: Can't cancel scheduleFrameCallback, but _isDirty = false
    // ensures onFlush won't be called
  }

  /// Dispose the coalescer.
  ///
  /// Cancels any pending updates. The coalescer should not be used after this.
  void dispose() {
    _isDisposed = true;
    _isDirty = false;
  }
}

/// A frame coalescer that tracks which series have been updated.
///
/// Useful when you need to know specifically what changed, not just that
/// something changed.
class SeriesFrameCoalescer {
  /// Creates a series-aware frame coalescer.
  SeriesFrameCoalescer({required this.onFlush, this.enabled = true});

  /// Called when accumulated updates should be flushed.
  ///
  /// [dirtySeries] contains the names of all series that were updated
  /// since the last flush.
  final void Function(Set<String> dirtySeries) onFlush;

  /// Whether coalescing is enabled.
  bool enabled;

  final Set<String> _dirtySeries = {};
  bool _isScheduled = false;
  bool _isDisposed = false;

  /// Whether there are pending updates.
  bool get isDirty => _dirtySeries.isNotEmpty;

  /// Whether a frame callback is scheduled.
  bool get isScheduled => _isScheduled;

  /// Get the set of series marked dirty (read-only view).
  Set<String> get dirtySeries => Set.unmodifiable(_dirtySeries);

  /// Mark a series as updated.
  ///
  /// [seriesName] is the name of the series that was updated.
  void markSeries(String seriesName) {
    if (_isDisposed) {
      assert(() {
        debugPrint(
          'Warning: SeriesFrameCoalescer.markSeries() called after dispose',
        );
        return true;
      }());
      return;
    }

    if (!enabled) {
      onFlush({seriesName});
      return;
    }

    _dirtySeries.add(seriesName);

    if (!_isScheduled) {
      _isScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
    }
  }

  /// Mark multiple series as updated.
  void markAllSeries(Iterable<String> seriesNames) {
    if (_isDisposed) return;

    if (!enabled) {
      onFlush(seriesNames.toSet());
      return;
    }

    _dirtySeries.addAll(seriesNames);

    if (!_isScheduled) {
      _isScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
    }
  }

  void _onFrame(Duration timestamp) {
    _isScheduled = false;

    if (_isDisposed) return;

    if (_dirtySeries.isNotEmpty) {
      final series = Set<String>.from(_dirtySeries);
      _dirtySeries.clear();
      onFlush(series);
    }
  }

  /// Flush any pending updates immediately.
  void flush() {
    if (_isDisposed) return;

    if (_dirtySeries.isNotEmpty) {
      final series = Set<String>.from(_dirtySeries);
      _dirtySeries.clear();
      onFlush(series);
    }
  }

  /// Cancel any pending frame callback.
  void cancel() {
    _dirtySeries.clear();
  }

  /// Dispose the coalescer.
  void dispose() {
    _isDisposed = true;
    _dirtySeries.clear();
  }
}

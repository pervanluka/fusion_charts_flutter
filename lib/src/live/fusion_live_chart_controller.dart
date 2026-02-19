import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/fusion_data_point.dart';
import '../utils/lttb_downsampler.dart';
import 'duplicate_timestamp_behavior.dart';
import 'frame_coalescer.dart';
import 'live_controller_statistics.dart';
import 'out_of_order_behavior.dart';
import 'retention_policy.dart';
import 'ring_buffer.dart';

/// Controller for managing real-time chart data.
///
/// Create one controller per chart. The controller manages data buffering,
/// retention policies, and notifies the chart when to repaint.
///
/// ## Basic Usage
///
/// ```dart
/// final controller = FusionLiveChartController(
///   retentionPolicy: RetentionPolicy.rollingCount(500),
/// );
///
/// // Add data from any source
/// websocket.onMessage((data) {
///   controller.addPoint('price', FusionDataPoint(now, data.price));
/// });
///
/// // Use in widget
/// FusionLineChart(
///   liveController: controller,
///   series: [FusionLineSeries(name: 'price')],
/// )
/// ```
///
/// ## Stream Binding
///
/// ```dart
/// controller.bindStream(
///   'heartRate',
///   bleDevice.heartRateStream,
///   mapper: (hr) => FusionDataPoint(DateTime.now().millisecondsSinceEpoch, hr.bpm),
/// );
/// ```
class FusionLiveChartController extends ChangeNotifier {
  /// Creates a live chart controller.
  ///
  /// [retentionPolicy] controls how much data is kept in memory.
  /// [frameCoalescing] batches rapid updates to max 60fps (recommended).
  /// [outOfOrderBehavior] handles data points arriving out of order.
  /// [duplicateTimestampBehavior] handles points with the same x-value.
  FusionLiveChartController({
    RetentionPolicy retentionPolicy = const RetentionPolicy.unlimited(),
    this.frameCoalescing = true,
    this.outOfOrderBehavior = OutOfOrderBehavior.acceptWithWarning,
    this.duplicateTimestampBehavior = DuplicateTimestampBehavior.replace,
  }) : _retentionPolicy = retentionPolicy {
    _frameCoalescer = FrameCoalescer(
      onFlush: _onFrameFlush,
      enabled: frameCoalescing,
    );
  }

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Policy for managing data retention and memory.
  ///
  /// Can be changed at runtime (triggers immediate policy application).
  RetentionPolicy get retentionPolicy => _retentionPolicy;
  RetentionPolicy _retentionPolicy;

  set retentionPolicy(RetentionPolicy value) {
    if (_retentionPolicy == value) return;
    _retentionPolicy = value;

    // Apply new policy immediately to all series
    for (final seriesName in _seriesData.keys) {
      _applyRetentionPolicy(seriesName);
    }

    _markDirty();
  }

  /// Whether to batch multiple updates into single frame.
  ///
  /// Default: true (recommended for high-frequency data)
  final bool frameCoalescing;

  /// How to handle out-of-order data points.
  final OutOfOrderBehavior outOfOrderBehavior;

  /// How to handle duplicate timestamps.
  final DuplicateTimestampBehavior duplicateTimestampBehavior;

  // ===========================================================================
  // INTERNAL STATE
  // ===========================================================================

  /// Data storage: seriesName -> RingBuffer of points (recent/full resolution)
  final Map<String, RingBuffer<FusionDataPoint>> _seriesData = {};

  /// Archive storage for DownsampledPolicy: seriesName -> downsampled older data
  final Map<String, List<FusionDataPoint>> _archiveData = {};

  /// LTTB downsampler instance
  static const _downsampler = LTTBDownsampler();

  /// Stream subscriptions: seriesName -> subscription
  final Map<String, StreamSubscription<dynamic>> _streamBindings = {};

  /// Ingest rate trackers: seriesName -> tracker
  final Map<String, IngestRateTracker> _ingestTrackers = {};

  /// Frame coalescer for batching updates
  late final FrameCoalescer _frameCoalescer;

  /// Pause state
  bool _isPaused = false;

  /// Whether disposed
  bool _isDisposed = false;

  // ===========================================================================
  // DATA INGESTION
  // ===========================================================================

  /// Add a single data point to a series.
  ///
  /// [seriesName] must match the `name` property of a series in the chart.
  /// If [isPaused] is true, data is still buffered but chart doesn't scroll.
  ///
  /// Returns true if point was accepted, false if rejected
  /// (out-of-order with reject policy, or invalid data).
  bool addPoint(String seriesName, FusionDataPoint point) {
    if (_isDisposed) {
      assert(() {
        debugPrint(
          'Warning: addPoint called on disposed FusionLiveChartController',
        );
        return true;
      }());
      return false;
    }

    if (seriesName.isEmpty) {
      assert(() {
        debugPrint('Warning: Empty series name provided to addPoint');
        return true;
      }());
      return false;
    }

    // Sanitize point (handle NaN, infinity)
    final sanitizedPoint = _sanitizePoint(point);

    // Get or create buffer for series
    final buffer = _getOrCreateBuffer(seriesName);

    // Check out-of-order
    if (!_handleOutOfOrder(sanitizedPoint, buffer)) {
      return false;
    }

    // Handle duplicate timestamps
    final duplicateResult = _handleDuplicate(sanitizedPoint, buffer);
    if (!duplicateResult.accepted) {
      return false; // Duplicate was rejected (keepFirst behavior)
    }

    // Add to buffer if needed (replace/average already modified in place)
    if (duplicateResult.shouldAdd) {
      buffer.add(duplicateResult.point!);
    }

    // Apply retention policy
    _applyRetentionPolicy(seriesName);

    // Track ingest rate
    _getOrCreateIngestTracker(seriesName).record();

    // Check for high frequency warning
    _checkIngestRate(seriesName);

    // Mark for repaint
    _markDirty();

    return true;
  }

  /// Add multiple data points to a series (batch insert).
  ///
  /// More efficient than multiple [addPoint] calls.
  /// Points should be in chronological order for best performance.
  ///
  /// Returns number of points accepted.
  int addPoints(String seriesName, List<FusionDataPoint> points) {
    if (_isDisposed || seriesName.isEmpty || points.isEmpty) return 0;

    int accepted = 0;

    for (final point in points) {
      if (addPoint(seriesName, point)) {
        accepted++;
      }
    }

    return accepted;
  }

  /// Add points to multiple series atomically.
  ///
  /// Useful when data arrives as a bundle (e.g., {temp: 25, humidity: 60}).
  /// All points are treated as arriving at the same logical time.
  void addMultiSeriesPoints(Map<String, FusionDataPoint> points) {
    if (_isDisposed || points.isEmpty) return;

    for (final entry in points.entries) {
      addPoint(entry.key, entry.value);
    }
  }

  /// Pre-populate with historical data before starting live updates.
  ///
  /// Call once before adding live points. Points are subject to retention policy.
  /// Use this to load history from API before switching to WebSocket.
  ///
  /// [points] should be sorted by x-value (oldest first).
  void setInitialData(String seriesName, List<FusionDataPoint> points) {
    if (_isDisposed || seriesName.isEmpty) return;

    // Clear existing data for this series
    _seriesData.remove(seriesName);

    // Add all points
    addPoints(seriesName, points);
  }

  // ===========================================================================
  // STREAM BINDING (Convenience Layer)
  // ===========================================================================

  /// Bind a Dart Stream to a series.
  ///
  /// The stream will be listened to and data forwarded to [addPoint].
  /// Returns the subscription for manual control if needed.
  ///
  /// Example:
  /// ```dart
  /// controller.bindStream(
  ///   'heartRate',
  ///   bleDevice.heartRateStream,
  ///   mapper: (hr) => FusionDataPoint(DateTime.now().millisecondsSinceEpoch.toDouble(), hr.bpm.toDouble()),
  /// );
  /// ```
  StreamSubscription<T> bindStream<T>(
    String seriesName,
    Stream<T> stream, {
    required FusionDataPoint Function(T event) mapper,
    void Function(Object error, StackTrace stackTrace)? onError,
    VoidCallback? onDone,
    bool cancelOnError = false,
  }) {
    if (_isDisposed) {
      throw StateError('Cannot bind stream to disposed controller');
    }

    // Warn if rebinding
    if (_streamBindings.containsKey(seriesName)) {
      assert(() {
        debugPrint(
          'Warning: Rebinding stream for series "$seriesName". '
          'Previous stream will be cancelled.',
        );
        return true;
      }());
      unbindStream(seriesName);
    }

    final subscription = stream.listen(
      (event) {
        final point = mapper(event);
        addPoint(seriesName, point);
      },
      onError: onError,
      onDone: () {
        _streamBindings.remove(seriesName);
        onDone?.call();
      },
      cancelOnError: cancelOnError,
    );

    _streamBindings[seriesName] = subscription;
    return subscription;
  }

  /// Unbind and cancel a previously bound stream.
  ///
  /// Does nothing if no stream is bound to [seriesName].
  void unbindStream(String seriesName) {
    final subscription = _streamBindings.remove(seriesName);
    subscription?.cancel();
  }

  /// Unbind all streams.
  void unbindAllStreams() {
    for (final subscription in _streamBindings.values) {
      subscription.cancel();
    }
    _streamBindings.clear();
  }

  /// Check if a stream is bound to [seriesName].
  bool hasStreamBinding(String seriesName) =>
      _streamBindings.containsKey(seriesName);

  // ===========================================================================
  // PLAYBACK CONTROL
  // ===========================================================================

  /// Pause live updates.
  ///
  /// When paused:
  /// - Data continues to be buffered (not lost)
  /// - Chart viewport stops auto-scrolling
  /// - User can pan/zoom to inspect historical data
  /// - Retention policy continues to apply (old data may be evicted)
  ///
  /// Call [resume] to continue live updates.
  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    onPauseChanged?.call(true);
    notifyListeners();
  }

  /// Resume live updates after [pause].
  ///
  /// [animationDuration] controls the transition animation back to live position.
  /// Default is 300ms. Pass Duration.zero for instant jump.
  void resume({
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    if (!_isPaused) return;
    _isPaused = false;
    _resumeAnimationDuration = animationDuration;
    onPauseChanged?.call(false);
    notifyListeners();
  }

  /// The animation duration for the current resume transition.
  Duration _resumeAnimationDuration = const Duration(milliseconds: 300);

  /// Get the animation duration for resuming (used by chart widget).
  Duration get resumeAnimationDuration => _resumeAnimationDuration;

  /// Whether live updates are currently paused.
  bool get isPaused => _isPaused;

  /// Callback fired when pause state changes.
  ValueChanged<bool>? onPauseChanged;

  /// Callback fired when data is evicted while user is viewing it (during pause).
  void Function(String seriesName, int evictedCount)? onViewedDataEvicted;

  // ===========================================================================
  // DATA ACCESS
  // ===========================================================================

  /// Get all buffered points for a series.
  ///
  /// For DownsampledPolicy, returns combined archive + recent data.
  /// Returns unmodifiable list view (no copy for performance) when possible.
  List<FusionDataPoint> getPoints(String seriesName) {
    final buffer = _seriesData[seriesName];
    final archive = _archiveData[seriesName];

    // If using DownsampledPolicy and we have archive data, combine them
    if (_retentionPolicy is DownsampledPolicy &&
        archive != null &&
        archive.isNotEmpty) {
      final recent = buffer?.asUnmodifiableView() ?? const <FusionDataPoint>[];
      // Archive is already sorted (older data), recent is sorted (newer data)
      return [...archive, ...recent];
    }

    return buffer?.asUnmodifiableView() ?? const [];
  }

  /// Get the latest point for a series, or null if empty.
  FusionDataPoint? getLatestPoint(String seriesName) {
    final buffer = _seriesData[seriesName];
    return buffer?.lastOrNull;
  }

  /// Get the oldest point for a series, or null if empty.
  FusionDataPoint? getOldestPoint(String seriesName) {
    // For DownsampledPolicy, oldest point is in archive
    if (_retentionPolicy is DownsampledPolicy) {
      final archive = _archiveData[seriesName];
      if (archive != null && archive.isNotEmpty) {
        return archive.first;
      }
    }
    final buffer = _seriesData[seriesName];
    return buffer?.firstOrNull;
  }

  /// Get point count for a series.
  ///
  /// For DownsampledPolicy, includes both archive and recent points.
  int getPointCount(String seriesName) {
    final recentCount = _seriesData[seriesName]?.length ?? 0;
    final archiveCount = _archiveData[seriesName]?.length ?? 0;
    return recentCount + archiveCount;
  }

  /// Get all series names that have data.
  Set<String> get seriesNames => Set.unmodifiable(_seriesData.keys.toSet());

  /// Get the data range for a series.
  ///
  /// Returns (minX, maxX) or null if series is empty.
  /// For DownsampledPolicy, includes both archive and recent data range.
  (double, double)? getDataRange(String seriesName) {
    final buffer = _seriesData[seriesName];
    final archive = _archiveData[seriesName];

    double? minX;
    double? maxX;

    // Check archive for min
    if (archive != null && archive.isNotEmpty) {
      minX = archive.first.x;
    }

    // Check recent buffer
    if (buffer != null && buffer.isNotEmpty) {
      minX ??= buffer.first.x;
      maxX = buffer.last.x;
    } else if (archive != null && archive.isNotEmpty) {
      maxX = archive.last.x;
    }

    if (minX == null || maxX == null) return null;
    return (minX, maxX);
  }

  /// Clear data for a specific series, or all series if null.
  ///
  /// Does not unbind streams.
  void clear([String? seriesName]) {
    if (seriesName != null) {
      _seriesData[seriesName]?.clear();
      _archiveData.remove(seriesName);
    } else {
      for (final buffer in _seriesData.values) {
        buffer.clear();
      }
      _archiveData.clear();
    }
    _markDirty();
  }

  // ===========================================================================
  // STATISTICS (For debugging/display)
  // ===========================================================================

  /// Data ingestion rate (points per second) over last [window].
  double getIngestRate(
    String seriesName, {
    Duration window = const Duration(seconds: 5),
  }) {
    return _ingestTrackers[seriesName]?.rate ?? 0;
  }

  /// Total points received since creation (including evicted).
  int getTotalPointsReceived(String seriesName) {
    return _seriesData[seriesName]?.totalAdded ?? 0;
  }

  /// Points evicted due to retention policy since creation.
  int getPointsEvicted(String seriesName) {
    return _seriesData[seriesName]?.totalEvicted ?? 0;
  }

  /// Current memory usage estimate in bytes for a series.
  ///
  /// Rough estimate: ~100 bytes per FusionDataPoint
  /// (includes object overhead, x, y, label, metadata).
  int getMemoryUsage(String seriesName) {
    return getPointCount(seriesName) * 100; // Rough estimate
  }

  /// Get statistics for all series.
  LiveControllerStatistics getStatistics() {
    final seriesStats = <String, SeriesStatistics>{};
    int totalPoints = 0;
    int totalMemory = 0;
    double totalRate = 0;

    for (final seriesName in _seriesData.keys) {
      final pointCount = getPointCount(seriesName);
      final memoryBytes = getMemoryUsage(seriesName);
      final rate = getIngestRate(seriesName);

      seriesStats[seriesName] = SeriesStatistics(
        name: seriesName,
        pointCount: pointCount,
        totalReceived: getTotalPointsReceived(seriesName),
        totalEvicted: getPointsEvicted(seriesName),
        ingestRate: rate,
        memoryBytes: memoryBytes,
        dataRange: getDataRange(seriesName),
      );

      totalPoints += pointCount;
      totalMemory += memoryBytes;
      totalRate += rate;
    }

    return LiveControllerStatistics(
      seriesStats: seriesStats,
      totalPoints: totalPoints,
      totalMemoryBytes: totalMemory,
      aggregateIngestRate: totalRate,
    );
  }

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void dispose() {
    _isDisposed = true;
    unbindAllStreams();
    _frameCoalescer.dispose();
    _seriesData.clear();
    _ingestTrackers.clear();
    super.dispose();
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  RingBuffer<FusionDataPoint> _getOrCreateBuffer(String seriesName) {
    return _seriesData.putIfAbsent(
      seriesName,
      () => RingBuffer<FusionDataPoint>(_getBufferCapacity()),
    );
  }

  IngestRateTracker _getOrCreateIngestTracker(String seriesName) {
    return _ingestTrackers.putIfAbsent(seriesName, IngestRateTracker.new);
  }

  int _getBufferCapacity() {
    // Determine buffer capacity based on retention policy
    switch (_retentionPolicy) {
      case RollingCountPolicy(maxPoints: final max):
        return max;
      case RollingDurationPolicy():
        // For duration-based, use a reasonable default that can grow
        return 10000;
      case UnlimitedPolicy():
        return 100000; // Practical limit
      case CombinedPolicy(maxPoints: final max):
        return max;
      case DownsampledPolicy(recentMaxPoints: final max):
        // Use a larger capacity to prevent auto-eviction before archiving.
        // The _applyDownsampledPolicy method handles the actual eviction/archiving.
        return (max ?? 10000) * 2;
    }
  }

  FusionDataPoint _sanitizePoint(FusionDataPoint point) {
    // Handle NaN and infinity
    if (point.y.isNaN) {
      assert(() {
        debugPrint('Warning: NaN y-value at x=${point.x}. Treating as gap.');
        return true;
      }());
      // For NaN, we keep the point but mark it somehow
      // Since y is non-nullable double, we'll use a special value or skip
      // Actually, looking at FusionDataPoint, y is a double, not double?
      // So we can't set it to null. Let's use double.nan which will be
      // handled by the renderer as a gap.
      return point;
    }

    if (point.y.isInfinite) {
      assert(() {
        debugPrint(
          'Warning: Infinite y-value at x=${point.x}. '
          'Using 0.0 instead.',
        );
        return true;
      }());
      return point.copyWith(y: 0.0);
    }

    return point;
  }

  bool _handleOutOfOrder(
    FusionDataPoint point,
    RingBuffer<FusionDataPoint> buffer,
  ) {
    if (buffer.isEmpty) return true;

    final lastX = buffer.last.x;
    if (point.x >= lastX) return true; // In order, OK

    switch (outOfOrderBehavior) {
      case OutOfOrderBehavior.accept:
        return true;

      case OutOfOrderBehavior.acceptWithWarning:
        assert(() {
          debugPrint(
            'Warning: Out-of-order point received. '
            'New x=${point.x}, last x=$lastX. Point accepted.',
          );
          return true;
        }());
        return true;

      case OutOfOrderBehavior.reject:
        assert(() {
          debugPrint(
            'Warning: Out-of-order point rejected. '
            'New x=${point.x}, last x=$lastX.',
          );
          return true;
        }());
        return false;

      case OutOfOrderBehavior.autoSort:
        // Point will be inserted and then we sort
        return true;
    }
  }

  _DuplicateHandleResult _handleDuplicate(
    FusionDataPoint point,
    RingBuffer<FusionDataPoint> buffer,
  ) {
    if (buffer.isEmpty) {
      return _DuplicateHandleResult(
        accepted: true,
        shouldAdd: true,
        point: point,
      );
    }

    // Check last point for duplicate
    final lastPoint = buffer.last;
    if (lastPoint.x != point.x) {
      return _DuplicateHandleResult(
        accepted: true,
        shouldAdd: true,
        point: point,
      );
    }

    switch (duplicateTimestampBehavior) {
      case DuplicateTimestampBehavior.replace:
        // Replace in-place by updating the last element
        buffer.replaceLast(point);
        return _DuplicateHandleResult(accepted: true, shouldAdd: false);

      case DuplicateTimestampBehavior.keepFirst:
        return _DuplicateHandleResult(accepted: false, shouldAdd: false);

      case DuplicateTimestampBehavior.keepBoth:
        return _DuplicateHandleResult(
          accepted: true,
          shouldAdd: true,
          point: point,
        );

      case DuplicateTimestampBehavior.average:
        final avgY = (lastPoint.y + point.y) / 2;
        final averaged = point.copyWith(y: avgY);
        buffer.replaceLast(averaged);
        return _DuplicateHandleResult(accepted: true, shouldAdd: false);
    }
  }

  void _applyRetentionPolicy(String seriesName) {
    final buffer = _seriesData[seriesName];
    if (buffer == null || buffer.isEmpty) return;

    int evictedCount = 0;

    switch (_retentionPolicy) {
      case RollingCountPolicy(maxPoints: final max):
        while (buffer.length > max) {
          buffer.removeFirst();
          evictedCount++;
        }

      case RollingDurationPolicy(duration: final duration):
        final latestX = buffer.last.x;
        final cutoffX = latestX - duration.inMilliseconds;
        evictedCount = buffer.removeWhile((point) => point.x < cutoffX);

      case UnlimitedPolicy():
        // No eviction
        break;

      case CombinedPolicy(maxPoints: final max, maxDuration: final duration):
        // Apply count limit
        while (buffer.length > max) {
          buffer.removeFirst();
          evictedCount++;
        }
        // Apply duration limit
        if (buffer.isNotEmpty) {
          final latestX = buffer.last.x;
          final cutoffX = latestX - duration.inMilliseconds;
          evictedCount += buffer.removeWhile((point) => point.x < cutoffX);
        }

      case DownsampledPolicy():
        final policy = _retentionPolicy as DownsampledPolicy;
        evictedCount = _applyDownsampledPolicy(seriesName, buffer, policy);
    }

    // Notify if data was evicted while paused
    if (evictedCount > 0 && _isPaused) {
      onViewedDataEvicted?.call(seriesName, evictedCount);
    }
  }

  /// Applies the DownsampledPolicy to a series buffer.
  ///
  /// Moves data older than [policy.recentDuration] to the archive buffer,
  /// downsampling it according to [policy.downsampleMethod].
  ///
  /// Returns the number of points evicted (removed entirely, not archived).
  int _applyDownsampledPolicy(
    String seriesName,
    RingBuffer<FusionDataPoint> buffer,
    DownsampledPolicy policy,
  ) {
    if (buffer.isEmpty) return 0;

    int evictedCount = 0;
    final latestX = buffer.last.x;
    final cutoffX = latestX - policy.recentDuration.inMilliseconds;

    // Collect points that are too old for the recent buffer
    final pointsToArchive = <FusionDataPoint>[];
    while (buffer.isNotEmpty && buffer.first.x < cutoffX) {
      pointsToArchive.add(buffer.removeFirst()!);
    }

    // Also apply count limit to recent buffer if specified
    if (policy.recentMaxPoints != null) {
      while (buffer.length > policy.recentMaxPoints!) {
        pointsToArchive.add(buffer.removeFirst()!);
      }
    }

    // If we have points to archive, process them
    if (pointsToArchive.isNotEmpty) {
      // Get or create archive for this series
      final archive = _archiveData.putIfAbsent(seriesName, () => []);

      // Downsample the points to archive
      final downsampled = _downsamplePoints(
        pointsToArchive,
        policy.archiveResolution,
        policy.downsampleMethod,
      );

      // Merge downsampled points into archive (maintaining sort order)
      if (archive.isEmpty) {
        archive.addAll(downsampled);
      } else {
        // Insert at the end since new archive points are more recent than existing
        archive.addAll(downsampled);
      }

      // Apply archive limit if specified
      if (policy.maxArchivePoints != null) {
        while (archive.length > policy.maxArchivePoints!) {
          archive.removeAt(0); // Remove oldest
          evictedCount++;
        }
      }
    }

    return evictedCount;
  }

  /// Downsamples a list of points according to the specified method and resolution.
  List<FusionDataPoint> _downsamplePoints(
    List<FusionDataPoint> points,
    Duration archiveResolution,
    DownsampleMethod method,
  ) {
    if (points.isEmpty) return [];
    if (points.length <= 2) return points;

    // Calculate target points based on time range and resolution
    final timeRange = points.last.x - points.first.x;
    final targetPoints = (timeRange / archiveResolution.inMilliseconds)
        .ceil()
        .clamp(2, points.length);

    // If we don't need to downsample much, return as-is
    if (targetPoints >= points.length) return points;

    switch (method) {
      case DownsampleMethod.lttb:
        return _downsampler.downsample(
          data: points,
          targetPoints: targetPoints,
        );

      case DownsampleMethod.first:
        return _downsampleByBucket(
          points,
          targetPoints,
          (bucket) => bucket.first,
        );

      case DownsampleMethod.last:
        return _downsampleByBucket(
          points,
          targetPoints,
          (bucket) => bucket.last,
        );

      case DownsampleMethod.average:
        return _downsampleByBucket(points, targetPoints, _bucketAverage);

      case DownsampleMethod.minMax:
        return _downsampleMinMax(points, targetPoints);
    }
  }

  /// Downsamples by dividing into buckets and selecting one point per bucket.
  List<FusionDataPoint> _downsampleByBucket(
    List<FusionDataPoint> points,
    int targetPoints,
    FusionDataPoint Function(List<FusionDataPoint> bucket) selector,
  ) {
    if (points.length <= targetPoints) return points;

    final result = <FusionDataPoint>[];
    final bucketSize = points.length / targetPoints;

    for (int i = 0; i < targetPoints; i++) {
      final start = (i * bucketSize).floor();
      final end = ((i + 1) * bucketSize).floor().clamp(
        start + 1,
        points.length,
      );
      final bucket = points.sublist(start, end);
      if (bucket.isNotEmpty) {
        result.add(selector(bucket));
      }
    }

    return result;
  }

  /// Returns the average point of a bucket.
  FusionDataPoint _bucketAverage(List<FusionDataPoint> bucket) {
    if (bucket.isEmpty) return bucket.first;
    if (bucket.length == 1) return bucket.first;

    double sumX = 0;
    double sumY = 0;
    for (final point in bucket) {
      sumX += point.x;
      sumY += point.y;
    }
    return FusionDataPoint(sumX / bucket.length, sumY / bucket.length);
  }

  /// Downsamples keeping min and max points in each bucket.
  List<FusionDataPoint> _downsampleMinMax(
    List<FusionDataPoint> points,
    int targetPoints,
  ) {
    if (points.length <= targetPoints) return points;

    // For min/max, we need pairs, so halve the target
    final bucketCount = targetPoints ~/ 2;
    if (bucketCount <= 0) return [points.first, points.last];

    final result = <FusionDataPoint>[];
    final bucketSize = points.length / bucketCount;

    for (int i = 0; i < bucketCount; i++) {
      final start = (i * bucketSize).floor();
      final end = ((i + 1) * bucketSize).floor().clamp(
        start + 1,
        points.length,
      );
      final bucket = points.sublist(start, end);

      if (bucket.isNotEmpty) {
        FusionDataPoint minPoint = bucket.first;
        FusionDataPoint maxPoint = bucket.first;

        for (final point in bucket) {
          if (point.y < minPoint.y) minPoint = point;
          if (point.y > maxPoint.y) maxPoint = point;
        }

        // Add in chronological order
        if (minPoint.x <= maxPoint.x) {
          result.add(minPoint);
          if (minPoint != maxPoint) result.add(maxPoint);
        } else {
          result.add(maxPoint);
          if (minPoint != maxPoint) result.add(minPoint);
        }
      }
    }

    return result;
  }

  void _checkIngestRate(String seriesName) {
    final rate = getIngestRate(seriesName);

    if (rate > 500) {
      // 500 Hz threshold
      assert(() {
        debugPrint(
          'Warning: Very high ingest rate (${rate.toStringAsFixed(0)} Hz) '
          'for series "$seriesName". '
          'Consider using addPoints() for batch inserts.',
        );
        return true;
      }());
    }
  }

  void _markDirty() {
    if (_isDisposed) return;
    _frameCoalescer.mark();
  }

  void _onFrameFlush() {
    if (_isDisposed) return;
    notifyListeners();
  }
}

/// Result of duplicate timestamp handling.
class _DuplicateHandleResult {
  const _DuplicateHandleResult({
    required this.accepted,
    required this.shouldAdd,
    this.point,
  });

  /// Whether the point was accepted (update succeeded).
  final bool accepted;

  /// Whether the point should be added to the buffer.
  /// False when it was handled in-place (replace, average).
  final bool shouldAdd;

  /// The point to add, if [shouldAdd] is true.
  final FusionDataPoint? point;
}

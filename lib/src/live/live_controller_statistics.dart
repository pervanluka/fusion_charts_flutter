/// Statistics snapshot for a live chart controller.
///
/// Provides diagnostic information about data ingestion, memory usage,
/// and performance for debugging and monitoring purposes.
///
/// Example:
/// ```dart
/// final stats = controller.getStatistics();
/// print('Total points: ${stats.totalPoints}');
/// print('Memory: ${stats.totalMemoryBytes} bytes');
/// print('Ingest rate: ${stats.aggregateIngestRate} Hz');
/// ```
class LiveControllerStatistics {
  /// Creates a statistics snapshot.
  const LiveControllerStatistics({
    required this.seriesStats,
    required this.totalPoints,
    required this.totalMemoryBytes,
    required this.aggregateIngestRate,
  });

  /// Statistics for each series, keyed by series name.
  final Map<String, SeriesStatistics> seriesStats;

  /// Total number of points across all series.
  final int totalPoints;

  /// Estimated total memory usage in bytes.
  final int totalMemoryBytes;

  /// Combined data ingestion rate across all series (points per second).
  final double aggregateIngestRate;

  /// Whether any series has degraded performance (>16.67ms frame time).
  bool get hasPerformanceIssues =>
      seriesStats.values.any((s) => s.isHighFrequency);

  @override
  String toString() =>
      'LiveControllerStatistics('
      'series: ${seriesStats.length}, '
      'totalPoints: $totalPoints, '
      'memory: ${(totalMemoryBytes / 1024).toStringAsFixed(1)} KB, '
      'rate: ${aggregateIngestRate.toStringAsFixed(1)} Hz)';
}

/// Statistics for a single series.
///
/// Provides detailed information about a specific data series
/// for debugging and performance monitoring.
class SeriesStatistics {
  /// Creates statistics for a series.
  const SeriesStatistics({
    required this.name,
    required this.pointCount,
    required this.totalReceived,
    required this.totalEvicted,
    required this.ingestRate,
    required this.memoryBytes,
    this.dataRange,
  });

  /// Name of the series.
  final String name;

  /// Current number of points in buffer.
  final int pointCount;

  /// Total points received since controller creation (including evicted).
  final int totalReceived;

  /// Points evicted due to retention policy since controller creation.
  final int totalEvicted;

  /// Data ingestion rate (points per second) over the measurement window.
  final double ingestRate;

  /// Estimated memory usage in bytes for this series.
  final int memoryBytes;

  /// Time range of data in buffer, or null if empty.
  ///
  /// The tuple contains (minX, maxX) values.
  final (double, double)? dataRange;

  /// Whether this series has high-frequency data (>100 Hz).
  ///
  /// High-frequency data may benefit from additional optimization.
  bool get isHighFrequency => ingestRate > 100;

  /// Retention ratio: how much data is being kept vs received.
  ///
  /// A value of 1.0 means all data is kept.
  /// A lower value indicates active eviction due to retention policy.
  double get retentionRatio =>
      totalReceived > 0 ? pointCount / totalReceived : 1.0;

  @override
  String toString() =>
      'SeriesStatistics('
      'name: $name, '
      'points: $pointCount, '
      'received: $totalReceived, '
      'evicted: $totalEvicted, '
      'rate: ${ingestRate.toStringAsFixed(1)} Hz, '
      'memory: ${(memoryBytes / 1024).toStringAsFixed(1)} KB)';
}

/// Tracks ingest rate using a sliding window.
///
/// Internal class used by the controller to calculate
/// data ingestion rates over a configurable time window.
class IngestRateTracker {
  /// Creates an ingest rate tracker with the given measurement window.
  IngestRateTracker({this.window = const Duration(seconds: 5)});

  /// The time window over which to calculate the rate.
  final Duration window;

  final List<int> _timestamps = [];

  /// Record a data point arrival.
  void record() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _timestamps.add(now);
    _pruneOld(now);
  }

  /// Record multiple data point arrivals.
  void recordBatch(int count) {
    if (count <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < count; i++) {
      _timestamps.add(now);
    }
    _pruneOld(now);
  }

  /// Get the current ingest rate in points per second.
  double get rate {
    if (_timestamps.isEmpty) return 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    _pruneOld(now);

    if (_timestamps.isEmpty) return 0;

    final windowMs = window.inMilliseconds;
    final elapsed = now - _timestamps.first;

    // Use the actual elapsed time or the window, whichever is smaller
    final effectiveWindow = elapsed < windowMs ? elapsed : windowMs;

    if (effectiveWindow <= 0) return 0;

    return _timestamps.length / (effectiveWindow / 1000);
  }

  void _pruneOld(int now) {
    final cutoff = now - window.inMilliseconds;
    while (_timestamps.isNotEmpty && _timestamps.first < cutoff) {
      _timestamps.removeAt(0);
    }
  }

  /// Clear all recorded timestamps.
  void clear() {
    _timestamps.clear();
  }
}

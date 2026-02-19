/// Policy for managing data retention in live charts.
///
/// Prevents unbounded memory growth for long-running live sessions.
/// Each policy defines rules for when to evict old data points.
///
/// Example:
/// ```dart
/// // Keep last 500 points
/// final policy = RetentionPolicy.rollingCount(500);
///
/// // Keep last 5 minutes of data
/// final policy = RetentionPolicy.rollingDuration(Duration(minutes: 5));
/// ```
sealed class RetentionPolicy {
  const RetentionPolicy();

  /// Keep the last [maxPoints] data points per series.
  ///
  /// Oldest points are evicted when limit is reached.
  ///
  /// Memory usage: Fixed, predictable.
  /// Best for: High-frequency data where you want consistent memory usage.
  ///
  /// Example: `RetentionPolicy.rollingCount(500)` keeps last 500 points.
  const factory RetentionPolicy.rollingCount(int maxPoints) =
      RollingCountPolicy;

  /// Keep data points from the last [duration].
  ///
  /// Points older than duration are evicted on each update.
  /// Uses data point timestamps for eviction, not wall clock time.
  ///
  /// Memory usage: Varies with data frequency.
  /// At 10 Hz with 5 minute window = ~3000 points.
  ///
  /// Best for: Time-based monitoring where you want "last N minutes".
  ///
  /// Example: `RetentionPolicy.rollingDuration(Duration(minutes: 5))`
  const factory RetentionPolicy.rollingDuration(Duration duration) =
      RollingDurationPolicy;

  /// Keep all data points. Use with caution!
  ///
  /// Memory usage: Unbounded, grows indefinitely.
  ///
  /// Best for: Short sessions where you need complete history.
  ///
  /// Warning: Only use for:
  /// - Short sessions (< 1 hour at low frequency)
  /// - Low-frequency data (< 1 Hz)
  /// - When you need to export complete session data
  const factory RetentionPolicy.unlimited() = UnlimitedPolicy;

  /// Combined count and duration limit.
  ///
  /// Evicts when EITHER limit is exceeded.
  ///
  /// Memory usage: Bounded by count, responsive to time.
  ///
  /// Best for: Variable-frequency data where you want both guarantees.
  ///
  /// Example: Keep last 5 minutes OR 1000 points, whichever is less.
  const factory RetentionPolicy.combined({
    required int maxPoints,
    required Duration maxDuration,
  }) = CombinedPolicy;

  /// Keep recent data at full resolution, older data downsampled.
  ///
  /// Memory usage: Bounded, with configurable detail levels.
  ///
  /// Best for: Long sessions where you want both recent detail and history.
  ///
  /// Example:
  /// ```dart
  /// RetentionPolicy.downsampled(
  ///   recentDuration: Duration(minutes: 5),   // Full resolution
  ///   recentMaxPoints: 500,                   // Cap recent points
  ///   archiveResolution: Duration(seconds: 30), // 1 point per 30s for older
  ///   maxArchivePoints: 1000,                 // Cap archive size
  ///   downsampleMethod: DownsampleMethod.lttb, // Use LTTB for visual quality
  /// )
  /// ```
  const factory RetentionPolicy.downsampled({
    required Duration recentDuration,
    required Duration archiveResolution,
    int? recentMaxPoints,
    int? maxArchivePoints,
    DownsampleMethod downsampleMethod,
  }) = DownsampledPolicy;
}

/// Method for downsampling when archiving data.
enum DownsampleMethod {
  /// Keep first point in each bucket.
  first,

  /// Keep last point in each bucket.
  last,

  /// Average all points in each bucket.
  average,

  /// Keep min and max points in each bucket.
  minMax,

  /// Largest Triangle Three Buckets - best visual quality.
  ///
  /// Preserves visual shape of the data by selecting points
  /// that form the largest triangles when connected.
  lttb,
}

/// Keep the last [maxPoints] data points per series.
class RollingCountPolicy extends RetentionPolicy {
  /// Creates a rolling count retention policy.
  ///
  /// [maxPoints] must be greater than 0.
  const RollingCountPolicy(this.maxPoints)
    : assert(maxPoints > 0, 'maxPoints must be positive');

  /// Maximum number of points to keep per series.
  final int maxPoints;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RollingCountPolicy &&
          runtimeType == other.runtimeType &&
          maxPoints == other.maxPoints;

  @override
  int get hashCode => maxPoints.hashCode;

  @override
  String toString() => 'RollingCountPolicy($maxPoints)';
}

/// Keep data points from the last [duration].
class RollingDurationPolicy extends RetentionPolicy {
  /// Creates a rolling duration retention policy.
  ///
  /// [duration] should be greater than zero for meaningful behavior.
  const RollingDurationPolicy(this.duration);

  /// Maximum age of points to keep, relative to the newest point.
  final Duration duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RollingDurationPolicy &&
          runtimeType == other.runtimeType &&
          duration == other.duration;

  @override
  int get hashCode => duration.hashCode;

  @override
  String toString() => 'RollingDurationPolicy($duration)';
}

/// Keep all data points.
class UnlimitedPolicy extends RetentionPolicy {
  /// Creates an unlimited retention policy.
  const UnlimitedPolicy();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlimitedPolicy && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'UnlimitedPolicy()';
}

/// Combined count and duration limit.
class CombinedPolicy extends RetentionPolicy {
  /// Creates a combined retention policy.
  ///
  /// [maxPoints] must be greater than 0.
  /// [maxDuration] should be greater than zero for meaningful behavior.
  const CombinedPolicy({required this.maxPoints, required this.maxDuration})
    : assert(maxPoints > 0, 'maxPoints must be positive');

  /// Maximum number of points to keep per series.
  final int maxPoints;

  /// Maximum age of points to keep, relative to the newest point.
  final Duration maxDuration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombinedPolicy &&
          runtimeType == other.runtimeType &&
          maxPoints == other.maxPoints &&
          maxDuration == other.maxDuration;

  @override
  int get hashCode => Object.hash(maxPoints, maxDuration);

  @override
  String toString() =>
      'CombinedPolicy(maxPoints: $maxPoints, maxDuration: $maxDuration)';
}

/// Keep recent data at full resolution, older data downsampled.
class DownsampledPolicy extends RetentionPolicy {
  /// Creates a downsampled retention policy.
  const DownsampledPolicy({
    required this.recentDuration,
    required this.archiveResolution,
    this.recentMaxPoints,
    this.maxArchivePoints,
    this.downsampleMethod = DownsampleMethod.lttb,
  });

  /// How long to keep data at full resolution.
  final Duration recentDuration;

  /// Maximum points to keep in the recent buffer.
  /// If null, limited only by [recentDuration].
  final int? recentMaxPoints;

  /// Resolution for archived (older) data.
  /// One representative point is kept per this duration.
  final Duration archiveResolution;

  /// Maximum points to keep in the archive buffer.
  /// If null, archive grows indefinitely.
  final int? maxArchivePoints;

  /// Method to use when downsampling to archive.
  final DownsampleMethod downsampleMethod;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownsampledPolicy &&
          runtimeType == other.runtimeType &&
          recentDuration == other.recentDuration &&
          recentMaxPoints == other.recentMaxPoints &&
          archiveResolution == other.archiveResolution &&
          maxArchivePoints == other.maxArchivePoints &&
          downsampleMethod == other.downsampleMethod;

  @override
  int get hashCode => Object.hash(
    recentDuration,
    recentMaxPoints,
    archiveResolution,
    maxArchivePoints,
    downsampleMethod,
  );

  @override
  String toString() =>
      'DownsampledPolicy('
      'recentDuration: $recentDuration, '
      'recentMaxPoints: $recentMaxPoints, '
      'archiveResolution: $archiveResolution, '
      'maxArchivePoints: $maxArchivePoints, '
      'downsampleMethod: $downsampleMethod)';
}

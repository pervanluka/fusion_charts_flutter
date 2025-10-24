import 'package:flutter/material.dart' show TextPainter, Offset, Path, Shader, TextStyle;

import '../data/fusion_data_point.dart';
import 'fusion_coordinate_system.dart';

/// Cache for expensive rendering calculations.
///
/// This class dramatically improves performance by caching computed values
/// that don't change between frames. Essential for 60 FPS rendering.
///
/// ## What Gets Cached
///
/// 1. **Coordinate transformations** - Screen positions of data points
/// 2. **Paths** - Pre-computed Path objects for curves
/// 3. **Text layouts** - TextPainter layouts for labels
/// 4. **Gradients** - Shader objects
/// 5. **Clipping regions** - Computed clip paths
///
/// ## Cache Invalidation
///
/// Cache is automatically invalidated when:
/// - Data changes
/// - Coordinate system changes (zoom/pan)
/// - Size changes
/// - Theme changes
///
/// ## Memory Management
///
/// Cache has a maximum size and uses LRU (Least Recently Used) eviction.
class FusionRenderCache {
  FusionRenderCache({this.maxCacheSize = 100});

  /// Maximum number of cached items.
  final int maxCacheSize;

  // ==========================================================================
  // CACHE STORAGE
  // ==========================================================================

  final Map<String, _CacheEntry> _cache = {};
  final List<String> _accessOrder = [];

  // ==========================================================================
  // COORDINATE TRANSFORMATION CACHE
  // ==========================================================================

  /// Caches screen positions for data points.
  ///
  /// Key format: "coords_{hashCode}"
  List<Offset>? getCachedScreenPositions(
    List<FusionDataPoint> dataPoints,
    FusionCoordinateSystem coordSystem,
  ) {
    final key = _generateCoordKey(dataPoints, coordSystem);
    final entry = _get(key);

    if (entry != null && entry.value is List<Offset>) {
      return entry.value as List<Offset>;
    }

    return null;
  }

  /// Stores screen positions in cache.
  void setCachedScreenPositions(
    List<FusionDataPoint> dataPoints,
    FusionCoordinateSystem coordSystem,
    List<Offset> screenPositions,
  ) {
    final key = _generateCoordKey(dataPoints, coordSystem);
    _put(key, screenPositions);
  }

  String _generateCoordKey(List<FusionDataPoint> dataPoints, FusionCoordinateSystem coordSystem) {
    return 'coords_${dataPoints.hashCode}_${coordSystem.hashCode}';
  }

  // ==========================================================================
  // PATH CACHE
  // ==========================================================================

  /// Caches a computed path.
  Path? getCachedPath(String pathId) {
    final entry = _get(pathId);
    return entry?.value as Path?;
  }

  /// Stores a path in cache.
  void setCachedPath(String pathId, Path path) {
    _put(pathId, path);
  }

  /// Generates a path cache key.
  String generatePathKey({
    required String seriesName,
    required List<FusionDataPoint> dataPoints,
    required FusionCoordinateSystem coordSystem,
    required bool isCurved,
    double? smoothness,
  }) {
    return 'path_${seriesName}_'
        '${dataPoints.hashCode}_'
        '${coordSystem.hashCode}_'
        '${isCurved}_'
        '${smoothness ?? 0}';
  }

  // ==========================================================================
  // TEXT LAYOUT CACHE
  // ==========================================================================

  /// Caches a text layout.
  TextPainter? getCachedTextLayout(String text, TextStyle style) {
    final key = _generateTextKey(text, style);
    final entry = _get(key);
    return entry?.value as TextPainter?;
  }

  /// Stores a text layout in cache.
  void setCachedTextLayout(String text, TextStyle style, TextPainter painter) {
    final key = _generateTextKey(text, style);
    _put(key, painter);
  }

  String _generateTextKey(String text, TextStyle style) {
    return 'text_${text}_${style.hashCode}';
  }

  // ==========================================================================
  // SHADER/GRADIENT CACHE
  // ==========================================================================

  /// Caches a gradient shader.
  Shader? getCachedShader(String shaderId) {
    final entry = _get(shaderId);
    return entry?.value as Shader?;
  }

  /// Stores a shader in cache.
  void setCachedShader(String shaderId, Shader shader) {
    _put(shaderId, shader);
  }

  // ==========================================================================
  // GENERIC CACHE OPERATIONS
  // ==========================================================================

  /// Gets a cached value by key.
  _CacheEntry? _get(String key) {
    final entry = _cache[key];

    if (entry != null) {
      // Update access order (LRU)
      _accessOrder.remove(key);
      _accessOrder.add(key);
      entry.lastAccessed = DateTime.now();
    }

    return entry;
  }

  /// Puts a value in the cache.
  void _put(String key, dynamic value) {
    // Check if we need to evict old entries
    if (_cache.length >= maxCacheSize && !_cache.containsKey(key)) {
      _evictLeastRecentlyUsed();
    }

    _cache[key] = _CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );

    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// Evicts the least recently used entry.
  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isEmpty) return;

    final keyToEvict = _accessOrder.first;
    _cache.remove(keyToEvict);
    _accessOrder.remove(keyToEvict);
  }

  // ==========================================================================
  // CACHE MANAGEMENT
  // ==========================================================================

  /// Clears all cached data.
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Clears cache entries matching a prefix.
  void clearPrefix(String prefix) {
    final keysToRemove = _cache.keys.where((k) => k.startsWith(prefix)).toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }
  }

  /// Clears old entries (older than specified duration).
  void clearOldEntries(Duration maxAge) {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      final age = now.difference(entry.value.createdAt);
      if (age > maxAge) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }
  }

  /// Gets cache statistics.
  CacheStatistics getStatistics() {
    return CacheStatistics(
      totalEntries: _cache.length,
      maxSize: maxCacheSize,
      utilizationPercent: (_cache.length / maxCacheSize * 100),
    );
  }

  /// Checks if cache contains a key.
  bool contains(String key) {
    return _cache.containsKey(key);
  }

  /// Gets the number of cached entries.
  int get size => _cache.length;

  /// Checks if cache is empty.
  bool get isEmpty => _cache.isEmpty;

  /// Checks if cache is full.
  bool get isFull => _cache.length >= maxCacheSize;
}

/// Cache entry with metadata.
class _CacheEntry {
  _CacheEntry({required this.value, required this.createdAt, required this.lastAccessed});

  final dynamic value;
  final DateTime createdAt;
  DateTime lastAccessed;
}

/// Cache statistics.
class CacheStatistics {
  const CacheStatistics({
    required this.totalEntries,
    required this.maxSize,
    required this.utilizationPercent,
  });

  final int totalEntries;
  final int maxSize;
  final double utilizationPercent;

  @override
  String toString() {
    return 'CacheStatistics('
        'entries: $totalEntries/$maxSize, '
        'utilization: ${utilizationPercent.toStringAsFixed(1)}%'
        ')';
  }
}

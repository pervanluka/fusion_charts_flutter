import 'dart:ui';

/// Optimizes rendering by detecting and skipping redundant operations.
///
/// Tracks what changed between frames and only rerenders affected areas.
class FusionRenderOptimizer {
  FusionRenderOptimizer({this.enableDirtyRegionTracking = true, this.enablePathCaching = true});

  final bool enableDirtyRegionTracking;
  final bool enablePathCaching;

  /// Dirty regions that need repainting.
  final List<Rect> _dirtyRegions = [];

  /// Last frame's render hash for change detection.
  final Map<String, int> _lastFrameHashes = {};

  /// Path cache with LRU eviction.
  final Map<String, _CachedPath> _pathCache = {};
  static const int maxCachedPaths = 100;

  /// Marks a region as dirty (needs repaint).
  void markDirty(Rect region) {
    if (!enableDirtyRegionTracking) return;
    _dirtyRegions.add(region);
  }

  /// Checks if a region needs repainting.
  bool isDirty(Rect region) {
    if (!enableDirtyRegionTracking) return true;
    return _dirtyRegions.any((dirty) => dirty.overlaps(region));
  }

  /// Checks if data changed since last frame.
  bool hasDataChanged(String key, List<Object?> data) {
    final currentHash = Object.hashAll(data);
    final lastHash = _lastFrameHashes[key];

    if (lastHash != currentHash) {
      _lastFrameHashes[key] = currentHash;
      return true;
    }
    return false;
  }

  /// Gets cached path or returns null if not found.
  Path? getCachedPath(String key) {
    if (!enablePathCaching) return null;

    final cached = _pathCache[key];
    if (cached != null) {
      cached.lastUsedFrame = _currentFrame;
      return cached.path;
    }
    return null;
  }

  /// Caches a path for reuse.
  void cachePath(String key, Path path) {
    if (!enablePathCaching) return;

    // Evict oldest if cache full
    if (_pathCache.length >= maxCachedPaths) {
      _evictOldestPath();
    }

    _pathCache[key] = _CachedPath(
      path: path,
      createdFrame: _currentFrame,
      lastUsedFrame: _currentFrame,
    );
  }

  int _currentFrame = 0;

  /// Call this at the start of each frame.
  void beginFrame() {
    _currentFrame++;
    _dirtyRegions.clear();
  }

  /// Call this at the end of each frame.
  void endFrame() {
    // Evict paths not used in last 60 frames (~1 second at 60 FPS)
    _pathCache.removeWhere((key, cached) {
      return _currentFrame - cached.lastUsedFrame > 60;
    });
  }

  void _evictOldestPath() {
    String? oldestKey;
    int oldestFrame = _currentFrame;

    _pathCache.forEach((key, cached) {
      if (cached.lastUsedFrame < oldestFrame) {
        oldestFrame = cached.lastUsedFrame;
        oldestKey = key;
      }
    });

    if (oldestKey != null) {
      _pathCache.remove(oldestKey);
    }
  }

  /// Clears all caches.
  void clear() {
    _dirtyRegions.clear();
    _lastFrameHashes.clear();
    _pathCache.clear();
    _currentFrame = 0;
  }

  /// Gets optimization statistics.
  OptimizerStats get stats => OptimizerStats(
    cachedPaths: _pathCache.length,
    dirtyRegions: _dirtyRegions.length,
    currentFrame: _currentFrame,
  );
}

class _CachedPath {
  _CachedPath({required this.path, required this.createdFrame, required this.lastUsedFrame});

  final Path path;
  final int createdFrame;
  int lastUsedFrame;
}

class OptimizerStats {
  const OptimizerStats({
    required this.cachedPaths,
    required this.dirtyRegions,
    required this.currentFrame,
  });

  final int cachedPaths;
  final int dirtyRegions;
  final int currentFrame;
}

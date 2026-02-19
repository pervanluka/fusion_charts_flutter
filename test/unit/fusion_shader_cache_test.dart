import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_shader_cache.dart';

void main() {
  // ===========================================================================
  // FUSION SHADER CACHE
  // ===========================================================================
  group('FusionShaderCache', () {
    // =========================================================================
    // Construction
    // =========================================================================
    group('construction', () {
      test('creates with default max cache size', () {
        final cache = FusionShaderCache();

        expect(cache.maxCacheSize, 100);
        expect(cache.size, 0);
        expect(cache.isEmpty, isTrue);
        expect(cache.isFull, isFalse);
      });

      test('creates with custom max cache size', () {
        final cache = FusionShaderCache(maxCacheSize: 50);

        expect(cache.maxCacheSize, 50);
      });
    });

    // =========================================================================
    // getShader() method
    // =========================================================================
    group('getShader()', () {
      test('creates shader on cache miss', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        final shader = cache.getShader(gradient, bounds);

        expect(shader, isNotNull);
        expect(cache.size, 1);
        expect(cache.statistics.cacheMisses, 1);
        expect(cache.statistics.cacheHits, 0);
      });

      test('returns cached shader on cache hit', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        final shader1 = cache.getShader(gradient, bounds);
        final shader2 = cache.getShader(gradient, bounds);

        expect(shader1, same(shader2));
        expect(cache.statistics.cacheHits, 1);
      });

      test('creates different shaders for different gradients', () {
        final cache = FusionShaderCache();
        const gradient1 = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const gradient2 = LinearGradient(colors: [Colors.red, Colors.orange]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        final shader1 = cache.getShader(gradient1, bounds);
        final shader2 = cache.getShader(gradient2, bounds);

        expect(shader1, isNot(same(shader2)));
        expect(cache.size, 2);
      });

      test('creates different shaders for different bounds', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds1 = Rect.fromLTWH(0, 0, 100, 100);
        const bounds2 = Rect.fromLTWH(0, 0, 200, 200);

        final shader1 = cache.getShader(gradient, bounds1);
        final shader2 = cache.getShader(gradient, bounds2);

        expect(shader1, isNot(same(shader2)));
        expect(cache.size, 2);
      });

      test('evicts LRU shader when cache is full', () {
        final cache = FusionShaderCache(maxCacheSize: 3);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        const gradient1 = LinearGradient(colors: [Colors.red, Colors.red]);
        const gradient2 = LinearGradient(colors: [Colors.blue, Colors.blue]);
        const gradient3 = LinearGradient(colors: [Colors.green, Colors.green]);
        const gradient4 = LinearGradient(
          colors: [Colors.yellow, Colors.yellow],
        );

        cache.getShader(gradient1, bounds);
        cache.getShader(gradient2, bounds);
        cache.getShader(gradient3, bounds);
        cache.getShader(gradient4, bounds);

        expect(cache.size, lessThanOrEqualTo(3));
        expect(cache.contains(gradient1, bounds), isFalse);
      });
    });

    // =========================================================================
    // getLinearGradient() method
    // =========================================================================
    group('getLinearGradient()', () {
      test('returns shader for linear gradient', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        final shader = cache.getLinearGradient(gradient, bounds);

        expect(shader, isNotNull);
      });
    });

    // =========================================================================
    // getLinearShader() method
    // =========================================================================
    group('getLinearShader()', () {
      test('returns shader for linear gradient', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        final shader = cache.getLinearShader(gradient, bounds);

        expect(shader, isNotNull);
      });
    });

    // =========================================================================
    // getRadialShader() method
    // =========================================================================
    group('getRadialShader()', () {
      test('returns shader for radial gradient', () {
        final cache = FusionShaderCache();
        const gradient = RadialGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        final shader = cache.getRadialShader(gradient, bounds);

        expect(shader, isNotNull);
      });
    });

    // =========================================================================
    // getSweepShader() method
    // =========================================================================
    group('getSweepShader()', () {
      test('returns shader for sweep gradient', () {
        final cache = FusionShaderCache();
        const gradient = SweepGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        final shader = cache.getSweepShader(gradient, bounds);

        expect(shader, isNotNull);
      });
    });

    // =========================================================================
    // clear() method
    // =========================================================================
    group('clear()', () {
      test('clears all cached shaders', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient, bounds);
        expect(cache.size, 1);

        cache.clear();

        expect(cache.size, 0);
        expect(cache.isEmpty, isTrue);
        expect(cache.statistics.cacheHits, 0);
        expect(cache.statistics.cacheMisses, 0);
      });
    });

    // =========================================================================
    // remove() method
    // =========================================================================
    group('remove()', () {
      test('removes specific shader from cache', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient, bounds);
        expect(cache.contains(gradient, bounds), isTrue);

        cache.remove(gradient, bounds);

        expect(cache.contains(gradient, bounds), isFalse);
        expect(cache.size, 0);
      });

      test('does nothing for non-existent shader', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.remove(gradient, bounds);

        expect(cache.size, 0);
      });
    });

    // =========================================================================
    // trim() method
    // =========================================================================
    group('trim()', () {
      test('trims cache to default target size (half of max)', () {
        final cache = FusionShaderCache(maxCacheSize: 10);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        for (int i = 0; i < 10; i++) {
          final gradient = LinearGradient(colors: [Color(i), Color(i + 1)]);
          cache.getShader(gradient, bounds);
        }

        cache.trim();

        expect(cache.size, lessThanOrEqualTo(5));
      });

      test('trims cache to specified target size', () {
        final cache = FusionShaderCache(maxCacheSize: 10);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        for (int i = 0; i < 10; i++) {
          final gradient = LinearGradient(colors: [Color(i), Color(i + 1)]);
          cache.getShader(gradient, bounds);
        }

        cache.trim(targetSize: 3);

        expect(cache.size, lessThanOrEqualTo(3));
      });
    });

    // =========================================================================
    // removeOldEntries() method
    // =========================================================================
    group('removeOldEntries()', () {
      test('removes entries older than max age', () async {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient, bounds);

        // Wait briefly
        await Future<void>.delayed(const Duration(milliseconds: 50));

        cache.removeOldEntries(const Duration(milliseconds: 10));

        expect(cache.size, 0);
      });

      test('keeps entries younger than max age', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient, bounds);

        cache.removeOldEntries(const Duration(hours: 1));

        expect(cache.size, 1);
      });
    });

    // =========================================================================
    // contains() method
    // =========================================================================
    group('contains()', () {
      test('returns true for cached shader', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient, bounds);

        expect(cache.contains(gradient, bounds), isTrue);
      });

      test('returns false for non-cached shader', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        expect(cache.contains(gradient, bounds), isFalse);
      });
    });

    // =========================================================================
    // statistics property
    // =========================================================================
    group('statistics', () {
      test('tracks cache hits and misses', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        // 1 miss
        cache.getShader(gradient, bounds);

        // 2 hits
        cache.getShader(gradient, bounds);
        cache.getShader(gradient, bounds);

        final stats = cache.statistics;

        expect(stats.cacheMisses, 1);
        expect(stats.cacheHits, 2);
        expect(stats.totalRequests, 3);
        expect(stats.hitRate, closeTo(0.666, 0.01));
      });

      test('returns 0 hit rate when no requests', () {
        final cache = FusionShaderCache();

        expect(cache.statistics.hitRate, 0.0);
      });
    });

    // =========================================================================
    // size, isEmpty, isFull properties
    // =========================================================================
    group('size, isEmpty, isFull', () {
      test('isEmpty returns true for empty cache', () {
        final cache = FusionShaderCache();

        expect(cache.isEmpty, isTrue);
      });

      test('isEmpty returns false for non-empty cache', () {
        final cache = FusionShaderCache();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient, bounds);

        expect(cache.isEmpty, isFalse);
      });

      test('isFull returns true when cache reaches max size', () {
        final cache = FusionShaderCache(maxCacheSize: 2);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        const gradient1 = LinearGradient(colors: [Colors.red, Colors.red]);
        const gradient2 = LinearGradient(colors: [Colors.blue, Colors.blue]);

        cache.getShader(gradient1, bounds);
        cache.getShader(gradient2, bounds);

        expect(cache.isFull, isTrue);
      });
    });

    // =========================================================================
    // toString() method
    // =========================================================================
    group('toString()', () {
      test('returns descriptive string', () {
        final cache = FusionShaderCache();

        final str = cache.toString();

        expect(str, contains('FusionShaderCache'));
        expect(str, contains('size:'));
        expect(str, contains('hitRate:'));
      });
    });

    // =========================================================================
    // Gradient type handling
    // =========================================================================
    group('gradient type handling', () {
      test('handles LinearGradient with different begin/end', () {
        final cache = FusionShaderCache();
        const gradient1 = LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        const gradient2 = LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient1, bounds);
        cache.getShader(gradient2, bounds);

        expect(cache.size, 2);
      });

      test('handles RadialGradient with different center/radius', () {
        final cache = FusionShaderCache();
        const gradient1 = RadialGradient(
          colors: [Colors.blue, Colors.purple],
          center: Alignment.center,
          radius: 0.5,
        );
        const gradient2 = RadialGradient(
          colors: [Colors.blue, Colors.purple],
          center: Alignment.topLeft,
          radius: 1.0,
        );
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient1, bounds);
        cache.getShader(gradient2, bounds);

        expect(cache.size, 2);
      });

      test('handles SweepGradient with different angles', () {
        final cache = FusionShaderCache();
        const gradient1 = SweepGradient(
          colors: [Colors.blue, Colors.purple],
          startAngle: 0.0,
          endAngle: 3.14,
        );
        const gradient2 = SweepGradient(
          colors: [Colors.blue, Colors.purple],
          startAngle: 1.57,
          endAngle: 4.71,
        );
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient1, bounds);
        cache.getShader(gradient2, bounds);

        expect(cache.size, 2);
      });

      test('handles gradients with stops', () {
        final cache = FusionShaderCache();
        const gradient1 = LinearGradient(
          colors: [Colors.blue, Colors.purple],
          stops: [0.0, 1.0],
        );
        const gradient2 = LinearGradient(
          colors: [Colors.blue, Colors.purple],
          stops: [0.2, 0.8],
        );
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.getShader(gradient1, bounds);
        cache.getShader(gradient2, bounds);

        expect(cache.size, 2);
      });
    });
  });

  // ===========================================================================
  // SHADER CACHE STATISTICS
  // ===========================================================================
  group('ShaderCacheStatistics', () {
    test('calculates totalRequests', () {
      const stats = ShaderCacheStatistics(
        totalShaders: 5,
        cacheHits: 10,
        cacheMisses: 5,
        hitRate: 0.666,
      );

      expect(stats.totalRequests, 15);
    });

    test('calculates estimatedMemoryBytes', () {
      const stats = ShaderCacheStatistics(
        totalShaders: 5,
        cacheHits: 10,
        cacheMisses: 5,
        hitRate: 0.666,
      );

      expect(stats.estimatedMemoryBytes, 5 * 1024);
    });

    test('toString returns descriptive string', () {
      const stats = ShaderCacheStatistics(
        totalShaders: 5,
        cacheHits: 10,
        cacheMisses: 5,
        hitRate: 0.666,
      );

      final str = stats.toString();

      expect(str, contains('ShaderCacheStatistics'));
      expect(str, contains('shaders:'));
      expect(str, contains('hits:'));
      expect(str, contains('misses:'));
      expect(str, contains('hitRate:'));
    });
  });

  // ===========================================================================
  // FUSION SHADER CACHE EXTENSIONS
  // ===========================================================================
  group('FusionShaderCacheExtensions', () {
    group('applyShaderToPaint()', () {
      test('applies shader to paint', () {
        final cache = FusionShaderCache();
        final paint = Paint();
        const gradient = LinearGradient(colors: [Colors.blue, Colors.purple]);
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.applyShaderToPaint(paint, gradient, bounds);

        expect(paint.shader, isNotNull);
      });
    });

    group('prewarmCache()', () {
      test('pre-warms cache with gradients', () {
        final cache = FusionShaderCache();
        const gradients = [
          LinearGradient(colors: [Colors.red, Colors.orange]),
          LinearGradient(colors: [Colors.blue, Colors.purple]),
          LinearGradient(colors: [Colors.green, Colors.teal]),
        ];
        const bounds = Rect.fromLTWH(0, 0, 100, 100);

        cache.prewarmCache(gradients, bounds);

        expect(cache.size, 3);
      });
    });
  });
}

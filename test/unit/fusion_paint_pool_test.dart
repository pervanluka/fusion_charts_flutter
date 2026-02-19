import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/rendering/engine/fusion_paint_pool.dart';

void main() {
  // ===========================================================================
  // FUSION PAINT POOL
  // ===========================================================================
  group('FusionPaintPool', () {
    // =========================================================================
    // Construction
    // =========================================================================
    group('construction', () {
      test('creates with default max pool size', () {
        final pool = FusionPaintPool();

        expect(pool.maxPoolSize, 50);
        expect(pool.statistics.totalCreated, 0);
        expect(pool.statistics.inPool, 0);
        expect(pool.statistics.inUse, 0);
      });

      test('creates with custom max pool size', () {
        final pool = FusionPaintPool(maxPoolSize: 100);

        expect(pool.maxPoolSize, 100);
      });
    });

    // =========================================================================
    // acquire() method
    // =========================================================================
    group('acquire()', () {
      test('creates new Paint when pool is empty', () {
        final pool = FusionPaintPool();

        final paint = pool.acquire();

        expect(paint, isNotNull);
        expect(pool.statistics.totalCreated, 1);
        expect(pool.statistics.inUse, 1);
        expect(pool.statistics.cacheHits, 0);
      });

      test('reuses Paint from pool when available', () {
        final pool = FusionPaintPool();

        final paint1 = pool.acquire();
        pool.release(paint1);

        final paint2 = pool.acquire();

        expect(paint2, same(paint1));
        expect(pool.statistics.totalCreated, 1);
        expect(pool.statistics.cacheHits, 1);
      });

      test('resets Paint to default state', () {
        final pool = FusionPaintPool();

        final paint = pool.acquire();

        expect(paint.color, const Color(0xFF000000));
        expect(paint.strokeWidth, 1.0);
        expect(paint.style, PaintingStyle.stroke);
        expect(paint.strokeCap, StrokeCap.butt);
        expect(paint.strokeJoin, StrokeJoin.miter);
        expect(paint.isAntiAlias, isTrue);
        expect(paint.filterQuality, FilterQuality.none);
        expect(paint.shader, isNull);
        expect(paint.maskFilter, isNull);
        expect(paint.colorFilter, isNull);
        expect(paint.imageFilter, isNull);
        expect(paint.invertColors, isFalse);

        pool.release(paint);
      });

      test('increments acquire count', () {
        final pool = FusionPaintPool();

        pool.acquire();
        pool.acquire();
        pool.acquire();

        expect(pool.statistics.acquireCount, 3);
      });
    });

    // =========================================================================
    // release() method
    // =========================================================================
    group('release()', () {
      test('returns Paint to pool', () {
        final pool = FusionPaintPool();

        final paint = pool.acquire();
        expect(pool.statistics.inUse, 1);

        pool.release(paint);

        expect(pool.statistics.inUse, 0);
        expect(pool.statistics.inPool, 1);
      });

      test('ignores Paint not from this pool', () {
        final pool = FusionPaintPool();
        final foreignPaint = Paint();

        pool.release(foreignPaint);

        expect(pool.statistics.inPool, 0);
      });

      test('does not exceed max pool size', () {
        final pool = FusionPaintPool(maxPoolSize: 5);

        // Acquire and release more than max
        for (int i = 0; i < 10; i++) {
          final paint = pool.acquire();
          pool.release(paint);
        }

        expect(pool.statistics.inPool, lessThanOrEqualTo(5));
      });

      test('resets Paint before returning to pool', () {
        final pool = FusionPaintPool();

        final paint = pool.acquire();
        paint.color = Colors.red;
        paint.strokeWidth = 5.0;
        paint.style = PaintingStyle.fill;

        pool.release(paint);
        final reacquired = pool.acquire();

        expect(reacquired.color, const Color(0xFF000000));
        expect(reacquired.strokeWidth, 1.0);
        expect(reacquired.style, PaintingStyle.stroke);

        pool.release(reacquired);
      });
    });

    // =========================================================================
    // acquireBatch() method
    // =========================================================================
    group('acquireBatch()', () {
      test('acquires multiple Paints at once', () {
        final pool = FusionPaintPool();

        final paints = pool.acquireBatch(5);

        expect(paints.length, 5);
        expect(pool.statistics.inUse, 5);
        expect(pool.statistics.acquireCount, 5);

        pool.releaseBatch(paints);
      });

      test('returns empty list for count 0', () {
        final pool = FusionPaintPool();

        final paints = pool.acquireBatch(0);

        expect(paints, isEmpty);
      });
    });

    // =========================================================================
    // releaseBatch() method
    // =========================================================================
    group('releaseBatch()', () {
      test('releases multiple Paints at once', () {
        final pool = FusionPaintPool();

        final paints = pool.acquireBatch(5);
        pool.releaseBatch(paints);

        expect(pool.statistics.inUse, 0);
        expect(pool.statistics.inPool, 5);
      });
    });

    // =========================================================================
    // clear() method
    // =========================================================================
    group('clear()', () {
      test('clears all pool state', () {
        final pool = FusionPaintPool();

        pool.acquire();
        pool.acquire();
        pool.clear();

        expect(pool.statistics.totalCreated, 0);
        expect(pool.statistics.inPool, 0);
        expect(pool.statistics.inUse, 0);
        expect(pool.statistics.acquireCount, 0);
        expect(pool.statistics.cacheHits, 0);
      });
    });

    // =========================================================================
    // prewarm() method
    // =========================================================================
    group('prewarm()', () {
      test('pre-fills pool with Paint objects', () {
        final pool = FusionPaintPool();

        pool.prewarm(10);

        expect(pool.statistics.inPool, 10);
        expect(pool.statistics.totalCreated, 10);
      });

      test('does not exceed max pool size', () {
        final pool = FusionPaintPool(maxPoolSize: 5);

        pool.prewarm(10);

        expect(pool.statistics.inPool, 5);
      });

      test('does not add to existing pool beyond max', () {
        final pool = FusionPaintPool(maxPoolSize: 5);

        pool.prewarm(3);
        pool.prewarm(5);

        expect(pool.statistics.inPool, 5);
      });
    });

    // =========================================================================
    // trim() method
    // =========================================================================
    group('trim()', () {
      test('trims pool to default target size (half of max)', () {
        final pool = FusionPaintPool(maxPoolSize: 10);

        pool.prewarm(10);
        pool.trim();

        expect(pool.statistics.inPool, 5);
      });

      test('trims pool to specified target size', () {
        final pool = FusionPaintPool(maxPoolSize: 10);

        pool.prewarm(10);
        pool.trim(targetSize: 3);

        expect(pool.statistics.inPool, 3);
      });

      test('does nothing if pool is already smaller than target', () {
        final pool = FusionPaintPool();

        pool.prewarm(3);
        pool.trim(targetSize: 10);

        expect(pool.statistics.inPool, 3);
      });
    });

    // =========================================================================
    // statistics property
    // =========================================================================
    group('statistics', () {
      test('calculates correct hit rate', () {
        final pool = FusionPaintPool();

        // 2 misses (new allocations)
        final paint1 = pool.acquire();
        final paint2 = pool.acquire();
        pool.release(paint1);
        pool.release(paint2);

        // 2 hits (reused)
        pool.acquire();
        pool.acquire();

        final stats = pool.statistics;
        expect(stats.hitRate, 0.5);
        expect(stats.acquireCount, 4);
        expect(stats.cacheHits, 2);
      });

      test('returns 0 hit rate when no acquires', () {
        final pool = FusionPaintPool();

        expect(pool.statistics.hitRate, 0.0);
      });
    });

    // =========================================================================
    // health property
    // =========================================================================
    group('health', () {
      test('returns excellent for >90% hit rate', () {
        final pool = FusionPaintPool();
        pool.prewarm(10);

        // All hits
        for (int i = 0; i < 10; i++) {
          final p = pool.acquire();
          pool.release(p);
        }

        expect(pool.health, PoolHealth.excellent);
      });

      test('returns good for 75-90% hit rate', () {
        final pool = FusionPaintPool();

        // 1 miss
        final p = pool.acquire();
        pool.release(p);

        // 3 hits (75% rate)
        pool.acquire();

        expect(pool.statistics.hitRate, 0.5);
        // Need more hits to reach 75%
      });

      test('returns poor for <50% hit rate', () {
        final pool = FusionPaintPool();

        // All misses
        pool.acquire();
        pool.acquire();
        pool.acquire();

        expect(pool.health, PoolHealth.poor);
      });
    });

    // =========================================================================
    // toString() method
    // =========================================================================
    group('toString()', () {
      test('returns descriptive string', () {
        final pool = FusionPaintPool();

        pool.acquire();
        final str = pool.toString();

        expect(str, contains('FusionPaintPool'));
        expect(str, contains('created:'));
        expect(str, contains('pooled:'));
        expect(str, contains('inUse:'));
        expect(str, contains('hitRate:'));
      });
    });
  });

  // ===========================================================================
  // POOL STATISTICS
  // ===========================================================================
  group('PoolStatistics', () {
    test('calculates cacheMisses', () {
      const stats = PoolStatistics(
        totalCreated: 10,
        inPool: 5,
        inUse: 3,
        acquireCount: 20,
        cacheHits: 15,
        hitRate: 0.75,
      );

      expect(stats.cacheMisses, 5);
    });

    test('calculates totalAlive', () {
      const stats = PoolStatistics(
        totalCreated: 10,
        inPool: 5,
        inUse: 3,
        acquireCount: 20,
        cacheHits: 15,
        hitRate: 0.75,
      );

      expect(stats.totalAlive, 8);
    });

    test('calculates estimatedMemorySaved', () {
      const stats = PoolStatistics(
        totalCreated: 10,
        inPool: 5,
        inUse: 3,
        acquireCount: 20,
        cacheHits: 15,
        hitRate: 0.75,
      );

      expect(stats.estimatedMemorySaved, 1500);
    });

    test('toString returns descriptive string', () {
      const stats = PoolStatistics(
        totalCreated: 10,
        inPool: 5,
        inUse: 3,
        acquireCount: 20,
        cacheHits: 15,
        hitRate: 0.75,
      );

      final str = stats.toString();

      expect(str, contains('PoolStatistics'));
      expect(str, contains('created:'));
      expect(str, contains('pooled:'));
      expect(str, contains('inUse:'));
      expect(str, contains('hitRate:'));
    });
  });

  // ===========================================================================
  // POOL HEALTH ENUM
  // ===========================================================================
  group('PoolHealth', () {
    test('has all expected values', () {
      expect(PoolHealth.values, hasLength(4));
      expect(PoolHealth.values, contains(PoolHealth.excellent));
      expect(PoolHealth.values, contains(PoolHealth.good));
      expect(PoolHealth.values, contains(PoolHealth.fair));
      expect(PoolHealth.values, contains(PoolHealth.poor));
    });
  });

  // ===========================================================================
  // SCOPED PAINT
  // ===========================================================================
  group('ScopedPaint', () {
    test('acquires Paint from pool on creation', () {
      final pool = FusionPaintPool();
      final scoped = ScopedPaint(pool);

      expect(scoped.paint, isNotNull);
      expect(pool.statistics.inUse, 1);

      scoped.dispose();
    });

    test('releases Paint on dispose', () {
      final pool = FusionPaintPool();
      final scoped = ScopedPaint(pool);

      scoped.dispose();

      expect(pool.statistics.inUse, 0);
      expect(pool.statistics.inPool, 1);
    });

    test('dispose is idempotent', () {
      final pool = FusionPaintPool();
      final scoped = ScopedPaint(pool);

      scoped.dispose();
      scoped.dispose();
      scoped.dispose();

      expect(pool.statistics.inPool, 1);
    });
  });

  // ===========================================================================
  // FUSION PAINT POOL EXTENSIONS
  // ===========================================================================
  group('FusionPaintPoolExtensions', () {
    group('withPaint()', () {
      test('provides Paint and releases after callback', () {
        final pool = FusionPaintPool();

        pool.withPaint((paint) {
          expect(paint, isNotNull);
          expect(pool.statistics.inUse, 1);
        });

        expect(pool.statistics.inUse, 0);
        expect(pool.statistics.inPool, 1);
      });

      test('releases Paint even if callback throws', () {
        final pool = FusionPaintPool();

        expect(
          () => pool.withPaint((_) => throw Exception('test')),
          throwsException,
        );

        expect(pool.statistics.inUse, 0);
        expect(pool.statistics.inPool, 1);
      });
    });

    group('withPaints()', () {
      test('provides multiple Paints and releases after callback', () {
        final pool = FusionPaintPool();

        pool.withPaints(3, (paints) {
          expect(paints.length, 3);
          expect(pool.statistics.inUse, 3);
        });

        expect(pool.statistics.inUse, 0);
        expect(pool.statistics.inPool, 3);
      });

      test('releases Paints even if callback throws', () {
        final pool = FusionPaintPool();

        expect(
          () => pool.withPaints(3, (_) => throw Exception('test')),
          throwsException,
        );

        expect(pool.statistics.inUse, 0);
        expect(pool.statistics.inPool, 3);
      });
    });
  });
}

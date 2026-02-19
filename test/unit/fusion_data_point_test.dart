import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_data_point.dart';

void main() {
  // ===========================================================================
  // FUSION DATA POINT CLASS
  // ===========================================================================

  group('FusionDataPoint', () {
    group('constructor', () {
      test('creates point with required x and y', () {
        final point = FusionDataPoint(1.0, 2.0);

        expect(point.x, 1.0);
        expect(point.y, 2.0);
        expect(point.label, isNull);
        expect(point.metadata, isNull);
      });

      test('creates point with optional label', () {
        final point = FusionDataPoint(1.0, 2.0, label: 'January');

        expect(point.label, 'January');
      });

      test('creates point with optional metadata', () {
        final point = FusionDataPoint(
          1.0,
          2.0,
          metadata: {'category': 'Sales', 'count': 10},
        );

        expect(point.metadata, {'category': 'Sales', 'count': 10});
      });

      test('creates point with all parameters', () {
        final point = FusionDataPoint(
          1.0,
          2.0,
          label: 'January',
          metadata: {'key': 'value'},
        );

        expect(point.x, 1.0);
        expect(point.y, 2.0);
        expect(point.label, 'January');
        expect(point.metadata, {'key': 'value'});
      });

      test('handles negative values', () {
        final point = FusionDataPoint(-5.0, -10.0);

        expect(point.x, -5.0);
        expect(point.y, -10.0);
      });

      test('handles zero values', () {
        final point = FusionDataPoint(0.0, 0.0);

        expect(point.x, 0.0);
        expect(point.y, 0.0);
      });
    });

    group('copyWith', () {
      test('creates copy with modified x', () {
        final original = FusionDataPoint(1.0, 2.0, label: 'test');
        final copy = original.copyWith(x: 5.0);

        expect(copy.x, 5.0);
        expect(copy.y, 2.0);
        expect(copy.label, 'test');
      });

      test('creates copy with modified y', () {
        final original = FusionDataPoint(1.0, 2.0, label: 'test');
        final copy = original.copyWith(y: 10.0);

        expect(copy.x, 1.0);
        expect(copy.y, 10.0);
        expect(copy.label, 'test');
      });

      test('creates copy with modified label', () {
        final original = FusionDataPoint(1.0, 2.0, label: 'old');
        final copy = original.copyWith(label: 'new');

        expect(copy.label, 'new');
      });

      test('creates copy with modified metadata', () {
        final original = FusionDataPoint(1.0, 2.0, metadata: {'old': 1});
        final copy = original.copyWith(metadata: {'new': 2});

        expect(copy.metadata, {'new': 2});
      });

      test('creates unchanged copy when no parameters provided', () {
        final original = FusionDataPoint(
          1.0,
          2.0,
          label: 'test',
          metadata: {'key': 'value'},
        );
        final copy = original.copyWith();

        expect(copy.x, original.x);
        expect(copy.y, original.y);
        expect(copy.label, original.label);
        expect(copy.metadata, original.metadata);
      });
    });

    group('lerp', () {
      test('returns start point when t is 0', () {
        final start = FusionDataPoint(0.0, 0.0, label: 'start');
        final end = FusionDataPoint(10.0, 10.0, label: 'end');
        final result = start.lerp(end, 0.0);

        expect(result.x, 0.0);
        expect(result.y, 0.0);
        expect(result.label, 'start');
      });

      test('returns end point when t is 1', () {
        final start = FusionDataPoint(0.0, 0.0, label: 'start');
        final end = FusionDataPoint(10.0, 10.0, label: 'end');
        final result = start.lerp(end, 1.0);

        expect(result.x, 10.0);
        expect(result.y, 10.0);
        expect(result.label, 'end');
      });

      test('interpolates linearly at t=0.5', () {
        final start = FusionDataPoint(0.0, 0.0);
        final end = FusionDataPoint(10.0, 20.0);
        final result = start.lerp(end, 0.5);

        expect(result.x, 5.0);
        expect(result.y, 10.0);
      });

      test('interpolates at t=0.25', () {
        final start = FusionDataPoint(0.0, 0.0);
        final end = FusionDataPoint(100.0, 100.0);
        final result = start.lerp(end, 0.25);

        expect(result.x, 25.0);
        expect(result.y, 25.0);
      });

      test('uses start label when t < 0.5', () {
        final start = FusionDataPoint(0.0, 0.0, label: 'start');
        final end = FusionDataPoint(10.0, 10.0, label: 'end');
        final result = start.lerp(end, 0.49);

        expect(result.label, 'start');
      });

      test('uses end label when t >= 0.5', () {
        final start = FusionDataPoint(0.0, 0.0, label: 'start');
        final end = FusionDataPoint(10.0, 10.0, label: 'end');
        final result = start.lerp(end, 0.5);

        expect(result.label, 'end');
      });

      test('handles negative coordinates', () {
        final start = FusionDataPoint(-10.0, -10.0);
        final end = FusionDataPoint(10.0, 10.0);
        final result = start.lerp(end, 0.5);

        expect(result.x, 0.0);
        expect(result.y, 0.0);
      });
    });

    group('distanceTo', () {
      test('returns 0 for same point', () {
        final point = FusionDataPoint(5.0, 5.0);
        expect(point.distanceTo(point), 0.0);
      });

      test('calculates horizontal distance', () {
        final p1 = FusionDataPoint(0.0, 0.0);
        final p2 = FusionDataPoint(10.0, 0.0);
        expect(p1.distanceTo(p2), 10.0);
      });

      test('calculates vertical distance', () {
        final p1 = FusionDataPoint(0.0, 0.0);
        final p2 = FusionDataPoint(0.0, 10.0);
        expect(p1.distanceTo(p2), 10.0);
      });

      test('calculates diagonal distance (3-4-5 triangle)', () {
        final p1 = FusionDataPoint(0.0, 0.0);
        final p2 = FusionDataPoint(3.0, 4.0);
        expect(p1.distanceTo(p2), 5.0);
      });

      test('is symmetric', () {
        final p1 = FusionDataPoint(1.0, 2.0);
        final p2 = FusionDataPoint(4.0, 6.0);
        expect(p1.distanceTo(p2), p2.distanceTo(p1));
      });

      test('handles negative coordinates', () {
        final p1 = FusionDataPoint(-3.0, -4.0);
        final p2 = FusionDataPoint(0.0, 0.0);
        expect(p1.distanceTo(p2), 5.0);
      });
    });

    group('isWithinBounds', () {
      test('returns true for point inside bounds', () {
        final point = FusionDataPoint(5.0, 5.0);
        expect(point.isWithinBounds(0.0, 10.0, 0.0, 10.0), isTrue);
      });

      test('returns true for point on boundary', () {
        final point = FusionDataPoint(0.0, 0.0);
        expect(point.isWithinBounds(0.0, 10.0, 0.0, 10.0), isTrue);
      });

      test('returns true for point on max boundary', () {
        final point = FusionDataPoint(10.0, 10.0);
        expect(point.isWithinBounds(0.0, 10.0, 0.0, 10.0), isTrue);
      });

      test('returns false for point outside x bounds (too low)', () {
        final point = FusionDataPoint(-1.0, 5.0);
        expect(point.isWithinBounds(0.0, 10.0, 0.0, 10.0), isFalse);
      });

      test('returns false for point outside x bounds (too high)', () {
        final point = FusionDataPoint(11.0, 5.0);
        expect(point.isWithinBounds(0.0, 10.0, 0.0, 10.0), isFalse);
      });

      test('returns false for point outside y bounds (too low)', () {
        final point = FusionDataPoint(5.0, -1.0);
        expect(point.isWithinBounds(0.0, 10.0, 0.0, 10.0), isFalse);
      });

      test('returns false for point outside y bounds (too high)', () {
        final point = FusionDataPoint(5.0, 11.0);
        expect(point.isWithinBounds(0.0, 10.0, 0.0, 10.0), isFalse);
      });
    });

    group('equality', () {
      test('equal points are equal', () {
        final p1 = FusionDataPoint(1.0, 2.0, label: 'test');
        final p2 = FusionDataPoint(1.0, 2.0, label: 'test');
        expect(p1, equals(p2));
      });

      test('points with different x are not equal', () {
        final p1 = FusionDataPoint(1.0, 2.0);
        final p2 = FusionDataPoint(2.0, 2.0);
        expect(p1, isNot(equals(p2)));
      });

      test('points with different y are not equal', () {
        final p1 = FusionDataPoint(1.0, 2.0);
        final p2 = FusionDataPoint(1.0, 3.0);
        expect(p1, isNot(equals(p2)));
      });

      test('points with different labels are not equal', () {
        final p1 = FusionDataPoint(1.0, 2.0, label: 'a');
        final p2 = FusionDataPoint(1.0, 2.0, label: 'b');
        expect(p1, isNot(equals(p2)));
      });

      test('points with different metadata are not equal', () {
        final p1 = FusionDataPoint(1.0, 2.0, metadata: {'a': 1});
        final p2 = FusionDataPoint(1.0, 2.0, metadata: {'a': 2});
        expect(p1, isNot(equals(p2)));
      });

      test('points with equal metadata are equal', () {
        final p1 = FusionDataPoint(1.0, 2.0, metadata: {'a': 1});
        final p2 = FusionDataPoint(1.0, 2.0, metadata: {'a': 1});
        expect(p1, equals(p2));
      });

      test('identical points are equal', () {
        final point = FusionDataPoint(1.0, 2.0);
        // ignore: unrelated_type_equality_checks
        expect(point == point, isTrue);
      });
    });

    group('hashCode', () {
      test('equal points have equal hash codes', () {
        final p1 = FusionDataPoint(1.0, 2.0, label: 'test');
        final p2 = FusionDataPoint(1.0, 2.0, label: 'test');
        expect(p1.hashCode, equals(p2.hashCode));
      });

      test('different points may have different hash codes', () {
        final p1 = FusionDataPoint(1.0, 2.0);
        final p2 = FusionDataPoint(3.0, 4.0);
        // Hash codes can collide, but these specific values shouldn't
        expect(p1.hashCode, isNot(equals(p2.hashCode)));
      });
    });

    group('toString', () {
      test('includes x and y', () {
        final point = FusionDataPoint(1.0, 2.0);
        expect(point.toString(), contains('x: 1.0'));
        expect(point.toString(), contains('y: 2.0'));
      });

      test('includes label when present', () {
        final point = FusionDataPoint(1.0, 2.0, label: 'January');
        expect(point.toString(), contains('label: "January"'));
      });

      test('excludes label when null', () {
        final point = FusionDataPoint(1.0, 2.0);
        expect(point.toString(), isNot(contains('label')));
      });

      test('includes metadata when present', () {
        final point = FusionDataPoint(1.0, 2.0, metadata: {'key': 'value'});
        expect(point.toString(), contains('metadata'));
      });

      test('excludes metadata when null', () {
        final point = FusionDataPoint(1.0, 2.0);
        expect(point.toString(), isNot(contains('metadata')));
      });
    });
  });

  // ===========================================================================
  // FUSION DATA POINT LIST EXTENSIONS
  // ===========================================================================

  group('FusionDataPointListExtensions', () {
    group('minX', () {
      test('returns null for empty list', () {
        final List<FusionDataPoint> points = [];
        expect(points.minX, isNull);
      });

      test('returns correct minimum x', () {
        final points = [
          FusionDataPoint(3.0, 0.0),
          FusionDataPoint(1.0, 0.0),
          FusionDataPoint(2.0, 0.0),
        ];
        expect(points.minX, 1.0);
      });

      test('handles negative values', () {
        final points = [
          FusionDataPoint(-5.0, 0.0),
          FusionDataPoint(1.0, 0.0),
          FusionDataPoint(-2.0, 0.0),
        ];
        expect(points.minX, -5.0);
      });

      test('handles single element', () {
        final points = [FusionDataPoint(5.0, 0.0)];
        expect(points.minX, 5.0);
      });
    });

    group('maxX', () {
      test('returns null for empty list', () {
        final List<FusionDataPoint> points = [];
        expect(points.maxX, isNull);
      });

      test('returns correct maximum x', () {
        final points = [
          FusionDataPoint(3.0, 0.0),
          FusionDataPoint(1.0, 0.0),
          FusionDataPoint(2.0, 0.0),
        ];
        expect(points.maxX, 3.0);
      });

      test('handles negative values', () {
        final points = [
          FusionDataPoint(-5.0, 0.0),
          FusionDataPoint(-1.0, 0.0),
          FusionDataPoint(-2.0, 0.0),
        ];
        expect(points.maxX, -1.0);
      });
    });

    group('minY', () {
      test('returns null for empty list', () {
        final List<FusionDataPoint> points = [];
        expect(points.minY, isNull);
      });

      test('returns correct minimum y', () {
        final points = [
          FusionDataPoint(0.0, 10.0),
          FusionDataPoint(0.0, 5.0),
          FusionDataPoint(0.0, 8.0),
        ];
        expect(points.minY, 5.0);
      });
    });

    group('maxY', () {
      test('returns null for empty list', () {
        final List<FusionDataPoint> points = [];
        expect(points.maxY, isNull);
      });

      test('returns correct maximum y', () {
        final points = [
          FusionDataPoint(0.0, 10.0),
          FusionDataPoint(0.0, 5.0),
          FusionDataPoint(0.0, 8.0),
        ];
        expect(points.maxY, 10.0);
      });
    });

    group('filterByBounds', () {
      test('returns empty list for empty input', () {
        final List<FusionDataPoint> points = [];
        expect(points.filterByBounds(0, 10, 0, 10), isEmpty);
      });

      test('filters points within bounds', () {
        final points = [
          FusionDataPoint(5.0, 5.0),
          FusionDataPoint(15.0, 5.0), // Outside x
          FusionDataPoint(5.0, 15.0), // Outside y
          FusionDataPoint(3.0, 3.0),
        ];
        final filtered = points.filterByBounds(0, 10, 0, 10);
        expect(filtered.length, 2);
        expect(filtered[0].x, 5.0);
        expect(filtered[1].x, 3.0);
      });

      test('includes points on boundary', () {
        final points = [FusionDataPoint(0.0, 0.0), FusionDataPoint(10.0, 10.0)];
        final filtered = points.filterByBounds(0, 10, 0, 10);
        expect(filtered.length, 2);
      });
    });

    group('sortByX', () {
      test('returns empty list for empty input', () {
        final List<FusionDataPoint> points = [];
        expect(points.sortByX(), isEmpty);
      });

      test('sorts points by x ascending', () {
        final points = [
          FusionDataPoint(3.0, 0.0),
          FusionDataPoint(1.0, 0.0),
          FusionDataPoint(2.0, 0.0),
        ];
        final sorted = points.sortByX();
        expect(sorted[0].x, 1.0);
        expect(sorted[1].x, 2.0);
        expect(sorted[2].x, 3.0);
      });

      test('does not modify original list', () {
        final points = [FusionDataPoint(3.0, 0.0), FusionDataPoint(1.0, 0.0)];
        points.sortByX();
        expect(points[0].x, 3.0);
      });
    });

    group('sortByY', () {
      test('returns empty list for empty input', () {
        final List<FusionDataPoint> points = [];
        expect(points.sortByY(), isEmpty);
      });

      test('sorts points by y ascending', () {
        final points = [
          FusionDataPoint(0.0, 30.0),
          FusionDataPoint(0.0, 10.0),
          FusionDataPoint(0.0, 20.0),
        ];
        final sorted = points.sortByY();
        expect(sorted[0].y, 10.0);
        expect(sorted[1].y, 20.0);
        expect(sorted[2].y, 30.0);
      });
    });

    group('averageY', () {
      test('returns null for empty list', () {
        final List<FusionDataPoint> points = [];
        expect(points.averageY, isNull);
      });

      test('calculates correct average', () {
        final points = [
          FusionDataPoint(0.0, 10.0),
          FusionDataPoint(0.0, 20.0),
          FusionDataPoint(0.0, 30.0),
        ];
        expect(points.averageY, 20.0);
      });

      test('handles single element', () {
        final points = [FusionDataPoint(0.0, 15.0)];
        expect(points.averageY, 15.0);
      });
    });

    group('sumY', () {
      test('returns 0 for empty list', () {
        final List<FusionDataPoint> points = [];
        expect(points.sumY, 0.0);
      });

      test('calculates correct sum', () {
        final points = [
          FusionDataPoint(0.0, 10.0),
          FusionDataPoint(0.0, 20.0),
          FusionDataPoint(0.0, 30.0),
        ];
        expect(points.sumY, 60.0);
      });

      test('handles negative values', () {
        final points = [
          FusionDataPoint(0.0, -10.0),
          FusionDataPoint(0.0, 20.0),
        ];
        expect(points.sumY, 10.0);
      });
    });
  });

  // ===========================================================================
  // FUSION DATA POINT HELPER
  // ===========================================================================

  group('FusionDataPointHelper', () {
    group('generate', () {
      test('returns empty list for count <= 0', () {
        expect(
          FusionDataPointHelper.generate(
            count: 0,
            startX: 0,
            endX: 10,
            yValueGenerator: (x) => x,
          ),
          isEmpty,
        );
        expect(
          FusionDataPointHelper.generate(
            count: -1,
            startX: 0,
            endX: 10,
            yValueGenerator: (x) => x,
          ),
          isEmpty,
        );
      });

      test('generates single point for count = 1', () {
        final points = FusionDataPointHelper.generate(
          count: 1,
          startX: 5,
          endX: 10,
          yValueGenerator: (x) => x * 2,
        );
        expect(points.length, 1);
        expect(points[0].x, 5.0);
        expect(points[0].y, 10.0);
      });

      test('generates correct number of points', () {
        final points = FusionDataPointHelper.generate(
          count: 5,
          startX: 0,
          endX: 4,
          yValueGenerator: (x) => x,
        );
        expect(points.length, 5);
      });

      test('generates evenly spaced x values', () {
        final points = FusionDataPointHelper.generate(
          count: 5,
          startX: 0,
          endX: 4,
          yValueGenerator: (x) => 0,
        );
        expect(points[0].x, 0.0);
        expect(points[1].x, 1.0);
        expect(points[2].x, 2.0);
        expect(points[3].x, 3.0);
        expect(points[4].x, 4.0);
      });

      test('applies y value generator', () {
        final points = FusionDataPointHelper.generate(
          count: 3,
          startX: 0,
          endX: 2,
          yValueGenerator: (x) => x * x,
        );
        expect(points[0].y, 0.0);
        expect(points[1].y, 1.0);
        expect(points[2].y, 4.0);
      });

      test('applies label generator when provided', () {
        final points = FusionDataPointHelper.generate(
          count: 3,
          startX: 0,
          endX: 2,
          yValueGenerator: (x) => x,
          labelGenerator: (x) => 'Label ${x.toInt()}',
        );
        expect(points[0].label, 'Label 0');
        expect(points[1].label, 'Label 1');
        expect(points[2].label, 'Label 2');
      });
    });

    group('fromLists', () {
      test('creates points from x and y lists', () {
        final points = FusionDataPointHelper.fromLists(
          [0.0, 1.0, 2.0],
          [10.0, 20.0, 30.0],
        );
        expect(points.length, 3);
        expect(points[0].x, 0.0);
        expect(points[0].y, 10.0);
        expect(points[2].x, 2.0);
        expect(points[2].y, 30.0);
      });

      test('includes labels when provided', () {
        final points = FusionDataPointHelper.fromLists(
          [0.0, 1.0],
          [10.0, 20.0],
          labels: ['A', 'B'],
        );
        expect(points[0].label, 'A');
        expect(points[1].label, 'B');
      });

      test('handles empty lists', () {
        final points = FusionDataPointHelper.fromLists([], []);
        expect(points, isEmpty);
      });
    });

    group('fromMap', () {
      test('creates points from map', () {
        final points = FusionDataPointHelper.fromMap({
          0.0: 10.0,
          1.0: 20.0,
          2.0: 30.0,
        });
        expect(points.length, 3);
        // Map order may vary, so check that all points are present
        final xValues = points.map((p) => p.x).toSet();
        expect(xValues, containsAll([0.0, 1.0, 2.0]));
      });

      test('handles empty map', () {
        final points = FusionDataPointHelper.fromMap({});
        expect(points, isEmpty);
      });
    });

    group('random', () {
      test('generates correct count', () {
        final points = FusionDataPointHelper.random(count: 10);
        expect(points.length, 10);
      });

      test('respects x bounds', () {
        final points = FusionDataPointHelper.random(
          count: 50,
          minX: 5,
          maxX: 15,
        );
        for (final point in points) {
          expect(point.x, greaterThanOrEqualTo(5.0));
          expect(point.x, lessThanOrEqualTo(15.0));
        }
      });

      test('respects y bounds', () {
        final points = FusionDataPointHelper.random(
          count: 50,
          minY: 20,
          maxY: 50,
        );
        for (final point in points) {
          expect(point.y, greaterThanOrEqualTo(20.0));
          expect(point.y, lessThanOrEqualTo(50.0));
        }
      });

      test('produces reproducible results with seed', () {
        final points1 = FusionDataPointHelper.random(count: 5, seed: 42);
        final points2 = FusionDataPointHelper.random(count: 5, seed: 42);

        for (int i = 0; i < 5; i++) {
          expect(points1[i].x, points2[i].x);
          expect(points1[i].y, points2[i].y);
        }
      });

      test('produces different results with different seeds', () {
        final points1 = FusionDataPointHelper.random(count: 5, seed: 42);
        final points2 = FusionDataPointHelper.random(count: 5, seed: 43);

        // At least one y value should differ
        bool foundDifference = false;
        for (int i = 0; i < 5; i++) {
          if (points1[i].y != points2[i].y) {
            foundDifference = true;
            break;
          }
        }
        expect(foundDifference, isTrue);
      });
    });
  });
}

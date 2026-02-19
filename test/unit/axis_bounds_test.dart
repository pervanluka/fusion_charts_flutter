import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/models/axis_bounds.dart';

void main() {
  // ===========================================================================
  // AXIS BOUNDS CLASS
  // ===========================================================================

  group('AxisBounds', () {
    group('constructor', () {
      test('creates bounds with required parameters', () {
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);

        expect(bounds.min, 0);
        expect(bounds.max, 100);
        expect(bounds.interval, 20);
        expect(bounds.decimalPlaces, 2);
        expect(bounds.minorTickInterval, isNull);
        expect(bounds.padding, 0.0);
      });

      test('creates bounds with all parameters', () {
        final bounds = AxisBounds(
          min: 0,
          max: 100,
          interval: 20,
          decimalPlaces: 1,
          minorTickInterval: 5,
          padding: 0.1,
        );

        expect(bounds.decimalPlaces, 1);
        expect(bounds.minorTickInterval, 5);
        expect(bounds.padding, 0.1);
      });

      test('handles negative min/max', () {
        final bounds = AxisBounds(min: -100, max: -10, interval: 10);

        expect(bounds.min, -100);
        expect(bounds.max, -10);
      });

      test('handles zero range (min equals max)', () {
        final bounds = AxisBounds(min: 50, max: 50, interval: 1);

        expect(bounds.range, 0);
      });
    });

    group('fromDataRange factory', () {
      test('creates bounds from simple data range', () {
        final bounds = AxisBounds.fromDataRange(dataMin: 0, dataMax: 100);

        expect(bounds.min, lessThanOrEqualTo(0));
        expect(bounds.max, greaterThanOrEqualTo(100));
        expect(bounds.interval, greaterThan(0));
      });

      test('creates bounds with nice numbers', () {
        final bounds = AxisBounds.fromDataRange(
          dataMin: 3.2,
          dataMax: 97.8,
          desiredTickCount: 5,
        );

        // Should round to nice numbers like 0 and 100
        expect(bounds.min, lessThanOrEqualTo(3.2));
        expect(bounds.max, greaterThanOrEqualTo(97.8));
      });

      test('handles single value (zero range)', () {
        final bounds = AxisBounds.fromDataRange(dataMin: 50, dataMax: 50);

        expect(bounds.min, lessThan(50));
        expect(bounds.max, greaterThan(50));
        expect(bounds.interval, greaterThan(0));
      });

      test('handles zero value', () {
        final bounds = AxisBounds.fromDataRange(dataMin: 0, dataMax: 0);

        expect(bounds.interval, greaterThan(0));
      });

      test('includes zero when requested', () {
        final bounds = AxisBounds.fromDataRange(
          dataMin: 10,
          dataMax: 100,
          includeZero: true,
        );

        expect(bounds.min, lessThanOrEqualTo(0));
      });

      test('respects padding parameter', () {
        final boundsNoPadding = AxisBounds.fromDataRange(
          dataMin: 0,
          dataMax: 100,
          padding: 0,
        );

        final boundsWithPadding = AxisBounds.fromDataRange(
          dataMin: 0,
          dataMax: 100,
          padding: 0.2,
        );

        expect(boundsWithPadding.range, greaterThan(boundsNoPadding.range));
      });

      test('respects desired tick count', () {
        final fewTicks = AxisBounds.fromDataRange(
          dataMin: 0,
          dataMax: 100,
          desiredTickCount: 3,
        );

        final manyTicks = AxisBounds.fromDataRange(
          dataMin: 0,
          dataMax: 100,
          desiredTickCount: 10,
        );

        expect(fewTicks.interval, greaterThan(manyTicks.interval));
      });
    });

    group('computed properties', () {
      group('range', () {
        test('calculates correct range', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.range, 100);
        });

        test('handles negative range', () {
          final bounds = AxisBounds(min: -100, max: -10, interval: 10);
          expect(bounds.range, 90);
        });
      });

      group('majorTickCount', () {
        test('returns 1 for zero range', () {
          final bounds = AxisBounds(min: 50, max: 50, interval: 1);
          expect(bounds.majorTickCount, 1);
        });

        test('calculates correct count', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.majorTickCount, 6); // 0, 20, 40, 60, 80, 100
        });

        test('calculates count for non-zero start', () {
          final bounds = AxisBounds(min: 10, max: 50, interval: 10);
          expect(bounds.majorTickCount, 5); // 10, 20, 30, 40, 50
        });
      });

      group('minorTicksPerInterval', () {
        test('returns 0 when no minor tick interval', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.minorTicksPerInterval, 0);
        });

        test('calculates correct count with minor interval', () {
          final bounds = AxisBounds(
            min: 0,
            max: 100,
            interval: 20,
            minorTickInterval: 5,
          );
          expect(bounds.minorTicksPerInterval, 3); // 4 divisions - 1
        });
      });

      group('majorTicks', () {
        test('generates correct tick values', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          final ticks = bounds.majorTicks;

          expect(ticks, [0, 20, 40, 60, 80, 100]);
        });

        test('handles negative values', () {
          final bounds = AxisBounds(min: -40, max: 40, interval: 20);
          final ticks = bounds.majorTicks;

          expect(ticks, [-40, -20, 0, 20, 40]);
        });

        test('handles decimal intervals', () {
          final bounds = AxisBounds(min: 0, max: 1, interval: 0.2);
          final ticks = bounds.majorTicks;

          expect(ticks.length, 6); // 0, 0.2, 0.4, 0.6, 0.8, 1.0
          expect(ticks.first, closeTo(0, 0.001));
          expect(ticks.last, closeTo(1.0, 0.001));
        });
      });

      group('minorTicks', () {
        test('returns empty list when no minor interval', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.minorTicks, isEmpty);
        });

        test('generates correct minor ticks', () {
          final bounds = AxisBounds(
            min: 0,
            max: 40,
            interval: 20,
            minorTickInterval: 5,
          );
          final minorTicks = bounds.minorTicks;

          // Between 0 and 20: 5, 10, 15
          // Between 20 and 40: 25, 30, 35
          expect(minorTicks.length, 6);
          expect(minorTicks, contains(closeTo(5, 0.001)));
          expect(minorTicks, contains(closeTo(25, 0.001)));
        });
      });
    });

    group('methods', () {
      group('copyWith', () {
        test('creates copy with modified min', () {
          final original = AxisBounds(min: 0, max: 100, interval: 20);
          final copy = original.copyWith(min: 10);

          expect(copy.min, 10);
          expect(copy.max, 100);
          expect(copy.interval, 20);
        });

        test('creates copy with modified max', () {
          final original = AxisBounds(min: 0, max: 100, interval: 20);
          final copy = original.copyWith(max: 200);

          expect(copy.max, 200);
        });

        test('creates copy with modified interval', () {
          final original = AxisBounds(min: 0, max: 100, interval: 20);
          final copy = original.copyWith(interval: 25);

          expect(copy.interval, 25);
        });

        test('creates unchanged copy when no parameters', () {
          final original = AxisBounds(
            min: 0,
            max: 100,
            interval: 20,
            minorTickInterval: 5,
          );
          final copy = original.copyWith();

          expect(copy, equals(original));
        });
      });

      group('contains', () {
        test('returns true for value within bounds', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.contains(50), isTrue);
        });

        test('returns true for value at min', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.contains(0), isTrue);
        });

        test('returns true for value at max', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.contains(100), isTrue);
        });

        test('returns false for value below min', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.contains(-1), isFalse);
        });

        test('returns false for value above max', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.contains(101), isFalse);
        });
      });

      group('normalize', () {
        test('returns 0 for min value', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.normalize(0), 0);
        });

        test('returns 1 for max value', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.normalize(100), 1);
        });

        test('returns 0.5 for midpoint', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.normalize(50), 0.5);
        });

        test('handles values outside bounds', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.normalize(150), 1.5);
          expect(bounds.normalize(-50), -0.5);
        });

        test('returns 0.5 for zero range', () {
          final bounds = AxisBounds(min: 50, max: 50, interval: 1);
          expect(bounds.normalize(50), 0.5);
        });
      });

      group('denormalize', () {
        test('returns min for 0', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.denormalize(0), 0);
        });

        test('returns max for 1', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.denormalize(1), 100);
        });

        test('returns midpoint for 0.5', () {
          final bounds = AxisBounds(min: 0, max: 100, interval: 20);
          expect(bounds.denormalize(0.5), 50);
        });

        test('is inverse of normalize', () {
          final bounds = AxisBounds(min: 10, max: 90, interval: 20);
          const value = 45.0;
          final normalized = bounds.normalize(value);
          final denormalized = bounds.denormalize(normalized);

          expect(denormalized, closeTo(value, 0.001));
        });
      });
    });

    group('equality', () {
      test('equal bounds are equal', () {
        final b1 = AxisBounds(min: 0, max: 100, interval: 20);
        final b2 = AxisBounds(min: 0, max: 100, interval: 20);

        expect(b1, equals(b2));
      });

      test('bounds with different min are not equal', () {
        final b1 = AxisBounds(min: 0, max: 100, interval: 20);
        final b2 = AxisBounds(min: 10, max: 100, interval: 20);

        expect(b1, isNot(equals(b2)));
      });

      test('bounds with different max are not equal', () {
        final b1 = AxisBounds(min: 0, max: 100, interval: 20);
        final b2 = AxisBounds(min: 0, max: 200, interval: 20);

        expect(b1, isNot(equals(b2)));
      });

      test('bounds with different interval are not equal', () {
        final b1 = AxisBounds(min: 0, max: 100, interval: 20);
        final b2 = AxisBounds(min: 0, max: 100, interval: 25);

        expect(b1, isNot(equals(b2)));
      });

      test('identical bounds are equal', () {
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);
        expect(bounds == bounds, isTrue);
      });
    });

    group('hashCode', () {
      test('equal bounds have equal hash codes', () {
        final b1 = AxisBounds(min: 0, max: 100, interval: 20);
        final b2 = AxisBounds(min: 0, max: 100, interval: 20);

        expect(b1.hashCode, equals(b2.hashCode));
      });
    });

    group('toString', () {
      test('includes min, max, interval', () {
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);
        final str = bounds.toString();

        expect(str, contains('min: 0'));
        expect(str, contains('max: 100'));
        expect(str, contains('interval: 20'));
      });

      test('includes tick count', () {
        final bounds = AxisBounds(min: 0, max: 100, interval: 20);
        final str = bounds.toString();

        expect(str, contains('ticks: 6'));
      });
    });
  });
}

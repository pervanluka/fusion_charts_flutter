import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/enums/chart_range_padding.dart';
import 'package:fusion_charts_flutter/src/utils/axis_calculator.dart';

void main() {
  // ===========================================================================
  // AXIS CALCULATOR CLASS
  // ===========================================================================

  group('AxisCalculator', () {
    // =========================================================================
    // log10
    // =========================================================================

    group('log10', () {
      test('returns correct log base 10 for powers of 10', () {
        expect(AxisCalculator.log10(1), closeTo(0, 1e-10));
        expect(AxisCalculator.log10(10), closeTo(1, 1e-10));
        expect(AxisCalculator.log10(100), closeTo(2, 1e-10));
        expect(AxisCalculator.log10(1000), closeTo(3, 1e-10));
        expect(AxisCalculator.log10(1e6), closeTo(6, 1e-10));
      });

      test('returns correct log base 10 for fractional powers', () {
        expect(AxisCalculator.log10(0.1), closeTo(-1, 1e-10));
        expect(AxisCalculator.log10(0.01), closeTo(-2, 1e-10));
        expect(AxisCalculator.log10(0.001), closeTo(-3, 1e-10));
      });

      test('returns correct log base 10 for arbitrary values', () {
        expect(
          AxisCalculator.log10(2),
          closeTo(math.log(2) / math.ln10, 1e-10),
        );
        expect(
          AxisCalculator.log10(50),
          closeTo(math.log(50) / math.ln10, 1e-10),
        );
        expect(
          AxisCalculator.log10(500),
          closeTo(math.log(500) / math.ln10, 1e-10),
        );
      });

      test('handles very small positive values', () {
        expect(AxisCalculator.log10(1e-10), closeTo(-10, 1e-10));
        expect(AxisCalculator.log10(1e-15), closeTo(-15, 1e-10));
      });

      test('handles very large values', () {
        expect(AxisCalculator.log10(1e10), closeTo(10, 1e-10));
        expect(AxisCalculator.log10(1e15), closeTo(15, 1e-10));
      });
    });

    // =========================================================================
    // calculateNiceInterval
    // =========================================================================

    group('calculateNiceInterval', () {
      group('standard ranges', () {
        test('returns nice interval for typical range 0-100', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 100, 5);

          // Should be a nice number like 20
          expect(interval, greaterThan(0));
          expect([10.0, 20.0, 25.0, 50.0], contains(interval));
        });

        test('returns nice interval for range 0-1000', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 1000, 5);

          expect(interval, greaterThan(0));
          expect([100.0, 200.0, 250.0, 500.0], contains(interval));
        });

        test('returns nice interval for range 0-50', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 50, 5);

          expect(interval, greaterThan(0));
          expect([5.0, 10.0, 20.0], contains(interval));
        });

        test('respects desired interval count', () {
          final fewIntervals = AxisCalculator.calculateNiceInterval(0, 100, 3);
          final manyIntervals = AxisCalculator.calculateNiceInterval(
            0,
            100,
            10,
          );

          expect(fewIntervals, greaterThan(manyIntervals));
        });
      });

      group('zero range handling', () {
        test('handles zero range with both values at zero', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 0, 5);

          expect(interval, greaterThan(0));
          expect(interval, closeTo(0.2, 1e-10));
        });

        test('handles zero range with equal positive values', () {
          final interval = AxisCalculator.calculateNiceInterval(50, 50, 5);

          expect(interval, greaterThan(0));
          expect(interval.isFinite, isTrue);
        });

        test('handles zero range with equal negative values', () {
          final interval = AxisCalculator.calculateNiceInterval(-50, -50, 5);

          expect(interval, greaterThan(0));
          expect(interval.isFinite, isTrue);
        });

        test('handles near-zero range (epsilon difference)', () {
          final interval = AxisCalculator.calculateNiceInterval(
            100,
            100 + 1e-12,
            5,
          );

          expect(interval, greaterThan(0));
          expect(interval.isFinite, isTrue);
        });
      });

      group('tiny ranges (< 0.001)', () {
        test('handles range 0 to 0.0005', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 0.0005, 5);

          expect(interval, greaterThan(0));
          expect(interval, lessThan(0.001));
          expect(interval.isFinite, isTrue);
        });

        test('handles range 0.0001 to 0.0003', () {
          final interval = AxisCalculator.calculateNiceInterval(
            0.0001,
            0.0003,
            5,
          );

          expect(interval, greaterThan(0));
          expect(interval, lessThanOrEqualTo(0.0002));
        });

        test('handles very tiny range 1e-6 to 2e-6', () {
          final interval = AxisCalculator.calculateNiceInterval(1e-6, 2e-6, 5);

          expect(interval, greaterThan(0));
          expect(interval, lessThan(1e-5));
        });

        test('handles scientific notation tiny ranges', () {
          final interval = AxisCalculator.calculateNiceInterval(1e-9, 5e-9, 5);

          expect(interval, greaterThan(0));
          expect(interval, lessThan(1e-8));
        });
      });

      group('large ranges (> 1e9)', () {
        test('handles range 0 to 5e9', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 5e9, 5);

          expect(interval, greaterThan(0));
          expect(interval, greaterThanOrEqualTo(1e8));
          expect(interval.isFinite, isTrue);
        });

        test('handles range 1e10 to 5e10', () {
          final interval = AxisCalculator.calculateNiceInterval(1e10, 5e10, 5);

          expect(interval, greaterThan(0));
          expect(interval.isFinite, isTrue);
        });

        test('handles extremely large range 1e12 to 1e13', () {
          final interval = AxisCalculator.calculateNiceInterval(1e12, 1e13, 5);

          expect(interval, greaterThan(0));
          expect(interval.isFinite, isTrue);
        });
      });

      group('negative values', () {
        test('handles negative range -100 to 0', () {
          final interval = AxisCalculator.calculateNiceInterval(-100, 0, 5);

          expect(interval, greaterThan(0));
          expect([10.0, 20.0, 25.0, 50.0], contains(interval));
        });

        test('handles range spanning negative to positive', () {
          final interval = AxisCalculator.calculateNiceInterval(-50, 50, 5);

          expect(interval, greaterThan(0));
          expect([10.0, 20.0, 25.0, 50.0], contains(interval));
        });

        test('handles entirely negative range', () {
          final interval = AxisCalculator.calculateNiceInterval(-1000, -100, 5);

          expect(interval, greaterThan(0));
          expect(interval.isFinite, isTrue);
        });
      });

      group('edge cases', () {
        test('handles inverted min/max (treats as absolute range)', () {
          final interval1 = AxisCalculator.calculateNiceInterval(0, 100, 5);
          final interval2 = AxisCalculator.calculateNiceInterval(100, 0, 5);

          // Uses abs(), so should be same
          expect(interval1, interval2);
        });

        test('handles single desired interval', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 100, 1);

          expect(interval, greaterThanOrEqualTo(100));
        });

        test('handles many desired intervals', () {
          final interval = AxisCalculator.calculateNiceInterval(0, 100, 20);

          expect(interval, lessThanOrEqualTo(10));
        });
      });
    });

    // =========================================================================
    // calculateNiceBounds
    // =========================================================================

    group('calculateNiceBounds', () {
      group('ChartRangePadding.none', () {
        test('returns exact data bounds', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            10,
            90,
            padding: ChartRangePadding.none,
          );

          expect(bounds.min, 10);
          expect(bounds.max, 90);
        });

        test('preserves bounds with decimal values', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            3.7,
            47.3,
            padding: ChartRangePadding.none,
          );

          expect(bounds.min, 3.7);
          expect(bounds.max, 47.3);
        });

        test('preserves negative bounds', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            -80,
            -20,
            padding: ChartRangePadding.none,
          );

          expect(bounds.min, -80);
          expect(bounds.max, -20);
        });
      });

      group('ChartRangePadding.normal', () {
        test('rounds down min and rounds up max to interval', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            3,
            97,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.min, lessThanOrEqualTo(3));
          expect(bounds.max, greaterThanOrEqualTo(97));
          // Min should be on interval boundary
          expect((bounds.min % bounds.interval).abs(), lessThan(1e-10));
        });

        test('handles values already on interval boundaries', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.min, 0);
          expect(bounds.max, greaterThanOrEqualTo(100));
        });
      });

      group('ChartRangePadding.round', () {
        test('rounds to nice numbers', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            3.7,
            47.3,
            padding: ChartRangePadding.round,
          );

          expect(bounds.min, lessThanOrEqualTo(3.7));
          expect(bounds.max, greaterThanOrEqualTo(47.3));
        });

        test('produces clean round numbers for typical data', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            12,
            88,
            padding: ChartRangePadding.round,
          );

          expect(bounds.min, lessThanOrEqualTo(12));
          expect(bounds.max, greaterThanOrEqualTo(88));
        });
      });

      group('ChartRangePadding.additional', () {
        test('adds one interval of padding on each side', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            10,
            90,
            padding: ChartRangePadding.additional,
          );

          // Should have padding beyond rounded bounds
          expect(bounds.min, lessThan(10));
          expect(bounds.max, greaterThan(90));
        });

        test('interval padding is applied correctly', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            desiredIntervals: 5,
            padding: ChartRangePadding.additional,
          );

          // With interval, min should be at least one interval below 0
          expect(bounds.min, lessThan(0));
          // Max should be at least one interval above rounded max
          expect(bounds.max, greaterThan(100));
        });
      });

      group('ChartRangePadding.auto', () {
        test('starts from zero for positive data', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            10,
            90,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, 0);
          expect(bounds.max, greaterThanOrEqualTo(90));
        });

        test('uses round padding for large ranges (> 1000)', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            1200,
            8500,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThanOrEqualTo(1200));
          expect(bounds.max, greaterThanOrEqualTo(8500));
        });

        test('handles negative data appropriately', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            -80,
            -20,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThanOrEqualTo(-80));
          expect(bounds.max, greaterThanOrEqualTo(-20));
        });

        test('handles mixed positive/negative data', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            -50,
            50,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThanOrEqualTo(-50));
          expect(bounds.max, greaterThanOrEqualTo(50));
        });
      });

      group('zero range handling', () {
        test('handles both values at zero', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            0,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThan(0));
          expect(bounds.max, greaterThan(0));
          expect(bounds.interval, greaterThan(0));
        });

        test('handles equal positive values', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            50,
            50,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThan(50));
          expect(bounds.max, greaterThan(50));
          expect(bounds.interval, greaterThan(0));
        });

        test('handles equal negative values', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            -50,
            -50,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThan(-50));
          expect(bounds.max, greaterThan(-50));
          expect(bounds.interval, greaterThan(0));
        });

        test('handles equal small values (< 1)', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0.5,
            0.5,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThan(0.5));
          expect(bounds.max, greaterThan(0.5));
          expect(bounds.interval, greaterThan(0));
        });

        test('handles equal large values (> 100)', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            5000,
            5000,
            padding: ChartRangePadding.auto,
          );

          expect(bounds.min, lessThan(5000));
          expect(bounds.max, greaterThan(5000));
          expect(bounds.interval, greaterThan(0));
        });
      });

      group('tiny ranges (< 0.001)', () {
        test('handles tiny positive range', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0.0001,
            0.0005,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.min, lessThanOrEqualTo(0.0001));
          expect(bounds.max, greaterThanOrEqualTo(0.0005));
          expect(bounds.interval, greaterThan(0));
          expect(bounds.interval, lessThan(0.001));
        });

        test('handles tiny range with scientific notation', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            1e-6,
            5e-6,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.min, lessThanOrEqualTo(1e-6));
          expect(bounds.max, greaterThanOrEqualTo(5e-6));
          expect(bounds.interval, greaterThan(0));
        });
      });

      group('large ranges (> 1e9)', () {
        test('handles large positive range', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            1e9,
            5e9,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.min, lessThanOrEqualTo(1e9));
          expect(bounds.max, greaterThanOrEqualTo(5e9));
          expect(bounds.interval, greaterThan(0));
          expect(bounds.interval.isFinite, isTrue);
        });

        test('handles extremely large range', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            1e12,
            1e13,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.min.isFinite, isTrue);
          expect(bounds.max.isFinite, isTrue);
          expect(bounds.interval.isFinite, isTrue);
        });
      });

      group('custom interval', () {
        test('uses provided interval', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            interval: 25,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.interval, 25);
        });

        test('respects custom interval with padding', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            interval: 15,
            padding: ChartRangePadding.additional,
          );

          expect(bounds.interval, 15);
          expect(bounds.min, -15);
        });
      });

      group('desired intervals', () {
        test('produces reasonable interval count', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            desiredIntervals: 5,
            padding: ChartRangePadding.normal,
          );

          final actualIntervals = (bounds.max - bounds.min) / bounds.interval;
          expect(actualIntervals, closeTo(5, 3)); // Allow some variation
        });

        test('handles small desired interval count', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            desiredIntervals: 2,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.interval, greaterThan(20));
        });

        test('handles large desired interval count', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            desiredIntervals: 20,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.interval, lessThanOrEqualTo(10));
        });
      });

      group('decimal places calculation', () {
        test('returns 0 decimal places for large intervals', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            100,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.decimalPlaces, 0);
        });

        test('returns appropriate decimal places for small intervals', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            1,
            desiredIntervals: 5,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.decimalPlaces, greaterThanOrEqualTo(1));
        });

        test('returns appropriate decimal places for tiny intervals', () {
          final bounds = AxisCalculator.calculateNiceBounds(
            0,
            0.01,
            desiredIntervals: 5,
            padding: ChartRangePadding.normal,
          );

          expect(bounds.decimalPlaces, greaterThanOrEqualTo(2));
        });
      });
    });

    // =========================================================================
    // generateLabelValues
    // =========================================================================

    group('generateLabelValues', () {
      group('standard cases', () {
        test('generates correct labels for 0 to 100 with interval 20', () {
          final labels = AxisCalculator.generateLabelValues(0, 100, 20);

          expect(labels, [0, 20, 40, 60, 80, 100]);
        });

        test('generates correct labels for 0 to 50 with interval 10', () {
          final labels = AxisCalculator.generateLabelValues(0, 50, 10);

          expect(labels, [0, 10, 20, 30, 40, 50]);
        });

        test('generates correct labels for non-zero start', () {
          final labels = AxisCalculator.generateLabelValues(10, 50, 10);

          expect(labels, [10, 20, 30, 40, 50]);
        });
      });

      group('negative values', () {
        test('generates labels for negative range', () {
          final labels = AxisCalculator.generateLabelValues(-100, -20, 20);

          expect(labels, [-100, -80, -60, -40, -20]);
        });

        test('generates labels spanning negative to positive', () {
          final labels = AxisCalculator.generateLabelValues(-40, 40, 20);

          expect(labels, [-40, -20, 0, 20, 40]);
        });
      });

      group('decimal intervals', () {
        test('generates labels with decimal interval', () {
          final labels = AxisCalculator.generateLabelValues(0, 1, 0.2);

          expect(labels.length, 6);
          expect(labels.first, closeTo(0, 1e-10));
          expect(labels.last, closeTo(1.0, 1e-10));
        });

        test('handles small decimal interval', () {
          final labels = AxisCalculator.generateLabelValues(0, 0.01, 0.002);

          expect(labels.length, 6);
          expect(labels.first, closeTo(0, 1e-10));
          expect(labels.last, closeTo(0.01, 1e-10));
        });
      });

      group('edge cases', () {
        test('includes max value when not exactly on interval', () {
          final labels = AxisCalculator.generateLabelValues(0, 95, 20);

          expect(labels.last, closeTo(95, 1e-10));
        });

        test('handles single step', () {
          final labels = AxisCalculator.generateLabelValues(0, 10, 10);

          expect(labels, [0, 10]);
        });

        test('handles zero range (min equals max)', () {
          final labels = AxisCalculator.generateLabelValues(50, 50, 10);

          expect(labels, isNotEmpty);
          expect(labels.first, 50);
        });

        test('cleans floating point errors', () {
          // 0.1 + 0.2 would typically be 0.30000000000000004
          final labels = AxisCalculator.generateLabelValues(0, 0.3, 0.1);

          // All values should be clean
          for (final label in labels) {
            expect(label.toString().length, lessThan(15));
          }
        });
      });

      group('large values', () {
        test('handles large range with large interval', () {
          final labels = AxisCalculator.generateLabelValues(0, 1e9, 2e8);

          expect(labels.length, greaterThan(1));
          expect(labels.first, 0);
          expect(labels.last, closeTo(1e9, 1e-5));
        });
      });
    });

    // =========================================================================
    // generateMinorTicks
    // =========================================================================

    group('generateMinorTicks', () {
      group('standard cases', () {
        test('generates correct minor ticks between major ticks', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 100, 20, 3);

          // Between 0-20: 5, 10, 15
          // Between 20-40: 25, 30, 35
          // etc.
          expect(minorTicks, isNotEmpty);
          expect(minorTicks, contains(closeTo(5, 1e-10)));
          expect(minorTicks, contains(closeTo(15, 1e-10)));
          expect(minorTicks, contains(closeTo(25, 1e-10)));
        });

        test('does not include major tick positions', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 100, 20, 3);

          // Should not contain 0, 20, 40, 60, 80, 100
          for (final tick in minorTicks) {
            final nearestMajor = (tick / 20).round() * 20;
            expect((tick - nearestMajor).abs(), greaterThan(1e-10));
          }
        });

        test('generates 1 minor tick per interval', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 40, 20, 1);

          // Between 0-20: one tick at 10
          // Between 20-40: one tick at 30
          expect(minorTicks, contains(closeTo(10, 1e-10)));
          expect(minorTicks, contains(closeTo(30, 1e-10)));
        });

        test('generates 4 minor ticks per interval', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 20, 20, 4);

          // Between 0-20: 4, 8, 12, 16
          expect(minorTicks.length, 4);
        });
      });

      group('edge cases', () {
        test('returns empty list when minorTicksPerInterval is 0', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 100, 20, 0);

          expect(minorTicks, isEmpty);
        });

        test('handles negative range', () {
          final minorTicks = AxisCalculator.generateMinorTicks(-100, 0, 20, 3);

          expect(minorTicks, isNotEmpty);
          // All ticks should be negative (except possibly near 0)
          for (final tick in minorTicks) {
            expect(tick, lessThan(0.001));
          }
        });

        test('handles decimal intervals', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 1, 0.2, 1);

          expect(minorTicks, isNotEmpty);
          // Minor ticks at 0.1, 0.3, 0.5, 0.7, 0.9
          expect(minorTicks, contains(closeTo(0.1, 1e-10)));
        });
      });

      group('boundary conditions', () {
        test('does not include ticks at or beyond max', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 100, 20, 3);

          for (final tick in minorTicks) {
            expect(tick, lessThan(100));
          }
        });

        test('does not include ticks at or before min', () {
          final minorTicks = AxisCalculator.generateMinorTicks(0, 100, 20, 3);

          for (final tick in minorTicks) {
            expect(tick, greaterThan(0));
          }
        });
      });
    });

    // =========================================================================
    // getNextNiceNumber
    // =========================================================================

    group('getNextNiceNumber', () {
      group('standard cases', () {
        test('returns 1 for values less than 1', () {
          expect(AxisCalculator.getNextNiceNumber(0.5), closeTo(1, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(0.9), closeTo(1, 1e-10));
        });

        test('returns 2 for values between 1 and 2', () {
          expect(AxisCalculator.getNextNiceNumber(1.0), closeTo(2, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(1.5), closeTo(2, 1e-10));
        });

        test('returns 5 for values between 2 and 5', () {
          expect(AxisCalculator.getNextNiceNumber(2.0), closeTo(5, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(3.0), closeTo(5, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(4.0), closeTo(5, 1e-10));
        });

        test('returns 10 for values between 5 and 10', () {
          expect(AxisCalculator.getNextNiceNumber(5.0), closeTo(10, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(7.0), closeTo(10, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(9.0), closeTo(10, 1e-10));
        });
      });

      group('magnitude handling', () {
        test('handles tens', () {
          expect(AxisCalculator.getNextNiceNumber(15), closeTo(20, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(35), closeTo(50, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(75), closeTo(100, 1e-10));
        });

        test('handles hundreds', () {
          expect(AxisCalculator.getNextNiceNumber(150), closeTo(200, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(350), closeTo(500, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(750), closeTo(1000, 1e-10));
        });

        test('handles decimals', () {
          expect(AxisCalculator.getNextNiceNumber(0.15), closeTo(0.2, 1e-10));
          expect(AxisCalculator.getNextNiceNumber(0.035), closeTo(0.05, 1e-10));
        });
      });

      group('edge cases', () {
        test('handles zero', () {
          expect(AxisCalculator.getNextNiceNumber(0), closeTo(1.0, 1e-10));
        });

        test('handles very small values near zero', () {
          expect(AxisCalculator.getNextNiceNumber(1e-12), closeTo(1.0, 1e-10));
        });

        test('handles large values', () {
          final result = AxisCalculator.getNextNiceNumber(1.5e9);

          expect(result, closeTo(2e9, 1e5));
        });
      });
    });

    // =========================================================================
    // getPreviousNiceNumber
    // =========================================================================

    group('getPreviousNiceNumber', () {
      group('standard cases', () {
        test('returns 0.5 for value 1', () {
          expect(
            AxisCalculator.getPreviousNiceNumber(1.0),
            closeTo(0.5, 1e-10),
          );
        });

        test('returns 1 for values between 1 and 2', () {
          expect(AxisCalculator.getPreviousNiceNumber(1.5), closeTo(1, 1e-10));
          expect(AxisCalculator.getPreviousNiceNumber(2.0), closeTo(1, 1e-10));
        });

        test('returns 2 for values between 2 and 5', () {
          expect(AxisCalculator.getPreviousNiceNumber(3.0), closeTo(2, 1e-10));
          expect(AxisCalculator.getPreviousNiceNumber(5.0), closeTo(2, 1e-10));
        });

        test('returns 5 for values between 5 and 10', () {
          expect(AxisCalculator.getPreviousNiceNumber(7.0), closeTo(5, 1e-10));
          expect(AxisCalculator.getPreviousNiceNumber(10.0), closeTo(5, 1e-10));
        });
      });

      group('magnitude handling', () {
        test('handles tens', () {
          expect(AxisCalculator.getPreviousNiceNumber(15), closeTo(10, 1e-10));
          expect(AxisCalculator.getPreviousNiceNumber(35), closeTo(20, 1e-10));
          expect(AxisCalculator.getPreviousNiceNumber(75), closeTo(50, 1e-10));
        });

        test('handles hundreds', () {
          expect(
            AxisCalculator.getPreviousNiceNumber(150),
            closeTo(100, 1e-10),
          );
          expect(
            AxisCalculator.getPreviousNiceNumber(350),
            closeTo(200, 1e-10),
          );
          expect(
            AxisCalculator.getPreviousNiceNumber(750),
            closeTo(500, 1e-10),
          );
        });

        test('handles decimals', () {
          expect(
            AxisCalculator.getPreviousNiceNumber(0.15),
            closeTo(0.1, 1e-10),
          );
          expect(
            AxisCalculator.getPreviousNiceNumber(0.35),
            closeTo(0.2, 1e-10),
          );
        });
      });

      group('edge cases', () {
        test('handles zero', () {
          expect(AxisCalculator.getPreviousNiceNumber(0), closeTo(-1.0, 1e-10));
        });

        test('handles very small values near zero', () {
          expect(
            AxisCalculator.getPreviousNiceNumber(1e-12),
            closeTo(-1.0, 1e-10),
          );
        });

        test('handles large values', () {
          final result = AxisCalculator.getPreviousNiceNumber(1.5e9);

          expect(result, closeTo(1e9, 1e5));
        });
      });
    });

    // =========================================================================
    // Integration tests
    // =========================================================================

    group('integration tests', () {
      test('calculateNiceBounds and generateLabelValues work together', () {
        final bounds = AxisCalculator.calculateNiceBounds(
          3.7,
          97.3,
          desiredIntervals: 5,
          padding: ChartRangePadding.normal,
        );

        final labels = AxisCalculator.generateLabelValues(
          bounds.min,
          bounds.max,
          bounds.interval,
        );

        // All labels should be within bounds
        for (final label in labels) {
          expect(label, greaterThanOrEqualTo(bounds.min - 1e-10));
          expect(label, lessThanOrEqualTo(bounds.max + 1e-10));
        }

        // Labels should be evenly spaced
        for (int i = 1; i < labels.length; i++) {
          final diff = labels[i] - labels[i - 1];
          expect(diff, closeTo(bounds.interval, 1e-10));
        }
      });

      test('bounds work correctly for all padding types', () {
        const dataMin = 15.0;
        const dataMax = 85.0;

        for (final padding in ChartRangePadding.values) {
          final bounds = AxisCalculator.calculateNiceBounds(
            dataMin,
            dataMax,
            padding: padding,
          );

          expect(
            bounds.min,
            lessThanOrEqualTo(dataMin),
            reason: 'min should be <= dataMin for $padding',
          );
          expect(
            bounds.max,
            greaterThanOrEqualTo(dataMax),
            reason: 'max should be >= dataMax for $padding',
          );
          expect(
            bounds.interval,
            greaterThan(0),
            reason: 'interval should be positive for $padding',
          );
          expect(
            bounds.decimalPlaces,
            greaterThanOrEqualTo(0),
            reason: 'decimalPlaces should be non-negative for $padding',
          );
        }
      });

      test('minor ticks complement major ticks correctly', () {
        final bounds = AxisCalculator.calculateNiceBounds(
          0,
          100,
          desiredIntervals: 5,
          padding: ChartRangePadding.normal,
        );

        final majorLabels = AxisCalculator.generateLabelValues(
          bounds.min,
          bounds.max,
          bounds.interval,
        );

        final minorTicks = AxisCalculator.generateMinorTicks(
          bounds.min,
          bounds.max,
          bounds.interval,
          4,
        );

        // No minor tick should equal a major tick
        for (final minor in minorTicks) {
          for (final major in majorLabels) {
            expect(
              (minor - major).abs(),
              greaterThan(1e-10),
              reason: 'Minor tick $minor should not equal major tick $major',
            );
          }
        }
      });

      test('handles realistic chart data scenario', () {
        // Simulating stock price data
        const prices = [142.50, 143.20, 141.80, 144.00, 143.50, 142.00, 145.30];
        final dataMin = prices.reduce(math.min);
        final dataMax = prices.reduce(math.max);

        final bounds = AxisCalculator.calculateNiceBounds(
          dataMin,
          dataMax,
          desiredIntervals: 5,
          padding: ChartRangePadding.normal,
        );

        expect(bounds.min, lessThanOrEqualTo(dataMin));
        expect(bounds.max, greaterThanOrEqualTo(dataMax));
        expect(bounds.interval, greaterThan(0));

        final labels = AxisCalculator.generateLabelValues(
          bounds.min,
          bounds.max,
          bounds.interval,
        );

        expect(labels.length, greaterThanOrEqualTo(2));
      });

      test('handles scientific data with very small values', () {
        // Simulating measurements in micrometers
        const dataMin = 0.00023;
        const dataMax = 0.00089;

        final bounds = AxisCalculator.calculateNiceBounds(
          dataMin,
          dataMax,
          desiredIntervals: 5,
          padding: ChartRangePadding.normal,
        );

        expect(bounds.min, lessThanOrEqualTo(dataMin));
        expect(bounds.max, greaterThanOrEqualTo(dataMax));
        expect(bounds.interval, greaterThan(0));
        expect(bounds.decimalPlaces, greaterThan(0));

        final labels = AxisCalculator.generateLabelValues(
          bounds.min,
          bounds.max,
          bounds.interval,
        );

        expect(labels.length, greaterThanOrEqualTo(2));
      });

      test('handles financial data with very large values', () {
        // Simulating market cap in billions
        const dataMin = 2.5e11;
        const dataMax = 3.2e12;

        final bounds = AxisCalculator.calculateNiceBounds(
          dataMin,
          dataMax,
          desiredIntervals: 5,
          padding: ChartRangePadding.normal,
        );

        expect(bounds.min.isFinite, isTrue);
        expect(bounds.max.isFinite, isTrue);
        expect(bounds.interval.isFinite, isTrue);
        expect(bounds.min, lessThanOrEqualTo(dataMin));
        expect(bounds.max, greaterThanOrEqualTo(dataMax));

        final labels = AxisCalculator.generateLabelValues(
          bounds.min,
          bounds.max,
          bounds.interval,
        );

        expect(labels.length, greaterThanOrEqualTo(2));
        for (final label in labels) {
          expect(label.isFinite, isTrue);
        }
      });
    });
  });
}

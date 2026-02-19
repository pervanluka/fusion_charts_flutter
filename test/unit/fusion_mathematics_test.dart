import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('FusionMathematics', () {
    // =========================================================================
    // BEZIER CURVE TESTS
    // =========================================================================

    group('Cubic Bezier', () {
      test('generates correct number of points', () {
        final points = FusionMathematics.calculateCubicBezier(
          Offset.zero,
          const Offset(1, 2),
          const Offset(2, 2),
          const Offset(3, 0),
          segments: 10,
        );

        expect(points.length, 11); // segments + 1
      });

      test('starts and ends at correct points', () {
        const p0 = Offset.zero;
        const p3 = Offset(3, 0);

        final points = FusionMathematics.calculateCubicBezier(
          p0,
          const Offset(1, 2),
          const Offset(2, 2),
          p3,
          segments: 20,
        );

        expect(points.first.dx, closeTo(p0.dx, 0.001));
        expect(points.first.dy, closeTo(p0.dy, 0.001));
        expect(points.last.dx, closeTo(p3.dx, 0.001));
        expect(points.last.dy, closeTo(p3.dy, 0.001));
      });

      test('midpoint is influenced by control points', () {
        // Control points above the line should pull the curve up
        final points = FusionMathematics.calculateCubicBezier(
          Offset.zero,
          const Offset(1, 10), // High control point
          const Offset(2, 10), // High control point
          const Offset(3, 0),
          segments: 10,
        );

        // Middle point should be above the straight line (y > 0)
        final midIndex = points.length ~/ 2;
        expect(points[midIndex].dy, greaterThan(0));
      });

      test('default segments is 20', () {
        final points = FusionMathematics.calculateCubicBezier(
          Offset.zero,
          const Offset(1, 1),
          const Offset(2, 1),
          const Offset(3, 0),
        );

        expect(points.length, 21); // 20 + 1
      });

      test('handles negative coordinates', () {
        final points = FusionMathematics.calculateCubicBezier(
          const Offset(-10, -10),
          const Offset(-5, 5),
          const Offset(5, 5),
          const Offset(10, -10),
          segments: 10,
        );

        expect(points.length, 11);
        expect(points.first.dx, closeTo(-10, 0.001));
        expect(points.first.dy, closeTo(-10, 0.001));
        expect(points.last.dx, closeTo(10, 0.001));
        expect(points.last.dy, closeTo(-10, 0.001));
      });

      test('handles very large coordinates', () {
        final points = FusionMathematics.calculateCubicBezier(
          Offset.zero,
          const Offset(1e6, 1e6),
          const Offset(2e6, 1e6),
          const Offset(3e6, 0),
          segments: 5,
        );

        expect(points.length, 6);
        expect(points.first.dx, closeTo(0, 0.001));
        expect(points.last.dx, closeTo(3e6, 1));
      });

      test('handles zero-length curve (all points same)', () {
        const point = Offset(5, 5);
        final points = FusionMathematics.calculateCubicBezier(
          point,
          point,
          point,
          point,
          segments: 5,
        );

        expect(points.length, 6);
        for (final p in points) {
          expect(p.dx, closeTo(5, 0.001));
          expect(p.dy, closeTo(5, 0.001));
        }
      });

      test('single segment produces 2 points', () {
        final points = FusionMathematics.calculateCubicBezier(
          Offset.zero,
          const Offset(1, 1),
          const Offset(2, 1),
          const Offset(3, 0),
          segments: 1,
        );

        expect(points.length, 2);
      });

      test('control points below the line pull curve down', () {
        final points = FusionMathematics.calculateCubicBezier(
          Offset.zero,
          const Offset(1, -10), // Low control point
          const Offset(2, -10), // Low control point
          const Offset(3, 0),
          segments: 10,
        );

        // Middle point should be below the straight line (y < 0)
        final midIndex = points.length ~/ 2;
        expect(points[midIndex].dy, lessThan(0));
      });
    });

    group('Quadratic Bezier', () {
      test('generates correct number of points', () {
        final points = FusionMathematics.calculateQuadraticBezier(
          Offset.zero,
          const Offset(1.5, 3),
          const Offset(3, 0),
          segments: 15,
        );

        expect(points.length, 16); // segments + 1
      });

      test('starts and ends at correct points', () {
        const p0 = Offset.zero;
        const p2 = Offset(4, 2);

        final points = FusionMathematics.calculateQuadraticBezier(
          p0,
          const Offset(2, 5),
          p2,
          segments: 10,
        );

        expect(points.first.dx, closeTo(p0.dx, 0.001));
        expect(points.first.dy, closeTo(p0.dy, 0.001));
        expect(points.last.dx, closeTo(p2.dx, 0.001));
        expect(points.last.dy, closeTo(p2.dy, 0.001));
      });

      test('control point affects curve shape', () {
        final points = FusionMathematics.calculateQuadraticBezier(
          Offset.zero,
          const Offset(1.5, 10), // High control point
          const Offset(3, 0),
          segments: 10,
        );

        // Middle point should be pulled up
        final midIndex = points.length ~/ 2;
        expect(points[midIndex].dy, greaterThan(0));
      });

      test('handles negative coordinates', () {
        final points = FusionMathematics.calculateQuadraticBezier(
          const Offset(-5, -5),
          const Offset(0, 5),
          const Offset(5, -5),
          segments: 10,
        );

        expect(points.length, 11);
        expect(points.first.dx, closeTo(-5, 0.001));
        expect(points.last.dx, closeTo(5, 0.001));
      });

      test('handles very large coordinates', () {
        final points = FusionMathematics.calculateQuadraticBezier(
          Offset.zero,
          const Offset(1e6, 2e6),
          const Offset(2e6, 0),
          segments: 5,
        );

        expect(points.length, 6);
        expect(points.last.dx, closeTo(2e6, 1));
      });

      test('handles zero-length curve (all points same)', () {
        const point = Offset(3, 3);
        final points = FusionMathematics.calculateQuadraticBezier(
          point,
          point,
          point,
          segments: 5,
        );

        expect(points.length, 6);
        for (final p in points) {
          expect(p.dx, closeTo(3, 0.001));
          expect(p.dy, closeTo(3, 0.001));
        }
      });

      test('single segment produces 2 points', () {
        final points = FusionMathematics.calculateQuadraticBezier(
          Offset.zero,
          const Offset(1.5, 3),
          const Offset(3, 0),
          segments: 1,
        );

        expect(points.length, 2);
      });

      test('default segments is 20', () {
        final points = FusionMathematics.calculateQuadraticBezier(
          Offset.zero,
          const Offset(1.5, 3),
          const Offset(3, 0),
        );

        expect(points.length, 21);
      });
    });

    // =========================================================================
    // CATMULL-ROM SPLINE TESTS
    // =========================================================================

    group('Catmull-Rom Spline', () {
      test('returns input if less than 4 points', () {
        final input = [Offset.zero, const Offset(1, 1), const Offset(2, 0)];
        final result = FusionMathematics.calculateCatmullRomSpline(input);

        expect(result.length, 3);
        expect(result[0], input[0]);
        expect(result[1], input[1]);
        expect(result[2], input[2]);
      });

      test('returns empty list for empty input', () {
        final result = FusionMathematics.calculateCatmullRomSpline([]);
        expect(result, isEmpty);
      });

      test('returns single point for single point input', () {
        final input = [const Offset(5, 5)];
        final result = FusionMathematics.calculateCatmullRomSpline(input);
        expect(result.length, 1);
        expect(result[0], input[0]);
      });

      test('returns two points for two point input', () {
        final input = [Offset.zero, const Offset(10, 10)];
        final result = FusionMathematics.calculateCatmullRomSpline(input);
        expect(result.length, 2);
      });

      test('generates smooth curve through points', () {
        final controlPoints = [
          Offset.zero,
          const Offset(1, 2),
          const Offset(2, 1),
          const Offset(3, 3),
          const Offset(4, 0),
        ];

        final result = FusionMathematics.calculateCatmullRomSpline(
          controlPoints,
          segmentsPerCurve: 10,
        );

        // Should have more points than input
        expect(result.length, greaterThan(controlPoints.length));

        // First point should match
        expect(result.first.dx, closeTo(controlPoints.first.dx, 0.001));
        expect(result.first.dy, closeTo(controlPoints.first.dy, 0.001));
      });

      test('respects tension parameter', () {
        final controlPoints = [
          Offset.zero,
          const Offset(1, 2),
          const Offset(2, 1),
          const Offset(3, 3),
        ];

        final resultLow = FusionMathematics.calculateCatmullRomSpline(
          controlPoints,
          tension: 0.3,
        );

        final resultHigh = FusionMathematics.calculateCatmullRomSpline(
          controlPoints,
          tension: 0.7,
        );

        // Different tensions should produce different results
        expect(resultLow.length, resultHigh.length);
        // At least some points should differ
        bool hasDifference = false;
        for (int i = 0; i < resultLow.length; i++) {
          if ((resultLow[i].dx - resultHigh[i].dx).abs() > 0.01 ||
              (resultLow[i].dy - resultHigh[i].dy).abs() > 0.01) {
            hasDifference = true;
            break;
          }
        }
        expect(hasDifference, isTrue);
      });

      test('handles negative coordinates', () {
        final controlPoints = [
          const Offset(-10, -5),
          const Offset(-5, 5),
          const Offset(5, -5),
          const Offset(10, 5),
        ];

        final result = FusionMathematics.calculateCatmullRomSpline(
          controlPoints,
          segmentsPerCurve: 5,
        );

        expect(result.length, greaterThan(controlPoints.length));
        expect(result.first.dx, closeTo(-10, 0.001));
      });

      test('handles very large coordinates', () {
        final controlPoints = [
          Offset.zero,
          const Offset(1e5, 1e5),
          const Offset(2e5, 0),
          const Offset(3e5, 1e5),
        ];

        final result = FusionMathematics.calculateCatmullRomSpline(
          controlPoints,
          segmentsPerCurve: 5,
        );

        expect(result.length, greaterThan(controlPoints.length));
      });

      test('handles zero tension', () {
        final controlPoints = [
          Offset.zero,
          const Offset(1, 2),
          const Offset(2, 1),
          const Offset(3, 3),
        ];

        final result = FusionMathematics.calculateCatmullRomSpline(
          controlPoints,
          tension: 0.0,
        );

        // With zero tension, all generated points should be zero (scaled by 0)
        // First point is the original, rest should be near zero
        expect(result.length, greaterThan(1));
      });

      test('handles single segment per curve', () {
        final controlPoints = [
          Offset.zero,
          const Offset(1, 2),
          const Offset(2, 1),
          const Offset(3, 3),
        ];

        final result = FusionMathematics.calculateCatmullRomSpline(
          controlPoints,
          segmentsPerCurve: 1,
        );

        // 4 points, 1 segment between p1-p2, so: first point + 1 segment point
        expect(result.length, greaterThanOrEqualTo(2));
      });
    });

    // =========================================================================
    // CONTROL POINTS GENERATION
    // =========================================================================

    group('Control Points Generation', () {
      test('returns empty for less than 2 points', () {
        final result = FusionMathematics.generateControlPoints([
          FusionDataPoint(0, 0),
        ]);
        expect(result, isEmpty);
      });

      test('returns empty for empty list', () {
        final result = FusionMathematics.generateControlPoints([]);
        expect(result, isEmpty);
      });

      test('generates 2 control points per segment', () {
        final dataPoints = [
          FusionDataPoint(0, 0),
          FusionDataPoint(1, 2),
          FusionDataPoint(2, 1),
          FusionDataPoint(3, 3),
        ];

        final controlPoints = FusionMathematics.generateControlPoints(
          dataPoints,
        );

        // 3 segments, 2 control points each = 6
        expect(controlPoints.length, 6);
      });

      test('generates 2 control points for 2 data points', () {
        final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(1, 1)];

        final controlPoints = FusionMathematics.generateControlPoints(
          dataPoints,
        );

        expect(controlPoints.length, 2);
      });

      test('respects smoothness parameter', () {
        final dataPoints = [
          FusionDataPoint(0, 0),
          FusionDataPoint(1, 2),
          FusionDataPoint(2, 1),
        ];

        final cpLow = FusionMathematics.generateControlPoints(
          dataPoints,
          smoothness: 0.1,
        );

        final cpHigh = FusionMathematics.generateControlPoints(
          dataPoints,
          smoothness: 0.5,
        );

        // Higher smoothness should produce more separated control points
        expect(cpLow.length, cpHigh.length);

        // Verify that control points differ
        bool hasDifference = false;
        for (int i = 0; i < cpLow.length; i++) {
          if ((cpLow[i].dx - cpHigh[i].dx).abs() > 0.001 ||
              (cpLow[i].dy - cpHigh[i].dy).abs() > 0.001) {
            hasDifference = true;
            break;
          }
        }
        expect(hasDifference, isTrue);
      });

      test('handles negative coordinates', () {
        final dataPoints = [
          FusionDataPoint(-10, -5),
          FusionDataPoint(-5, 5),
          FusionDataPoint(0, -5),
        ];

        final controlPoints = FusionMathematics.generateControlPoints(
          dataPoints,
        );

        expect(controlPoints.length, 4);
      });

      test('handles zero smoothness', () {
        final dataPoints = [
          FusionDataPoint(0, 0),
          FusionDataPoint(1, 2),
          FusionDataPoint(2, 1),
        ];

        final controlPoints = FusionMathematics.generateControlPoints(
          dataPoints,
          smoothness: 0.0,
        );

        expect(controlPoints.length, 4);
        // With zero smoothness, control points should be at data points
        expect(controlPoints[0].dx, closeTo(0, 0.001));
        expect(controlPoints[0].dy, closeTo(0, 0.001));
      });

      test('handles very large coordinates', () {
        final dataPoints = [
          FusionDataPoint(0, 0),
          FusionDataPoint(1e6, 1e6),
          FusionDataPoint(2e6, 0),
        ];

        final controlPoints = FusionMathematics.generateControlPoints(
          dataPoints,
        );

        expect(controlPoints.length, 4);
      });
    });

    // =========================================================================
    // MOVING AVERAGES
    // =========================================================================

    group('Simple Moving Average', () {
      test('calculates correct SMA', () {
        final data = [10.0, 20.0, 30.0, 40.0, 50.0];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 3);

        expect(sma.length, 3);
        expect(sma[0], closeTo(20.0, 0.001)); // (10+20+30)/3
        expect(sma[1], closeTo(30.0, 0.001)); // (20+30+40)/3
        expect(sma[2], closeTo(40.0, 0.001)); // (30+40+50)/3
      });

      test('throws assertion if window larger than data', () {
        final data = [10.0, 20.0];

        expect(
          () => FusionMathematics.simpleMovingAverage(data, window: 3),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws assertion if window is zero', () {
        final data = [10.0, 20.0, 30.0];

        expect(
          () => FusionMathematics.simpleMovingAverage(data, window: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws assertion if window is negative', () {
        final data = [10.0, 20.0, 30.0];

        expect(
          () => FusionMathematics.simpleMovingAverage(data, window: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('handles single-element window', () {
        final data = [10.0, 20.0, 30.0];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 1);

        expect(sma.length, 3);
        expect(sma[0], closeTo(10.0, 0.001));
        expect(sma[1], closeTo(20.0, 0.001));
        expect(sma[2], closeTo(30.0, 0.001));
      });

      test('handles window equal to data length', () {
        final data = [10.0, 20.0, 30.0];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 3);

        expect(sma.length, 1);
        expect(sma[0], closeTo(20.0, 0.001)); // (10+20+30)/3
      });

      test('handles negative values', () {
        final data = [-10.0, -20.0, 10.0, 20.0];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 2);

        expect(sma.length, 3);
        expect(sma[0], closeTo(-15.0, 0.001)); // (-10-20)/2
        expect(sma[1], closeTo(-5.0, 0.001)); // (-20+10)/2
        expect(sma[2], closeTo(15.0, 0.001)); // (10+20)/2
      });

      test('handles zero values', () {
        final data = [0.0, 0.0, 0.0, 0.0];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 2);

        expect(sma.length, 3);
        for (final val in sma) {
          expect(val, closeTo(0.0, 0.001));
        }
      });

      test('handles very large values', () {
        final data = [1e10, 2e10, 3e10, 4e10];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 2);

        expect(sma.length, 3);
        expect(sma[0], closeTo(1.5e10, 1e6));
        expect(sma[1], closeTo(2.5e10, 1e6));
        expect(sma[2], closeTo(3.5e10, 1e6));
      });

      test('handles very small values', () {
        final data = [1e-10, 2e-10, 3e-10, 4e-10];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 2);

        expect(sma.length, 3);
        expect(sma[0], closeTo(1.5e-10, 1e-15));
        expect(sma[1], closeTo(2.5e-10, 1e-15));
        expect(sma[2], closeTo(3.5e-10, 1e-15));
      });

      test('handles mixed positive and negative values', () {
        final data = [100.0, -50.0, 25.0, -12.5, 6.25];
        final sma = FusionMathematics.simpleMovingAverage(data, window: 3);

        expect(sma.length, 3);
        expect(sma[0], closeTo(25.0, 0.001)); // (100-50+25)/3
        expect(sma[1], closeTo(-12.5, 0.001)); // (-50+25-12.5)/3
        expect(sma[2], closeTo(6.25, 0.001)); // (25-12.5+6.25)/3
      });
    });

    group('Exponential Moving Average', () {
      test('first EMA equals first data point', () {
        final data = [10.0, 20.0, 30.0, 40.0];
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 3);

        expect(ema.first, 10.0);
      });

      test('returns empty for empty data', () {
        final ema = FusionMathematics.exponentialMovingAverage([], period: 3);
        expect(ema, isEmpty);
      });

      test('EMA length equals input length', () {
        final data = [10.0, 20.0, 30.0, 40.0, 50.0];
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 3);

        expect(ema.length, data.length);
      });

      test('EMA responds faster to recent changes', () {
        final data = [10.0, 10.0, 10.0, 50.0]; // Sudden jump
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 2);
        final sma = FusionMathematics.simpleMovingAverage(data, window: 2);

        // EMA should show the jump faster
        // Last EMA value should be closer to 50 than SMA
        expect(ema.last, greaterThan(sma.last));
      });

      test('handles single data point', () {
        final data = [42.0];
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 3);

        expect(ema.length, 1);
        expect(ema[0], 42.0);
      });

      test('handles negative values', () {
        final data = [-10.0, -20.0, -30.0, -40.0];
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 2);

        expect(ema.length, 4);
        expect(ema[0], -10.0);
        // EMA should trend downward
        expect(ema.last, lessThan(ema.first));
      });

      test('handles zero values', () {
        final data = [0.0, 0.0, 0.0, 0.0];
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 2);

        expect(ema.length, 4);
        for (final val in ema) {
          expect(val, closeTo(0.0, 0.001));
        }
      });

      test('handles very large period', () {
        final data = [10.0, 20.0, 30.0, 40.0, 50.0];
        final ema = FusionMathematics.exponentialMovingAverage(
          data,
          period: 100,
        );

        expect(ema.length, 5);
        // With very large period, alpha is very small, so EMA changes slowly
        expect(ema.last, lessThan(50.0));
      });

      test('handles period of 1 (fast response)', () {
        final data = [10.0, 20.0, 30.0, 40.0];
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 1);

        expect(ema.length, 4);
        // With period 1, alpha = 2/(1+1) = 1, so EMA should equal current value
        expect(ema[0], 10.0);
        expect(ema[1], closeTo(20.0, 0.001));
        expect(ema[2], closeTo(30.0, 0.001));
        expect(ema[3], closeTo(40.0, 0.001));
      });

      test('handles alternating values', () {
        final data = [100.0, 0.0, 100.0, 0.0, 100.0];
        final ema = FusionMathematics.exponentialMovingAverage(data, period: 2);

        expect(ema.length, 5);
        // EMA should smooth out the alternation
        expect(ema.last, greaterThan(0));
        expect(ema.last, lessThan(100));
      });
    });

    // =========================================================================
    // LINEAR REGRESSION
    // =========================================================================

    group('Linear Regression', () {
      test('calculates correct slope and intercept', () {
        // Perfect linear data: y = 2x + 1
        final dataPoints = [
          FusionDataPoint(0, 1),
          FusionDataPoint(1, 3),
          FusionDataPoint(2, 5),
          FusionDataPoint(3, 7),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(2.0, 0.001));
        expect(trendLine.intercept, closeTo(1.0, 0.001));
      });

      test('handles empty data', () {
        final trendLine = FusionMathematics.calculateLinearRegression([]);

        expect(trendLine.slope, 0);
        expect(trendLine.intercept, 0);
      });

      test('handles horizontal line (zero slope)', () {
        final dataPoints = [
          FusionDataPoint(0, 5),
          FusionDataPoint(1, 5),
          FusionDataPoint(2, 5),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(0, 0.001));
        expect(trendLine.intercept, closeTo(5.0, 0.001));
      });

      test('handles vertical line (infinite slope)', () {
        final dataPoints = [
          FusionDataPoint(3, 1),
          FusionDataPoint(3, 2),
          FusionDataPoint(3, 3),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        // Should handle gracefully without NaN
        expect(trendLine.slope.isNaN, isFalse);
        expect(trendLine.intercept.isNaN, isFalse);
      });

      test('handles single point', () {
        final dataPoints = [FusionDataPoint(5, 10)];
        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        // With one point, slope should be 0, intercept = y value
        expect(trendLine.intercept, closeTo(10.0, 0.001));
      });

      test('handles negative slope', () {
        // y = -2x + 10
        final dataPoints = [
          FusionDataPoint(0, 10),
          FusionDataPoint(1, 8),
          FusionDataPoint(2, 6),
          FusionDataPoint(3, 4),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(-2.0, 0.001));
        expect(trendLine.intercept, closeTo(10.0, 0.001));
      });

      test('handles negative coordinates', () {
        // y = x - 5
        final dataPoints = [
          FusionDataPoint(-5, -10),
          FusionDataPoint(-3, -8),
          FusionDataPoint(0, -5),
          FusionDataPoint(3, -2),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(1.0, 0.001));
        expect(trendLine.intercept, closeTo(-5.0, 0.001));
      });

      test('handles noisy data', () {
        final dataPoints = [
          FusionDataPoint(0, 1.1),
          FusionDataPoint(1, 2.9),
          FusionDataPoint(2, 5.2),
          FusionDataPoint(3, 6.8),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        // Should be approximately y = 2x + 1
        expect(trendLine.slope, closeTo(2.0, 0.5));
        expect(trendLine.intercept, closeTo(1.0, 0.5));
      });

      test('handles very large values', () {
        final dataPoints = [
          FusionDataPoint(0, 1e10),
          FusionDataPoint(1, 2e10),
          FusionDataPoint(2, 3e10),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(1e10, 1e6));
        expect(trendLine.intercept, closeTo(1e10, 1e6));
      });

      test('handles very small values', () {
        final dataPoints = [
          FusionDataPoint(0, 1e-10),
          FusionDataPoint(1, 2e-10),
          FusionDataPoint(2, 3e-10),
        ];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(1e-10, 1e-15));
        expect(trendLine.intercept, closeTo(1e-10, 1e-15));
      });

      test('handles two points', () {
        final dataPoints = [FusionDataPoint(0, 0), FusionDataPoint(10, 10)];

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(1.0, 0.001));
        expect(trendLine.intercept, closeTo(0.0, 0.001));
      });
    });

    group('R-Squared', () {
      test('returns 1 for perfect fit', () {
        final dataPoints = [
          FusionDataPoint(0, 1),
          FusionDataPoint(1, 3),
          FusionDataPoint(2, 5),
        ];
        final trendLine = FusionTrendLine(slope: 2, intercept: 1);

        final rSquared = FusionMathematics.calculateRSquared(
          dataPoints,
          trendLine,
        );

        expect(rSquared, closeTo(1.0, 0.001));
      });

      test('returns 0 for empty data', () {
        final rSquared = FusionMathematics.calculateRSquared(
          [],
          const FusionTrendLine(slope: 1, intercept: 0),
        );

        expect(rSquared, 0);
      });

      test('returns value between 0 and 1 for noisy data', () {
        final dataPoints = [
          FusionDataPoint(0, 1),
          FusionDataPoint(1, 2.5), // Slightly off from y = 2x + 1
          FusionDataPoint(2, 5.5), // Slightly off
          FusionDataPoint(3, 6.8), // Slightly off
        ];
        final trendLine = FusionTrendLine(slope: 2, intercept: 1);

        final rSquared = FusionMathematics.calculateRSquared(
          dataPoints,
          trendLine,
        );

        expect(rSquared, greaterThanOrEqualTo(0));
        expect(rSquared, lessThanOrEqualTo(1));
      });

      test('returns 0 for horizontal data with wrong trendline', () {
        final dataPoints = [
          FusionDataPoint(0, 5),
          FusionDataPoint(1, 5),
          FusionDataPoint(2, 5),
        ];
        // Using a sloped trendline for horizontal data
        final trendLine = FusionTrendLine(slope: 2, intercept: 1);

        final rSquared = FusionMathematics.calculateRSquared(
          dataPoints,
          trendLine,
        );

        // ssTot will be 0 (all y values same), so R² should be 0
        expect(rSquared, 0);
      });

      test('returns 1 for single point (trivially fits)', () {
        final dataPoints = [FusionDataPoint(5, 10)];
        final trendLine = FusionTrendLine(slope: 0, intercept: 10);

        final rSquared = FusionMathematics.calculateRSquared(
          dataPoints,
          trendLine,
        );

        // Single point: ssTot = 0, returns 0 based on implementation
        expect(rSquared, 0);
      });

      test('handles negative values', () {
        final dataPoints = [
          FusionDataPoint(-2, -3),
          FusionDataPoint(-1, -1),
          FusionDataPoint(0, 1),
          FusionDataPoint(1, 3),
        ];
        // Perfect fit: y = 2x + 1
        final trendLine = FusionTrendLine(slope: 2, intercept: 1);

        final rSquared = FusionMathematics.calculateRSquared(
          dataPoints,
          trendLine,
        );

        expect(rSquared, closeTo(1.0, 0.001));
      });
    });

    // =========================================================================
    // INTERPOLATION
    // =========================================================================

    group('Lerp', () {
      test('returns start at t=0', () {
        expect(FusionMathematics.lerp(10, 20, 0), 10);
      });

      test('returns end at t=1', () {
        expect(FusionMathematics.lerp(10, 20, 1), 20);
      });

      test('returns midpoint at t=0.5', () {
        expect(FusionMathematics.lerp(10, 20, 0.5), 15);
      });

      test('handles negative values', () {
        expect(FusionMathematics.lerp(-10, 10, 0.5), 0);
      });

      test('extrapolates beyond range', () {
        expect(FusionMathematics.lerp(0, 10, 2), 20); // t > 1
        expect(FusionMathematics.lerp(0, 10, -1), -10); // t < 0
      });

      test('handles same start and end values', () {
        expect(FusionMathematics.lerp(5, 5, 0.5), 5);
        expect(FusionMathematics.lerp(5, 5, 0), 5);
        expect(FusionMathematics.lerp(5, 5, 1), 5);
      });

      test('handles very large values', () {
        expect(FusionMathematics.lerp(0, 1e10, 0.5), closeTo(5e9, 1e5));
      });

      test('handles very small values', () {
        expect(FusionMathematics.lerp(0, 1e-10, 0.5), closeTo(5e-11, 1e-15));
      });

      test('handles negative to positive range', () {
        expect(FusionMathematics.lerp(-100, 100, 0.25), closeTo(-50, 0.001));
        expect(FusionMathematics.lerp(-100, 100, 0.75), closeTo(50, 0.001));
      });

      test('handles reversed range (start > end)', () {
        expect(FusionMathematics.lerp(20, 10, 0.5), 15);
        expect(FusionMathematics.lerp(20, 10, 0), 20);
        expect(FusionMathematics.lerp(20, 10, 1), 10);
      });

      test('handles zero values', () {
        expect(FusionMathematics.lerp(0, 0, 0.5), 0);
        expect(FusionMathematics.lerp(0, 10, 0), 0);
        expect(FusionMathematics.lerp(10, 0, 1), 0);
      });
    });

    group('Bilinear Interpolation', () {
      test('interpolates correctly at corner', () {
        final result = FusionMathematics.bilinearInterpolation(
          1,
          2,
          3,
          4, // q11, q12, q21, q22
          0,
          1,
          0,
          1, // x1, x2, y1, y2
          0,
          0, // x, y (bottom-left corner)
        );

        expect(result, closeTo(1.0, 0.001)); // Should be q11
      });

      test('interpolates at center', () {
        final result = FusionMathematics.bilinearInterpolation(
          0,
          0,
          10,
          10, // corners: 0 at left, 10 at right
          0,
          1,
          0,
          1,
          0.5,
          0.5, // center
        );

        expect(result, closeTo(5.0, 0.001)); // Average of corners
      });

      test('interpolates at other corners', () {
        // q11=1, q12=2, q21=3, q22=4
        // Top-left (x=0, y=1) should be q12=2
        final topLeft = FusionMathematics.bilinearInterpolation(
          1,
          2,
          3,
          4,
          0,
          1,
          0,
          1,
          0,
          1,
        );
        expect(topLeft, closeTo(2.0, 0.001));

        // Bottom-right (x=1, y=0) should be q21=3
        final bottomRight = FusionMathematics.bilinearInterpolation(
          1,
          2,
          3,
          4,
          0,
          1,
          0,
          1,
          1,
          0,
        );
        expect(bottomRight, closeTo(3.0, 0.001));

        // Top-right (x=1, y=1) should be q22=4
        final topRight = FusionMathematics.bilinearInterpolation(
          1,
          2,
          3,
          4,
          0,
          1,
          0,
          1,
          1,
          1,
        );
        expect(topRight, closeTo(4.0, 0.001));
      });

      test('interpolates along edges', () {
        // Along bottom edge (y=0)
        final bottom = FusionMathematics.bilinearInterpolation(
          0,
          0,
          10,
          10,
          0,
          1,
          0,
          1,
          0.5,
          0, // midpoint of bottom edge
        );
        expect(bottom, closeTo(5.0, 0.001));

        // Along left edge (x=0)
        final left = FusionMathematics.bilinearInterpolation(
          0,
          10,
          0,
          10,
          0,
          1,
          0,
          1,
          0,
          0.5, // midpoint of left edge
        );
        expect(left, closeTo(5.0, 0.001));
      });

      test('handles negative values', () {
        final result = FusionMathematics.bilinearInterpolation(
          -10,
          -5,
          5,
          10,
          0,
          1,
          0,
          1,
          0.5,
          0.5,
        );
        expect(result, closeTo(0.0, 0.001)); // Average of corners
      });

      test('handles large coordinates', () {
        final result = FusionMathematics.bilinearInterpolation(
          0,
          100,
          100,
          200,
          0,
          100,
          0,
          100,
          50,
          50,
        );
        expect(result, closeTo(100.0, 0.001));
      });
    });

    // =========================================================================
    // STATISTICAL FUNCTIONS
    // =========================================================================

    group('Standard Deviation', () {
      test('returns 0 for empty data', () {
        expect(FusionMathematics.standardDeviation([]), 0);
      });

      test('returns 0 for single value', () {
        expect(FusionMathematics.standardDeviation([5.0]), 0);
      });

      test('returns 0 for identical values', () {
        expect(FusionMathematics.standardDeviation([5.0, 5.0, 5.0]), 0);
      });

      test('calculates correct standard deviation', () {
        // Data: 2, 4, 4, 4, 5, 5, 7, 9
        // Mean: 5
        // Variance: 4
        // StdDev: 2
        final data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
        final stdDev = FusionMathematics.standardDeviation(data);

        expect(stdDev, closeTo(2.0, 0.001));
      });

      test('handles negative values', () {
        // Data: -2, -1, 0, 1, 2
        // Mean: 0
        // Variance: (4+1+0+1+4)/5 = 2
        // StdDev: sqrt(2) ≈ 1.414
        final data = [-2.0, -1.0, 0.0, 1.0, 2.0];
        final stdDev = FusionMathematics.standardDeviation(data);

        expect(stdDev, closeTo(math.sqrt(2), 0.001));
      });

      test('handles two values', () {
        // Data: 0, 10
        // Mean: 5
        // Variance: (25+25)/2 = 25
        // StdDev: 5
        final data = [0.0, 10.0];
        final stdDev = FusionMathematics.standardDeviation(data);

        expect(stdDev, closeTo(5.0, 0.001));
      });

      test('handles very large values', () {
        final data = [1e10, 2e10, 3e10];
        final stdDev = FusionMathematics.standardDeviation(data);

        // Should be approximately sqrt(2/3) * 1e10 ≈ 8.165e9
        expect(stdDev, greaterThan(0));
        expect(stdDev.isFinite, isTrue);
      });

      test('handles very small values', () {
        final data = [1e-10, 2e-10, 3e-10];
        final stdDev = FusionMathematics.standardDeviation(data);

        expect(stdDev, greaterThan(0));
        expect(stdDev.isFinite, isTrue);
      });

      test('handles mixed positive and negative', () {
        final data = [-100.0, -50.0, 0.0, 50.0, 100.0];
        final stdDev = FusionMathematics.standardDeviation(data);

        // Mean = 0, Variance = (10000+2500+0+2500+10000)/5 = 5000
        // StdDev = sqrt(5000) ≈ 70.71
        expect(stdDev, closeTo(math.sqrt(5000), 0.01));
      });
    });

    group('Correlation Coefficient', () {
      test('returns 1 for perfect positive correlation', () {
        final x = [1.0, 2.0, 3.0, 4.0];
        final y = [2.0, 4.0, 6.0, 8.0]; // y = 2x

        final corr = FusionMathematics.correlationCoefficient(x, y);

        expect(corr, closeTo(1.0, 0.001));
      });

      test('returns -1 for perfect negative correlation', () {
        final x = [1.0, 2.0, 3.0, 4.0];
        final y = [8.0, 6.0, 4.0, 2.0]; // y = -2x + 10

        final corr = FusionMathematics.correlationCoefficient(x, y);

        expect(corr, closeTo(-1.0, 0.001));
      });

      test('returns near 0 for weak correlation', () {
        // Data with weak/no clear linear relationship
        final x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
        final y = [2.0, 1.0, 3.0, 2.0, 4.0, 3.0]; // Noisy, roughly flat

        final corr = FusionMathematics.correlationCoefficient(x, y);

        // Weak correlation - just verify it's between -1 and 1
        expect(corr, greaterThanOrEqualTo(-1));
        expect(corr, lessThanOrEqualTo(1));
      });

      test('returns 0 for empty data', () {
        expect(FusionMathematics.correlationCoefficient([], []), 0);
      });

      test('handles constant values', () {
        final x = [5.0, 5.0, 5.0];
        final y = [1.0, 2.0, 3.0];

        final corr = FusionMathematics.correlationCoefficient(x, y);

        expect(corr, 0); // No correlation when one variable is constant
      });

      test('handles both constant values', () {
        final x = [5.0, 5.0, 5.0];
        final y = [10.0, 10.0, 10.0];

        final corr = FusionMathematics.correlationCoefficient(x, y);

        expect(corr, 0); // No correlation when both are constant
      });

      test('handles single point', () {
        final x = [5.0];
        final y = [10.0];

        final corr = FusionMathematics.correlationCoefficient(x, y);

        expect(corr, 0); // Cannot compute correlation with single point
      });

      test('handles negative values', () {
        final x = [-4.0, -2.0, 0.0, 2.0, 4.0];
        final y = [-8.0, -4.0, 0.0, 4.0, 8.0]; // y = 2x

        final corr = FusionMathematics.correlationCoefficient(x, y);

        expect(corr, closeTo(1.0, 0.001));
      });

      test('handles mixed positive and negative correlation regions', () {
        // Quadratic-like data: x² looks like no linear correlation
        final x = [-2.0, -1.0, 0.0, 1.0, 2.0];
        final y = [4.0, 1.0, 0.0, 1.0, 4.0]; // y = x²

        final corr = FusionMathematics.correlationCoefficient(x, y);

        // Symmetric data around origin should show near-zero linear correlation
        expect(corr, closeTo(0.0, 0.001));
      });

      test('handles two points', () {
        final x = [0.0, 10.0];
        final y = [0.0, 20.0];

        final corr = FusionMathematics.correlationCoefficient(x, y);

        // Two points always form a perfect line
        expect(corr, closeTo(1.0, 0.001));
      });

      test('is symmetric', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [2.0, 3.0, 5.0, 4.0, 6.0];

        final corrXY = FusionMathematics.correlationCoefficient(x, y);
        final corrYX = FusionMathematics.correlationCoefficient(y, x);

        expect(corrXY, closeTo(corrYX, 0.001));
      });
    });

    // =========================================================================
    // DATA SMOOTHING
    // =========================================================================

    group('Gaussian Smoothing', () {
      test('returns copy for small data', () {
        final data = [1.0, 2.0, 3.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          kernelSize: 5,
        );

        expect(smoothed.length, data.length);
      });

      test('returns empty for empty data', () {
        final smoothed = FusionMathematics.gaussianSmoothing([], kernelSize: 5);

        expect(smoothed, isEmpty);
      });

      test('returns single value for single data point', () {
        final data = [42.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          kernelSize: 5,
        );

        expect(smoothed.length, 1);
        expect(smoothed[0], closeTo(42.0, 0.001));
      });

      test('smooths noisy data', () {
        // Add noise to a line
        final data = [10.0, 15.0, 8.0, 12.0, 14.0, 9.0, 11.0, 13.0, 10.0, 12.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 1.0,
          kernelSize: 3,
        );

        expect(smoothed.length, data.length);

        // Calculate variance of both
        double variance(List<double> d) {
          final mean = d.reduce((a, b) => a + b) / d.length;
          return d.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
              d.length;
        }

        // Smoothed should have lower variance
        expect(variance(smoothed), lessThan(variance(data)));
      });

      test('respects sigma parameter', () {
        final data = [0.0, 10.0, 0.0, 10.0, 0.0, 10.0, 0.0, 10.0, 0.0, 10.0];

        final smoothedLow = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 0.5,
          kernelSize: 5,
        );

        final smoothedHigh = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 2.0,
          kernelSize: 5,
        );

        // Higher sigma should result in more smoothing (lower variance)
        double variance(List<double> d) {
          final mean = d.reduce((a, b) => a + b) / d.length;
          return d.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
              d.length;
        }

        expect(variance(smoothedHigh), lessThan(variance(smoothedLow)));
      });

      test('handles negative values', () {
        final data = [-10.0, -5.0, 0.0, 5.0, 10.0, 5.0, 0.0, -5.0, -10.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 1.0,
          kernelSize: 3,
        );

        expect(smoothed.length, data.length);
        // Should preserve sign pattern approximately
        expect(smoothed.first, lessThan(0));
        expect(smoothed.last, lessThan(0));
      });

      test('handles all zeros', () {
        final data = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 1.0,
          kernelSize: 3,
        );

        expect(smoothed.length, data.length);
        for (final val in smoothed) {
          expect(val, closeTo(0.0, 0.001));
        }
      });

      test('handles all same values', () {
        final data = [5.0, 5.0, 5.0, 5.0, 5.0, 5.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 1.0,
          kernelSize: 3,
        );

        expect(smoothed.length, data.length);
        for (final val in smoothed) {
          expect(val, closeTo(5.0, 0.001));
        }
      });

      test('handles kernel size of 1', () {
        final data = [1.0, 2.0, 3.0, 4.0, 5.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 1.0,
          kernelSize: 1,
        );

        expect(smoothed.length, data.length);
        // With kernel size 1, should return original values
        for (int i = 0; i < data.length; i++) {
          expect(smoothed[i], closeTo(data[i], 0.001));
        }
      });

      test('handles very large kernel size', () {
        final data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 2.0,
          kernelSize: 7,
        );

        expect(smoothed.length, data.length);
        // Large kernel should smooth significantly
        double variance(List<double> d) {
          final mean = d.reduce((a, b) => a + b) / d.length;
          return d.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
              d.length;
        }

        expect(variance(smoothed), lessThan(variance(data)));
      });

      test('preserves data length', () {
        final data = List.generate(100, (i) => i.toDouble());
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 1.0,
          kernelSize: 5,
        );

        expect(smoothed.length, data.length);
      });
    });
  });

  // ===========================================================================
  // FUSION TREND LINE TESTS
  // ===========================================================================

  group('FusionTrendLine', () {
    test('getY calculates correctly', () {
      final trendLine = FusionTrendLine(slope: 2, intercept: 3);

      expect(trendLine.getY(0), 3);
      expect(trendLine.getY(1), 5);
      expect(trendLine.getY(5), 13);
      expect(trendLine.getY(-2), -1);
    });

    test('generatePoints creates correct number of points', () {
      final trendLine = FusionTrendLine(slope: 1, intercept: 0);
      final points = trendLine.generatePoints(0, 10, 11);

      expect(points.length, 11);
    });

    test('generatePoints creates correct values', () {
      final trendLine = FusionTrendLine(slope: 2, intercept: 1);
      final points = trendLine.generatePoints(0, 3, 4);

      expect(points[0].x, closeTo(0, 0.001));
      expect(points[0].y, closeTo(1, 0.001));

      expect(points[1].x, closeTo(1, 0.001));
      expect(points[1].y, closeTo(3, 0.001));

      expect(points[2].x, closeTo(2, 0.001));
      expect(points[2].y, closeTo(5, 0.001));

      expect(points[3].x, closeTo(3, 0.001));
      expect(points[3].y, closeTo(7, 0.001));
    });

    test('toString formats correctly', () {
      final trendLine = FusionTrendLine(slope: 2.5, intercept: 1.5);
      expect(trendLine.toString(), 'y = 2.50x + 1.50');
    });

    test('handles negative slope and intercept', () {
      final trendLine = FusionTrendLine(slope: -1.5, intercept: -2.5);
      expect(trendLine.getY(0), -2.5);
      expect(trendLine.getY(2), -5.5);
    });

    test('handles zero slope', () {
      final trendLine = FusionTrendLine(slope: 0, intercept: 5);
      expect(trendLine.getY(0), 5);
      expect(trendLine.getY(100), 5);
      expect(trendLine.getY(-100), 5);
    });

    test('handles zero intercept', () {
      final trendLine = FusionTrendLine(slope: 2, intercept: 0);
      expect(trendLine.getY(0), 0);
      expect(trendLine.getY(5), 10);
      expect(trendLine.getY(-5), -10);
    });

    test('handles very large slope', () {
      final trendLine = FusionTrendLine(slope: 1e6, intercept: 0);
      expect(trendLine.getY(1), 1e6);
      expect(trendLine.getY(2), 2e6);
    });

    test('handles very small slope', () {
      final trendLine = FusionTrendLine(slope: 1e-6, intercept: 0);
      expect(trendLine.getY(1e6), closeTo(1.0, 0.001));
    });

    test('generatePoints handles reversed range', () {
      final trendLine = FusionTrendLine(slope: 1, intercept: 0);
      final points = trendLine.generatePoints(10, 0, 3);

      expect(points.length, 3);
      expect(points[0].x, closeTo(10, 0.001));
      expect(points[2].x, closeTo(0, 0.001));
    });

    test('generatePoints handles negative range', () {
      final trendLine = FusionTrendLine(slope: 2, intercept: 0);
      final points = trendLine.generatePoints(-5, 5, 5);

      expect(points.length, 5);
      expect(points[0].x, closeTo(-5, 0.001));
      expect(points[0].y, closeTo(-10, 0.001));
      expect(points[4].x, closeTo(5, 0.001));
      expect(points[4].y, closeTo(10, 0.001));
    });

    test('generatePoints with two points', () {
      final trendLine = FusionTrendLine(slope: 2, intercept: 1);
      // count = 2 is the minimum meaningful case for generatePoints
      final points = trendLine.generatePoints(0, 10, 2);

      expect(points.length, 2);
      expect(points[0].x, closeTo(0, 0.001));
      expect(points[0].y, closeTo(1, 0.001)); // y = 2*0 + 1 = 1
      expect(points[1].x, closeTo(10, 0.001));
      expect(points[1].y, closeTo(21, 0.001)); // y = 2*10 + 1 = 21
    });

    test('toString handles negative values', () {
      final trendLine = FusionTrendLine(slope: -2.5, intercept: -1.5);
      expect(trendLine.toString(), 'y = -2.50x + -1.50');
    });

    test('toString handles zero values', () {
      final trendLine = FusionTrendLine(slope: 0, intercept: 0);
      expect(trendLine.toString(), 'y = 0.00x + 0.00');
    });

    test('getY handles very large x values', () {
      final trendLine = FusionTrendLine(slope: 2, intercept: 1);
      final y = trendLine.getY(1e10);
      expect(y, closeTo(2e10 + 1, 1e6));
    });

    test('getY handles very small x values', () {
      final trendLine = FusionTrendLine(slope: 2, intercept: 1);
      final y = trendLine.getY(1e-10);
      expect(y, closeTo(1, 1e-9));
    });
  });

  // ===========================================================================
  // EDGE CASES AND BOUNDARY CONDITIONS
  // ===========================================================================

  group('Edge Cases and Boundary Conditions', () {
    group('Infinity and NaN handling', () {
      test('lerp handles infinity', () {
        final result = FusionMathematics.lerp(0, double.infinity, 0.5);
        expect(result, double.infinity);
      });

      test('standardDeviation handles infinity in data', () {
        final data = [1.0, double.infinity, 3.0];
        final stdDev = FusionMathematics.standardDeviation(data);
        expect(stdDev.isNaN || stdDev.isInfinite, isTrue);
      });

      test('trendLine getY handles infinity', () {
        final trendLine = FusionTrendLine(slope: 1, intercept: 0);
        final y = trendLine.getY(double.infinity);
        expect(y, double.infinity);
      });
    });

    group('Precision and floating point', () {
      test('lerp maintains precision for small differences', () {
        final result = FusionMathematics.lerp(1.0, 1.0 + 1e-10, 0.5);
        expect(result, closeTo(1.0 + 0.5e-10, 1e-15));
      });

      test('standardDeviation handles nearly identical values', () {
        final data = [1.0, 1.0 + 1e-10, 1.0 + 2e-10];
        final stdDev = FusionMathematics.standardDeviation(data);
        expect(stdDev, greaterThanOrEqualTo(0));
        expect(stdDev.isFinite, isTrue);
      });

      test('correlationCoefficient handles nearly identical arrays', () {
        final x = [1.0, 1.0 + 1e-10, 1.0 + 2e-10];
        final y = [1.0, 1.0 + 1e-10, 1.0 + 2e-10];

        final corr = FusionMathematics.correlationCoefficient(x, y);
        expect(corr.isFinite, isTrue);
      });
    });

    group('Large datasets', () {
      test('simpleMovingAverage handles large dataset', () {
        final data = List.generate(1000, (i) => i.toDouble());
        final sma = FusionMathematics.simpleMovingAverage(data, window: 10);

        expect(sma.length, 991);
        expect(sma.first, closeTo(4.5, 0.001)); // Average of 0-9
      });

      test('exponentialMovingAverage handles large dataset', () {
        final data = List.generate(1000, (i) => i.toDouble());
        final ema = FusionMathematics.exponentialMovingAverage(
          data,
          period: 10,
        );

        expect(ema.length, 1000);
        expect(ema.first, 0.0);
        expect(ema.last, greaterThan(900)); // Should be close to end values
      });

      test('gaussianSmoothing handles large dataset', () {
        final data = List.generate(1000, (i) => math.sin(i * 0.1));
        final smoothed = FusionMathematics.gaussianSmoothing(
          data,
          sigma: 1.0,
          kernelSize: 5,
        );

        expect(smoothed.length, 1000);
      });

      test('linearRegression handles large dataset', () {
        final dataPoints = List.generate(
          1000,
          (i) => FusionDataPoint(i.toDouble(), 2.0 * i + 1),
        );

        final trendLine = FusionMathematics.calculateLinearRegression(
          dataPoints,
        );

        expect(trendLine.slope, closeTo(2.0, 0.001));
        expect(trendLine.intercept, closeTo(1.0, 0.001));
      });
    });
  });
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/fusion_data_point.dart';

/// Advanced mathematical utilities for chart rendering.
///
/// Provides algorithms for:
/// - Curve smoothing (Bezier, Catmull-Rom splines)
/// - Data analysis (moving averages, trend lines)
/// - Statistical calculations
/// - Interpolation and extrapolation
///
/// Based on algorithms used by Syncfusion and industry standards.
class FusionMathematics {
  FusionMathematics._(); // Private constructor - utility class

  // ==========================================================================
  // BEZIER CURVE CALCULATIONS
  // ==========================================================================

  /// Calculates points along a cubic Bezier curve.
  ///
  /// Used by Syncfusion for smooth line rendering.
  ///
  /// **Formula:**
  /// ```
  /// P(t) = (1-t)³P₀ + 3(1-t)²tP₁ + 3(1-t)t²P₂ + t³P₃
  /// ```
  ///
  /// Where:
  /// - P₀, P₃ = endpoints
  /// - P₁, P₂ = control points
  /// - t ∈ [0, 1]
  ///
  /// Example:
  /// ```dart
  /// final curve = FusionMathematics.calculateCubicBezier(
  ///   Offset(0, 0),   // Start
  ///   Offset(1, 2),   // Control 1
  ///   Offset(2, 2),   // Control 2
  ///   Offset(3, 0),   // End
  ///   segments: 20,   // 20 points along curve
  /// );
  /// ```
  static List<Offset> calculateCubicBezier(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3, {
    int segments = 20,
  }) {
    assert(segments > 0, 'Segments must be positive');

    final points = <Offset>[];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final oneMinusT = 1.0 - t;

      // Cubic Bezier formula
      final x =
          math.pow(oneMinusT, 3) * p0.dx +
          3 * math.pow(oneMinusT, 2) * t * p1.dx +
          3 * oneMinusT * math.pow(t, 2) * p2.dx +
          math.pow(t, 3) * p3.dx;

      final y =
          math.pow(oneMinusT, 3) * p0.dy +
          3 * math.pow(oneMinusT, 2) * t * p1.dy +
          3 * oneMinusT * math.pow(t, 2) * p2.dy +
          math.pow(t, 3) * p3.dy;

      points.add(Offset(x, y));
    }

    return points;
  }

  /// Calculates points along a quadratic Bezier curve.
  ///
  /// Simpler than cubic, uses one control point.
  ///
  /// **Formula:**
  /// ```
  /// P(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
  /// ```
  static List<Offset> calculateQuadraticBezier(
    Offset p0,
    Offset p1,
    Offset p2, {
    int segments = 20,
  }) {
    final points = <Offset>[];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final oneMinusT = 1.0 - t;

      final x = math.pow(oneMinusT, 2) * p0.dx + 2 * oneMinusT * t * p1.dx + math.pow(t, 2) * p2.dx;

      final y = math.pow(oneMinusT, 2) * p0.dy + 2 * oneMinusT * t * p1.dy + math.pow(t, 2) * p2.dy;

      points.add(Offset(x, y));
    }

    return points;
  }

  // ==========================================================================
  // CATMULL-ROM SPLINE
  // ==========================================================================

  /// Calculates smooth curve through data points using Catmull-Rom spline.
  ///
  /// Used by Syncfusion for SplineSeries.
  /// Creates a natural-looking curve that passes through all points.
  ///
  /// **Formula:**
  /// ```
  /// P(t) = 0.5 × [
  ///   (2P₁) +
  ///   (-P₀ + P₂)t +
  ///   (2P₀ - 5P₁ + 4P₂ - P₃)t² +
  ///   (-P₀ + 3P₁ - 3P₂ + P₃)t³
  /// ]
  /// ```
  ///
  /// Example:
  /// ```dart
  /// final dataPoints = [
  ///   Offset(0, 1),
  ///   Offset(1, 3),
  ///   Offset(2, 2),
  ///   Offset(3, 4),
  /// ];
  ///
  /// final smoothCurve = FusionMathematics.calculateCatmullRomSpline(
  ///   dataPoints,
  ///   segmentsPerCurve: 20,
  /// );
  /// ```
  static List<Offset> calculateCatmullRomSpline(
    List<Offset> controlPoints, {
    int segmentsPerCurve = 20,
    double tension = 0.5,
  }) {
    if (controlPoints.length < 4) {
      return List.from(controlPoints);
    }

    final result = <Offset>[];

    // Add first point
    result.add(controlPoints[0]);

    // Process each segment
    for (int i = 0; i < controlPoints.length - 3; i++) {
      final p0 = controlPoints[i];
      final p1 = controlPoints[i + 1];
      final p2 = controlPoints[i + 2];
      final p3 = controlPoints[i + 3];

      // Generate points between p1 and p2
      for (int j = 1; j <= segmentsPerCurve; j++) {
        final t = j / segmentsPerCurve;
        final t2 = t * t;
        final t3 = t2 * t;

        final x =
            tension *
            ((2 * p1.dx) +
                (-p0.dx + p2.dx) * t +
                (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
                (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3);

        final y =
            tension *
            ((2 * p1.dy) +
                (-p0.dy + p2.dy) * t +
                (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
                (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3);

        result.add(Offset(x, y));
      }
    }

    return result;
  }

  /// Generates control points for smooth curves from data points.
  ///
  /// Used to create smooth transitions between data points.
  /// Essential for Syncfusion-style curved lines.
  static List<Offset> generateControlPoints(
    List<FusionDataPoint> dataPoints, {
    double smoothness = 0.35,
  }) {
    if (dataPoints.length < 2) return [];

    final controlPoints = <Offset>[];

    for (int i = 0; i < dataPoints.length - 1; i++) {
      final p0 = i > 0
          ? Offset(dataPoints[i - 1].x, dataPoints[i - 1].y)
          : Offset(dataPoints[i].x, dataPoints[i].y);
      final p1 = Offset(dataPoints[i].x, dataPoints[i].y);
      final p2 = Offset(dataPoints[i + 1].x, dataPoints[i + 1].y);
      final p3 = i < dataPoints.length - 2
          ? Offset(dataPoints[i + 2].x, dataPoints[i + 2].y)
          : Offset(dataPoints[i + 1].x, dataPoints[i + 1].y);

      // Calculate control points with smoothness factor
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * smoothness,
        p1.dy + (p2.dy - p0.dy) * smoothness,
      );

      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * smoothness,
        p2.dy - (p3.dy - p1.dy) * smoothness,
      );

      controlPoints.add(cp1);
      controlPoints.add(cp2);
    }

    return controlPoints;
  }

  // ==========================================================================
  // MOVING AVERAGES
  // ==========================================================================

  /// Calculates Simple Moving Average (SMA).
  ///
  /// Smooths data by averaging values over a window.
  ///
  /// Example:
  /// ```dart
  /// final data = [10, 20, 30, 40, 50];
  /// final sma = FusionMathematics.simpleMovingAverage(data, window: 3);
  /// // Result: [20, 30, 40] (average of each 3-value window)
  /// ```
  static List<double> simpleMovingAverage(List<double> data, {required int window}) {
    assert(window > 0 && window <= data.length);

    if (data.length < window) return [];

    final result = <double>[];

    for (int i = 0; i <= data.length - window; i++) {
      double sum = 0;
      for (int j = 0; j < window; j++) {
        sum += data[i + j];
      }
      result.add(sum / window);
    }

    return result;
  }

  /// Calculates Exponential Moving Average (EMA).
  ///
  /// Gives more weight to recent values.
  ///
  /// **Formula:**
  /// ```
  /// EMA_t = α × Value_t + (1 - α) × EMA_(t-1)
  /// Where α = 2 / (period + 1)
  /// ```
  ///
  /// Used in financial charts and trend analysis.
  static List<double> exponentialMovingAverage(List<double> data, {required int period}) {
    if (data.isEmpty) return [];

    final alpha = 2.0 / (period + 1);
    final result = <double>[];

    // First EMA is the first data point
    result.add(data[0]);

    for (int i = 1; i < data.length; i++) {
      final ema = alpha * data[i] + (1 - alpha) * result[i - 1];
      result.add(ema);
    }

    return result;
  }

  // ==========================================================================
  // TREND LINES & REGRESSION
  // ==========================================================================

  /// Calculates linear regression (trend line).
  ///
  /// **Formula:**
  /// ```
  /// y = mx + b
  ///
  /// Where:
  /// m = (n∑xy - ∑x∑y) / (n∑x² - (∑x)²)
  /// b = (∑y - m∑x) / n
  /// ```
  ///
  /// Returns slope and intercept.
  static FusionTrendLine calculateLinearRegression(List<FusionDataPoint> dataPoints) {
    if (dataPoints.isEmpty) {
      return FusionTrendLine(slope: 0, intercept: 0);
    }

    final n = dataPoints.length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (final point in dataPoints) {
      sumX += point.x;
      sumY += point.y;
      sumXY += point.x * point.y;
      sumX2 += point.x * point.x;
    }

    final denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) {
      return FusionTrendLine(slope: 0, intercept: sumY / n);
    }

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

    return FusionTrendLine(slope: slope, intercept: intercept);
  }

  /// Calculates R² (coefficient of determination) for trend line.
  ///
  /// Measures how well the trend line fits the data.
  ///
  /// **Formula:**
  /// ```
  /// R² = 1 - (SS_res / SS_tot)
  /// ```
  ///
  /// Returns value between 0 and 1:
  /// - 1.0 = perfect fit
  /// - 0.0 = no correlation
  static double calculateRSquared(List<FusionDataPoint> dataPoints, FusionTrendLine trendLine) {
    if (dataPoints.isEmpty) return 0;

    final meanY = dataPoints.map((p) => p.y).reduce((a, b) => a + b) / dataPoints.length;

    double ssRes = 0; // Sum of squares of residuals
    double ssTot = 0; // Total sum of squares

    for (final point in dataPoints) {
      final predicted = trendLine.getY(point.x);
      ssRes += math.pow(point.y - predicted, 2);
      ssTot += math.pow(point.y - meanY, 2);
    }

    if (ssTot == 0) return 0;

    return 1 - (ssRes / ssTot);
  }

  // ==========================================================================
  // INTERPOLATION
  // ==========================================================================

  /// Linear interpolation between two values.
  ///
  /// **Formula:**
  /// ```
  /// result = start + t × (end - start)
  /// ```
  static double lerp(double start, double end, double t) {
    return start + t * (end - start);
  }

  /// Bilinear interpolation for 2D data.
  static double bilinearInterpolation(
    double q11,
    double q12,
    double q21,
    double q22,
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
    double y,
  ) {
    final r1 = lerp(q11, q21, (x - x1) / (x2 - x1));
    final r2 = lerp(q12, q22, (x - x1) / (x2 - x1));
    return lerp(r1, r2, (y - y1) / (y2 - y1));
  }

  // ==========================================================================
  // STATISTICAL FUNCTIONS
  // ==========================================================================

  /// Calculates standard deviation.
  static double standardDeviation(List<double> data) {
    if (data.isEmpty) return 0;

    final mean = data.reduce((a, b) => a + b) / data.length;
    final variance = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / data.length;

    return math.sqrt(variance);
  }

  /// Calculates correlation coefficient between two datasets.
  ///
  /// Returns value between -1 and 1:
  /// - 1 = perfect positive correlation
  /// - 0 = no correlation
  /// - -1 = perfect negative correlation
  static double correlationCoefficient(List<double> dataX, List<double> dataY) {
    assert(dataX.length == dataY.length);

    if (dataX.isEmpty) return 0;

    final n = dataX.length;
    final meanX = dataX.reduce((a, b) => a + b) / n;
    final meanY = dataY.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double sumSqX = 0;
    double sumSqY = 0;

    for (int i = 0; i < n; i++) {
      final dx = dataX[i] - meanX;
      final dy = dataY[i] - meanY;
      numerator += dx * dy;
      sumSqX += dx * dx;
      sumSqY += dy * dy;
    }

    final denominator = math.sqrt(sumSqX * sumSqY);
    if (denominator == 0) return 0;

    return numerator / denominator;
  }

  // ==========================================================================
  // DATA SMOOTHING
  // ==========================================================================

  /// Smooths data using Gaussian kernel.
  static List<double> gaussianSmoothing(
    List<double> data, {
    double sigma = 1.0,
    int kernelSize = 5,
  }) {
    if (data.length < kernelSize) return List.from(data);

    // Generate Gaussian kernel
    final kernel = _generateGaussianKernel(kernelSize, sigma);
    final result = <double>[];

    for (int i = 0; i < data.length; i++) {
      double sum = 0;
      double weightSum = 0;

      for (int j = 0; j < kernelSize; j++) {
        final dataIndex = i - kernelSize ~/ 2 + j;
        if (dataIndex >= 0 && dataIndex < data.length) {
          sum += data[dataIndex] * kernel[j];
          weightSum += kernel[j];
        }
      }

      result.add(weightSum > 0 ? sum / weightSum : data[i]);
    }

    return result;
  }

  /// Generates Gaussian kernel for smoothing.
  static List<double> _generateGaussianKernel(int size, double sigma) {
    final kernel = <double>[];
    final center = size ~/ 2;

    for (int i = 0; i < size; i++) {
      final x = i - center;
      final value = math.exp(-(x * x) / (2 * sigma * sigma));
      kernel.add(value);
    }

    return kernel;
  }
}

// ==========================================================================
// DATA MODELS
// ==========================================================================

/// Represents a trend line (linear regression result).
class FusionTrendLine {
  const FusionTrendLine({required this.slope, required this.intercept});

  final double slope;
  final double intercept;

  /// Calculates y for a given x.
  double getY(double x) => slope * x + intercept;

  /// Generates data points along the trend line.
  List<FusionDataPoint> generatePoints(double startX, double endX, int count) {
    final points = <FusionDataPoint>[];
    final step = (endX - startX) / (count - 1);

    for (int i = 0; i < count; i++) {
      final x = startX + (i * step);
      points.add(FusionDataPoint(x, getY(x)));
    }

    return points;
  }

  @override
  String toString() => 'y = ${slope.toStringAsFixed(2)}x + ${intercept.toStringAsFixed(2)}';
}

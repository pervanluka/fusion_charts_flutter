import 'dart:math' as math;
import '../../data/fusion_data_point.dart';

/// Validates and cleans chart data to prevent rendering errors.
///
/// This is the first line of defense against bad data. It ensures
/// that all data points are valid, finite, and renderable.
///
/// ## Features:
/// - Removes invalid values (null, NaN, Infinity)
/// - Handles empty datasets
/// - Detects and reports data issues
/// - Provides fallback values
/// - Sorts data if needed
/// - Removes duplicates
///
/// ## Example:
///
/// ```dart
/// final validator = DataValidator();
/// final result = validator.validate(rawData);
///
/// if (result.hasErrors) {
///   print('Data issues: ${result.errors}');
/// }
///
/// // Use cleaned data
/// chart.data = result.validData;
/// ```
class DataValidator {
  /// Creates a data validator with optional configuration.
  DataValidator({
    this.removeNaN = true,
    this.removeInfinity = true,
    this.removeDuplicates = false,
    this.sortByX = false,
    this.interpolateMissing = false,
    this.clampToRange = false,
    this.minValue,
    this.maxValue,
  });

  /// Whether to remove NaN values.
  final bool removeNaN;

  /// Whether to remove Infinity values.
  final bool removeInfinity;

  /// Whether to remove duplicate X values.
  final bool removeDuplicates;

  /// Whether to sort data by X value.
  final bool sortByX;

  /// Whether to interpolate missing values.
  final bool interpolateMissing;

  /// Whether to clamp values to a range.
  final bool clampToRange;

  /// Minimum allowed value (if clamping).
  final double? minValue;

  /// Maximum allowed value (if clamping).
  final double? maxValue;

  // ==========================================================================
  // MAIN VALIDATION
  // ==========================================================================

  /// Validates a list of data points.
  ///
  /// Returns a validation result containing:
  /// - Cleaned data points
  /// - List of errors/warnings
  /// - Statistics about the data
  ValidationResult validate(List<FusionDataPoint> data) {
    final errors = <ValidationError>[];
    final warnings = <ValidationWarning>[];
    var validData = <FusionDataPoint>[];

    // Check for empty data
    if (data.isEmpty) {
      errors.add(
        ValidationError(
          code: 'EMPTY_DATA',
          message: 'Dataset is empty',
          severity: ErrorSeverity.critical,
        ),
      );

      return ValidationResult(
        originalCount: 0,
        validCount: 0,
        validData: [],
        errors: errors,
        warnings: warnings,
      );
    }

    // Step 1: Remove invalid values
    validData = _removeInvalidValues(data, errors);

    // Step 2: Remove duplicates (if enabled)
    if (removeDuplicates) {
      final beforeCount = validData.length;
      validData = _removeDuplicates(validData);

      if (validData.length < beforeCount) {
        warnings.add(
          ValidationWarning(
            code: 'DUPLICATES_REMOVED',
            message:
                'Removed ${beforeCount - validData.length} duplicate points',
          ),
        );
      }
    }

    // Step 3: Sort by X (if enabled)
    if (sortByX) {
      validData = _sortByX(validData);
    }

    // Step 4: Interpolate missing values (if enabled)
    if (interpolateMissing) {
      validData = _interpolateMissing(validData, warnings);
    }

    // Step 5: Clamp to range (if enabled)
    if (clampToRange && (minValue != null || maxValue != null)) {
      validData = _clampToRange(validData, warnings);
    }

    // Step 6: Final validation
    if (validData.isEmpty) {
      errors.add(
        ValidationError(
          code: 'NO_VALID_DATA',
          message: 'No valid data points after cleaning',
          severity: ErrorSeverity.critical,
        ),
      );
    }

    // Calculate statistics
    final stats = _calculateStatistics(validData);

    return ValidationResult(
      originalCount: data.length,
      validCount: validData.length,
      validData: validData,
      errors: errors,
      warnings: warnings,
      statistics: stats,
    );
  }

  // ==========================================================================
  // VALIDATION STEPS
  // ==========================================================================

  /// Removes invalid values (NaN, Infinity, null).
  List<FusionDataPoint> _removeInvalidValues(
    List<FusionDataPoint> data,
    List<ValidationError> errors,
  ) {
    final valid = <FusionDataPoint>[];
    int nanCount = 0;
    int infinityCount = 0;

    for (final point in data) {
      bool isValid = true;

      // Check for NaN
      if (point.x.isNaN || point.y.isNaN) {
        if (removeNaN) {
          isValid = false;
          nanCount++;
        }
      }

      // Check for Infinity
      if (point.x.isInfinite || point.y.isInfinite) {
        if (removeInfinity) {
          isValid = false;
          infinityCount++;
        }
      }

      if (isValid) {
        valid.add(point);
      }
    }

    // Report errors
    if (nanCount > 0) {
      errors.add(
        ValidationError(
          code: 'NAN_VALUES',
          message: 'Found $nanCount NaN values',
          severity: ErrorSeverity.warning,
          details: {'count': nanCount},
        ),
      );
    }

    if (infinityCount > 0) {
      errors.add(
        ValidationError(
          code: 'INFINITY_VALUES',
          message: 'Found $infinityCount Infinity values',
          severity: ErrorSeverity.warning,
          details: {'count': infinityCount},
        ),
      );
    }

    return valid;
  }

  /// Removes duplicate X values (keeps first occurrence).
  List<FusionDataPoint> _removeDuplicates(List<FusionDataPoint> data) {
    final seen = <double>{};
    final unique = <FusionDataPoint>[];

    for (final point in data) {
      if (!seen.contains(point.x)) {
        seen.add(point.x);
        unique.add(point);
      }
    }

    return unique;
  }

  /// Sorts data by X value.
  List<FusionDataPoint> _sortByX(List<FusionDataPoint> data) {
    final sorted = List<FusionDataPoint>.from(data);
    sorted.sort((a, b) => a.x.compareTo(b.x));
    return sorted;
  }

  /// Interpolates missing values.
  List<FusionDataPoint> _interpolateMissing(
    List<FusionDataPoint> data,
    List<ValidationWarning> warnings,
  ) {
    if (data.length < 2) return data;

    final result = <FusionDataPoint>[];

    for (int i = 0; i < data.length - 1; i++) {
      result.add(data[i]);

      // Check for gap
      final current = data[i];
      final next = data[i + 1];
      final gap = next.x - current.x;

      // If gap is larger than expected, interpolate
      if (gap > 1.5) {
        final steps = gap.round();
        for (int j = 1; j < steps; j++) {
          final t = j / steps;
          final interpolatedX = current.x + (gap * t);
          final interpolatedY = current.y + ((next.y - current.y) * t);

          result.add(
            FusionDataPoint(
              interpolatedX,
              interpolatedY,
              label: 'Interpolated',
            ),
          );
        }

        warnings.add(
          ValidationWarning(
            code: 'VALUES_INTERPOLATED',
            message:
                'Interpolated ${steps - 1} values between x=${current.x} and x=${next.x}',
          ),
        );
      }
    }

    result.add(data.last);
    return result;
  }

  /// Clamps values to specified range.
  List<FusionDataPoint> _clampToRange(
    List<FusionDataPoint> data,
    List<ValidationWarning> warnings,
  ) {
    final result = <FusionDataPoint>[];
    int clampedCount = 0;

    for (final point in data) {
      double y = point.y;

      if (minValue != null && y < minValue!) {
        y = minValue!;
        clampedCount++;
      }

      if (maxValue != null && y > maxValue!) {
        y = maxValue!;
        clampedCount++;
      }

      result.add(FusionDataPoint(point.x, y, label: point.label));
    }

    if (clampedCount > 0) {
      warnings.add(
        ValidationWarning(
          code: 'VALUES_CLAMPED',
          message:
              'Clamped $clampedCount values to range [$minValue, $maxValue]',
        ),
      );
    }

    return result;
  }

  /// Calculates statistics about the data.
  DataStatistics _calculateStatistics(List<FusionDataPoint> data) {
    if (data.isEmpty) {
      return const DataStatistics();
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    double sumY = 0;

    for (final point in data) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
      sumY += point.y;
    }

    final meanY = sumY / data.length;

    // Calculate standard deviation
    double varianceSum = 0;
    for (final point in data) {
      varianceSum += math.pow(point.y - meanY, 2);
    }
    final stdDevY = math.sqrt(varianceSum / data.length);

    return DataStatistics(
      count: data.length,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      meanY: meanY,
      stdDevY: stdDevY,
      rangeX: maxX - minX,
      rangeY: maxY - minY,
    );
  }
}

// =============================================================================
// RESULT CLASSES
// =============================================================================

/// Result of data validation.
class ValidationResult {
  const ValidationResult({
    required this.originalCount,
    required this.validCount,
    required this.validData,
    required this.errors,
    required this.warnings,
    this.statistics,
  });

  /// Number of original data points.
  final int originalCount;

  /// Number of valid data points after cleaning.
  final int validCount;

  /// Cleaned, valid data points.
  final List<FusionDataPoint> validData;

  /// List of validation errors.
  final List<ValidationError> errors;

  /// List of validation warnings.
  final List<ValidationWarning> warnings;

  /// Statistics about the valid data.
  final DataStatistics? statistics;

  /// Whether validation found any errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Whether validation found any warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Whether data is usable (has valid points and no critical errors).
  bool get isUsable => validCount > 0 && !hasCriticalErrors;

  /// Whether there are critical errors.
  bool get hasCriticalErrors =>
      errors.any((e) => e.severity == ErrorSeverity.critical);

  /// Percentage of data that was valid.
  double get validPercentage =>
      originalCount > 0 ? (validCount / originalCount) * 100 : 0;
}

/// Validation error information.
class ValidationError {
  const ValidationError({
    required this.code,
    required this.message,
    required this.severity,
    this.details,
  });

  /// Error code for programmatic handling.
  final String code;

  /// Human-readable error message.
  final String message;

  /// Severity of the error.
  final ErrorSeverity severity;

  /// Additional error details.
  final Map<String, dynamic>? details;
}

/// Validation warning information.
class ValidationWarning {
  const ValidationWarning({
    required this.code,
    required this.message,
    this.details,
  });

  /// Warning code.
  final String code;

  /// Human-readable warning message.
  final String message;

  /// Additional warning details.
  final Map<String, dynamic>? details;
}

/// Error severity levels.
enum ErrorSeverity {
  /// Information only.
  info,

  /// Warning - data is usable but has issues.
  warning,

  /// Error - some data is unusable.
  error,

  /// Critical - data is completely unusable.
  critical,
}

/// Statistics about the dataset.
class DataStatistics {
  const DataStatistics({
    this.count = 0,
    this.minX = 0,
    this.maxX = 0,
    this.minY = 0,
    this.maxY = 0,
    this.meanY = 0,
    this.stdDevY = 0,
    this.rangeX = 0,
    this.rangeY = 0,
  });

  /// Number of data points.
  final int count;

  /// Minimum X value.
  final double minX;

  /// Maximum X value.
  final double maxX;

  /// Minimum Y value.
  final double minY;

  /// Maximum Y value.
  final double maxY;

  /// Mean (average) Y value.
  final double meanY;

  /// Standard deviation of Y values.
  final double stdDevY;

  /// Range of X values (max - min).
  final double rangeX;

  /// Range of Y values (max - min).
  final double rangeY;
}

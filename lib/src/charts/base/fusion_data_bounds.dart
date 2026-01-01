import '../../data/fusion_data_point.dart';

/// Represents calculated data bounds for coordinate system creation.
///
/// This immutable value class encapsulates all the boundary information
/// needed to create a [FusionCoordinateSystem].
///
/// ## Usage
///
/// ```dart
/// // For line charts (continuous data)
/// final bounds = FusionDataBounds.fromPoints(allPoints);
///
/// // For bar charts (category data)
/// final bounds = FusionDataBounds.forCategories(
///   categoryCount: 5,
///   maxY: 100,
/// );
///
/// // For stacked bar charts
/// final bounds = FusionDataBounds.forStacked(
///   categoryCount: 5,
///   stackedMaxY: 250,
///   isStacked100: false,
/// );
/// ```
class FusionDataBounds {
  const FusionDataBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    this.marginMinX,
    this.marginMaxX,
  });

  /// Creates bounds from a list of data points.
  ///
  /// Automatically calculates min/max from the points.
  /// Uses "nice" bounds (starts from 0 if data is positive).
  ///
  /// Returns default bounds if points list is empty.
  factory FusionDataBounds.fromPoints(List<FusionDataPoint> points) {
    if (points.isEmpty) {
      return const FusionDataBounds(minX: 0, maxX: 10, minY: 0, maxY: 100);
    }

    final dataMinX = points.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final dataMaxX = points.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final dataMinY = points.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final dataMaxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    // Use "nice" bounds - start from 0 if data is positive
    return FusionDataBounds(
      minX: dataMinX >= 0 ? 0.0 : dataMinX,
      maxX: dataMaxX,
      minY: dataMinY >= 0 ? 0.0 : dataMinY,
      maxY: dataMaxY,
    );
  }

  /// Creates bounds for category-based charts (bar charts).
  ///
  /// Uses -0.5 to categoryCount-0.5 for proper bar centering.
  /// Adds 10% padding to maxY for visual breathing room.
  factory FusionDataBounds.forCategories({
    required int categoryCount,
    required double maxY,
    double yPaddingFactor = 0.1,
  }) {
    final effectiveCount = categoryCount > 0 ? categoryCount : 1;
    final paddedMaxY = maxY * (1 + yPaddingFactor);

    return FusionDataBounds(
      minX: -0.5,
      maxX: effectiveCount - 0.5,
      minY: 0,
      maxY: paddedMaxY > 0 ? paddedMaxY : 100,
      // For margin calculation, use actual label positions (0 to count-1)
      marginMinX: 0,
      marginMaxX: (effectiveCount - 1).toDouble(),
    );
  }

  /// Creates bounds for stacked bar charts.
  ///
  /// Similar to [forCategories] but handles 100% stacking mode.
  factory FusionDataBounds.forStacked({
    required int categoryCount,
    required double stackedMaxY,
    required bool isStacked100,
    double yPaddingFactor = 0.1,
  }) {
    final effectiveCount = categoryCount > 0 ? categoryCount : 1;

    // For 100% stacking, Y axis is always 0-100
    final maxY = isStacked100 ? 100.0 : stackedMaxY * (1 + yPaddingFactor);

    return FusionDataBounds(
      minX: -0.5,
      maxX: effectiveCount - 0.5,
      minY: 0,
      maxY: maxY > 0 ? maxY : 100,
      marginMinX: 0,
      marginMaxX: (effectiveCount - 1).toDouble(),
    );
  }

  /// Minimum X value for coordinate system.
  final double minX;

  /// Maximum X value for coordinate system.
  final double maxX;

  /// Minimum Y value for coordinate system.
  final double minY;

  /// Maximum Y value for coordinate system.
  final double maxY;

  /// Optional: X value to use for left margin calculation.
  /// Used when label overflow calculation differs from data bounds.
  /// Falls back to [minX] if not specified.
  final double? marginMinX;

  /// Optional: X value to use for right margin calculation.
  /// Used when label overflow calculation differs from data bounds.
  /// Falls back to [maxX] if not specified.
  final double? marginMaxX;

  /// Gets the effective margin minX (falls back to minX).
  double get effectiveMarginMinX => marginMinX ?? minX;

  /// Gets the effective margin maxX (falls back to maxX).
  double get effectiveMarginMaxX => marginMaxX ?? maxX;

  /// Returns the X range (maxX - minX).
  double get xRange => maxX - minX;

  /// Returns the Y range (maxY - minY).
  double get yRange => maxY - minY;

  /// Creates a copy with modified values.
  FusionDataBounds copyWith({
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    double? marginMinX,
    double? marginMaxX,
  }) {
    return FusionDataBounds(
      minX: minX ?? this.minX,
      maxX: maxX ?? this.maxX,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
      marginMinX: marginMinX ?? this.marginMinX,
      marginMaxX: marginMaxX ?? this.marginMaxX,
    );
  }

  /// Expands bounds to include additional padding.
  FusionDataBounds withPadding({double xPadding = 0, double yPadding = 0}) {
    return FusionDataBounds(
      minX: minX - xPadding,
      maxX: maxX + xPadding,
      minY: minY - yPadding,
      maxY: maxY + yPadding,
      marginMinX: marginMinX,
      marginMaxX: marginMaxX,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionDataBounds &&
        other.minX == minX &&
        other.maxX == maxX &&
        other.minY == minY &&
        other.maxY == maxY &&
        other.marginMinX == marginMinX &&
        other.marginMaxX == marginMaxX;
  }

  @override
  int get hashCode {
    return Object.hash(minX, maxX, minY, maxY, marginMinX, marginMaxX);
  }

  @override
  String toString() {
    return 'FusionDataBounds(x: $minX..$maxX, y: $minY..$maxY)';
  }
}

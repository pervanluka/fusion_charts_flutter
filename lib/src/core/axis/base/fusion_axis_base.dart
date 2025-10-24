import 'package:flutter/material.dart';

/// Abstract base class for all axis types.
///
/// Contains only essential properties shared across all axes:
/// - Numeric, Category, DateTime, Logarithmic
///
/// All styling and visibility properties have been moved to [FusionAxisConfiguration].
/// This keeps the axis definition clean and separates concerns.
///
/// ## Architecture
///
/// - [FusionAxisBase] - Defines WHAT kind of axis (numeric, category, etc.)
/// - [FusionAxisConfiguration] - Defines HOW it looks and behaves (styling, visibility)
/// - [FusionAxisRenderer] - Renders the axis using both definition and configuration
abstract class FusionAxisBase {
  const FusionAxisBase({
    // Identification
    this.name,

    // Title
    this.title,
    this.titleStyle,

    // Position & Orientation
    this.opposedPosition = false,
    this.isInversed = false,
  });

  // ==========================================================================
  // IDENTIFICATION
  // ==========================================================================

  /// Name of the axis (for multiple axes scenarios).
  ///
  /// Used to identify specific axes when you have multiple axes of the same type.
  /// For example: 'primaryYAxis', 'secondaryYAxis'
  final String? name;

  // ==========================================================================
  // TITLE
  // ==========================================================================

  /// Title text for the axis.
  ///
  /// Example: 'Revenue ($)', 'Temperature (°C)', 'Time (seconds)'
  final String? title;

  /// Text style for the title.
  ///
  /// If null, uses theme's default title style.
  final TextStyle? titleStyle;

  // ==========================================================================
  // POSITION & ORIENTATION
  // ==========================================================================

  /// Whether to position axis on opposite side.
  ///
  /// - X-axis: false = bottom, true = top
  /// - Y-axis: false = left, true = right
  ///
  /// Default: false
  final bool opposedPosition;

  /// Whether to inverse the axis direction.
  ///
  /// When true:
  /// - X-axis: values go from right to left
  /// - Y-axis: values go from top to bottom
  ///
  /// Useful for charts like population pyramids or reversed timelines.
  ///
  /// Default: false
  final bool isInversed;

  // ==========================================================================
  // COPY WITH (to be overridden by subclasses)
  // ==========================================================================

  /// Creates a copy with updated values.
  ///
  /// Subclasses should override this to include their specific properties.
  FusionAxisBase copyWith();

  // ==========================================================================
  // EQUALITY & HASH
  // ==========================================================================

  @override
  String toString() => 'FusionAxisBase(name: $name, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FusionAxisBase &&
        other.name == name &&
        other.title == title &&
        other.opposedPosition == opposedPosition &&
        other.isInversed == isInversed;
  }

  @override
  int get hashCode {
    return Object.hash(name, title, opposedPosition, isInversed);
  }
}

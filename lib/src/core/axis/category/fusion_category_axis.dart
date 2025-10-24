import 'package:flutter/material.dart';
import '../../enums/label_alignment.dart';
import '../base/fusion_axis_base.dart';

/// Category axis for displaying discrete labeled data.
///
/// Perfect for bar charts, column charts, and other categorical visualizations
/// where the X or Y axis shows named categories rather than continuous numbers.
///
/// ## Example
///
/// ```dart
/// final axis = FusionCategoryAxis(
///   categories: ['Q1', 'Q2', 'Q3', 'Q4'],
///   title: 'Quarter',
/// );
/// ```
class FusionCategoryAxis extends FusionAxisBase {
  /// Creates a category axis.
  const FusionCategoryAxis({
    // Base properties
    super.name,
    super.title,
    super.titleStyle,
    super.opposedPosition,
    super.isInversed,

    // Category-specific
    required this.categories,
    this.labelAlignment = LabelAlignment.center,
  }) : assert(categories.length > 0, 'Categories cannot be empty');

  /// The list of category labels to display.
  ///
  /// Example: ['Jan', 'Feb', 'Mar'], ['Product A', 'Product B']
  final List<String> categories;

  /// Label alignment relative to category position.
  final LabelAlignment labelAlignment;

  /// Number of categories.
  int get categoryCount => categories.length;

  /// Gets the index of a category by name.
  int? getCategoryIndex(String category) {
    final index = categories.indexOf(category);
    return index >= 0 ? index : null;
  }

  /// Gets the category name at an index.
  String? getCategoryAt(int index) {
    if (index >= 0 && index < categories.length) {
      return categories[index];
    }
    return null;
  }

  @override
  FusionCategoryAxis copyWith({
    String? name,
    String? title,
    TextStyle? titleStyle,
    bool? opposedPosition,
    bool? isInversed,
    List<String>? categories,
    LabelAlignment? labelAlignment,
  }) {
    return FusionCategoryAxis(
      name: name ?? this.name,
      title: title ?? this.title,
      titleStyle: titleStyle ?? this.titleStyle,
      opposedPosition: opposedPosition ?? this.opposedPosition,
      isInversed: isInversed ?? this.isInversed,
      categories: categories ?? this.categories,
      labelAlignment: labelAlignment ?? this.labelAlignment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionCategoryAxis &&
        other.name == name &&
        other.title == title &&
        other.opposedPosition == opposedPosition &&
        other.isInversed == isInversed &&
        _listEquals(other.categories, categories) &&
        other.labelAlignment == labelAlignment;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    name,
    title,
    opposedPosition,
    isInversed,
    Object.hashAll(categories),
    labelAlignment,
  );

  @override
  String toString() => 'FusionCategoryAxis(categories: ${categories.length})';
}

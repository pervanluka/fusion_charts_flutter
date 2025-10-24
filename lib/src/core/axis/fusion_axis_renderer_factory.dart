import '../../configuration/fusion_axis_configuration.dart';
import 'base/fusion_axis_renderer.dart';
import 'base/fusion_axis_base.dart';
import 'category/category_axis_renderer.dart';
import 'category/fusion_category_axis.dart';
import 'datetime/fusion_datetime_axis.dart';
import 'datetime/fusion_datetime_axis_renderer.dart';
import 'numeric/fusion_numeric_axis.dart';
import 'numeric/numeric_axis_renderer.dart';

/// Factory for creating axis renderers based on axis type.
///
/// This is the KEY class that bridges axis definitions with renderers.
/// It analyzes the axis type and creates the appropriate renderer.
///
/// ## Architecture Flow
///
/// ```
/// FusionAxisBase (definition)
///       ↓
/// FusionAxisRendererFactory.create()
///       ↓
///   ┌───┴───────────┐
///   │               │
/// Numeric    Category    DateTime
/// Renderer   Renderer    Renderer
/// ```
class FusionAxisRendererFactory {
  /// Creates the appropriate renderer for an axis.
  ///
  /// ## Parameters
  /// - [axis]: The axis definition (numeric, category, or datetime)
  /// - [configuration]: Styling and behavior configuration
  /// - [isVertical]: Whether this is a vertical axis (Y-axis)
  ///
  /// ## Returns
  /// The appropriate FusionAxisRenderer subclass
  static FusionAxisRenderer create({
    required FusionAxisBase? axis,
    required FusionAxisConfiguration configuration,
    bool isVertical = false,
  }) {
    // If no axis provided, default to numeric
    if (axis == null) {
      return NumericAxisRenderer(
        axis: const FusionNumericAxis(),
        configuration: configuration,
        isVertical: isVertical,
      );
    }

    // Create renderer based on axis type
    if (axis is FusionNumericAxis) {
      return NumericAxisRenderer(axis: axis, configuration: configuration, isVertical: isVertical);
    } else if (axis is FusionCategoryAxis) {
      return CategoryAxisRenderer(
        categories: axis.categories,
        configuration: configuration,
        isVertical: isVertical,
      );
    } else if (axis is FusionDateTimeAxis) {
      return DateTimeAxisRenderer(axis: axis, configuration: configuration, isVertical: isVertical);
    } else {
      // Fallback to numeric for unknown types
      return NumericAxisRenderer(
        axis: const FusionNumericAxis(),
        configuration: configuration,
        isVertical: isVertical,
      );
    }
  }
}

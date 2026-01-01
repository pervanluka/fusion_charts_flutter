/// Arguments passed to custom axis label rendering callbacks.
class AxisLabelRenderArgs {
  /// Creates axis label render arguments.
  const AxisLabelRenderArgs({
    required this.text,
    required this.value,
    required this.index,
  });

  /// The label text to render.
  final String text;

  /// The numeric value of this label.
  final double value;

  /// The index of this label in the axis.
  final int index;
}

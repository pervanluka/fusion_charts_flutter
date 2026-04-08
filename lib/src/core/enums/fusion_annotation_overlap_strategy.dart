/// Strategy for resolving overlap between annotation labels and data labels.
enum FusionAnnotationOverlapStrategy {
  /// Annotation badge shown, overlapping data label suppressed.
  annotationWins,

  /// Data label shown, annotation badge hidden (dashed line still visible).
  dataLabelWins,

  /// Both shown but annotation badge offset vertically to avoid overlap.
  offset,

  /// Both shown at exact position (developer accepts potential overlap).
  showBoth,
}

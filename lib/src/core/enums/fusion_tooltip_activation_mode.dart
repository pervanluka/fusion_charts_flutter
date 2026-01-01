enum FusionTooltipActivationMode {
  /// Show on single tap (mobile default)
  singleTap,

  /// Show on long press (for dense data)
  longPress,

  /// Show on double tap (prevents accidental activation)
  doubleTap,

  /// Show on hover (desktop/web default)
  hover,

  /// Context-aware activation
  /// Auto-detects platform and uses best mode:
  /// - Mobile/Tablet: singleTap
  /// - Desktop/Web: hover
  auto,

  /// Disable automatic activation (programmatic only)
  none,
}

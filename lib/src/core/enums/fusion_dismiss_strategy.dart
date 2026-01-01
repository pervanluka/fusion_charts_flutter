enum FusionDismissStrategy {
  /// ⚡ Dismiss immediately when finger/pointer lifts (BEST UX)
  /// This is what users expect on mobile!
  onRelease,

  /// ⏱️ Dismiss after duration timer
  /// Timer starts when tooltip appears
  onTimer,

  /// 🎯 Dismiss after delay from release (hybrid approach)
  /// Shows tooltip while touching + brief delay after release
  onReleaseDelayed,

  /// 🔒 Never dismiss (manual hide only)
  never,

  /// 🧠 Smart dismiss - adapts to user interaction
  /// - Quick tap: dismiss on release
  /// - Long press: persist with timer
  smart,
}

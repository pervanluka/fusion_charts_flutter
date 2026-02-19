import 'package:flutter/material.dart';
import '../core/enums/fusion_dismiss_strategy.dart';
import '../data/fusion_data_point.dart';

/// Signature for formatting crosshair axis labels.
///
/// [value] is the raw numeric value (X or Y coordinate).
/// [point] is the snapped data point, if available.
///
/// ## Example - Timestamp formatting
///
/// ```dart
/// xLabelFormatter: (value, point) {
///   final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
///   return '${date.hour}:${date.minute}:${date.second}';
/// }
/// ```
///
/// ## Example - Currency formatting
///
/// ```dart
/// yLabelFormatter: (value, point) => '\$${value.toStringAsFixed(2)}';
/// ```
typedef FusionCrosshairLabelFormatter =
    String Function(double value, FusionDataPoint? point);

/// Signature for building a custom crosshair label widget.
///
/// Allows complete control over the crosshair label appearance.
/// Return `null` to use the default label rendering.
///
/// ## Example
///
/// ```dart
/// labelBuilder: (context, point, isXAxis) {
///   if (isXAxis) {
///     final time = DateTime.fromMillisecondsSinceEpoch(point!.x.toInt());
///     return Container(
///       padding: EdgeInsets.all(4),
///       decoration: BoxDecoration(
///         color: Colors.blue,
///         borderRadius: BorderRadius.circular(4),
///       ),
///       child: Text(
///         '${time.hour}:${time.minute}:${time.second}',
///         style: TextStyle(color: Colors.white, fontSize: 10),
///       ),
///     );
///   }
///   return null; // Use default for Y axis
/// }
/// ```
typedef FusionCrosshairLabelBuilder =
    Widget? Function(
      BuildContext context,
      FusionDataPoint? point,
      bool isXAxis,
    );

/// Configuration for chart crosshair.
///
/// ## Example - Financial Chart
///
/// ```dart
/// final crosshairConfig = FusionCrosshairConfiguration(
///   activationMode: FusionCrosshairActivationMode.longPress,
///
///   // Control how crosshair dismisses!
///   dismissStrategy: FusionDismissStrategy.onTimer,
///   duration: Duration(seconds: 5), // Persist 5s for analysis
///
///   lineColor: Colors.grey.withOpacity(0.8),
///   lineDashArray: [5, 5],
///   snapToDataPoint: true,
/// );
/// ```
///
/// ## Example - Live Chart with Timestamp Formatting
///
/// ```dart
/// final crosshairConfig = FusionCrosshairConfiguration(
///   // Format X axis labels (timestamps) as HH:MM:SS
///   xLabelFormatter: (value, point) {
///     final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
///     return '${date.hour.toString().padLeft(2, '0')}:'
///            '${date.minute.toString().padLeft(2, '0')}:'
///            '${date.second.toString().padLeft(2, '0')}';
///   },
///   // Format Y axis labels as currency
///   yLabelFormatter: (value, point) => '\$${value.toStringAsFixed(2)}',
/// );
/// ```
///
/// ## Example - Desktop Analytics
///
/// ```dart
/// final crosshairConfig = FusionCrosshairConfiguration(
///   activationMode: FusionCrosshairActivationMode.hover,
///
///   // Brief linger after mouse moves away
///   dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
///   dismissDelay: Duration(milliseconds: 300),
/// );
/// ```
@immutable
class FusionCrosshairConfiguration {
  /// Creates a crosshair configuration.
  const FusionCrosshairConfiguration({
    // Core
    this.activationMode = FusionCrosshairActivationMode.longPress,
    this.dismissStrategy = FusionDismissStrategy.onRelease,
    this.dismissDelay = const Duration(milliseconds: 300),
    this.duration = const Duration(milliseconds: 3000),

    // Snapping
    this.snapToDataPoint = true,

    // Line appearance
    this.lineColor,
    this.lineWidth = 1.0,
    this.lineDashArray,
    this.showHorizontalLine = true,
    this.showVerticalLine = true,

    // Label appearance
    this.showLabel = true,
    this.labelBackgroundColor,
    this.labelTextStyle,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.labelBorderRadius = 4.0,

    // Label formatting
    this.xLabelFormatter,
    this.yLabelFormatter,
    this.labelBuilder,

    // Animation
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.exitAnimationCurve = Curves.easeInCubic,

    // Advanced
    this.fadeOutOnPanZoom = true,
  }) : assert(lineWidth > 0, 'lineWidth must be positive. Got: $lineWidth'),
       assert(
         labelBorderRadius >= 0,
         'labelBorderRadius must be non-negative. Got: $labelBorderRadius',
       );

  // ==========================================================================
  // VISIBILITY & INTERACTION
  // ==========================================================================

  /// How the crosshair is activated.
  final FusionCrosshairActivationMode activationMode;

  // ==========================================================================
  // DISMISS CONTROL
  // ==========================================================================

  /// Strategy for dismissing crosshair.
  ///
  /// **onRelease** (default) - Dismiss when finger/pointer lifts
  /// **onTimer** - Show for [duration] then dismiss
  /// **onReleaseDelayed** - Brief delay after release
  /// **never** - Manual hide only
  /// **smart** - Adapts to interaction (quick vs long press)
  final FusionDismissStrategy dismissStrategy;

  /// Additional delay before dismissing (for onReleaseDelayed).
  final Duration dismissDelay;

  /// Duration to display crosshair (for onTimer strategy).
  final Duration duration;

  // ==========================================================================
  // SNAPPING & POSITIONING
  // ==========================================================================

  /// Whether to snap crosshair to nearest data point.
  ///
  /// When true, crosshair locks to actual data points.
  /// When false, crosshair follows touch/mouse position freely.
  final bool snapToDataPoint;

  // ==========================================================================
  // LINE APPEARANCE
  // ==========================================================================

  /// Whether to show horizontal line.
  final bool showHorizontalLine;

  /// Whether to show vertical line.
  final bool showVerticalLine;

  /// Color of the crosshair lines.
  final Color? lineColor;

  /// Width of the crosshair lines.
  final double lineWidth;

  /// Dash pattern for the crosshair lines.
  ///
  /// Example: `[5, 5]` creates dashed lines (5px line, 5px gap).
  final List<double>? lineDashArray;

  // ==========================================================================
  // LABEL APPEARANCE
  // ==========================================================================

  /// Whether to show axis value labels.
  final bool showLabel;

  /// Background color of the crosshair labels.
  final Color? labelBackgroundColor;

  /// Text style for the crosshair labels.
  final TextStyle? labelTextStyle;

  /// Padding inside the crosshair labels.
  final EdgeInsets labelPadding;

  /// Corner radius of the crosshair labels.
  final double labelBorderRadius;

  // ==========================================================================
  // LABEL FORMATTING
  // ==========================================================================

  /// Formatter for the X-axis crosshair label.
  ///
  /// Use this to format timestamps, add units, or customize the display.
  /// If not provided, uses the data point's label or the raw X value.
  ///
  /// ## Example - Timestamp formatting
  ///
  /// ```dart
  /// xLabelFormatter: (value, point) {
  ///   final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
  ///   return '${date.hour}:${date.minute}:${date.second}';
  /// }
  /// ```
  final FusionCrosshairLabelFormatter? xLabelFormatter;

  /// Formatter for the Y-axis crosshair label.
  ///
  /// Use this to add units, format decimals, or customize the display.
  /// If not provided, displays the Y value with 1 decimal place.
  ///
  /// ## Example - Currency formatting
  ///
  /// ```dart
  /// yLabelFormatter: (value, point) => '\$${value.toStringAsFixed(2)}';
  /// ```
  final FusionCrosshairLabelFormatter? yLabelFormatter;

  /// Custom builder for crosshair labels.
  ///
  /// Provides complete control over label appearance.
  /// Return `null` to use the default label rendering.
  ///
  /// When set, takes precedence over [xLabelFormatter] and [yLabelFormatter].
  final FusionCrosshairLabelBuilder? labelBuilder;

  // ==========================================================================
  // ANIMATION PROPERTIES
  // ==========================================================================

  /// Animation duration for show/hide.
  final Duration animationDuration;

  /// Easing curve for enter animation.
  final Curve animationCurve;

  /// Easing curve for exit animation.
  final Curve exitAnimationCurve;

  // ==========================================================================
  // ADVANCED PROPERTIES
  // ==========================================================================

  /// Fade out crosshair during pan/zoom gestures.
  final bool fadeOutOnPanZoom;

  // ==========================================================================
  // 🚀 HELPER METHODS (Matching Tooltip Pattern!)
  // ==========================================================================

  /// Should dismiss on pointer release?
  bool shouldDismissOnRelease() {
    return dismissStrategy == FusionDismissStrategy.onRelease ||
        dismissStrategy == FusionDismissStrategy.onReleaseDelayed ||
        dismissStrategy == FusionDismissStrategy.smart;
  }

  /// Should use timer for dismissal?
  bool shouldUseTimer() {
    return dismissStrategy == FusionDismissStrategy.onTimer ||
        dismissStrategy == FusionDismissStrategy.smart;
  }

  /// Get dismiss delay duration based on interaction type.
  Duration getDismissDelay(bool wasLongPress) {
    switch (dismissStrategy) {
      case FusionDismissStrategy.onRelease:
        return Duration.zero;

      case FusionDismissStrategy.onReleaseDelayed:
        return dismissDelay;

      case FusionDismissStrategy.onTimer:
        return duration;

      case FusionDismissStrategy.never:
        return const Duration(days: 365); // Effectively never

      case FusionDismissStrategy.smart:
        // Smart behavior: long press = persist, quick tap = brief
        return wasLongPress ? duration : dismissDelay;
    }
  }

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// Gets the effective line color.
  Color getEffectiveLineColor(BuildContext context, Color? themeColor) {
    return lineColor ?? themeColor ?? Colors.grey;
  }

  /// Gets the effective label background color.
  Color getEffectiveLabelBackgroundColor(BuildContext context) {
    return labelBackgroundColor ?? Colors.black87;
  }

  /// Gets the effective label text style.
  TextStyle getEffectiveLabelTextStyle(BuildContext context) {
    return labelTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
  }

  /// Gets the formatted X-axis label text.
  ///
  /// Uses [xLabelFormatter] if provided, otherwise falls back to
  /// the point's label or raw X value.
  String getFormattedXLabel(double xValue, FusionDataPoint? point) {
    if (xLabelFormatter != null) {
      return xLabelFormatter!(xValue, point);
    }
    return point?.label ?? xValue.toStringAsFixed(1);
  }

  /// Gets the formatted Y-axis label text.
  ///
  /// Uses [yLabelFormatter] if provided, otherwise displays
  /// the Y value with 1 decimal place.
  String getFormattedYLabel(double yValue, FusionDataPoint? point) {
    if (yLabelFormatter != null) {
      return yLabelFormatter!(yValue, point);
    }
    return yValue.toStringAsFixed(1);
  }

  // ==========================================================================
  // CONFIGURATION VALIDATION
  // ==========================================================================

  /// Validates the crosshair configuration and returns warnings for potentially
  /// confusing or suboptimal combinations.
  ///
  /// Call this method during development to check for configuration issues.
  /// Returns a list of warning messages. An empty list means the configuration
  /// is fully optimal.
  List<String> validateConfiguration() {
    final warnings = <String>[];

    // Check if both lines are hidden
    if (!showHorizontalLine && !showVerticalLine) {
      warnings.add(
        'Both showHorizontalLine and showVerticalLine are false. '
        'The crosshair will not display any lines.',
      );
    }

    // Check label configuration
    if (showLabel && labelBuilder != null) {
      if (xLabelFormatter != null || yLabelFormatter != null) {
        warnings.add(
          'labelBuilder is set along with xLabelFormatter/yLabelFormatter. '
          'labelBuilder takes precedence and formatters will be ignored.',
        );
      }
    }

    // Check lineDashArray
    if (lineDashArray != null && lineDashArray!.isEmpty) {
      warnings.add(
        'lineDashArray is empty. Use null for solid lines or provide '
        'a valid dash pattern like [5, 5].',
      );
    }

    // Check dismiss delay without appropriate strategy
    if (dismissDelay != const Duration(milliseconds: 300) &&
        dismissStrategy != FusionDismissStrategy.onReleaseDelayed &&
        dismissStrategy != FusionDismissStrategy.smart) {
      warnings.add(
        'dismissDelay is only used with dismissStrategy: onReleaseDelayed '
        'or smart. Current strategy (${dismissStrategy.name}) ignores this value.',
      );
    }

    // Check duration without appropriate strategy
    if (duration != const Duration(milliseconds: 3000) &&
        dismissStrategy != FusionDismissStrategy.onTimer &&
        dismissStrategy != FusionDismissStrategy.smart) {
      warnings.add(
        'duration is only used with dismissStrategy: onTimer or smart. '
        'Current strategy (${dismissStrategy.name}) ignores this value.',
      );
    }

    // Check activationMode none with dismissStrategy never
    if (activationMode == FusionCrosshairActivationMode.none &&
        dismissStrategy == FusionDismissStrategy.never) {
      warnings.add(
        'activationMode: none with dismissStrategy: never means crosshair '
        'can only be controlled programmatically. Ensure you have code '
        'to show/hide the crosshair.',
      );
    }

    // Check showLabel false with label customizations
    if (!showLabel) {
      if (labelBackgroundColor != null ||
          labelTextStyle != null ||
          xLabelFormatter != null ||
          yLabelFormatter != null ||
          labelBuilder != null) {
        warnings.add(
          'showLabel is false but label customizations are set. '
          'Label customizations will be ignored.',
        );
      }
    }

    return warnings;
  }

  /// Asserts that the configuration is valid for development builds.
  ///
  /// This validates runtime constraints that can't be checked at compile time.
  void assertValid() {
    // Validate lineDashArray values
    if (lineDashArray != null) {
      assert(
        lineDashArray!.isNotEmpty,
        'lineDashArray must not be empty if specified.',
      );
      assert(
        lineDashArray!.every((v) => v > 0),
        'lineDashArray values must all be positive.',
      );
    }
  }

  /// Returns documentation of all supported configuration combinations.
  static String get configurationGuide => '''
FusionCrosshairConfiguration Guide
===================================

## Activation Modes
- longPress (default): Activate on long press
- tap: Activate on tap/click
- hover: Activate on hover (desktop/web)
- always: Always show crosshair
- none: Programmatic control only

## Dismiss Strategies
- onRelease (default): Dismiss when finger lifts
- onTimer: Dismiss after duration
- onReleaseDelayed: Brief delay after release
- never: Manual hide only
- smart: Adapts to interaction pattern

## Line Configuration
- showHorizontalLine/showVerticalLine: Control which lines appear
- lineWidth: Thickness of crosshair lines
- lineColor: Color (defaults to theme)
- lineDashArray: Dash pattern like [5, 5]

## Label Configuration
- showLabel: Whether to show axis labels
- labelBuilder: Custom widget builder (takes precedence)
- xLabelFormatter/yLabelFormatter: Custom text formatters
- labelBackgroundColor, labelTextStyle, labelPadding, labelBorderRadius

## Recommended Configurations

### Financial Analysis
```dart
FusionCrosshairConfiguration(
  activationMode: FusionCrosshairActivationMode.longPress,
  dismissStrategy: FusionDismissStrategy.onTimer,
  duration: Duration(seconds: 5),
  snapToDataPoint: true,
)
```

### Desktop Hover
```dart
FusionCrosshairConfiguration(
  activationMode: FusionCrosshairActivationMode.hover,
  dismissStrategy: FusionDismissStrategy.onReleaseDelayed,
  dismissDelay: Duration(milliseconds: 300),
)
```

### Timestamp Chart
```dart
FusionCrosshairConfiguration(
  xLabelFormatter: (value, point) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateFormat.Hms().format(date);
  },
)
```
''';

  // ==========================================================================
  // METHODS
  // ==========================================================================

  /// Creates a copy with modified values.
  FusionCrosshairConfiguration copyWith({
    FusionCrosshairActivationMode? activationMode,
    FusionDismissStrategy? dismissStrategy,
    Duration? dismissDelay,
    Duration? duration,
    bool? snapToDataPoint,
    Color? lineColor,
    double? lineWidth,
    List<double>? lineDashArray,
    bool? showHorizontalLine,
    bool? showVerticalLine,
    bool? showLabel,
    Color? labelBackgroundColor,
    TextStyle? labelTextStyle,
    EdgeInsets? labelPadding,
    double? labelBorderRadius,
    FusionCrosshairLabelFormatter? xLabelFormatter,
    FusionCrosshairLabelFormatter? yLabelFormatter,
    FusionCrosshairLabelBuilder? labelBuilder,
    Duration? animationDuration,
    Curve? animationCurve,
    Curve? exitAnimationCurve,
    bool? fadeOutOnPanZoom,
  }) {
    return FusionCrosshairConfiguration(
      activationMode: activationMode ?? this.activationMode,
      dismissStrategy: dismissStrategy ?? this.dismissStrategy,
      dismissDelay: dismissDelay ?? this.dismissDelay,
      duration: duration ?? this.duration,
      snapToDataPoint: snapToDataPoint ?? this.snapToDataPoint,
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineDashArray: lineDashArray ?? this.lineDashArray,
      showHorizontalLine: showHorizontalLine ?? this.showHorizontalLine,
      showVerticalLine: showVerticalLine ?? this.showVerticalLine,
      showLabel: showLabel ?? this.showLabel,
      labelBackgroundColor: labelBackgroundColor ?? this.labelBackgroundColor,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      labelPadding: labelPadding ?? this.labelPadding,
      labelBorderRadius: labelBorderRadius ?? this.labelBorderRadius,
      xLabelFormatter: xLabelFormatter ?? this.xLabelFormatter,
      yLabelFormatter: yLabelFormatter ?? this.yLabelFormatter,
      labelBuilder: labelBuilder ?? this.labelBuilder,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      exitAnimationCurve: exitAnimationCurve ?? this.exitAnimationCurve,
      fadeOutOnPanZoom: fadeOutOnPanZoom ?? this.fadeOutOnPanZoom,
    );
  }

  @override
  String toString() =>
      'FusionCrosshairConfiguration('
      'activationMode: $activationMode, '
      'dismissStrategy: $dismissStrategy'
      ')';
}

/// How the crosshair is activated.
enum FusionCrosshairActivationMode {
  /// Activate on tap/click.
  tap,

  /// Activate on long press (default).
  longPress,

  /// Activate on hover (desktop/web only).
  hover,

  /// Always show crosshair.
  always,

  /// Never show crosshair.
  none,
}

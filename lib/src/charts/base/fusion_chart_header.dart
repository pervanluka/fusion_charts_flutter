import 'package:flutter/material.dart';
import '../../themes/fusion_chart_theme.dart';

/// Shared chart title widget used across all chart types.
///
/// Provides consistent styling and spacing for chart titles,
/// using [FusionChartTheme] for proper theme integration.
///
/// ## Usage
///
/// ```dart
/// FusionChartTitle(
///   title: 'Sales Overview',
///   theme: config.theme,
/// )
/// ```
class FusionChartTitle extends StatelessWidget {
  const FusionChartTitle({
    required this.title,
    required this.theme,
    super.key,
    this.style,
    this.padding = const EdgeInsets.only(bottom: 8),
    this.textAlign = TextAlign.center,
  });

  /// The title text to display.
  final String title;

  /// The chart theme providing default styles.
  final FusionChartTheme theme;

  /// Optional custom text style. If null, uses [theme.titleStyle].
  final TextStyle? style;

  /// Padding around the title. Defaults to bottom padding of 8.
  final EdgeInsets padding;

  /// Text alignment. Defaults to center.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: style ?? theme.titleStyle,
        textAlign: textAlign,
      ),
    );
  }
}

/// Shared chart subtitle widget used across all chart types.
///
/// Provides consistent styling and spacing for chart subtitles,
/// using [FusionChartTheme] for proper theme integration.
///
/// ## Usage
///
/// ```dart
/// FusionChartSubtitle(
///   subtitle: 'Q1 2024 Results',
///   theme: config.theme,
/// )
/// ```
class FusionChartSubtitle extends StatelessWidget {
  const FusionChartSubtitle({
    required this.subtitle,
    required this.theme,
    super.key,
    this.style,
    this.padding = const EdgeInsets.only(bottom: 16),
    this.textAlign = TextAlign.center,
  });

  /// The subtitle text to display.
  final String subtitle;

  /// The chart theme providing default styles.
  final FusionChartTheme theme;

  /// Optional custom text style. If null, uses [theme.subtitleStyle].
  final TextStyle? style;

  /// Padding around the subtitle. Defaults to bottom padding of 16.
  final EdgeInsets padding;

  /// Text alignment. Defaults to center.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        subtitle,
        style: style ?? theme.subtitleStyle,
        textAlign: textAlign,
      ),
    );
  }
}

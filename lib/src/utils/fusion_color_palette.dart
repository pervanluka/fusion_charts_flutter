import 'package:flutter/material.dart';

/// Color palette for Fusion Charts.
@immutable
class FusionColorPalette {
  /// Creates a color palette from a list of colors.
  const FusionColorPalette(this.colors);

  /// The colors in this palette.
  final List<Color> colors;

  /// Gets color at index (cycles if index exceeds length).
  Color colorAt(int index) {
    if (colors.isEmpty) return Colors.grey;
    return colors[index % colors.length];
  }

  /// Number of colors in palette.
  int get length => colors.length;

  /// Creates gradient from two colors in this palette.
  LinearGradient gradient(int startIndex, int endIndex) {
    return LinearGradient(
      colors: [colorAt(startIndex), colorAt(endIndex)],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FusionColorPalette) return false;
    if (other.colors.length != colors.length) return false;
    for (int i = 0; i < colors.length; i++) {
      if (other.colors[i] != colors[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(colors);

  // ===========================================================================
  // COLOR LISTS (Static)
  // ===========================================================================

  /// Material Design colors.
  static const List<Color> materialColors = [
    Color(0xFF6C63FF),
    Color(0xFF4CAF50),
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
  ];

  /// Professional blue tones.
  static const List<Color> professionalColors = [
    Color(0xFF0D47A1),
    Color(0xFF1976D2),
    Color(0xFF2196F3),
    Color(0xFF42A5F5),
    Color(0xFF64B5F6),
    Color(0xFF90CAF9),
  ];

  /// Vibrant, high-energy colors.
  static const List<Color> vibrantColors = [
    Color(0xFFFF3366),
    Color(0xFF00D9FF),
    Color(0xFFFFD600),
    Color(0xFF00FF94),
    Color(0xFFFF00E5),
    Color(0xFF00F0FF),
  ];

  /// Soft pastel colors.
  static const List<Color> pastelColors = [
    Color(0xFFB4A7D6),
    Color(0xFFA8D5BA),
    Color(0xFFFFB4A2),
    Color(0xFFFFC09F),
    Color(0xFFAED8E6),
    Color(0xFFD5A6BD),
  ];

  /// Warm, friendly colors.
  static const List<Color> warmColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFF8E53),
    Color(0xFFFFC93C),
    Color(0xFFFFE66D),
    Color(0xFFFF8B94),
    Color(0xFFFFAB91),
  ];

  /// Cool, calm colors.
  static const List<Color> coolColors = [
    Color(0xFF4ECDC4),
    Color(0xFF44A8B3),
    Color(0xFF5C7AEA),
    Color(0xFF48A9A6),
    Color(0xFF7F9C96),
    Color(0xFF89B5AF),
  ];

  // ===========================================================================
  // PRESET PALETTES - Use factory getters (not const)
  // ===========================================================================

  /// Material Design inspired palette (default).
  static FusionColorPalette get material => const FusionColorPalette(materialColors);

  /// Professional business palette.
  static FusionColorPalette get professional => const FusionColorPalette(professionalColors);

  /// Vibrant, eye-catching palette.
  static FusionColorPalette get vibrant => const FusionColorPalette(vibrantColors);

  /// Soft pastel palette.
  static FusionColorPalette get pastel => const FusionColorPalette(pastelColors);

  /// Warm color palette.
  static FusionColorPalette get warm => const FusionColorPalette(warmColors);

  /// Cool color palette.
  static FusionColorPalette get cool => const FusionColorPalette(coolColors);

  // ===========================================================================
  // STATIC UTILITY METHODS
  // ===========================================================================

  /// Gets a color from a color list by index (cycles).
  static Color getColor(List<Color> colors, int index) {
    if (colors.isEmpty) return Colors.grey;
    return colors[index % colors.length];
  }

  /// Generates a gradient from two colors in a list.
  static LinearGradient generateGradient(
    List<Color> colors, {
    int startIndex = 0,
    int endIndex = 1,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [getColor(colors, startIndex), getColor(colors, endIndex)],
      begin: begin,
      end: end,
    );
  }

  /// Creates a lighter version of a color.
  static Color lightenColor(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Creates a darker version of a color.
  static Color darkenColor(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

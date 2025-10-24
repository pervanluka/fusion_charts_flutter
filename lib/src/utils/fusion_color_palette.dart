import 'package:flutter/material.dart';

/// Color palette manager for Fusion Charts.
///
/// Provides 6 professionally designed color palettes that work well
/// for data visualization. Each palette is:
/// - Color-blind friendly
/// - High contrast
/// - Aesthetically pleasing
/// - Suitable for both light and dark themes
///
/// Based on Material Design and Syncfusion color schemes.
///
/// ## Usage
///
/// ```dart
/// // Get a color from the material palette
/// final color = FusionColorPalette.getColor(
///   FusionColorPalette.material,
///   index,
/// );
///
/// // Use in multi-series charts
/// final series = List.generate(5, (i) {
///   return FusionLineSeries(
///     name: 'Series $i',
///     dataPoints: data[i],
///     color: FusionColorPalette.getColor(
///       FusionColorPalette.vibrant,
///       i,
///     ),
///   );
/// });
/// ```
class FusionColorPalette {
  // Private constructor - this is a utility class
  FusionColorPalette._();

  // ==========================================================================
  // MATERIAL PALETTE (Default)
  // ==========================================================================

  /// Material Design inspired palette.
  ///
  /// Professional, balanced colors suitable for business applications.
  /// This is the default palette used by Fusion Charts.
  ///
  /// Colors:
  /// 1. Purple (#6C63FF) - Primary, modern
  /// 2. Green (#4CAF50) - Success, growth
  /// 3. Red (#F44336) - Error, important
  /// 4. Orange (#FF9800) - Warning, attention
  /// 5. Blue (#2196F3) - Information, trust
  /// 6. Deep Purple (#9C27B0) - Accent, creativity
  static const List<Color> material = [
    Color(0xFF6C63FF),
    Color(0xFF4CAF50),
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
  ];

  // ==========================================================================
  // PROFESSIONAL PALETTE
  // ==========================================================================

  /// Professional business palette.
  ///
  /// Conservative, trustworthy colors for enterprise applications.
  /// Gradual progression from deep to light blue tones.
  ///
  /// Colors:
  /// 1. Deep Blue (#0D47A1)
  /// 2. Blue (#1976D2)
  /// 3. Light Blue (#2196F3)
  /// 4. Sky Blue (#42A5F5)
  /// 5. Pale Blue (#64B5F6)
  /// 6. Very Light Blue (#90CAF9)
  static const List<Color> professional = [
    Color(0xFF0D47A1),
    Color(0xFF1976D2),
    Color(0xFF2196F3),
    Color(0xFF42A5F5),
    Color(0xFF64B5F6),
    Color(0xFF90CAF9),
  ];

  // ==========================================================================
  // VIBRANT PALETTE
  // ==========================================================================

  /// Vibrant, eye-catching palette.
  ///
  /// High energy colors for modern, dynamic applications.
  /// Great for dashboards that need to grab attention.
  ///
  /// Colors:
  /// 1. Hot Pink (#FF3366)
  /// 2. Cyan (#00D9FF)
  /// 3. Yellow (#FFD600)
  /// 4. Mint (#00FF94)
  /// 5. Magenta (#FF00E5)
  /// 6. Bright Cyan (#00F0FF)
  static const List<Color> vibrant = [
    Color(0xFFFF3366),
    Color(0xFF00D9FF),
    Color(0xFFFFD600),
    Color(0xFF00FF94),
    Color(0xFFFF00E5),
    Color(0xFF00F0FF),
  ];

  // ==========================================================================
  // PASTEL PALETTE
  // ==========================================================================

  /// Soft pastel palette.
  ///
  /// Gentle, calming colors for elegant applications.
  /// Works well for reports and presentations.
  ///
  /// Colors:
  /// 1. Lavender (#B4A7D6)
  /// 2. Mint Green (#A8D5BA)
  /// 3. Peach (#FFB4A2)
  /// 4. Apricot (#FFC09F)
  /// 5. Baby Blue (#AED8E6)
  /// 6. Pink (#D5A6BD)
  static const List<Color> pastel = [
    Color(0xFFB4A7D6),
    Color(0xFFA8D5BA),
    Color(0xFFFFB4A2),
    Color(0xFFFFC09F),
    Color(0xFFAED8E6),
    Color(0xFFD5A6BD),
  ];

  // ==========================================================================
  // WARM PALETTE
  // ==========================================================================

  /// Warm color palette.
  ///
  /// Energetic, friendly colors creating a warm atmosphere.
  /// Great for data showing positive trends and growth.
  ///
  /// Colors:
  /// 1. Coral (#FF6B6B)
  /// 2. Orange (#FF8E53)
  /// 3. Gold (#FFC93C)
  /// 4. Lemon (#FFE66D)
  /// 5. Salmon (#FF8B94)
  /// 6. Light Coral (#FFAB91)
  static const List<Color> warm = [
    Color(0xFFFF6B6B),
    Color(0xFFFF8E53),
    Color(0xFFFFC93C),
    Color(0xFFFFE66D),
    Color(0xFFFF8B94),
    Color(0xFFFFAB91),
  ];

  // ==========================================================================
  // COOL PALETTE
  // ==========================================================================

  /// Cool color palette.
  ///
  /// Calm, professional colors with blue-green tones.
  /// Perfect for data related to stability and reliability.
  ///
  /// Colors:
  /// 1. Turquoise (#4ECDC4)
  /// 2. Teal (#44A8B3)
  /// 3. Periwinkle (#5C7AEA)
  /// 4. Seafoam (#48A9A6)
  /// 5. Sage (#7F9C96)
  /// 6. Aqua (#89B5AF)
  static const List<Color> cool = [
    Color(0xFF4ECDC4),
    Color(0xFF44A8B3),
    Color(0xFF5C7AEA),
    Color(0xFF48A9A6),
    Color(0xFF7F9C96),
    Color(0xFF89B5AF),
  ];

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Gets a color from a palette by index.
  ///
  /// If [index] exceeds palette length, wraps around using modulo.
  /// This ensures you always get a valid color.
  ///
  /// Example:
  /// ```dart
  /// final color0 = getColor(material, 0); // Purple
  /// final color1 = getColor(material, 1); // Green
  /// final color6 = getColor(material, 6); // Purple (wraps around)
  /// ```
  static Color getColor(List<Color> palette, int index) {
    assert(palette.isNotEmpty, 'Palette cannot be empty');
    assert(index >= 0, 'Index must be non-negative');
    return palette[index % palette.length];
  }

  /// Generates a gradient from two palette colors.
  ///
  /// Example:
  /// ```dart
  /// final gradient = generateGradient(
  ///   material,
  ///   startIndex: 0,
  ///   endIndex: 1,
  /// );
  /// // Creates gradient from Purple to Green
  /// ```
  static LinearGradient generateGradient(
    List<Color> palette, {
    int startIndex = 0,
    int endIndex = 1,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [getColor(palette, startIndex), getColor(palette, endIndex)],
      begin: begin,
      end: end,
    );
  }

  /// Generates a multi-stop gradient using multiple palette colors.
  ///
  /// Example:
  /// ```dart
  /// final gradient = generateMultiStopGradient(
  ///   vibrant,
  ///   indices: [0, 2, 4],
  /// );
  /// // Creates gradient: Pink -> Yellow -> Magenta
  /// ```
  static LinearGradient generateMultiStopGradient(
    List<Color> palette, {
    required List<int> indices,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    List<double>? stops,
  }) {
    final colors = indices.map((i) => getColor(palette, i)).toList();
    return LinearGradient(colors: colors, begin: begin, end: end, stops: stops);
  }

  /// Gets all colors from a palette as a list.
  ///
  /// Useful for legend generation or color pickers.
  static List<Color> getAllColors(List<Color> palette) {
    return List.unmodifiable(palette);
  }

  /// Creates a lighter version of a palette color.
  ///
  /// The [amount] parameter controls how much lighter (0.0 - 1.0).
  static Color lighten(List<Color> palette, int index, [double amount = 0.2]) {
    final color = getColor(palette, index);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Creates a darker version of a palette color.
  ///
  /// The [amount] parameter controls how much darker (0.0 - 1.0).
  static Color darken(List<Color> palette, int index, [double amount = 0.2]) {
    final color = getColor(palette, index);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Adjusts opacity of a palette color.
  static Color withOpacity(List<Color> palette, int index, double opacity) {
    return getColor(palette, index).withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  // ==========================================================================
  // PALETTE METADATA
  // ==========================================================================

  /// All available palettes with their names.
  static const Map<String, List<Color>> allPalettes = {
    'material': material,
    'professional': professional,
    'vibrant': vibrant,
    'pastel': pastel,
    'warm': warm,
    'cool': cool,
  };

  /// Gets a palette by name.
  ///
  /// Returns `null` if palette name doesn't exist.
  static List<Color>? getPaletteByName(String name) {
    return allPalettes[name.toLowerCase()];
  }

  /// Gets all palette names.
  static List<String> get paletteNames => allPalettes.keys.toList();
}

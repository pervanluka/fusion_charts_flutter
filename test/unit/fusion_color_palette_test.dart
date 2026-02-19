import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/utils/fusion_color_palette.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================

  group('FusionColorPalette - Construction', () {
    test('creates palette with list of colors', () {
      final palette = FusionColorPalette([Colors.red, Colors.blue]);

      expect(palette.colors.length, 2);
      expect(palette.colors[0], Colors.red);
      expect(palette.colors[1], Colors.blue);
    });

    test('creates empty palette', () {
      const palette = FusionColorPalette([]);

      expect(palette.colors, isEmpty);
      expect(palette.length, 0);
    });
  });

  // ===========================================================================
  // COLOR AT INDEX
  // ===========================================================================

  group('FusionColorPalette - colorAt', () {
    test('returns color at valid index', () {
      final palette = FusionColorPalette([
        Colors.red,
        Colors.blue,
        Colors.green,
      ]);

      expect(palette.colorAt(0), Colors.red);
      expect(palette.colorAt(1), Colors.blue);
      expect(palette.colorAt(2), Colors.green);
    });

    test('cycles when index exceeds length', () {
      final palette = FusionColorPalette([Colors.red, Colors.blue]);

      expect(palette.colorAt(0), Colors.red);
      expect(palette.colorAt(1), Colors.blue);
      expect(palette.colorAt(2), Colors.red); // Cycles back
      expect(palette.colorAt(3), Colors.blue); // Cycles back
      expect(palette.colorAt(10), Colors.red); // 10 % 2 = 0
    });

    test('returns grey for empty palette', () {
      const palette = FusionColorPalette([]);

      expect(palette.colorAt(0), Colors.grey);
      expect(palette.colorAt(5), Colors.grey);
    });
  });

  // ===========================================================================
  // LENGTH
  // ===========================================================================

  group('FusionColorPalette - length', () {
    test('returns correct length', () {
      expect(const FusionColorPalette([]).length, 0);
      expect(FusionColorPalette([Colors.red]).length, 1);
      expect(
        FusionColorPalette([Colors.red, Colors.blue, Colors.green]).length,
        3,
      );
    });
  });

  // ===========================================================================
  // GRADIENT
  // ===========================================================================

  group('FusionColorPalette - gradient', () {
    test('creates gradient from two colors', () {
      final palette = FusionColorPalette([
        Colors.red,
        Colors.blue,
        Colors.green,
      ]);
      final gradient = palette.gradient(0, 2);

      expect(gradient.colors.length, 2);
      expect(gradient.colors[0], Colors.red);
      expect(gradient.colors[1], Colors.green);
    });

    test('cycles indices for gradient', () {
      final palette = FusionColorPalette([Colors.red, Colors.blue]);
      final gradient = palette.gradient(5, 6);

      expect(gradient.colors[0], palette.colorAt(5));
      expect(gradient.colors[1], palette.colorAt(6));
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================

  group('FusionColorPalette - Equality', () {
    test('equal palettes are equal', () {
      final palette1 = FusionColorPalette([Colors.red, Colors.blue]);
      final palette2 = FusionColorPalette([Colors.red, Colors.blue]);

      expect(palette1, equals(palette2));
    });

    test('palettes with different colors are not equal', () {
      final palette1 = FusionColorPalette([Colors.red, Colors.blue]);
      final palette2 = FusionColorPalette([Colors.red, Colors.green]);

      expect(palette1, isNot(equals(palette2)));
    });

    test('palettes with different lengths are not equal', () {
      final palette1 = FusionColorPalette([Colors.red, Colors.blue]);
      final palette2 = FusionColorPalette([Colors.red]);

      expect(palette1, isNot(equals(palette2)));
    });

    test('identical palettes are equal', () {
      final palette = FusionColorPalette([Colors.red]);
      expect(palette == palette, isTrue);
    });

    test('not equal to non-palette object', () {
      final palette = FusionColorPalette([Colors.red]);
      // ignore: unrelated_type_equality_checks
      expect(palette == 'not a palette', isFalse);
    });
  });

  // ===========================================================================
  // HASH CODE
  // ===========================================================================

  group('FusionColorPalette - hashCode', () {
    test('equal palettes have equal hash codes', () {
      final palette1 = FusionColorPalette([Colors.red, Colors.blue]);
      final palette2 = FusionColorPalette([Colors.red, Colors.blue]);

      expect(palette1.hashCode, equals(palette2.hashCode));
    });
  });

  // ===========================================================================
  // PRESET PALETTES
  // ===========================================================================

  group('FusionColorPalette - Preset Palettes', () {
    test('material palette has colors', () {
      final palette = FusionColorPalette.material;

      expect(palette.length, 6);
      expect(palette.colors, isNotEmpty);
    });

    test('professional palette has colors', () {
      final palette = FusionColorPalette.professional;

      expect(palette.length, 6);
      expect(palette.colors, isNotEmpty);
    });

    test('vibrant palette has colors', () {
      final palette = FusionColorPalette.vibrant;

      expect(palette.length, 6);
      expect(palette.colors, isNotEmpty);
    });

    test('pastel palette has colors', () {
      final palette = FusionColorPalette.pastel;

      expect(palette.length, 6);
      expect(palette.colors, isNotEmpty);
    });

    test('warm palette has colors', () {
      final palette = FusionColorPalette.warm;

      expect(palette.length, 6);
      expect(palette.colors, isNotEmpty);
    });

    test('cool palette has colors', () {
      final palette = FusionColorPalette.cool;

      expect(palette.length, 6);
      expect(palette.colors, isNotEmpty);
    });
  });

  // ===========================================================================
  // STATIC COLOR LISTS
  // ===========================================================================

  group('FusionColorPalette - Static Color Lists', () {
    test('materialColors has 6 colors', () {
      expect(FusionColorPalette.materialColors.length, 6);
    });

    test('professionalColors has 6 colors', () {
      expect(FusionColorPalette.professionalColors.length, 6);
    });

    test('vibrantColors has 6 colors', () {
      expect(FusionColorPalette.vibrantColors.length, 6);
    });

    test('pastelColors has 6 colors', () {
      expect(FusionColorPalette.pastelColors.length, 6);
    });

    test('warmColors has 6 colors', () {
      expect(FusionColorPalette.warmColors.length, 6);
    });

    test('coolColors has 6 colors', () {
      expect(FusionColorPalette.coolColors.length, 6);
    });
  });

  // ===========================================================================
  // GET COLOR (STATIC)
  // ===========================================================================

  group('FusionColorPalette.getColor', () {
    test('returns color at valid index', () {
      final colors = [Colors.red, Colors.blue, Colors.green];

      expect(FusionColorPalette.getColor(colors, 0), Colors.red);
      expect(FusionColorPalette.getColor(colors, 1), Colors.blue);
      expect(FusionColorPalette.getColor(colors, 2), Colors.green);
    });

    test('cycles when index exceeds length', () {
      final colors = [Colors.red, Colors.blue];

      expect(FusionColorPalette.getColor(colors, 2), Colors.red);
      expect(FusionColorPalette.getColor(colors, 3), Colors.blue);
    });

    test('returns grey for empty list', () {
      expect(FusionColorPalette.getColor([], 0), Colors.grey);
    });
  });

  // ===========================================================================
  // GENERATE GRADIENT (STATIC)
  // ===========================================================================

  group('FusionColorPalette.generateGradient', () {
    test('creates gradient from colors', () {
      final colors = [Colors.red, Colors.blue, Colors.green];
      final gradient = FusionColorPalette.generateGradient(colors);

      expect(gradient.colors.length, 2);
      expect(gradient.colors[0], Colors.red);
      expect(gradient.colors[1], Colors.blue);
    });

    test('respects custom indices', () {
      final colors = [Colors.red, Colors.blue, Colors.green];
      final gradient = FusionColorPalette.generateGradient(
        colors,
        startIndex: 1,
        endIndex: 2,
      );

      expect(gradient.colors[0], Colors.blue);
      expect(gradient.colors[1], Colors.green);
    });

    test('respects custom alignment', () {
      final colors = [Colors.red, Colors.blue];
      final gradient = FusionColorPalette.generateGradient(
        colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

      expect(gradient.begin, Alignment.centerLeft);
      expect(gradient.end, Alignment.centerRight);
    });
  });

  // ===========================================================================
  // LIGHTEN COLOR
  // ===========================================================================

  group('FusionColorPalette.lightenColor', () {
    test('creates lighter version of color', () {
      const baseColor = Color(0xFF0000FF); // Blue
      final lighterColor = FusionColorPalette.lightenColor(baseColor);

      final baseHsl = HSLColor.fromColor(baseColor);
      final lighterHsl = HSLColor.fromColor(lighterColor);

      expect(lighterHsl.lightness, greaterThan(baseHsl.lightness));
    });

    test('respects custom amount', () {
      const baseColor = Color(0xFF0000FF);
      final lightened1 = FusionColorPalette.lightenColor(baseColor, 0.1);
      final lightened2 = FusionColorPalette.lightenColor(baseColor, 0.3);

      final hsl1 = HSLColor.fromColor(lightened1);
      final hsl2 = HSLColor.fromColor(lightened2);

      expect(hsl2.lightness, greaterThan(hsl1.lightness));
    });

    test('clamps at maximum lightness', () {
      const nearWhite = Color(0xFFEEEEEE);
      final lightened = FusionColorPalette.lightenColor(nearWhite, 0.5);
      final hsl = HSLColor.fromColor(lightened);

      expect(hsl.lightness, lessThanOrEqualTo(1.0));
    });
  });

  // ===========================================================================
  // DARKEN COLOR
  // ===========================================================================

  group('FusionColorPalette.darkenColor', () {
    test('creates darker version of color', () {
      const baseColor = Color(0xFF0000FF); // Blue
      final darkerColor = FusionColorPalette.darkenColor(baseColor);

      final baseHsl = HSLColor.fromColor(baseColor);
      final darkerHsl = HSLColor.fromColor(darkerColor);

      expect(darkerHsl.lightness, lessThan(baseHsl.lightness));
    });

    test('respects custom amount', () {
      const baseColor = Color(0xFF0000FF);
      final darkened1 = FusionColorPalette.darkenColor(baseColor, 0.1);
      final darkened2 = FusionColorPalette.darkenColor(baseColor, 0.3);

      final hsl1 = HSLColor.fromColor(darkened1);
      final hsl2 = HSLColor.fromColor(darkened2);

      expect(hsl2.lightness, lessThan(hsl1.lightness));
    });

    test('clamps at minimum lightness', () {
      const nearBlack = Color(0xFF111111);
      final darkened = FusionColorPalette.darkenColor(nearBlack, 0.5);
      final hsl = HSLColor.fromColor(darkened);

      expect(hsl.lightness, greaterThanOrEqualTo(0.0));
    });
  });

  // ===========================================================================
  // GET CONTRASTING TEXT COLOR
  // ===========================================================================

  group('FusionColorPalette.getContrastingTextColor', () {
    test('returns dark text for light background', () {
      const lightBackground = Colors.white;
      final textColor = FusionColorPalette.getContrastingTextColor(
        lightBackground,
      );

      expect(textColor, Colors.black);
    });

    test('returns light text for dark background', () {
      const darkBackground = Colors.black;
      final textColor = FusionColorPalette.getContrastingTextColor(
        darkBackground,
      );

      expect(textColor, Colors.white);
    });

    test('respects custom threshold', () {
      const mediumGrey = Color(0xFF888888);

      // With high threshold, should return light text
      final highThreshold = FusionColorPalette.getContrastingTextColor(
        mediumGrey,
        threshold: 0.7,
      );

      // With low threshold, should return dark text
      final lowThreshold = FusionColorPalette.getContrastingTextColor(
        mediumGrey,
        threshold: 0.1,
      );

      expect(highThreshold, Colors.white);
      expect(lowThreshold, Colors.black);
    });

    test('respects custom dark and light colors', () {
      const lightBackground = Colors.white;
      const darkBackground = Colors.black;

      final customDark = FusionColorPalette.getContrastingTextColor(
        lightBackground,
        darkColor: Colors.purple,
        lightColor: Colors.yellow,
      );

      final customLight = FusionColorPalette.getContrastingTextColor(
        darkBackground,
        darkColor: Colors.purple,
        lightColor: Colors.yellow,
      );

      expect(customDark, Colors.purple);
      expect(customLight, Colors.yellow);
    });
  });
}

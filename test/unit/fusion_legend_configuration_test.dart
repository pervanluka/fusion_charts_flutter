import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_legend_configuration.dart';

void main() {
  // ===========================================================================
  // FUSION LEGEND CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionLegendConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionLegendConfiguration();

      expect(config.visible, isTrue);
      expect(config.position, FusionLegendPosition.bottom);
      expect(config.alignment, FusionLegendAlignment.center);
      expect(config.orientation, FusionLegendOrientation.horizontal);
      expect(config.backgroundColor, isNull);
      expect(config.borderColor, isNull);
      expect(config.borderWidth, 0.0);
      expect(config.borderRadius, 4.0);
      expect(config.padding, const EdgeInsets.all(8.0));
      expect(config.margin, const EdgeInsets.all(8.0));
      expect(config.itemSpacing, 16.0);
      expect(config.iconSize, 16.0);
      expect(config.iconPadding, 8.0);
      expect(config.textStyle, isNull);
      expect(config.toggleSeriesOnTap, isTrue);
      expect(config.itemBuilder, isNull);
      expect(config.maxWidth, isNull);
      expect(config.maxHeight, isNull);
      expect(config.scrollable, isFalse);
    });

    test('creates with custom values', () {
      final config = FusionLegendConfiguration(
        visible: false,
        position: FusionLegendPosition.top,
        alignment: FusionLegendAlignment.start,
        orientation: FusionLegendOrientation.vertical,
        backgroundColor: Colors.white,
        borderColor: Colors.grey,
        borderWidth: 1.0,
        borderRadius: 8.0,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(4.0),
        itemSpacing: 20.0,
        iconSize: 20.0,
        iconPadding: 12.0,
        textStyle: const TextStyle(fontSize: 14),
        toggleSeriesOnTap: false,
        maxWidth: 200.0,
        maxHeight: 100.0,
        scrollable: true,
      );

      expect(config.visible, isFalse);
      expect(config.position, FusionLegendPosition.top);
      expect(config.alignment, FusionLegendAlignment.start);
      expect(config.orientation, FusionLegendOrientation.vertical);
      expect(config.backgroundColor, Colors.white);
      expect(config.borderColor, Colors.grey);
      expect(config.borderWidth, 1.0);
      expect(config.borderRadius, 8.0);
      expect(config.padding, const EdgeInsets.all(16.0));
      expect(config.margin, const EdgeInsets.all(4.0));
      expect(config.itemSpacing, 20.0);
      expect(config.iconSize, 20.0);
      expect(config.iconPadding, 12.0);
      expect(config.textStyle?.fontSize, 14);
      expect(config.toggleSeriesOnTap, isFalse);
      expect(config.maxWidth, 200.0);
      expect(config.maxHeight, 100.0);
      expect(config.scrollable, isTrue);
    });

    test('creates with custom item builder', () {
      final config = FusionLegendConfiguration(
        itemBuilder: (item, index) => Text(item.name),
      );

      expect(config.itemBuilder, isNotNull);
    });
  });

  // ===========================================================================
  // FUSION LEGEND CONFIGURATION - COPYWITH
  // ===========================================================================
  group('FusionLegendConfiguration - copyWith', () {
    test('copyWith creates copy with modified values', () {
      const original = FusionLegendConfiguration(
        visible: true,
        position: FusionLegendPosition.bottom,
      );

      final copy = original.copyWith(
        visible: false,
        position: FusionLegendPosition.left,
      );

      expect(copy.visible, isFalse);
      expect(copy.position, FusionLegendPosition.left);
    });

    test('copyWith preserves unchanged values', () {
      const original = FusionLegendConfiguration(
        visible: true,
        position: FusionLegendPosition.right,
        alignment: FusionLegendAlignment.end,
        itemSpacing: 24.0,
      );

      final copy = original.copyWith(visible: false);

      expect(copy.visible, isFalse);
      expect(copy.position, FusionLegendPosition.right);
      expect(copy.alignment, FusionLegendAlignment.end);
      expect(copy.itemSpacing, 24.0);
    });

    test('copyWith handles all parameters', () {
      const original = FusionLegendConfiguration();

      final copy = original.copyWith(
        visible: false,
        position: FusionLegendPosition.top,
        alignment: FusionLegendAlignment.spaceBetween,
        orientation: FusionLegendOrientation.auto,
        backgroundColor: Colors.black,
        borderColor: Colors.white,
        borderWidth: 2.0,
        borderRadius: 12.0,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        itemSpacing: 30.0,
        iconSize: 24.0,
        iconPadding: 16.0,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        toggleSeriesOnTap: false,
        maxWidth: 300.0,
        maxHeight: 150.0,
        scrollable: true,
      );

      expect(copy.visible, isFalse);
      expect(copy.position, FusionLegendPosition.top);
      expect(copy.alignment, FusionLegendAlignment.spaceBetween);
      expect(copy.orientation, FusionLegendOrientation.auto);
      expect(copy.backgroundColor, Colors.black);
      expect(copy.borderColor, Colors.white);
      expect(copy.borderWidth, 2.0);
      expect(copy.borderRadius, 12.0);
      expect(copy.padding, const EdgeInsets.symmetric(horizontal: 20));
      expect(copy.margin, const EdgeInsets.symmetric(vertical: 10));
      expect(copy.itemSpacing, 30.0);
      expect(copy.iconSize, 24.0);
      expect(copy.iconPadding, 16.0);
      expect(copy.textStyle?.fontWeight, FontWeight.bold);
      expect(copy.toggleSeriesOnTap, isFalse);
      expect(copy.maxWidth, 300.0);
      expect(copy.maxHeight, 150.0);
      expect(copy.scrollable, isTrue);
    });
  });

  // ===========================================================================
  // FUSION LEGEND CONFIGURATION - TOSTRING
  // ===========================================================================
  group('FusionLegendConfiguration - toString', () {
    test('toString returns descriptive string', () {
      const config = FusionLegendConfiguration(
        visible: true,
        position: FusionLegendPosition.top,
      );

      final str = config.toString();

      expect(str, contains('FusionLegendConfiguration'));
      expect(str, contains('visible: true'));
      expect(str, contains('position: FusionLegendPosition.top'));
    });
  });

  // ===========================================================================
  // FUSION LEGEND POSITION ENUM
  // ===========================================================================
  group('FusionLegendPosition - Enum', () {
    test('has all expected values', () {
      expect(FusionLegendPosition.values, hasLength(4));
      expect(FusionLegendPosition.values, contains(FusionLegendPosition.top));
      expect(
        FusionLegendPosition.values,
        contains(FusionLegendPosition.bottom),
      );
      expect(FusionLegendPosition.values, contains(FusionLegendPosition.left));
      expect(FusionLegendPosition.values, contains(FusionLegendPosition.right));
    });
  });

  // ===========================================================================
  // FUSION LEGEND ALIGNMENT ENUM
  // ===========================================================================
  group('FusionLegendAlignment - Enum', () {
    test('has all expected values', () {
      expect(FusionLegendAlignment.values, hasLength(6));
      expect(
        FusionLegendAlignment.values,
        contains(FusionLegendAlignment.start),
      );
      expect(
        FusionLegendAlignment.values,
        contains(FusionLegendAlignment.center),
      );
      expect(FusionLegendAlignment.values, contains(FusionLegendAlignment.end));
      expect(
        FusionLegendAlignment.values,
        contains(FusionLegendAlignment.spaceBetween),
      );
      expect(
        FusionLegendAlignment.values,
        contains(FusionLegendAlignment.spaceAround),
      );
      expect(
        FusionLegendAlignment.values,
        contains(FusionLegendAlignment.spaceEvenly),
      );
    });
  });

  // ===========================================================================
  // FUSION LEGEND ORIENTATION ENUM
  // ===========================================================================
  group('FusionLegendOrientation - Enum', () {
    test('has all expected values', () {
      expect(FusionLegendOrientation.values, hasLength(3));
      expect(
        FusionLegendOrientation.values,
        contains(FusionLegendOrientation.horizontal),
      );
      expect(
        FusionLegendOrientation.values,
        contains(FusionLegendOrientation.vertical),
      );
      expect(
        FusionLegendOrientation.values,
        contains(FusionLegendOrientation.auto),
      );
    });
  });

  // ===========================================================================
  // FUSION LEGEND ITEM
  // ===========================================================================
  group('FusionLegendItem', () {
    test('creates with required parameters', () {
      const item = FusionLegendItem(
        name: 'Series 1',
        color: Colors.blue,
        visible: true,
      );

      expect(item.name, 'Series 1');
      expect(item.color, Colors.blue);
      expect(item.visible, isTrue);
      expect(item.icon, isNull);
    });

    test('creates with custom icon', () {
      const item = FusionLegendItem(
        name: 'Series 1',
        color: Colors.blue,
        visible: true,
        icon: Icon(Icons.star),
      );

      expect(item.icon, isNotNull);
    });

    test('toString returns descriptive string', () {
      const item = FusionLegendItem(
        name: 'Revenue',
        color: Colors.green,
        visible: false,
      );

      final str = item.toString();

      expect(str, contains('FusionLegendItem'));
      expect(str, contains('Revenue'));
      expect(str, contains('visible: false'));
    });
  });
}

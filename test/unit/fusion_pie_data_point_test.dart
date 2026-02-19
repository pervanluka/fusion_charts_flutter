import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/data/fusion_pie_data_point.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================

  group('FusionPieDataPoint - Construction', () {
    test('creates with required value', () {
      const point = FusionPieDataPoint(35);

      expect(point.value, 35);
      expect(point.label, isNull);
    });

    test('creates with all default values', () {
      const point = FusionPieDataPoint(50);

      expect(point.value, 50);
      expect(point.label, isNull);
      expect(point.color, isNull);
      expect(point.gradient, isNull);
      expect(point.borderColor, isNull);
      expect(point.borderWidth, 0.0);
      expect(point.cornerRadius, 0.0);
      expect(point.shadow, isNull);
      expect(point.explode, isFalse);
      expect(point.explodeOffset, isNull);
      expect(point.enabled, isTrue);
      expect(point.visible, isTrue);
      expect(point.onTap, isNull);
      expect(point.onDoubleTap, isNull);
      expect(point.onLongPress, isNull);
      expect(point.onHover, isNull);
      expect(point.tooltip, isNull);
      expect(point.metadata, isNull);
    });

    test('creates with custom values', () {
      const shadow = BoxShadow(color: Colors.black26, blurRadius: 8);
      final gradient = RadialGradient(
        colors: [Colors.blue.shade300, Colors.blue.shade800],
      );

      final point = FusionPieDataPoint(
        35,
        label: 'Sales',
        color: Colors.blue,
        gradient: gradient,
        borderColor: Colors.white,
        borderWidth: 2.0,
        cornerRadius: 8.0,
        shadow: shadow,
        explode: true,
        explodeOffset: 15.0,
        enabled: false,
        visible: false,
        tooltip: 'Custom tooltip',
        metadata: {'id': 123},
      );

      expect(point.value, 35);
      expect(point.label, 'Sales');
      expect(point.color, Colors.blue);
      expect(point.gradient, gradient);
      expect(point.borderColor, Colors.white);
      expect(point.borderWidth, 2.0);
      expect(point.cornerRadius, 8.0);
      expect(point.shadow, shadow);
      expect(point.explode, isTrue);
      expect(point.explodeOffset, 15.0);
      expect(point.enabled, isFalse);
      expect(point.visible, isFalse);
      expect(point.tooltip, 'Custom tooltip');
      expect(point.metadata, {'id': 123});
    });
  });

  // ===========================================================================
  // ASSERTIONS
  // ===========================================================================

  group('FusionPieDataPoint - Assertions', () {
    test('throws for negative value', () {
      expect(() => FusionPieDataPoint(-1), throwsA(isA<AssertionError>()));
    });

    test('allows zero value', () {
      const point = FusionPieDataPoint(0);
      expect(point.value, 0);
    });

    test('throws for negative borderWidth', () {
      expect(
        () => FusionPieDataPoint(10, borderWidth: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws for negative cornerRadius', () {
      expect(
        () => FusionPieDataPoint(10, cornerRadius: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  group('FusionPieDataPoint - Computed Properties', () {
    test('hasBorder returns true when border is configured', () {
      const point = FusionPieDataPoint(
        10,
        borderWidth: 2.0,
        borderColor: Colors.white,
      );

      expect(point.hasBorder, isTrue);
    });

    test('hasBorder returns false when borderWidth is 0', () {
      const point = FusionPieDataPoint(
        10,
        borderWidth: 0.0,
        borderColor: Colors.white,
      );

      expect(point.hasBorder, isFalse);
    });

    test('hasBorder returns false when borderColor is null', () {
      const point = FusionPieDataPoint(10, borderWidth: 2.0);

      expect(point.hasBorder, isFalse);
    });

    test('hasShadow returns true when shadow is set', () {
      const point = FusionPieDataPoint(
        10,
        shadow: BoxShadow(color: Colors.black26, blurRadius: 4),
      );

      expect(point.hasShadow, isTrue);
    });

    test('hasShadow returns false when shadow is null', () {
      const point = FusionPieDataPoint(10);

      expect(point.hasShadow, isFalse);
    });

    test('hasGradient returns true when gradient is set', () {
      final point = FusionPieDataPoint(
        10,
        gradient: const RadialGradient(colors: [Colors.blue, Colors.green]),
      );

      expect(point.hasGradient, isTrue);
    });

    test('hasGradient returns false when gradient is null', () {
      const point = FusionPieDataPoint(10);

      expect(point.hasGradient, isFalse);
    });
  });

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  group('FusionPieDataPoint - copyWith', () {
    test('creates copy with modified value', () {
      const original = FusionPieDataPoint(35, label: 'Sales');
      final copy = original.copyWith(value: 50);

      expect(copy.value, 50);
      expect(copy.label, 'Sales'); // Unchanged
      expect(original.value, 35);
    });

    test('creates copy with modified label', () {
      const original = FusionPieDataPoint(35, label: 'Sales');
      final copy = original.copyWith(label: 'Revenue');

      expect(copy.label, 'Revenue');
      expect(original.label, 'Sales');
    });

    test('creates copy with modified visual properties', () {
      const original = FusionPieDataPoint(35);
      final copy = original.copyWith(
        color: Colors.red,
        borderColor: Colors.white,
        borderWidth: 2.0,
        cornerRadius: 4.0,
      );

      expect(copy.color, Colors.red);
      expect(copy.borderColor, Colors.white);
      expect(copy.borderWidth, 2.0);
      expect(copy.cornerRadius, 4.0);
    });

    test('creates copy with modified explode properties', () {
      const original = FusionPieDataPoint(35);
      final copy = original.copyWith(explode: true, explodeOffset: 20.0);

      expect(copy.explode, isTrue);
      expect(copy.explodeOffset, 20.0);
    });

    test('creates copy with modified state', () {
      const original = FusionPieDataPoint(35);
      final copy = original.copyWith(enabled: false, visible: false);

      expect(copy.enabled, isFalse);
      expect(copy.visible, isFalse);
    });

    test('creates unchanged copy when no parameters', () {
      const original = FusionPieDataPoint(35, label: 'Test');
      final copy = original.copyWith();

      expect(copy.value, original.value);
      expect(copy.label, original.label);
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================

  group('FusionPieDataPoint - Equality', () {
    test('equal points are equal', () {
      const point1 = FusionPieDataPoint(35, label: 'Sales', color: Colors.blue);
      const point2 = FusionPieDataPoint(35, label: 'Sales', color: Colors.blue);

      expect(point1, equals(point2));
    });

    test('points with different values are not equal', () {
      const point1 = FusionPieDataPoint(35);
      const point2 = FusionPieDataPoint(50);

      expect(point1, isNot(equals(point2)));
    });

    test('points with different labels are not equal', () {
      const point1 = FusionPieDataPoint(35, label: 'Sales');
      const point2 = FusionPieDataPoint(35, label: 'Revenue');

      expect(point1, isNot(equals(point2)));
    });

    test('points with different colors are not equal', () {
      const point1 = FusionPieDataPoint(35, color: Colors.blue);
      const point2 = FusionPieDataPoint(35, color: Colors.red);

      expect(point1, isNot(equals(point2)));
    });

    test('points with different explode are not equal', () {
      const point1 = FusionPieDataPoint(35, explode: true);
      const point2 = FusionPieDataPoint(35, explode: false);

      expect(point1, isNot(equals(point2)));
    });

    test('points with different visible are not equal', () {
      const point1 = FusionPieDataPoint(35, visible: true);
      const point2 = FusionPieDataPoint(35, visible: false);

      expect(point1, isNot(equals(point2)));
    });

    test('identical points are equal', () {
      const point = FusionPieDataPoint(35);
      expect(point == point, isTrue);
    });
  });

  // ===========================================================================
  // HASH CODE
  // ===========================================================================

  group('FusionPieDataPoint - hashCode', () {
    test('equal points have equal hash codes', () {
      const point1 = FusionPieDataPoint(35, label: 'Sales');
      const point2 = FusionPieDataPoint(35, label: 'Sales');

      expect(point1.hashCode, equals(point2.hashCode));
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('FusionPieDataPoint - toString', () {
    test('includes value and label', () {
      const point = FusionPieDataPoint(35, label: 'Sales');
      final str = point.toString();

      expect(str, contains('35'));
      expect(str, contains('Sales'));
    });

    test('includes value without label', () {
      const point = FusionPieDataPoint(35);
      final str = point.toString();

      expect(str, contains('35'));
      expect(str, contains('null'));
    });
  });

  // ===========================================================================
  // CALLBACKS
  // ===========================================================================

  group('FusionPieDataPoint - Callbacks', () {
    test('can store onTap callback', () {
      var tapped = false;
      final point = FusionPieDataPoint(35, onTap: (p, i) => tapped = true);

      expect(point.onTap, isNotNull);
      point.onTap!(point, 0);
      expect(tapped, isTrue);
    });

    test('can store onDoubleTap callback', () {
      var doubleTapped = false;
      final point = FusionPieDataPoint(
        35,
        onDoubleTap: (p, i) => doubleTapped = true,
      );

      expect(point.onDoubleTap, isNotNull);
      point.onDoubleTap!(point, 0);
      expect(doubleTapped, isTrue);
    });

    test('can store onLongPress callback', () {
      var longPressed = false;
      final point = FusionPieDataPoint(
        35,
        onLongPress: (p, i) => longPressed = true,
      );

      expect(point.onLongPress, isNotNull);
      point.onLongPress!(point, 0);
      expect(longPressed, isTrue);
    });

    test('can store onHover callback', () {
      var hovered = false;
      final point = FusionPieDataPoint(
        35,
        onHover: (p, i, isHovered) => hovered = isHovered,
      );

      expect(point.onHover, isNotNull);
      point.onHover!(point, 0, true);
      expect(hovered, isTrue);
    });
  });

  // ===========================================================================
  // METADATA
  // ===========================================================================

  group('FusionPieDataPoint - Metadata', () {
    test('can store map metadata', () {
      const point = FusionPieDataPoint(
        35,
        metadata: {'id': 123, 'category': 'sales'},
      );

      expect(point.metadata, isA<Map<String, dynamic>>());
      expect((point.metadata as Map<String, dynamic>?)?['id'], 123);
    });

    test('can store object metadata', () {
      final customObj = DateTime(2024, 1, 1);
      final point = FusionPieDataPoint(35, metadata: customObj);

      expect(point.metadata, customObj);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/axis/category/fusion_category_axis.dart';
import 'package:fusion_charts_flutter/src/core/enums/label_alignment.dart';

void main() {
  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================
  group('FusionCategoryAxis - Construction', () {
    test('creates with required categories', () {
      final axis = FusionCategoryAxis(
        categories: const ['Q1', 'Q2', 'Q3', 'Q4'],
      );

      expect(axis.categories, ['Q1', 'Q2', 'Q3', 'Q4']);
      expect(axis.name, isNull);
      expect(axis.title, isNull);
      expect(axis.titleStyle, isNull);
      expect(axis.opposedPosition, isFalse);
      expect(axis.isInversed, isFalse);
      expect(axis.labelAlignment, LabelAlignment.center);
    });

    test('creates with all parameters', () {
      final axis = FusionCategoryAxis(
        categories: const ['Jan', 'Feb', 'Mar'],
        name: 'months',
        title: 'Month',
        titleStyle: const TextStyle(fontSize: 14),
        opposedPosition: true,
        isInversed: true,
        labelAlignment: LabelAlignment.end,
      );

      expect(axis.categories, ['Jan', 'Feb', 'Mar']);
      expect(axis.name, 'months');
      expect(axis.title, 'Month');
      expect(axis.titleStyle?.fontSize, 14);
      expect(axis.opposedPosition, isTrue);
      expect(axis.isInversed, isTrue);
      expect(axis.labelAlignment, LabelAlignment.end);
    });

    test('throws assertion for empty categories', () {
      expect(
        () => FusionCategoryAxis(categories: const []),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionCategoryAxis - Computed Properties', () {
    test('categoryCount returns correct count', () {
      final axis = FusionCategoryAxis(
        categories: const ['A', 'B', 'C', 'D', 'E'],
      );

      expect(axis.categoryCount, 5);
    });

    test('getCategoryIndex returns correct index', () {
      final axis = FusionCategoryAxis(
        categories: const ['Jan', 'Feb', 'Mar', 'Apr'],
      );

      expect(axis.getCategoryIndex('Jan'), 0);
      expect(axis.getCategoryIndex('Feb'), 1);
      expect(axis.getCategoryIndex('Mar'), 2);
      expect(axis.getCategoryIndex('Apr'), 3);
    });

    test('getCategoryIndex returns null for non-existent category', () {
      final axis = FusionCategoryAxis(categories: const ['Jan', 'Feb', 'Mar']);

      expect(axis.getCategoryIndex('Dec'), isNull);
      expect(axis.getCategoryIndex('Unknown'), isNull);
    });

    test('getCategoryAt returns correct category', () {
      final axis = FusionCategoryAxis(categories: const ['A', 'B', 'C']);

      expect(axis.getCategoryAt(0), 'A');
      expect(axis.getCategoryAt(1), 'B');
      expect(axis.getCategoryAt(2), 'C');
    });

    test('getCategoryAt returns null for out of bounds index', () {
      final axis = FusionCategoryAxis(categories: const ['A', 'B', 'C']);

      expect(axis.getCategoryAt(-1), isNull);
      expect(axis.getCategoryAt(3), isNull);
      expect(axis.getCategoryAt(100), isNull);
    });
  });

  // ===========================================================================
  // COPYWITH
  // ===========================================================================
  group('FusionCategoryAxis - copyWith', () {
    test('copyWith creates copy with modified categories', () {
      final original = FusionCategoryAxis(categories: const ['A', 'B', 'C']);

      final copy = original.copyWith(categories: ['X', 'Y', 'Z']);

      expect(copy.categories, ['X', 'Y', 'Z']);
    });

    test('copyWith preserves unchanged values', () {
      final original = FusionCategoryAxis(
        categories: const ['Q1', 'Q2', 'Q3', 'Q4'],
        name: 'quarters',
        title: 'Quarter',
      );

      final copy = original.copyWith(title: 'New Title');

      expect(copy.categories, ['Q1', 'Q2', 'Q3', 'Q4']);
      expect(copy.name, 'quarters');
      expect(copy.title, 'New Title');
    });

    test('copyWith handles all parameters', () {
      final original = FusionCategoryAxis(categories: const ['A']);

      final copy = original.copyWith(
        name: 'newAxis',
        title: 'New Title',
        titleStyle: const TextStyle(fontSize: 16),
        opposedPosition: true,
        isInversed: true,
        categories: ['X', 'Y', 'Z'],
        labelAlignment: LabelAlignment.start,
      );

      expect(copy.name, 'newAxis');
      expect(copy.title, 'New Title');
      expect(copy.titleStyle?.fontSize, 16);
      expect(copy.opposedPosition, isTrue);
      expect(copy.isInversed, isTrue);
      expect(copy.categories, ['X', 'Y', 'Z']);
      expect(copy.labelAlignment, LabelAlignment.start);
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================
  group('FusionCategoryAxis - Equality', () {
    test('equal axes are equal', () {
      final axis1 = FusionCategoryAxis(
        categories: const ['A', 'B', 'C'],
        name: 'test',
      );
      final axis2 = FusionCategoryAxis(
        categories: const ['A', 'B', 'C'],
        name: 'test',
      );

      expect(axis1, equals(axis2));
    });

    test('axes with different categories are not equal', () {
      final axis1 = FusionCategoryAxis(categories: const ['A', 'B', 'C']);
      final axis2 = FusionCategoryAxis(categories: const ['X', 'Y', 'Z']);

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different category order are not equal', () {
      final axis1 = FusionCategoryAxis(categories: const ['A', 'B', 'C']);
      final axis2 = FusionCategoryAxis(categories: const ['C', 'B', 'A']);

      expect(axis1, isNot(equals(axis2)));
    });

    test('axes with different category count are not equal', () {
      final axis1 = FusionCategoryAxis(categories: const ['A', 'B']);
      final axis2 = FusionCategoryAxis(categories: const ['A', 'B', 'C']);

      expect(axis1, isNot(equals(axis2)));
    });

    test('hashCode is consistent', () {
      final axis1 = FusionCategoryAxis(categories: const ['A', 'B', 'C']);
      final axis2 = FusionCategoryAxis(categories: const ['A', 'B', 'C']);

      expect(axis1.hashCode, equals(axis2.hashCode));
    });

    test('identical axes are equal', () {
      final axis = FusionCategoryAxis(categories: const ['A', 'B']);
      expect(axis == axis, isTrue);
    });
  });

  // ===========================================================================
  // TOSTRING
  // ===========================================================================
  group('FusionCategoryAxis - toString', () {
    test('toString returns descriptive string', () {
      final axis = FusionCategoryAxis(
        categories: const ['Jan', 'Feb', 'Mar', 'Apr'],
      );

      final str = axis.toString();

      expect(str, contains('FusionCategoryAxis'));
      expect(str, contains('4'));
    });
  });
}

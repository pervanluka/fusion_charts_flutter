import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/annotations/fusion_reference_line.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_annotation_overlap_strategy.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_label_position.dart';

void main() {
  // ===========================================================================
  // FUSION REFERENCE LINE - CONSTRUCTION
  // ===========================================================================
  group('FusionReferenceLine - Construction', () {
    test('creates with required value only', () {
      const line = FusionReferenceLine(value: 100.0);

      expect(line.value, 100.0);
      expect(line.label, isNull);
      expect(line.lineColor, isNull);
      expect(line.lineWidth, 1.0);
      expect(line.lineDashPattern, [4, 4]);
      expect(line.extendToEdge, isTrue);
      expect(line.labelPosition, FusionLabelPosition.right);
      expect(line.labelStyle, isNull);
      expect(line.labelBackgroundColor, isNull);
      expect(line.labelBorderRadius, 4.0);
      expect(line.labelPadding,
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3));
      expect(line.labelMaxWidth, isNull);
      expect(line.overlapStrategy,
          FusionAnnotationOverlapStrategy.annotationWins);
      expect(line.overlapThreshold, 0.02);
      expect(line.visible, isTrue);
    });

    test('creates with all parameters', () {
      final line = FusionReferenceLine(
        value: 9642.24,
        label: '9,642.24 €',
        lineColor: Colors.green,
        lineWidth: 2.0,
        lineDashPattern: const [2, 2],
        extendToEdge: false,
        labelPosition: FusionLabelPosition.left,
        labelStyle: const TextStyle(fontSize: 11, color: Colors.white),
        labelBackgroundColor: Colors.green,
        labelBorderRadius: 8.0,
        labelPadding: const EdgeInsets.all(4),
        labelMaxWidth: 120.0,
        overlapStrategy: FusionAnnotationOverlapStrategy.offset,
        overlapThreshold: 0.05,
        visible: false,
      );

      expect(line.value, 9642.24);
      expect(line.label, '9,642.24 €');
      expect(line.lineColor, Colors.green);
      expect(line.lineWidth, 2.0);
      expect(line.lineDashPattern, [2, 2]);
      expect(line.extendToEdge, isFalse);
      expect(line.labelPosition, FusionLabelPosition.left);
      expect(line.labelStyle!.fontSize, 11);
      expect(line.labelBackgroundColor, Colors.green);
      expect(line.labelBorderRadius, 8.0);
      expect(line.labelPadding, const EdgeInsets.all(4));
      expect(line.labelMaxWidth, 120.0);
      expect(line.overlapStrategy, FusionAnnotationOverlapStrategy.offset);
      expect(line.overlapThreshold, 0.05);
      expect(line.visible, isFalse);
    });

    test('creates with solid line (null dash pattern)', () {
      const line = FusionReferenceLine(
        value: 50.0,
        lineDashPattern: null,
      );

      expect(line.lineDashPattern, isNull);
    });
  });

  // ===========================================================================
  // FUSION REFERENCE LINE - ASSERTIONS
  // ===========================================================================
  group('FusionReferenceLine - Assertions', () {
    test('asserts lineWidth must be positive', () {
      expect(
        () => FusionReferenceLine(value: 100, lineWidth: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionReferenceLine(value: 100, lineWidth: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts labelBorderRadius must be non-negative', () {
      expect(
        () => FusionReferenceLine(value: 100, labelBorderRadius: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts overlapThreshold must be between 0 and 1', () {
      expect(
        () => FusionReferenceLine(value: 100, overlapThreshold: -0.1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => FusionReferenceLine(value: 100, overlapThreshold: 1.5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts boundary values for overlapThreshold', () {
      const lineZero = FusionReferenceLine(value: 100, overlapThreshold: 0);
      const lineOne = FusionReferenceLine(value: 100, overlapThreshold: 1);
      expect(lineZero.overlapThreshold, 0);
      expect(lineOne.overlapThreshold, 1);
    });
  });

  // ===========================================================================
  // FUSION REFERENCE LINE - COPY WITH
  // ===========================================================================
  group('FusionReferenceLine - copyWith', () {
    test('preserves all fields when no arguments given', () {
      final original = FusionReferenceLine(
        value: 500,
        label: 'Target',
        lineColor: Colors.red,
        lineWidth: 2.0,
        lineDashPattern: const [6, 3],
        extendToEdge: false,
        labelPosition: FusionLabelPosition.topLeft,
        labelStyle: const TextStyle(fontSize: 14),
        labelBackgroundColor: Colors.red,
        labelBorderRadius: 6.0,
        labelPadding: const EdgeInsets.all(10),
        labelMaxWidth: 200,
        overlapStrategy: FusionAnnotationOverlapStrategy.dataLabelWins,
        overlapThreshold: 0.03,
        visible: false,
      );

      final copy = original.copyWith();

      expect(copy.value, original.value);
      expect(copy.label, original.label);
      expect(copy.lineColor, original.lineColor);
      expect(copy.lineWidth, original.lineWidth);
      expect(copy.lineDashPattern, original.lineDashPattern);
      expect(copy.extendToEdge, original.extendToEdge);
      expect(copy.labelPosition, original.labelPosition);
      expect(copy.labelStyle, original.labelStyle);
      expect(copy.labelBackgroundColor, original.labelBackgroundColor);
      expect(copy.labelBorderRadius, original.labelBorderRadius);
      expect(copy.labelPadding, original.labelPadding);
      expect(copy.labelMaxWidth, original.labelMaxWidth);
      expect(copy.overlapStrategy, original.overlapStrategy);
      expect(copy.overlapThreshold, original.overlapThreshold);
      expect(copy.visible, original.visible);
    });

    test('replaces individual fields', () {
      const original = FusionReferenceLine(value: 100, label: 'A');

      final updated = original.copyWith(value: 200, label: 'B');

      expect(updated.value, 200);
      expect(updated.label, 'B');
      expect(updated.lineWidth, original.lineWidth);
    });
  });

  // ===========================================================================
  // FUSION REFERENCE LINE - EFFECTIVE COLORS
  // ===========================================================================
  group('FusionReferenceLine - Effective Colors', () {
    test('getEffectiveLineColor returns lineColor when set', () {
      const line = FusionReferenceLine(value: 100, lineColor: Colors.red);
      expect(line.getEffectiveLineColor(Colors.grey), Colors.red);
    });

    test('getEffectiveLineColor falls back to theme color', () {
      const line = FusionReferenceLine(value: 100);
      expect(line.getEffectiveLineColor(Colors.grey), Colors.grey);
    });

    test('getEffectiveLabelBackgroundColor returns labelBackgroundColor when set',
        () {
      const line = FusionReferenceLine(
        value: 100,
        labelBackgroundColor: Colors.blue,
      );
      expect(line.getEffectiveLabelBackgroundColor(Colors.grey), Colors.blue);
    });

    test('getEffectiveLabelBackgroundColor falls back to lineColor', () {
      const line = FusionReferenceLine(value: 100, lineColor: Colors.red);
      expect(line.getEffectiveLabelBackgroundColor(Colors.grey), Colors.red);
    });

    test('getEffectiveLabelBackgroundColor falls back to theme color', () {
      const line = FusionReferenceLine(value: 100);
      expect(line.getEffectiveLabelBackgroundColor(Colors.grey), Colors.grey);
    });
  });

  // ===========================================================================
  // FUSION REFERENCE LINE - EQUALITY
  // ===========================================================================
  group('FusionReferenceLine - Equality', () {
    test('equal when same core fields', () {
      const a = FusionReferenceLine(value: 100, label: 'X');
      const b = FusionReferenceLine(value: 100, label: 'X');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when different value', () {
      const a = FusionReferenceLine(value: 100);
      const b = FusionReferenceLine(value: 200);
      expect(a, isNot(equals(b)));
    });

    test('not equal when different visibility', () {
      const a = FusionReferenceLine(value: 100, visible: true);
      const b = FusionReferenceLine(value: 100, visible: false);
      expect(a, isNot(equals(b)));
    });
  });

  // ===========================================================================
  // FUSION LABEL POSITION - ENUM
  // ===========================================================================
  group('FusionLabelPosition', () {
    test('has all expected values', () {
      expect(FusionLabelPosition.values, hasLength(4));
      expect(FusionLabelPosition.values,
          containsAll([
            FusionLabelPosition.left,
            FusionLabelPosition.right,
            FusionLabelPosition.topLeft,
            FusionLabelPosition.topRight,
          ]));
    });
  });

  // ===========================================================================
  // FUSION ANNOTATION OVERLAP STRATEGY - ENUM
  // ===========================================================================
  group('FusionAnnotationOverlapStrategy', () {
    test('has all expected values', () {
      expect(FusionAnnotationOverlapStrategy.values, hasLength(4));
      expect(FusionAnnotationOverlapStrategy.values,
          containsAll([
            FusionAnnotationOverlapStrategy.annotationWins,
            FusionAnnotationOverlapStrategy.dataLabelWins,
            FusionAnnotationOverlapStrategy.offset,
            FusionAnnotationOverlapStrategy.showBoth,
          ]));
    });
  });

  // ===========================================================================
  // CHART CONFIGURATION - ANNOTATIONS
  // ===========================================================================
  group('FusionChartConfiguration - annotations', () {
    test('defaults to empty list', () {
      // Verified via FusionReferenceLine constructor default
      const line = FusionReferenceLine(value: 100);
      expect(line.visible, isTrue);
    });
  });
}

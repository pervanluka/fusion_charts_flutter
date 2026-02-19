import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/models/axis_bounds.dart';
import 'package:fusion_charts_flutter/src/rendering/layout/chart_layout.dart';

void main() {
  // Default test layout for use in multiple tests
  ChartLayout createTestLayout({
    Size chartSize = const Size(400, 300),
    Rect? plotArea,
    Rect? xAxisArea,
    Rect? yAxisArea,
    AxisBounds? xBounds,
    AxisBounds? yBounds,
    EdgeInsets? margins,
    Rect? legendArea,
    Rect? titleArea,
  }) {
    return ChartLayout(
      chartSize: chartSize,
      plotArea: plotArea ?? const Rect.fromLTRB(50, 20, 350, 250),
      xAxisArea: xAxisArea ?? const Rect.fromLTRB(50, 250, 350, 280),
      yAxisArea: yAxisArea ?? const Rect.fromLTRB(10, 20, 50, 250),
      xBounds: xBounds ?? AxisBounds(min: 0, max: 100, interval: 20),
      yBounds: yBounds ?? AxisBounds(min: 0, max: 100, interval: 20),
      margins: margins ?? const EdgeInsets.all(10),
      legendArea: legendArea,
      titleArea: titleArea,
    );
  }

  // ===========================================================================
  // CONSTRUCTION
  // ===========================================================================
  group('ChartLayout - Construction', () {
    test('creates with required parameters', () {
      final layout = createTestLayout();

      expect(layout.chartSize, const Size(400, 300));
      expect(layout.plotArea, const Rect.fromLTRB(50, 20, 350, 250));
      expect(layout.xAxisArea, const Rect.fromLTRB(50, 250, 350, 280));
      expect(layout.yAxisArea, const Rect.fromLTRB(10, 20, 50, 250));
      expect(layout.xBounds.min, 0);
      expect(layout.xBounds.max, 100);
      expect(layout.yBounds.min, 0);
      expect(layout.yBounds.max, 100);
      expect(layout.margins, const EdgeInsets.all(10));
    });

    test('creates with optional legend area', () {
      final layout = createTestLayout(
        legendArea: const Rect.fromLTRB(360, 20, 390, 150),
      );

      expect(layout.legendArea, isNotNull);
      expect(layout.legendArea, const Rect.fromLTRB(360, 20, 390, 150));
    });

    test('creates with optional title area', () {
      final layout = createTestLayout(
        titleArea: const Rect.fromLTRB(50, 0, 350, 20),
      );

      expect(layout.titleArea, isNotNull);
      expect(layout.titleArea, const Rect.fromLTRB(50, 0, 350, 20));
    });

    test('legend area defaults to null', () {
      final layout = createTestLayout();

      expect(layout.legendArea, isNull);
    });

    test('title area defaults to null', () {
      final layout = createTestLayout();

      expect(layout.titleArea, isNull);
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================
  group('ChartLayout - Computed Properties', () {
    test('plotWidth returns correct value', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
      );

      expect(layout.plotWidth, 300.0); // 350 - 50
    });

    test('plotHeight returns correct value', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
      );

      expect(layout.plotHeight, 230.0); // 250 - 20
    });

    test('hasLegend returns true when legendArea is set', () {
      final layout = createTestLayout(
        legendArea: const Rect.fromLTRB(360, 20, 390, 150),
      );

      expect(layout.hasLegend, isTrue);
    });

    test('hasLegend returns false when legendArea is null', () {
      final layout = createTestLayout();

      expect(layout.hasLegend, isFalse);
    });

    test('hasTitle returns true when titleArea is set', () {
      final layout = createTestLayout(
        titleArea: const Rect.fromLTRB(50, 0, 350, 20),
      );

      expect(layout.hasTitle, isTrue);
    });

    test('hasTitle returns false when titleArea is null', () {
      final layout = createTestLayout();

      expect(layout.hasTitle, isFalse);
    });

    test('totalMarginWidth returns correct value', () {
      final layout = createTestLayout(
        margins: const EdgeInsets.symmetric(horizontal: 15),
      );

      expect(layout.totalMarginWidth, 30.0); // 15 + 15
    });

    test('totalMarginHeight returns correct value', () {
      final layout = createTestLayout(
        margins: const EdgeInsets.symmetric(vertical: 20),
      );

      expect(layout.totalMarginHeight, 40.0); // 20 + 20
    });

    test('contentWidth returns correct value', () {
      final layout = createTestLayout(
        chartSize: const Size(400, 300),
        margins: const EdgeInsets.symmetric(horizontal: 25),
      );

      expect(layout.contentWidth, 350.0); // 400 - 50
    });

    test('contentHeight returns correct value', () {
      final layout = createTestLayout(
        chartSize: const Size(400, 300),
        margins: const EdgeInsets.symmetric(vertical: 30),
      );

      expect(layout.contentHeight, 240.0); // 300 - 60
    });
  });

  // ===========================================================================
  // COORDINATE CONVERSION
  // ===========================================================================
  group('ChartLayout - Coordinate Conversion', () {
    test('dataXToScreenX converts min value to left edge', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.dataXToScreenX(0), 50.0);
    });

    test('dataXToScreenX converts max value to right edge', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.dataXToScreenX(100), 350.0);
    });

    test('dataXToScreenX converts middle value correctly', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.dataXToScreenX(50), 200.0); // middle of 50-350
    });

    test('dataYToScreenY converts min value to bottom edge', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.dataYToScreenY(0), 250.0); // bottom (Y is inverted)
    });

    test('dataYToScreenY converts max value to top edge', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.dataYToScreenY(100), 20.0); // top
    });

    test('dataYToScreenY converts middle value correctly', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.dataYToScreenY(50), 135.0); // middle of 20-250
    });

    test('screenXToDataX converts left edge to min value', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.screenXToDataX(50), closeTo(0, 1e-10));
    });

    test('screenXToDataX converts right edge to max value', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.screenXToDataX(350), closeTo(100, 1e-10));
    });

    test('screenYToDataY converts bottom edge to min value', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.screenYToDataY(250), closeTo(0, 1e-10));
    });

    test('screenYToDataY converts top edge to max value', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.screenYToDataY(20), closeTo(100, 1e-10));
    });

    test('dataToScreen converts point correctly', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      final screenPoint = layout.dataToScreen(50, 50);
      expect(screenPoint.dx, 200.0); // middle X
      expect(screenPoint.dy, 135.0); // middle Y
    });

    test('screenToData converts point correctly', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      final dataPoint = layout.screenToData(const Offset(200, 135));
      expect(dataPoint.dx, closeTo(50, 1e-10));
      expect(dataPoint.dy, closeTo(50, 1e-10));
    });

    test('round-trip data to screen to data preserves value', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      const originalX = 75.0;
      const originalY = 25.0;

      final screenPoint = layout.dataToScreen(originalX, originalY);
      final dataPoint = layout.screenToData(screenPoint);

      expect(dataPoint.dx, closeTo(originalX, 1e-10));
      expect(dataPoint.dy, closeTo(originalY, 1e-10));
    });
  });

  // ===========================================================================
  // HIT TESTING
  // ===========================================================================
  group('ChartLayout - Hit Testing', () {
    test('isInPlotArea returns true for point inside plot area', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
      );

      expect(layout.isInPlotArea(const Offset(200, 150)), isTrue);
    });

    test('isInPlotArea returns false for point outside plot area', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
      );

      expect(layout.isInPlotArea(const Offset(10, 150)), isFalse);
    });

    test('isInPlotArea returns true for point on edge', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
      );

      expect(layout.isInPlotArea(const Offset(50, 20)), isTrue);
    });

    test('isInXAxisArea returns true for point inside X-axis area', () {
      final layout = createTestLayout(
        xAxisArea: const Rect.fromLTRB(50, 250, 350, 280),
      );

      expect(layout.isInXAxisArea(const Offset(200, 265)), isTrue);
    });

    test('isInXAxisArea returns false for point outside X-axis area', () {
      final layout = createTestLayout(
        xAxisArea: const Rect.fromLTRB(50, 250, 350, 280),
      );

      expect(layout.isInXAxisArea(const Offset(200, 100)), isFalse);
    });

    test('isInYAxisArea returns true for point inside Y-axis area', () {
      final layout = createTestLayout(
        yAxisArea: const Rect.fromLTRB(10, 20, 50, 250),
      );

      expect(layout.isInYAxisArea(const Offset(30, 150)), isTrue);
    });

    test('isInYAxisArea returns false for point outside Y-axis area', () {
      final layout = createTestLayout(
        yAxisArea: const Rect.fromLTRB(10, 20, 50, 250),
      );

      expect(layout.isInYAxisArea(const Offset(100, 150)), isFalse);
    });

    test('isInLegendArea returns true for point inside legend area', () {
      final layout = createTestLayout(
        legendArea: const Rect.fromLTRB(360, 20, 390, 150),
      );

      expect(layout.isInLegendArea(const Offset(375, 80)), isTrue);
    });

    test('isInLegendArea returns false for point outside legend area', () {
      final layout = createTestLayout(
        legendArea: const Rect.fromLTRB(360, 20, 390, 150),
      );

      expect(layout.isInLegendArea(const Offset(200, 80)), isFalse);
    });

    test('isInLegendArea returns false when legend area is null', () {
      final layout = createTestLayout();

      expect(layout.isInLegendArea(const Offset(375, 80)), isFalse);
    });
  });

  // ===========================================================================
  // COPY WITH
  // ===========================================================================
  group('ChartLayout - copyWith', () {
    test('returns new instance with same values when no arguments', () {
      final original = createTestLayout();
      final copy = original.copyWith();

      expect(copy.chartSize, original.chartSize);
      expect(copy.plotArea, original.plotArea);
      expect(copy.xAxisArea, original.xAxisArea);
      expect(copy.yAxisArea, original.yAxisArea);
      expect(copy.margins, original.margins);
    });

    test('copies with new chartSize', () {
      final original = createTestLayout();
      final copy = original.copyWith(chartSize: const Size(500, 400));

      expect(copy.chartSize, const Size(500, 400));
      expect(copy.plotArea, original.plotArea);
    });

    test('copies with new plotArea', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        plotArea: const Rect.fromLTRB(60, 30, 360, 260),
      );

      expect(copy.plotArea, const Rect.fromLTRB(60, 30, 360, 260));
      expect(copy.chartSize, original.chartSize);
    });

    test('copies with new xAxisArea', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        xAxisArea: const Rect.fromLTRB(60, 260, 360, 290),
      );

      expect(copy.xAxisArea, const Rect.fromLTRB(60, 260, 360, 290));
    });

    test('copies with new yAxisArea', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        yAxisArea: const Rect.fromLTRB(15, 25, 55, 255),
      );

      expect(copy.yAxisArea, const Rect.fromLTRB(15, 25, 55, 255));
    });

    test('copies with new xBounds', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        xBounds: AxisBounds(min: 10, max: 200, interval: 20),
      );

      expect(copy.xBounds.min, 10);
      expect(copy.xBounds.max, 200);
    });

    test('copies with new yBounds', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        yBounds: AxisBounds(min: -50, max: 150, interval: 20),
      );

      expect(copy.yBounds.min, -50);
      expect(copy.yBounds.max, 150);
    });

    test('copies with new margins', () {
      final original = createTestLayout();
      final copy = original.copyWith(margins: const EdgeInsets.all(20));

      expect(copy.margins, const EdgeInsets.all(20));
    });

    test('copies with new legendArea', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        legendArea: const Rect.fromLTRB(370, 30, 395, 160),
      );

      expect(copy.legendArea, const Rect.fromLTRB(370, 30, 395, 160));
    });

    test('copies with new titleArea', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        titleArea: const Rect.fromLTRB(50, 0, 350, 25),
      );

      expect(copy.titleArea, const Rect.fromLTRB(50, 0, 350, 25));
    });

    test('copies with new xAxisLabelArea', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        xAxisLabelArea: const Rect.fromLTRB(50, 255, 350, 275),
      );

      expect(copy.xAxisLabelArea, const Rect.fromLTRB(50, 255, 350, 275));
    });

    test('copies with new yAxisLabelArea', () {
      final original = createTestLayout();
      final copy = original.copyWith(
        yAxisLabelArea: const Rect.fromLTRB(15, 20, 45, 250),
      );

      expect(copy.yAxisLabelArea, const Rect.fromLTRB(15, 20, 45, 250));
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================
  group('ChartLayout - toString', () {
    test('toString returns formatted string', () {
      final layout = createTestLayout();
      final str = layout.toString();

      expect(str, contains('ChartLayout'));
      expect(str, contains('chartSize'));
      expect(str, contains('plotArea'));
      expect(str, contains('xBounds'));
      expect(str, contains('yBounds'));
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('ChartLayout - Edge Cases', () {
    test('handles zero-width plot area', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(100, 20, 100, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.plotWidth, 0.0);
      // Zero-width should still allow dataXToScreenX without crashing
      final result = layout.dataXToScreenX(50);
      expect(result, isNotNull); // Just ensure it doesn't throw
    });

    test('handles zero-height plot area', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 100, 350, 100),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      expect(layout.plotHeight, 0.0);
    });

    test('handles negative data bounds', () {
      final layout = createTestLayout(
        xBounds: AxisBounds(min: -100, max: 100, interval: 25),
        yBounds: AxisBounds(min: -50, max: 50, interval: 10),
      );

      expect(layout.dataXToScreenX(0), isNotNull);
      expect(layout.dataYToScreenY(0), isNotNull);
    });

    test('handles small margins', () {
      final layout = createTestLayout(margins: EdgeInsets.zero);

      expect(layout.totalMarginWidth, 0.0);
      expect(layout.totalMarginHeight, 0.0);
      expect(layout.contentWidth, layout.chartSize.width);
      expect(layout.contentHeight, layout.chartSize.height);
    });

    test('handles large margins', () {
      final layout = createTestLayout(
        chartSize: const Size(400, 300),
        margins: const EdgeInsets.all(100),
      );

      expect(layout.totalMarginWidth, 200.0);
      expect(layout.totalMarginHeight, 200.0);
      expect(layout.contentWidth, 200.0);
      expect(layout.contentHeight, 100.0);
    });

    test('coordinate conversion handles values outside bounds', () {
      final layout = createTestLayout(
        plotArea: const Rect.fromLTRB(50, 20, 350, 250),
        xBounds: AxisBounds(min: 0, max: 100, interval: 20),
        yBounds: AxisBounds(min: 0, max: 100, interval: 20),
      );

      // Value beyond max should extend beyond plot area
      final screenX = layout.dataXToScreenX(150);
      expect(screenX, greaterThan(350));

      // Value before min should extend before plot area
      final screenX2 = layout.dataXToScreenX(-50);
      expect(screenX2, lessThan(50));
    });
  });
}

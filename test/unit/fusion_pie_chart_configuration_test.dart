import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_pie_chart_configuration.dart';
import 'package:fusion_charts_flutter/src/data/fusion_pie_data_point.dart';
import 'package:fusion_charts_flutter/src/series/fusion_pie_series.dart';
import 'package:fusion_charts_flutter/src/themes/fusion_light_theme.dart';

void main() {
  // ===========================================================================
  // FUSION PIE CHART CONFIGURATION - CONSTRUCTION
  // ===========================================================================
  group('FusionPieChartConfiguration - Construction', () {
    test('creates with default values', () {
      const config = FusionPieChartConfiguration();

      // Layout
      expect(config.innerRadiusPercent, 0.0);
      expect(config.outerRadiusPercent, 0.85);
      expect(config.startAngle, -90.0);
      expect(config.direction, PieDirection.clockwise);
      expect(config.chartPadding, const EdgeInsets.all(4));

      // Labels
      expect(config.labelPosition, PieLabelPosition.auto);
      expect(config.showLabels, isTrue);
      expect(config.showPercentages, isTrue);
      expect(config.showValues, isFalse);
      expect(config.percentageThreshold, 3.0);
      expect(config.labelConnectorLength, 20.0);
      expect(config.labelConnectorWidth, 1.0);
      expect(config.labelConnectorColor, isNull);
      expect(config.labelStyle, isNull);
      expect(config.labelFormatter, isNull);

      // Center
      expect(config.showCenterLabel, isFalse);
      expect(config.centerLabelText, isNull);
      expect(config.centerLabelStyle, isNull);
      expect(config.centerSubLabelText, isNull);
      expect(config.centerSubLabelStyle, isNull);
      expect(config.centerWidget, isNull);

      // Animation
      expect(config.animationType, PieAnimationType.sweep);

      // Selection
      expect(config.selectionMode, PieSelectionMode.single);
      expect(config.selectedOpacity, 1.0);
      expect(config.unselectedOpacity, 0.4);
      expect(config.selectedScale, 1.02);

      // Hover
      expect(config.enableHover, isTrue);
      expect(config.hoverScale, 1.03);

      // Explode
      expect(config.explodeOffset, 10.0);
      expect(config.explodeOnSelection, isFalse);
      expect(config.explodeOnHover, isFalse);

      // Legend
      expect(config.legendPosition, LegendPosition.right);
      expect(config.legendSpacing, 16.0);
      expect(config.legendItemSpacing, 8.0);
      expect(config.legendIconSize, 12.0);
      expect(config.legendIconShape, LegendIconShape.circle);
      expect(config.legendTextStyle, isNull);
      expect(config.legendValueTextStyle, isNull);
      expect(config.showLegendValues, isFalse);
      expect(config.showLegendPercentages, isTrue);
      expect(config.legendScrollable, isTrue);

      // Stroke
      expect(config.strokeWidth, 1.0);
      expect(config.strokeColor, isNull);

      // Shadow
      expect(config.enableShadow, isFalse);
      expect(config.shadowColor, isNull);
      expect(config.shadowBlurRadius, 8.0);
      expect(config.shadowOffset, const Offset(2, 2));

      // Corner / Gap
      expect(config.cornerRadius, 0.0);
      expect(config.gapBetweenSlices, 0.0);

      // Sorting / Grouping
      expect(config.sortMode, PieSortMode.none);
      expect(config.groupSmallSegments, isFalse);
      expect(config.groupThreshold, 3.0);
      expect(config.groupLabel, 'Other');
      expect(config.groupColor, isNull);
    });

    test('creates donut chart configuration', () {
      const config = FusionPieChartConfiguration(innerRadiusPercent: 0.5);

      expect(config.innerRadiusPercent, 0.5);
      expect(config.isDonut, isTrue);
    });

    test('creates pie chart configuration (non-donut)', () {
      const config = FusionPieChartConfiguration(innerRadiusPercent: 0.0);

      expect(config.innerRadiusPercent, 0.0);
      expect(config.isDonut, isFalse);
    });

    test('creates with custom layout', () {
      const config = FusionPieChartConfiguration(
        innerRadiusPercent: 0.3,
        outerRadiusPercent: 0.9,
        startAngle: 0.0,
        direction: PieDirection.counterClockwise,
        chartPadding: EdgeInsets.all(16),
      );

      expect(config.innerRadiusPercent, 0.3);
      expect(config.outerRadiusPercent, 0.9);
      expect(config.startAngle, 0.0);
      expect(config.direction, PieDirection.counterClockwise);
      expect(config.chartPadding, const EdgeInsets.all(16));
    });

    test('creates with custom label settings', () {
      const style = TextStyle(fontSize: 14, color: Colors.black);
      const config = FusionPieChartConfiguration(
        labelPosition: PieLabelPosition.outside,
        showLabels: false,
        showPercentages: false,
        showValues: true,
        percentageThreshold: 5.0,
        labelConnectorLength: 30.0,
        labelConnectorWidth: 2.0,
        labelConnectorColor: Colors.grey,
        labelStyle: style,
      );

      expect(config.labelPosition, PieLabelPosition.outside);
      expect(config.showLabels, isFalse);
      expect(config.showPercentages, isFalse);
      expect(config.showValues, isTrue);
      expect(config.percentageThreshold, 5.0);
      expect(config.labelConnectorLength, 30.0);
      expect(config.labelConnectorWidth, 2.0);
      expect(config.labelConnectorColor, Colors.grey);
      expect(config.labelStyle, style);
    });

    test('creates with center content', () {
      const mainStyle = TextStyle(fontSize: 24);
      const subStyle = TextStyle(fontSize: 14);

      const config = FusionPieChartConfiguration(
        showCenterLabel: true,
        centerLabelText: 'Total',
        centerLabelStyle: mainStyle,
        centerSubLabelText: '\$1,234',
        centerSubLabelStyle: subStyle,
      );

      expect(config.showCenterLabel, isTrue);
      expect(config.centerLabelText, 'Total');
      expect(config.centerLabelStyle, mainStyle);
      expect(config.centerSubLabelText, '\$1,234');
      expect(config.centerSubLabelStyle, subStyle);
    });

    test('creates with center widget', () {
      const widget = Icon(Icons.pie_chart);
      const config = FusionPieChartConfiguration(centerWidget: widget);

      expect(config.centerWidget, widget);
    });

    test('creates with custom selection settings', () {
      const config = FusionPieChartConfiguration(
        selectionMode: PieSelectionMode.multiple,
        selectedOpacity: 0.9,
        unselectedOpacity: 0.3,
        selectedScale: 1.05,
      );

      expect(config.selectionMode, PieSelectionMode.multiple);
      expect(config.selectedOpacity, 0.9);
      expect(config.unselectedOpacity, 0.3);
      expect(config.selectedScale, 1.05);
    });

    test('creates with explode settings', () {
      const config = FusionPieChartConfiguration(
        explodeOffset: 15.0,
        explodeOnSelection: true,
        explodeOnHover: true,
      );

      expect(config.explodeOffset, 15.0);
      expect(config.explodeOnSelection, isTrue);
      expect(config.explodeOnHover, isTrue);
    });

    test('creates with shadow settings', () {
      const config = FusionPieChartConfiguration(
        enableShadow: true,
        shadowColor: Colors.black54,
        shadowBlurRadius: 12.0,
        shadowOffset: Offset(4, 4),
      );

      expect(config.enableShadow, isTrue);
      expect(config.shadowColor, Colors.black54);
      expect(config.shadowBlurRadius, 12.0);
      expect(config.shadowOffset, const Offset(4, 4));
    });

    test('creates with grouping settings', () {
      const config = FusionPieChartConfiguration(
        sortMode: PieSortMode.descending,
        groupSmallSegments: true,
        groupThreshold: 5.0,
        groupLabel: 'Miscellaneous',
        groupColor: Colors.grey,
      );

      expect(config.sortMode, PieSortMode.descending);
      expect(config.groupSmallSegments, isTrue);
      expect(config.groupThreshold, 5.0);
      expect(config.groupLabel, 'Miscellaneous');
      expect(config.groupColor, Colors.grey);
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================
  group('FusionPieChartConfiguration - Computed Properties', () {
    test('isDonut returns true when innerRadiusPercent > 0', () {
      const config = FusionPieChartConfiguration(innerRadiusPercent: 0.5);
      expect(config.isDonut, isTrue);
    });

    test('isDonut returns false when innerRadiusPercent = 0', () {
      const config = FusionPieChartConfiguration(innerRadiusPercent: 0.0);
      expect(config.isDonut, isFalse);
    });

    test('effectiveStrokeColor uses provided color', () {
      const theme = FusionLightTheme();
      const config = FusionPieChartConfiguration(strokeColor: Colors.red);

      expect(config.effectiveStrokeColor(theme), Colors.red);
    });

    test('effectiveStrokeColor falls back to theme', () {
      const theme = FusionLightTheme();
      const config = FusionPieChartConfiguration();

      expect(config.effectiveStrokeColor(theme), theme.pieStrokeColor);
    });

    test('effectiveShadowColor uses provided color', () {
      const theme = FusionLightTheme();
      const config = FusionPieChartConfiguration(shadowColor: Colors.black54);

      expect(config.effectiveShadowColor(theme), Colors.black54);
    });

    test('effectiveShadowColor falls back to theme', () {
      const theme = FusionLightTheme();
      const config = FusionPieChartConfiguration();

      expect(config.effectiveShadowColor(theme), theme.pieShadowColor);
    });

    test('effectiveGroupColor uses provided color', () {
      const theme = FusionLightTheme();
      const config = FusionPieChartConfiguration(groupColor: Colors.grey);

      expect(config.effectiveGroupColor(theme), Colors.grey);
    });

    test('effectiveGroupColor falls back to theme', () {
      const theme = FusionLightTheme();
      const config = FusionPieChartConfiguration();

      expect(config.effectiveGroupColor(theme), theme.gridColor);
    });
  });

  // ===========================================================================
  // RESOLVED VALUES
  // ===========================================================================
  group('FusionPieChartConfiguration - Resolved Values', () {
    late FusionPieSeries series;

    setUp(() {
      series = FusionPieSeries(
        name: 'Test',
        dataPoints: [
          FusionPieDataPoint(10, label: 'A'),
          FusionPieDataPoint(20, label: 'B'),
        ],
        innerRadiusPercent: 0.3,
        outerRadiusPercent: 0.8,
        startAngle: 45,
        direction: PieDirection.counterClockwise,
        cornerRadius: 5.0,
        gapBetweenSlices: 2.0,
        explodeOffset: 15.0,
        sortMode: PieSortMode.ascending,
        groupThreshold: 4.0,
        groupSmallSegments: false,
        groupLabel: 'Others',
      );
    });

    test('resolveInnerRadius returns config value when set', () {
      const config = FusionPieChartConfiguration(innerRadiusPercent: 0.5);
      expect(config.resolveInnerRadius(series), 0.5);
    });

    test('resolveInnerRadius returns series value when config is 0', () {
      const config = FusionPieChartConfiguration(innerRadiusPercent: 0.0);
      expect(config.resolveInnerRadius(series), 0.3);
    });

    test('resolveOuterRadius returns config value when < 1', () {
      const config = FusionPieChartConfiguration(outerRadiusPercent: 0.9);
      expect(config.resolveOuterRadius(series), 0.9);
    });

    test('resolveOuterRadius returns series value when config >= 1', () {
      const config = FusionPieChartConfiguration(outerRadiusPercent: 1.0);
      expect(config.resolveOuterRadius(series), 0.8);
    });

    test('resolveStartAngle returns config value when not default', () {
      const config = FusionPieChartConfiguration(startAngle: 0.0);
      expect(config.resolveStartAngle(series), 0.0);
    });

    test('resolveStartAngle returns series value when config is default', () {
      const config = FusionPieChartConfiguration(startAngle: -90.0);
      expect(config.resolveStartAngle(series), 45);
    });

    test('resolveDirection returns config value when not default', () {
      const config = FusionPieChartConfiguration(
        direction: PieDirection.counterClockwise,
      );
      expect(config.resolveDirection(series), PieDirection.counterClockwise);
    });

    test('resolveDirection returns series value when config is default', () {
      const config = FusionPieChartConfiguration(
        direction: PieDirection.clockwise,
      );
      expect(config.resolveDirection(series), PieDirection.counterClockwise);
    });

    test('resolveCornerRadius returns config value when > 0', () {
      const config = FusionPieChartConfiguration(cornerRadius: 10.0);
      expect(config.resolveCornerRadius(series), 10.0);
    });

    test('resolveCornerRadius returns series value when config is 0', () {
      const config = FusionPieChartConfiguration(cornerRadius: 0.0);
      expect(config.resolveCornerRadius(series), 5.0);
    });

    test('resolveGapBetweenSlices returns config value when > 0', () {
      const config = FusionPieChartConfiguration(gapBetweenSlices: 3.0);
      expect(config.resolveGapBetweenSlices(series), 3.0);
    });

    test('resolveGapBetweenSlices returns series value when config is 0', () {
      const config = FusionPieChartConfiguration(gapBetweenSlices: 0.0);
      expect(config.resolveGapBetweenSlices(series), 2.0);
    });

    test('resolveExplodeOffset returns config value when not default', () {
      const config = FusionPieChartConfiguration(explodeOffset: 20.0);
      expect(config.resolveExplodeOffset(series), 20.0);
    });

    test(
      'resolveExplodeOffset returns series value when config is default',
      () {
        const config = FusionPieChartConfiguration(explodeOffset: 10.0);
        expect(config.resolveExplodeOffset(series), 15.0);
      },
    );

    test('resolveSortMode returns config value when not default', () {
      const config = FusionPieChartConfiguration(
        sortMode: PieSortMode.descending,
      );
      expect(config.resolveSortMode(series), PieSortMode.descending);
    });

    test('resolveSortMode returns series value when config is default', () {
      const config = FusionPieChartConfiguration(sortMode: PieSortMode.none);
      expect(config.resolveSortMode(series), PieSortMode.ascending);
    });

    test('resolveGroupThreshold returns config value when not default', () {
      const config = FusionPieChartConfiguration(groupThreshold: 5.0);
      expect(config.resolveGroupThreshold(series), 5.0);
    });

    test(
      'resolveGroupThreshold returns series value when config is default',
      () {
        const config = FusionPieChartConfiguration(groupThreshold: 3.0);
        expect(config.resolveGroupThreshold(series), 4.0);
      },
    );

    test('resolveGroupSmallSegments returns true if either is true', () {
      const config = FusionPieChartConfiguration(groupSmallSegments: true);
      expect(config.resolveGroupSmallSegments(series), isTrue);
    });

    test('resolveGroupSmallSegments returns false if both are false', () {
      const config = FusionPieChartConfiguration(groupSmallSegments: false);
      expect(config.resolveGroupSmallSegments(series), isFalse);
    });

    test('resolveGroupLabel returns config value when not default', () {
      const config = FusionPieChartConfiguration(groupLabel: 'Misc');
      expect(config.resolveGroupLabel(series), 'Misc');
    });

    test('resolveGroupLabel returns series value when config is default', () {
      const config = FusionPieChartConfiguration(groupLabel: 'Other');
      expect(config.resolveGroupLabel(series), 'Others');
    });
  });

  // ===========================================================================
  // ENUMS
  // ===========================================================================
  group('PieAnimationType', () {
    test('has all expected values', () {
      expect(
        PieAnimationType.values,
        containsAll([
          PieAnimationType.sweep,
          PieAnimationType.scale,
          PieAnimationType.fade,
          PieAnimationType.scaleFade,
          PieAnimationType.none,
        ]),
      );
    });

    test('has 5 values', () {
      expect(PieAnimationType.values.length, 5);
    });
  });

  group('LegendPosition', () {
    test('has all expected values', () {
      expect(
        LegendPosition.values,
        containsAll([
          LegendPosition.top,
          LegendPosition.bottom,
          LegendPosition.left,
          LegendPosition.right,
          LegendPosition.none,
        ]),
      );
    });

    test('has 5 values', () {
      expect(LegendPosition.values.length, 5);
    });
  });

  group('LegendIconShape', () {
    test('has all expected values', () {
      expect(
        LegendIconShape.values,
        containsAll([
          LegendIconShape.circle,
          LegendIconShape.square,
          LegendIconShape.roundedSquare,
          LegendIconShape.diamond,
          LegendIconShape.line,
        ]),
      );
    });

    test('has 5 values', () {
      expect(LegendIconShape.values.length, 5);
    });
  });

  // ===========================================================================
  // PIE CONFIG LABEL DATA
  // ===========================================================================
  group('PieConfigLabelData', () {
    test('creates with required parameters', () {
      const data = PieConfigLabelData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        label: 'Sales',
        color: Colors.blue,
      );

      expect(data.index, 0);
      expect(data.value, 100.0);
      expect(data.percentage, 25.0);
      expect(data.label, 'Sales');
      expect(data.color, Colors.blue);
    });

    test('creates with null label', () {
      const data = PieConfigLabelData(
        index: 1,
        value: 50.0,
        percentage: 12.5,
        label: null,
        color: Colors.red,
      );

      expect(data.label, isNull);
    });
  });

  // ===========================================================================
  // LABEL FORMATTER
  // ===========================================================================
  group('FusionPieChartConfiguration - Label Formatter', () {
    test('labelFormatter is called with correct data', () {
      PieConfigLabelData? receivedData;

      final config = FusionPieChartConfiguration(
        labelFormatter: (data) {
          receivedData = data;
          return '${data.label}: ${data.percentage.toStringAsFixed(1)}%';
        },
      );

      const testData = PieConfigLabelData(
        index: 0,
        value: 100.0,
        percentage: 25.0,
        label: 'Sales',
        color: Colors.blue,
      );

      final result = config.labelFormatter!(testData);

      expect(receivedData, testData);
      expect(result, 'Sales: 25.0%');
    });

    test('labelFormatter can return empty string to hide label', () {
      final config = FusionPieChartConfiguration(
        labelFormatter: (data) {
          if (data.percentage < 5) return '';
          return '${data.percentage.toStringAsFixed(0)}%';
        },
      );

      const smallData = PieConfigLabelData(
        index: 0,
        value: 10.0,
        percentage: 2.5,
        label: 'Small',
        color: Colors.grey,
      );

      const largeData = PieConfigLabelData(
        index: 1,
        value: 100.0,
        percentage: 25.0,
        label: 'Large',
        color: Colors.blue,
      );

      expect(config.labelFormatter!(smallData), '');
      expect(config.labelFormatter!(largeData), '25%');
    });
  });

  // ===========================================================================
  // EDGE CASES
  // ===========================================================================
  group('FusionPieChartConfiguration - Edge Cases', () {
    test('handles zero values', () {
      const config = FusionPieChartConfiguration(
        innerRadiusPercent: 0.0,
        outerRadiusPercent: 0.0,
        strokeWidth: 0.0,
        cornerRadius: 0.0,
        gapBetweenSlices: 0.0,
        explodeOffset: 0.0,
      );

      expect(config.innerRadiusPercent, 0.0);
      expect(config.outerRadiusPercent, 0.0);
      expect(config.strokeWidth, 0.0);
    });

    test('handles maximum inner radius', () {
      const config = FusionPieChartConfiguration(innerRadiusPercent: 0.99);
      expect(config.isDonut, isTrue);
    });

    test('handles negative start angle', () {
      const config = FusionPieChartConfiguration(startAngle: -180.0);
      expect(config.startAngle, -180.0);
    });

    test('handles large start angle', () {
      const config = FusionPieChartConfiguration(startAngle: 270.0);
      expect(config.startAngle, 270.0);
    });
  });
}

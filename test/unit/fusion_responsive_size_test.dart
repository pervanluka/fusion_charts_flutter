import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_legend_configuration.dart';
import 'package:fusion_charts_flutter/src/utils/fusion_responsive_size.dart';

void main() {
  // ===========================================================================
  // FUSION DEVICE TYPE ENUM
  // ===========================================================================

  group('FusionDeviceType', () {
    test('has correct values', () {
      expect(FusionDeviceType.values.length, 3);
      expect(FusionDeviceType.phone, isNotNull);
      expect(FusionDeviceType.tablet, isNotNull);
      expect(FusionDeviceType.desktop, isNotNull);
    });
  });

  // ===========================================================================
  // FUSION RESPONSIVE SIZE - PHONE
  // ===========================================================================

  group('FusionResponsiveSize - Phone', () {
    testWidgets('detects phone correctly', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isPhone, isTrue);
              expect(responsive.isTablet, isFalse);
              expect(responsive.isDesktop, isFalse);
              expect(responsive.deviceType, FusionDeviceType.phone);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('detects XS breakpoint', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(500, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isXS, isTrue);
              expect(responsive.isSM, isFalse);
              expect(responsive.isMD, isFalse);
              expect(responsive.isLG, isFalse);
              expect(responsive.isXL, isFalse);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct chart height for phone', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getChartHeight(), 280.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct chart width for phone', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getChartWidth(), 400 - 32);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns base font size for phone', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getScaledFontSize(12), 12.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns base padding for phone', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getScaledPadding(16), 16.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct axis label count for phone', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getRecommendedAxisLabelCount(), 5);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // FUSION RESPONSIVE SIZE - TABLET
  // ===========================================================================

  group('FusionResponsiveSize - Tablet', () {
    testWidgets('detects tablet correctly', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isPhone, isFalse);
              expect(responsive.isTablet, isTrue);
              expect(responsive.isDesktop, isFalse);
              expect(responsive.deviceType, FusionDeviceType.tablet);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('detects SM breakpoint', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isXS, isFalse);
              expect(responsive.isSM, isTrue);
              expect(responsive.isMD, isFalse);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct chart height for tablet', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getChartHeight(), 380.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct chart width for tablet', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getChartWidth(), 700 - 64);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns scaled font size for tablet', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getScaledFontSize(10), 11.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns scaled padding for tablet', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getScaledPadding(16), 20.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct axis label count for tablet', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getRecommendedAxisLabelCount(), 8);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // FUSION RESPONSIVE SIZE - DESKTOP
  // ===========================================================================

  group('FusionResponsiveSize - Desktop', () {
    testWidgets('detects desktop correctly', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isPhone, isFalse);
              expect(responsive.isTablet, isFalse);
              expect(responsive.isDesktop, isTrue);
              expect(responsive.deviceType, FusionDeviceType.desktop);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('detects MD breakpoint', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1000, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isXS, isFalse);
              expect(responsive.isSM, isFalse);
              expect(responsive.isMD, isTrue);
              expect(responsive.isLG, isFalse);
              expect(responsive.isXL, isFalse);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('detects LG breakpoint', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1400, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isLG, isTrue);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('detects XL breakpoint', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1800, 1000),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isXL, isTrue);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct chart height for desktop', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getChartHeight(), 450.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct chart width for desktop', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1400, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              // Should be clamped between 600 and maxWidth (1200)
              final width = responsive.getChartWidth();
              expect(width, greaterThanOrEqualTo(600));
              expect(width, lessThanOrEqualTo(1200));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns scaled font size for desktop', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getScaledFontSize(10), 12.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns scaled padding for desktop', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getScaledPadding(10), 15.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct axis label count for desktop', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getRecommendedAxisLabelCount(), 12);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // CUSTOM VALUES
  // ===========================================================================

  group('FusionResponsiveSize - Custom values', () {
    testWidgets('custom height overrides default', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getChartHeight(customHeight: 500), 500.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('custom width overrides default', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.getChartWidth(customWidth: 600), 600.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // RESPONSIVE METHOD
  // ===========================================================================

  group('FusionResponsiveSize - responsive method', () {
    testWidgets('returns xs value for phone', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              final result = responsive.responsive<int>(
                xs: 1,
                sm: 2,
                md: 3,
                lg: 4,
                xl: 5,
              );
              expect(result, 1);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns sm value for tablet', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              final result = responsive.responsive<int>(xs: 1, sm: 2, md: 3);
              expect(result, 2);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns md value for medium desktop', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1000, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              final result = responsive.responsive<int>(xs: 1, sm: 2, md: 3);
              expect(result, 3);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('falls back to xs when smaller breakpoints not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              final result = responsive.responsive<int>(xs: 1);
              expect(result, 1);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // ORIENTATION
  // ===========================================================================

  group('FusionResponsiveSize - Orientation', () {
    testWidgets('detects portrait orientation', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isPortrait, isTrue);
              expect(responsive.isLandscape, isFalse);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('detects landscape orientation', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(800, 400),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.isPortrait, isFalse);
              expect(responsive.isLandscape, isTrue);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // CHART HELPERS
  // ===========================================================================

  group('FusionResponsiveSize - Chart helpers', () {
    testWidgets('getMarkerSize scales correctly', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              // Desktop scales by 1.3
              expect(responsive.getMarkerSize(baseSize: 10), 13.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getLineWidth scales correctly', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              // Phone returns base width
              expect(responsive.getLineWidth(baseWidth: 2.0), 2.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getLineWidth scales for desktop', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              // Desktop scales by 1.1
              expect(responsive.getLineWidth(baseWidth: 2.0), 2.2);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getRecommendedLegendPosition for portrait phone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(
                responsive.getRecommendedLegendPosition(),
                FusionLegendPosition.bottom,
              );

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getRecommendedLegendPosition for landscape tablet', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1024, 700),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              // Tablet in landscape
              if (responsive.isTablet && responsive.isLandscape) {
                expect(
                  responsive.getRecommendedLegendPosition(),
                  FusionLegendPosition.right,
                );
              }

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getChartPadding scales correctly', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(1200, 900),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              final padding = responsive.getChartPadding(
                basePadding: const EdgeInsets.all(10),
              );

              // Desktop scales by 1.5
              expect(padding.left, 15.0);
              expect(padding.top, 15.0);
              expect(padding.right, 15.0);
              expect(padding.bottom, 15.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getScaledSpacing returns correct values', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              // Tablet scales by 1.2
              expect(responsive.getScaledSpacing(10), 12.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getScaledValue returns correct values', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(700, 1024),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              // Tablet scales by 1.15
              expect(responsive.getScaledValue(100), closeTo(115.0, 0.001));

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // SCREEN PROPERTIES
  // ===========================================================================

  group('FusionResponsiveSize - Screen properties', () {
    testWidgets('returns correct screen dimensions', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.screenWidth, 400.0);
              expect(responsive.screenHeight, 800.0);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns pixel ratio', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = FusionResponsiveSize(context);

              expect(responsive.pixelRatio, greaterThan(0));

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  // ===========================================================================
  // CONTEXT EXTENSION
  // ===========================================================================

  group('FusionResponsiveContext extension', () {
    testWidgets('provides responsive helper via extension', (tester) async {
      await tester.pumpWidget(
        _TestWidget(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              final responsive = context.responsive;

              expect(responsive, isA<FusionResponsiveSize>());
              expect(responsive.isPhone, isTrue);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}

/// Test widget that provides a controllable MediaQuery.
class _TestWidget extends StatelessWidget {
  const _TestWidget({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );
  }
}

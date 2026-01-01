import 'package:flutter/widgets.dart';
import 'package:fusion_charts_flutter/src/configuration/fusion_legend_configuration.dart';

/// Responsive sizing utilities for charts.
///
/// Provides helpers for adapting chart dimensions and styling
/// to different screen sizes and device types.
///
/// ## Example
///
/// ```dart
/// final responsive = FusionResponsiveSize(context);
///
/// final chartHeight = responsive.getChartHeight();
/// final fontSize = responsive.getScaledFontSize(12);
/// final padding = responsive.getScaledPadding(16);
/// ```
class FusionResponsiveSize {
  /// Creates a responsive size helper.
  const FusionResponsiveSize(this.context);

  /// The build context for screen size calculations.
  final BuildContext context;

  // ==========================================================================
  // SCREEN SIZE QUERIES
  // ==========================================================================

  /// Gets the screen width.
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Gets the screen height.
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Gets the device pixel ratio.
  double get pixelRatio => MediaQuery.of(context).devicePixelRatio;

  /// Checks if the device is in portrait orientation.
  bool get isPortrait =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Checks if the device is in landscape orientation.
  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // ==========================================================================
  // DEVICE TYPE DETECTION
  // ==========================================================================

  /// Checks if the device is a phone (width < 600dp).
  bool get isPhone => screenWidth < 600;

  /// Checks if the device is a tablet (600dp <= width < 900dp).
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Checks if the device is a desktop (width >= 900dp).
  bool get isDesktop => screenWidth >= 900;

  /// Gets the device type.
  FusionDeviceType get deviceType {
    if (isPhone) return FusionDeviceType.phone;
    if (isTablet) return FusionDeviceType.tablet;
    return FusionDeviceType.desktop;
  }

  // ==========================================================================
  // BREAKPOINTS
  // ==========================================================================

  /// Checks if screen width is extra small (< 600dp).
  bool get isXS => screenWidth < 600;

  /// Checks if screen width is small (600dp <= width < 900dp).
  bool get isSM => screenWidth >= 600 && screenWidth < 900;

  /// Checks if screen width is medium (900dp <= width < 1200dp).
  bool get isMD => screenWidth >= 900 && screenWidth < 1200;

  /// Checks if screen width is large (1200dp <= width < 1600dp).
  bool get isLG => screenWidth >= 1200 && screenWidth < 1600;

  /// Checks if screen width is extra large (>= 1600dp).
  bool get isXL => screenWidth >= 1600;

  // ==========================================================================
  // CHART DIMENSIONS
  // ==========================================================================

  /// Gets recommended chart height based on screen size.
  ///
  /// Returns appropriate height for chart content:
  /// - Phone: 250-300dp
  /// - Tablet: 350-400dp
  /// - Desktop: 400-500dp
  double getChartHeight({double? customHeight}) {
    if (customHeight != null) return customHeight;

    if (isPhone) return 280.0;
    if (isTablet) return 380.0;
    return 450.0;
  }

  /// Gets recommended chart width based on screen size.
  ///
  /// Returns full width minus padding on phones,
  /// constrained width on larger screens.
  double getChartWidth({double? customWidth, double maxWidth = 1200}) {
    if (customWidth != null) return customWidth;

    if (isPhone) return screenWidth - 32; // 16dp padding each side
    if (isTablet) return screenWidth - 64; // 32dp padding each side
    return (screenWidth - 128).clamp(600, maxWidth); // 64dp padding, max 1200
  }

  // ==========================================================================
  // SCALED VALUES
  // ==========================================================================

  /// Scales a font size based on screen size.
  ///
  /// Base size is for phone, scales up for larger screens.
  double getScaledFontSize(double baseSize) {
    if (isPhone) return baseSize;
    if (isTablet) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  /// Scales a padding value based on screen size.
  double getScaledPadding(double basePadding) {
    if (isPhone) return basePadding;
    if (isTablet) return basePadding * 1.25;
    return basePadding * 1.5;
  }

  /// Scales a spacing value based on screen size.
  double getScaledSpacing(double baseSpacing) {
    if (isPhone) return baseSpacing;
    if (isTablet) return baseSpacing * 1.2;
    return baseSpacing * 1.4;
  }

  /// Scales a dimension value based on screen size.
  double getScaledValue(double baseValue) {
    if (isPhone) return baseValue;
    if (isTablet) return baseValue * 1.15;
    return baseValue * 1.3;
  }

  // ==========================================================================
  // CONDITIONAL VALUES
  // ==========================================================================

  /// Returns different values based on screen size.
  ///
  /// Example:
  /// ```dart
  /// final columns = responsive.responsive<int>(
  ///   xs: 1,
  ///   sm: 2,
  ///   md: 3,
  ///   lg: 4,
  ///   xl: 5,
  /// );
  /// ```
  T responsive<T>({required T xs, T? sm, T? md, T? lg, T? xl}) {
    if (isXL && xl != null) return xl;
    if (isLG && lg != null) return lg;
    if (isMD && md != null) return md;
    if (isSM && sm != null) return sm;
    return xs;
  }

  // ==========================================================================
  // CHART-SPECIFIC HELPERS
  // ==========================================================================

  /// Gets recommended number of axis labels based on screen size.
  int getRecommendedAxisLabelCount() {
    if (isPhone) return 5;
    if (isTablet) return 8;
    return 12;
  }

  /// Gets recommended marker size for data points.
  double getMarkerSize({double baseSize = 6.0}) {
    return getScaledValue(baseSize);
  }

  /// Gets recommended line width for series.
  double getLineWidth({double baseWidth = 3.0}) {
    if (isPhone) return baseWidth;
    return baseWidth * 1.1;
  }

  /// Gets recommended legend position based on screen size.
  FusionLegendPosition getRecommendedLegendPosition() {
    if (isPhone && isPortrait) return FusionLegendPosition.bottom;
    if (isTablet && isLandscape) return FusionLegendPosition.right;
    return FusionLegendPosition.bottom;
  }

  /// Gets recommended chart padding based on screen size.
  EdgeInsets getChartPadding({EdgeInsets? basePadding}) {
    final base = basePadding ?? const EdgeInsets.all(4);
    final scale = isPhone ? 1.0 : (isTablet ? 1.25 : 1.5);

    return EdgeInsets.fromLTRB(
      base.left * scale,
      base.top * scale,
      base.right * scale,
      base.bottom * scale,
    );
  }
}

// ==========================================================================
// ENUMS
// ==========================================================================

/// Device type categories.
enum FusionDeviceType {
  /// Phone (< 600dp width).
  phone,

  /// Tablet (600-900dp width).
  tablet,

  /// Desktop (>= 900dp width).
  desktop,
}

// ==========================================================================
// EXTENSION METHODS
// ==========================================================================

/// Extension on BuildContext for easy responsive access.
extension FusionResponsiveContext on BuildContext {
  /// Gets a responsive size helper for this context.
  FusionResponsiveSize get responsive => FusionResponsiveSize(this);
}

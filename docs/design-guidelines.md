# Design Guidelines

This document covers the visual design system of **fusion_charts_flutter**: theming,
color palettes, typography, layout, responsive sizing, interaction patterns, and
animation. It is intended for developers integrating the library and for designers
specifying chart appearance in Flutter applications.

> Cross-references: [API Reference](api-reference.md) | [Configuration Guide](configuration-guide.md)

---

## Table of Contents

1. [Theme System](#theme-system)
2. [Color Palettes](#color-palettes)
3. [Typography](#typography)
4. [Layout System](#layout-system)
5. [Responsive Design](#responsive-design)
6. [Gradients and Fills](#gradients-and-fills)
7. [Shadows and Elevation](#shadows-and-elevation)
8. [Rounded Corners](#rounded-corners)
9. [Markers](#markers)
10. [Data Labels](#data-labels)
11. [Animations](#animations)
12. [Interaction Design](#interaction-design)
13. [Accessibility](#accessibility)
14. [Error Handling](#error-handling)
15. [Creating Custom Themes](#creating-custom-themes)
16. [Example App Gallery](#example-app-gallery)

---

## Theme System

Every chart receives its visual identity from a **theme**. The theme hierarchy is:

```
FusionChartTheme (abstract base class)
├── FusionLightTheme   — light color scheme (default)
└── FusionDarkTheme    — dark color scheme
```

`FusionChartTheme` is abstract and defines the full surface area of visual
properties. The two built-in implementations provide opinionated defaults that
are production-ready. Custom themes implement or extend `FusionChartTheme`
directly.

### Theme Properties

The theme exposes the following categories of properties:

#### Colors

| Property                | Purpose                                        | Light Default  | Dark Default   |
|-------------------------|------------------------------------------------|----------------|----------------|
| `primaryColor`          | Main series color, active interaction elements  | `#6C63FF`      | `#BB86FC`      |
| `secondaryColor`        | Accent elements, gradient endpoints             | `#4CAF50`      | `#03DAC6`      |
| `backgroundColor`       | Chart container background                      | `#FFFFFF`      | `#1E1E1E`      |
| `gridColor`             | Grid lines (subtle, non-distracting)            | `#E0E0E0`      | `#333333`      |
| `textColor`             | All text elements (titles, labels, legend)       | `#2C2C2C`      | `#E0E0E0`      |
| `borderColor`           | Borders and separators                          | `#E0E0E0`      | `#333333`      |
| `axisColor`             | Axis lines (defaults to `gridColor`)            | inherited      | inherited      |
| `errorColor`            | Negative values, errors                         | `#F44336`      | `#F44336`      |
| `successColor`          | Positive values, achievements                   | `#4CAF50`      | `#4CAF50`      |
| `warningColor`          | Caution states                                  | `#FF9800`      | `#FF9800`      |
| `crosshairColor`        | Crosshair guide line                            | primary        | primary        |
| `highlightColor`        | Selected/highlighted elements (20% opacity)     | primary@0.2    | primary@0.2    |
| `hoverColor`            | Hover state (10% opacity)                       | primary@0.1    | primary@0.1    |
| `tooltipBackgroundColor`| Tooltip background                              | `#DD000000`    | `#DD000000`    |
| `markerBorderColor`     | Marker border (contrast ring)                   | `#FFFFFF`      | `#FFFFFF`      |

#### Dimensions

| Property          | Purpose                           | Default    |
|-------------------|-----------------------------------|------------|
| `borderRadius`    | Containers and tooltips           | theme-set  |
| `elevation`       | Card shadow depth (0-16 dp)       | theme-set  |
| `axisLineWidth`   | Axis line stroke width            | 1.0-1.5 px |
| `gridLineWidth`   | Grid line stroke width            | 0.5-1.0 px |
| `seriesLineWidth` | Default series line width         | 3.0 px     |
| `markerSize`      | Data point marker diameter        | 6.0 px     |
| `chartPadding`    | Inner padding of chart container  | 4.0 all    |
| `legendSpacing`   | Spacing between legend items      | 8.0 px     |
| `axisLabelPadding`| Gap between axis and its labels   | 8.0 px     |

### Applying a Theme

```dart
// Light theme (default — no configuration needed)
FusionLineChart(
  series: [mySeries],
)

// Explicit dark theme
final config = FusionChartConfigurationBuilder()
  .withTheme(FusionDarkTheme())
  .build();

FusionLineChart(
  configuration: config,
  series: [mySeries],
)
```

For the full list of configurable properties, see the [Configuration Guide](configuration-guide.md).

---

## Color Palettes

The library ships six pre-built color palettes, each containing six colors. When
a chart has more series than palette colors, colors cycle automatically.

### Built-in Palettes

| Palette          | Accessor                            | Character                      |
|------------------|-------------------------------------|--------------------------------|
| **Material**     | `FusionColorPalette.material`       | Standard Material Design tones |
| **Professional** | `FusionColorPalette.professional`   | Blue-scale business palette    |
| **Vibrant**      | `FusionColorPalette.vibrant`        | Bright, saturated, high energy |
| **Pastel**       | `FusionColorPalette.pastel`         | Soft, muted, gentle tones      |
| **Warm**         | `FusionColorPalette.warm`           | Red / orange / yellow spectrum |
| **Cool**         | `FusionColorPalette.cool`           | Blue / green / teal spectrum   |

### Palette Colors

**Material** (default)
```
#6C63FF  #4CAF50  #F44336  #FF9800  #2196F3  #9C27B0
```

**Professional**
```
#0D47A1  #1976D2  #2196F3  #42A5F5  #64B5F6  #90CAF9
```

**Vibrant**
```
#FF3366  #00D9FF  #FFD600  #00FF94  #FF00E5  #00F0FF
```

**Pastel**
```
#B4A7D6  #A8D5BA  #FFB4A2  #FFC09F  #AED8E6  #D5A6BD
```

**Warm**
```
#FF6B6B  #FF8E53  #FFC93C  #FFE66D  #FF8B94  #FFAB91
```

**Cool**
```
#4ECDC4  #44A8B3  #5C7AEA  #48A9A6  #7F9C96  #89B5AF
```

### Using a Palette

```dart
// Access a single color by index (cycles if out of range)
final color = FusionColorPalette.vibrant.colorAt(0); // #FF3366

// Generate a linear gradient between two palette indices
final gradient = FusionColorPalette.warm.gradient(0, 2);
```

### Custom Palettes

```dart
final brandPalette = FusionColorPalette([
  Color(0xFF1A1A2E),
  Color(0xFF16213E),
  Color(0xFF0F3460),
  Color(0xFFE94560),
]);
```

### Color Utilities

`FusionColorPalette` provides static helpers:

- `lightenColor(color, amount)` / `darkenColor(color, amount)` -- adjust lightness via HSL
- `getContrastingTextColor(backgroundColor, {threshold, darkColor, lightColor})` -- returns black or white based on WCAG luminance
- `generateGradient(colors, {startIndex, endIndex, begin, end})` -- build a `LinearGradient` from a color list

---

## Typography

All text rendered by the library is styled through `TextStyle` objects defined on
the theme. Every text style can be overridden per-component in configuration.

### Theme Text Styles

| Style             | Used For                          | Recommended Size | Weight   |
|-------------------|-----------------------------------|------------------|----------|
| `titleStyle`      | Chart title                       | 18-20 px         | 600-700  |
| `subtitleStyle`   | Subtitle / secondary text         | 14 px            | 500      |
| `axisLabelStyle`  | Axis tick labels                  | 10-12 px         | 500      |
| `legendStyle`     | Legend item text                  | 11-13 px         | 400-500  |
| `tooltipStyle`    | Tooltip content                   | 12-13 px         | 600      |
| `dataLabelStyle`  | Labels rendered on data points    | 10-11 px         | 600      |

### Overriding Text Styles

Any text element can be customized independently:

```dart
final config = FusionChartConfigurationBuilder()
  .withTheme(FusionLightTheme())
  .build();

// Axis labels use the theme's axisLabelStyle by default.
// Override through axis configuration:
final axisConfig = FusionAxisConfiguration(
  labelStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.blueGrey,
  ),
);
```

The `FusionThemeUtils` mixin's `createTextStyle()` accepts an optional
`fontFamily`. By default the system font is used. Override theme text style
getters to apply a custom font globally.

---

## Layout System

Chart layout is computed automatically by two core classes.

### ChartLayout

A computed, immutable model that holds the resolved positions and sizes of all
chart regions:

- **Chart area** -- the rectangle where series are drawn
- **Axis areas** -- the strips reserved for X and Y axis labels
- **Legend area** -- the region allocated to the legend
- **Margins and padding** -- spacing around and within the chart

### ChartLayoutManager

The layout manager takes the chart's total size, configuration, and data, then
calculates the `ChartLayout`. It handles:

- Measuring axis label text widths and heights
- Reserving space for the legend based on its position (top, bottom, left, right)
- Applying `chartPadding` from the theme
- Determining the final drawable chart area

### Label Collision Avoidance

When axis labels overlap, the `AxisLabelIntersectAction` enum controls the
resolution strategy:

| Value    | Behavior                              |
|----------|---------------------------------------|
| `hide`   | Hide overlapping labels               |
| `none`   | No action (labels may overlap)        |

These are set through `FusionAxisConfiguration`. See the
[Configuration Guide](configuration-guide.md) for full axis options.

### FusionMarginCalculator

A utility that computes margins and padding automatically, factoring in axis
label sizes, title presence, and legend placement so that charts use space
efficiently without manual margin tuning.

### FusionAxisAlignment

Controls positioning and alignment of axis labels relative to their axis line,
ensuring labels do not clip outside the chart container.

---

## Responsive Design

Charts adapt to their container size automatically. The library provides explicit
utilities for cases where fine-grained control is needed.

### FusionResponsiveSize

A context-aware helper that reads `MediaQuery` and exposes breakpoints and
scaling functions:

```dart
final responsive = FusionResponsiveSize(context);
responsive.isPhone;   // width < 600 dp
responsive.isTablet;  // 600-899 dp
responsive.isDesktop; // >= 900 dp

final height   = responsive.getChartHeight();
final fontSize = responsive.getScaledFontSize(12);
final padding  = responsive.getScaledPadding(16);
```

### Device Breakpoints

| Device  | Width Threshold | Typical Adjustments                         |
|---------|-----------------|---------------------------------------------|
| Phone   | < 600 dp        | Smaller fonts, fewer axis labels, tap input  |
| Tablet  | 600-899 dp      | Medium fonts, mixed touch/pointer input      |
| Desktop | >= 900 dp       | Full fonts, hover tooltips, mouse wheel zoom |

### Platform-Specific Behavior

The library detects input modality automatically:

- **Mobile (touch):** Tap and long-press for tooltips, pinch-to-zoom, drag-to-pan
- **Tablet:** Same touch gestures, larger hit targets
- **Desktop:** Hover tooltips, mouse wheel zoom, click-and-drag pan, scroll interception via `FusionScrollInterceptWrapper`

### Container Sizing

Charts fill the space given by their parent widget. Use `SizedBox`, `Expanded`,
`AspectRatio`, or any standard Flutter layout widget to control chart dimensions.

---

## Gradients and Fills

Series support `LinearGradient` and `RadialGradient` for fills.

### Area Fill Gradient

Line and area charts fill the region below the line with a gradient. The theme
controls default opacity through `areaFillOpacity` (default 0.3).

```dart
FusionLineSeries(
  dataSource: data,
  gradient: LinearGradient(
    colors: [Colors.blue, Colors.blue.withOpacity(0.0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
)
```

### Generating Gradients from Palettes

```dart
// Quick two-color gradient from a palette
final gradient = FusionColorPalette.cool.gradient(0, 2);
```

Each theme also provides `chartGradientColors`, a list of 2-3 colors designed
for multi-color gradients in area charts and backgrounds.

---

## Shadows and Elevation

Shadows add depth and visual hierarchy.

### Series Shadow

The theme's `seriesShadow` (`BoxShadow`) is applied to lines and bars. Defaults:
offset (0, 2), blur 4, color = primaryColor at 20% opacity.

### Chart Container Shadow

`chartShadow` returns a `List<BoxShadow>` derived from the theme's `elevation`
value, applied to the chart card.

### Custom Shadows on Series

Series configurations accept a `BoxShadow` for per-series customization:

```dart
FusionLineSeries(
  dataSource: data,
  shadow: BoxShadow(
    color: Colors.blue.withOpacity(0.3),
    offset: Offset(0, 4),
    blurRadius: 8,
  ),
)
```

### Pie Chart Shadows

Pie charts use `pieShadowColor` (default `Colors.black26`) for segment drop
shadows.

---

## Rounded Corners

### Bar Charts

`borderRadius` on bar series controls corner rounding of each bar:

```dart
FusionBarSeries(
  dataSource: data,
  borderRadius: BorderRadius.circular(8),
)
```

### Pie Charts

Pie segments support rounded edges through the pie chart configuration, creating
a softer visual appearance.

### Tooltips

Tooltip corner radius is set through `tooltipBorderRadius` on the theme
(default 8.0 px).

### Data Labels

Data label background boxes use `dataLabelBorderRadius` (default 3.0 px).

---

## Markers

Data point markers are rendered at each plotted value on line and area charts.
Six shapes are available via the `MarkerShape` enum:

| Shape       | Enum Value             | Visual   |
|-------------|------------------------|----------|
| Circle      | `MarkerShape.circle`   | Filled circle |
| Square      | `MarkerShape.square`   | Filled square |
| Triangle    | `MarkerShape.triangle` | Upward triangle |
| Diamond     | `MarkerShape.diamond`  | 45-degree rotated square |
| Pentagon    | `MarkerShape.pentagon` | Five-sided polygon |
| Plus        | `MarkerShape.plus`     | Cross / plus sign |

### Marker Sizing

The theme provides `markerSize` (default 6.0 px). Markers also have a border
ring colored by `markerBorderColor` (default white) for contrast against the
series color.

### Usage

```dart
FusionLineSeries(
  dataSource: data,
  markerShape: MarkerShape.diamond,
  markerSize: 8.0,
)
```

---

## Data Labels

Data labels display values directly on the chart next to their data points. The
`FusionDataLabelDisplay` enum controls which points receive labels:

| Mode         | Behavior                                      |
|--------------|-----------------------------------------------|
| `all`        | Label every data point (can be cluttered)      |
| `max`        | Label only the maximum value                   |
| `min`        | Label only the minimum value                   |
| `maxAndMin`  | Label both the maximum and minimum values      |
| `none`       | No data labels                                 |

### Styling

Data labels inherit `dataLabelStyle` from the theme (10-11 px, weight 600). They
render with a semi-transparent background (`dataLabelBackgroundOpacity` = 0.9)
and rounded corners (`dataLabelBorderRadius` = 3.0 px), with internal padding
controlled by `dataLabelPadding`.

```dart
FusionLineSeries(
  dataSource: data,
  dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
)
```

---

## Animations

Charts animate on initial render. Animation behavior is controlled through the
theme and can be overridden per chart.

### Theme Animation Properties

| Property            | Purpose                    | Typical Range     |
|---------------------|----------------------------|-------------------|
| `animationDuration` | Total animation duration    | 500-2000 ms       |
| `animationCurve`    | Easing curve               | `easeInOutCubic`  |

### Supported Curves

Flutter's standard `Curves` class provides all available easing functions. Common
choices for charts:

| Curve                | Character                                        |
|----------------------|--------------------------------------------------|
| `Curves.easeInOut`   | Smooth start and end (general purpose)            |
| `Curves.easeInOutCubic` | Slightly more pronounced ease (Material feel) |
| `Curves.easeOut`     | Fast start, slow end (draws attention to result)  |
| `Curves.elasticOut`  | Overshoot and settle (playful, attention-getting) |
| `Curves.bounceOut`   | Bounce at the end (energetic, informal)           |
| `Curves.fastOutSlowIn` | Material Design standard motion               |

### Entry Animation

On first render, series elements animate from zero to their target values. Bars
grow from the axis, lines draw progressively, and pie segments expand from the
center.

### Ticker Management

The library uses `TickerProviderStateMixin` internally to support multiple
concurrent animation controllers without ticker conflicts.

---

## Interaction Design

The library provides layered interaction features that can be enabled or disabled
independently through `FusionChartConfiguration`.

### Tooltips

Tooltips display data details when the user interacts with a data point.

**Activation modes** (`FusionTooltipActivationMode`):

| Mode          | Trigger                          | Best For           |
|---------------|----------------------------------|--------------------|
| `singleTap`   | Single tap                      | Mobile (default)   |
| `longPress`   | Long press                      | Dense data         |
| `doubleTap`   | Double tap                      | Prevent accidental |
| `hover`        | Mouse hover                    | Desktop / web      |
| `always`       | Always visible                 | Dashboards         |

**Dismiss strategies** are configured separately to control when tooltips
disappear (on tap outside, after delay, on next gesture, etc.).

**Custom tooltip builders** allow fully custom widget trees inside the tooltip
popup. See the [API Reference](api-reference.md) for `FusionTooltipConfiguration`
and `FusionStackedTooltipBuilder`.

**Tooltip visual properties** from the theme:

| Property                  | Default           |
|---------------------------|-------------------|
| `tooltipBackgroundColor`  | `#DD000000`       |
| `tooltipBorderRadius`     | 8.0 px            |
| `tooltipBorderWidth`      | 2.0 px            |
| `tooltipPadding`          | 12h x 8v          |
| `tooltipIndicatorRadius`  | 2.0 px            |

### Crosshair

A guide line (vertical, horizontal, or both) that follows the user's pointer or
touch position to help read values. The crosshair color defaults to
`primaryColor` and is toggled via `enableCrosshair` on `FusionChartConfiguration`.

### Selection

Tapping a data point highlights it with the `highlightColor` (primaryColor at
20% opacity). This provides visual feedback that a point has been selected,
useful for detail panels or drill-down workflows.

### Zoom

Zoom is enabled via `enableZoom` on `FusionChartConfiguration`. A visual
selection rectangle overlay appears when the user drags to select a region.
Configuration options are in `FusionZoomConfiguration`.

On desktop, mouse wheel zoom is supported. The `FusionZoomControls` widget
provides on-screen zoom buttons.

### Pan

Pan is enabled via `enablePanning` on `FusionChartConfiguration`. Panning uses
smooth momentum-based scrolling for a natural feel. Configuration details are in
`FusionPanConfiguration`.

### Desktop Helpers

`FusionDesktopHelper` provides utilities for detecting desktop platforms and
adjusting interaction accordingly. `FusionScrollInterceptWrapper` prevents parent
scroll views from consuming scroll events intended for chart zoom/pan.

---

## Accessibility

### Color Contrast

The light theme is designed for WCAG 2.1 Level AA compliance:

- Text on background: minimum 4.5:1 contrast ratio
- `FusionLightTheme` text color `#2C2C2C` on `#FFFFFF` achieves 13.5:1

### Color-Blind Friendliness

The Material palette is chosen for distinguishability across common color vision
deficiencies. For maximum accessibility, use the Professional palette (blue scale
with luminance variation) or apply marker shapes (`MarkerShape`) as a secondary
differentiator.

### Contrast Utilities

Both `FusionColorPalette.getContrastingTextColor()` (static) and the theme
instance method `getContrastingTextColor()` return black or white based on
background luminance. The `FusionThemeUtils` mixin adds `isLightColor()` for
boolean checks.

---

## Error Handling

### FusionChartErrorBoundary

Wrap any chart in `FusionChartErrorBoundary` to catch and display rendering
errors gracefully instead of crashing the widget tree:

```dart
FusionChartErrorBoundary(
  child: FusionLineChart(
    series: [mySeries],
  ),
)
```

When a rendering error occurs, the boundary replaces the chart with a
user-friendly error message rather than a red error screen.

---

## Creating Custom Themes

### Option 1: Implement the Abstract Class

For full control, implement `FusionChartTheme` and mix in `FusionThemeUtils`.
You must override all abstract getters: `primaryColor`, `secondaryColor`,
`backgroundColor`, `gridColor`, `textColor`, `borderColor`, `titleStyle`,
`axisLabelStyle`, `legendStyle`, `tooltipStyle`, `borderRadius`, `elevation`,
`axisLineWidth`, `gridLineWidth`, `chartGradientColors`, `animationDuration`,
and `animationCurve`. All other properties have sensible defaults.

```dart
class CorporateTheme extends FusionChartTheme with FusionThemeUtils {
  const CorporateTheme();

  @override
  Color get primaryColor => Color(0xFF1A73E8);
  @override
  Color get secondaryColor => Color(0xFF34A853);
  @override
  Color get backgroundColor => Colors.white;
  @override
  Color get gridColor => Color(0xFFE8EAED);
  @override
  Color get textColor => Color(0xFF202124);
  @override
  Color get borderColor => Color(0xFFDADCE0);

  @override
  TextStyle get titleStyle => createTextStyle(
    fontSize: 18, fontWeight: FontWeight.w700, color: textColor);
  @override
  TextStyle get axisLabelStyle => createTextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, color: textColor);
  @override
  TextStyle get legendStyle => createTextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: textColor);
  @override
  TextStyle get tooltipStyle => createTextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white);

  @override
  double get borderRadius => 12.0;
  @override
  double get elevation => 2.0;
  @override
  double get axisLineWidth => 1.0;
  @override
  double get gridLineWidth => 0.5;
  @override
  List<Color> get chartGradientColors => [primaryColor, secondaryColor];
  @override
  Duration get animationDuration => Duration(milliseconds: 800);
  @override
  Curve get animationCurve => Curves.easeInOutCubic;
}
```

### Option 2: Extend a Built-in Theme

For smaller adjustments, extend `FusionLightTheme` or `FusionDarkTheme`:

```dart
class BrandedLightTheme extends FusionLightTheme {
  const BrandedLightTheme();

  @override
  Color get primaryColor => Color(0xFFFF6600); // brand orange
}
```

### Design Principles

The theme system follows the **Open/Closed Principle**: it is open for extension
(create any number of custom themes) and closed for modification (the abstract
interface remains stable).

The `FusionThemeUtils` mixin provides shared helper methods available to all
theme implementations:

| Method                      | Purpose                                    |
|-----------------------------|--------------------------------------------|
| `createTextStyle()`         | Build a `TextStyle` with named parameters  |
| `createGradient()`          | Build a `LinearGradient` from color list   |
| `isLightColor()`            | Check if a color is light (luminance > 0.5)|
| `getContrastingTextColor()` | Return black or white for best contrast    |

Theme instances also provide:

| Method                 | Purpose                                         |
|------------------------|-------------------------------------------------|
| `lighten(color, amount)` | Return a lighter version of a color (HSL)     |
| `darken(color, amount)`  | Return a darker version of a color (HSL)      |
| `withOpacity(color, opacity)` | Adjust alpha channel                     |

---

## Example App Gallery

The project includes a full example application demonstrating all visual features.

### Structure

The example app uses Material Design 3, supports dark/light mode toggling, and
organizes demonstrations across 8 showcase files covering all chart types and
configurations.

### Running the Example

```bash
cd example
flutter run
```

Key demonstrations include theme switching, palette comparison, gradient fills,
shadow effects, all six marker shapes, data label modes, responsive layout, and
interaction modes (tooltips, crosshair, zoom, pan).

---

## Quick Reference

### Minimum Viable Chart

```dart
FusionLineChart(
  series: [FusionLineSeries(dataSource: myData)],
)
```

This renders with the default light theme, Material palette, entry animation,
and no interactive features enabled.

### Fully Styled Chart

```dart
final config = FusionChartConfigurationBuilder()
  .withTheme(FusionDarkTheme())
  .withEnableCrosshair(true)
  .withEnableZoom(true)
  .withEnablePanning(true)
  .build();

FusionChartErrorBoundary(
  child: FusionLineChart(
    configuration: config,
    series: [
      FusionLineSeries(
        dataSource: myData,
        gradient: LinearGradient(
          colors: [Colors.cyan, Colors.cyan.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        markerShape: MarkerShape.diamond,
        dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
      ),
    ],
  ),
)
```

For additional options, see the [Configuration Guide](configuration-guide.md)
and [API Reference](api-reference.md).

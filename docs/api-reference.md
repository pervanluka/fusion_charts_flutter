# API Reference

Public API reference for `fusion_charts_flutter`. All types below are exported
from the single entry point:

```dart
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';
```

See also: [System Architecture](system-architecture.md) | [Configuration Guide](configuration-guide.md)

---

## Chart Widgets

The four top-level widgets are the primary consumer API. Each is a `StatefulWidget`.

### FusionLineChart

Line, area, and curved-line charts.

```dart
const FusionLineChart({
  required List<FusionLineSeries> series,
  FusionChartConfiguration? config,
  FusionAxisConfiguration? xAxis,
  FusionAxisConfiguration? yAxis,
  String? title,
  String? subtitle,
  FusionChartController? controller,
  FusionLiveChartController? liveController,
  LiveViewportMode? liveViewportMode,
  void Function(FusionDataPoint point, String seriesName)? onPointTap,
  void Function(FusionDataPoint point, String seriesName)? onPointLongPress,
})
```

| Prop | Description |
|------|-------------|
| `series` | One or more `FusionLineSeries`. At least one required. |
| `config` | Base or line-specific configuration (`FusionLineChartConfiguration`). |
| `xAxis` / `yAxis` | Axis configuration (range, labels, ticks, grid). |
| `controller` | Programmatic zoom/pan via `FusionChartController`. |
| `liveController` | Real-time streaming via `FusionLiveChartController`. When provided, data comes from the controller; series objects define styling only. |
| `liveViewportMode` | Viewport strategy for live mode. Defaults to auto-scroll 60 s. |

### FusionBarChart

Vertical (column) and horizontal bar charts, grouped or overlapped.

```dart
const FusionBarChart({
  required List<FusionBarSeries> series,
  FusionChartConfiguration? config,   // or FusionBarChartConfiguration
  FusionAxisConfiguration? xAxis,
  FusionAxisConfiguration? yAxis,
  String? title,
  String? subtitle,
  FusionChartController? controller,
  FusionLiveChartController? liveController,
  LiveViewportMode? liveViewportMode,
  void Function(FusionDataPoint, String)? onBarTap,
  void Function(FusionDataPoint, String)? onBarLongPress,
})
```

### FusionStackedBarChart

Stacked and 100 % stacked bar charts.

```dart
const FusionStackedBarChart({
  required List<FusionStackedBarSeries> series,
  FusionStackedBarChartConfiguration? config,
  FusionAxisConfiguration? xAxis,
  FusionAxisConfiguration? yAxis,
  String? title,
  String? subtitle,
  FusionChartController? controller,
})
```

Enable 100 % mode via `FusionStackedBarChartConfiguration(isStacked100: true)`.

### FusionPieChart

Pie and donut charts with explode, selection, and label support.

```dart
const FusionPieChart({
  required FusionPieSeries series,
  FusionPieChartConfiguration? config,
  String? title,
  String? subtitle,
})
```

Set `innerRadiusPercent > 0` in the config to get a donut chart.

---

## Series Types

### FusionLineSeries

```dart
const FusionLineSeries({
  required List<FusionDataPoint> dataPoints,
  required Color color,
  String? name,
  bool visible = true,
  double lineWidth = 3.0,           // 0 < lineWidth <= 10
  bool isCurved = true,
  double smoothness = 0.35,         // 0..1
  List<double>? lineDashArray,
  Gradient? gradient,
  bool showMarkers = false,
  double markerSize = 6.0,
  MarkerShape markerShape = MarkerShape.circle,
  bool showShadow = true,
  BoxShadow? shadow,
  bool showArea = false,
  double areaOpacity = 0.3,
  bool showDataLabels = false,
  FusionDataLabelDisplay dataLabelDisplay = FusionDataLabelDisplay.all,
  TextStyle? dataLabelStyle,
  String Function(FusionDataPoint)? dataLabelFormatter,
  Duration? animationDuration,
  Curve? animationCurve,
  FusionSeriesInteraction interaction,
})
```

Key notes:
- Set `showArea: true` for an area chart (equivalent to `FusionAreaSeries`).
- `isCurved: true` with `smoothness` controls Bezier tension.
- `gradient` applies to the line stroke (and area fill when enabled).

### FusionAreaSeries

Identical API to `FusionLineSeries` with `showArea` defaulting to `true`.

### FusionBarSeries

```dart
const FusionBarSeries({
  required List<FusionDataPoint> dataPoints,
  required Color color,
  String? name,
  bool visible = true,
  double barWidth = 0.6,            // 0 < barWidth <= 1
  double borderRadius = 4.0,
  double spacing = 0.2,             // 0 <= spacing < 1
  Gradient? gradient,
  Color? borderColor,
  double borderWidth = 0.0,
  bool showShadow = true,
  BoxShadow? shadow,
  bool showDataLabels = false,
  TextStyle? dataLabelStyle,
  String Function(FusionDataPoint)? dataLabelFormatter,
  Duration? animationDuration,
  Curve? animationCurve,
  bool isVertical = true,           // false = horizontal bars
  bool isTrackVisible = false,      // background track bar
  Color? trackColor,
  double trackBorderWidth = 0.0,
  Color? trackBorderColor,
  double trackPadding = 0.0,
  FusionSeriesInteraction interaction,
})
```

### FusionStackedBarSeries

```dart
const FusionStackedBarSeries({
  required List<FusionDataPoint> dataPoints,
  required String name,             // required (used in legend/tooltip)
  required Color color,
  bool visible = true,
  double barWidth = 0.7,
  double borderRadius = 0.0,
  double spacing = 0.0,
  String groupName = '',            // series with same groupName stack together
  Gradient? gradient,
  Color? borderColor,
  double borderWidth = 0.0,
  bool showShadow = false,
  BoxShadow? shadow,
  bool showDataLabels = false,
  TextStyle? dataLabelStyle,
  String Function(FusionDataPoint)? dataLabelFormatter,
  Duration? animationDuration,
  Curve? animationCurve,
  bool isVertical = true,
  FusionSeriesInteraction interaction,
})
```

### FusionPieSeries

```dart
FusionPieSeries({
  required List<FusionPieDataPoint> dataPoints,
  double innerRadiusPercent = 0.0,
  double startAngle = -90,
  double explodeOffset = 12,
  PieDirection direction = PieDirection.clockwise,
  PieSortMode sortMode = PieSortMode.none,
  FusionColorPalette? colorPalette,
})
```

Pie-specific enums defined alongside the series:

| Enum | Values |
|------|--------|
| `PieDirection` | `clockwise`, `counterClockwise` |
| `PieSortMode` | `none`, `ascending`, `descending` |
| `PieSelectionMode` | `none`, `single`, `multiple` |
| `PieLabelPosition` | `auto`, `inside`, `outside`, `none` |

---

## Data Points

### FusionDataPoint

Used by line, bar, and stacked bar charts.

```dart
const FusionDataPoint(
  double x,
  double y, {
  String? label,
  Map<String, dynamic>? metadata,
})
```

Methods: `copyWith(...)`, `lerp(other, t)`, `distanceTo(other)`, `isWithinBounds(...)`.

List extension on `List<FusionDataPoint>`: `minX`, `maxX`, `minY`, `maxY`,
`averageY`, `sumY`, `filterByBounds(...)`, `sortByX()`, `sortByY()`.

`FusionDataPointHelper` static factories: `generate(...)`, `fromLists(...)`,
`fromMap(...)`, `random(...)`.

### FusionPieDataPoint

Used by pie/donut charts.

```dart
const FusionPieDataPoint(
  double value, {            // must be >= 0
  String? label,
  Color? color,
  Gradient? gradient,
  Color? borderColor,
  double borderWidth = 0.0,
  double cornerRadius = 0.0,
  BoxShadow? shadow,
  bool explode = false,
  double? explodeOffset,
  bool enabled = true,
  bool visible = true,
  void Function(FusionPieDataPoint, int)? onTap,
  void Function(FusionPieDataPoint, int)? onDoubleTap,
  void Function(FusionPieDataPoint, int)? onLongPress,
  void Function(FusionPieDataPoint, int, bool)? onHover,
  dynamic tooltip,
  Object? metadata,
})
```

Color resolution order: data point `color` > series palette at index > theme palette at index.

---

## Configuration Classes

### FusionChartConfiguration (base)

Shared settings for all chart types. Chart-specific configs extend this class.

```dart
const FusionChartConfiguration({
  FusionChartTheme? theme,                        // default: FusionLightTheme()
  FusionTooltipBehavior tooltipBehavior,
  FusionCrosshairConfiguration crosshairBehavior,
  FusionZoomConfiguration zoomBehavior,
  FusionPanConfiguration panBehavior,
  InteractionAnchorMode interactionAnchorMode,
  bool enableAnimation = true,
  bool enableTooltip = true,
  bool enableCrosshair = false,
  bool enableZoom = false,
  bool enablePanning = false,
  bool enableSelection = true,
  bool enableLegend = true,
  bool enableDataLabels = false,
  bool enableBorder = false,
  bool enableGrid = true,
  bool enableAxis = true,
  EdgeInsets padding = EdgeInsets.all(4),
  Duration? animationDuration,
  Curve? animationCurve,
})
```

### FusionLineChartConfiguration

Extends `FusionChartConfiguration` with line-specific options (marker defaults,
line width, etc.). Pass to `FusionLineChart.config`.

### FusionBarChartConfiguration

Extends `FusionChartConfiguration`. Key additions:

- `barWidthRatio` -- overall width ratio across grouped bars.
- `enableSideBySideSeriesPlacement` -- `true` = grouped, `false` = overlapped.

### FusionStackedBarChartConfiguration

Extends `FusionChartConfiguration`. Key additions:

- `isStacked100` -- normalize to 100 %.
- `tooltipValueFormatter` -- format values in multi-segment tooltips.

### FusionPieChartConfiguration

Extends `FusionChartConfiguration`. Key parameters:

| Group | Parameters |
|-------|-----------|
| Layout | `innerRadiusPercent` (0 = pie, >0 = donut), `outerRadiusPercent`, `startAngle`, `direction`, `chartPadding` |
| Labels | `labelPosition`, `showLabels`, `showPercentages`, `showValues`, `percentageThreshold`, `labelFormatter` |
| Center | `showCenterLabel`, `centerLabelText`, `centerWidget` (donut hole content) |
| Animation | `animationType` (`sweep`, `scale`, `fade`) |
| Selection | `selectionMode`, `selectedOpacity`, `unselectedOpacity`, `selectedScale` |
| Hover | `enableHover`, `hoverScale` |
| Explode | `explodeOffset`, `explodeOnSelection`, `explodeOnHover` |
| Legend | `legendPosition` |

### FusionAxisConfiguration

Styling and behavior for a single axis. Passed via `xAxis` / `yAxis` on chart
widgets.

```dart
const FusionAxisConfiguration({
  FusionAxisBase? axisType,          // FusionNumericAxis, FusionCategoryAxis, etc.
  double? min,
  double? max,
  double? interval,
  String? title,
  String Function(double)? labelFormatter,
  TextStyle? labelStyle,
  double? labelRotation,
  LabelAlignment labelAlignment = LabelAlignment.center,
  bool visible = true,
  bool autoRange = true,
  bool autoInterval = true,
  bool? includeZero,
  int desiredTickCount = 5,
  int desiredIntervals = 5,
  bool useAbbreviation = true,
  bool showGrid = true,
  bool showMinorGrid = false,
  bool showMinorTicks = false,
  bool showTicks = false,
  bool showLabels = true,
  bool showAxisLine = true,
  AxisPosition? position,
  Color? majorGridColor,
  double? majorGridWidth,
  Color? minorGridColor,
  double? minorGridWidth,
  Color? axisLineColor,
  double? axisLineWidth,
  AxisRangePadding? rangePadding,
  String Function(num value, int index)? labelGenerator,
})
```

The `labelGenerator` callback gives full control over axis label text:

```dart
xAxis: FusionAxisConfiguration(
  labelGenerator: (value, index) => '\$${value.toStringAsFixed(0)}',
)
```

### FusionTooltipBehavior

```dart
const FusionTooltipBehavior({
  FusionTooltipPosition position = FusionTooltipPosition.floating,
  FusionTooltipActivationMode activationMode = FusionTooltipActivationMode.auto,
  FusionDismissStrategy dismissStrategy = FusionDismissStrategy.onRelease,
  Duration dismissDelay = Duration(milliseconds: 300),
  Duration duration = Duration(milliseconds: 3000),
  FusionTooltipTrackballMode trackballMode = FusionTooltipTrackballMode.none,
  double trackballSnapRadius = 20.0,
  bool showTrackballLine = true,
  Duration animationDuration = Duration(milliseconds: 200),
  Curve animationCurve = Curves.easeOutCubic,
  double elevation = 2.5,
  bool shared = false,
  double opacity = 0.9,
  bool hapticFeedback = true,
  String? format,
  Widget Function(BuildContext, List<FusionDataPoint>)? builder,
  Color? color,
  TextStyle? textStyle,
  Color? borderColor,
})
```

### FusionCrosshairConfiguration

Crosshair lines that follow the pointer or snap to data points.

Key properties: `lineColor`, `lineWidth`, `labelStyle`,
`xLabelFormatter`, `yLabelFormatter`, `labelBuilder`, `dismissStrategy`.

### FusionZoomConfiguration

```dart
const FusionZoomConfiguration({
  bool enablePinchZoom = true,
  bool enableMouseWheelZoom = true,
  bool requireModifierForWheelZoom = true,
  bool enableSelectionZoom = true,
  bool enableDoubleTapZoom = true,
  double minZoomLevel = 0.5,
  double maxZoomLevel = 5.0,
  double zoomSpeed = 1.0,
  bool enableZoomControls = false,
  FusionZoomMode zoomMode = FusionZoomMode.both,
  bool animateZoom = true,
  Duration zoomAnimationDuration = Duration(milliseconds: 300),
  Curve zoomAnimationCurve = Curves.easeInOut,
})
```

### FusionPanConfiguration

```dart
const FusionPanConfiguration({
  FusionPanMode panMode = FusionPanMode.both,
  bool enableInertia = true,
  Duration inertiaDuration = Duration(milliseconds: 500),
  double inertiaDecay = 0.95,              // 0..1
  FusionPanEdgeBehavior edgeBehavior = FusionPanEdgeBehavior.bounce,
})
```

### FusionLegendConfiguration

```dart
const FusionLegendConfiguration({
  bool visible = true,
  FusionLegendPosition position = FusionLegendPosition.bottom,
  FusionLegendAlignment alignment = FusionLegendAlignment.center,
  FusionLegendOrientation orientation = FusionLegendOrientation.horizontal,
  Color? backgroundColor,
  Color? borderColor,
  double borderWidth = 0.0,
  double borderRadius = 4.0,
  EdgeInsets padding = EdgeInsets.all(8),
  EdgeInsets margin = EdgeInsets.all(8),
  double itemSpacing = 16.0,
  double iconSize = 16.0,
  double iconPadding = 8.0,
  TextStyle? textStyle,
  bool toggleSeriesOnTap = true,
  Widget Function(dynamic series, int index)? itemBuilder,
  double? maxWidth,
  double? maxHeight,
  bool scrollable = false,
})
```

---

## Controllers

### FusionChartController

Programmatic zoom and pan control. Extends `ChangeNotifier`.

```dart
final controller = FusionChartController();
```

| Member | Type | Description |
|--------|------|-------------|
| `isAttached` | `bool` | Whether the controller is bound to a chart |
| `isZoomed` | `bool` | Whether the chart is currently zoomed |
| `zoomLevel` | `double` | Current zoom multiplier (1.0 = no zoom) |
| `zoomIn()` | `void` | Zoom in 1.5x centered |
| `zoomOut()` | `void` | Zoom out 1.5x centered |
| `resetZoom()` | `void` | Animated reset to original bounds |
| `reset()` | `void` | Reset all interactions (zoom, pan, tooltips) |
| `dispose()` | `void` | Detach and release resources |

Pass the controller to any chart widget via the `controller` parameter and
call `dispose()` in your state's `dispose()` method.

### FusionLiveChartController

Real-time data streaming controller. Extends `ChangeNotifier`.

```dart
FusionLiveChartController({
  RetentionPolicy retentionPolicy = const RetentionPolicy.unlimited(),
  bool frameCoalescing = true,
  OutOfOrderBehavior outOfOrderBehavior = OutOfOrderBehavior.acceptWithWarning,
  DuplicateTimestampBehavior duplicateTimestampBehavior = DuplicateTimestampBehavior.replace,
})
```

| Method | Signature | Description |
|--------|-----------|-------------|
| `addPoint` | `bool addPoint(String seriesName, FusionDataPoint point)` | Push a single point. Returns `false` if rejected. |
| `bindStream` | `void bindStream<T>(String seriesName, Stream<T> stream, {required FusionDataPoint Function(T) mapper})` | Bind a Dart stream to a series |
| `retentionPolicy` | getter/setter | Change retention at runtime |
| `dispose` | `void dispose()` | Cancel streams, release buffers |

The `retentionPolicy` setter triggers immediate eviction under the new policy.

---

## Axis Types

Assign an axis type via `FusionAxisConfiguration(axisType: ...)`.

### FusionNumericAxis

Continuous numeric data with smart interval calculation (Wilkinson's Extended
Algorithm).

```dart
const FusionNumericAxis({
  String? name,
  String? title,
  TextStyle? titleStyle,
  bool opposedPosition = false,
  bool isInversed = false,
  double? min,
  double? max,
  double? interval,
  int desiredIntervals = 5,
  // ...
})
```

### FusionCategoryAxis

Discrete labeled categories.

```dart
const FusionCategoryAxis({
  required List<String> categories,
  String? name,
  String? title,
  LabelAlignment labelAlignment = LabelAlignment.center,
  // ...
})
```

### FusionDateTimeAxis

Time-series data with automatic date formatting.

```dart
const FusionDateTimeAxis({
  DateTime? min,
  DateTime? max,
  Duration? interval,
  int desiredIntervals = 5,
  DateFormat? dateFormat,
  String? name,
  String? title,
  LabelAlignment labelAlignment = LabelAlignment.center,
  // ...
})
```

Data points use millisecondsSinceEpoch for the `x` value when paired with this
axis type.

---

## Enums

### Zoom and Pan

| Enum | Values |
|------|--------|
| `FusionZoomMode` | `horizontal`, `vertical`, `both` |
| `FusionPanMode` | `horizontal`, `vertical`, `both` |
| `FusionPanEdgeBehavior` | `stop`, `bounce`, `continuous` |

### Tooltips

| Enum | Values |
|------|--------|
| `FusionTooltipActivationMode` | `auto`, `tap`, `doubleTap`, `longPress`, `hover` |
| `FusionTooltipPosition` | `floating`, `top`, `bottom` |
| `FusionDismissStrategy` | `onRelease`, `onReleaseDelayed`, `onTimer`, `manual` |
| `FusionTooltipTrackballMode` | `none`, `follow`, `snap`, `magnetic` |

### Data Labels

| Enum | Values |
|------|--------|
| `FusionDataLabelDisplay` | `all`, `max`, `min`, `maxAndMin`, `none` |

### Markers

| Enum | Values |
|------|--------|
| `MarkerShape` | `circle`, `square`, `triangle`, `diamond`, `cross`, `x` |

### Axes

| Enum | Values |
|------|--------|
| `AxisPosition` | `left`, `right`, `top`, `bottom` |
| `AxisType` | `numeric`, `category`, `dateTime` |
| `AxisLabelIntersectAction` | `hide`, `wrap`, `rotate`, `none` |
| `AxisRangePadding` | `none`, `normal`, `additional`, `round` |
| `LabelAlignment` | `start`, `center`, `end` |

### Interaction

| Enum | Values |
|------|--------|
| `InteractionAnchorMode` | `screenPosition`, `nearestDataPoint` |
| `FusionLabelAlignmentStrategy` | various label alignment modes |
| `TextAnchor` | `start`, `middle`, `end` |

---

## Live Data

### LiveViewportMode (sealed class)

Controls how the visible window behaves as data streams in.

| Factory | Key Parameters | Behavior |
|---------|---------------|----------|
| `LiveViewportMode.autoScroll(visibleDuration, {leadingPadding, trailingPadding})` | `Duration` | Scrolls to keep latest data visible within a time window |
| `LiveViewportMode.autoScrollPoints(visiblePoints, {leadingPoints})` | `int` | Scrolls to show the last N points |
| `LiveViewportMode.fixed({initialRange})` | `(double, double)?` | Static viewport; user pans/zooms manually |
| `LiveViewportMode.autoScrollUntilInteraction(visibleDuration, {interactionTimeout})` | `Duration`, `Duration?` | Auto-scrolls until user interacts, then freezes |
| `LiveViewportMode.fillThenScroll(maxDuration, {leadingPadding})` | `Duration` | Grows to fill, then scrolls |

### RetentionPolicy (sealed class)

Memory management for long-running live sessions.

| Factory | Key Parameters | Description |
|---------|---------------|-------------|
| `RetentionPolicy.rollingCount(int maxPoints)` | count | Keep last N points per series |
| `RetentionPolicy.rollingDuration(Duration duration)` | time | Keep points within a time window |
| `RetentionPolicy.unlimited()` | -- | Keep all data (use with caution) |
| `RetentionPolicy.combined(maxPoints, maxDuration)` | count + time | Evict when either limit is exceeded |
| `RetentionPolicy.downsampled(recentDuration, archiveResolution, {recentMaxPoints, maxArchivePoints, downsampleMethod})` | mixed | Full-resolution recent data + downsampled archive |

`DownsampleMethod` enum: `first`, `last`, `average`, `minMax`, `lttb`.

---

## Themes

### FusionChartTheme (abstract)

Base class defining all visual style properties. Implement this to create
custom themes.

Key properties to override:

| Property | Type | Description |
|----------|------|-------------|
| `primaryColor` | `Color` | Main chart element color |
| `secondaryColor` | `Color` | Secondary accent |
| `backgroundColor` | `Color` | Chart background |
| `gridLineColor` | `Color` | Grid lines |
| `textColor` | `Color` | Label and title text |
| `colorPalette` | `List<Color>` | Auto-assigned series colors |

### FusionLightTheme / FusionDarkTheme

Built-in implementations. `FusionLightTheme` is the default when no theme is
specified. Pass via `FusionChartConfiguration(theme: FusionDarkTheme())`.

To create a custom theme, extend or implement `FusionChartTheme` and override
all color/style getters.

---

## Utilities

### PlotBand

Highlights a rectangular region on the chart (target zones, thresholds, etc.).
Constructor takes `start`, `end` (num or DateTime), `color`, `opacity`,
optional `text`, `textStyle`, `borderColor`, `borderWidth`, and text alignment.

### FusionColorPalette

Predefined color sets for automatic series coloring.

### FusionDataFormatter

Utilities for formatting numeric values in labels and tooltips.

### FusionDateTimeUtils

Date/time helpers for time-series axis formatting.

### FusionMathematics

Math utilities used internally (nice numbers, interpolation).

### FusionResponsiveSize

Responsive sizing helpers that adapt chart elements to screen dimensions.

### LTTBDownsampler

Largest Triangle Three Buckets downsampling for rendering large datasets
without visual quality loss. Used automatically by the live data system and
available for manual use:

```dart
const downsampler = LTTBDownsampler();
final reduced = downsampler.downsample(points, targetCount: 500);
```

### ChartBoundsCalculator

Computes consistent axis bounds across all series in a chart.

### FusionChartErrorBoundary

Widget wrapper that catches rendering errors and shows a fallback UI instead
of a red error screen. Wrap any chart widget with it.

### FusionZoomControls

Overlay widget providing +/- zoom buttons. Enable via
`FusionZoomConfiguration(enableZoomControls: true)`.

---

## Version Constants

| Constant | Value |
|----------|-------|
| `fusionChartsVersion` | `'1.0.1'` |
| `fusionChartsName` | `'fusion_charts_flutter'` |
| `fusionChartsRepository` | GitHub URL |
| `fusionChartsLicense` | `'MIT'` |
| `fusionChartsAuthor` | `'Luka Pervan'` |

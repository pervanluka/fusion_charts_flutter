# Configuration Guide

This guide documents the configuration system of fusion_charts_flutter. All configuration classes are `@immutable` and support `copyWith()` for safe modification.

See also: [API Reference](api-reference.md) | [System Architecture](system-architecture.md)

---

## Configuration Hierarchy

```
FusionChartConfiguration (base)
├── FusionLineChartConfiguration
├── FusionBarChartConfiguration
├── FusionStackedBarChartConfiguration
└── FusionPieChartConfiguration
```

Each chart-type configuration inherits all fields from the base class and adds type-specific fields. Behavioral sub-configurations (tooltip, zoom, pan, crosshair, legend) are composed as fields within the base.

---

## FusionChartConfiguration (Base)

**Source:** `lib/src/configuration/fusion_chart_configuration.dart` (369 LOC)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `theme` | `FusionChartTheme` | `FusionLightTheme()` | Visual theme |
| `enableAnimation` | `bool` | `true` | Enable animations |
| `animationDuration` | `Duration?` | Theme default | Animation duration override |
| `animationCurve` | `Curve?` | Theme default | Animation curve override |
| `enableTooltip` | `bool` | `true` | Show tooltips on interaction |
| `enableCrosshair` | `bool` | `false` | Show crosshair lines |
| `enableZoom` | `bool` | `false` | Enable zoom gestures |
| `enablePanning` | `bool` | `false` | Enable pan gestures |
| `enableSelection` | `bool` | `true` | Enable data point selection |
| `enableLegend` | `bool` | `true` | Show the legend |
| `enableDataLabels` | `bool` | `false` | Show data labels |
| `enableBorder` | `bool` | `false` | Show chart border |
| `enableGrid` | `bool` | `true` | Show grid lines |
| `enableAxis` | `bool` | `true` | Show axes |
| `padding` | `EdgeInsets` | `EdgeInsets.all(4)` | Internal padding |
| `tooltipBehavior` | `FusionTooltipBehavior` | Default | Tooltip configuration |
| `crosshairBehavior` | `FusionCrosshairConfiguration` | Default | Crosshair configuration |
| `zoomBehavior` | `FusionZoomConfiguration` | Default | Zoom configuration |
| `panBehavior` | `FusionPanConfiguration` | Default | Pan configuration |
| `interactionAnchorMode` | `InteractionAnchorMode` | `screenPosition` | Interaction anchoring |

```dart
FusionLineChart(
  config: FusionLineChartConfiguration(
    theme: FusionDarkTheme(),
    enableZoom: true,
    enablePanning: true,
    zoomBehavior: FusionZoomConfiguration(
      zoomMode: FusionZoomMode.x,
      maxZoomLevel: 10.0,
    ),
    panBehavior: FusionPanConfiguration(panMode: FusionPanMode.x),
  ),
  series: [...],
)
```

---

## Chart-Type Configurations

### FusionLineChartConfiguration

Extends base with line-specific settings.

| Field | Type | Default | Constraint |
|-------|------|---------|------------|
| `lineWidth` | `double` | `2.0` | 0 - 10 |
| `enableMarkers` | `bool` | `false` | -- |
| `markerSize` | `double` | `6.0` | 0 - 20 |
| `enableAreaFill` | `bool` | `false` | -- |
| `areaFillOpacity` | `double` | `0.3` | 0.0 - 1.0 |
| `enableCurveSmoothing` | `bool` | `false` | -- |
| `curveTension` | `double` | `0.4` | 0.0 - 1.0 |

```dart
FusionLineChartConfiguration(
  lineWidth: 2.5,
  enableMarkers: true,
  enableAreaFill: true,
  areaFillOpacity: 0.2,
  enableCurveSmoothing: true,
)
```

### FusionBarChartConfiguration

Extends base with bar layout settings.

| Field | Type | Default |
|-------|------|---------|
| `enableSideBySideSeriesPlacement` | `bool` | `true` |
| `barWidthRatio` | `double` | `0.8` |
| `barSpacing` | `double` | `0.2` |
| `borderRadius` | `double` | `4.0` |

```dart
// Grouped bars
FusionBarChartConfiguration(enableSideBySideSeriesPlacement: true)

// Overlapped bars (target vs actual)
FusionBarChartConfiguration(enableSideBySideSeriesPlacement: false)
```

### FusionStackedBarChartConfiguration

Extends base for stacked bar charts. Series values stack in list order.

### FusionPieChartConfiguration

**Source:** `lib/src/configuration/fusion_pie_chart_configuration.dart` (501 LOC)

#### Layout

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `innerRadiusPercent` | `double` | `0.0` | 0.0 = solid pie, 0.5+ = donut |
| `outerRadiusPercent` | `double` | `0.85` | Outer radius fraction |
| `startAngle` | `double` | `-90.0` | Start angle in degrees |
| `direction` | `PieDirection` | `clockwise` | Drawing direction |

#### Labels

| Field | Type | Default |
|-------|------|---------|
| `labelPosition` | `PieLabelPosition` | `auto` |
| `showLabels` | `bool` | `true` |
| `showPercentages` | `bool` | `true` |
| `showValues` | `bool` | `false` |
| `percentageThreshold` | `double` | `3.0` |
| `labelConnectorLength` | `double` | `20.0` |
| `labelFormatter` | `Function?` | `null` |

#### Center (Donut)

| Field | Type | Default |
|-------|------|---------|
| `showCenterLabel` | `bool` | `false` |
| `centerLabelText` | `String?` | `null` |
| `centerSubLabelText` | `String?` | `null` |
| `centerWidget` | `Widget?` | `null` |

```dart
// Donut with center label
FusionPieChartConfiguration(
  innerRadiusPercent: 0.55,
  showCenterLabel: true,
  centerLabelText: 'Total',
  centerSubLabelText: '\$42,000',
  labelPosition: PieLabelPosition.outside,
)
```

---

## Axis Configuration

**Source:** `lib/src/configuration/fusion_axis_configuration.dart` (714 LOC)

### Core Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `axisType` | `FusionAxisBase?` | `null` | Numeric, category, or datetime |
| `min` | `num?` | Auto | Manual minimum |
| `max` | `num?` | Auto | Manual maximum |
| `interval` | `num?` | Auto | Manual tick interval |
| `title` | `String?` | `null` | Axis title |
| `labelFormatter` | `String Function(num)?` | `null` | Custom label text |
| `labelGenerator` | `Function?` | `null` | Custom label generation |
| `labelStyle` | `TextStyle?` | Theme | Label text style |
| `labelRotation` | `double?` | `null` | Label rotation degrees |
| `labelAlignment` | `LabelAlignment` | `center` | Label alignment |
| `visible` | `bool` | `true` | Show/hide axis |
| `autoRange` | `bool` | `true` | Auto-calculate min/max |
| `autoInterval` | `bool` | `true` | Auto-calculate interval |
| `includeZero` | `bool?` | `null` | Force range to include zero |
| `desiredTickCount` | `int` | `5` | Target tick count |
| `useAbbreviation` | `bool` | `true` | Abbreviate large numbers |

### Grid and Tick Fields

| Field | Type | Default |
|-------|------|---------|
| `showGrid` | `bool` | `true` |
| `showMinorGrid` | `bool` | `false` |
| `showTicks` | `bool` | `false` |
| `showMinorTicks` | `bool` | `false` |
| `showLabels` | `bool` | `true` |
| `showAxisLine` | `bool` | `true` |
| `majorGridColor` | `Color?` | Theme |
| `majorGridWidth` | `double?` | Theme |
| `minorGridColor` | `Color?` | Theme |
| `axisLineColor` | `Color?` | Theme |
| `rangePadding` | `double?` | `null` |

```dart
// Auto axis (most common)
FusionAxisConfiguration(autoRange: true, desiredTickCount: 5)

// Manual bounds
FusionAxisConfiguration(min: 0, max: 100, interval: 20)

// Currency labels
FusionAxisConfiguration(
  labelFormatter: (value) => '\$${value.toStringAsFixed(0)}',
)

// Date labels
FusionAxisConfiguration(
  labelGenerator: (value) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return '${date.month}/${date.day}';
  },
)
```

---

## Tooltip Configuration

**Source:** `lib/src/configuration/fusion_tooltip_configuration.dart` (760 LOC)

### Position and Trackball

| Field | Type | Default |
|-------|------|---------|
| `position` | `FusionTooltipPosition` | `floating` |
| `showTrackballLine` | `bool` | `true` |
| `trackballMode` | `FusionTooltipTrackballMode` | `none` |
| `trackballSnapRadius` | `double` | `20.0` |

### Activation and Dismissal

| Field | Type | Default |
|-------|------|---------|
| `activationMode` | `FusionTooltipActivationMode` | `auto` |
| `activationDelay` | `Duration` | `Duration.zero` |
| `dismissStrategy` | `FusionDismissStrategy` | `onRelease` |
| `dismissDelay` | `Duration` | `300ms` |
| `duration` | `Duration` | `3000ms` |

### Appearance

| Field | Type | Default |
|-------|------|---------|
| `shared` | `bool` | `false` |
| `elevation` | `double` | `2.5` |
| `decimalPlaces` | `int` | `2` |
| `opacity` | `double` | `0.9` |
| `color` | `Color?` | Theme |
| `textStyle` | `TextStyle?` | Theme |
| `animationDuration` | `Duration` | `200ms` |
| `animationCurve` | `Curve` | `easeOutCubic` |

### Content Customization

| Field | Type | Description |
|-------|------|-------------|
| `format` | `String Function(FusionDataPoint)?` | Custom text formatter |
| `builder` | `Widget Function(context, dataPoints)?` | Fully custom widget |

```dart
// Shared tooltip for multi-series
FusionTooltipBehavior(
  shared: true,
  activationMode: FusionTooltipActivationMode.tap,
  position: FusionTooltipPosition.top,
)

// Custom formatted tooltip
FusionTooltipBehavior(
  format: (point) => '${point.label}: \$${point.y.toStringAsFixed(2)}',
)

// Fully custom widget
FusionTooltipBehavior(
  builder: (context, dataPoints) => Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: dataPoints.map((p) =>
        Text('${p.label}: ${p.y}', style: TextStyle(color: Colors.white)),
      ).toList(),
    ),
  ),
)
```

---

## Crosshair Configuration

**Source:** `lib/src/configuration/fusion_crosshair_configuration.dart` (614 LOC)

| Field | Type | Default |
|-------|------|---------|
| `lineColor` | `Color?` | Theme |
| `lineWidth` | `double` | Theme |
| `dashArray` | `List<double>?` | `null` |
| `showLabel` | `bool` | `true` |
| `labelStyle` | `TextStyle?` | Theme |
| `activationMode` | `FusionTooltipActivationMode` | `auto` |
| `dismissStrategy` | `FusionDismissStrategy` | `onRelease` |
| `xLabelFormatter` | `FusionCrosshairLabelFormatter?` | `null` |
| `yLabelFormatter` | `FusionCrosshairLabelFormatter?` | `null` |
| `labelBuilder` | `FusionCrosshairLabelBuilder?` | `null` |

**Type aliases:**
- `FusionCrosshairLabelFormatter` = `String Function(double value, FusionDataPoint? point)`
- `FusionCrosshairLabelBuilder` = `Widget? Function(BuildContext, FusionDataPoint?, bool isXAxis)`

```dart
FusionCrosshairConfiguration(
  dashArray: [5, 3],
  xLabelFormatter: (value, point) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return '${date.hour}:${date.minute}:${date.second}';
  },
  yLabelFormatter: (value, point) => '\$${value.toStringAsFixed(2)}',
)
```

---

## Zoom Configuration

**Source:** `lib/src/configuration/fusion_zoom_configuration.dart` (268 LOC)

Zoom must be enabled with `enableZoom: true` on the base configuration.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `zoomMode` | `FusionZoomMode` | `both` | Axes to zoom (x, y, both) |
| `enablePinchZoom` | `bool` | `true` | Pinch gesture (mobile) |
| `enableMouseWheelZoom` | `bool` | `true` | Scroll wheel (desktop/web) |
| `requireModifierForWheelZoom` | `bool` | `true` | Require Ctrl/Cmd for wheel zoom |
| `enableSelectionZoom` | `bool` | `true` | Shift+drag rectangle zoom |
| `enableDoubleTapZoom` | `bool` | `true` | Double-tap to zoom |
| `minZoomLevel` | `double` | `0.5` | Min zoom (must be > 0) |
| `maxZoomLevel` | `double` | `5.0` | Max zoom (must be >= min) |
| `zoomSpeed` | `double` | `1.0` | Zoom speed multiplier |
| `enableZoomControls` | `bool` | `false` | Show on-screen zoom buttons |
| `animateZoom` | `bool` | `true` | Animate zoom transitions |
| `zoomAnimationDuration` | `Duration` | `300ms` | Zoom animation duration |
| `zoomAnimationCurve` | `Curve` | `easeInOut` | Zoom animation curve |

```dart
FusionZoomConfiguration(
  zoomMode: FusionZoomMode.x,
  maxZoomLevel: 10.0,
  requireModifierForWheelZoom: true,
  enableSelectionZoom: true,
)
```

---

## Pan Configuration

**Source:** `lib/src/configuration/fusion_pan_configuration.dart` (173 LOC)

Panning must be enabled with `enablePanning: true` on the base configuration.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `panMode` | `FusionPanMode` | `both` | Axes to pan |
| `enableInertia` | `bool` | `true` | Momentum scrolling after release |
| `inertiaDuration` | `Duration` | `500ms` | Inertia animation duration |
| `inertiaDecay` | `double` | `0.95` | Decay rate (0-1, higher = longer) |
| `edgeBehavior` | `FusionPanEdgeBehavior` | `bounce` | Edge behavior |

**Edge behaviors:** `stop` (hard stop at boundary), `bounce` (overscroll and snap back), `continuous` (wrap around).

```dart
FusionPanConfiguration(
  panMode: FusionPanMode.x,
  edgeBehavior: FusionPanEdgeBehavior.bounce,
  enableInertia: true,
)
```

---

## Legend Configuration

**Source:** `lib/src/configuration/fusion_legend_configuration.dart` (298 LOC)

| Field | Type | Default |
|-------|------|---------|
| `visible` | `bool` | `true` |
| `position` | `FusionLegendPosition` | `bottom` |
| `alignment` | `FusionLegendAlignment` | `center` |
| `orientation` | `FusionLegendOrientation` | `horizontal` |
| `itemSpacing` | `double` | `16.0` |
| `iconSize` | `double` | `16.0` |
| `iconPadding` | `double` | `8.0` |
| `textStyle` | `TextStyle?` | Theme |
| `toggleSeriesOnTap` | `bool` | `true` |
| `itemBuilder` | `Function?` | `null` |
| `scrollable` | `bool` | `false` |
| `padding` | `EdgeInsets` | `EdgeInsets.all(8.0)` |
| `margin` | `EdgeInsets` | `EdgeInsets.all(8.0)` |

```dart
FusionLegendConfiguration(
  position: FusionLegendPosition.bottom,
  orientation: FusionLegendOrientation.horizontal,
  toggleSeriesOnTap: true,
)
```

---

## Series-Level Configuration

Series objects carry their own visual settings that complement chart-level configuration.

### FusionLineSeries

| Field | Type | Default |
|-------|------|---------|
| `color` | `Color` | Required |
| `lineWidth` | `double` | `3.0` |
| `isCurved` | `bool` | `true` |
| `smoothness` | `double` | `0.35` |
| `lineDashArray` | `List<double>?` | `null` |
| `gradient` | `Gradient?` | `null` |
| `showMarkers` | `bool` | `false` |
| `markerSize` | `double` | `6.0` |
| `markerShape` | `MarkerShape` | `circle` |
| `showArea` | `bool` | `false` |
| `areaOpacity` | `double` | `0.3` |
| `showShadow` | `bool` | `true` |
| `showDataLabels` | `bool` | `false` |

```dart
FusionLineSeries(
  name: 'Revenue',
  dataPoints: dataPoints,
  color: Colors.blue,
  isCurved: true,
  smoothness: 0.4,
  showMarkers: true,
  showArea: true,
  areaOpacity: 0.15,
)
```

### FusionBarSeries

| Field | Type | Default |
|-------|------|---------|
| `color` | `Color` | Required |
| `barWidth` | `double` | `0.6` |
| `borderRadius` | `double` | `4.0` |
| `spacing` | `double` | `0.2` |
| `gradient` | `Gradient?` | `null` |
| `borderColor` | `Color?` | `null` |
| `borderWidth` | `double` | `0.0` |
| `showShadow` | `bool` | `true` |
| `showDataLabels` | `bool` | `false` |
| `dataLabelFormatter` | `Function?` | `null` |

### FusionStackedBarSeries

Shares the same fields as `FusionBarSeries`. Series stack in list order.

---

## Theme Configuration

**Source:** `lib/src/themes/fusion_chart_theme.dart`

`FusionChartTheme` is an abstract class. Two built-in themes: `FusionLightTheme` (default) and `FusionDarkTheme`.

### Theme Properties

**Colors:** `primaryColor`, `secondaryColor`, `backgroundColor`, `gridColor`, `textColor`, `borderColor`, `axisColor`, `errorColor`, `successColor`, `warningColor`

**Typography:** `titleStyle`, `axisLabelStyle`, `legendStyle`, `tooltipStyle`

**Palette:** `colorPalette` -- a `List<Color>` for automatic series color assignment.

### Custom Theme

```dart
class MyCompanyTheme implements FusionChartTheme {
  const MyCompanyTheme();

  @override
  Color get primaryColor => Color(0xFF1A73E8);
  @override
  Color get secondaryColor => Color(0xFF34A853);
  @override
  Color get backgroundColor => Colors.white;
  @override
  Color get gridColor => Colors.grey.shade200;
  @override
  Color get textColor => Colors.grey.shade800;
  @override
  Color get borderColor => Colors.grey.shade300;

  @override
  TextStyle get titleStyle => TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  @override
  TextStyle get axisLabelStyle => TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  @override
  TextStyle get legendStyle => TextStyle(fontSize: 12);
  @override
  TextStyle get tooltipStyle => TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

  @override
  List<Color> get colorPalette => [
    Color(0xFF1A73E8), Color(0xFF34A853), Color(0xFFFBBC04),
    Color(0xFFEA4335), Color(0xFF9334E6), Color(0xFF00ACC1),
  ];
  // ... implement remaining properties
}
```

---

## Live Chart Configuration

**Source:** `lib/src/live/`

### FusionLiveChartController

| Parameter | Type | Default |
|-----------|------|---------|
| `retentionPolicy` | `RetentionPolicy` | `unlimited()` |
| `frameCoalescing` | `bool` | `true` |
| `outOfOrderBehavior` | `OutOfOrderBehavior` | `acceptWithWarning` |
| `duplicateTimestampBehavior` | `DuplicateTimestampBehavior` | `replace` |

### RetentionPolicy (sealed)

| Variant | Memory |
|---------|--------|
| `RetentionPolicy.rollingCount(500)` | Fixed |
| `RetentionPolicy.rollingDuration(Duration(minutes: 5))` | Variable |
| `RetentionPolicy.unlimited()` | Unbounded |

### LiveViewportMode (sealed)

| Variant | Description |
|---------|-------------|
| `LiveViewportMode.autoScroll(visibleDuration: Duration(seconds: 60))` | Rolling time window |
| `LiveViewportMode.autoScrollPoints(visiblePoints: 100)` | Fixed point count |

```dart
final controller = FusionLiveChartController(
  retentionPolicy: RetentionPolicy.rollingCount(500),
);

websocket.onMessage((data) {
  controller.addPoint('price', FusionDataPoint(now, data.price));
});

// Stream binding
controller.bindStream(
  'heartRate',
  bleDevice.heartRateStream,
  mapper: (hr) => FusionDataPoint(
    DateTime.now().millisecondsSinceEpoch.toDouble(),
    hr.bpm.toDouble(),
  ),
);
```

---

## Common Patterns

### Immutable Modification

```dart
final baseConfig = FusionLineChartConfiguration(enableAnimation: true);
final darkConfig = baseConfig.copyWith(theme: FusionDarkTheme());
```

### Zoom + Pan for Time Series

```dart
FusionLineChartConfiguration(
  enableZoom: true,
  enablePanning: true,
  zoomBehavior: FusionZoomConfiguration(zoomMode: FusionZoomMode.x, maxZoomLevel: 10.0),
  panBehavior: FusionPanConfiguration(panMode: FusionPanMode.x, edgeBehavior: FusionPanEdgeBehavior.bounce),
)
```

### Tooltip + Crosshair

```dart
FusionLineChartConfiguration(
  enableTooltip: true,
  enableCrosshair: true,
  tooltipBehavior: FusionTooltipBehavior(shared: true),
  crosshairBehavior: FusionCrosshairConfiguration(
    dashArray: [5, 3],
    xLabelFormatter: (value, point) => formatDate(value),
  ),
)
```

### Minimal Configuration

```dart
// All defaults: light theme, animation, tooltip enabled
FusionLineChart(
  series: [FusionLineSeries(name: 'Data', dataPoints: myData, color: Colors.blue)],
)
```

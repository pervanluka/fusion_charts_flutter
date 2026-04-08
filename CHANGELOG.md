# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-04-09

### Added

#### Reference Line Annotations
- **`FusionReferenceLine`** — Customizable horizontal reference lines for marking specific Y-axis values (e.g., current price, target price, stop loss)
  - Dashed or solid lines with configurable color, width, and dash pattern
  - Label badge with background color, border radius, padding, and text styling
  - `FusionLabelPosition` — Label placement: `left`, `right`, `topLeft`, `topRight`
  - `showDot` — Dot marker on the last data point matching the annotation value (avoids duplicates)
  - Dot automatically skips rendering when it would overlap the label badge
  - `FusionAnnotationOverlapStrategy` — Overlap resolution with data labels: `annotationWins`, `dataLabelWins`, `offset`, `showBoth`
  - Labels render above series and data labels (zIndex 75), lines render behind series (zIndex 25)
  - Annotation added via `FusionChartConfiguration.annotations` list — works on all chart types

#### Edge Label Placement
- **`EdgeLabelPlacement`** — Controls how first/last X-axis labels handle overflow at chart boundaries
  - `none` — Labels at exact position, margin expands to fit (default, backward compatible)
  - `shift` — Edge labels shift inward to stay within chart area, no extra margin
  - `hide` — Edge labels that would overflow are hidden
- Added to `FusionAxisConfiguration.edgeLabelPlacement` with `copyWith` support

#### Annotation Showcase

```dart
FusionLineChart(
  series: [
    FusionLineSeries(
      dataPoints: data,
      color: Colors.green,
      showArea: true,
      gradient: LinearGradient(
        colors: [Colors.green, Colors.green.withValues(alpha: 0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      showDataLabels: true,
      dataLabelDisplay: FusionDataLabelDisplay.maxAndMin,
    ),
  ],
  config: FusionChartConfiguration(
    padding: EdgeInsets.zero,
    annotations: [
      FusionReferenceLine(
        value: 9642.24,
        label: '9,642.24 €',
        lineColor: Colors.grey,
        lineDashPattern: [4, 4],
        labelPosition: FusionLabelPosition.left,
        labelBackgroundColor: Colors.black87,
        labelStyle: TextStyle(color: Colors.white, fontSize: 11),
        showDot: true,
        dotColor: Colors.black87,
      ),
    ],
  ),
  xAxis: FusionAxisConfiguration(
    edgeLabelPlacement: EdgeLabelPlacement.shift,
  ),
)
```

### Fixed
- **Gradient overriding alpha values** — When a gradient is explicitly provided on `FusionLineSeries`, its color alpha values are now used as-is. `areaOpacity` only applies to the solid color fallback (no gradient)
- **Gradient bleeding into line stroke** — Gradient shader is no longer applied to the line stroke paint, keeping the line at full solid color
- **Tooltip marker dot overlapping data labels** — Tooltip marker is suppressed when the active series has a data label at the hovered point (respects all `FusionDataLabelDisplay` modes)
- **Tooltip allSeries not passed** — Both line and bar chart painters now pass series list to `FusionTooltipLayer`, enabling data label overlap detection
- **Hidden axis still reserving margin** — `FusionMarginCalculator` now respects `visible: false` on both X and Y axes, eliminating gap where axis was
- **Animation sync for overlays** — Reference lines, label badges, dots, and data labels all fade in with `animationProgress` instead of appearing instantly before the series animates

### Stability
- Added `mounted` guard to all `setState()` calls across chart widgets (line, bar, stacked bar, pie, base state)
- Added bounds check in stacked bar hit tester for category label access
- Added empty categories guard in category axis renderer grid drawing
- Added zero-length/zero-dashSum guard in crosshair dashed line painting
- Fixed axis calculator assertion from `>0` to `>=0` for minor ticks count

### Tests
- 20 unit tests for `FusionReferenceLine` (construction, assertions, copyWith, effective colors, equality)
- 12 unit tests for annotation config integration across all chart configuration types
- All 2,950+ existing unit tests continue to pass

---

## [1.1.1] - 2026-03-27

### Fixed
- **SingleTickerProviderStateMixin crash** — All chart states (`FusionLineChart`, `FusionBarChart`, `FusionStackedBarChart`, `FusionPieChart`, `FusionChartBaseState`) now use `TickerProviderStateMixin` instead of `SingleTickerProviderStateMixin`. This fixes the "multiple tickers were created" assertion that occurred when charts rebuilt with new data (e.g., switching date ranges or granularity), which triggered `didUpdateWidget` to reinitialize animation controllers.

## [1.0.0] - 2026-01-01

### Added

#### Chart Types
- **FusionLineChart** — Line chart with straight or smooth curved lines (Bezier/Catmull-Rom splines)
- **FusionBarChart** — Bar chart for categorical data comparison
- **FusionStackedBarChart** — Stacked bar chart for cumulative data visualization
- **FusionPieChart** — Pie and Donut charts with smart labels, selection, and center content

#### Series Features
- `FusionLineSeries` — Line series with configurable width, curves, dash patterns
- `FusionBarSeries` — Bar series with customizable bar width, spacing, and border radius
- `FusionStackedBarSeries` — Stacked bar series for cumulative visualization
- `FusionPieSeries` — Pie series with customizable colors, strokes, and corner radius
- `FusionAreaSeries` — Area fill support with gradient backgrounds
- Series visibility toggling
- Gradient support (linear gradients)
- Shadow/glow effects
- Data labels with custom formatters
- Marker shapes (circle, square, triangle, diamond, pentagon, hexagon)

#### Theming System
- `FusionChartTheme` — Abstract theme interface
- `FusionLightTheme` — Professional light color scheme (default)
- `FusionDarkTheme` — Dark mode theme
- Full customization: colors, typography, dimensions, animations, shadows
- WCAG 2.1 AA compliant contrast ratios

#### Configuration
- `FusionChartConfiguration` — Central configuration with builder pattern
- `FusionAxisConfiguration` — Axis customization (min, max, intervals, labels)
- `FusionTooltipConfiguration` — Tooltip behavior and styling
- `FusionCrosshairConfiguration` — Crosshair appearance and dismiss strategies
- `FusionZoomConfiguration` — Zoom limits and behavior
- `FusionLegendConfiguration` — Legend positioning and styling

#### Interactions
- Touch/tap detection with nearest point finding
- Long-press for crosshair activation
- Hover support (desktop)
- Pinch-to-zoom
- Pan/drag navigation
- Trackball modes: none, follow, snap, magnetic
- Haptic feedback integration
- Configurable dismiss strategies (onRelease, afterDuration, never)

#### Axis System
- Numeric axis with auto-scaling
- DateTime axis with intelligent interval selection
- Category axis support
- Custom label formatters
- Axis bounds calculation with nice numbers algorithm
- Multiple range padding strategies

#### Performance Optimizations
- `FusionPaintPool` — Object pooling for Paint instances (90% GC reduction)
- `FusionShaderCache` — Gradient shader caching
- `FusionRenderCache` — General render cache
- `FusionRenderOptimizer` — Dirty region tracking and path caching
- `LTTBDownsampler` — Largest Triangle Three Buckets algorithm for 10K+ points
- Coordinate system caching with hash-based invalidation
- Pixel snapping for crisp rendering on high-DPI displays

#### Data Handling
- `FusionDataPoint` — Immutable data point with x, y, label, metadata
- `DataValidator` — Validates and cleans data (NaN, Infinity, duplicates)
- Data statistics calculation (min, max, mean, range)
- Range clamping support
- Automatic sorting by X coordinate

#### Rendering Engine
- `FusionCoordinateSystem` — Immutable coordinate transforms with pixel snapping
- `FusionPathBuilder` — Smooth path generation (Bezier, Catmull-Rom, Douglas-Peucker)
- `FusionChartPainterBase` — Template method pattern for painters
- Dashed line support with custom patterns
- Area fill with baseline

#### Utilities
- `FusionColorPalette` — 6 color palettes (Material, Professional, Vibrant, Pastel, Warm, Cool)
- `FusionDataFormatter` — Number and date formatting utilities
- `FusionMathematics` — Spline calculations, interpolation
- `FusionResponsiveSize` — Responsive sizing helpers

#### Documentation
- Comprehensive dartdoc comments
- Example application with 20+ demos
- README with quick start guide

### Notes

- Minimum Flutter SDK: 3.22.0
- Minimum Dart SDK: 3.9.0
- Dependencies: `intl` for formatting

---

## [1.1.0] - 2026-02-19

### Added

#### Live Chart Streaming
- **`FusionLiveChartController`** — Real-time data streaming with automatic viewport management
  - `addDataPoint()` / `addDataPoints()` for streaming data
  - `pause()` / `resume()` for stream control
  - Configurable viewport modes: `sliding`, `expanding`, `fixed`
  - Auto-scroll with configurable window duration
- **LTTB Downsampling** — Largest Triangle Three Buckets algorithm for `DownsampledPolicy`
  - Archive storage for older data combined with recent full-resolution points
  - Maintains visual fidelity while reducing point count
- **Live Tooltip Probe Mode** — Real-time data tracking at fixed screen position
  - `updateLiveTooltip()` method for proper tooltip updates during streaming
- **`FusionLiveChartMixin`** — Reusable mixin for live streaming functionality

#### Crosshair Enhancements
- `FusionCrosshairLabelFormatter` — Custom axis label formatting callback
- `FusionCrosshairLabelBuilder` — Custom label widget builder
- `InteractionAnchorMode` — Persistent crosshair anchoring modes

#### Performance Optimizations
- Batch grid line and tick rendering using Path (reduces N drawLine calls to 1 drawPath)
- Cache `TextPainter` instances and label sizes in axis renderers
- Binary search for nearest point lookup (O(log n) vs O(n))
- Quick sorted-data detection to choose optimal search algorithm

#### Comprehensive Test Suite
- Added 54 new test files covering all major components
- Total test count: **3,626 tests**
- Test coverage increased from ~60% to **75.86%** (8,864/11,685 lines)
- Full coverage for axis renderers, tooltip system, data labels, interactive states
- Extensive tests for DST handling, render pipeline, chart themes, error boundaries

#### Examples
- New `live_chart_showcase.dart` — Comprehensive example with live streaming demonstrations

### Changed
- Removed deprecated `enabled` field from `FusionZoomConfiguration` (use `FusionChartConfiguration.enableZoom`)
- Removed deprecated `enabled` field from `FusionPanConfiguration` (use `FusionChartConfiguration.enablePanning`)
- Migrated deprecated `Color.value` to `Color.toARGB32()` throughout codebase
- Replaced unnecessary lambdas with method tearoffs for better performance
- Updated `withOpacity` calls to `withValues(alpha:)` for Flutter 3.22+ compatibility

### Fixed
- Fixed multi-series live chart tooltip incorrectly switching to first series when mouse stops moving
- Fixed dual timer inconsistency in `hideTooltip()` causing stale callbacks
- Added disposal protection to prevent "disposed EngineFlutterView" errors
- Resolved all lint warnings for clean static analysis

### Quality
- **Pana Score**: 160/160 (perfect score)
- **Static Analysis**: 0 issues
- All tests passing

---

## [1.0.1] - 2026-01-13

### Added

#### Programmatic Control API
- `FusionChartController` — Full programmatic control over zoom and pan operations
  - `zoomIn()`, `zoomOut()`, `zoomToFit()`, `resetZoom()` methods
  - `panTo()`, `panBy()` for programmatic panning
  - `setZoomLevel()` with animation support
  - Event streams for zoom/pan state changes
  - Attach/detach to any interactive chart

#### New Widgets
- `FusionZoomControls` — Ready-to-use zoom control widget with customizable buttons
- `FusionScrollInterceptWrapper` — Desktop scroll wheel zoom support with proper event handling

#### New Utilities
- `FusionDesktopHelper` — Platform detection utilities for desktop-specific behaviors
- `FusionZoomAnimationMixin` — Smooth animated zoom transitions with configurable curves
- `FusionSelectionRectLayer` — Box selection rendering for zoom-to-region functionality

#### Axis Configuration
- `labelGenerator` callback in `FusionAxisConfiguration` for complete control over axis label positioning
  - Receives axis bounds, available size, and orientation
  - Returns list of values where labels should appear
  - Supports use cases like:
    - Edge-inclusive labels (always show min/max)
    - Percentage-based labels (0%, 25%, 50%, 75%, 100%)
    - Powers of 10 (log-scale style)
    - Fibonacci sequence positioning
    - Custom business thresholds
    - DateTime patterns (first of month, every Monday)
    - Density-based responsive labels

#### Examples
- New `zoom_pan_showcase.dart` — Comprehensive example with 27 zoom/pan demonstrations

### Changed
- `enableCrosshair` default changed from `true` to `false` for cleaner out-of-box experience
  - Charts now render without crosshair by default
  - Explicitly set `enableCrosshair: true` to enable

### Fixed
- Fixed zoom and pan gestures being interrupted mid-interaction due to gesture recognizer recreation
- Fixed gesture recognizer caching not being populated in `FusionInteractiveChartState`
- Added gesture recognizer caching to `FusionBarInteractiveState` and `FusionStackedBarInteractiveState`
- Fixed unnecessary widget rebuilds during pan/zoom start that killed in-progress gestures
- Fixed `FusionInteractionHandler` being recreated during active gestures, which reset `_lastScale` and broke incremental pinch-zoom calculations
- **Fixed zoom state being reset on widget rebuild** — coordinate system updates during active gestures now preserve zoomed data bounds while only updating screen dimensions
- Fixed timer cleanup in multi-touch interaction tests

### Deprecated
The following fields are ignored and will be removed in v2.0.0. Use the top-level configuration flags instead:

- `FusionZoomConfiguration.enabled` → Use `FusionChartConfiguration.enableZoom`
- `FusionPanConfiguration.enabled` → Use `FusionChartConfiguration.enablePanning`
- `FusionTooltipBehavior.enable` → Use `FusionChartConfiguration.enableTooltip`
- `FusionCrosshairConfiguration.enabled` → Use `FusionChartConfiguration.enableCrosshair`

---

## [Unreleased]

### Planned
- Scatter charts
- Bubble charts
- Candlestick/OHLC charts
- Radar/Spider charts
- Gauge charts
- Funnel charts
- Multiple Y-axes
- Plot bands
- Export to image (PNG, SVG)
- Accessibility improvements (Semantics)

---

## Version History

| Version | Date       | Description                                                      |
|---------|------------|------------------------------------------------------------------|
| 1.2.0   | 2026-04-09 | Reference line annotations, edge label placement, gradient fixes |
| 1.1.1   | 2026-03-27 | SingleTickerProviderStateMixin crash fix                         |
| 1.1.0   | 2026-02-19 | Live chart streaming, LTTB downsampling, 75.86% test coverage    |
| 1.0.1   | 2026-01-13 | Programmatic control API, labelGenerator, zoom/pan fixes, deprecations |
| 1.0.0   | 2026-01-01 | Initial release                                                  |

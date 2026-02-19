# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Annotations and plot bands
- Export to image (PNG, SVG)
- Accessibility improvements (Semantics)

---

## Version History

| Version | Date       | Description                                                      |
|---------|------------|------------------------------------------------------------------|
| 1.1.0   | 2026-02-19 | Live chart streaming, LTTB downsampling, 75.86% test coverage    |
| 1.0.1   | 2026-01-13 | Programmatic control API, labelGenerator, zoom/pan fixes, deprecations |
| 1.0.0   | 2026-01-01 | Initial release                                                  |

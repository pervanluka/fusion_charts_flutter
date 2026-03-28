# Changelog

All notable changes to the **fusion_charts_flutter** project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

## [1.1.1] - 2026-03-27

### Fixed

- **SingleTickerProviderStateMixin crash** -- All chart states (`FusionLineChart`, `FusionBarChart`, `FusionStackedBarChart`, `FusionPieChart`, `FusionChartBaseState`) now use `TickerProviderStateMixin` instead of `SingleTickerProviderStateMixin`. This fixes the "multiple tickers were created" assertion that occurred when charts rebuilt with new data (e.g., switching date ranges or granularity), which triggered `didUpdateWidget` to reinitialize animation controllers.

**Commits:**

- `b09fb02` fix: use TickerProviderStateMixin to prevent multiple ticker crash
- `c3e530b` fix: use TickerProviderStateMixin for multiple animation controllers

---

## [1.1.0] - 2026-02-19

### Added

#### Live Chart Streaming

- **`FusionLiveChartController`** -- Real-time data streaming with automatic viewport management
  - `addDataPoint()` / `addDataPoints()` for streaming data
  - `pause()` / `resume()` for stream control
  - Configurable viewport modes: `sliding`, `expanding`, `fixed`
  - Auto-scroll with configurable window duration
- **LTTB Downsampling** -- Largest Triangle Three Buckets algorithm for `DownsampledPolicy`
  - Archive storage for older data combined with recent full-resolution points
  - Maintains visual fidelity while reducing point count
- **`RingBuffer`** -- Efficient circular data storage for high-frequency streaming
- **`FrameCoalescer`** -- Batches updates at 60fps to prevent unnecessary rebuilds
- **`RetentionPolicy`** -- Memory management via `maxDataPoints` and `maxDuration`
- **`LiveViewportMode`** -- Auto-scroll by duration or point count (`autoScrollDuration`, `autoScrollPoints`)
- **Live Tooltip Probe Mode** -- Real-time data tracking at fixed screen position
  - `updateLiveTooltip()` method for proper tooltip updates during streaming
- **`FusionLiveChartMixin`** -- Reusable mixin for live streaming functionality
- Out-of-order and duplicate timestamp handling

#### Crosshair Enhancements

- `FusionCrosshairLabelFormatter` -- Custom axis label formatting callback
- `FusionCrosshairLabelBuilder` -- Custom label widget builder
- `InteractionAnchorMode` -- Persistent crosshair anchoring modes

#### Performance Optimizations

- Batch grid line and tick rendering using `Path` (reduces N `drawLine` calls to 1 `drawPath`)
- Cache `TextPainter` instances and label sizes in axis renderers
- Binary search for nearest point lookup (O(log n) vs O(n))
- Quick sorted-data detection to choose optimal search algorithm

#### Comprehensive Test Suite

- Added 54 new test files covering all major components
- Full coverage for axis renderers, tooltip system, data labels, interactive states
- Extensive tests for DST handling, render pipeline, chart themes, error boundaries

#### Examples

- New `live_chart_showcase.dart` -- Comprehensive example with live streaming demonstrations

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

### Quality Metrics

| Metric           | Value                    |
|------------------|--------------------------|
| Pana Score       | 160/160                  |
| Static Analysis  | 0 issues                 |
| Test Coverage    | 75.86% (8,864/11,685)   |
| Total Tests      | 3,626                    |

**Commits:**

- `513b809` feat(v1.1.0): Live chart streaming with LTTB downsampling
- `a7a28a5` docs(v1.1.0): Update documentation for live chart streaming release
- `5686cb1` ref(code-format): Formatted codebase
- `31aff9f` test(coverage): Comprehensive unit test suite achieving 75.86% coverage
- `b320fea` fix(tooltip): Multi-series live chart tooltip selecting correct series
- `9d52690` ref: Format code for improved readability and consistency
- `c4fedc1` feat(v1.1.0): Live chart enhancements with LTTB downsampling and performance optimizations
- `9a7a0ac` feat(example): Add comprehensive live chart showcase
- `509eb70` feat(live-stream): Add widget integration and LTTB downsampling (Phase 3)
- `3ed1592` feat(live-stream): Add core infrastructure for live streaming (Phase 1)
- `b22d856` Refactor color contrast handling and implement bar chart interaction state

---

## [1.0.1] - 2026-01-13

### Added

#### Programmatic Control API

- **`FusionChartController`** -- Full programmatic control over zoom and pan operations
  - `zoomIn()`, `zoomOut()`, `zoomToFit()`, `resetZoom()` methods
  - `panTo()`, `panBy()` for programmatic panning
  - `setZoomLevel()` with animation support
  - Event streams for zoom/pan state changes
  - Attach/detach to any interactive chart

#### New Widgets

- `FusionZoomControls` -- Ready-to-use zoom control widget with customizable buttons
- `FusionScrollInterceptWrapper` -- Desktop scroll wheel zoom support with proper event handling

#### New Utilities

- `FusionDesktopHelper` -- Platform detection utilities for desktop-specific behaviors
- `FusionZoomAnimationMixin` -- Smooth animated zoom transitions with configurable curves
- `FusionSelectionRectLayer` -- Box selection rendering for zoom-to-region functionality

#### Axis Configuration

- `labelGenerator` callback in `FusionAxisConfiguration` for complete control over axis label positioning
  - Receives axis bounds, available size, and orientation
  - Returns list of values where labels should appear
  - Supports use cases such as edge-inclusive labels, percentage-based labels, powers of 10, Fibonacci positioning, custom business thresholds, DateTime patterns, and density-based responsive labels

#### Examples

- New `zoom_pan_showcase.dart` -- Comprehensive example with 27 zoom/pan demonstrations

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
- Fixed zoom state being reset on widget rebuild -- coordinate system updates during active gestures now preserve zoomed data bounds while only updating screen dimensions
- Fixed timer cleanup in multi-touch interaction tests

### Deprecated

The following fields are ignored and will be removed in v2.0.0. Use the top-level configuration flags instead:

- `FusionZoomConfiguration.enabled` -- use `FusionChartConfiguration.enableZoom`
- `FusionPanConfiguration.enabled` -- use `FusionChartConfiguration.enablePanning`
- `FusionTooltipBehavior.enable` -- use `FusionChartConfiguration.enableTooltip`
- `FusionCrosshairConfiguration.enabled` -- use `FusionChartConfiguration.enableCrosshair`

**Commits:**

- `d460efd` feat(v1.0.1): Major zoom/pan improvements with programmatic control API
- `4bb223c` On dev: zoom/pan bugfix
- `de0f28d` feat: Implement custom label generation feature for axes; add showcase examples
- `d21db11` ref: Format code for pub.dev
- `c466f73` ref: Format code for pub.dev
- `7396ee1` Refactor test cases and remove unused golden test images
- `66c6b84` docs: Update README for clarity and enhance project description
- `57626a9` fix: Update linter rules for mutable classes and return types
- `65dd255` Refactor and optimize code across multiple files
- `6e2e767` Add comprehensive performance and unit tests for Fusion Charts
- `874be68` chore: Update changelog date and version, remove deprecated methods

---

## [1.0.0] - 2026-01-01

### Added

#### Chart Types

- **FusionLineChart** -- Line chart with straight or smooth curved lines (Bezier/Catmull-Rom splines)
- **FusionBarChart** -- Bar chart for categorical data comparison
- **FusionStackedBarChart** -- Stacked bar chart for cumulative data visualization
- **FusionPieChart** -- Pie and Donut charts with smart labels, selection, and center content
- **FusionAreaSeries** -- Area fill support with gradient backgrounds

#### Series Features

- `FusionLineSeries` -- Line series with configurable width, curves, dash patterns
- `FusionBarSeries` -- Bar series with customizable bar width, spacing, and border radius
- `FusionStackedBarSeries` -- Stacked bar series for cumulative visualization
- `FusionPieSeries` -- Pie series with customizable colors, strokes, and corner radius
- Series visibility toggling
- Gradient support (linear gradients)
- Shadow/glow effects
- Data labels with custom formatters
- Marker shapes: circle, square, triangle, diamond, pentagon, hexagon

#### Axis System

- Numeric axis with auto-scaling and nice numbers algorithm
- DateTime axis with intelligent interval selection
- Category axis support
- Custom label formatters
- Multiple range padding strategies
- Axis position configuration (top, bottom, left, right)

#### Theming System

- `FusionChartTheme` -- Abstract theme interface
- `FusionLightTheme` -- Professional light color scheme (default)
- `FusionDarkTheme` -- Dark mode theme
- Full customization: colors, typography, dimensions, animations, shadows
- WCAG 2.1 AA compliant contrast ratios
- 6 color palettes: Material, Professional, Vibrant, Pastel, Warm, Cool

#### Configuration

- `FusionChartConfiguration` -- Central configuration with builder pattern
- `FusionAxisConfiguration` -- Axis customization (min, max, intervals, labels)
- `FusionTooltipConfiguration` -- Tooltip behavior and styling
- `FusionCrosshairConfiguration` -- Crosshair appearance and dismiss strategies
- `FusionZoomConfiguration` -- Zoom limits and behavior
- `FusionLegendConfiguration` -- Legend positioning and styling

#### Interactions

- Touch/tap detection with nearest point finding
- Long-press for crosshair activation
- Hover support (desktop)
- Pinch-to-zoom
- Pan/drag navigation
- Trackball modes: none, follow, snap, magnetic
- Haptic feedback integration
- Configurable dismiss strategies: onRelease, afterDuration, never

#### Performance Optimizations

- `FusionPaintPool` -- Object pooling for Paint instances (90% GC reduction)
- `FusionShaderCache` -- Gradient shader caching
- `FusionRenderCache` -- General render cache
- `FusionRenderOptimizer` -- Dirty region tracking and path caching
- `LTTBDownsampler` -- Largest Triangle Three Buckets algorithm for 10K+ points
- Coordinate system caching with hash-based invalidation
- Pixel snapping for crisp rendering on high-DPI displays

#### Data Handling

- `FusionDataPoint` -- Immutable data point with x, y, label, metadata
- `DataValidator` -- Validates and cleans data (NaN, Infinity, duplicates)
- Data statistics calculation (min, max, mean, range)
- Range clamping support
- Automatic sorting by X coordinate

#### Rendering Engine

- `FusionCoordinateSystem` -- Immutable coordinate transforms with pixel snapping
- `FusionPathBuilder` -- Smooth path generation (Bezier, Catmull-Rom, Douglas-Peucker)
- `FusionChartPainterBase` -- Template method pattern for painters
- Dashed line support with custom patterns
- Area fill with baseline
- Plot bands

#### Utilities

- `FusionColorPalette` -- 6 color palettes
- `FusionDataFormatter` -- Number and date formatting utilities
- `FusionMathematics` -- Spline calculations, interpolation
- `FusionResponsiveSize` -- Responsive sizing helpers
- `FusionPolarMath` -- Polar coordinate math for pie/donut charts
- Error boundary widget for graceful error handling

#### Documentation

- Comprehensive dartdoc comments
- Example application with 20+ demos
- README with quick start guide

### Notes

- Minimum Flutter SDK: 3.22.0
- Minimum Dart SDK: 3.9.0
- Dependencies: `intl` for formatting

### Earlier Commits (pre-1.0.0)

The following commits contributed to the initial release:

- `099de78` Major refactor
- `a621c53` feat: Implement centralized chart bounds calculator for consistent axis bounds
- `736ee53` feat: Update chart padding to improve layout consistency across themes
- `5d97b71` Add screenshots for charts
- `c2552c1` feat: Add border rendering option for charts and update configurations
- `b421c39` Add comprehensive widget tests for FusionPieChart
- `e35d597` Add unit tests for FusionPathBuilder functionality
- `e371610` feat: Enhance tooltip text handling for empty series names
- `3513c74` fix: Disable ticks display on the chart axis configuration
- `14ff1a3` feat: Add FusionPolarMath and FusionPieSeries for advanced pie/donut chart rendering
- `d786842` Refactor chart components and enhance tooltip functionality
- `1508714` feat: Add theme support for tooltips and data labels
- `1372c8b` feat: Enhance tooltip and data label functionalities
- `2b92738` feat: Add methods to find nearest data points by X and Y coordinates
- `6c1ae10` ref: bar chart implementation for improved margin calculations
- `f4791e9` Add unit tests for FusionCoordinateSystem and LTTBDownsampler
- `b1963f1` feat: Implement dispose method in render pipeline and prevent memory leaks
- `ad62326` feat: Add axis type configuration and auto-detection
- `4014e9b` feat: Improve tooltip positioning logic and enhance chart area margins
- `2717332` feat: Enhance tooltip functionality in FusionTooltipLayer
- `133bfcc` refactor: Chart configuration classes and add specific configurations
- `f129839` feat: Implement stacked bar chart rendering and tooltip functionality
- `d19904d` feat: Update dependencies and enhance crosshair and tooltip configurations
- `ff9c993` Enhance tooltip behavior and configuration
- `aaf016a` Add axis position configuration and implement position-aware rendering
- `4f8fa6d` Add axis definitions to render context
- `95dc38a` Fix CustomPaint size in FusionBarChart
- `72ab829` Refactor FusionBarChart and FusionLineChart imports
- `baffc48` Initial commit

---

## Version History

| Version | Date       | Description                                                                  |
|---------|------------|------------------------------------------------------------------------------|
| 1.1.1   | 2026-03-27 | TickerProviderStateMixin fix for multiple animation controller crash          |
| 1.1.0   | 2026-02-19 | Live chart streaming, LTTB downsampling, 75.86% test coverage (3,626 tests)  |
| 1.0.1   | 2026-01-13 | Programmatic control API, labelGenerator, zoom/pan fixes, deprecations       |
| 1.0.0   | 2026-01-01 | Initial release with 5 chart types, theming, interactions, performance       |

---

[Unreleased]: https://github.com/user/fusion_charts_flutter/compare/v1.1.1...HEAD
[1.1.1]: https://github.com/user/fusion_charts_flutter/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/user/fusion_charts_flutter/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/user/fusion_charts_flutter/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/user/fusion_charts_flutter/releases/tag/v1.0.0

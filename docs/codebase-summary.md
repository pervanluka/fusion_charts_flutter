# Codebase Summary

> **fusion_charts_flutter v1.1.1** -- Professional Flutter charting library with line, bar, pie/donut charts, smooth animations, tooltips, zoom/pan, and high performance.

**Related documentation:** [System Architecture](system-architecture.md) | [Code Standards](code-standards.md)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Directory Structure](#directory-structure)
4. [Module Breakdown](#module-breakdown)
   - [Charts](#charts)
   - [Configuration](#configuration)
   - [Controllers](#controllers)
   - [Core](#core)
   - [Data Models](#data-models)
   - [Series](#series)
   - [Rendering](#rendering)
   - [Themes](#themes)
   - [Live Streaming](#live-streaming)
   - [Utilities](#utilities)
   - [Widgets](#widgets)
5. [Public API Surface](#public-api-surface)
6. [Dependencies](#dependencies)
7. [Test Suite](#test-suite)
8. [Key Metrics](#key-metrics)
9. [Largest Files](#largest-files)
10. [Cross-Cutting Concerns](#cross-cutting-concerns)

---

## Project Overview

fusion_charts_flutter is a pure-Dart Flutter charting library published on pub.dev. It provides four chart families -- line/area, bar, stacked bar, and pie/donut -- with a unified configuration system, theme support, interactive gestures (zoom, pan, crosshair, tooltips), and real-time live data streaming with LTTB downsampling.

**Repository:** <https://github.com/pervanluka/fusion_charts_flutter>

**Key characteristics:**

- Zero native dependencies -- pure Dart/Flutter
- SOLID architecture with abstract base classes, mixins, and composition
- Multi-layer rendering pipeline (background, grid, series, markers, labels, overlays)
- ~45,200 lines of library code across 149 files
- ~57,300 lines of test code across 80 files
- SDK constraints: Dart ^3.9.0, Flutter >=3.22.0

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Language | Dart 3.9+ |
| Framework | Flutter 3.22+ |
| Rendering | Flutter `Canvas` / `CustomPainter` |
| State management | `StatefulWidget` + `ChangeNotifier` |
| Animations | Flutter `AnimationController` / `TickerProviderStateMixin` |
| Internationalization | `intl` package (date/number formatting) |
| Testing | `flutter_test` (unit, widget, golden, integration) |
| Quality | `flutter_lints`, `pana` |

---

## Directory Structure

```
lib/ (~45,205 LOC, 149 files)
|-- fusion_charts_flutter.dart          Main barrel file (333 LOC, 50+ exports)
|-- src/
    |-- charts/                         Chart widgets and state management
    |   |-- base/                       Abstract base classes and shared state
    |   |-- mixins/                     Reusable chart functionality (live, zoom)
    |   |-- pie/                        Pie/donut chart family (869 LOC)
    |   |-- fusion_line_chart.dart      Line/area chart widget (623 LOC)
    |   |-- fusion_bar_chart.dart       Bar chart widget (729 LOC)
    |   |-- fusion_stacked_bar_chart.dart  Stacked bar widget (560 LOC)
    |   |-- fusion_interactive_chart.dart  Shared interactive chart logic (1,412 LOC)
    |
    |-- configuration/                  12 configuration classes (~4,599 LOC)
    |-- controllers/                    FusionChartController (130 LOC)
    |
    |-- core/                           Foundation layer
    |   |-- axis/                       Axis system (2,526 LOC)
    |   |   |-- base/                   Abstract axis base
    |   |   |-- numeric/               Continuous numeric axis
    |   |   |-- category/              Discrete category axis
    |   |   |-- datetime/              Time-series axis with smart formatting
    |   |   |-- fusion_axis_renderer_factory.dart
    |   |-- enums/                     18 enum files (zoom modes, tooltip modes, etc.)
    |   |-- features/                  Plot bands
    |   |-- models/                    Axis bounds, axis labels, grid/tick config
    |   |-- styling/                   Axis line and tick styling
    |   |-- constants/                 Shared constants
    |   |-- validation/                Data validation (518 LOC)
    |
    |-- data/                          Data models
    |   |-- fusion_data_point.dart     Core data point (x, y)
    |   |-- fusion_pie_data_point.dart Pie-specific data point
    |   |-- fusion_bar_chart_data.dart Bar chart data
    |   |-- fusion_line_chart_data.dart Line chart data
    |
    |-- series/                        6 series types (~2,211 LOC)
    |   |-- fusion_series.dart         Abstract base series
    |   |-- series_with_data_points.dart Interface
    |   |-- fusion_line_series.dart
    |   |-- fusion_area_series.dart
    |   |-- fusion_bar_series.dart
    |   |-- fusion_stacked_bar_series.dart
    |   |-- fusion_pie_series.dart
    |
    |-- rendering/                     Rendering engine (~12,600 LOC)
    |   |-- engine/                    Pipeline, context, optimizer, caching
    |   |-- layers/                    12 render layers (series, tooltip, crosshair, etc.)
    |   |-- painters/                  Chart-specific CustomPainters
    |   |-- polar/                     Polar coordinate math for pie/donut
    |   |-- layout/                    Chart layout manager
    |   |-- interaction/               Spatial index for hit testing
    |   |-- animation/                 Animation orchestrator
    |
    |-- themes/                        Light and dark themes (984 LOC)
    |-- live/                          Real-time streaming subsystem (2,822 LOC)
    |-- utils/                         Math, formatting, layout utilities (7,334 LOC)
    |-- type/                          FusionGradient type (322 LOC)
    |-- widgets/                       Overlay widgets (zoom controls, error boundary)

test/ (~57,339 LOC, 80 files)
|-- unit/                              66 files -- core logic testing
|-- widget_tests/                      5 files -- chart widget rendering
|-- golden_tests/                      1 file -- visual regression
|-- interaction_tests/                 1 file -- gesture handling
|-- live/                              4 files -- real-time streaming
|-- performance_tests/                 1 file -- stress testing
|-- edge_case_tests.dart               Boundary conditions
```

---

## Module Breakdown

### Charts

**Path:** `lib/src/charts/`

The charts module contains the user-facing widget classes and their associated state objects.

#### Base classes (`charts/base/`)

| File | Purpose |
|------|---------|
| `fusion_chart_base.dart` | Abstract `StatefulWidget` base parameterized by series type `<S>`. Defines the common widget interface: series, config, axes, title, callbacks. |
| `fusion_chart_base_state.dart` | Shared state lifecycle (init, dispose, didUpdateWidget). |
| `fusion_interactive_state_base.dart` | Base interactive state with gesture handling. |
| `fusion_cartesian_interactive_state_base.dart` | Cartesian-specific interactive state (956 LOC). Manages zoom/pan transforms, crosshair, tooltip positioning for X/Y axis charts. |
| `fusion_bar_interactive_state_base.dart` | Bar-chart-specific interactive state. |
| `fusion_data_bounds.dart` | Data bounds calculation helpers. |
| `fusion_chart_header.dart` | Title/subtitle header widget. |

#### Mixins (`charts/mixins/`)

| File | Purpose |
|------|---------|
| `fusion_live_chart_mixin.dart` | Adds real-time data streaming support to any chart widget state. |
| `fusion_zoom_animation_mixin.dart` | Smooth animated zoom transitions. |

#### Chart widgets

| Widget | File | LOC | Description |
|--------|------|-----|-------------|
| `FusionLineChart` | `fusion_line_chart.dart` | 623 | Line and area charts with smooth curves, gradient fills, markers. |
| `FusionBarChart` | `fusion_bar_chart.dart` | 729 | Vertical/horizontal bar charts with rounded corners. |
| `FusionStackedBarChart` | `fusion_stacked_bar_chart.dart` | 560 | Stacked and 100% stacked bar charts. |
| `FusionPieChart` | `pie/fusion_pie_chart.dart` | 869 | Pie and donut charts with center labels, explosion. |
| `FusionInteractiveChart` | `fusion_interactive_chart.dart` | 1,412 | Shared interactive chart shell with `GestureDetector`, zoom controls, legend, tooltip overlay. Used internally by line, bar, and stacked bar charts. |

**Inheritance hierarchy:**

```
StatefulWidget
  +-- FusionChartBase<S>        (abstract, parameterized by series type)
       +-- FusionLineChart
       +-- FusionBarChart
       +-- FusionStackedBarChart
       +-- FusionPieChart
```

For more on the widget architecture, see [System Architecture](system-architecture.md).

---

### Configuration

**Path:** `lib/src/configuration/` (~4,599 LOC, 12 files)

All chart behavior is controlled through immutable configuration objects. Each chart type has its own configuration class that extends or composes the base configuration.

| Configuration Class | File | Purpose |
|---------------------|------|---------|
| `FusionChartConfiguration` | `fusion_chart_configuration.dart` | Master configuration: animation, zoom, pan, tooltip, crosshair, legend enables. |
| `FusionAxisConfiguration` | `fusion_axis_configuration.dart` | Axis appearance: labels, grid lines, tick marks, range padding, custom label generators (714 LOC). |
| `FusionLineChartConfiguration` | `fusion_line_chart_configuration.dart` | Line-specific: curve smoothing, area fill, markers, data labels. |
| `FusionBarChartConfiguration` | `fusion_bar_chart_configuration.dart` | Bar-specific: corner radius, spacing, orientation. |
| `FusionStackedBarChartConfiguration` | `fusion_stacked_bar_chart_configuration.dart` | Stacked bar: 100% mode, segment spacing. |
| `FusionPieChartConfiguration` | `fusion_pie_chart_configuration.dart` | Pie/donut: inner radius, start angle, explosion, center text. |
| `FusionTooltipConfiguration` | `fusion_tooltip_configuration.dart` | Tooltip styling, positioning, activation modes, trackball, dismiss strategy (760 LOC). |
| `FusionCrosshairConfiguration` | `fusion_crosshair_configuration.dart` | Crosshair line style, snap behavior. |
| `FusionZoomConfiguration` | `fusion_zoom_configuration.dart` | Zoom limits, modes (horizontal, vertical, both), selection rect. |
| `FusionPanConfiguration` | `fusion_pan_configuration.dart` | Pan modes, edge behavior (stop, bounce, continuous). |
| `FusionLegendConfiguration` | `fusion_legend_configuration.dart` | Legend position, styling, toggle behavior. |
| `FusionStackedTooltipBuilder` | `fusion_stacked_tooltip_builder.dart` | Custom tooltip builder typedef for stacked charts. |

---

### Controllers

**Path:** `lib/src/controllers/` (130 LOC)

| Class | Purpose |
|-------|---------|
| `FusionChartController` | Programmatic chart control: `zoomIn()`, `zoomOut()`, `resetZoom()`, `panTo()`, `zoomToRange()`. Exposed to users for toolbar integration and external control. |

See also [FusionLiveChartController](#live-streaming) for real-time data control.

---

### Core

**Path:** `lib/src/core/`

The foundation layer providing axis systems, enumerations, models, and validation.

#### Axis system (`core/axis/`, 2,526 LOC)

Three axis types with a factory for runtime selection:

| Axis | Path | Description |
|------|------|-------------|
| `FusionNumericAxis` | `numeric/` | Continuous numerical data with smart interval calculation. |
| `FusionCategoryAxis` | `category/` | Discrete labels (e.g., months, product names). |
| `FusionDateTimeAxis` | `datetime/` | Time-series data with intelligent date formatting (721 LOC renderer). |
| `FusionAxisBase` | `base/` | Abstract base defining the axis contract. |
| `FusionAxisRendererFactory` | `fusion_axis_renderer_factory.dart` | Creates the correct axis renderer based on axis type enum. |

#### Enumerations (`core/enums/`, 18 files)

Fine-grained enums controlling every aspect of chart behavior:

- **Axis:** `AxisPosition`, `AxisType`, `AxisRangePadding`, `AxisLabelIntersectAction`
- **Zoom/Pan:** `FusionZoomMode`, `FusionPanMode`, `FusionPanEdgeBehavior`
- **Tooltip:** `FusionTooltipActivationMode`, `FusionTooltipPosition`, `FusionTooltipTrackballMode`, `FusionDismissStrategy`
- **Labels:** `FusionDataLabelDisplay`, `FusionLabelAlignmentStrategy`, `LabelAlignment`, `TextAnchor`
- **Visual:** `MarkerShape`, `ChartRangePadding`, `InteractionAnchorMode`

#### Models (`core/models/`)

- `AxisBounds` -- calculated min/max/interval for an axis
- `AxisLabel` -- positioned label with text and metadata
- `MinorGridLines`, `MinorTickLines` -- sub-division configuration

#### Features (`core/features/`)

- `PlotBand` -- horizontal/vertical highlighted regions on the chart area

#### Validation (`core/validation/`, 518 LOC)

- `DataValidator` -- validates series data, configuration consistency, axis compatibility. Reports warnings for common misconfigurations.

---

### Data Models

**Path:** `lib/src/data/`

| Class | File | Description |
|-------|------|-------------|
| `FusionDataPoint` | `fusion_data_point.dart` | Core data point with `x` (num) and `y` (num) values. Used by line, bar, and stacked bar charts. Also supports optional metadata. |
| `FusionPieDataPoint` | `fusion_pie_data_point.dart` | Pie-specific: value, label, color, explode flag. |
| `FusionBarChartData` | `fusion_bar_chart_data.dart` | Bar chart data container. |
| `FusionLineChartData` | `fusion_line_chart_data.dart` | Line chart data container. |

---

### Series

**Path:** `lib/src/series/` (~2,211 LOC, 7 files)

Series objects define what data to render and how. Each chart type has a matching series class.

| Series | Description |
|--------|-------------|
| `FusionSeries` | Abstract base -- name, color, visibility. |
| `SeriesWithDataPoints` | Interface adding `dataPoints` list access. |
| `FusionLineSeries` | Line series with color, width, dash pattern, marker config. |
| `FusionAreaSeries` | Area series (extends line with gradient fill below the curve). |
| `FusionBarSeries` | Bar series with color, border, corner radius overrides. |
| `FusionStackedBarSeries` | Stacked bar segment within a stack group. |
| `FusionPieSeries` | Pie series wrapping a list of `FusionPieDataPoint`. |

---

### Rendering

**Path:** `lib/src/rendering/` (~12,600 LOC)

The largest module. Implements a composable multi-layer rendering pipeline built on Flutter's `CustomPainter`.

For the full rendering architecture, see [System Architecture](system-architecture.md).

#### Engine (`rendering/engine/`)

| File | Purpose |
|------|---------|
| `fusion_render_pipeline.dart` | Orchestrates layer rendering in sequence: background -> grid -> series -> markers -> labels -> axes -> overlays. Supports profiling. |
| `fusion_render_context.dart` | Shared context passed to all layers (canvas, size, theme, data bounds, transforms). |
| `fusion_render_optimizer.dart` | Frame-level optimizations (dirty checking, skip unchanged layers). |
| `fusion_clipping_manager.dart` | Manages clip regions for chart plot area. |
| `fusion_paint_pool.dart` | Reusable `Paint` object pool to reduce GC pressure. |
| `fusion_shader_cache.dart` | Caches gradient shaders across frames. |

#### Layers (`rendering/layers/`, 12 files)

Each layer is a self-contained rendering unit implementing `FusionRenderLayer` (884 LOC base):

| Layer | LOC | Purpose |
|-------|-----|---------|
| `FusionSeriesLayer` | -- | Renders line paths, area fills. |
| `FusionBarSeriesRenderer` | 760 | Bar rectangle rendering with rounded corners. |
| `FusionStackedBarSeriesRenderer` | -- | Stacked bar segment rendering. |
| `FusionTooltipLayer` | 1,100 | Tooltip bubble rendering, positioning, animation. |
| `FusionStackedTooltipLayer` | -- | Multi-segment tooltip for stacked charts. |
| `FusionPieTooltipLayer` | -- | Tooltip layer for pie/donut charts. |
| `FusionCrosshairLayer` | -- | Vertical/horizontal crosshair lines. |
| `FusionDataLabelLayer` | 696 | Data labels above/below points with collision avoidance. |
| `FusionMarkerLayer` | -- | Data point markers (circle, square, diamond, triangle, etc.). |
| `FusionLegendLayer` | -- | Legend rendering and hit testing. |
| `FusionSelectionRectLayer` | -- | Zoom selection rectangle overlay. |

#### Painters (`rendering/painters/`)

Chart-type-specific `CustomPainter` implementations that compose the render pipeline:

- `FusionLineChartPainter`
- `FusionBarChartPainter`
- `FusionStackedBarChartPainter`

Pie chart uses its own painter at `charts/pie/fusion_pie_chart_painter.dart`.

#### Polar math (`rendering/polar/`)

- `FusionPolarMath` (755 LOC) -- Cartesian-to-polar coordinate transforms, arc calculations, label positioning for pie/donut charts.
- `FusionPieSegment` -- Computed pie segment geometry (start angle, sweep angle, center point).

#### Interaction (`rendering/interaction/`)

- `FusionSpatialIndex` -- Spatial indexing for efficient hit testing on data points and chart elements.

#### Layout (`rendering/layout/`)

- `ChartLayoutManager` / `ChartLayout` -- Calculates plot area bounds after accounting for axes, title, legend, and padding.

#### Animation (`rendering/animation/`)

- `FusionAnimationOrchestrator` -- Coordinates entry animations, transition animations, and hover effects across layers.

#### Other rendering files

| File | Purpose |
|------|---------|
| `fusion_coordinate_system.dart` | Data-space to pixel-space coordinate transforms with zoom/pan support. |
| `fusion_chart_painter_base.dart` | Abstract base for all chart painters. |
| `fusion_path_builder.dart` | Bezier curve path construction for smooth lines. |
| `fusion_render_cache.dart` | Caches computed paths and layout between frames. |
| `fusion_bar_hit_tester.dart` | Bar-specific tap/hover hit testing. |
| `fusion_stacked_bar_hit_tester.dart` | Stacked bar hit testing. |
| `fusion_tooltip_renderer.dart` | Low-level tooltip drawing primitives. |
| `fusion_interaction_handler.dart` | Gesture-to-chart-action translation. |

---

### Themes

**Path:** `lib/src/themes/` (984 LOC, 3 files)

| Class | Description |
|-------|-------------|
| `FusionChartTheme` | Abstract theme interface defining all color/style properties. |
| `FusionLightTheme` | Light theme (default). White backgrounds, dark text. |
| `FusionDarkTheme` | Dark theme. Dark backgrounds, light text. |

Themes control: background colors, grid line colors, axis label styles, tooltip styling, legend text styles, series color palettes, and crosshair colors. Custom themes can be created by implementing `FusionChartTheme`.

---

### Live Streaming

**Path:** `lib/src/live/` (2,822 LOC, 10 files)

Real-time data streaming subsystem added in v1.1.0. Enables charts to display live-updating data from WebSockets, BLE devices, sensors, or any `Stream<T>`.

| File | LOC | Purpose |
|------|-----|---------|
| `fusion_live_chart_controller.dart` | 979 | Central controller: data buffering, stream binding, retention, frame coalescing. Extends `ChangeNotifier`. |
| `ring_buffer.dart` | -- | Fixed-capacity circular buffer for efficient data storage. |
| `frame_coalescer.dart` | -- | Batches rapid data updates to cap repaints at 60fps. |
| `retention_policy.dart` | -- | Data retention: `unlimited`, `rollingCount(n)`, `rollingDuration(d)`. |
| `lttb_downsampler.dart` (in utils) | -- | Largest-Triangle-Three-Buckets downsampling for large datasets. |
| `downsampling.dart` | -- | Downsampling configuration and integration. |
| `live_controller_statistics.dart` | -- | Runtime statistics (points/sec, buffer size, dropped points). |
| `live_viewport_mode.dart` | -- | Viewport tracking modes (follow latest, fixed window). |
| `out_of_order_behavior.dart` | -- | Enum: accept, reject, or warn on out-of-order data. |
| `duplicate_timestamp_behavior.dart` | -- | Enum: replace, ignore, or error on duplicate x-values. |
| `live.dart` | -- | Barrel export file. |

**Key features:**

- `addPoint()` / `addPoints()` for push-based data
- `bindStream()` for reactive stream binding with mapper function
- Configurable retention policies to bound memory usage
- Frame coalescing to prevent excessive repaints
- LTTB downsampling for rendering thousands of points efficiently
- Statistics tracking for debugging and monitoring

---

### Utilities

**Path:** `lib/src/utils/` (7,334 LOC, 13 files)

| File | LOC | Purpose |
|------|-----|---------|
| `fusion_axis_alignment.dart` | 732 | Axis label positioning, rotation, and collision detection. |
| `fusion_mathematics.dart` | -- | Nice number calculation, interpolation, rounding for axis intervals. |
| `fusion_data_formatter.dart` | -- | Number and date formatting for labels and tooltips. Uses `intl`. |
| `fusion_datetime_utils.dart` | -- | DateTime interval calculation, range detection, smart tick placement. |
| `fusion_responsive_size.dart` | -- | Responsive sizing based on chart dimensions. |
| `fusion_color_palette.dart` | -- | Default color sequences for multi-series charts. |
| `fusion_margin_calculator.dart` | -- | Auto-margin calculation based on label sizes. |
| `fusion_performance.dart` | -- | Performance profiling utilities. |
| `fusion_desktop_helper.dart` | -- | Desktop-specific input handling (mouse wheel zoom, hover). |
| `chart_bounds_calculator.dart` | -- | Consistent axis bounds across chart types. |
| `axis_calculator.dart` | -- | Axis range and interval algorithms. |
| `lttb_downsampler.dart` | -- | Largest-Triangle-Three-Buckets algorithm for visual downsampling. |
| `list_data_source.dart` | -- | List-backed data source abstraction. |

---

### Widgets

**Path:** `lib/src/widgets/`

| Widget | File | Purpose |
|--------|------|---------|
| `FusionZoomControls` | `fusion_zoom_controls.dart` | Floating +/- button overlay for zoom interaction. |
| `FusionScrollInterceptWrapper` | `fusion_scroll_intercept_wrapper.dart` | Intercepts scroll events to prevent parent `ScrollView` interference during chart pan/zoom. |
| `FusionChartErrorBoundary` | `error/fusion_chart_error_boundary.dart` | Catches rendering errors and displays a fallback widget instead of crashing. |

---

## Public API Surface

The library exports 50+ symbols through `lib/fusion_charts_flutter.dart`. The barrel file also re-exports select Flutter `material.dart` symbols (`Color`, `Colors`, `TextStyle`, `Offset`, `Rect`, `Curves`, etc.) for user convenience.

**Exported categories:**

| Category | Count | Examples |
|----------|-------|---------|
| Chart widgets | 4 | `FusionLineChart`, `FusionBarChart`, `FusionStackedBarChart`, `FusionPieChart` |
| Configuration | 12 | `FusionChartConfiguration`, `FusionTooltipConfiguration`, etc. |
| Series | 7 | `FusionLineSeries`, `FusionBarSeries`, `FusionPieSeries`, etc. |
| Data models | 4 | `FusionDataPoint`, `FusionPieDataPoint`, etc. |
| Axis types | 4 | `FusionNumericAxis`, `FusionCategoryAxis`, `FusionDateTimeAxis`, `FusionAxisBase` |
| Enums | 18 | `FusionZoomMode`, `MarkerShape`, `AxisPosition`, etc. |
| Themes | 3 | `FusionChartTheme`, `FusionLightTheme`, `FusionDarkTheme` |
| Controllers | 1 | `FusionChartController` |
| Utilities | 7 | `FusionMathematics`, `FusionColorPalette`, `LttbDownsampler`, etc. |
| Widgets | 2 | `FusionZoomControls`, `FusionChartErrorBoundary` |
| Rendering | 3 | `FusionCoordinateSystem`, `FusionPolarMath`, `FusionPieSegment` |
| Core models | 5 | `AxisBounds`, `AxisLabel`, `PlotBand`, `MinorGridLines`, `MinorTickLines` |

---

## Dependencies

### Runtime Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Framework |
| `intl` | ^0.20.2 | Date and number formatting (i18n) |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing framework |
| `flutter_lints` | ^6.0.0 | Linting rules |
| `pana` | ^0.23.3 | pub.dev quality analysis |

### Environment Constraints

| Constraint | Value |
|------------|-------|
| Dart SDK | ^3.9.0 |
| Flutter SDK | >=3.22.0 |

The library has a minimal dependency footprint by design -- only `intl` is required at runtime beyond the Flutter SDK itself.

---

## Test Suite

**Path:** `test/` (~57,339 LOC, 80 files)

Test-to-code ratio: **1.27:1** (57,339 test LOC / 45,205 library LOC)

### Test categories

| Category | Path | Files | Description |
|----------|------|-------|-------------|
| Unit tests | `test/unit/` | 66 | Core logic: axis calculation, coordinate transforms, data validation, formatting, math utilities, configuration, series, rendering layers, layout. |
| Widget tests | `test/widget_tests/` | 5 | Chart widget rendering, lifecycle, rebuild behavior. |
| Golden tests | `test/golden_tests/` | 1 | Visual regression -- pixel-level comparison of rendered charts against approved baselines. |
| Interaction tests | `test/interaction_tests/` | 1 | Gesture handling: tap, drag, pinch-zoom, hover, long-press. |
| Live streaming tests | `test/live/` | 4 | `FusionLiveChartController`, ring buffer, frame coalescing, retention policies. |
| Performance tests | `test/performance_tests/` | 1 | Stress testing with large datasets (10K+ points). |
| Edge case tests | `test/edge_case_tests.dart` | 1 | Boundary conditions: empty data, single point, NaN/Infinity, extreme zoom. |

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Library LOC | ~45,205 |
| Library files | 149 |
| Test LOC | ~57,339 |
| Test files | 80 |
| Test:code ratio | 1.27:1 |
| Public exports | 50+ |
| Chart types | 4 (line/area, bar, stacked bar, pie/donut) |
| Axis types | 3 (numeric, category, datetime) |
| Configuration classes | 12 |
| Enum types | 18 |
| Series types | 6 (+ 1 interface) |
| Render layers | 12 |
| Theme implementations | 2 (light, dark) |
| Runtime dependencies | 1 (`intl`) |
| Largest module | Rendering (~12,600 LOC) |

---

## Largest Files

The 15 largest files by lines of code, indicating areas of highest complexity:

| Rank | File | LOC | Module |
|------|------|-----|--------|
| 1 | `fusion_interactive_chart.dart` | 1,412 | charts |
| 2 | `fusion_tooltip_layer.dart` | 1,100 | rendering/layers |
| 3 | `fusion_live_chart_controller.dart` | 979 | live |
| 4 | `fusion_cartesian_interactive_state_base.dart` | 956 | charts/base |
| 5 | `fusion_render_layer.dart` | 884 | rendering/layers |
| 6 | `fusion_pie_chart.dart` | 869 | charts/pie |
| 7 | `fusion_pie_interactive_state.dart` | 801 | charts/pie |
| 8 | `fusion_bar_series_renderer.dart` | 760 | rendering/layers |
| 9 | `fusion_tooltip_configuration.dart` | 760 | configuration |
| 10 | `fusion_polar_math.dart` | 755 | rendering/polar |
| 11 | `fusion_axis_alignment.dart` | 732 | utils |
| 12 | `fusion_bar_chart.dart` | 729 | charts |
| 13 | `fusion_datetime_axis_renderer.dart` | 721 | core/axis |
| 14 | `fusion_axis_configuration.dart` | 714 | configuration |
| 15 | `fusion_data_label_layer.dart` | 696 | rendering/layers |

**Observations:**

- Interaction handling (items 1, 4, 7) accounts for significant complexity -- zoom, pan, crosshair, and tooltip coordination.
- Tooltip rendering (items 2, 9) is complex due to positioning logic, multi-series support, and animation.
- The rendering layer base class (item 5) carries substantial logic for the composable layer system.
- Polar math (item 10) reflects the geometric complexity of pie/donut chart layout.

---

## Cross-Cutting Concerns

### Error handling

- `FusionChartErrorBoundary` widget catches rendering exceptions and displays fallback UI.
- `DataValidator` validates input data and configuration before rendering begins.
- The live controller handles out-of-order and duplicate data gracefully via configurable behaviors.

### Performance

- `FusionRenderOptimizer` skips unchanged layers via dirty checking.
- `FusionPaintPool` and `FusionShaderCache` reduce garbage collection pressure.
- `FusionRenderCache` caches computed paths between frames.
- LTTB downsampling enables rendering of datasets with thousands of points.
- Frame coalescing in the live controller caps repaints at 60fps.
- `FusionSpatialIndex` enables O(log n) hit testing instead of linear scan.

### Responsiveness

- `FusionResponsiveSize` adapts font sizes, margins, and marker sizes to chart dimensions.
- `FusionMarginCalculator` auto-calculates margins based on actual label measurements.
- `FusionScrollInterceptWrapper` prevents scroll conflicts in scrollable parent containers.

### Extensibility

- Abstract base classes (`FusionChartBase`, `FusionAxisBase`, `FusionRenderLayer`, `FusionChartTheme`) enable extension.
- Configuration objects are immutable with `copyWith` support for safe composition.
- Custom label generators allow user-defined axis label formatting.
- The render pipeline accepts arbitrary layer lists for custom rendering.

For architectural details and design patterns, see [System Architecture](system-architecture.md).
For naming conventions and code style guidelines, see [Code Standards](code-standards.md).

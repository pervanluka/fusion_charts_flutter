# Project Overview and Decision Record

> **fusion_charts_flutter** v1.1.1 | Author: Luka Pervan | License: MIT
> Published on [pub.dev](https://pub.dev/packages/fusion_charts_flutter)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Project Decision Record](#project-decision-record)
3. [Goals and Non-Goals](#goals-and-non-goals)
4. [Key Metrics](#key-metrics)
5. [Technology Choices](#technology-choices)
6. [Cross-References](#cross-references)

---

## Project Overview

### What

fusion_charts_flutter is a professional-grade charting library for Flutter that provides
five chart types (Line, Area, Bar, Stacked Bar, Pie/Donut), three axis types (Numeric,
Category, DateTime), and a real-time live streaming pipeline with LTTB downsampling. It
ships as a single pub.dev package with one runtime dependency (`intl ^0.20.2`) and targets
Dart 3.9+ / Flutter 3.22+.

The library delivers interactive features out of the box -- tooltips, crosshair, zoom/pan,
animated transitions, data labels, markers, gradients, plot bands, legends, and theming
(light/dark) -- all driven through a declarative configuration API and optionally controlled
programmatically via `FusionChartController`.

### Why

Flutter's ecosystem has charting options, but most fall into one of two traps: either they
are toy-level demos that break past a few hundred points, or they are heavy ports of web
charting libraries that fight Flutter's rendering model. fusion_charts_flutter was built
from scratch on top of `CustomPainter` to work *with* Flutter's rendering pipeline, not
against it. The design goals are:

- Render 10,000+ data points at 60 fps without jank.
- Stay fully declarative so charts compose naturally inside widget trees.
- Keep the dependency footprint minimal -- one runtime dependency, zero native code.
- Provide real-time live streaming as a first-class feature, not an afterthought.

### Who

The primary audience is Flutter application developers who need production-quality data
visualisation without pulling in a framework that doubles their app size. Secondary
audiences include:

- Dashboard and analytics app developers needing live-updating charts.
- Teams that need a charting library they can theme to match their design system.
- Developers who value a small dependency graph and verifiable pub.dev scores.

---

## Project Decision Record

This section records the key architectural decisions made during the development of
fusion_charts_flutter, the reasoning behind each, and the trade-offs accepted.

### PDR-1: Layered Rendering Pipeline

**Context:** Charts are composed of many visual concerns -- axes, grid lines, series data,
markers, data labels, tooltips, crosshair overlays, legends, selection rectangles. Mixing
all of these into a single paint method leads to an unmaintainable monolith where draw
order bugs, hit-testing collisions, and feature additions become increasingly painful.

**Decision:** Adopt a layered rendering architecture where each visual concern is
implemented as a discrete render layer (see `lib/src/rendering/layers/`). Each layer
implements a common `FusionRenderLayer` interface and is composited in a defined z-order
by the chart painter. Layers include:

| Layer | Responsibility |
|---|---|
| `FusionSeriesLayer` | Paints line, area, and pie series geometry |
| `FusionBarSeriesRenderer` | Paints bar chart rectangles |
| `FusionStackedBarSeriesRenderer` | Paints stacked bar segments |
| `FusionMarkerLayer` | Draws data point markers |
| `FusionDataLabelLayer` | Positions and renders data labels |
| `FusionCrosshairLayer` | Draws crosshair lines and value indicators |
| `FusionTooltipLayer` | Renders tooltip popups for Cartesian charts |
| `FusionPieTooltipLayer` | Renders tooltip popups for pie/donut charts |
| `FusionStackedTooltipLayer` | Renders tooltips for stacked series |
| `FusionLegendLayer` | Draws the chart legend |
| `FusionSelectionRectLayer` | Renders zoom selection rectangles |

**Consequences:**
- Each layer can be developed, tested, and optimised in isolation.
- Z-order is explicit and easy to reason about.
- Adding a new visual feature means adding a new layer, not modifying existing paint code.
- Slight overhead from iterating the layer list on each frame, but negligible compared to
  the actual paint cost.

**Status:** Adopted. Stable since v1.0.0.

---

### PDR-2: CustomPainter-Based Rendering

**Context:** Flutter offers several ways to draw custom graphics: `CustomPainter`,
`RenderObject`, `Canvas` via `drawImage`, or even external rendering engines. The choice
affects performance, compositing behaviour, hit testing, and maintenance cost.

**Decision:** Use `CustomPainter` as the primary rendering mechanism for all chart types.
The chart widget tree contains a `CustomPaint` widget whose painter holds the full render
pipeline. Interaction (tap, pan, zoom) is handled by wrapping the `CustomPaint` in gesture
detectors and forwarding events to an interaction handler
(`FusionInteractionHandler`).

**Rationale:**
- `CustomPainter` is the idiomatic Flutter approach for complex 2D drawing.
- It integrates naturally with the framework's repaint boundary and compositing system.
- `shouldRepaint` gives fine-grained control over when repaints occur.
- No platform channels, no web views, no foreign rendering engines -- the library stays
  pure Dart/Flutter.

**Alternatives considered:**
- **RenderObject subclass:** More control over layout and hit testing, but significantly
  more boilerplate and harder for contributors to understand. The hit-testing needs of a
  chart (find nearest data point, detect bar taps) are better served by spatial lookup in
  the coordinate system than by the RenderObject hit-test tree.
- **External engines (Skia direct, Impeller shaders):** Would couple the library to
  engine internals and break cross-platform guarantees.

**Consequences:**
- All rendering is pure Dart -- easy to debug, profile, and test.
- Chart painters must be careful to cache paint objects and avoid allocations in the paint
  method for 60 fps performance.
- Hit testing is manual (via `FusionBarHitTester`, `FusionStackedBarHitTester`, and
  coordinate-based nearest-point lookup) rather than automatic.

**Status:** Adopted. Foundational -- unlikely to change.

---

### PDR-3: Series Polymorphism

**Context:** The library supports five visually distinct chart types. Each has different
data shapes (Cartesian vs polar), different rendering logic, and different interaction
behaviour. A naive approach would be a large switch/case or if/else tree in the painter.

**Decision:** Model each chart type as a polymorphic series class extending `FusionSeries`:

- `FusionLineSeries` -- Cartesian line chart
- `FusionAreaSeries` -- Cartesian area chart (extends line series concepts)
- `FusionBarSeries` -- Cartesian vertical bar chart
- `FusionStackedBarSeries` -- Cartesian stacked bar chart
- `FusionPieSeries` -- Polar pie/donut chart

Each series type carries its own configuration (colours, styles, data) and knows how to
provide data to the rendering layers. The render layers query series properties through the
common `FusionSeries` interface and through the `SeriesWithDataPoints` mixin where data
point access is needed.

**Rationale:**
- Follows the Open/Closed Principle: new chart types can be added by creating a new series
  subclass without modifying existing code.
- Keeps chart-type-specific logic co-located with the series definition.
- Enables mixed-type charts in the future (e.g., line + bar on the same axes) because the
  renderer iterates a list of polymorphic series.

**Consequences:**
- Series classes must conform to the interface contract, which constrains their shape.
- Some rendering layers (bar renderer, stacked bar renderer) are specialised to a single
  series type, creating a parallel hierarchy. This is an accepted trade-off for rendering
  performance and clarity.

**Status:** Adopted. Stable since v1.0.0.

---

### PDR-4: Immutable Coordinate System

**Context:** The chart must translate between three coordinate spaces: data space (the
user's numeric/datetime/category values), normalised space (0.0-1.0 within the plot area),
and pixel space (canvas coordinates). Mutable coordinate transforms are a common source of
bugs -- especially when zoom, pan, and animation are involved.

**Decision:** Implement the coordinate system (`FusionCoordinateSystem`) as an immutable
value object. When zoom level or pan offset changes, a new coordinate system instance is
created rather than mutating the existing one. The coordinate system is computed during the
layout phase and passed as a read-only dependency to all render layers.

**Rationale:**
- Eliminates an entire class of bugs where one layer reads stale transform state written
  by another layer.
- Makes it trivial to snapshot the coordinate system for animation interpolation.
- Simplifies testing -- coordinate transforms are pure functions with no hidden state.
- Aligns with Flutter's overall preference for immutable widget and configuration objects.

**Alternatives considered:**
- **Mutable transform matrix:** Fewer allocations but high risk of order-dependent bugs
  when multiple layers read and write the same transform in a single frame.

**Consequences:**
- A new coordinate system object is allocated on each layout pass. In practice this is a
  lightweight value object and GC pressure is negligible.
- All downstream consumers (layers, hit testers) receive a consistent, frozen view of the
  coordinate space for the current frame.

**Status:** Adopted. Stable since v1.0.0.

---

### PDR-5: Ring Buffer for Live Data

**Context:** The live streaming feature must ingest data points continuously -- potentially
hundreds per second from financial feeds, IoT sensors, or real-time metrics. A naive list
append grows unboundedly, eventually exhausting memory and causing GC pauses that drop
frames.

**Decision:** Use a ring buffer (`RingBuffer`, defined in `lib/src/live/ring_buffer.dart`)
as the backing store for live chart data. The ring buffer has a fixed capacity set by the
retention policy. When new points arrive and the buffer is full, the oldest points are
silently overwritten. The buffer provides O(1) append and O(1) indexed read.

**Rationale:**
- Fixed memory footprint regardless of how long the stream runs.
- O(1) insertion with no allocations after initial setup.
- No GC pauses from growing/shrinking lists.
- Natural fit for time-series "sliding window" visualisation.

**Supporting mechanisms:**
- `RetentionPolicy` configures the buffer capacity.
- `FrameCoalescer` batches incoming points so the chart repaints at most once per
  animation frame, not once per data point.
- `DuplicateTimestampBehavior` and `OutOfOrderBehavior` handle messy real-world data
  streams.
- `LiveViewportMode` controls whether the viewport auto-scrolls with new data or stays
  fixed.

**Consequences:**
- Historical data beyond the retention window is lost. This is by design -- the live chart
  is a real-time monitor, not a historical archive.
- The fixed capacity must be tuned by the consumer. Too small and data is lost too quickly;
  too large and rendering of the full buffer becomes the bottleneck.

**Status:** Adopted in v1.1.0.

---

### PDR-6: LTTB Downsampling

**Context:** When a live chart accumulates thousands of points but the display is only a
few hundred pixels wide, rendering every point is wasteful. Worse, it causes visual
aliasing and tooltip confusion. Downsampling is necessary, but the algorithm choice matters
-- naive approaches (every Nth point, random sampling) distort the visual shape of the data.

**Decision:** Use the Largest-Triangle-Three-Buckets (LTTB) algorithm for downsampling
(implemented in `lib/src/live/downsampling.dart`). LTTB divides the data into buckets and
selects the point in each bucket that forms the largest triangle with the selected points
in adjacent buckets, preserving the visual shape of the data.

**Rationale:**
- LTTB is specifically designed for time-series visualisation downsampling. It was
  introduced by Sveinn Steinarsson in his 2013 MSc thesis and has become the de facto
  standard in data visualisation tools.
- It preserves peaks, valleys, and overall trend shape far better than uniform sampling.
- It runs in O(n) time with O(1) extra space -- no sorting, no tree structures.
- The output point count matches the pixel width, so every rendered point maps to a
  distinct visual position.

**Alternatives considered:**
- **Every Nth point:** Fast but obliterates peaks and valleys.
- **Min-max per bucket:** Preserves extremes but doubles the output size and creates
  artificial zigzag patterns.
- **Douglas-Peucker:** Good shape preservation but O(n log n) and designed for line
  simplification, not time-series buckets.
- **M4 aggregation:** Good for bar-like aggregation but not ideal for line/area series.

**Consequences:**
- LTTB assumes monotonically increasing x-values (timestamps). Non-monotonic data must be
  handled before reaching the downsampler (see `OutOfOrderBehavior`).
- The algorithm slightly shifts point positions within buckets, so exact original
  coordinates are not guaranteed in the downsampled output. For visualisation purposes this
  is imperceptible.

**Status:** Adopted in v1.1.0.

---

## Goals and Non-Goals

### Goals

1. **Production-ready charting for Flutter.** Provide chart types, interactions, and
   performance characteristics that meet the needs of real-world production applications,
   not just demos.

2. **60 fps at scale.** Render 10,000+ data points without dropping frames on mid-range
   devices. Use caching, efficient data structures, and minimal allocations in the render
   path.

3. **Declarative, composable API.** Charts are configured through immutable configuration
   objects and compose naturally inside Flutter widget trees. No imperative "chart.addPoint()"
   mutations -- except through the explicit `FusionChartController` for programmatic control
   and `FusionLiveChartController` for streaming.

4. **Minimal dependencies.** Ship with the smallest possible dependency footprint. The only
   runtime dependency is `intl` for number and date formatting. No native code, no platform
   channels, no web views.

5. **Full pub.dev compliance.** Maintain a perfect pana score (160/160), complete API
   documentation, and adherence to Dart analysis rules.

6. **Live streaming as a first-class feature.** Support real-time data ingestion with
   bounded memory, automatic downsampling, and configurable viewport behaviour.

7. **Theming and customisation.** Support light and dark themes out of the box, with full
   control over colours, fonts, stroke widths, gradients, and visual properties through
   configuration objects.

8. **Testability.** Maintain high test coverage (target: >75%) with unit tests for data
   structures, coordinate transforms, downsampling, and rendering logic.

### Non-Goals

1. **3D charts.** The library targets 2D data visualisation only. 3D charts (surface
   plots, 3D bar charts) are out of scope.

2. **Map/geo visualisation.** Geographic charts, choropleths, and map overlays are not in
   scope. Use a dedicated mapping library.

3. **Spreadsheet-like data editing.** The chart is a read-only visualisation. Inline data
   editing, drag-to-reorder, or cell-level interaction is not planned.

4. **Server-side rendering.** The library targets Flutter's client-side rendering pipeline.
   Generating chart images on a server is not a goal.

5. **Backward compatibility with Dart <3.9 / Flutter <3.22.** The library uses modern Dart
   features and does not maintain shims for older SDK versions.

6. **CI/CD pipeline.** While the project has comprehensive local testing, no continuous
   integration or continuous deployment pipeline is configured at this time. This is a known
   gap, not a design choice.

7. **Plugin/extension marketplace.** Third-party chart type plugins or renderer extensions
   are not supported. The series type system is internal.

---

## Key Metrics

| Metric | Value |
|---|---|
| **Version** | 1.1.1 |
| **Dart files** | 149 |
| **Lines of code (lib/)** | ~45,000 |
| **Test files** | 80 |
| **Total tests** | 3,626 |
| **Code coverage** | 75.86% |
| **Pana score** | 160 / 160 |
| **Minimum Dart SDK** | 3.9 |
| **Minimum Flutter SDK** | 3.22.0 |
| **Runtime dependencies** | 1 (`intl ^0.20.2`) |
| **Dev dependencies** | 3 (`flutter_test`, `flutter_lints`, `pana`) |
| **Chart types** | 5 (Line, Area, Bar, Stacked Bar, Pie/Donut) |
| **Axis types** | 3 (Numeric, Category, DateTime) |
| **License** | MIT |
| **Performance target** | 10,000+ points at 60 fps |

---

## Technology Choices

### Flutter and Dart (Core Platform)

**Choice:** Pure Dart/Flutter with no native code or platform channels.

**Rationale:** Flutter's Skia/Impeller rendering engine provides GPU-accelerated 2D drawing
through the `Canvas` API. By staying in pure Dart, the library:
- Works on all Flutter platforms (iOS, Android, Web, macOS, Windows, Linux) without
  platform-specific builds.
- Avoids the complexity and fragility of method channels or FFI bindings.
- Can be tested entirely with `flutter_test` without device or emulator dependencies.
- Keeps the pub.dev score at 160/160 with no platform-specific warnings.

### CustomPainter (Rendering)

**Choice:** `CustomPainter` as the rendering primitive for all chart types.

**Rationale:** See [PDR-2](#pdr-2-custompainter-based-rendering). `CustomPainter` is the
idiomatic Flutter mechanism for complex 2D drawing. It integrates with repaint boundaries,
supports `shouldRepaint` for efficient invalidation, and requires no external rendering
engines.

### intl (Formatting)

**Choice:** `intl ^0.20.2` as the sole runtime dependency.

**Rationale:** Axis labels need locale-aware number formatting (thousands separators,
decimal points) and date/time formatting (month names, date patterns). The `intl` package
is the Dart ecosystem standard for internationalisation, maintained by the Dart team, and
already a transitive dependency of most Flutter apps. Adding it does not increase the
effective dependency count for typical consumers.

### LTTB (Downsampling Algorithm)

**Choice:** Largest-Triangle-Three-Buckets for live data downsampling.

**Rationale:** See [PDR-6](#pdr-6-lttb-downsampling). LTTB offers the best balance of
visual fidelity, computational efficiency (O(n) time, O(1) space), and suitability for
time-series data. It is the industry standard for chart downsampling.

### Ring Buffer (Live Data Storage)

**Choice:** Fixed-capacity ring buffer for live streaming data.

**Rationale:** See [PDR-5](#pdr-5-ring-buffer-for-live-data). Ring buffers provide O(1)
insertion, bounded memory, and natural sliding-window semantics for real-time data. The
alternative -- an unbounded list with periodic truncation -- creates GC pressure spikes and
unpredictable memory usage.

### Immutable Configuration Objects (API Design)

**Choice:** All chart configuration is expressed through immutable Dart objects
(`FusionChartConfiguration`, `FusionZoomConfiguration`, `FusionPanConfiguration`,
`FusionCrosshairConfiguration`, theme objects, etc.).

**Rationale:** Flutter's widget tree is built on immutable descriptions of UI. Using the
same pattern for chart configuration means:
- Charts rebuild predictably when configuration changes.
- Configuration objects can be compared for equality to skip unnecessary repaints.
- No hidden mutable state leaks between frames.
- Configuration can be serialised, logged, or snapshot-tested trivially.

### TickerProviderStateMixin (Animation)

**Choice:** Use `TickerProviderStateMixin` in chart widget state classes.

**Rationale:** Charts use multiple animation controllers (for data transitions, tooltip
fade-in, crosshair movement, etc.). `TickerProviderStateMixin` supports multiple tickers
from a single state object, avoiding the "multiple ticker" crash that occurs with
`SingleTickerProviderStateMixin` when more than one `AnimationController` is active.

### SOLID Principles (Architecture)

**Choice:** Structure the codebase around SOLID principles with clear module boundaries.

**Rationale:** The library's `lib/src/` directory is organised into focused modules:

| Module | Responsibility |
|---|---|
| `charts/` | Top-level chart widgets |
| `configuration/` | Immutable configuration objects |
| `controllers/` | `FusionChartController` for programmatic control |
| `core/` | Axes, constants, enums, models, validation, styling |
| `data/` | Data point and data set models |
| `live/` | Live streaming pipeline (ring buffer, downsampling, coalescing) |
| `rendering/` | Layered render pipeline (painters, layers, layout, animation) |
| `series/` | Polymorphic series types |
| `themes/` | Light/dark theme definitions |
| `type/` | Chart type enumeration |
| `utils/` | Shared utility functions |
| `widgets/` | Supporting widget infrastructure |

This structure ensures that:
- **Single Responsibility:** Each module owns one concern.
- **Open/Closed:** New chart types and features are added by extension, not modification.
- **Liskov Substitution:** Series types are interchangeable through the `FusionSeries`
  interface.
- **Interface Segregation:** Render layers depend on narrow interfaces, not the full chart
  state.
- **Dependency Inversion:** High-level chart widgets depend on abstractions (series,
  configuration), not on concrete rendering details.

---

## Cross-References

- [System Architecture](system-architecture.md) -- Detailed module diagrams, data flow,
  and rendering pipeline documentation.
- [Code Standards](code-standards.md) -- Dart style guide, naming conventions, testing
  requirements, and contribution standards.
- [API Reference](api-reference.md) -- Complete public API documentation with usage
  examples for all chart types, configurations, and controllers.

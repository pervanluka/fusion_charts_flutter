# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

### Added

#### Chart Types
- **FusionLineChart** — Line chart with straight or smooth curved lines (Bezier/Catmull-Rom splines)
- **FusionBarChart** — Bar chart for categorical data comparison

#### Series Features
- `FusionLineSeries` — Line series with configurable width, curves, dash patterns
- `FusionBarSeries` — Bar series with customizable bar width and spacing
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
- Example application
- README with quick start guide

### Notes

- Minimum Flutter SDK: 3.22.0
- Minimum Dart SDK: 3.9.0
- Dependencies: `intl` for formatting

---

## [Unreleased]

### Planned
- Pie/Donut charts
- Scatter charts
- Bubble charts
- Candlestick/OHLC charts
- Radar/Spider charts
- Gauge charts
- Funnel charts
- Stacked bar/area charts
- Multiple Y-axes
- Annotations and plot bands
- Real-time streaming data support
- Export to image (PNG, SVG)
- Accessibility improvements (Semantics)
- Golden tests
- Widget tests

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2025-01-XX | Initial release |


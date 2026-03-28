# Testing Guide

This document describes the test suite for **fusion_charts_flutter**, covering test
organization, categories, patterns, coverage, and instructions for running tests.

For coding conventions referenced throughout the test suite, see [Code Standards](code-standards.md).
For an overview of the codebase architecture that these tests validate, see
[Codebase Summary](codebase-summary.md).

---

## Table of Contents

- [Overview](#overview)
- [Test Suite at a Glance](#test-suite-at-a-glance)
- [Directory Structure](#directory-structure)
- [Test Categories](#test-categories)
  - [Unit Tests](#unit-tests)
  - [Widget Tests](#widget-tests)
  - [Golden Tests](#golden-tests)
  - [Interaction Tests](#interaction-tests)
  - [Live Streaming Tests](#live-streaming-tests)
  - [Performance Tests](#performance-tests)
  - [Edge Case Tests](#edge-case-tests)
- [Key Test Files](#key-test-files)
- [Test Patterns and Conventions](#test-patterns-and-conventions)
  - [Framework and Dependencies](#framework-and-dependencies)
  - [Data Fixtures](#data-fixtures)
  - [Custom Mocks](#custom-mocks)
  - [Widget Test Wrapper](#widget-test-wrapper)
  - [Configuration Variants](#configuration-variants)
- [Running Tests](#running-tests)
  - [Full Suite](#full-suite)
  - [Targeted Runs](#targeted-runs)
  - [Golden File Management](#golden-file-management)
  - [Code Coverage](#code-coverage)
- [Coverage Report](#coverage-report)
- [Writing New Tests](#writing-new-tests)
  - [Adding a Unit Test](#adding-a-unit-test)
  - [Adding a Widget Test](#adding-a-widget-test)
  - [Adding a Golden Test](#adding-a-golden-test)
  - [Adding an Edge Case Test](#adding-an-edge-case-test)
- [Troubleshooting](#troubleshooting)

---

## Overview

The test suite uses **flutter_test** from the Flutter SDK exclusively. There are no external
mocking libraries (no `mockito`, no `mocktail`). All test doubles are hand-written within the
test files themselves.

Every layer of the charting library is covered: data models, mathematical utilities,
coordinate systems, rendering pipelines, widget composition, gesture handling, live-streaming
controllers, and visual regression through golden snapshots.

---

## Test Suite at a Glance

| Metric             | Value                    |
|--------------------|--------------------------|
| Test files         | 80                       |
| Total tests        | 3,626                    |
| Lines of test code | ~57,339                  |
| Line coverage      | 75.86% (8,864 / 11,685) |
| Framework          | `flutter_test` (SDK)     |
| External mocks     | None                     |

---

## Directory Structure

```
test/
├── unit/                    # 66 files -- Core logic tests
│   ├── axis_bounds_test.dart
│   ├── fusion_mathematics_test.dart
│   ├── fusion_render_pipeline_test.dart
│   ├── ... (63 more files)
│   └── tooltip_configuration_test.dart
├── widget_tests/            # 5 files -- Chart rendering
├── golden_tests/            # 1 file, 7 golden PNGs
├── interaction_tests/       # 1 file -- Gesture handling
├── live/                    # 4 files -- Real-time streaming
├── performance_tests/       # 1 file -- Stress testing
├── edge_case_tests.dart     # Boundary conditions
└── fusion_charts_flutter_test.dart
```

---

## Test Categories

### Unit Tests

**Location:** `test/unit/` (66 files)

Unit tests form the backbone of the suite. They exercise individual classes and functions
in isolation without rendering widgets. Covered domains include:

| Domain                  | Example Files                                                      |
|-------------------------|--------------------------------------------------------------------|
| Data models             | `fusion_data_point_test.dart`, `fusion_pie_data_point_test.dart`   |
| Configuration           | `configuration_test.dart`, `fusion_chart_configuration_test.dart`  |
| Mathematics (Bezier)    | `fusion_mathematics_test.dart`, `fusion_path_builder_test.dart`    |
| Polar math              | `fusion_polar_math_test.dart`                                      |
| Coordinate system       | `coordinate_system_test.dart`, `fusion_coordinate_system_test.dart`|
| Axis bounds & ticks     | `axis_bounds_test.dart`, `axis_calculator_test.dart`               |
| Series logic            | `fusion_series_test.dart`, `fusion_line_series_test.dart`          |
| Rendering pipeline      | `fusion_render_pipeline_test.dart`, `fusion_render_context_test.dart` |
| Paint pool / caching    | `fusion_paint_pool_test.dart`, `fusion_shader_cache_test.dart`     |
| Tooltips                | `fusion_tooltip_layer_test.dart`, `multi_series_tooltip_test.dart` |
| Crosshair               | `fusion_crosshair_configuration_test.dart`                         |
| Interactive state       | `fusion_interactive_state_base_test.dart`, `interaction_handler_test.dart` |
| Live controller         | `fusion_live_chart_controller_test.dart`, `live_chart_mixin_test.dart` |
| Downsampling (LTTB)     | `lttb_downsampler_test.dart`                                       |
| Ring buffer             | `ring_buffer_test.dart`                                            |
| Date/time utilities     | `fusion_datetime_utils_test.dart`, `fusion_datetime_axis_test.dart`|

Typical unit test structure:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('AxisBounds', () {
    test('computes correct range from data min/max', () {
      final bounds = AxisBounds.fromDataRange(
        dataMin: 0.0,
        dataMax: 100.0,
        desiredTickCount: 5,
      );

      expect(bounds.range, greaterThan(0));
      expect(bounds.min, lessThanOrEqualTo(0.0));
      expect(bounds.max, greaterThanOrEqualTo(100.0));
      expect(bounds.interval, greaterThan(0));
    });
  });
}
```

### Widget Tests

**Location:** `test/widget_tests/` (5 files)

Widget tests verify that chart widgets build and render correctly within a Flutter widget
tree. Each chart type (line, bar, pie, stacked bar) has a dedicated test file. The
`series_visibility_test.dart` file tests toggling series visibility on and off.

Test files:

| File                              | Coverage                         |
|-----------------------------------|----------------------------------|
| `line_chart_widget_test.dart`     | Line chart rendering, single/multi-point |
| `bar_chart_widget_test.dart`      | Bar chart rendering              |
| `pie_chart_widget_test.dart`      | Pie chart rendering              |
| `stacked_bar_chart_widget_test.dart` | Stacked bar rendering         |
| `series_visibility_test.dart`     | Series show/hide toggles         |

Standard widget test pattern:

```dart
testWidgets('renders without error', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: FusionLineChart(
            series: [
              FusionLineSeries(
                name: 'Test',
                dataPoints: [
                  FusionDataPoint(0, 10),
                  FusionDataPoint(1, 20),
                  FusionDataPoint(2, 15),
                ],
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.byType(FusionLineChart), findsOneWidget);
  expect(find.byType(CustomPaint), findsWidgets);
});
```

Charts are always wrapped in `MaterialApp > Scaffold > SizedBox` to provide a material
context and explicit dimensions. Call `tester.pumpAndSettle()` after pumping to let
animations and layout complete.

### Golden Tests

**Location:** `test/golden_tests/` (1 test file, 7 golden images)

Golden tests capture pixel-perfect snapshots of rendered charts and compare them against
stored reference images. Any visual regression causes a test failure and produces a diff
image in `test/golden_tests/failures/`.

Golden images stored in `test/golden_tests/goldens/`:

| Golden File                   | Chart Type              |
|-------------------------------|-------------------------|
| `line_chart.png`              | Line chart              |
| `bar_chart.png`               | Bar chart               |
| `pie_chart.png`               | Pie chart               |
| `donut_chart.png`             | Donut chart             |
| `stacked_bar_chart.png`       | Stacked bar chart       |
| `dark_theme_line_chart.png`   | Line chart (dark theme) |
| `dark_theme_pie_chart.png`    | Pie chart (dark theme)  |

Golden test pattern:

```dart
testWidgets('line chart matches golden', (tester) async {
  final chartKey = GlobalKey();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: RepaintBoundary(
          key: chartKey,
          child: SizedBox(
            width: 400,
            height: 300,
            child: FusionLineChart(
              series: [
                FusionLineSeries(
                  name: 'Revenue',
                  dataPoints: [
                    FusionDataPoint(0, 30),
                    FusionDataPoint(1, 50),
                    FusionDataPoint(2, 40),
                    FusionDataPoint(3, 65),
                    FusionDataPoint(4, 55),
                    FusionDataPoint(5, 80),
                  ],
                  color: const Color(0xFF6366F1),
                  lineWidth: 2.5,
                ),
              ],
              config: const FusionLineChartConfiguration(
                enableAnimation: false,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  await expectLater(
    find.byKey(chartKey),
    matchesGoldenFile('goldens/line_chart.png'),
  );
});
```

Animations are disabled (`enableAnimation: false`) for determinism. A `RepaintBoundary`
with a `GlobalKey` isolates the chart for pixel capture. Background color is set explicitly
to avoid platform-dependent defaults.

### Interaction Tests

**Location:** `test/interaction_tests/` (1 file)

`chart_interaction_test.dart` exercises user gesture handling across chart types. Tested
interactions include:

- **Tap** -- Shows tooltip on tap near a data point.
- **Long press** -- Triggers crosshair or extended tooltip display.
- **Drag / pan** -- Pans the visible viewport horizontally.
- **Zoom (scroll wheel)** -- Zooms in/out on desktop via scroll events.
- **Multi-touch** -- Pinch-to-zoom on touch devices.

Gesture simulation uses Flutter's built-in `WidgetTester` methods:

```dart
// Tap at a specific screen coordinate
await tester.tapAt(const Offset(200, 150));
await tester.pump(const Duration(milliseconds: 100));

// Drag gesture for panning
await tester.drag(find.byType(FusionLineChart), const Offset(-50, 0));
await tester.pumpAndSettle();
```

Tests assert that the chart widget remains rendered (no crash) and that the interaction
produces the expected state change.

### Live Streaming Tests

**Location:** `test/live/` (4 files)

These tests cover the real-time data streaming subsystem that allows charts to update
continuously with incoming data points.

| File                          | Focus                                      |
|-------------------------------|--------------------------------------------|
| `controller_test.dart`        | Live chart controller lifecycle, start/stop, data push |
| `downsampling_test.dart`      | LTTB downsampling under streaming conditions |
| `live_chart_widget_test.dart` | Widget-level live updates and re-rendering  |
| `ring_buffer_test.dart`       | Ring buffer data structure for fixed-window storage |

Tests verify controller lifecycle (create/start/dispose), data propagation to the chart,
LTTB downsampling activation above configured thresholds, and ring buffer eviction at
capacity.

### Performance Tests

**Location:** `test/performance_tests/` (1 file)

`performance_test.dart` stress-tests chart rendering with large datasets to verify that
the library handles high data volumes without timeouts or crashes.

Tested scales:

| Dataset Size | Test Description                  |
|--------------|-----------------------------------|
| 1,000 points | Baseline large dataset rendering  |
| 5,000 points | Medium stress test                |
| 10,000+ points | Upper-bound stress test         |

Example:

```dart
testWidgets('renders 1000 points without timeout', (tester) async {
  final data = List.generate(
    1000,
    (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1) * 50 + 50),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: FusionLineChart(
            series: [
              FusionLineSeries(
                name: 'Large',
                dataPoints: data,
                color: Colors.blue,
              ),
            ],
            config: const FusionChartConfiguration(
              enableAnimation: false,
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.byType(FusionLineChart), findsOneWidget);
});
```

### Edge Case Tests

**Location:** `test/edge_case_tests.dart` (1 file, 40+ tests)

This file targets boundary conditions and pathological inputs that could cause crashes,
rendering artifacts, or incorrect calculations. Tested scenarios include:

- **Zero-range axis** -- Identical `dataMin` and `dataMax` (e.g., all values are 50.0).
- **Zero-to-zero** -- Both min and max are 0.0.
- **Extreme values** -- Very large numbers (1e9+).
- **Negative coordinates** -- Negative x and y values.
- **Empty data** -- Series with no data points.
- **NaN and Infinity** -- Non-finite values in data points.
- **Single data point** -- Series with exactly one point.

Example:

```dart
test('handles identical values (zero range)', () {
  final bounds = AxisBounds.fromDataRange(
    dataMin: 50.0,
    dataMax: 50.0,
    desiredTickCount: 5,
  );

  expect(bounds.range, greaterThan(0), reason: 'Should create non-zero range');
  expect(bounds.min, lessThan(50.0), reason: 'Min should be below value');
  expect(bounds.max, greaterThan(50.0), reason: 'Max should be above value');
  expect(bounds.interval, greaterThan(0), reason: 'Interval must be positive');
});
```

Edge case tests use the `reason` parameter in `expect()` calls to provide clear failure
messages explaining what invariant was violated.

---

## Key Test Files

The following files contain the highest concentration of critical tests:

| File                                          | Approx. Tests | Domain            |
|-----------------------------------------------|---------------|-------------------|
| `unit/fusion_mathematics_test.dart`           | 50+           | Math functions (Bezier curves, interpolation) |
| `unit/axis_bounds_test.dart`                  | 30+           | Axis bound calculation algorithms |
| `unit/fusion_chart_controller_test.dart`      | 25+           | Chart controller public API |
| `interaction_tests/chart_interaction_test.dart`| 20+          | Gesture handling (tap, drag, zoom) |
| `live/controller_test.dart`                   | 30+           | Live streaming controller lifecycle |
| `edge_case_tests.dart`                        | 40+           | Boundary conditions and pathological inputs |

---

## Test Patterns and Conventions

### Framework and Dependencies

All tests import from `flutter_test` (Flutter SDK). No external test utilities or mocking
libraries are used. Widget tests additionally import `package:flutter/material.dart`;
interaction tests import `package:flutter/gestures.dart`.

### Data Fixtures

Test data is created inline. There are no shared fixture files or factory functions outside
of the test files:

```dart
// Minimal data point creation
FusionDataPoint(0, 10)

// Series with inline data
FusionLineSeries(
  name: 'Test',
  dataPoints: [
    FusionDataPoint(0, 10),
    FusionDataPoint(1, 20),
    FusionDataPoint(2, 15),
  ],
  color: Colors.blue,
)

// Generated large datasets
final data = List.generate(
  1000,
  (i) => FusionDataPoint(i.toDouble(), math.sin(i * 0.1) * 50 + 50),
);
```

### Custom Mocks

Since no mocking library is used, test doubles are hand-rolled as private classes within
each test file:

- `_MockInteractiveState` -- Stubs the interactive state interface for gesture tests.
- `_MockCanvas` -- Minimal canvas implementation for rendering pipeline tests.
- `MockRenderLayer` -- Stubs the render layer interface for composition tests.

These mocks typically extend or implement the target class/interface with minimal overrides,
providing just enough behavior for the test at hand.

### Widget Test Wrapper

All widget tests wrap charts in the same boilerplate to provide a valid render context:

```dart
MaterialApp(
  home: Scaffold(
    body: SizedBox(
      width: 400,
      height: 300,
      child: chartWidget,
    ),
  ),
)
```

The `SizedBox` with fixed dimensions (typically 400x300) ensures deterministic layout.
Golden tests additionally set `backgroundColor` on the `Scaffold` and wrap the chart in a
`RepaintBoundary`.

### Configuration Variants

Tests exercise configuration permutations using the `copyWith()` method available on
configuration classes:

```dart
const baseConfig = FusionChartConfiguration(
  enableAnimation: false,
);

// Derive variant with different settings
final withTooltip = baseConfig.copyWith(enableTooltip: true);
final withZoom = baseConfig.copyWith(enableZoom: true);
```

This pattern avoids repeating full constructor calls and makes it clear which parameter
each test is exercising.

---

## Running Tests

### Full Suite

Run all 3,626 tests:

```bash
flutter test
```

### Targeted Runs

Run specific test categories:

```bash
# Unit tests only (66 files)
flutter test test/unit/

# Widget tests only
flutter test test/widget_tests/

# Golden tests only
flutter test test/golden_tests/

# Interaction tests only
flutter test test/interaction_tests/

# Live streaming tests only
flutter test test/live/

# Performance tests only
flutter test test/performance_tests/

# Edge case tests only
flutter test test/edge_case_tests.dart
```

Run a single test file:

```bash
flutter test test/unit/fusion_mathematics_test.dart
```

Run tests matching a name pattern:

```bash
flutter test --name "handles identical values"
```

### Golden File Management

Golden tests compare rendered output against stored reference PNGs. When the chart
rendering changes intentionally (new styling, layout adjustments), the golden files must
be regenerated:

```bash
# Regenerate all golden files
flutter test --update-goldens

# Regenerate goldens for golden tests only
flutter test test/golden_tests/ --update-goldens
```

After regeneration, review the updated PNGs in `test/golden_tests/goldens/` visually
before committing. Failed golden comparisons produce diff images in
`test/golden_tests/failures/`.

**Important:** Golden files are platform-sensitive. Rendering differences between macOS,
Linux, and Windows can cause false failures. Establish a single reference platform for
golden generation (typically the CI platform) and regenerate goldens only on that platform.

### Code Coverage

Generate a coverage report:

```bash
flutter test --coverage
```

This creates `coverage/lcov.info`. To view an HTML report:

```bash
# Install lcov if needed (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

Current coverage: **75.86%** (8,864 of 11,685 lines covered).

---

## Coverage Report

| Category         | Files | Tests | Primary Coverage Areas                        |
|------------------|-------|-------|-----------------------------------------------|
| Unit tests       | 66    | ~3,400| Models, math, config, axis, series, rendering |
| Widget tests     | 5     | ~50   | Widget build, layout, paint integration       |
| Golden tests     | 1     | 7     | Visual correctness (pixel-level)              |
| Interaction tests| 1     | ~20   | Gesture recognition, state transitions        |
| Live tests       | 4     | ~70   | Controller, downsampling, ring buffer         |
| Performance tests| 1     | ~10   | Large-dataset rendering paths                 |
| Edge cases       | 1     | ~40   | Boundary conditions across multiple modules   |

Lower-coverage areas (candidates for improvement): complex `Canvas` rendering paths,
platform-specific gesture edge cases, and animated transitions (most tests disable
animation for determinism).

---

## Writing New Tests

### Adding a Unit Test

1. Create a new file in `test/unit/` following the naming convention
   `<class_or_feature>_test.dart`.
2. Import `flutter_test` and the library.
3. Organize with `group()` and `test()`.
4. Keep tests focused on a single behavior per `test()` block.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

void main() {
  group('MyNewFeature', () {
    test('computes expected value', () {
      final result = MyNewFeature.compute(input: 42);
      expect(result, equals(expectedValue));
    });
  });
}
```

See [Code Standards](code-standards.md) for naming conventions.

### Adding a Widget Test

1. Add to an existing file in `test/widget_tests/` or create a new one.
2. Use the standard `MaterialApp > Scaffold > SizedBox` wrapper.
3. Disable animations for deterministic results.
4. Call `tester.pumpAndSettle()` after pumping.

```dart
testWidgets('new chart type renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: FusionNewChart(
            series: [/* test data */],
            config: const FusionChartConfiguration(
              enableAnimation: false,
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.byType(FusionNewChart), findsOneWidget);
});
```

### Adding a Golden Test

1. Add a new `testWidgets` in `test/golden_tests/chart_golden_test.dart`.
2. Wrap the chart in a `RepaintBoundary` with a `GlobalKey`.
3. Set an explicit background color on the `Scaffold`.
4. Disable animations.
5. Run `flutter test --update-goldens` to generate the initial reference image.
6. Visually verify the generated PNG before committing.

```dart
testWidgets('new chart matches golden', (tester) async {
  final chartKey = GlobalKey();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: RepaintBoundary(
          key: chartKey,
          child: SizedBox(
            width: 400,
            height: 300,
            child: FusionNewChart(/* ... */),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  await expectLater(
    find.byKey(chartKey),
    matchesGoldenFile('goldens/new_chart.png'),
  );
});
```

### Adding an Edge Case Test

1. Add to `test/edge_case_tests.dart` within the appropriate `group()` or create a new
   group.
2. Use the `reason` parameter in `expect()` to explain the invariant being checked.
3. Focus on inputs that might cause division by zero, NaN propagation, empty collections,
   or out-of-bounds access.

```dart
test('handles NaN in data points', () {
  final bounds = AxisBounds.fromDataRange(
    dataMin: double.nan,
    dataMax: 100.0,
    desiredTickCount: 5,
  );

  expect(bounds.range, isFinite, reason: 'NaN input should not produce NaN range');
  expect(bounds.interval, greaterThan(0), reason: 'Interval must remain positive');
});
```

---

## Troubleshooting

### Golden test failures on a different platform

Golden images are pixel-exact. Font rendering, anti-aliasing, and compositing differ
across platforms. If goldens pass on macOS but fail on Linux CI:

- Regenerate goldens on the CI platform: `flutter test --update-goldens`.
- Commit the platform-specific goldens.
- Consider running golden tests only on the designated reference platform.

### Tests timing out

Performance tests with 10K+ data points may approach the default test timeout. If a test
times out:

- Confirm animations are disabled (`enableAnimation: false`).
- Check if `pumpAndSettle()` is waiting for an animation that never completes.
- Increase the timeout for specific tests if needed:
  ```dart
  testWidgets('large dataset', (tester) async {
    // test body
  }, timeout: const Timeout(Duration(seconds: 30)));
  ```

### Flaky interaction tests

Gesture tests that rely on specific screen coordinates can be sensitive to layout changes.
If an interaction test becomes flaky:

- Verify the chart dimensions match the hardcoded tap/drag coordinates.
- Use `tester.getCenter(find.byType(ChartType))` to compute coordinates dynamically
  rather than using hardcoded `Offset` values.

### Coverage not increasing after adding tests

- Ensure the new test file is discoverable by `flutter test` (must end in `_test.dart`
  or `_tests.dart`).
- Run `flutter test --coverage` and inspect `coverage/lcov.info` to confirm the new file
  appears.
- Tests that only exercise already-covered lines will not increase the coverage percentage.

---

## Related Documentation

- [Code Standards](code-standards.md) -- Naming conventions, code organization, and style
  guidelines that apply to test code.
- [Codebase Summary](codebase-summary.md) -- Architecture overview of the modules tested
  by this suite.

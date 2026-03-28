# Code Standards

> **fusion_charts_flutter** -- Flutter charting library, Dart 3.9+
>
> Related docs: [System Architecture](system-architecture.md) | [Testing Guide](testing-guide.md)

This document is the single source of truth for code style, naming, architecture patterns, and lint configuration in the fusion_charts_flutter project. All contributions must conform to these standards; CI enforces them via `dart analyze` and the rules defined in `analysis_options.yaml`.

---

## Table of Contents

1. [Analyzer Configuration](#analyzer-configuration)
2. [Lint Rules Reference](#lint-rules-reference)
3. [Naming Conventions](#naming-conventions)
4. [File Organization](#file-organization)
5. [Architecture Patterns](#architecture-patterns)
6. [Code Style Rules](#code-style-rules)
7. [Testing Standards](#testing-standards)
8. [Common Pitfalls](#common-pitfalls)

---

## Analyzer Configuration

### Strict Mode

All three strict flags are enabled. The analyzer rejects implicit casts, inferred `dynamic` types, and raw generic types:

```yaml
analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
```

**What this means in practice:**

- Every generic type must have explicit type arguments (no `List` -- write `List<double>`).
- No implicit downcasts from `dynamic` or `Object`.
- The analyzer infers types where possible, but will error when inference produces `dynamic`.

### Error-Level Rules

The following rules are promoted to **error** severity and will fail CI:

| Rule | Why |
|---|---|
| `missing_required_param` | Prevents runtime null errors from missing constructor arguments |
| `missing_return` | Ensures all code paths return a value |
| `must_be_immutable` | Enforces widget immutability contract |
| `avoid_slow_async_io` | Blocks `File.exists()` and similar -- use async alternatives |
| `cancel_subscriptions` | Prevents `StreamSubscription` memory leaks |
| `close_sinks` | Prevents `StreamController` / `Sink` leaks |

### Excluded Paths

The analyzer ignores generated and build artifacts:

```yaml
exclude:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
  - "build/**"
  - ".dart_tool/**"
  - "example/**"
```

The `example/` directory is excluded so that demo apps can use a more relaxed style without triggering library-level warnings.

---

## Lint Rules Reference

The project enables **160+ lint rules**. This section groups them by category with rationale for key decisions.

### Error Prevention

These rules catch bugs at analysis time rather than at runtime:

```
always_declare_return_types       avoid_dynamic_calls
avoid_empty_else                  avoid_print
avoid_type_to_string              avoid_types_as_parameter_names
cancel_subscriptions              close_sinks
collection_methods_unrelated_type empty_statements
hash_and_equals                   literal_only_boolean_expressions
no_adjacent_strings_in_list       no_duplicate_case_values
no_logic_in_create_state          prefer_void_to_null
throw_in_finally                  unnecessary_statements
unrelated_type_equality_checks    valid_regexps
avoid_slow_async_io               avoid_relative_lib_imports
avoid_web_libraries_in_flutter
```

### Style (Enabled)

```
always_put_required_named_parameters_first
annotate_overrides
avoid_bool_literals_in_conditional_expressions
avoid_catching_errors
avoid_multiple_declarations_per_line
avoid_void_async
await_only_futures
camel_case_types
camel_case_extensions
constant_identifier_names
curly_braces_in_flow_control_structures
directives_ordering
eol_at_end_of_file
exhaustive_cases
file_names
flutter_style_todos
only_throw_errors
parameter_assignments
prefer_asserts_in_initializer_lists
prefer_collection_literals
prefer_conditional_assignment
prefer_const_declarations
prefer_const_constructors_in_immutables
prefer_contains
prefer_final_fields
prefer_final_in_for_each
prefer_final_locals
prefer_function_declarations_over_variables
prefer_if_null_operators
prefer_initializing_formals
prefer_interpolation_to_compose_strings
prefer_is_empty
prefer_is_not_empty
prefer_is_not_operator
prefer_iterable_whereType
prefer_mixin
prefer_null_aware_operators
prefer_single_quotes
prefer_spread_collections
prefer_typing_uninitialized_variables
provide_deprecation_message
require_trailing_commas
slash_for_doc_comments
sort_child_properties_last
sort_constructors_first
sort_unnamed_constructors_first
tighten_type_of_initializing_formals
type_annotate_public_apis
unawaited_futures
unnecessary_lambdas
use_build_context_synchronously
use_enums
use_full_hex_values_for_flutter_colors
use_key_in_widget_constructors
use_super_parameters
```

### Intentionally Disabled Rules

These rules are **disabled on purpose** -- do not enable them:

| Rule | Reason |
|---|---|
| `cascade_invocations` | Builder-style `copyWith` chains and multi-step configuration reads better without forced cascades |
| `prefer_const_constructors` | Creates excessive noise in widget trees and chart configuration; immutability is enforced through design, not `const` |
| `prefer_const_literals_to_create_immutables` | Same rationale as above |
| `omit_local_variable_types` | Explicit local types improve readability in math-heavy rendering code |
| `avoid_redundant_argument_values` | Explicit defaults in chart configurations serve as documentation |
| `avoid_returning_this` | Fluent builder APIs return `this` intentionally |
| `prefer_constructors_over_static_methods` | Factory static methods are used for named construction patterns |
| `prefer_int_literals` | Charting math uses `double` extensively; `1.0` is clearer than `1` |
| `use_late_for_private_fields_and_variables` | Prefer explicit nullable types over `late` to avoid runtime errors |
| `use_raw_strings` | Regex patterns are rare; standard strings are preferred for consistency |
| `avoid_equals_and_hash_code_on_mutable_classes` | Some mutable state objects need equality for caching |

---

## Naming Conventions

### Public API Classes

All public classes are prefixed with `Fusion` to namespace the library and avoid collisions:

```dart
// Charts
FusionLineChart
FusionBarChart
FusionPieChart

// Data
FusionDataPoint
FusionDataSet

// Series
FusionLineSeries
FusionBarSeries
FusionPieSeries
```

### Configuration Classes

Follow the pattern `Fusion[Feature]Configuration`:

```dart
FusionChartConfiguration
FusionAxisConfiguration
FusionZoomConfiguration
FusionPanConfiguration
FusionCrosshairConfiguration
FusionTooltipConfiguration
FusionLegendConfiguration
FusionLineChartConfiguration
FusionBarChartConfiguration
FusionPieChartConfiguration
FusionStackedBarChartConfiguration
```

### Series Classes

Follow the pattern `Fusion[Type]Series`:

```dart
FusionLineSeries
FusionBarSeries
FusionStackedBarSeries
```

### Renderers, Layers, and Painters

Rendering components use consistent suffixes:

```dart
// Renderers -- standalone rendering units
FusionTooltipRenderer

// Layers -- composable render layers (see System Architecture)
FusionGridLayer
FusionAxisLayer
FusionDataLayer

// Painters -- CustomPainter implementations
FusionLineChartPainter
FusionBarChartPainter
FusionPieChartPainter
```

See [System Architecture](system-architecture.md) for how these compose into the rendering pipeline.

### Enums

Enums use descriptive PascalCase names and live in dedicated files under `lib/src/core/enums/`:

```
axis_label_intersect_action.dart
axis_position.dart
axis_type.dart
fusion_zoom_mode.dart
fusion_pan_mode.dart
fusion_pan_edge_behavior.dart
fusion_tooltip_activation_mode.dart
fusion_tooltip_position.dart
marker_shape.dart
label_alignment.dart
```

Enum values use lowerCamelCase per Dart convention:

```dart
enum FusionZoomMode {
  horizontal,
  vertical,
  both,
}
```

### Private Classes and Members

- Private classes: underscore prefix `_ClassName` (e.g., `_ChartState`, `_RenderHelper`)
- Private fields: underscore prefix `_fieldName`
- Private methods: underscore prefix `_methodName`

### File Names

All files use `snake_case` matching the primary class name:

```
FusionLineChart        -> fusion_line_chart.dart
FusionChartConfiguration -> fusion_chart_configuration.dart
FusionZoomMode         -> fusion_zoom_mode.dart
```

---

## File Organization

### Directory Structure

```
lib/
  src/
    charts/              # Chart widget implementations
    configuration/       # All Fusion*Configuration classes
    controllers/         # Chart controllers (zoom, pan, animation)
    core/
      enums/             # One enum per file
    data/                # Data models (FusionDataPoint, FusionDataSet)
    live/                # Live streaming chart support
    rendering/
      animation/         # Animation utilities
      engine/            # Core rendering engine
      interaction/       # Gesture handling, hit testing
      layers/            # Composable render layers
      layout/            # Layout computation
      painters/          # CustomPainter implementations
      polar/             # Polar coordinate rendering (pie/donut)
    series/              # Series model classes
    themes/              # Theme strategy implementations
    type/                # Type definitions and typedefs
    utils/               # Shared utility functions
    widgets/             # Reusable widget components
```

### Rules

1. **One primary class per file.** A file may contain closely related private helper classes, but only one public class.

2. **Mixins** are co-located with their base class or placed in a `mixins/` subdirectory when shared across multiple classes.

3. **Enums** always go in dedicated files under `core/enums/`. Never inline an enum inside another class file.

4. **Tests mirror source structure.** A class at `lib/src/rendering/layers/grid_layer.dart` has its test at `test/rendering/layers/grid_layer_test.dart`.

5. **Exports** are managed through barrel files. The public API is defined in the top-level library file.

---

## Architecture Patterns

The codebase applies specific design patterns consistently. Refer to [System Architecture](system-architecture.md) for detailed diagrams and data flow.

### SOLID Principles

- **Single Responsibility:** Each render layer handles exactly one concern (grid, axes, data, tooltips).
- **Open/Closed:** New chart types are added by composing existing layers, not modifying them.
- **Liskov Substitution:** All series types conform to the same interface contract.
- **Interface Segregation:** Configuration classes expose only relevant options per feature.
- **Dependency Inversion:** Renderers depend on abstractions (coordinate systems), not concrete chart types.

### Composition Over Inheritance

Rendering uses a **layer composition** model rather than deep class hierarchies:

```dart
// Good: compose layers
class FusionLineChartPainter extends FusionChartPainterBase {
  // Delegates to FusionGridLayer, FusionAxisLayer, FusionDataLayer
}

// Bad: deep inheritance
class FusionLineChartPainter extends FusionCartesianPainter
    extends FusionAnimatedPainter extends FusionBasePainter { ... }
```

### Template Method -- Interactive States

Base classes define the skeleton of interactive behavior (touch down, drag, release); subclasses override specific steps:

```dart
abstract class FusionInteractionHandler {
  void handlePointerDown(PointerEvent event);
  void handlePointerMove(PointerEvent event);
  void handlePointerUp(PointerEvent event);
}
```

### Factory Pattern -- Axis Renderers

Axis renderers are created through factory methods based on axis type and position:

```dart
// The factory selects the correct renderer at runtime
final renderer = FusionAxisRenderer.create(
  type: AxisType.numeric,
  position: AxisPosition.left,
);
```

### Strategy Pattern -- Themes

Themes are interchangeable strategy objects:

```dart
final chart = FusionLineChart(
  theme: FusionDarkTheme(),   // or FusionLightTheme(), or custom
);
```

### Builder Pattern -- Configuration with copyWith

All configuration classes are immutable and expose `copyWith` for modification:

```dart
final config = FusionChartConfiguration(
  enableZoom: true,
  enablePanning: true,
).copyWith(
  enableCrosshair: true,
);
```

### Immutable Value Objects

Core data structures like `FusionCoordinateSystem` are immutable value objects. They are created once and never mutated; new instances are produced via `copyWith` when changes are needed.

---

## Code Style Rules

### Return Types

Always declare return types explicitly. The `always_declare_return_types` rule enforces this:

```dart
// Good
double calculateYPosition(double value) { ... }
void updateChart() { ... }
List<FusionDataPoint> filterVisible(List<FusionDataPoint> points) { ... }

// Bad -- missing return type
calculateYPosition(double value) { ... }
```

### Override Annotations

Always annotate overrides. The `annotate_overrides` rule enforces this:

```dart
// Good
@override
void paint(Canvas canvas, Size size) { ... }

// Bad
void paint(Canvas canvas, Size size) { ... }
```

### String Quotes

Use single quotes everywhere. The `prefer_single_quotes` rule enforces this:

```dart
// Good
final label = 'Total: $value';

// Bad
final label = "Total: $value";
```

### Local Variables

Prefer `final` for local variables. The `prefer_final_locals` rule enforces this:

```dart
// Good
final double x = offset.dx;
final points = series.dataPoints;

// Bad
double x = offset.dx;        // if never reassigned
var points = series.dataPoints; // if never reassigned
```

### Explicit Local Types

The `omit_local_variable_types` rule is **disabled**. You may (and should) use explicit types in rendering and math code for clarity:

```dart
// Encouraged in rendering code
double pixelX = coordinateSystem.toPixelX(dataX);
double pixelY = coordinateSystem.toPixelY(dataY);
Offset center = Offset(pixelX, pixelY);

// Also fine -- var is acceptable when the type is obvious
final points = <Offset>[];
```

### Trailing Commas

The `require_trailing_commas` rule is enabled. Always add trailing commas in argument lists, parameter lists, and collection literals:

```dart
// Good
final config = FusionChartConfiguration(
  enableZoom: true,
  enablePanning: true,   // <-- trailing comma
);

// Bad
final config = FusionChartConfiguration(
  enableZoom: true,
  enablePanning: true);
```

### Constructor Ordering

The `sort_constructors_first` rule is enabled. Constructors must appear before all other members:

```dart
class FusionDataPoint {
  // 1. Constructors first
  FusionDataPoint({
    required this.x,
    required this.y,
  });

  // 2. Then fields
  final double x;
  final double y;

  // 3. Then methods
  double distanceTo(FusionDataPoint other) { ... }
}
```

### Required Parameters First

The `always_put_required_named_parameters_first` rule is enabled:

```dart
// Good
FusionLineSeries({
  required List<FusionDataPoint> dataPoints,
  required Color color,
  double strokeWidth = 2.0,
  bool showMarkers = false,
});

// Bad
FusionLineSeries({
  double strokeWidth = 2.0,
  required List<FusionDataPoint> dataPoints,  // required should be first
  required Color color,
});
```

### No print Statements

The `avoid_print` rule is enabled. Use proper logging or debugging tools:

```dart
// Good
debugPrint('Chart rendered in ${stopwatch.elapsedMilliseconds}ms');
assert(() {
  debugPrint('Debug-only message');
  return true;
}());

// Bad
print('Chart rendered');
```

### Unawaited Futures

The `unawaited_futures` rule is enabled. Either `await` a Future or explicitly mark it with `unawaited()`:

```dart
// Good
await controller.animateTo(1.0);
unawaited(analytics.trackEvent('chart_rendered'));

// Bad
controller.animateTo(1.0);  // unawaited Future -- lint error
```

### Unnecessary Lambdas

The `unnecessary_lambdas` rule is enabled. Use tear-offs when possible:

```dart
// Good
points.map(transform);
points.forEach(canvas.drawCircle);

// Bad
points.map((p) => transform(p));
points.forEach((p) => canvas.drawCircle(p));
```

### Super Parameters

The `use_super_parameters` rule is enabled (Dart 3.0+):

```dart
// Good
class FusionLineChart extends StatefulWidget {
  FusionLineChart({super.key, required this.series});
  final List<FusionLineSeries> series;
}

// Bad
class FusionLineChart extends StatefulWidget {
  FusionLineChart({Key? key, required this.series}) : super(key: key);
  final List<FusionLineSeries> series;
}
```

### Import Ordering

The `directives_ordering` rule is enabled. Imports follow this order:

```dart
// 1. Dart SDK imports
import 'dart:math';
import 'dart:ui';

// 2. Package imports
import 'package:flutter/material.dart';

// 3. Relative project imports
import '../core/enums/axis_type.dart';
import '../rendering/layers/fusion_grid_layer.dart';
```

### Hex Colors

The `use_full_hex_values_for_flutter_colors` rule is enabled:

```dart
// Good
final color = Color(0xFF42A5F5);

// Bad
final color = Color(0x42A5F5);
```

---

## Testing Standards

See [Testing Guide](testing-guide.md) for the complete testing strategy and examples.

### Key Points

- **No generated mocks.** The project uses custom mock classes instead of mockito or build_runner-based mocking. This keeps the dependency tree clean and avoids code generation in the test pipeline.

- **Test file location.** Tests mirror the source tree: `lib/src/foo/bar.dart` is tested in `test/foo/bar_test.dart`.

- **No code generation in production.** The project does not use `build_runner`, `freezed`, `json_serializable`, or similar generators for production code. The `*.g.dart` and `*.freezed.dart` exclusions in `analysis_options.yaml` are a safety net, not an indication of active use.

---

## Common Pitfalls

### 1. Forgetting Trailing Commas

The formatter produces different output with and without trailing commas. Always include them so `dart format` produces the intended multi-line layout.

### 2. Using `var` When `final` Works

If a local variable is never reassigned, use `final`. The linter will flag this.

### 3. Raw Generic Types

`strict-raw-types: true` means `List`, `Map`, `Future` without type arguments will fail analysis. Always specify the type:

```dart
// Fails analysis
List points = [];

// Correct
List<Offset> points = [];
```

### 4. Implicit Casts from dynamic

`strict-casts: true` means you cannot silently cast `dynamic` to a concrete type:

```dart
// Fails analysis
final dynamic data = getData();
String name = data['name'];  // implicit cast from dynamic

// Correct
final Map<String, Object?> data = getData();
final name = data['name'] as String;
```

### 5. Missing the Fusion Prefix

All public API classes must be prefixed with `Fusion`. If you add a new public class, ensure it follows the naming convention. Internal/private classes do not need the prefix.

### 6. Forgetting to Cancel Subscriptions

The `cancel_subscriptions` rule is at **error** level. Every `StreamSubscription` must be cancelled in `dispose()` or equivalent:

```dart
class _ChartState extends State<FusionLineChart> {
  StreamSubscription<List<FusionDataPoint>>? _dataSubscription;

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
}
```

### 7. Using print Instead of debugPrint

`avoid_print` is enforced. Use `debugPrint` for debug output or wrap in an assert closure for debug-only logging.

---

## Quick Reference Card

| Topic | Rule |
|---|---|
| Quotes | Single quotes (`'`) |
| Local variables | `final` when not reassigned |
| Return types | Always explicit |
| Overrides | Always `@override` |
| Trailing commas | Always required |
| Generic types | Always explicit type arguments |
| Public class prefix | `Fusion` |
| Config class suffix | `Configuration` |
| Constructor position | Before all other members |
| Required params | Before optional params |
| Futures | `await` or `unawaited()` |
| Subscriptions | Always cancel in `dispose()` |
| Logging | `debugPrint`, never `print` |
| Mocking | Custom mocks, no mockito |
| Code generation | None in production |

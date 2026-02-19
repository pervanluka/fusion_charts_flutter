# fusion_charts_flutter

<p align="center">
  <a href="https://pub.dev/packages/fusion_charts_flutter"><img src="https://img.shields.io/pub/v/fusion_charts_flutter.svg" alt="Pub Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/coverage-75.86%25-brightgreen.svg" alt="Test Coverage">
  <a href="https://github.com/pervanluka/fusion_charts_flutter"><img src="https://img.shields.io/github/stars/pervanluka/fusion_charts_flutter?style=social" alt="GitHub Stars"></a>
</p>

**Professional Flutter charting library with stunning visuals, smooth animations, and enterprise-grade performance.**

---

## ✨ Features

- 📊 **Chart Types**: Line, Bar, Stacked Bar, Pie, and Donut charts
- 📡 **Live Streaming**: Real-time data with auto-scrolling viewport and LTTB downsampling
- ⚡ **High Performance**: Optimized for 10,000+ data points with LTTB downsampling
- 🎨 **Professional Themes**: Light and Dark themes out-of-the-box
- 🎬 **Smooth Animations**: Configurable animations with cubic easing curves
- 📱 **Fully Responsive**: Adapts to mobile, tablet, and desktop
- 🎯 **Interactive**: Tooltips, crosshair, zoom, and pan gestures
- 🔧 **Highly Customizable**: Themes, colors, markers, gradients, and more
- 🌈 **6 Color Palettes**: Material, Professional, Vibrant, Pastel, Warm, Cool
- 🏗️ **SOLID Architecture**: Clean, maintainable, extensible code

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  fusion_charts_flutter: ^1.1.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

### Line Chart

```dart
import 'package:fusion_charts_flutter/fusion_charts_flutter.dart';

FusionLineChart(
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
      color: Colors.blue,
      lineWidth: 2.5,
      isCurved: true,
    ),
  ],
)
```

### Bar Chart

```dart
FusionBarChart(
  series: [
    FusionBarSeries(
      name: 'Sales',
      dataPoints: [
        FusionDataPoint(0, 65, label: 'Q1'),
        FusionDataPoint(1, 78, label: 'Q2'),
        FusionDataPoint(2, 82, label: 'Q3'),
        FusionDataPoint(3, 95, label: 'Q4'),
      ],
      color: Colors.indigo,
      borderRadius: 8.0,
    ),
  ],
)
```

### Stacked Bar Chart

```dart
FusionStackedBarChart(
  series: [
    FusionStackedBarSeries(
      name: 'Product A',
      dataPoints: [
        FusionDataPoint(0, 30),
        FusionDataPoint(1, 40),
        FusionDataPoint(2, 35),
      ],
      color: Colors.blue,
    ),
    FusionStackedBarSeries(
      name: 'Product B',
      dataPoints: [
        FusionDataPoint(0, 20),
        FusionDataPoint(1, 25),
        FusionDataPoint(2, 30),
      ],
      color: Colors.green,
    ),
  ],
)
```

### Pie / Donut Chart

```dart
FusionPieChart(
  series: FusionPieSeries(
    dataPoints: [
      FusionPieDataPoint(35, label: 'Sales', color: Colors.indigo),
      FusionPieDataPoint(25, label: 'Marketing', color: Colors.green),
      FusionPieDataPoint(20, label: 'Engineering', color: Colors.orange),
      FusionPieDataPoint(20, label: 'Other', color: Colors.grey),
    ],
  ),
  config: const FusionPieChartConfiguration(
    innerRadiusPercent: 0.5, // Set to 0 for pie, >0 for donut
    showCenterLabel: true,
    centerLabelText: '\$2.4M',
    centerSubLabelText: 'Revenue',
  ),
)
```

---

## 🎨 Theming

```dart
// Light theme (default)
FusionLineChart(
  series: [...],
  config: const FusionChartConfiguration(
    theme: FusionLightTheme(),
  ),
)

// Dark theme
FusionLineChart(
  series: [...],
  config: const FusionChartConfiguration(
    theme: FusionDarkTheme(),
  ),
)
```

---

## 🎯 Interactivity

### Basic Setup

```dart
FusionLineChart(
  series: [...],
  config: const FusionChartConfiguration(
    enableTooltip: true,
    enableCrosshair: true,
    enableZoom: true,
    enablePanning: true,
  ),
)
```

### Zoom & Pan

The library supports multiple zoom/pan interactions:

#### Mobile Gestures

| Gesture | Action |
|---------|--------|
| Pinch | Zoom in/out |
| Double-tap | Zoom in 2x / Reset |
| Drag | Pan (when zoomed) |

#### Desktop / Web Gestures

| Gesture | Action |
|---------|--------|
| `Ctrl + Scroll` (Win/Linux) | Zoom in/out at cursor |
| `Cmd + Scroll` (macOS) | Zoom in/out at cursor |
| `Shift + Drag` | Selection zoom (draw rectangle) |
| Double-click | Zoom in 2x / Reset |
| Drag | Pan (when zoomed) |

> **Note:** Mouse wheel zoom requires holding `Ctrl` (Windows/Linux) or `Cmd` (macOS) to prevent conflicts with page scrolling. This matches the behavior of Google Maps, Figma, and other professional applications.

#### Selection Zoom

When using `Shift + Drag` on desktop/web, a visual selection rectangle appears with:
- Semi-transparent fill
- Dashed border
- Corner handles
- Dimension indicator (width x height)

Release to zoom into the selected area.

#### Configuration

```dart
FusionLineChart(
  series: [...],
  config: FusionChartConfiguration(
    enableZoom: true,
    enablePanning: true,
    zoomBehavior: FusionZoomConfiguration(
      zoomMode: FusionZoomMode.x,             // x, y, or both
      minZoomLevel: 0.5,                       // Max zoom out (0.5x)
      maxZoomLevel: 10.0,                      // Max zoom in (10x)
      enableDoubleTapZoom: true,
      enableSelectionZoom: true,               // Shift+drag rectangle zoom
      enableMouseWheelZoom: true,
      requireModifierForWheelZoom: true,       // Require Ctrl/Cmd for wheel zoom
      animateZoom: true,
      zoomAnimationDuration: Duration(milliseconds: 300),
    ),
    panBehavior: FusionPanConfiguration(
      panMode: FusionPanMode.x,               // x, y, or both
    ),
  ),
)
```

#### Programmatic Control

Use `FusionChartController` for programmatic zoom/pan control:

```dart
class MyChartWidget extends StatefulWidget {
  @override
  State<MyChartWidget> createState() => _MyChartWidgetState();
}

class _MyChartWidgetState extends State<MyChartWidget> {
  final _controller = FusionChartController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FusionLineChart(
            controller: _controller,
            series: [...],
            config: const FusionChartConfiguration(
              enableZoom: true,
              enablePanning: true,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.zoom_in),
              onPressed: _controller.zoomIn,
            ),
            IconButton(
              icon: Icon(Icons.zoom_out),
              onPressed: _controller.zoomOut,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _controller.resetZoom,
            ),
          ],
        ),
      ],
    );
  }
}
```

### Zoom Controls Widget

Add UI buttons for zoom control:

```dart
Stack(
  children: [
    FusionLineChart(series: [...], config: config),
    Positioned(
      right: 16,
      bottom: 16,
      child: FusionZoomControls(
        onZoomIn: () => chartState.zoomIn(),
        onZoomOut: () => chartState.zoomOut(),
        onReset: () => chartState.reset(),
      ),
    ),
  ],
)
```

### Tooltip Trackball Modes

Control how tooltips follow user interaction:

```dart
config: FusionChartConfiguration(
  enableTooltip: true,
  tooltipBehavior: FusionTooltipBehavior(
    trackballMode: FusionTooltipTrackballMode.snapToX,  // Ideal for line charts
    // Options: none, follow, snap, snapToX, snapToY, magnetic
    shared: true,  // Show all series values at same X position
  ),
)
```

### Crosshair

Long-press to show crosshair lines:

```dart
config: FusionChartConfiguration(
  enableCrosshair: true,
  crosshairBehavior: FusionCrosshairConfiguration(
    showHorizontalLine: true,
    showVerticalLine: true,
    snapToDataPoint: true,
    lineColor: Colors.grey,
    lineWidth: 1.0,
  ),
)
```

---

## ⚡ Performance

For large datasets, the library automatically uses LTTB (Largest Triangle Three Buckets) downsampling to maintain smooth 60fps rendering:

```dart
// Works smoothly with 10,000+ data points
final largeDataset = List.generate(
  10000,
  (i) => FusionDataPoint(i.toDouble(), sin(i * 0.1) * 100),
);

FusionLineChart(
  series: [
    FusionLineSeries(
      name: 'Large Dataset',
      dataPoints: largeDataset,
      color: Colors.purple,
    ),
  ],
)
```

---

## 📡 Live Streaming Charts

Create real-time charts with automatic viewport management:

```dart
class LiveChartDemo extends StatefulWidget {
  @override
  State<LiveChartDemo> createState() => _LiveChartDemoState();
}

class _LiveChartDemoState extends State<LiveChartDemo> {
  late final FusionLiveChartController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = FusionLiveChartController(
      windowDuration: const Duration(seconds: 30),
      viewportMode: LiveViewportMode.sliding,
      retentionPolicy: const DownsampledPolicy(
        maxPoints: 500,
        archivePoints: 1000,
      ),
    );
    _startStreaming();
  }

  void _startStreaming() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _controller.addDataPoint(
        FusionDataPoint(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          Random().nextDouble() * 100,
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FusionLineChart(
      liveController: _controller,
      series: [
        FusionLineSeries(
          name: 'Live Data',
          dataPoints: [],  // Data managed by controller
          color: Colors.blue,
        ),
      ],
      config: const FusionChartConfiguration(
        enableTooltip: true,
      ),
    );
  }
}
```

### Viewport Modes

| Mode | Description |
|------|-------------|
| `sliding` | Fixed window that scrolls with new data |
| `expanding` | Window expands to show all data |
| `fixed` | Static viewport, data scrolls through |

### Retention Policies

```dart
// Keep all points (memory intensive)
const UnlimitedPolicy()

// Keep last N points
const SlidingWindowPolicy(maxPoints: 1000)

// LTTB downsampling (recommended for long sessions)
const DownsampledPolicy(
  maxPoints: 500,      // Recent full-resolution points
  archivePoints: 1000, // Downsampled historical points
)
```

---

## 📅 DateTime Axis & DST Support

The library includes a dedicated `FusionDateTimeAxis` for time-series data with **DST (Daylight Saving Time) safe** handling:

```dart
FusionLineChart(
  series: [
    FusionLineSeries(
      name: 'Temperature',
      dataPoints: temperatureData.map((d) =>
        FusionDataPoint(d.timestamp.millisecondsSinceEpoch.toDouble(), d.value)
      ).toList(),
    ),
  ],
  xAxis: FusionDateTimeAxis(
    min: DateTime(2024, 1, 1),
    max: DateTime(2024, 12, 31),
    desiredIntervals: 6,
  ),
)
```

### DST Support Details

| Interval Type | DST Handling | Method |
|---------------|--------------|--------|
| Days, Weeks, Months, Years | **DST-Safe** | Calendar arithmetic (no drift) |
| Hours, Minutes, Seconds | Duration-based | May show gaps/doubles at DST transitions |

**Key Features:**
- Automatic date formatting based on time range
- Smart interval calculation
- Custom `DateFormat` support via `intl` package
- Month edge case handling (Jan 31 + 1 month = Feb 28)
- Leap year support

**Note:** The library works with local `DateTime` objects. For timezone-aware applications, convert your data to local time before passing to the chart.

---

## 🗺️ Roadmap

Future releases will include:

- 🔵 Scatter & Bubble charts
- 📈 Candlestick/OHLC charts
- 🎯 Radar/Spider charts
- 📊 Multiple Y-axes
- 🖼️ Export to image (PNG, SVG)
- ♿ Enhanced accessibility (Semantics)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting a PR.

---

## 📬 Support

- 🐛 [Report bugs](https://github.com/pervanluka/fusion_charts_flutter/issues)
- 💡 [Request features](https://github.com/pervanluka/fusion_charts_flutter/issues)
- ⭐ Star the repo if you find it useful!

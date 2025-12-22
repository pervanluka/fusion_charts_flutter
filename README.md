# fusion_charts_flutter

<p align="center">
  <a href="https://pub.dev/packages/fusion_charts_flutter"><img src="https://img.shields.io/pub/v/fusion_charts_flutter.svg" alt="Pub Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/pervanluka/fusion_charts_flutter"><img src="https://img.shields.io/github/stars/pervanluka/fusion_charts_flutter?style=social" alt="GitHub Stars"></a>
</p>

**Professional Flutter charting library with stunning visuals, smooth animations, and enterprise-grade performance.**

---

## ✨ Features

- 📊 **Chart Types**: Line, Bar, and Stacked Bar charts
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
  fusion_charts_flutter: ^1.0.0
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

## 🗺️ Roadmap

Future releases will include:

- 🥧 Pie & Donut charts
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

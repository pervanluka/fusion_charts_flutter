import 'dart:ui';

import 'package:fusion_charts_flutter/src/rendering/engine/fusion_render_context.dart';

import '../layers/fusion_render_layer.dart';

/// Implements a multi-layer rendering system with proper clipping,
/// anti-aliasing, and performance optimizations.
///
/// ## Architecture
///
/// Pipeline Flow:
/// 1. Setup Context
/// 2. Background Layer
/// 3. Grid Layer (clipped)
/// 4. Series Layer (clipped)
/// 5. Marker Layer
/// 6. Label Layer
/// 7. Axis Layer
/// 8. Overlay Layer (tooltips, crosshair)
///
/// ## Example
///
/// dart
/// final pipeline = FusionRenderPipeline(
///   context: renderContext,
///   layers: [
///     FusionBackgroundLayer(),
///     FusionGridLayer(),
///     FusionSeriesLayer(),
///     FusionMarkerLayer(),
///   ],
/// );
///
/// pipeline.render(canvas, size);
class FusionRenderPipeline {
  FusionRenderPipeline({required this.layers, this.enableProfiling = false});

  /// Ordered list of render layers.
  final List<FusionRenderLayer> layers;

  /// Enable performance profiling.
  final bool enableProfiling;

  /// Render statistics from last frame.
  RenderStatistics? lastFrameStats;
  // ==========================================================================
  // MAIN RENDER METHOD
  // ==========================================================================
  /// Renders all layers in sequence.
  ///
  /// This is the main entry point for the rendering pipeline.
  void render(Canvas canvas, Size size, FusionRenderContext context) {
    final stopwatch = enableProfiling ? (Stopwatch()..start()) : null;
    final layerTimes = <String, int>{};
    // Save initial canvas state
    canvas.save();

    try {
      for (final layer in layers) {
        if (!layer.enabled) continue;

        final layerStopwatch = enableProfiling ? (Stopwatch()..start()) : null;

        // Render the layer
        _renderLayer(canvas, size, context, layer);

        if (layerStopwatch != null) {
          layerTimes[layer.name] = layerStopwatch.elapsedMicroseconds;
        }
      }

      // Store statistics
      if (stopwatch != null) {
        lastFrameStats = RenderStatistics(
          totalTime: stopwatch.elapsedMicroseconds,
          layerTimes: layerTimes,
          layerCount: layers.length,
        );
      }
    } finally {
      // Restore canvas state
      canvas.restore();
    }
  }

  /// Renders a single layer with proper setup/teardown.
  void _renderLayer(
    Canvas canvas,
    Size size,
    FusionRenderContext context,
    FusionRenderLayer layer,
  ) {
    canvas.save();
    try {
      // Apply layer clipping if specified
      if (layer.clipRect != null) {
        canvas.clipRect(layer.clipRect!);
      }

      // Apply layer transform if specified
      if (layer.transform != null) {
        canvas.transform(layer.transform!.storage);
      }

      // Render the layer
      layer.paint(canvas, size, context);
    } finally {
      canvas.restore();
    }
  }

  // ==========================================================================
  // LAYER MANAGEMENT
  // ==========================================================================
  /// Adds a layer to the pipeline.
  void addLayer(FusionRenderLayer layer) {
    layers.add(layer);
  }

  /// Removes a layer from the pipeline.
  void removeLayer(String layerName) {
    layers.removeWhere((layer) => layer.name == layerName);
  }

  /// Gets a layer by name.
  FusionRenderLayer? getLayer(String name) {
    try {
      return layers.firstWhere((layer) => layer.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Enables/disables a layer.
  void setLayerEnabled(String name, bool enabled) {
    final layer = getLayer(name);
    if (layer != null) {
      layer.enabled = enabled;
    }
  }

  // ==========================================================================
  // OPTIMIZATION
  // ==========================================================================
  /// Checks if any layer needs repainting.
  bool shouldRepaint(FusionRenderPipeline oldPipeline) {
    if (layers.length != oldPipeline.layers.length) return true;
    for (int i = 0; i < layers.length; i++) {
      if (layers[i].shouldRepaint(oldPipeline.layers[i])) {
        return true;
      }
    }

    return false;
  }

  /// Invalidates cache for all layers.
  void invalidateCache() {
    for (final layer in layers) {
      layer.invalidateCache();
    }
  }

  /// Invalidates cache for specific layer.
  void invalidateLayerCache(String layerName) {
    final layer = getLayer(layerName);
    layer?.invalidateCache();
  }

  // ==========================================================================
  // PROFILING
  // ==========================================================================
  /// Gets performance report.
  String getPerformanceReport() {
    if (lastFrameStats == null) return 'No statistics available';
    final buffer = StringBuffer();
    buffer.writeln('=== Render Performance ===');
    buffer.writeln('Total: ${lastFrameStats!.totalTime}μs');
    buffer.writeln('Layers: ${lastFrameStats!.layerCount}');
    buffer.writeln('');
    buffer.writeln('Layer Breakdown:');

    for (final entry in lastFrameStats!.layerTimes.entries) {
      final percentage = (entry.value / lastFrameStats!.totalTime * 100).toStringAsFixed(1);
      buffer.writeln('  ${entry.key}: ${entry.value}μs ($percentage%)');
    }

    return buffer.toString();
  }

  /// Checks if rendering is at 60 FPS.
  bool get isRunningAt60FPS {
    if (lastFrameStats == null) return true;
    // 60 FPS = 16.67ms per frame = 16,667 microseconds
    return lastFrameStats!.totalTime < 16667;
  }
}

// ==========================================================================
// RENDER STATISTICS
// ==========================================================================
/// Statistics from a single render frame.
class RenderStatistics {
  const RenderStatistics({
    required this.totalTime,
    required this.layerTimes,
    required this.layerCount,
  });

  /// Total render time in microseconds.
  final int totalTime;

  /// Time per layer in microseconds.
  final Map<String, int> layerTimes;

  /// Number of layers rendered.
  final int layerCount;

  /// Gets FPS from render time.
  double get fps => 1000000 / totalTime;

  /// Gets render time in milliseconds.
  double get totalTimeMs => totalTime / 1000;
  @override
  String toString() {
    return 'RenderStatistics(${totalTimeMs.toStringAsFixed(2)}ms, '
        '${fps.toStringAsFixed(1)} FPS, $layerCount layers)';
  }
}

// ==========================================================================
// PIPELINE BUILDER
// ==========================================================================
/// Builder for creating rendering pipelines.
class FusionRenderPipelineBuilder {
  final List<FusionRenderLayer> _layers = [];
  bool _enableProfiling = false;

  /// Adds a layer to the pipeline.
  FusionRenderPipelineBuilder addLayer(FusionRenderLayer layer) {
    _layers.add(layer);
    return this;
  }

  /// Enables profiling.
  FusionRenderPipelineBuilder withProfiling(bool enable) {
    _enableProfiling = enable;
    return this;
  }

  /// Builds the pipeline.
  FusionRenderPipeline build() {
    return FusionRenderPipeline(layers: _layers, enableProfiling: _enableProfiling);
  }
}

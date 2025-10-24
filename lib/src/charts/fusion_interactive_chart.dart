import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../configuration/fusion_chart_configuration.dart';
import '../configuration/fusion_tooltip_configuration.dart';
import '../data/fusion_data_point.dart';
import '../rendering/fusion_coordinate_system.dart';
import '../rendering/fusion_interaction_handler.dart';
import '../series/series_with_data_points.dart';

/// State manager for interactive chart features.
///
///  Works with ANY series type that implements SeriesWithDataPoints.
///
///  Scales to infinite chart types without modification.
class FusionInteractiveChartState extends ChangeNotifier {
  FusionInteractiveChartState({
    required this.config,
    required FusionCoordinateSystem initialCoordSystem,
    required this.series,
  }) : _currentCoordSystem = initialCoordSystem,
       _originalCoordSystem = initialCoordSystem;

  final FusionChartConfiguration config;

  /// ✅ All series - works with Line, Bar, Area, Pie, Scatter, etc.
  final List<SeriesWithDataPoints> series;

  final FusionCoordinateSystem _originalCoordSystem;
  FusionCoordinateSystem _currentCoordSystem;
  FusionInteractionHandler? _interactionHandler;

  // Tooltip state
  TooltipRenderData? _tooltipData;

  // Crosshair state
  Offset? _crosshairPosition;
  FusionDataPoint? _crosshairPoint;

  // Zoom/Pan state
  bool _isPanning = false;
  bool _isZooming = false;

  // Getters
  FusionCoordinateSystem get coordSystem => _currentCoordSystem;
  TooltipRenderData? get tooltipData => _tooltipData;
  Offset? get crosshairPosition => _crosshairPosition;
  FusionDataPoint? get crosshairPoint => _crosshairPoint;
  bool get isInteracting => _isPanning || _isZooming;

  /// ✅ Get all data points from all series (works with ANY series type!)
  List<FusionDataPoint> get _allDataPoints {
    return series
        .where((s) => s.visible) // Only visible series
        .expand((s) => s.dataPoints) // Flatten all data points
        .toList();
  }

  void initialize() {
    _interactionHandler = FusionInteractionHandler(
      coordSystem: _currentCoordSystem,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onHover: _handleHover,
    );
  }

  // ========================================================================
  // TAP & HOVER HANDLING
  // ========================================================================

  void _handleTap(FusionDataPoint point, Offset position) {
    if (config.enableTooltip) {
      _showTooltip(point, position);
    }
  }

  void _handleLongPress(FusionDataPoint point, Offset position) {
    if (config.enableCrosshair) {
      _showCrosshair(position, point);
    }
  }

  void _handleHover(Offset position) {
    if (!config.enableTooltip && !config.enableCrosshair) return;

    final nearestPoint = _interactionHandler?.findNearestPoint(_allDataPoints, position);

    if (nearestPoint != null) {
      if (config.enableTooltip) {
        _showTooltip(nearestPoint, position);
      }
      if (config.enableCrosshair) {
        _showCrosshair(position, nearestPoint);
      }
    } else {
      _hideTooltip();
      _hideCrosshair();
    }
  }

  void _showTooltip(FusionDataPoint point, Offset position) {
    // ✅ Find which series this point belongs to
    final seriesInfo = _findSeriesForPoint(point);

    _tooltipData = TooltipRenderData(
      point: point,
      seriesName: seriesInfo.name,
      seriesColor: seriesInfo.color,
      screenPosition: _currentCoordSystem.dataToScreen(point),
    );
    notifyListeners();

    // Auto-hide after duration
    if (!config.tooltipBehavior.shouldAlwaysShow) {
      Future.delayed(config.tooltipBehavior.duration, () {
        _hideTooltip();
      });
    }
  }

  /// ✅ CLEAN: Single loop works for ALL series types
  SeriesWithDataPoints _findSeriesForPoint(FusionDataPoint point) {
    for (final s in series) {
      // Check if this point exists in this series
      final exists = s.dataPoints.any((p) => p.x == point.x && p.y == point.y);

      if (exists) {
        return s;
      }
    }

    // Fallback (shouldn't happen)
    return series.first;
  }

  void _hideTooltip() {
    if (_tooltipData != null) {
      _tooltipData = null;
      notifyListeners();
    }
  }

  void _showCrosshair(Offset position, FusionDataPoint? snappedPoint) {
    _crosshairPosition = position;
    _crosshairPoint = snappedPoint;
    notifyListeners();
  }

  void _hideCrosshair() {
    if (_crosshairPosition != null) {
      _crosshairPosition = null;
      _crosshairPoint = null;
      notifyListeners();
    }
  }

  // ========================================================================
  // PAN HANDLING (unchanged)
  // ========================================================================

  void _handlePanStart(Offset position) {
    if (!config.enablePanning) return;
    _isPanning = true;
    notifyListeners();
  }

  void _handlePanUpdate(Offset delta) {
    if (!config.enablePanning || !_isPanning) return;

    // Extract individual bounds from current coordinate system
    final currentXMin = _currentCoordSystem.dataXMin;
    final currentXMax = _currentCoordSystem.dataXMax;
    final currentYMin = _currentCoordSystem.dataYMin;
    final currentYMax = _currentCoordSystem.dataYMax;

    // Calculate panned bounds (returns named tuple)
    final newBounds = _interactionHandler!.calculatePannedBounds(
      delta, // ✅ POSITIONAL parameter
      currentXMin,
      currentXMax,
      currentYMin,
      currentYMax,
    );

    // Extract original bounds
    final originalXMin = _originalCoordSystem.dataXMin;
    final originalXMax = _originalCoordSystem.dataXMax;
    final originalYMin = _originalCoordSystem.dataYMin;
    final originalYMax = _originalCoordSystem.dataYMax;

    // Constrain bounds (returns named tuple)
    final constrainedBounds = _interactionHandler!.constrainBounds(
      newBounds.xMin, // ✅ POSITIONAL parameters
      newBounds.xMax,
      newBounds.yMin,
      newBounds.yMax,
      originalXMin,
      originalXMax,
      originalYMin,
      originalYMax,
    );

    // Update coordinate system using named tuple
    _currentCoordSystem = FusionCoordinateSystem(
      chartArea: _currentCoordSystem.chartArea,
      dataXMin: constrainedBounds.xMin,
      dataXMax: constrainedBounds.xMax,
      dataYMin: constrainedBounds.yMin,
      dataYMax: constrainedBounds.yMax,
    );

    notifyListeners();
  }

  void _handlePanEnd() {
    _isPanning = false;
    notifyListeners();
  }

  // ========================================================================
  // ZOOM HANDLING (unchanged)
  // ========================================================================

  void _handleScaleStart(Offset focalPoint) {
    if (!config.enableZoom) return;
    _isZooming = true;
    notifyListeners();
  }

  void _handleScaleUpdate(double scaleFactor, Offset focalPoint) {
    if (!config.enableZoom || !_isZooming) return;

    // Extract current bounds
    final currentXMin = _currentCoordSystem.dataXMin;
    final currentXMax = _currentCoordSystem.dataXMax;
    final currentYMin = _currentCoordSystem.dataYMin;
    final currentYMax = _currentCoordSystem.dataYMax;

    // Calculate zoomed bounds (returns named tuple)
    final newBounds = _interactionHandler!.calculateZoomedBounds(
      scaleFactor, // ✅ POSITIONAL parameters
      focalPoint,
      currentXMin,
      currentXMax,
      currentYMin,
      currentYMax,
    );

    // Extract original bounds for constraints
    final originalXMin = _originalCoordSystem.dataXMin;
    final originalXMax = _originalCoordSystem.dataXMax;
    final originalYMin = _originalCoordSystem.dataYMin;
    final originalYMax = _originalCoordSystem.dataYMax;

    // Constrain bounds (returns named tuple)
    final constrainedBounds = _interactionHandler!.constrainBounds(
      newBounds.xMin, // ✅ POSITIONAL parameters
      newBounds.xMax,
      newBounds.yMin,
      newBounds.yMax,
      originalXMin,
      originalXMax,
      originalYMin,
      originalYMax,
    );

    // Update coordinate system using named tuple
    _currentCoordSystem = FusionCoordinateSystem(
      chartArea: _currentCoordSystem.chartArea,
      dataXMin: constrainedBounds.xMin,
      dataXMax: constrainedBounds.xMax,
      dataYMin: constrainedBounds.yMin,
      dataYMax: constrainedBounds.yMax,
    );

    notifyListeners();
  }

  void _handleScaleEnd() {
    _isZooming = false;
    notifyListeners();
  }

  // ========================================================================
  // RESET (unchanged)
  // ========================================================================

  void reset() {
    _currentCoordSystem = _originalCoordSystem;
    _hideTooltip();
    _hideCrosshair();
    notifyListeners();
  }

  // ========================================================================
  // GESTURE RECOGNIZERS (unchanged)
  // ========================================================================

  Map<Type, GestureRecognizerFactory> getGestureRecognizers() {
    final recognizers = <Type, GestureRecognizerFactory>{};

    if (config.enableTooltip || config.enableSelection) {
      recognizers[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(() => TapGestureRecognizer(), (
            recognizer,
          ) {
            recognizer.onTapDown = (details) {
              _interactionHandler?.handleTapDown(details.localPosition, _allDataPoints);
            };
          });
    }

    if (config.enableCrosshair) {
      recognizers[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(),
            (recognizer) {
              recognizer.onLongPressStart = (details) {
                _interactionHandler?.handleLongPress(details.localPosition, _allDataPoints);
              };
            },
          );
    }

    if (config.enableZoom && config.enablePanning) {
      recognizers[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(),
            (recognizer) {
              recognizer
                ..onStart = (details) {
                  _interactionHandler?.handleScaleStart(details.localFocalPoint);
                }
                ..onUpdate = (details) {
                  _interactionHandler?.handleScaleUpdate(details.scale, details.localFocalPoint);
                }
                ..onEnd = (details) {
                  _interactionHandler?.handleScaleEnd();
                };
            },
          );
    } else if (config.enablePanning) {
      recognizers[PanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(() => PanGestureRecognizer(), (
            recognizer,
          ) {
            recognizer
              ..onStart = (details) {
                _interactionHandler?.handlePanStart(details.localPosition);
              }
              ..onUpdate = (details) {
                _interactionHandler?.handlePanUpdate(details.delta);
              }
              ..onEnd = (details) {
                _interactionHandler?.handlePanEnd();
              };
          });
    }

    return recognizers;
  }

  @override
  void dispose() {
    _interactionHandler = null;
    super.dispose();
  }
}

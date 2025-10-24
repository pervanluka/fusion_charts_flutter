import 'dart:async';

import '../core/validation/data_validator.dart';
import '../core/validation/null_handler.dart';
import '../data/fusion_data_point.dart';
import 'lttb_downsampler.dart';

/// Standard in-memory data source for charts.
///
/// Provides a reactive data source that:
/// - Validates data automatically
/// - Handles null values
/// - Downsamples large datasets
/// - Notifies listeners on changes
/// - Supports CRUD operations
///
/// ## Example:
///
/// ```dart
/// final dataSource = ListDataSource(
///   data: myDataPoints,
///   autoValidate: true,
///   autoDownsample: true,
/// );
///
/// // Listen to changes
/// dataSource.dataStream.listen((data) {
///   chart.updateData(data);
/// });
///
/// // Add new data
/// dataSource.addData(newPoint);
/// ```
class ListDataSource {
  /// Creates a list data source.
  ListDataSource({
    List<FusionDataPoint>? data,
    this.autoValidate = true,
    this.autoDownsample = true,
    this.downsampleThreshold = 10000,
    this.downsampleTarget = 500,
    this.validator,
    this.nullHandler,
    this.downsampler,
  }) : _originalData = data ?? [] {
    _processData();
  }

  /// Whether to automatically validate data.
  final bool autoValidate;

  /// Whether to automatically downsample large datasets.
  final bool autoDownsample;

  /// Number of points above which to trigger downsampling.
  final int downsampleThreshold;

  /// Target number of points after downsampling.
  final int downsampleTarget;

  /// Data validator instance.
  final DataValidator? validator;

  /// Null handler instance.
  final NullHandler? nullHandler;

  /// Downsampler instance.
  final LTTBDownsampler? downsampler;

  /// Original unprocessed data.
  List<FusionDataPoint> _originalData;

  /// Processed data (after validation and downsampling).
  List<FusionDataPoint> _processedData = [];

  /// Stream controller for data changes.
  final _dataController = StreamController<List<FusionDataPoint>>.broadcast();

  /// Validation result from last processing.
  ValidationResult? _lastValidation;

  // ==========================================================================
  // PUBLIC API
  // ==========================================================================

  /// Gets the current processed data.
  List<FusionDataPoint> get data => List.unmodifiable(_processedData);

  /// Gets the original unprocessed data.
  List<FusionDataPoint> get originalData => List.unmodifiable(_originalData);

  /// Stream of data changes.
  Stream<List<FusionDataPoint>> get dataStream => _dataController.stream;

  /// Number of processed data points.
  int get length => _processedData.length;

  /// Number of original data points.
  int get originalLength => _originalData.length;

  /// Whether data is empty.
  bool get isEmpty => _processedData.isEmpty;

  /// Whether data was downsampled.
  bool get isDownsampled => _originalData.length > _processedData.length;

  /// Last validation result.
  ValidationResult? get lastValidation => _lastValidation;

  /// Whether last validation had errors.
  bool get hasValidationErrors => _lastValidation?.hasErrors ?? false;

  // ==========================================================================
  // DATA MANIPULATION
  // ==========================================================================

  /// Sets new data, replacing existing.
  void setData(List<FusionDataPoint> data) {
    _originalData = data;
    _processData();
    _notifyListeners();
  }

  /// Adds a single data point.
  void addData(FusionDataPoint point) {
    _originalData.add(point);
    _processData();
    _notifyListeners();
  }

  /// Adds multiple data points.
  void addAllData(List<FusionDataPoint> points) {
    _originalData.addAll(points);
    _processData();
    _notifyListeners();
  }

  /// Inserts data at specific index.
  void insertData(int index, FusionDataPoint point) {
    _originalData.insert(index, point);
    _processData();
    _notifyListeners();
  }

  /// Updates data at specific index.
  void updateData(int index, FusionDataPoint point) {
    if (index >= 0 && index < _originalData.length) {
      _originalData[index] = point;
      _processData();
      _notifyListeners();
    }
  }

  /// Removes data at specific index.
  void removeDataAt(int index) {
    if (index >= 0 && index < _originalData.length) {
      _originalData.removeAt(index);
      _processData();
      _notifyListeners();
    }
  }

  /// Removes specific data point.
  void removeData(FusionDataPoint point) {
    _originalData.remove(point);
    _processData();
    _notifyListeners();
  }

  /// Clears all data.
  void clearData() {
    _originalData.clear();
    _processedData.clear();
    _lastValidation = null;
    _notifyListeners();
  }

  /// Sorts data by X value.
  void sortByX() {
    _originalData.sort((a, b) => a.x.compareTo(b.x));
    _processData();
    _notifyListeners();
  }

  /// Sorts data by Y value.
  void sortByY() {
    _originalData.sort((a, b) => a.y.compareTo(b.y));
    _processData();
    _notifyListeners();
  }

  // ==========================================================================
  // DATA PROCESSING
  // ==========================================================================

  /// Processes data through validation and downsampling pipeline.
  void _processData() {
    if (_originalData.isEmpty) {
      _processedData = [];
      _lastValidation = null;
      return;
    }

    var processedData = _originalData;

    // Step 1: Handle null values
    if (nullHandler != null) {
      processedData = nullHandler!.handle(processedData.cast<FusionDataPoint?>());
    }

    // Step 2: Validate data
    if (autoValidate) {
      final validatorInstance = validator ?? DataValidator(sortByX: true);
      _lastValidation = validatorInstance.validate(processedData);

      if (_lastValidation!.isUsable) {
        processedData = _lastValidation!.validData;
      } else {
        // Data is not usable, use empty
        processedData = [];
      }
    }

    // Step 3: Downsample if needed
    if (autoDownsample && processedData.length > downsampleThreshold) {
      final downsamplerInstance = downsampler ?? const LTTBDownsampler();
      processedData = downsamplerInstance.downsample(
        data: processedData,
        targetPoints: downsampleTarget,
      );
    }

    _processedData = processedData;
  }

  /// Notifies listeners of data changes.
  void _notifyListeners() {
    if (!_dataController.isClosed) {
      _dataController.add(_processedData);
    }
  }

  // ==========================================================================
  // QUERIES
  // ==========================================================================

  /// Gets data points within X range.
  List<FusionDataPoint> getDataInXRange(double minX, double maxX) {
    return _processedData.where((p) => p.x >= minX && p.x <= maxX).toList();
  }

  /// Gets data points within Y range.
  List<FusionDataPoint> getDataInYRange(double minY, double maxY) {
    return _processedData.where((p) => p.y >= minY && p.y <= maxY).toList();
  }

  /// Gets data point at specific X value (or nearest).
  FusionDataPoint? getDataAtX(double x) {
    if (_processedData.isEmpty) return null;

    FusionDataPoint? nearest;
    double minDistance = double.infinity;

    for (final point in _processedData) {
      final distance = (point.x - x).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearest = point;
      }
    }

    return nearest;
  }

  /// Gets statistics about the data.
  DataStatistics calculateStatistics() {
    if (_processedData.isEmpty) {
      return const DataStatistics();
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    double sumY = 0;

    for (final point in _processedData) {
      minX = minX > point.x ? point.x : minX;
      maxX = maxX < point.x ? point.x : maxX;
      minY = minY > point.y ? point.y : minY;
      maxY = maxY < point.y ? point.y : maxY;
      sumY += point.y;
    }

    final meanY = sumY / _processedData.length;

    // Calculate standard deviation
    double varianceSum = 0;
    for (final point in _processedData) {
      varianceSum += (point.y - meanY) * (point.y - meanY);
    }
    final stdDevY = (varianceSum / _processedData.length);

    return DataStatistics(
      count: _processedData.length,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      meanY: meanY,
      stdDevY: stdDevY,
      rangeX: maxX - minX,
      rangeY: maxY - minY,
    );
  }

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  /// Reprocesses data (useful after changing settings).
  void refresh() {
    _processData();
    _notifyListeners();
  }

  /// Disposes of resources.
  void dispose() {
    _dataController.close();
  }
}

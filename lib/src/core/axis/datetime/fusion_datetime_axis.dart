// lib/src/core/axis/types/fusion_datetime_axis.dart

import 'package:flutter/material.dart';
import '../../../utils/fusion_data_formatter.dart';
import '../../enums/label_alignment.dart';
import '../base/fusion_axis_base.dart';

/// DateTime axis for displaying time-based data.
///
/// Automatically formats dates based on the time range and provides
/// smart interval calculation for time series data.
///
/// ## Example
///
/// ```dart
/// final axis = FusionDateTimeAxis(
///   min: DateTime(2024, 1, 1),
///   max: DateTime(2024, 12, 31),
///   dateFormat: DateFormat('MMM yyyy'),
///   title: 'Date',
/// );
/// ```
class FusionDateTimeAxis extends FusionAxisBase {
  /// Creates a datetime axis.
  const FusionDateTimeAxis({
    // Base properties
    super.name,
    super.title,
    super.titleStyle,
    super.opposedPosition,
    super.isInversed,

    // DateTime-specific
    this.min,
    this.max,
    this.interval,
    this.desiredIntervals = 5,
    this.dateFormat,
    this.labelAlignment = LabelAlignment.center,
  });

  /// Minimum date/time for the axis.
  final DateTime? min;

  /// Maximum date/time for the axis.
  final DateTime? max;

  /// Interval between labels in milliseconds.
  ///
  /// If null, calculated automatically based on range.
  final Duration? interval;

  /// Desired number of intervals for auto-calculation.
  final int desiredIntervals;

  /// Custom date format for labels.
  ///
  /// If null, format is chosen automatically based on time range:
  /// - Hours: 'HH:mm'
  /// - Days: 'MMM dd'
  /// - Months: 'MMM yyyy'
  /// - Years: 'yyyy'
  final DateFormat? dateFormat;

  /// Label alignment relative to tick position.
  final LabelAlignment labelAlignment;

  /// Converts DateTime to milliseconds for coordinate system.
  double dateToValue(DateTime date) {
    return date.millisecondsSinceEpoch.toDouble();
  }

  /// Converts milliseconds back to DateTime.
  DateTime valueToDate(double value) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }

  @override
  FusionDateTimeAxis copyWith({
    String? name,
    String? title,
    TextStyle? titleStyle,
    bool? opposedPosition,
    bool? isInversed,
    DateTime? min,
    DateTime? max,
    Duration? interval,
    int? desiredIntervals,
    DateFormat? dateFormat,
    LabelAlignment? labelAlignment,
  }) {
    return FusionDateTimeAxis(
      name: name ?? this.name,
      title: title ?? this.title,
      titleStyle: titleStyle ?? this.titleStyle,
      opposedPosition: opposedPosition ?? this.opposedPosition,
      isInversed: isInversed ?? this.isInversed,
      min: min ?? this.min,
      max: max ?? this.max,
      interval: interval ?? this.interval,
      desiredIntervals: desiredIntervals ?? this.desiredIntervals,
      dateFormat: dateFormat ?? this.dateFormat,
      labelAlignment: labelAlignment ?? this.labelAlignment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FusionDateTimeAxis &&
        other.name == name &&
        other.title == title &&
        other.min == min &&
        other.max == max &&
        other.interval == interval &&
        other.desiredIntervals == desiredIntervals &&
        other.labelAlignment == labelAlignment;
  }

  @override
  int get hashCode =>
      Object.hash(name, title, min, max, interval, desiredIntervals, labelAlignment);

  @override
  String toString() => 'FusionDateTimeAxis(min: $min, max: $max)';
}

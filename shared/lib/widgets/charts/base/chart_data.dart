import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum AnimState {
  incoming, staying, outgoing
}

typedef SeriesColorBuilder<T> = dynamic Function(T? value, int index);

abstract class ChartLifecycleObject {
  /// A unique id representing this [ChartLifecycleObject].
  /// Needed to be able to detect changes and animate between them.
  dynamic id;
  final bool _hasId;
  ChartLifecycleObject([
    this._hasId = false,
    this.id,
  ]);

  AnimState state = AnimState.staying;

  bool get isIncoming => _hasId && hasId && state == AnimState.incoming;
  set isIncoming(bool value) => value ? state = AnimState.incoming : state = state;
  bool get isOutgoing => _hasId && hasId && state == AnimState.outgoing;
  set isOutgoing(bool value) => value ? state = AnimState.outgoing : state = state;
  bool get isStaying => _hasId && !hasId || state == AnimState.staying;
  set isStaying(bool value) => value ? state = AnimState.staying : state = state;

  bool get hasId => id != null;

  double getFraction(double v) =>
      lerpDouble(0, 1, isOutgoing ? 1.0 - v : isIncoming ? v : 1.0);
}

/// The base class for the state of a [Chart].
///
/// Every chart should have its own Data class to hold its state
/// to be able to lerp between them and thus animate the changes.
abstract class ChartData<T> {
  ChartData<T> scaleTo(ChartData<T>? end, double t);
}

/// The base class for a Series in a [Chart].
///
/// A Series holds a data set for a [Chart] and how it is visualized.
abstract class Series<T> extends ChartLifecycleObject {
  final String? label;

  Series({
    /// A unique id representing this [LineSeries].
    /// Needed to be able to detect changes and animate between them.
    required dynamic id,
    required this.label,
  }) : super(true, id);
}

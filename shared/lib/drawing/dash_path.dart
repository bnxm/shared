import 'dart:ui';

import 'package:shared/shared.dart';

/// Creates a new path that is drawn from the segments of `source`.
///
/// Dash intervals are controled by the `dashArray` - see [DashPattern]
/// for examples.
///
/// `dashOffset` specifies an initial starting point for the dashing.
///
/// Passing in a null `source` will result in a null result.  Passing a `source`
/// that is an empty path will return an empty path.
Path? dashPath(
  Path? source, {
  required List<double> pattern,
  DashOffset? dashOffset,
}) {
  final dashArray = DashPattern(pattern);
  
  if (source == null || dashArray.isZero) return source;
  dashOffset ??= const DashOffset.absolute(0.0);

  final dest = Path();
  for (final metric in source.computeMetrics()) {
    double distance = dashOffset._calculate(metric.length);
    bool draw = true;
    while (distance < metric.length) {
      final double len = dashArray.next;
      if (draw) {
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      draw = !draw;
    }
  }

  return dest;
}

enum _DashOffsetType { Absolute, Percentage }

/// Specifies the starting position of a dash array on a path, either as a
/// percentage or absolute value.
///
/// The internal value will be guaranteed to not be null.
class DashOffset {
  /// Create a DashOffset that will be measured as a percentage of the length
  /// of the segment being dashed.
  ///
  /// `percentage` will be clamped between 0.0 and 1.0; null will be converted
  /// to 0.0.
  DashOffset.percentage(double percentage)
      : _rawVal = percentage.clamp(0.0, 1.0),
        _dashOffsetType = _DashOffsetType.Percentage;

  /// Create a DashOffset that will be measured in terms of absolute pixels
  /// along the length of a [Path] segment.
  ///
  /// `start` will be coerced to 0.0 if null.
  const DashOffset.absolute(double start)
      : _rawVal = start,
        _dashOffsetType = _DashOffsetType.Absolute;

  final double _rawVal;
  final _DashOffsetType _dashOffsetType;

  double _calculate(double length) {
    return _dashOffsetType == _DashOffsetType.Absolute ? _rawVal : length * _rawVal;
  }
}

/// A circular array of dash offsets and lengths.
///
/// For example, the array `[5, 10]` would result in dashes 5 pixels long
/// followed by blank spaces 10 pixels long.  The array `[5, 10, 5]` would
/// result in a 5 pixel dash, a 10 pixel gap, a 5 pixel dash, a 5 pixel gap,
/// a 10 pixel dash, etc.
///
/// Note that this does not quite conform to an [Iterable<T>], because it does
/// not have a moveNext.
class DashPattern {
  final List<double> _values;
  DashPattern(this._values);

  int _idx = 0;

  double get next {
    if (_idx >= _values.length) _idx = 0;
    return _values[_idx++];
  }

  bool get isZero {
    if (_values.isEmpty) {
      return true;
    }

    bool onlyZero = true;
    for (final v in _values) {
      if (v != 0.0) {
        onlyZero = false;
        break;
      }
    }
    return onlyZero;
  }

  int get length => _values.length;

  static DashPattern? lerp(DashPattern? a, DashPattern? b, double v) {
    final List<double> result = [];
    a ??= DashPattern([0, 0]);
    if (b == null) return null;

    for (var i = 0; i < b._values.length; i++) {
      final value = b._values[i];
      if (i < a._values.length) {
        result.add(
          lerpDouble(a._values[i], value, v)!,
        );
      } else {
        result.add(
          lerpDouble(0, value, v)!,
        );
      }
    }

    return DashPattern(result);
  }

  @override
  String toString() => 'DashPattern _values: $_values';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DashPattern && o._values == _values;
  }

  @override
  int get hashCode => _values.hashCode;
}

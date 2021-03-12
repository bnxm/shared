import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

List<Color> applyOpacity(List<Color> colors, double factor) {
  final list = List<Color>.from(colors);
  return list.map((color) => color.withOpacity(color.opacity * factor)).toList();
}

bool areAllTransparent(List<Color> colors) {
  if (colors == null) return false;

  for (final color in colors) {
    if (color != Colors.transparent) return false;
  }
  return true;
}

enum ChartAxis {
  x,
  y,
}

class ChartValue {
  double? x;
  double? y;
  ChartValue(
    dynamic x, [
    dynamic y,
  ]) {
    if (x is num) this.x = x.toDouble();
    if (y is num) this.y = y.toDouble();
    if (x is DateTime) this.x = x.millisecondsSinceEpoch.toDouble();
    if (y is DateTime) this.y = y.millisecondsSinceEpoch.toDouble();
  }

  static List<ChartValue> lerpAll(List<ChartValue> a, List<ChartValue> b, double v) {
    List<ChartValue> values = [];

    if (a.isEmpty) {
      values = b;
    } else if (b.isEmpty) {
      values = [];
    } else {
      for (var i = 0; i < b.length; i++) {
        if (i < a.length) {
          values.add(ChartValue.lerp(a[i], b[i], v));
        } else {
          values.add(ChartValue.lerp(a.last, b[i], v));
        }
      }
    }

    return values;
  }

  static ChartValue lerp(ChartValue a, ChartValue b, double v) {
    return ChartValue(
      lerpDouble(a.x!, b.x!, v),
      lerpDouble(a.y!, b.y!, v),
    );
  }

  static D domainOfX<D>(double value) {
    if (D.toString() == 'int') return value.toInt() as D;
    if (D.toString() == 'double') return value.toDouble() as D;
    if (D.toString() == 'num') return value as D;
    if (D.toString() == 'DateTime') {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt()) as D;
    }

    return value as D;
  }

  ChartValue copyWith({
    double? x,
    double? y,
  }) {
    return ChartValue(
      x ?? this.x,
      y ?? this.y,
    );
  }

  @override
  String toString() => 'GraphValue x: $x, y: $y';
}

class ListChanges<T> {
  final List<T> added;
  final List<T> stayed;
  final List<T> removed;
  ListChanges({
    this.added = const [],
    this.stayed = const [],
    this.removed = const [],
  });
}

ListChanges<T> detectChanges<T>(List<T> a, List<T> b, [bool Function(T, T)? predicate]) {
  if (b == null) return ListChanges(removed: a);
  if (a == null) return ListChanges(added: b);

  final List<T> added = [];
  final List<T> stayed = [];
  final List<T> removed = [];

  bool areEqual(T t1, T t2) => predicate?.call(t1, t2) ?? t1 == t2;

  for (final n in b) {
    for (final o in a) {
      if (areEqual(o, n)) {
        stayed.add(n);
        break;
      }
    }
  }

  for (final n in b) {
    bool contains = false;
    for (final s in stayed) {
      if (areEqual(n, s)) {
        contains = true;
        break;
      }
    }

    if (!contains) added.add(n);
  }

  for (final o in a) {
    bool contains = false;
    for (final s in stayed) {
      if (areEqual(o, s)) {
        contains = true;
        break;
      }
    }

    if (!contains) removed.add(o);
  }

  return ListChanges(
    added: added,
    stayed: stayed,
    removed: removed,
  );
}

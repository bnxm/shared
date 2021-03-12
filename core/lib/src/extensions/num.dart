import 'dart:math' as math;

import 'package:intl/intl.dart';

extension NumExtensions<T extends num> on T {
  T get neg => (isNegative ? this * -1 : this) as T;

  T atLeast(T value) => math.max(this, value);

  T atMost(T value) => math.min(this, value);

  bool isBetween(num lower, num upper) => this >= lower && this <= upper;

  String format([String? pattern]) => NumberFormat(pattern).format(this);

  T swapSign() => this * -1 as T;

  T wrapAt(T min, T max) {
    if (this < min) {
      return max - (min - this) as T;
    } else if (this > max) {
      return min + (this - max) as T;
    } else {
      return this;
    }
  }

  double get radians => this * (math.pi / 180.0);
  double get degrees => this * (180.0 / math.pi);

  double root(num exp) => (math.pow(this, 1 / exp) * 1E+9).round() / 1E+9;
  double get cbrt => root(3);
}

extension IntExtensions on int {
  List<int> to(int to) {
    assert(this >= 0 && to >= 0);

    final length = (this - to).abs() + 1;
    if (this <= to) {
      return List.generate(length, (i) => this + i);
    } else {
      return List.generate(length, (i) => this - i);
    }
  }

  List<int> until(int until) {
    final range = to(until);
    if (range.isEmpty) {
      return range;
    } else if (this > until) {
      return range..removeAt(0);
    } else {
      return range..removeLast();
    }
  }

  String get hex => '#${toRadixString(16).toUpperCase()}';
}

extension DoubleExtensions on double {
  double get half => this / 2.0;

  double roundToPrecision(double precision) {
    final mod = math.pow(10.0, precision);
    return (this * mod).round().toDouble() / mod;
  }
}



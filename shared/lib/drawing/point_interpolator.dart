import 'dart:math' as math;

import 'package:flutter/material.dart';

class Points {
  static List<Offset?> lerp(List<Offset> from, List<Offset> to, double value) {
    final List<Offset?> values = [];
    if (from.isEmpty && to.isEmpty) {
      return values;
    }

    final grew = from.length < to.length;
    final min = math.max(math.min(from.length, to.length), 0);
    final max = math.max(from.length, to.length);

    void add(Offset a, Offset b) {
      values.add(Offset.lerp(a, b, value));
    }

    for (var i = 0; i < max; i++) {
      if ( from.isEmpty &&  to.isNotEmpty) {
        add(Offset(to[i].dx, 0), to[i]);
      } else if ( to.isEmpty &&  from.isNotEmpty) {
        add(from[i], Offset(from[i].dx, 0));
      } else if (i < min) {
        add(from[i], to[i]);
      } else if (grew) {
        add(from[min - 1], to[i]);
      } else {
        add(from[i], to[min - 1]);
      }
    }

    // Remove duplicates. When this list has a length of one, return this list
    // meaning that the points shall be represented by a point rather than a curve.
    final List<Offset?> distinct = [];
    for (final value in values) {
      if (!distinct.contains(value)) distinct.add(value);
    }

    return distinct.length == 1 ? distinct : values;
  }
}

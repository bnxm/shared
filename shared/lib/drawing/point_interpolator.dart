import 'dart:math' as math;

import 'package:flutter/material.dart';

class Points {
  static List<Offset> lerp(List<Offset> from, List<Offset> to, double value) {
    final List<Offset> values = [];
    if ((from == null && to == null) || (from.isEmpty && to.isEmpty)) {
      return values;
    }

    final grew = (from?.length ?? 0) < (to?.length ?? 0);
    final min = math.max(math.min(from?.length ?? 0, to?.length ?? 0), 0);
    final max = math.max(from?.length ?? 0, to?.length ?? 0);

    void add(Offset a, Offset b) {
      values.add(Offset.lerp(a, b, value));
    }

    for (var i = 0; i < max; i++) {
      if ((from == null || from.isEmpty) && (to != null && to.isNotEmpty)) {
        add(Offset(to[i].dx, 0), to[i]);
      } else if ((to == null || to.isEmpty) && (from != null && from.isNotEmpty)) {
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
    final List<Offset> distinct = [];
    for (final value in values) {
      if (!distinct.contains(value)) distinct.add(value);
    }

    return distinct.length == 1 ? distinct : values;
  }
}

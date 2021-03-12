import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

export 'base_painter.dart';
export 'dash_path.dart';
export 'path.dart';
export 'point_interpolator.dart';
export 'pressure_path.dart';

List<Color>? dynamicToColors(dynamic color, [bool gradient = false]) {
  if (color is List && color.isEmpty) return <Color>[];

  assert(
    color == null ||
        (color is Color || color is List<Color> || color is SeriesColorBuilder),
    'Only Color, List<Color>, or SeriesColorBuilder are supported color values. ${color.runtimeType} is not.',
  );

  if (color != null) {
    if (color is List<Color>) {
      final List<Color> colors = List.from(color);
      if (colors.length <= 1 && gradient) {
        for (var i = 0; i < (2 - colors.length); i++) {
          colors.add(colors[0]);
        }
      }

      return colors;
    } else if (color is Color) {
      return [color, color];
    }
  }

  return null;
}

List<Color> lerpColors(List<Color>? a, List<Color>? b, double v) {
  if (a == null && b != null) return b;
  if (a == null || b == null) return [];

  final List<Color> result = [];

  for (var i = 0; i < max(a.length, b.length); i++) {
    final start = a.getOrNull(i);
    final end = b.getOrNull(i);
    result.add(Color.lerp(start, end, v)!);
  }

  return result;
}

List<double> calculateColorStops(List<Color> colors) {
  if (colors.length == 2) return [0.0, 1.0];

  int i = 0;
  return colors.map((_) => (1 / (colors.length - 1)) * i++).toList();
}

Pair<double, double> calcMaxMin(List<num> values) {
  double max = double.minPositive;
  double min = double.maxFinite;

  for (final value in values) {
    if (value > max) max = value.toDouble();
    if (value < min) min = value.toDouble();
  }

  return Pair(max, min);
}

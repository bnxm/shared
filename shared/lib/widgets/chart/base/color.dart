import 'dart:math';

import 'package:collection/collection.dart';
import 'package:shared/shared.dart';
import 'package:flutter/material.dart';

typedef SeriesColorBuilder<T> = dynamic Function(T value, int index);

class Gradient extends DelegatingList<Color> {
  Gradient(dynamic gradient)
      : super(
          _parse(gradient),
        );

  bool get isOpaque => any((color) => color.opacity > 0);

  static Gradient from(dynamic gradient) {
    if (gradient is Gradient) {
      return gradient;
    } else {
      return Gradient(gradient);
    }
  }

  static List<Color> _parse(dynamic gradient) {
    if (gradient is List<Color>) {
      assert(gradient.isNotEmpty);

      if (gradient.length == 1) {
        return [gradient.first, gradient.first];
      } else {
        return gradient;
      }
    } else if (gradient is Color) {
      return [gradient, gradient];
    } else {
      throw ArgumentError('${gradient.runtimeType} is not supported');
    }
  }

  Gradient scaleTo(Gradient b, double t) {
    final colors = [
      for (var i = 0; i < max(length, b.length); i++)
        Color.lerp(getOrElse(i, last), b.getOrElse(i, b.last), t)!,
    ];

    return Gradient(colors);
  }
}

extension ListGradientExtension on List<Gradient> {
  List<Gradient> scaleTo(List<Gradient> b, double t) {
    return [
      for (var i = 0; i < max(length, b.length); i++)
        getOrElse(i, last).scaleTo(b.getOrElse(i, b.last), t),
    ];
  }

  bool get isOpaque => any((gradient) => gradient.isOpaque);
}

class Gradients {
  static List<Gradient>? from<T>(dynamic builder, List<T> data) {
    if (builder is List<Gradient>) {
      return builder;
    } else if (builder is SeriesColorBuilder) {
      return [
        for (var i = 0; i < data.length; i++)
          Gradient.from(
            builder(data[i], i),
          ),
      ];
    } else {
      return [
        for (final _ in data)
          Gradient.from(
            builder,
          ),
      ];
    }
  }
}

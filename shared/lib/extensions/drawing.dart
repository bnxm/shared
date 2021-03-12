import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared/drawing/drawing.dart';

extension PathExtensions on Path {
  ui.Tangent? fractionalTangent(double x) {
    final metrics = computeMetrics().first;
    return metrics.getTangentForOffset(x.clamp(0.0, 1.0) * metrics.length);
  }

  Offset fractionalOffset(double x) => fractionalTangent(x)?.position ?? Offset.zero;

  Offset offsetForFractionalDx(double dx, [double margin = 1]) {
    final metrics = computeMetrics().first;
    assert(!metrics.isClosed);

    Offset fractionalOffset(double x) {
      return metrics.getTangentForOffset(x * metrics.length)!.position;
    }

    final bounds = getBounds();
    final width = bounds.width;
    final aim = bounds.left + (width * dx);

    double nextFraction = 0.0;
    double approachedOffset = 0.0;

    int i = 0;

    while ((approachedOffset - aim).abs() > margin) {
      i++;
      final offset = fractionalOffset(nextFraction).dx;
      final diff = (aim - offset) / width;
      nextFraction += diff;

      if (i > 1 && offset == approachedOffset) break;

      approachedOffset = offset;
      if (i > 100) break;
    }

    return this.fractionalOffset(nextFraction);
  }

  Offset absoluteOffset(double x) {
    final metrics = computeMetrics().first;
    final b = getBounds();
    return metrics
            .getTangentForOffset(
                ((x - b.left) / b.width).clamp(0.0, 1.0) * metrics.length)
            ?.position ??
        Offset.zero;
  }

  Path trim(double from, double? to, {bool isFractional = true}) {
    final metrics = computeMetrics().toList();
    final bounds = getBounds();

    double? toFractional(double? value) {
      if (isFractional) return value;

      return ((value! - bounds.left) / bounds.width).clamp(0.0, 1.0);
    }

    if (metrics.isEmpty) {
      return this;
    }

    final metric = metrics.first;
    final length = metric.length;

    return metric.extractPath(
      toFractional(from)! * length,
      toFractional(to)! * length,
    );
  }
}

extension CanvasExtension on Canvas {
  void drawPressurePath(
    Path path,
    Paint paint,
    List<PressureStop> stops,
  ) {
    PressurePath(
      path,
      stops,
    ).draw(
      this,
      paint,
    );
  }

  void drawDashPath(
    Path source,
    Paint paint, {
    required List<double> pattern,
    DashOffset? dashOffset,
  }) {
    final path = dashPath(source, pattern: pattern, dashOffset: dashOffset)!;
    drawPath(path, paint);
  }
}

extension PaintExtension on Paint {
  set fill(bool value) => style = value ? PaintingStyle.fill : PaintingStyle.stroke;

  Paint blur(
    double? radius, {
    BlurStyle style = BlurStyle.normal,
  }) =>
      this
        ..maskFilter =
            radius == null || radius == 0 ? null : MaskFilter.blur(style, radius);

  Paint setShader(dynamic rect, List<Color>? colors, {List<double>? stops, bool? vertical}) {
    assert(rect is RRect || rect is Rect);
    late Offset start;
    late Offset end;

    final v = vertical ?? rect.width < rect.height;

    if (rect is Rect) {
      start = v ? rect.topCenter : rect.centerLeft;
      end = v ? rect.bottomCenter : rect.centerRight;
    } else if (rect is RRect) {
      start = v ? rect.topCenter : rect.centerLeft;
      end = v ? rect.bottomCenter : rect.centerRight;
    }

    return this
      ..shader = linearGradient(
        colors,
        start,
        end,
        stops: stops,
      );
  }

  ui.Gradient linearGradient(
    dynamic colors,
    Offset from,
    Offset to, {
    List<double>? stops,
    ui.TileMode tileMode = ui.TileMode.clamp,
  }) {
    final finalColors = dynamicToColors(colors, true)!;
    final finalStops = stops ?? calculateColorStops(finalColors);

    return ui.Gradient.linear(
      from,
      to,
      finalColors,
      finalStops,
      tileMode,
    );
  }
}

extension RRectExtensions on RRect {
  Offset get topCenter => Offset(center.dx, top);
  Offset get topLeft => Offset(left, top);
  Offset get topRight => Offset(right, top);
  Offset get bottomCenter => Offset(center.dx, bottom);
  Offset get bottomLeft => Offset(left, bottom);
  Offset get bottomRight => Offset(right, bottom);
  Offset get centerRight => Offset(right, center.dy);
  Offset get centerLeft => Offset(left, center.dy);

  Rect get rect => Rect.fromLTRB(left, top, right, bottom);

  RRect translate({double dx = 0.0, double dy = 0.0}) {
    return RRect.fromLTRBAndCorners(
      left + dx,
      top + dy,
      right + dx,
      bottom + dy,
      topLeft: tlRadius,
      topRight: trRadius,
      bottomLeft: blRadius,
      bottomRight: brRadius,
    );
  }

  RRect copyWith(
      {Rect? r, double? bottomRight, double? bottomLeft, double? topLeft, double? topRight}) {
    return RRect.fromRectAndCorners(
      r ?? rect,
      bottomLeft: bottomLeft != null ? Radius.circular(bottomLeft) : blRadius,
      bottomRight: bottomRight != null ? Radius.circular(bottomRight) : brRadius,
      topLeft: topLeft != null ? Radius.circular(topLeft) : tlRadius,
      topRight: topRight != null ? Radius.circular(topRight) : trRadius,
    );
  }
}

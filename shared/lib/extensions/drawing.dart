import 'dart:ui' as ui;

import 'package:shared/shared.dart';
import 'package:flutter/material.dart' hide Gradient;
import 'package:shared/drawing/drawing.dart';
import 'package:shared/widgets/chart/base/color.dart';

extension PathExtensions on Path {
  ui.Tangent? relativeTangentAt(double x) {
    final metrics = computeMetrics().first;
    return metrics.getTangentForOffset(x.clamp(0.0, 1.0) * metrics.length);
  }

  Offset relativeOffsetAt(double x) => relativeTangentAt(x)?.position ?? Offset.zero;

  Offset offsetForDx(double dx, [double margin = 1]) {
    final metrics = computeMetrics().first;
    final left = getBounds().left;

    var lower = 0.0, upper = 1.0, aim = 0.0;
    var offset = Offset.zero;

    dx += left;
    int i = 0;
    while ((aim - dx).abs() > margin) {
      final f = lerpDouble(lower, upper, 0.5)!;
      offset = metrics.getTangentForOffset(f * metrics.length)!.position;
      aim = offset.dx + (left.isNegative ? left : 0);

      if (dx < aim) {
        upper = f;
      } else if (dx > aim) {
        lower = f;
      } else {
        break;
      }

      if (i > 100) break;
      i++;
    }

    return offset;
  }

  Offset offsetForRelativeDx(double dx, [double margin = 1]) {
    return offsetForDx(getBounds().width * dx, margin);
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

  Paint setShader(
    dynamic rect,
    List<Color>? colors, {
    List<double>? stops,
    bool? vertical,
  }) {
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
    colors = Gradient.from(colors);
    stops ??= (colors as List).imap((i, item) => i * (1 / (colors.length - 1)));

    return ui.Gradient.linear(
      from,
      to,
      colors,
      stops,
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
      {Rect? r,
      double? bottomRight,
      double? bottomLeft,
      double? topLeft,
      double? topRight}) {
    return RRect.fromRectAndCorners(
      r ?? rect,
      bottomLeft: bottomLeft != null ? Radius.circular(bottomLeft) : blRadius,
      bottomRight: bottomRight != null ? Radius.circular(bottomRight) : brRadius,
      topLeft: topLeft != null ? Radius.circular(topLeft) : tlRadius,
      topRight: topRight != null ? Radius.circular(topRight) : trRadius,
    );
  }
}

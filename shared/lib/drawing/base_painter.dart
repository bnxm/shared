import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

abstract class BasePainter extends CustomPainter {
  late Canvas canvas;
  late Size size;

  double get width => size.width;
  double get height => size.height;
  double get centerX => width / 2;
  double get centerY => height / 2;
  Offset get center => Offset(centerX, centerY);
  Rect get drawingArea => Rect.fromLTWH(0, 0, width, height);

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void clipDrawingArea() => clip(Rect.fromLTWH(0, 0, width, height));

  void save() => canvas.save();
  void restore() => canvas.restore();

  void clip(dynamic area) {
    assert(
      area is Rect || area is RRect || area is Path || area == null,
      'Type ${area.runtimeType} is not a supported clipping type',
    );

    if (area is Rect) {
      canvas.clipRect(area);
    } else if (area is RRect) {
      canvas.clipRRect(area);
    } else if (area is Path) {
      canvas.clipPath(area);
    } else {
      canvas.clipRect(drawingArea);
    }
  }

  void rotate(double radians, {Offset? center}) {
    center ??= this.center;
    canvas
      ..translate(center.dx, center.dy)
      ..rotate(radians)
      ..translate(-center.dx, -center.dy);
  }

  Path drawPath(
    Path? path,
    Paint paint, {
    List<double>? dashPattern,
    DashOffset? dashOffset,
  }) {
    final p = dashPattern == null
        ? path!
        : dashPath(
            path,
            pattern: dashPattern,
            dashOffset: dashOffset,
          )!;

    canvas.drawPath(p, paint);
    return p;
  }

  void drawRect(Rect rect, Paint paint) {
    canvas.drawRect(rect, paint);
  }

  void drawShadow(
    Path path,
    Color color,
    double elevation, {
    bool transparentOccluder = true,
  }) {
    canvas.drawShadow(
      path,
      color,
      elevation,
      transparentOccluder,
    );
  }

  RRect drawRRect(
    dynamic rect,
    Paint paint, {
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    double all = 0.0,
    BorderRadius? borderRadius,
  }) {
    assert(rect is Rect || rect is RRect);

    final r = rect is Rect
        ? RRect.fromRectAndCorners(
            rect,
            topLeft: borderRadius?.topLeft ?? Radius.circular(topLeft ?? all),
            topRight: borderRadius?.topRight ?? Radius.circular(topRight ?? all),
            bottomLeft: borderRadius?.bottomLeft ?? Radius.circular(bottomLeft ?? all),
            bottomRight: borderRadius?.bottomRight ?? Radius.circular(bottomRight ?? all),
          )
        : rect;

    canvas.drawRRect(r, paint);
    return r;
  }

  TextPainter? drawText(
    TextSpan text,
    Offset position, {
    Alignment? align = Alignment.topCenter,
    double angle = 0,
    String ellipsis = '...',
    int? maxLines,
  }) {
    assert(angle == 0 || angle == 90 || angle == 180 || angle == 270);

    final painter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: ellipsis,
    )..layout();

    final w = angle == 0 || angle == 180 ? painter.width : painter.height;
    final h = angle == 0 || angle == 180 ? painter.height : painter.width;

    late Offset offset;
    if (align == Alignment.center) {
      offset = Offset(position.dx - (w / 2), position.dy - (h / 2));
    } else if (align == Alignment.centerLeft) {
      offset = Offset(position.dx, position.dy - (h / 2));
    } else if (align == Alignment.centerRight) {
      offset = Offset(position.dx - w, position.dy - (h / 2));
    } else if (align == Alignment.topLeft) {
      offset = Offset(position.dx, position.dy);
    } else if (align == Alignment.topCenter) {
      offset = Offset(position.dx - (w / 2), position.dy);
    } else if (align == Alignment.topRight) {
      offset = Offset(position.dx - w, position.dy);
    } else if (align == Alignment.bottomLeft) {
      offset = Offset(position.dx, position.dy - h);
    } else if (align == Alignment.bottomCenter) {
      offset = Offset(position.dx - (w / 2), position.dy - h);
    } else if (align == Alignment.bottomRight) {
      offset = Offset(position.dx - w, position.dy - h);
    }

    if (angle == 90) {
      offset = Offset(offset.dx + w, offset.dy);
    } else if (angle == 180) {
      offset = Offset(offset.dx + w, offset.dy + h);
    } else if (angle == 270) {
      offset = Offset(offset.dx, offset.dy + h);
    }

    if (angle != 0) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle.radians);
      painter.paint(canvas, Offset.zero);
      canvas.restore();
    } else {
      painter.paint(canvas, offset);
    }

    return painter;
  }

  Size measureText(
    TextSpan text, {
    Alignment align = Alignment.topCenter,
    int? maxLines,
    String ellipsis = '...',
  }) {
    final painter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: ellipsis,
    )..layout();
    return Size(painter.width, painter.height);
  }

  double radiusToSigma(double radius) => radius * 0.57735 + 0.5;

  void drawCircle(Offset p, double r, Paint paint) => canvas.drawCircle(p, r, paint);

  void drawLine(
    Offset a,
    Offset b,
    Paint paint, {
    List<double>? dashPattern,
    DashOffset? dashOffset,
  }) {
    if (dashPattern != null) {
      drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy),
        paint,
        dashPattern: dashPattern,
        dashOffset: dashOffset,
      );
    } else {
      canvas.drawLine(a, b, paint);
    }
  }
}

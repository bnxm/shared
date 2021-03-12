import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef PaintCallback = void Function(Canvas canvas, Size size, BuildContext context);

abstract class Painter extends StatelessWidget {
  final Size size;
  const Painter({
    Key? key,
    required this.size,
  })  : assert(size != null),
        super(key: key);

  double get width => size.width;
  double get height => size.height;
  Offset get center => Offset(width / 2, height / 2);
  double get centerX => center.dx;
  double get centerY => center.dy;

  bool get isComplex => false;
  bool get willChange => false;
  Widget? get child => null;

  void paint(Canvas canvas, Size size, BuildContext context);

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: CustomPaint(
        isComplex: isComplex,
        willChange: willChange,
        painter: _PaintWidgetPainter(paint, context),
        child: child,
      ),
    );
  }
}

class _PaintWidgetPainter extends CustomPainter {
  final PaintCallback _paint;
  final BuildContext context;
  const _PaintWidgetPainter(this._paint, this.context);

  @override
  void paint(Canvas canvas, Size size) => _paint(canvas, size, context);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

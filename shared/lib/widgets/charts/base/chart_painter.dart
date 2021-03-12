import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

abstract class ChartPainter<T, S extends ChartData<T>> extends BasePainter {
  Interaction? interaction;
  double? v;

  bool isPreDraw = false;

  void adjustData(S data) {
    isPreDraw = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    assert(v != null);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
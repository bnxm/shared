import 'dart:ui';

import 'package:flutter/material.dart';

/// Utility methods to draw various paths, especially cubic ones.
Path computeLinearCurve(List<Offset> knots) {
  final path = Path();
  for (final knot in knots) {
    if (knot == knots.first) {
      path.moveTo(knot.dx, knot.dy);
    } else {
      path.lineTo(knot.dx, knot.dy);
    }
  }

  return path;
}

Path computeBezierCurve(List<Offset> knots, {double smoothFactor = 1.0}) {
  if (knots.isEmpty) return Path();

  smoothFactor = smoothFactor.clamp(0.0, 1.0);

  if (smoothFactor == 0.0) {
    return computeLinearCurve(knots);
  }

  smoothFactor *= 0.19;

  // Credits: http://www.jayway.com/author/andersericsson/
  int si(int setSize, int i) {
    if (i > setSize - 1) {
      return setSize - 1;
    } else if (i < 0) {
      return 0;
    } else {
      return i;
    }
  }

  double thisPointX;
  double thisPointY;
  double nextPointX;
  double nextPointY;
  double startDiffX;
  double startDiffY;
  double endDiffX;
  double endDiffY;
  double firstControlX;
  double firstControlY;
  double secondControlX;
  double secondControlY;

  final res = Path();
  res.moveTo(knots.first.dx, knots.first.dy);

  for (var i = 0; i < knots.length - 1; i++) {
    thisPointX = knots[i].dx;
    thisPointY = knots[i].dy;

    nextPointX = knots[i + 1].dx;
    nextPointY = knots[i + 1].dy;

    startDiffX = nextPointX - knots[si(knots.length, i - 1)].dx;
    startDiffY = nextPointY - knots[si(knots.length, i - 1)].dy;

    endDiffX = knots[si(knots.length, i + 2)].dx - thisPointX;
    endDiffY = knots[si(knots.length, i + 2)].dy - thisPointY;

    firstControlX = thisPointX + smoothFactor * startDiffX;
    firstControlY = thisPointY + smoothFactor * startDiffY;

    secondControlX = nextPointX - smoothFactor * endDiffX;
    secondControlY = nextPointY - smoothFactor * endDiffY;

    res.cubicTo(
      firstControlX,
      firstControlY,
      secondControlX,
      secondControlY,
      nextPointX,
      nextPointY,
    );
  }

  return res;
}

class _Point {
  final double x, y;
  double dx, dy;
  _Point(
    this.x,
    this.y, [
    this.dx = 0.0,
    this.dy = 0.0,
  ]);

  _Point plus({double factor = 1.0, required _Point point}) {
    return _Point(x + factor * point.x, y + factor * point.y);
  }

  _Point minus({double factor = 1.0, required _Point point}) {
    return _Point(x - factor * point.x, y - factor * point.y);
  }

  _Point scaleBy(double factor) {
    return _Point(factor * x, factor * y);
  }

  @override
  String toString() {
    return '_EPointF x: $x, y: $y, dx: $dx, dy: $dy';
  }

  @override
  bool operator ==(Object o) {
    return o is _Point && o.x == x && o.y == y && o.dx == dx && o.dy == dy;
  }

  @override
  int get hashCode {
    return hashList([
      x,
      y,
      dx,
      dy,
    ]);
  }
}

Path computeCubicMeanCurve(List<Offset> knots) {
  final path = Path();
  final points = knots.map((k) => _Point(k.dx, k.dy)).toList();

  if (points.length >= 2) {
    late _Point prevPoint;
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      if (i == 0) {
        path.moveTo(point.x, point.y);
      } else {
        final midX = (prevPoint.x + point.x) / 2;
        final midY = (prevPoint.y + point.y) / 2;

        if (i == 1) {
          path.lineTo(midX, midY);
        } else {
          path.quadraticBezierTo(prevPoint.x, prevPoint.y, midX, midY);
        }
      }
      prevPoint = point;
    }

    path.lineTo(prevPoint.x, prevPoint.y);
  } else {
    return computeLinearCurve(knots);
  }

  return path;
}

Path computePolyBezierCurve(List<Offset> knots) {
  final nodes = knots.map((o) => _Point(o.dx, o.dy)).toList();
  final path = Path();

  if (nodes.length <= 2) {
    return computeLinearCurve(knots);
  }

  final p1 = nodes[0];
  final n = nodes.length - 1;

  path.moveTo(p1.x, p1.y);

  if (n == 1) {
    final last = nodes.last;
    path.lineTo(last.x, last.y);
  } else {
    final controllPoints = _computeControlPoints(n, nodes);

    for (var i = 0; i < n; i++) {
      final target = nodes[i + 1];
      _appendCurveToPath(path, controllPoints[i]!, controllPoints[n + i]!, target);
    }
  }

  return path;
}

List<_Point?> _computeControlPoints(int n, List<_Point> knots) {
  final List<_Point?> result = List<_Point?>.filled(n * 2, null);

  final target = _constructTargetVector(n, knots);
  final lowerDiag = _constructLowerDiagonalVector(n - 1);
  final mainDiag = _constructMainDiagonalVector(n);
  final upperDiag = _constructUpperDiagonalVector(n - 1);

  final newTarget = List<_Point?>.filled(n, null);
  final newUpperDiag = List<double?>.filled(n - 1, null);

  // forward sweep for control points c_i,0:
  newUpperDiag[0] = upperDiag[0]! / mainDiag[0]!;
  newTarget[0] = target[0]!.scaleBy(1 / mainDiag[0]!);

  for (int i = 1; i < n - 1; i++) {
    newUpperDiag[i] =
        upperDiag[i]! / (mainDiag[i]! - lowerDiag[i - 1]! * newUpperDiag[i - 1]!);
  }

  for (int i = 1; i < n; i++) {
    final double targetScale =
        1 / (mainDiag[i]! - lowerDiag[i - 1]! * newUpperDiag[i - 1]!);
    newTarget[i] = (target[i]!.minus(point: newTarget[i - 1]!.scaleBy(lowerDiag[i - 1]!)))
        .scaleBy(targetScale);
  }

  // backward sweep for control points c_i,0:
  result[n - 1] = newTarget[n - 1];

  for (int i = n - 2; i >= 0; i--) {
    result[i] = newTarget[i]!.minus(factor: newUpperDiag[i]!, point: result[i + 1]!);
  }

  // calculate remaining control points c_i,1 directly:
  for (int i = 0; i < n - 1; i++) {
    result[n + i] = knots[i + 1].scaleBy(2).minus(point: result[i + 1]!);
  }

  result[2 * n - 1] = knots[n].plus(point: result[n - 1]!).scaleBy(0.5);

  return result;
}

List<_Point?> _constructTargetVector(int n, List<_Point> knots) {
  final result = List<_Point?>.filled(n, null);

  result[0] = knots[0].plus(factor: 2, point: knots[1]);

  for (int i = 1; i < n - 1; i++) {
    result[i] = (knots[i].scaleBy(2).plus(point: knots[i + 1])).scaleBy(2);
  }

  result[result.length - 1] = knots[n - 1].scaleBy(8).plus(point: knots[n]);

  return result;
}

List<double?> _constructLowerDiagonalVector(int length) {
  final result = List<double?>.filled(length, null);

  for (int i = 0; i < result.length - 1; i++) {
    result[i] = 1.0;
  }

  result[result.length - 1] = 2.0;

  return result;
}

List<double?> _constructMainDiagonalVector(int n) {
  final result = List<double?>.filled(n, null);
  result[0] = 2.0;

  for (int i = 1; i < result.length - 1; i++) {
    result[i] = 4.0;
  }

  result[result.length - 1] = 7.0;

  return result;
}

List<double?> _constructUpperDiagonalVector(int length) {
  final result = List<double?>.filled(length, null);

  for (int i = 0; i < result.length; i++) {
    result[i] = 1.0;
  }

  return result;
}

void _appendCurveToPath(Path path, _Point control1, _Point control2, _Point targetKnot) {
  path.cubicTo(
    control1.x,
    control1.y,
    control2.x,
    control2.y,
    targetKnot.x,
    targetKnot.y,
  );
}

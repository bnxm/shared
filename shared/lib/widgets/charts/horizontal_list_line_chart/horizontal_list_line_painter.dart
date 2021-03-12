import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import 'horizontal_list_line_chart_data.dart';

class HorizontaListLinePainer<T> extends BasePainter {
  final int index;
  final bool isFirst;
  final bool isLast;
  final HorizontalListLineChartState<T> parent;
  final List<ListLineSeries<T>> allSeries;
  HorizontaListLinePainer({
    required List<ListLineSeries<T>> series,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.parent,
  }) : allSeries = List.from(series)
          ..sort(
            (a, b) => a.elevation!.compareTo(b.elevation!),
          );

  double max = minDouble;
  double min = maxDouble;
  int totalItemCount = 0;

  ListLineChartData<T>? get data => parent.value;
  double get t => parent.v;

  double get itemExtent => parent.itemExtent;
  EdgeInsets? get padding => data!.innerPadding;
  double get leftInset => isFirst ? padding!.left : 0.0;
  double get rightInset => isLast ? padding!.right : 0.0;

  HorizontalListLabelBuilder<T>? get labelBuilder => parent.widget.labelBuilder;

  Rect? shaderRect;

  late double fontHeight;
  ListLineSeries<T>? series;
  ListLineSeries<T>? prevSeries;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    _calculateExtremas();

    for (final series in allSeries) {
      this.series = series;

      if (series.labelStyle != null) {
        fontHeight = measureText(TextSpan(text: 'A', style: series.labelStyle)).height;
      }

      _findOldSeries();
      _drawSeries();
    }
  }

  void _findOldSeries() {
    for (final oldSeries in parent.prevSeries ?? allSeries) {
      if (series!.id == oldSeries.id) {
        prevSeries = oldSeries.copyWith();
      }
    }
    prevSeries ??= series!.copyWith();
  }

  void _drawSeries() {
    final paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = series!.thickness!
      ..strokeJoin = series!.strokeJoin!
      ..strokeCap = StrokeCap.square;

    final knots = _computeKnots();
    final paths = _computePaths(knots);
    final path = paths.first;
    final fillPath = paths.second;
    final computePath = paths.third;

    _computeShaderRect(path);

    final y = computePath.offsetForFractionalDx(0.5).dy;
    final prevY = computePath.fractionalOffset(0.0).dy;
    final nextY = computePath.fractionalOffset(1.0).dy;

    if (series!.hasFill) {
      _drawFill(fillPath, paint);
    }

    paint.style = PaintingStyle.stroke;

    final hasLabelBuilder = series!.labelBuilder != null || labelBuilder != null;
    if (hasLabelBuilder) {
      _drawLabel(y);
    }

    if (series!.hasDivider) {
      _drawDivider(prevY, nextY, fillPath, paint);
    }

    if (series!.hasShadow) {
      _drawShadow(path, paint);
    }

    _drawStroke(path, paint);
  }

  void _computeShaderRect(Path path) {
    final startDx = index * itemExtent;
    final fullWidth = totalItemCount * itemExtent;
    final bounds = path.getBounds();
    shaderRect = Rect.fromLTWH(-startDx, bounds.top, fullWidth, bounds.bottom);
  }

  List<Offset> _computeKnots() {
    final labelStyle = series!.labelStyle;
    final labelInset = labelStyle != null ? series!.labelSpacing! + fontHeight : 0.0;
    final h = height - (labelInset + padding!.vertical);

    double getDyForValue(double? value) {
      value ??= series!.values[index].y;

      final m = (value! - min) / (max - min);
      final dy = h - (m * h);
      return dy + padding!.top + labelInset - (series!.thickness! / 2);
    }

    final List<Offset> knots = [];
    int i = 0;
    for (final value in series!.values) {
      final isFirst = i == 0;
      final isLast = value == series!.values.last;

      final dy = getDyForValue(value.y);
      final dx = padding!.left + (i * parent.itemExtent);

      if (isFirst) knots.add(Offset(0, dy));
      knots.add(Offset(dx + ((width - (leftInset + rightInset)) / 2), dy));
      if (isLast) knots.add(Offset(dx + width, dy));

      i++;
    }

    return knots;
  }

  Triplet<Path, Path, Path> _computePaths(List<Offset> knots) {
    final dx = isFirst ? 0.0 : padding!.left + (index * parent.itemExtent);
    final shift = Offset(-dx, 0);

    final wholePath = computeBezierCurve(knots, smoothFactor: series!.smoothFactor ?? 0.0);

    final path = wholePath
        .trim(
          dx - width,
          dx + width + width,
          isFractional: false,
        )
        .shift(shift);

    final computePath = wholePath
        .trim(
          dx,
          dx + width,
          isFractional: false,
        )
        .shift(shift);

    final fillPath = Path.from(wholePath.shift(shift))
      ..lineTo(dx + width, height)
      ..lineTo(0, height)
      ..close();

    return Triplet(path, fillPath, computePath);
  }

  void _drawFill(Path path, Paint paint) {
    paint
      ..style = PaintingStyle.fill
      ..setShader(
        drawingArea,
        series!.getFill(index),
        vertical: series!.verticalFill,
      );

    canvas.save();
    clip(path);
    // The rect needs to be inflated so that there is
    // no visible gap between each of the elements on
    // low resolution devices.
    drawRect(
        series!.hasDivider ? drawingArea : Rect.fromLTRB(-2, 0, width + 2, height), paint);
    canvas.restore();
  }

  void _drawShadow(Path path, Paint paint) {
    paint.setShader(
      drawingArea,
      series!.getShadow(index),
      vertical: series!.verticalGradient,
    );

    paint.blur(series!.elevation);

    drawPath(path, paint);

    paint.blur(0);
  }

  void _drawDivider(double prevY, double nextY, Path path, Paint paint) {
    final hdt = series!.dividerThickness!;
    final prevDivider =
        Rect.fromLTRB(-hdt, series!.smoothFactor == 0.0 ? prevY : 0.0, hdt, height);
    final nextDivider = Rect.fromLTRB(
        width - hdt, series!.smoothFactor == 0.0 ? nextY : 0.0, width + hdt, height);

    void draw(Rect divider) {
      drawLine(
        divider.topCenter,
        divider.bottomCenter,
        paint
          ..setShader(
            divider,
            series!.getDivider(index),
          )
          ..strokeWidth = hdt,
      );
    }

    canvas.save();
    clip(path);

    final isFirstInSeries = index <= 0;
    if (!isFirstInSeries) {
      draw(prevDivider);
    }

    final isLastInSeries = index >= (series!.values.length - 1);
    if (!isLastInSeries) {
      draw(nextDivider);
    }

    canvas.restore();
    paint.strokeWidth = series!.thickness!;
  }

  void _drawStroke(Path path, Paint paint) {
    paint.setShader(
      drawingArea,
      series!.getColor(index),
      vertical: series!.verticalGradient,
    );

    canvas.save();
    clip(drawingArea.inflate(1));

    drawPath(
      path,
      paint,
    );

    canvas.restore();
  }

  void _drawLabel(double y) {
    final T value = series!.data[index];
    final label = series!.labelBuilder?.call(value, index) ??
        labelBuilder?.call(series, value, index);
    if (label == null) return;

    final style = series!.labelStyle;
    final labelInset = style != null ? series!.labelSpacing! + fontHeight : 0.0;

    double dx = (width - (leftInset + rightInset)) / 2;
    if (isFirst) dx += leftInset;

    drawText(
      TextSpan(text: label, style: style),
      Offset(dx, y - labelInset),
      align: Alignment.topCenter,
    );
  }

  void _calculateExtremas() {
    if (parent.widget.min != null) {
      min = parent.widget.min as double;
    }

    if (parent.widget.max != null) {
      max = parent.widget.max as double;
    }

    for (final series in allSeries) {
      if (series.data.length > totalItemCount) {
        totalItemCount = series.data.length;
      }

      for (final value in series.values) {
        final v = value.y;
        if (parent.widget.min == null && v! < min) {
          min = v;
        }
        if (parent.widget.max == null && v! > max) {
          max = v;
        }
      }
    }

    final num padding = data!.minDelta! - (max - min);
    if (padding > 0) {
      max += padding / 2;
      min -= padding / 2;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

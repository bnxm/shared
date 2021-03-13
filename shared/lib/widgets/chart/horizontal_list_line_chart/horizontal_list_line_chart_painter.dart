import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import 'horizontal_list_line_chart_data.dart';

class HorizontalListLineChartPainter extends BasePainter {
  final ListLineChartData data;
  final List<ListLineSeries> series;
  final int index;
  HorizontalListLineChartPainter(
    this.data,
    this.series,
    this.index,
  );

  late double min, max;
  late int itemCount;
  late double labelInset;
  late bool isFirst, isLast;

  late ListLineSeries s;

  double get w => width - (leftInset + rightInset);
  double get h => height - padding.vertical;
  double get c => padding.left + (data.itemExtent * index) + (w / 2);

  EdgeInsets get padding => data.innerPadding;
  double get leftInset => isFirst ? padding.left : 0.0;
  double get rightInset => isLast ? padding.right : 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    calculateMinMax();

    save();

    for (final series in this.series) {
      s = series;
      computeLabels();
      drawSeries(series);
    }

    restore();
  }

  void drawSeries(ListLineSeries series) {
    final path = computePath();

    final fillPath = Path.from(path)
      ..lineTo(itemCount * data.itemExtent, height)
      ..lineTo(0, height)
      ..close();

    if (series.hasFill && !series.hasStroke) {}

    drawElevation(series, fillPath);

    drawFill(series, fillPath);
    drawDivider(series, fillPath);

    /* if (series.hasStroke) {
      drawElevation(series, path);
    } */

    drawStroke(series, path);
    drawLabel(series, path);
  }

  void drawStroke(ListLineSeries series, Path path) {
    if (!series.hasStroke) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = series.thickness!
      ..strokeCap = series.strokeCap!
      ..strokeJoin = series.strokeJoin!
      ..setShader(
        drawingArea,
        series.stroke![index].scaleOpacity(series.f),
        vertical: series.verticalGradient,
      );

    save();
    clip(drawingArea.inflate(1));

    drawPath(
      path,
      paint,
    );

    restore();
  }

  void drawFill(ListLineSeries series, Path path) {
    if (!series.hasFill) return;

    final paint = Paint()
      ..setShader(
        drawingArea,
        series.fill![index].scaleOpacity(series.f),
        vertical: series.verticalFill,
      );

    save();
    clip(path);
    drawRect(drawingArea, paint);
    restore();
  }

  void drawElevation(ListLineSeries series, Path path) {
    if (!series.hasShadow) return;

    save();
    clip(drawingArea);

    /* drawShadow(
      path,
      series.shadow![index].first,
      series.elevation!,
    );
 */
    drawPath(
      path,
      Paint()
        ..color = series.shadow![index].first
        ..blur(series.elevation, style: BlurStyle.outer),
    );

    restore();
  }

  void drawDivider(ListLineSeries series, Path path) {
    if (!series.hasDivider) return;

    final hdt = series.dividerThickness! / 2.0;
    final prevDivider = Rect.fromLTRB(0, 0.0, hdt, height);
    final nextDivider = Rect.fromLTRB(width - hdt, 0.0, width + hdt, height);

    void draw(Rect divider) {
      drawLine(
        divider.topCenter,
        divider.bottomCenter,
        Paint()
          ..setShader(divider, series.divider![index].scaleOpacity(series.f))
          ..strokeWidth = hdt,
      );
    }

    save();
    clip(path);

    final isFirstInSeries = index == 0;
    if (!isFirstInSeries) {
      draw(prevDivider);
    }

    final isLastInSeries = index >= (series.values.length - 1);
    if (!isLastInSeries) {
      draw(nextDivider);
    }

    restore();
  }

  void drawLabel(ListLineSeries series, Path path) {
    if (series.labelStyle == null && series.labels!.isNotEmpty) {
      return;
    }

    final label = series.labels![index];
    final dx = leftInset + (w / 2);
    final dy = path.offsetForDx(dx).dy;

    drawText(
      TextSpan(
        text: label,
        style: series.labelStyle?.copyWith(
          color: series.labelStyle!.color!.scaleOpacity(series.f),
          shadows: series.labelStyle!.shadows
              ?.map(
                (e) => Shadow(
                  blurRadius: e.blurRadius,
                  offset: e.offset,
                  color: e.color.scaleOpacity(s.f),
                ),
              )
              .toList(),
        ),
      ),
      Offset(dx, dy - series.labelSpacing!),
      align: Alignment.bottomCenter,
    );
  }

  Path computePath() {
    final height = this.height - padding.vertical - labelInset;

    double dy(double value) {
      final m = (value - min) / (max - min);
      final dy = height - (m * height);
      return dy + padding.top + labelInset - (s.thickness! / 2);
    }

    final List<Offset> knots = [];

    void add(double dx, double dy) => knots.add(Offset(dx, dy));

    for (var i = 0; i < s.values.length; i++) {
      final value = s.values[i];

      final y = dy(lerpDouble(min, value, s.f));
      final x = padding.left + (i * data.itemExtent) + w / 2;

      if (i == 0) add(0, y);
      add(x, y);
      if (i == s.values.length - 1) {
        add(x + (w / 2) + (i == itemCount - 1 ? padding.right : 0), y);
      }
    }

    return computeBezierCurve(knots, smoothFactor: s.smoothFactor!).shift(
      Offset(-((data.itemExtent * index) + (index > 0 ? padding.left : 0.0)), 0),
    );
  }

  void calculateMinMax() {
    final values = series.map((s) => s.values).flatten();

    itemCount = series.getMax((s) => s.data.length).data.length;
    isFirst = index == 0;
    isLast = index == itemCount - 1;

    min = data.min ?? values.getMin();
    max = data.max ?? values.getMax();

    final padding = data.minDelta - (max - min);
    if (padding > 0) {
      max += padding / 2;
      min -= padding / 2;
    }
  }

  void computeLabels() {
    final maxHeight = measureText(TextSpan(text: 'A', style: s.labelStyle)).height;
    final maxSpacing = series.getMax((s) => s.labelSpacing!).labelSpacing!;

    labelInset = s.labelStyle != null ? maxHeight + maxSpacing : 0.0;
  }
}

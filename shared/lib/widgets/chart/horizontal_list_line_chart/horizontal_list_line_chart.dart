import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:shared/widgets/chart/base/chart.dart';
import 'package:shared/widgets/chart/horizontal_list_line_chart/horizontal_list_line_chart_painter.dart';

import 'horizontal_list_line_chart_data.dart';

export 'horizontal_list_line_chart_data.dart';

typedef ListItemBuilder = Widget Function(
  BuildContext context,
  EdgeInsets insets,
  int index,
  Widget chart,
);

class HorizontalListLineChart extends StatelessWidget {
  final List<ListLineSeries> series;
  final ListItemBuilder? builder;
  final double itemExtent;
  final EdgeInsets innerPadding;
  final dynamic color;
  final dynamic fill;
  final dynamic divider;
  final dynamic shadow;
  final EdgeInsets padding;
  final double dividerThickness;
  final double thickness;
  final double elevation;
  final double labelSpacing;
  final TextStyle? labelStyle;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double smoothFactor;
  final bool verticalGradient;
  final bool verticalFill;
  final double? min;
  final double? max;
  final double minDelta;
  final Duration duration;
  final Curve curve;
  final double height;

  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool reverse;
  final bool shrinkWrap;
  const HorizontalListLineChart({
    Key? key,
    required this.series,
    this.builder,
    required this.itemExtent,
    this.innerPadding = const EdgeInsets.symmetric(vertical: 8),
    this.minDelta = 0,
    this.color = Colors.red,
    this.fill = Colors.transparent,
    this.divider = Colors.transparent,
    this.shadow = Colors.transparent,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.dividerThickness = 4.0,
    this.thickness = 3.0,
    this.elevation = 0.0,
    this.labelSpacing = 8.0,
    this.labelStyle,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.smoothFactor = 1.0,
    this.verticalGradient = true,
    this.verticalFill = true,
    this.min,
    this.max,
    this.duration = const Millis(500),
    this.curve = Curves.ease,
    this.height = 128.0,
    this.controller,
    this.physics,
    this.reverse = false,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartAnimationBuilder<ListLineChartData, ListLineSeries>(
      curve: curve,
      duration: duration,
      builder: (series, data, f) {
        final itemCount =
            series.isNotEmpty ? series.getMax((item) => item.data.length).data.length : 0;

        return AnimatedContainer(
          duration: duration,
          curve: curve,
          height: height,
          child: ListView.builder(
            controller: controller,
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
            reverse: reverse,
            itemCount: itemCount,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final srs = series.filter((item) => item.data.length > index);

              final padding = data.innerPadding.copyWith(
                left: index == 0 ? null : 0.0,
                right: index == itemCount - 1 ? null : 0.0,
                bottom: 0.0,
                top: 0.0,
              );

              final painter = SizedBox(
                width: data.itemExtent + padding.horizontal,
                child: CustomPaint(
                  painter: HorizontalListLineChartPainter(data, srs, index),
                ),
              );

              return builder?.call(context, padding, index, painter) ?? painter;
            },
          ),
        );
      },
      series: [
        for (final series in this.series)
          series.apply(
            stroke: color,
            fill: fill,
            divider: divider,
            shadow: shadow,
            padding: padding,
            dividerThickness: dividerThickness,
            thickness: thickness,
            elevation: elevation,
            labelSpacing: labelSpacing,
            labelStyle: labelStyle,
            strokeCap: strokeCap,
            strokeJoin: strokeJoin,
            smoothFactor: smoothFactor,
            verticalGradient: verticalGradient,
            verticalFill: verticalFill,
          ),
      ],
      data: ListLineChartData(
        innerPadding: innerPadding,
        minDelta: minDelta,
        itemExtent: itemExtent,
        min: min,
        max: max,
      ),
    );
  }
}

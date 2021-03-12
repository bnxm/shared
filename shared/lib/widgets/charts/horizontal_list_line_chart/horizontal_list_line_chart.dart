import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import '../util.dart';
import 'horizontal_list_line_chart_data.dart';
import 'horizontal_list_line_painter.dart';

export 'horizontal_list_line_chart_data.dart';

typedef HorizontalListItemBuilder = Widget Function(
    BuildContext context, Widget chart, EdgeInsets insets, int index);

typedef HorizontalListLabelBuilder<T> = String Function(
    ListLineSeries<T>? series, T value, int index);

class HorizontalListLineChart<T> extends ImplicitAnimation {
  final num Function(T value, int index) y;
  final List<ListLineSeries<T>> data;
  final HorizontalListItemBuilder? itemBuilder;
  final double itemExtent;
  final HorizontalListLabelBuilder<T>? labelBuilder;
  final dynamic color;
  final dynamic shadow;
  final dynamic divider;
  final dynamic fill;
  final StrokeJoin strokeJoin;
  final EdgeInsets innerPadding;
  final TextStyle? labelStyle;
  final double thickness;
  final double dividerThickness;
  final double elevation;
  final double smoothFactor;
  final double labelSpacing;
  final double? height;
  final bool verticalGradient;
  final bool verticalFill;
  final num? min;
  final num? max;
  final num minDelta;

  // ScrollView parameters
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsets padding;
  final bool reverse;
  final bool shrinkWrap;
  const HorizontalListLineChart({
    Key? key,
    Duration duration = const Millis(800),
    Curve curve = Curves.linear,
    required this.y,
    required this.data,
    this.itemBuilder,
    required this.itemExtent,
    this.labelBuilder,
    this.color = const [Colors.black, Colors.black],
    this.shadow,
    this.divider,
    this.fill,
    this.strokeJoin = StrokeJoin.round,
    this.innerPadding = EdgeInsets.zero,
    this.labelStyle,
    this.thickness = 3.0,
    this.dividerThickness = 3.0,
    this.elevation = 0.0,
    this.smoothFactor = 0.0,
    this.labelSpacing = 8.0,
    this.height,
    this.verticalGradient = false,
    this.verticalFill = true,
    this.min,
    this.max,
    this.minDelta = 0,
    this.controller,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.reverse = false,
    this.shrinkWrap = false,
  })  : assert(itemExtent > 0),
        assert(minDelta >= 0.0),
        super(
          key,
          duration,
          curve,
        );

  @override
  HorizontalListLineChartState<T> createState() => HorizontalListLineChartState<T>();
}

class HorizontalListLineChartState<T>
    extends ImplicitAnimationState<ListLineChartData<T>, HorizontalListLineChart<T>> {
  double get itemExtent => widget.itemExtent;

  List<ListLineSeries<T>>? prevSeries;

  @override
  ListLineChartData<T> lerp(ListLineChartData<T>? a, ListLineChartData<T> b, double t) =>
      a!.scaleTo(b, v) as ListLineChartData<T>;

  @override
  Widget builder(BuildContext context, ListLineChartData<T>? data) {
    return AnimatedContainer(
      height: widget.height,
      duration: widget.duration,
      child: ListView.builder(
        padding: widget.padding,
        physics: widget.physics,
        reverse: widget.reverse,
        shrinkWrap: widget.shrinkWrap,
        controller: widget.controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final series = getSeriesForIndex(data!.series, index);
          if (series.isEmpty) return const SizedBox();

          final isFirst = index == 0;
          final isLast = !series.includes((item) => index != (item.data.length - 1));

          final leftInset = isFirst ? data.innerPadding!.left : 0.0;
          final rightInset = isLast ? data.innerPadding!.right : 0.0;
          final width = itemExtent + leftInset + rightInset;

          final chart = CustomPaint(
            size: Size(width, double.infinity),
            painter: HorizontaListLinePainer(
              index: index,
              parent: this,
              series: series,
              isLast: isLast,
              isFirst: isFirst,
            ),
          );

          return SizedBox(
            child: widget.itemBuilder?.call(
                  context,
                  chart,
                  EdgeInsets.only(left: leftInset, right: rightInset),
                  index,
                ) ??
                chart,
          );
        },
      ),
    );
  }

  List<ListLineSeries<T>> getSeriesForIndex(List<ListLineSeries<T>> series, int index) {
    return series.filter(
      (series) => index < series.values.length,
    );
  }

  @override
  void didUpdateWidget(HorizontalListLineChart<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    prevSeries = List.from(value.series);
  }

  @override
  ListLineChartData<T> get newValue {
    final List<ListLineSeries<T>> newSeries = widget.data
        .map(
          (series) => series.setDefaults(
            fill: widget.fill,
            color: widget.color,
            shadow: widget.shadow ?? series.color,
            divider: widget.divider,
            padding: widget.innerPadding,
            elevation: widget.elevation,
            thickness: widget.thickness,
            labelStyle: widget.labelStyle ?? Theme.of(context).textTheme.bodyText1,
            strokeJoin: widget.strokeJoin,
            smoothFactor: widget.smoothFactor,
            labelSpacing: widget.labelSpacing,
            verticalFill: widget.verticalFill,
            dividerThickness: widget.dividerThickness,
            verticalGradient: widget.verticalGradient,
          ),
        )
        .toList();

    for (final series in newSeries) {
      series.values.clear();
      for (var i = 0; i < series.data.length; i++) {
        final T value = series.data[i];

        series.values.add(
          ChartValue(0.0, widget.y(value, i)),
        );
      }
    }

    return ListLineChartData<T>(
      series: newSeries,
      innerPadding: widget.innerPadding,
      minDelta: widget.minDelta,
    );
  }
}

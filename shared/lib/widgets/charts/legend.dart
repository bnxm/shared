import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'charts.dart';

enum LegendPosition { top, side, bottom }

class Legend<T> {
  final TextStyle style;
  final double spacing;
  final double verticalSpacing;
  final double chartSpacing;
  final double indicatorSpacing;
  final LegendPosition position;
  final bool alignToDrawArea;
  final Widget Function(BuildContext context, Series<T> series)? indicatorBuilder;
  Legend({
    required this.style,
    this.spacing = 8.0,
    this.verticalSpacing = 8.0,
    this.chartSpacing = 8.0,
    this.indicatorSpacing = 8.0,
    this.alignToDrawArea = true,
    this.position = LegendPosition.bottom,
    this.indicatorBuilder,
  });

  bool get onTop => position == LegendPosition.top;
  bool get onBottom => position == LegendPosition.bottom;
  bool get onSide => position == LegendPosition.side;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Legend &&
        o.style == style &&
        o.spacing == spacing &&
        o.verticalSpacing == verticalSpacing &&
        o.position == position &&
        o.indicatorBuilder == indicatorBuilder;
  }

  @override
  int get hashCode {
    return style.hashCode ^ spacing.hashCode ^ verticalSpacing.hashCode ^ position.hashCode ^ indicatorBuilder.hashCode;
  }

  @override
  String toString() {
    return 'Legend style: $style, horizontalSpacing: $spacing, verticalSpacing: $verticalSpacing, position: $position, indicatorBuilder: $indicatorBuilder';
  }
}

class ChartLegend<T> extends StatefulWidget {
  final List<Series<T>> data;
  final Legend<T>? legend;
  final Widget chart;
  const ChartLegend({
    Key? key,
    this.data = const [],
    this.legend,
    required this.chart,
  })  : assert(chart != null),
        assert(data != null),
        super(key: key);

  @override
  _ChartLegendState createState() => _ChartLegendState<T>();
}

class _ChartLegendState<T> extends State<ChartLegend> {
  Handler? handler;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  /* List<Series<T>> get data {
    return List<Series<T>>.from(widget.data.reversed)
      ..removeWhere(
        (s) => s.label == null && !s.hasId,
      );
  }

  Legend<T> get legend => widget.legend;
  AxisPainter get painter => widget.axisPainter;
  EdgeInsets insets = const EdgeInsets.all(0);

  @override
  void initState() {
    super.initState();
    // Immediately rebuild widget to build with the correct insets.
    postFrame(() {
      setState(() => insets = painter?.insets ?? EdgeInsets.all(0));
    });
  }

  Widget buildLegendItem(Series<T> series) {
    if (series.label == null && series.id == null) return Container();

    final defaultIndicator = MyContainer(
      width: 12,
      height: 12,
      color: series.color,
      boxShape: BoxShape.circle,
    );

    final indicator = legend.indicatorBuilder?.call(context, series) ?? defaultIndicator;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        indicator,
        SizedBox(width: legend.indicatorSpacing),
        Text(
          series.label ?? series.id.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (legend == null || data.isEmpty) return widget.chart;

    // Always get the latest insets after the axispainter
    // is layed out.
    postFrame(() => insets = painter?.insets ?? const EdgeInsets.all(0));

    final spacing = legend.chartSpacing;
    final l = Padding(
      padding: EdgeInsets.fromLTRB(
        legend.alignToDrawArea ? insets.left : spacing,
        legend.onBottom ? spacing : 0,
        legend.alignToDrawArea ? insets.right : spacing,
        legend.onTop ? spacing : 0,
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: legend.spacing,
        runSpacing: legend.verticalSpacing,
        children: data.map((s) => buildLegendItem(s)).toList(),
      ),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (legend.position == LegendPosition.top) l,
              Expanded(child: widget.chart),
              if (legend.position == LegendPosition.bottom) l,
            ],
          ),
        ),
        if (legend.position == LegendPosition.side) l,
      ],
    );
  }

  @override
  void dispose() {
    handler?.cancel();
    super.dispose();
  } */
}

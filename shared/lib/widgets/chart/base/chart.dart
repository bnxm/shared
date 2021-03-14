import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared/widgets/chart/base/series.dart';

class ChartAnimationBuilder<D, S extends Series> extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final List<S> series;
  final D data;
  final Widget Function(List<S> series, D data, double f) builder;
  const ChartAnimationBuilder({
    Key? key,
    required this.duration,
    required this.curve,
    required this.series,
    required this.data,
    required this.builder,
  }) : super(key: key);

  @override
  _ChartAnimationBuilderState createState() => _ChartAnimationBuilderState<D, S>();
}

class _ChartAnimationBuilderState<D, S extends Series>
    extends State<ChartAnimationBuilder<D, S>> with TickerProviderStateMixin {
  late AnimationController sController = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..addListener(() => setState(() {}));

  late Animation<double> sAnimation = CurvedAnimation(
    curve: widget.curve,
    parent: sController,
  );

  late AnimationController dController = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..addListener(() => setState(() {}));

  late Animation<double> dAnimation = CurvedAnimation(
    curve: widget.curve,
    parent: dController,
  );

  late List<S> previousSeries = widget.series;
  late List<S> currentSeries = widget.series;
  late List<S> changedSeries = [];

  late D oldData = widget.data;

  bool isIncoming = true;

  @override
  void didUpdateWidget(ChartAnimationBuilder<D, S> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.series, oldWidget.series)) {
      final series = widget.series;
      final oldSeries = oldWidget.series;

      final length = min(oldSeries.length, series.length);
      isIncoming = oldSeries.length <= series.length;

      previousSeries = oldSeries.sublist(0, length);
      currentSeries = series.sublist(0, length);
      changedSeries = isIncoming ? series.sublist(length) : oldSeries.sublist(length);

      sController
        ..reset()
        ..forward();
    }

    if (widget.data != oldWidget.data) {
      oldData = oldWidget.data;

      dController
        ..reset()
        ..forward();
    }

    dAnimation = CurvedAnimation(
      curve: widget.curve,
      parent: dController,
    );

    sAnimation = CurvedAnimation(
      curve: widget.curve,
      parent: sController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = (oldData as dynamic).scaleTo(widget.data, dAnimation.value) as D;
    final series = zipWith<dynamic, S, S>(
      previousSeries,
      currentSeries,
      (a, b) => a.scaleTo(b, sAnimation.value),
    );

    for (final s in changedSeries) {
      s.f = isIncoming ? sAnimation.value : 1.0 - sAnimation.value;
    }

    return widget.builder(series + changedSeries, data, sAnimation.value);
  }

  @override
  void dispose() {
    dController.dispose();
    sController.dispose();
    super.dispose();
  }
}

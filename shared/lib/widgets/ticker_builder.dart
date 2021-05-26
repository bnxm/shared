import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:core/core.dart';

class TickerBuilder extends StatefulWidget {
  final bool enabled;
  final WidgetBuilder builder;
  const TickerBuilder({
    Key? key,
    this.enabled = true,
    required this.builder,
  }) : super(key: key);

  @override
  _TickerBuilderState createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder> {
  Ticker? ticker;

  @override
  void initState() {
    super.initState();

    ticker = Ticker((_) {
      if (widget.enabled) {
        setState(() {});
      }
    })
      ..start();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }
}

class TimerBuilder extends StatefulWidget {
  final bool syncWithTime;
  final Duration period;
  final WidgetBuilder builder;
  const TimerBuilder({
    Key? key,
    this.syncWithTime = true,
    this.period = const Seconds(1),
    required this.builder,
  })  : assert(syncWithTime != null),
        assert(period != null),
        assert(builder != null),
        super(key: key);

  @override
  _TimerBuilderState createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder> {
  Handler? scheduler;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    scheduleTimer();
  }

  @override
  void didUpdateWidget(TimerBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.period != oldWidget.period ||
        widget.syncWithTime != oldWidget.syncWithTime) {
      scheduleTimer();
    }
  }

  void scheduleTimer() {
    cancelTimer();

    final period = widget.period;
    Duration delay = Duration.zero;
    if (widget.syncWithTime) {
      final now = DateTime.now();

      int hours = 0;
      int minutes = 0;
      int seconds = 0;
      int milliseconds = 0;

      if (period >= const Days(1)) {
        hours = 23 - now.hour;
      }
      if (period >= const Hours(1)) {
        minutes = 59 - now.minute;
      }
      if (period >= const Minutes(1)) {
        seconds = 59 - now.second;
      }
      if (period >= const Seconds(1)) {
        milliseconds = 999 - now.millisecond;
      }

      delay = Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    }

    scheduler = post(delay, () {
      if (mounted) setState(() {});
      timer = Timer.periodic(
        period,
        (_) => setState(() {}),
      );
    });
  }

  void cancelTimer() {
    scheduler?.cancel();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import 'progress_bar_data.dart';

part 'circular_progress_bar.dart';
part 'horizontal_progress_bar.dart';
part 'path_progress_bar.dart';

abstract class _ProgressBar extends ImplicitAnimation {
  final double size;
  final double? value;
  final double strokeWidth;
  final double backgroundStrokeWidth;
  final double elevation;
  final Color? color;
  final Color? backgroundColor;
  final Color? shadowColor;
  final bool round;
  const _ProgressBar({
    Key? key,
    required Duration duration,
    required Curve curve,
    required this.size,
    required this.value,
    required this.strokeWidth,
    required this.backgroundStrokeWidth,
    required this.elevation,
    required this.color,
    required this.backgroundColor,
    required this.shadowColor,
    required this.round,
  })   : assert(value == null || (value >= 0.0 && value <= 1.0)),
        assert(strokeWidth != null && strokeWidth >= 0.0),
        assert(backgroundStrokeWidth != null && backgroundStrokeWidth >= 0.0),
        assert(elevation != null && elevation >= 0.0),
        assert(round != null),
        super(
          key,
          duration,
          curve,
        );
}

abstract class _ProgressBarState<W extends _ProgressBar>
    extends ImplicitAnimationState<ProgressBarData, W> with TickerProviderStateMixin {
  late AnimationController indeterminateController;

  Duration get indeterminateDuration => const Duration(milliseconds: 1800);

  TextDirection get textDirection => Directionality.of(context);

  @override
  void initState() {
    super.initState();

    indeterminateController = AnimationController(
      duration: indeterminateDuration,
      vsync: this,
    );

    if (widget.value == null) {
      indeterminateController.repeat();
    }
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);

    indeterminateController.duration = indeterminateDuration;

    if (widget.value == null && !indeterminateController.isAnimating) {
      indeterminateController.repeat();
    } else if (widget.value != null && indeterminateController.isAnimating) {
      indeterminateController.stop();
    }
  }

  @override
  ProgressBarData lerp(ProgressBarData? a, ProgressBarData b, double t) =>
      a!.scaleTo(b, t);

  @override
  ProgressBarData get newValue {
    return ProgressBarData(
      size: widget.size,
      color: widget.color ?? Theme.of(context).accentColor,
      round: widget.round,
      progress: widget.value?.clamp(0.0, 1.0),
      elevation: widget.elevation,
      shadowColor: widget.shadowColor ?? widget.color ?? Colors.black26,
      strokeWidth: widget.strokeWidth,
      backgroundColor:
          widget.backgroundColor ?? widget.color?.transparent ?? Colors.transparent,
      backgroundStrokeWidth: widget.backgroundStrokeWidth,
    );
  }

  @nonVirtual
  @override
  Widget builder(BuildContext context, ProgressBarData? data) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: indeterminateController,
        builder: (context, _) => Semantics(
          value: data!.progress != null ? '${(data.progress! * 100).round()} %' : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return buildProgressBar(
                  context, constraints.biggest, data, indeterminateController.value);
            },
          ),
        ),
      ),
    );
  }

  Widget buildProgressBar(
    BuildContext context,
    Size size,
    ProgressBarData? data,
    double animationValue,
  );

  @override
  void dispose() {
    indeterminateController.dispose();
    super.dispose();
  }
}

abstract class _ProgressBarPainter extends BasePainter {
  final ProgressBarData? data;
  final double value;
  _ProgressBarPainter(
    this.data,
    this.value,
  );

  double? get progress => data!.progress;
  double? get strokeWidth => data!.strokeWidth;
  double? get backgroundStrokeWidth => data!.backgroundStrokeWidth;
  double? get elevation => data!.elevation;
  Color? get color => data!.color;
  Color? get backgroundColor => data!.backgroundColor;
  Color? get shadowColor => data!.shadowColor;
  bool? get round => data!.round;

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.value != value;
  }
}

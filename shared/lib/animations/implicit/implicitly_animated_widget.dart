import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A base Widget for implicit animations.
abstract class ImplicitAnimation extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  const ImplicitAnimation(
    Key? key,
    this.duration,
    this.curve,
  ) : super(key: key);
}

abstract class ImplicitAnimationState<T, W extends ImplicitAnimation> extends State<W>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    duration: duration,
    vsync: this,
  )..value = 1.0;

  late Animation<double> animation = CurvedAnimation(
    curve: widget.curve,
    parent: controller,
  )..addListener(
      () => value = lerp(oldValue, newValue, v),
    );

  Duration get duration => widget.duration;

  double get v => animation.value;
  T get newValue;
  late T value = newValue;
  late T oldValue = newValue;

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      controller.duration = widget.duration;
    }

    if (oldWidget.curve != widget.curve) {
      animation = CurvedAnimation(
        curve: widget.curve,
        parent: controller,
      );
    }

    if (value != newValue) {
      oldValue = value;
      controller.reset();
      controller.forward();
    }
  }

  T lerp(T a, T b, double t);

  Widget builder(BuildContext context, T value);

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return builder(context, value);
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

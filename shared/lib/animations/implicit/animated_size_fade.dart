import 'package:flutter/material.dart';

import 'package:shared/animations/transitions/transitions.dart';

class AnimatedSizeFade extends StatefulWidget {
  final bool show;
  final Widget child;
  final Axis axis;
  final double axisAlignment;
  final Duration duration;
  final Curve curve;
  final double sizeFraction;
  const AnimatedSizeFade({
    Key? key,
    required this.show,
    required this.duration,
    this.curve = Curves.ease,
    this.axis = Axis.vertical,
    this.axisAlignment = 0.0,
    this.sizeFraction = 0.75,
    required this.child,
  }) : super(key: key);

  @override
  _AnimatedSizeFadeState createState() => _AnimatedSizeFadeState();
}

class _AnimatedSizeFadeState extends State<AnimatedSizeFade>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    duration: widget.duration,
    vsync: this,
    value: widget.show ? 1.0 : 0.0,
  );

  @override
  void didUpdateWidget(AnimatedSizeFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.duration = widget.duration;

    if (widget.show != oldWidget.show) {
      widget.show ? controller.forward() : controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizeFadeTransition(
      axis: widget.axis,
      curve: widget.curve,
      child: widget.child,
      animation: controller,
      sizeFraction: widget.sizeFraction,
      axisAlignment: widget.axisAlignment,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

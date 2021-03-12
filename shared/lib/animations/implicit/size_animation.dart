import 'package:flutter/material.dart';

import 'package:shared/animations/animations.dart';

class SizeAnimation extends StatelessWidget {
  final bool show;
  final Widget? child;
  final Axis axis;
  final double axisAlignment;
  final Duration duration;
  final Curve curve;
  const SizeAnimation({
    Key? key,
    required this.show,
    required this.duration,
    this.curve = Curves.ease,
    this.axis = Axis.vertical,
    this.axisAlignment = 0.0,
    this.child,
  })  : assert(show != null),
        assert(duration != null),
        assert(curve != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animator(
      toEnd: show,
      duration: duration,
      curve: curve,
      builder: (context, animation, _) {
        return SizeTransition(
          axis: axis,
          child: child,
          sizeFactor: animation,
          axisAlignment: axisAlignment,
        );
      },
    );
  }
}

class AnimatedSizeChanges extends StatefulWidget {
  final Duration duration;
  final Duration? reverseDuration;
  final Alignment? alignment;
  final Curve curve;
  final Widget? child;
  const AnimatedSizeChanges({
    Key? key,
    this.duration = const Duration(milliseconds: 200),
    this.reverseDuration,
    this.alignment = Alignment.center,
    this.curve = Curves.easeInOut,
    this.child,
  }) : super(key: key);

  @override
  _AnimatedSizeChangesState createState() => _AnimatedSizeChangesState();
}

class _AnimatedSizeChangesState extends State<AnimatedSizeChanges> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      alignment: widget.alignment!,
      curve: widget.curve,
      child: widget.child,
    );
  }
}

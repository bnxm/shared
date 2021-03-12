import 'package:flutter/material.dart';

import 'package:shared/animations/animations.dart';

class AnimatedColor extends StatelessWidget {
  final Color color;
  final Widget Function(BuildContext context, Widget? child, Color color) builder;
  final Duration duration;
  final Curve curve;
  final Widget? child;
  const AnimatedColor({
    Key? key,
    required this.color,
    required this.builder,
    required this.duration,
    this.curve = Curves.linear,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImplicitAnimationBuilder<Color>(
      lerp: (a, b, t) => Color.lerp(a, b, t)!,
      value: color,
      curve: curve,
      child: child,
      duration: duration,
      builder: (context, value, child) => builder(context, child, value),
    );
  }
}

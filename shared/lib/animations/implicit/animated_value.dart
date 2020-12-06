import 'package:flutter/material.dart';

import 'package:core/core.dart';

import 'implicit.dart';

class AnimatedValue extends StatelessWidget {
  final num value;
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext context, double value) builder;
  const AnimatedValue({
    Key key,
    @required this.value,
    @required this.duration,
    this.curve = Curves.linear,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImplicitAnimationBuilder<double>(
      lerp: lerpDouble,
      value: value.toDouble(),
      curve: curve,
      duration: duration,
      builder: (context, value, _) => builder(context, value),
    );
  }
}

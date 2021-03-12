import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

class AnimatedScale extends StatelessWidget {
  final double scale;
  final Widget child;
  final Alignment alignment;
  final Duration duration;
  final Curve curve;
  const AnimatedScale({
    Key? key,
    required this.scale,
    required this.child,
    this.alignment = Alignment.center,
    required this.duration,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImplicitAnimationBuilder<double>(
      lerp: lerpDouble,
      curve: curve,
      value: scale,
      duration: duration,
      builder: (context, value, _) => Transform.scale(
        scale: value,
        alignment: alignment,
        child: child,
      ),
    );
  }
}

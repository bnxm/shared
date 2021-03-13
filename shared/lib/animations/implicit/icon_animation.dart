import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

class IconAnimation extends StatelessWidget {
  final AnimatedIconData icon;
  final bool forward;
  final double size;
  final Color? color;
  final TextDirection? textDirection;
  final Duration duration;
  final Curve curve;
  const IconAnimation({
    Key? key,
    required this.icon,
    required this.forward,
    this.size = 24.0,
    this.color,
    this.textDirection,
    required this.duration,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImplicitAnimationBuilder<double>(
      lerp: (a, b, t) => lerpDouble(a, b, t)!,
      value: forward ? 1.0 : 0.0,
      curve: curve,
      duration: duration,
      builder: (context, value, _) {
        return AnimatedIcon(
          icon: icon,
          size: size,
          color: color,
          progress: AlwaysStoppedAnimation(value),
          textDirection: textDirection,
        );
      },
    );
  }
}

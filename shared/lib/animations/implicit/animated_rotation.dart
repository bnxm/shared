import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

class AnimatedRotation extends StatelessWidget {
  final double angle;
  final Widget child;
  final AlignmentGeometry alignment;
  final Offset origin;
  final Duration duration;
  final Curve curve;
  const AnimatedRotation({
    Key key,
    @required this.angle,
    @required this.child,
    this.alignment = Alignment.center,
    this.origin,
    @required this.duration,
    this.curve,
  })  : assert(angle != null),
        assert(alignment != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImplicitAnimationBuilder<double>(
      lerp: lerpDouble,
      value: angle,
      duration: duration,
      builder: (context, value, _) {
        return Transform.rotate(
          angle: value,
          child: child,
          origin: origin,
          alignment: alignment,
        );
      },
    );
  }
}

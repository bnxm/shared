import 'package:flutter/material.dart';

import 'package:shared/animations/translate.dart';
import 'package:shared/shared.dart';

class AnimatedTranslation extends StatelessWidget {
  final Offset translation;
  final Duration duration;
  final Widget? child;
  final Curve curve;
  final Alignment alignment;
  final bool isFractional;
  const AnimatedTranslation({
    Key? key,
    required this.translation,
    required this.duration,
    required this.child,
    this.curve = Curves.linear,
    this.alignment = Alignment.topLeft,
    this.isFractional = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImplicitAnimationBuilder<Offset?>(
      lerp: Offset.lerp,
      value: translation,
      curve: curve,
      duration: duration,
      builder: (context, value, _) {
        return Translate(
          child: child,
          alignment: alignment,
          translation: value,
          isFractional: isFractional,
        );
      },
    );
  }
}

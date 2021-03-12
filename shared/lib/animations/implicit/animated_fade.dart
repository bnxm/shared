import 'package:flutter/material.dart';

class AnimatedFade extends StatelessWidget {
  final bool show;
  final Widget child;
  final Duration duration;
  const AnimatedFade({
    Key? key,
    required this.show,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: duration,
      child: child,
    );
  }
}

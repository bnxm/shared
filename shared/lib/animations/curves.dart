import 'package:flutter/material.dart';

class HillTween extends Animatable<double> {
  final bool beginAtZero;
  const HillTween({
    this.beginAtZero = true,
  });

  @override
  double transform(double t) {
    final begin = beginAtZero ? 0.0 : 1.0;
    final end = beginAtZero ? 1.0 : 0.0;

    final forwardTween = Tween(begin: begin, end: end);
    final reverseTween = Tween(begin: end, end: begin);

    return TweenSequence([
      TweenSequenceItem(tween: forwardTween, weight: 1),
      TweenSequenceItem(tween: reverseTween, weight: 1),
    ]).transform(t);
  }
}

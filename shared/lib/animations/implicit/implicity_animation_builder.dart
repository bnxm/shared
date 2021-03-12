import 'package:flutter/material.dart';

import 'package:shared/animations/animations.dart';

class ImplicitAnimationBuilder<T> extends ImplicitAnimation {
  final T Function(T a, T b, double t) lerp;
  final T value;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;
  const ImplicitAnimationBuilder({
    Key? key,
    required Duration duration,
    Curve curve = Curves.linear,
    required this.lerp,
    required this.value,
    required this.builder,
    this.child,
  }) : super(key, duration, curve);

  @override
  _ImplicitAnimationBuilderState createState() => _ImplicitAnimationBuilderState<T>();
}

class _ImplicitAnimationBuilderState<T> extends ImplicitAnimationState<T, ImplicitAnimationBuilder<T>> {
  @override
  T get newValue => widget.value;

  @override
  T lerp(T a, T b, double t) => widget.lerp(a, b, t);

  @override
  Widget builder(BuildContext context, T value) {
    return widget.builder(context, value, widget.child);
  }
}

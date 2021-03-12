import 'package:flutter/material.dart';

import 'package:core/core.dart';

class TransparentRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext, Animation) builder;
  final Duration duration;
  TransparentRoute({
    required this.builder,
    this.duration = const Millis(250),
    RouteSettings? settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final result = builder(context, animation);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }
}

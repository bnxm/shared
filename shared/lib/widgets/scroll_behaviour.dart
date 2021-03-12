import 'package:flutter/material.dart';

class BouncingScroll extends StatelessWidget {
  final Widget? child;
  const BouncingScroll({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: BouncingScrollBehaviour(),
      child: child!,
    );
  }
}

class NoOverscroll extends StatelessWidget {
  final Widget? child;
  const NoOverscroll({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const NoOverscrollBehaviour(),
      child: child!,
    );
  }
}

class NoOverscrollBehaviour extends ScrollBehavior {
  const NoOverscrollBehaviour();

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class BouncingScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

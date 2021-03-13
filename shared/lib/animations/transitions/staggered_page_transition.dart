import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

class StaggeredPageTransition extends StatelessWidget {
  final int count;
  final double delayFraction;
  final Animation<double> animation;
  final Widget child;
  const StaggeredPageTransition({
    Key? key,
    this.count = 2,
    this.delayFraction = 0.0,
    required this.animation,
    required this.child,
  })   : assert(count >= 1),
        assert(delayFraction >= 0.0 && delayFraction <= 1.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: child,
      animation: animation,
      builder: (_, child) => ClipPath(
        child: child,
        clipper: _Clipper(
          count,
          delayFraction,
          animation.value,
        ),
      ),
    );
  }
}

class _Clipper extends CustomClipper<Path> {
  final int count;
  final double delayFraction;
  final double t;
  _Clipper(
    this.count,
    this.delayFraction,
    this.t,
  );

  @override
  Path getClip(Size size) {
    final path = Path();

    for (var i = 0; i < count; i++) {
      final rect = getRectForIndex(size, i);
      path.addRect(rect);
    }

    return path;
  }

  Rect getRectForIndex(Size size, int index) {
    final animationFraction = lerpDouble(1.0, 1.0 / count.toDouble(), delayFraction)!;
    final delay = (delayFraction / count) * index;
    final translation =
        (1.0 - interval(delay, delay + animationFraction, t)) * size.width;
    final height = size.height / count;

    return Rect.fromLTWH(
      index.isEven ? translation : -translation,
      height * index,
      size.width,
      height,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

import 'package:flutter/material.dart';

class SizeFadeTransition extends StatefulWidget {
  final Animation<double> animation;
  final Curve curve;
  final double sizeFraction;
  final Axis axis;
  final double axisAlignment;
  final Widget? child;
  const SizeFadeTransition({
    Key? key,
    required this.animation,
    this.sizeFraction = 0.5,
    this.curve = Curves.linear,
    this.axis = Axis.vertical,
    this.axisAlignment = 0.0,
    this.child,
  })  : assert(sizeFraction >= 0.0 && sizeFraction <= 1.0),
        super(key: key);

  @override
  _SizeFadeTransitionState createState() => _SizeFadeTransitionState();
}

class _SizeFadeTransitionState extends State<SizeFadeTransition> {
  late Animation size;
  late Animation opacity;

  @override
  void initState() {
    super.initState();
    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(SizeFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    final curve = CurvedAnimation(parent: widget.animation, curve: widget.curve);
    size = CurvedAnimation(curve: Interval(0.0, widget.sizeFraction), parent: curve);
    opacity = CurvedAnimation(curve: Interval(widget.sizeFraction, 1.0), parent: curve);
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: size as Animation<double>,
      axis: widget.axis,
      axisAlignment: widget.axisAlignment,
      child: FadeTransition(
        opacity: opacity as Animation<double>,
        child: widget.child,
      ),
    );
  }
}

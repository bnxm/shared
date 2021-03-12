import 'package:flutter/material.dart';

import 'package:core/core.dart';

class AnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final Widget Function(Animation<double> animation, Widget? child)? builder;
  const AnimatedIndexedStack({
    Key? key,
    required this.index,
    required this.children,
    this.duration = const Millis(250),
    this.builder,
  }) : super(key: key);

  @override
  _AnimatedIndexedStackState createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    duration: widget.duration * 0.5,
    vsync: this,
    value: 1.0,
  );

  late Animation<double> animation = CurvedAnimation(
    parent: controller,
    curve: Curves.ease,
  );

  late int index = widget.index;

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != index) {
      controller.reverse().then(
        (_) {
          setState(() => index = widget.index);
          controller.forward();
        },
      );
    }

    if (widget.duration != oldWidget.duration) {
      controller.duration = widget.duration * 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        if (widget.builder != null) {
          return widget.builder!(controller, child);
        }

        return Opacity(
          opacity: controller.value,
          child: Transform.scale(
            scale: 1.015 - (controller.value * 0.015),
            child: child,
          ),
        );
      },
      child: IndexedStack(
        index: index,
        children: widget.children,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class PumpingIcon extends StatelessWidget {
  final Widget icon;
  final Duration duration;
  final Duration interval;
  final double intensity;
  const PumpingIcon({
    Key? key,
    required this.icon,
    this.duration = const Millis(250),
    this.interval = const Millis(750),
    this.intensity = 0.15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animator(
      reverseRepeat: true,
      duration: duration,
      period: interval,
      builder: (context, animation, child) {
        return ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.0 + intensity).animate(animation),
          child: icon,
        );
      },
    );
  }
}

class CircularRipple extends StatelessWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final Duration interval;
  const CircularRipple({
    Key? key,
    required this.size,
    this.color,
    this.duration = const Millis(200),
    this.interval = const Seconds(1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animator(
      curve: Curves.easeOut,
      duration: duration,
      period: interval,
      builder: (context, animation, child) {
        final scale = CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.7));
        final opacity =
            Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: animation, curve: const Interval(0.8, 1.0)));

        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: Box(
              radius: size / 2,
              color: color ?? Theme.of(context).accentColor,
            ),
          ),
        );
      },
    );
  }
}

class PumpingHeart extends StatelessWidget {
  final double? size;
  final Duration duration;
  final Duration interval;
  final Color color;
  const PumpingHeart({
    Key? key,
    this.size,
    this.duration = const Millis(250),
    this.interval = const Millis(750),
    this.color = Colors.pink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? Theme.of(context).iconTheme.size;

    return PumpingIcon(
      duration: duration,
      interval: interval,
      icon: Icon(
        Icons.favorite,
        size: size,
        color: color,
      ),
    );
  }
}

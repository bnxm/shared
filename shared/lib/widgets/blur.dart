import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:shared/constants/constants.dart';

class Blur extends StatelessWidget {
  final double sigma;
  final Color? color;
  final Widget? child;
  const Blur({
    Key? key,
    required this.sigma,
    this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blur = ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          color: color ?? Colors.black.withOpacity(0.01),
          child: child,
        ),
      ),
    );
    return blur;

    if (child == null) {
      return blur;
    } else {
      return Stack(
        fit: StackFit.passthrough,
        children: [blur, child!],
      );
    }
  }
}

class OuterElevation extends StatelessWidget {
  final double elevation;
  final Color shadowColor;
  final BorderRadiusGeometry borderRadius;
  final Widget? child;
  const OuterElevation({
    Key? key,
    required this.elevation,
    this.shadowColor = Colors.black26,
    this.borderRadius = BorderRadius.zero,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: borderRadius as BorderRadius?,
        child: child,
      ),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          _OuterBoxShadow(
            blurRadius: elevation,
            color: shadowColor,
          ),
        ],
      ),
    );
  }
}

class _OuterBoxShadow extends BoxShadow {
  const _OuterBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
  }) : super(
          color: color,
          offset: offset,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        );

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, blurSigma);

    if (kIsDebug && debugDisableShadows) {
      result.maskFilter = null;
    }

    return result;
  }
}

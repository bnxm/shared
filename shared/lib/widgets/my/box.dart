import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum ShadowDirection {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
  center,
}

class Box extends StatelessWidget {
  final bool clip;
  final dynamic borderRadius;
  final double elevation;
  final num? height;
  final num? width;
  final num? radius;
  final Border? border;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final Widget? child;
  final dynamic color;
  final Color shadowColor;
  final List<BoxShadow>? boxShadows;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final BoxShape boxShape;
  final AlignmentGeometry? alignment;
  final ShadowDirection shadowDirection;
  final Color? splashColor;
  final Duration? duration;
  final Curve curve;
  final BoxConstraints? constraints;
  final bool showInkWell;
  const Box({
    Key? key,
    this.clip = true,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.height,
    this.width,
    this.radius,
    this.border,
    this.margin,
    this.padding = const EdgeInsets.all(0),
    this.child,
    this.color = Colors.transparent,
    this.shadowColor = Colors.black12,
    this.boxShadows,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.boxShape = BoxShape.rectangle,
    this.alignment,
    this.shadowDirection = ShadowDirection.bottomRight,
    this.splashColor,
    this.duration,
    this.curve = Curves.linear,
    this.constraints,
    this.showInkWell = true,
  })  : assert(color == null ||
            color is Color ||
            color is Gradient),
        super(key: key);

  static const WRAP = -1;

  bool get circle => radius != null || boxShape == BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final r = radius != null ? radius! * 2 : null;
    final h = (r ?? height)?.toDouble();
    final w =
        (r ?? (height != null && width == null ? double.infinity : width))?.toDouble();

    final BorderRadiusGeometry? br = borderRadius is BorderRadiusGeometry
        ? borderRadius
        : BorderRadius.circular(
            !circle
                ? borderRadius?.toDouble() ?? 0.0
                : w != null
                    ? w / 2.0
                    : h != null
                        ? h / 2.0
                        : 0.0,
          );

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (circle || (clip && br != BorderRadius.zero)) {
      content = circle
          ? ClipOval(child: content)
          : ClipRRect(
              borderRadius: br!.resolve(Directionality.of(context)),
              child: content,
            );
    }

    if (onTap != null || onLongPress != null || onDoubleTap != null) {
      content = Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        shape: circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: br!),
        child: InkWell(
          splashColor:
              showInkWell ? splashColor ?? theme.splashColor : Colors.transparent,
          highlightColor: showInkWell ? theme.highlightColor : Colors.transparent,
          hoverColor: showInkWell ? theme.hoverColor : Colors.transparent,
          focusColor: showInkWell ? theme.focusColor : Colors.transparent,
          customBorder:
              circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: br!),
          onTap: onTap,
          onLongPress: onLongPress,
          onDoubleTap: onDoubleTap,
          child: content,
        ),
      );
    }

    final List<BoxShadow>? boxShadow = boxShadows ??
        ((elevation > 0 && shadowColor.opacity > 0)
            ? [
                BoxShadow(
                  color: shadowColor,
                  offset: _getShadowOffset(min(elevation / 5.0, 1.0)),
                  blurRadius: elevation,
                  spreadRadius: 0,
                ),
              ]
            : null);

    LinearGradient? gradient;
     if (color is LinearGradient) {
      gradient = color;
    }

    final boxDecoration = BoxDecoration(
      color: color is Color ? color : null,
      gradient: gradient,
      borderRadius: !circle && (border == null || border!.isUniform) ? br : null,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      boxShadow: boxShadow,
      border: border,
    );

    return duration != null && duration! > Duration.zero
        ? AnimatedContainer(
            height: h,
            width: w,
            margin: margin,
            alignment: alignment,
            duration: duration!,
            curve: curve,
            decoration: boxDecoration,
            constraints: constraints,
            child: content,
          )
        : Container(
            height: h,
            width: w,
            margin: margin,
            alignment: alignment,
            decoration: boxDecoration,
            constraints: constraints,
            child: content,
          );
  }

  Offset _getShadowOffset(double elevation) {
    final ym = 5 * elevation;
    final xm = 2 * elevation;

    switch (shadowDirection) {
      case ShadowDirection.topLeft:
        return Offset(-1 * xm, -1 * ym);
        break;
      case ShadowDirection.top:
        return Offset(0, -1 * ym);
        break;
      case ShadowDirection.topRight:
        return Offset(xm, -1 * ym);
        break;
      case ShadowDirection.right:
        return Offset(xm, 0);
        break;
      case ShadowDirection.bottomRight:
        return Offset(xm, ym);
        break;
      case ShadowDirection.bottom:
        return Offset(0, ym);
        break;
      case ShadowDirection.bottomLeft:
        return Offset(-1 * xm, ym);
        break;
      case ShadowDirection.left:
        return Offset(-1 * xm, 0);
        break;
      default:
        return Offset.zero;
        break;
    }
  }
}

class ListBox extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final dynamic leading;
  final dynamic trailing;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final bool reserveIconSpace;
  final VoidCallback? onTap;
  final Color? color;
  final bool? isEnabled;
  final double? maxWidth;
  final Duration? duration;
  final BorderRadiusGeometry? borderRadius;
  const ListBox({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.elevation = 0.0,
    this.padding,
    this.reserveIconSpace = false,
    this.onTap,
    this.color,
    this.isEnabled,
    this.maxWidth,
    this.duration,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget? leading = this.leading;
    if (leading is Icon) {
      leading = Container(
        width: 36,
        alignment: Alignment.center,
        child: leading,
      );
    }

    Widget? trailing = this.trailing;
    if (trailing is Icon) {
      trailing = Container(
        width: 40,
        alignment: Alignment.center,
        child: trailing,
      );
    }

    final box = Box(
      duration: duration,
      color: color,
      onTap: onTap,
      elevation: elevation,
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      padding: padding ?? const EdgeInsets.all(16),
      borderRadius: borderRadius,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (leading != null) leading,
          SizedBox(
              width: leading != null
                  ? 16
                  : reserveIconSpace
                      ? 56
                      : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null)
                  DefaultTextStyle(style: textTheme.subtitle1!, child: title!),
                if (subtitle != null) const SizedBox(height: 4),
                if (subtitle != null)
                  DefaultTextStyle(style: textTheme.subtitle2!, child: subtitle!),
              ],
            ),
          ),
          if (trailing != null) const SizedBox(width: 16),
          if (trailing != null) trailing,
        ],
      ),
    );

    if (isEnabled != null) {
      return AnimatedOpacity(
        opacity: isEnabled! ? 1.0 : 0.5,
        duration: const Millis(400),
        child: IgnorePointer(
          ignoring: !isEnabled!,
          child: box,
        ),
      );
    }

    return box;
  }
}

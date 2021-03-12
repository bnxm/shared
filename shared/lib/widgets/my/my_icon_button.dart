import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shared/widgets/widgets.dart';

class CircleButton extends StatelessWidget {
  final dynamic icon;
  final Color? color;
  final double? size;
  final bool active;
  final VoidCallback onTap;
  final EdgeInsets padding;
  const CircleButton({
    Key? key,
    this.color,
    this.active = true,
    required this.icon,
    required this.onTap,
    this.padding = const EdgeInsets.all(6),
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? theme.iconTheme.color;
    final size = this.size ?? theme.iconTheme.size;

    Widget? child;
    if (icon is IconData) {
      child = Icon(icon, color: color, size: size);
    } else if (icon is String) {
      child = icon.toLowerCase().endsWith('.svg')
          ? SvgPicture.asset(icon, width: size, height: size, color: color)
          : Image.asset(icon, width: size, height: size, color: color);
    } else {
      child = icon;
    }

    return AnimatedOpacity(
      opacity: active ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 250),
      child: Box(
        padding: padding,
        boxShape: BoxShape.circle,
        onTap: active ? onTap : null,
        child: Container(
          width: size ?? theme.iconTheme.size,
          height: size ?? theme.iconTheme.size,
          child: child,
        ),
      ),
    );
  }
}

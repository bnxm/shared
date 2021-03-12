import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared/widgets/widgets.dart';

class MyBackButton extends StatelessWidget {
  final dynamic icon;
  final VoidCallback? onBackPressed;
  final Color? color;
  final double size;
  const MyBackButton({
    Key? key,
    this.icon,
    this.onBackPressed,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleButton(
      size: size,
      icon: icon ?? (Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
      onTap: onBackPressed ?? () => Navigator.pop(context),
      color: color,
    );
  }
}

import 'package:flutter/material.dart';

class DoubleText extends StatelessWidget {
  final Text left;
  final Text right;
  final double spacing;
  const DoubleText({
    Key? key,
    required this.left,
    required this.right,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: left),
        SizedBox(width: spacing),
        Expanded(child: right),
      ],
    );
  }
}

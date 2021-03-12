import 'package:flutter/material.dart';

class Translate extends StatefulWidget {
  final Offset? translation;
  final Alignment alignment;
  final Widget? child;
  final bool isFractional;
  const Translate({
    Key? key,
    this.translation,
    this.alignment = Alignment.topLeft,
    this.child,
    this.isFractional = false,
  }) : super(key: key);

  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<Translate> {
  late Offset offset;
  Alignment get align => widget.alignment;

  @override
  Widget build(BuildContext context) {
    if (align == Alignment.topCenter) {
      offset = const Offset(-0.5, 0.0);
    } else if (align == Alignment.topLeft) {
      offset = const Offset(0.0, 0.0);
    } else if (align == Alignment.topRight) {
      offset = const Offset(-1.0, 0.0);
    } else if (align == Alignment.center) {
      offset = const Offset(-0.5, -0.5);
    } else if (align == Alignment.centerLeft) {
      offset = const Offset(0.0, -0.5);
    } else if (align == Alignment.centerRight) {
      offset = const Offset(-1.0, -0.5);
    } else if (align == Alignment.bottomCenter) {
      offset = const Offset(-0.5, -1.0);
    } else if (align == Alignment.bottomLeft) {
      offset = const Offset(0.0, -1.0);
    } else if (align == Alignment.bottomRight) {
      offset = const Offset(-1.0, -1.0);
    }

    return !widget.isFractional
        ? Transform.translate(
            offset: widget.translation!,
            child: FractionalTranslation(
              translation: offset,
              child: widget.child,
            ),
          )
        : FractionalTranslation(
            translation: widget.translation!,
            child: FractionalTranslation(
              translation: offset,
              child: widget.child,
            ),
          );
  }
}

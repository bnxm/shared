import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

export 'android_refreshrate_unlocker.dart';
export 'inputs.dart';
export 'math_string_parser.dart';

double lpToPx(BuildContext context, double px) {
  return MediaQuery.of(context).devicePixelRatio * px;
}

void postFrame(VoidCallback callback) {
  assert(callback != null);
  WidgetsBinding.instance.addPostFrameCallback((_) => callback());
}

T lerp<T>(T a, T b, double t) {
  if (T is double) {
    return lerpDouble(a as double, b as double, t) as T;
  } else if (T is int) {
    return lerpInt(a as int, b as int, t) as T;
  } else if (T is Color) {
    return Color.lerp(a as Color, b as Color, t) as T;
  } else if (T is Offset) {
    return Offset.lerp(a as Offset, b as Offset, t) as T;
  } else {
    throw ArgumentError('$T cannot be interpolated');
  }
}

Future<T> openDialog<T>(BuildContext context, Widget dialog,
    {bool dismissable = true}) async {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, anim, secondaryAnim) {
      return dialog;
    },
    barrierColor: Colors.black38,
    barrierDismissible: dismissable,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 200),
  );
}

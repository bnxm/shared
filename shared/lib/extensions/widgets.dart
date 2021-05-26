import 'package:flutter/material.dart';

import 'package:shared/theme/schema.dart';

extension ListWidgetExtensions on Iterable<Widget> {
  List<Widget> seperate([dynamic spacing = const Divider()]) {
    assert(spacing is Widget || spacing is num);

    final List<Widget> result = [];
    for (var i = 0; i < length; i++) {
      final widget = toList()[i];
      result.add(widget);

      if (i < (length - 1)) {
        final spacer = spacing is Widget ? spacing : SizedBox(height: spacing.toDouble());
        result.add(spacer);
      }
    }

    return result;
  }
}

extension StateExtensions<T extends StatefulWidget> on State<T> {
  ThemeData get theme => Theme.of(context);
  TextTheme get textTheme => theme.textTheme;
  Schema get schema => Schema.of(context);
}

extension GlobalKeyExtension on GlobalKey {
  RenderBox? get renderBox => currentContext?.renderBox;

  Size? get size => renderBox?.hasSize == true ? renderBox?.size : Size.zero;
  double? get height => size?.height;
  double? get width => size?.width;

  Offset? get offset => renderBox?.offset;
}

extension BuildContextUiExtension on BuildContext {
  RenderBox? get renderBox => findRenderObject() as RenderBox?;

  Size? get size => renderBox?.hasSize == true ? renderBox?.size : Size.zero;
  double? get height => size?.height;
  double? get width => size?.width;

  Offset? get offset => renderBox?.offset;
}

extension RenderBoxExtension on RenderBox {
  Offset get offset => localToGlobal(Offset.zero);
}

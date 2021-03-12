import 'package:flutter/material.dart';

class TextController extends TextEditingController {
  FocusNode? node;
  TextController() {
    node = FocusNode()
      ..addListener(
        () => onFocus?.call(node!.hasFocus),
      );
  }

  @override
  set text(String newText) {
    int offset = selection.extentOffset;
    if (text.length == offset) {
      offset = newText.length;
    }

    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  void Function(bool hasFocus)? onFocus;

  void requestFocus() => node!.requestFocus();

  void clearFocus(BuildContext context) => FocusScope.of(context).requestFocus(FocusNode());

  bool get hasFocus => node!.hasFocus;

  @override
  void dispose() {
    node?.dispose();
    super.dispose();
  }
}

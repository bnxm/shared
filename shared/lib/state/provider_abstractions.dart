import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/exceptions/exceptions.dart';

abstract class Model extends ChangeNotifier {
  void notify([void optional]) {
    notifyListeners();
  }
}

class ModelProvider<T extends ChangeNotifier> extends ChangeNotifierProvider<T> {
  ModelProvider({
    Key? key,
    required T Function(BuildContext context) create,
    Widget? child,
  }) : super(
          key: key,
          create: create,
          child: child,
        );
}

class Observer<T> extends StatelessWidget {
  final ValueListenable<T>? value;
  final Widget Function(BuildContext context, T? model) builder;
  const Observer({
    Key? key,
    this.value,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return ValueListenableBuilder(
        valueListenable: value!,
        builder: (context, dynamic value, _) => builder(context, value),
      );
    } else {
      try {
        return Consumer<T>(
          builder: (context, model, _) => builder(context, model),
        );
      } on Exception {
        throw IllegalArgumentException(
            'Type ${T.runtimeType} is neither a ChangeNotifier nor a value was provided!');
      }
    }
  }
}

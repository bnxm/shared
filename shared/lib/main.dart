import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(12, (_) => const AnimatedColor()).seperate(
              const Divider(),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedColor extends StatefulWidget {
  const AnimatedColor({Key? key}) : super(key: key);

  @override
  _AnimatedColorState createState() => _AnimatedColorState();
}

class _AnimatedColorState extends State<AnimatedColor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Color? color = Colors.red;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )
      ..addListener(
        () => setState(
          () => color = Color.lerp(Colors.green, Colors.red, _controller.value),
        ),
      )
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      color: color,
      child: Center(
        child: Text(
          'Test',
          style: TextStyle(fontSize: 100),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

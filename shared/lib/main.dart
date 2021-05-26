import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

void main() {
  unlockRefreshRate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Test(),
      ),
    );
  }
}

class Chart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final series = ListLineSeries<int>(
      data: List.generate(24, (i) => i)..shuffle(),
      y: (value, index) => value.toDouble(),
      elevation: 4.0,
      labelBuilder: (value, index) => value.toString(),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Rubik',
        shadows: [
          Shadow(
            blurRadius: 4,
            color: Colors.black38,
          ),
        ],
      ),
      stroke: Colors.black,
      fill: [Colors.grey, Colors.grey.withAlpha(0)],
      divider: [Colors.grey, Colors.grey.withAlpha(0)],
    );

    return HorizontalListLineChart(
      itemExtent: 72,
      series: [series],
    );
  }
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var i = 0; i < 5; i++)
            Container(
              margin: EdgeInsets.symmetric(vertical: 250),
              height: 200,
              child: Chart(),
            ),
        ],
      ),
    );
  }
}

class Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(10.0, 0.0)
      ..lineTo(11.0, 1.0)
      ..lineTo(size.width, size.height);

    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke);

    final metrics = path.computeMetrics().first;
    final offset = metrics.getTangentForOffset(1)!.position;

    print([offset.dx, offset.dy]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

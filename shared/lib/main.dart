import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final series = ListLineSeries<double>(
      data: [0.25, 0.5, 0.75, 1.0],
      y: (value, index) => value,
      labelBuilder: (value, index) => value.toString(),
      labelStyle: TextStyle(color: Colors.black)
    );

    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Center(
          child: HorizontalListLineChart(
            itemExtent: 50,
            series: [series],
          ),
        ),
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

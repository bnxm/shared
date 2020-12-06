import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:shared/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await I18n.init([
    Language.english,
    Language.german,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        backgroundColor: Color(0xFF08182C),
        body: Center(child: BlowingSnow()),
      ),
    );
  }
}

class BlowingSnow extends StatelessWidget {
  const BlowingSnow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FxRenderLoop(
      count: 500,
      duration: Duration(milliseconds: 2000),
      create: (i) => create(i)..t = random(),
      advance: (fx, t) => fx..t += t * fx.z,
      recreate: (fx) => create(fx.i),
      render: (particles) => _SnowRenderer(particles),
    );
  }

  _Flake create(int i) => _Flake()
    ..color = Colors.white
    ..size = random(min: 3.0, max: 6.0)
    ..i = i
    ..x = random()
    ..z = random(min: 0.5)
    ..payload = random(min: 2.0, max: 4.0);
}

class _Flake extends Fx {
  double sc = 1.0;
}

class _SnowRenderer extends FxRenderer<_Flake> {
  _SnowRenderer(List<_Flake> particles) : super(particles);

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    for (final fx in particles) {
      final x = width * fx.x;
      final y = lerpDouble(-fx.size, height + fx.size, fx.t);

      final sway = math.sin(fx.t * math.pi * 2 * fx.sc) *
          (width * fx.z * 0.05) *
          (fx.i.isEven ? 1.0 : -1.0);

      canvas.drawCircle(
        Offset(x + sway, y),
        fx.size,
        Paint()..color = fx.color.withOpacity(fx.z),
      );
    }
  }
}

class FxRenderLoop<T extends Fx> extends StatefulWidget {
  final T Function(int i) create;
  final T Function(T fx) recreate;
  final void Function(T fx, double t) advance;
  final FxRenderer Function(List<T> particles) render;
  final int count;
  final Duration duration;
  final double rotation;
  final Widget child;
  const FxRenderLoop({
    Key key,
    @required this.create,
    @required this.recreate,
    this.advance,
    @required this.render,
    this.count = 10,
    this.duration = const Millis(3000),
    this.rotation = 0.0,
    this.child,
  })  : assert(duration > Duration.zero),
        super(key: key);

  @override
  _FxRenderLoopState createState() => _FxRenderLoopState<T>();
}

class _FxRenderLoopState<T extends Fx> extends State<FxRenderLoop<T>> {
  Ticker ticker;
  Duration lastEllapsed;

  List<T> particles = [];

  @override
  void initState() {
    super.initState();

    createParticles();
    ticker = Ticker(onTick)..start();
  }

  @override
  void didUpdateWidget(covariant FxRenderLoop oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.count != oldWidget.count) {
      createParticles();
    }
  }

  void createParticles() {
    particles = List<T>.generate(widget.count, widget.create);
  }

  void onTick(Duration ellapsed) {
    lastEllapsed ??= ellapsed;
    final delta = ellapsed - lastEllapsed;
    lastEllapsed = ellapsed;

    if (delta > const Millis(500)) {
      createParticles();
      return;
    }

    final t = delta.inMilliseconds.toDouble() / widget.duration.inMilliseconds.toDouble();

    final List<T> toBeRecreated = [];
    for (final fx in particles) {
      if (widget.advance != null) {
        widget.advance(fx, t);
      } else {
        fx.t += t;
      }

      if (fx.t > 1.0) {
        toBeRecreated.add(fx);
      }
    }

    particles
      ..removeAll(toBeRecreated)
      ..addAll(toBeRecreated.map(widget.recreate));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: SizeBuilder(
          builder: (context, width, height) {
            final rotation = widget.rotation.radians;
            final f = (math.tan(rotation) * (height / 2.0)) / math.min(width, height);

            final painter = CustomPaint(
              child: widget.child,
              size: Size.infinite,
              isComplex: false,
              willChange: true,
              painter: widget.render(particles),
            );

            if (rotation != 0) {
              return OverflowBox(
                maxWidth: width < height ? width * (1.0 + f) : width,
                maxHeight: height < width ? height * (1.0 + f) : height,
                child: Transform.rotate(
                  angle: widget.rotation.radians,
                  child: painter,
                ),
              );
            } else {
              return painter;
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    ticker.stop();
    super.dispose();
  }
}

abstract class FxRenderer<T extends Fx> extends BasePainter {
  final List<T> particles;
  FxRenderer(this.particles);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Fx {
  double width = 0, height = 0, size = 0;
  double x = 0, y = 0, z = 0;
  Color color = Colors.white;
  double theta = 0;
  double t = 0, start = 0;
  int i = 0;
  dynamic payload;

  double get f => math.sin(t * math.pi * 2);
}

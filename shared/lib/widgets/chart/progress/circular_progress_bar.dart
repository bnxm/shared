part of 'progress_bar.dart';

// Tweens used by circular progress indicator
final Animatable<double> _kStrokeHeadTween = CurveTween(
  curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<double> _kStrokeTailTween = CurveTween(
  curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<int> _kStepTween = StepTween(begin: 0, end: 5);

final Animatable<double> _kRotationTween = CurveTween(curve: const SawTooth(5));

class CircularProgressBar extends _ProgressBar {
  const CircularProgressBar({
    Key? key,
    double? value,
    bool round = true,
    Color color = Colors.black,
    Color backgroundColor = Colors.grey,
    Color shadowColor = Colors.grey,
    double size = 100.0,
    double strokeWidth = 4.0,
    double backgroundStrokeWidth = 2.0,
    double elevation = 0.0,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.ease,
  }) : super(
          key: key,
          round: round,
          color: color,
          backgroundColor: backgroundColor,
          shadowColor: shadowColor,
          size: size,
          value: value,
          strokeWidth: strokeWidth,
          backgroundStrokeWidth: backgroundStrokeWidth,
          elevation: elevation,
          duration: duration,
          curve: curve,
        );

  @override
  _CircularProgressBarState createState() => _CircularProgressBarState();
}

class _CircularProgressBarState extends _ProgressBarState<CircularProgressBar> {
  @override
  Duration get indeterminateDuration => const Seconds(6);

  @override
  Widget buildProgressBar(
    BuildContext context,
    Size size,
    ProgressBarData? data,
    double animationValue,
  ) {
    final rotationValue = _kRotationTween.transform(animationValue);
    final headValue = _kStrokeHeadTween.transform(animationValue);
    final tailValue = _kStrokeTailTween.transform(animationValue);
    final stepValue = _kStepTween.transform(animationValue);

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _CircularProgressPainter(
        value,
        animationValue,
        headValue,
        tailValue,
        stepValue,
        rotationValue,
      ),
    );
  }
}

class _CircularProgressPainter extends _ProgressBarPainter {
  final double headValue;
  final double tailValue;
  final int stepValue;
  final double rotationValue;
  _CircularProgressPainter(
    ProgressBarData? data,
    double animationValue,
    this.headValue,
    this.tailValue,
    this.stepValue,
    this.rotationValue,
  ) : super(data, animationValue);

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  static const double _startAngle = -math.pi / 2.0;

  double get capInset => round! ? strokeWidth! / 2 : 0;

  late Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    rect = Rect.fromLTRB(
      capInset,
      capInset,
      width - capInset,
      height - capInset,
    );

    final backgroundPaint = Paint()
      ..color = backgroundColor ?? Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = backgroundStrokeWidth!;

    final backgroundPath = Path()
      ..reset()
      ..moveTo(width / 2, capInset)
      ..addArc(rect, 0.0, _twoPi);

    drawPath(backgroundPath, backgroundPaint);

    if (progress != null) {
      drawArc(270.0.radians, ((progress ?? 0) * 360).radians);
    } else {
      final arcStart = _startAngle +
          tailValue * 3 / 2 * math.pi +
          rotationValue * math.pi * 1.7 -
          stepValue * 0.8 * math.pi;
      final arcSweep =
          math.max(headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi, _epsilon);

      drawArc(arcStart, arcSweep);
    }
  }

  void drawArc(double start, double sweep) {
    final paint = Paint()
      ..color = color ?? Colors.black
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth!
      ..strokeCap = progress == 1.0 || !round! ? StrokeCap.butt : StrokeCap.round;

    final path = Path()
      ..reset()
      ..moveTo(width / 2, 0)
      ..addArc(rect, start, sweep);

    drawPath(
      path,
      paint
        ..blur(elevation)
        ..color = shadowColor!,
    );

    drawPath(
      path,
      paint
        ..blur(0.0)
        ..color = color!,
    );
  }
}

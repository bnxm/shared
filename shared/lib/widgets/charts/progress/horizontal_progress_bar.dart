part of 'progress_bar.dart';

const int _kIndeterminateLinearDuration = 1800;

class HorizontalProgressBar extends _ProgressBar {
  final EdgeInsets padding;
  const HorizontalProgressBar({
    Key? key,
    bool round = true,
    Color? color,
    Color? backgroundColor,
    Color? shadowColor,
    double? value,
    double strokeWidth = 2.0,
    double backgroundStrokeWidth = 2.0,
    double elevation = 0.0,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.ease,
    this.padding = EdgeInsets.zero,
  }) : super(
          key: key,
          round: round,
          color: color,
          backgroundColor: backgroundColor,
          shadowColor: shadowColor,
          size: 0.0,
          value: value,
          strokeWidth: strokeWidth,
          backgroundStrokeWidth: backgroundStrokeWidth,
          elevation: elevation,
          duration: duration,
          curve: curve,
        );

  @override
  _HorizontalProgressBarState createState() => _HorizontalProgressBarState();
}

class _HorizontalProgressBarState extends _ProgressBarState<HorizontalProgressBar> {
  @override
  Widget buildProgressBar(
    BuildContext context,
    Size size,
    ProgressBarData? data,
    double animationValue,
  ) {
    return AnimatedContainer(
      width: double.infinity,
      height: widget.strokeWidth,
      padding: widget.padding,
      duration: widget.duration,
      curve: widget.curve,
      child: CustomPaint(
        size: Size.infinite,
        painter: _HorizontalProgressPainter(
          data,
          animationValue,
          Directionality.of(context),
        ),
      ),
    );
  }
}

class _HorizontalProgressPainter extends _ProgressBarPainter {
  final TextDirection textDirection;
  _HorizontalProgressPainter(
    ProgressBarData? data,
    double animationValue,
    this.textDirection,
  ) : super(data, animationValue);

  // The indeterminate progress animation displays two lines whose leading (head)
  // and trailing (tail) endpoints are defined by the following four curves.
  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  double get capInset => round! ? strokeWidth! / 2 : 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    final backgroundPaint = Paint()
      ..color = backgroundColor!
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth!
      ..strokeCap = round! ? StrokeCap.round : StrokeCap.butt;

    final backgroundPath = Path()
      ..reset()
      ..moveTo(capInset, (height - capInset) / 2)
      ..lineTo(width - capInset, (height - capInset) / 2);

    drawPath(backgroundPath, backgroundPaint);

    if (progress != null) {
      drawBar(0.0, progress! * width);
    } else {
      final double x1 = width * line1Tail.transform(value);
      final double width1 = width * line1Head.transform(value) - x1;

      final double x2 = width * line2Tail.transform(value);
      final double width2 = width * line2Head.transform(value) - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
    }
  }

  void drawBar(double x, double width) {
    if (width <= 0.0) return;

    final paint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth!
      ..strokeCap = round! ? StrokeCap.round : StrokeCap.butt;

    final y = (height - capInset) / 2;

    late double dx;
    switch (textDirection) {
      case TextDirection.rtl:
        dx = this.width - width - x;
        break;
      case TextDirection.ltr:
        dx = x;
        break;
    }

    final path = Path()
      ..reset()
      ..moveTo(dx + capInset, y)
      ..lineTo(dx + width - capInset, y);

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

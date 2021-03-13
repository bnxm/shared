part of 'progress_bar.dart';

class RRectProgressBar extends _ProgressBar {
  final Widget? child;
  final Duration indeterminateDuration;
  final BorderRadiusGeometry borderRadius;
  final bool running;
  const RRectProgressBar({
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
    this.child,
    this.indeterminateDuration = const Duration(milliseconds: 1000),
    required this.borderRadius,
    this.running = true,
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
  _PathProgresBarState createState() => _PathProgresBarState();
}

class _PathProgresBarState extends _ProgressBarState<RRectProgressBar> {
  late AnimationController lengthController;
  late Animation lengthAnimation;

  @override
  Duration get indeterminateDuration => widget.indeterminateDuration;

  @override
  void initState() {
    super.initState();

    lengthController = AnimationController(
      duration: indeterminateDuration,
      vsync: this,
    );

    if (widget.running) {
      setInterval(0.125, 0.6);
      lengthController.repeat(reverse: true);
    } else {
      setInterval(0.125, 1.0);
      lengthController.value = 1.0;
      indeterminateController.stop();
    }
  }

  @override
  void didUpdateWidget(RRectProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    lengthController.duration = indeterminateDuration;

    if (widget.running) {
      setInterval(0.125, 0.6);
      lengthController.repeat(reverse: true);
    } else {
      setInterval(lengthController.value, 1.0);
      () async {
        await lengthController.forward(from: 0.0);
        if (!widget.running) {
          indeterminateController.stop();
        }
      }();
    }
  }

  void setInterval(double s, double e) {
    lengthAnimation = Tween(begin: s, end: e).animate(lengthController);
  }

  @override
  Widget buildProgressBar(
    BuildContext context,
    Size size,
    ProgressBarData? data,
    double animationValue,
  ) {
    return AnimatedBuilder(
      animation: lengthAnimation,
      builder: (context, child) {
        return CustomPaint(
          child: widget.child,
          foregroundPainter: _PathProgressPainter(
            data,
            animationValue,
            textDirection,
            lengthAnimation.value,
            widget.borderRadius.resolve(textDirection),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    lengthController.dispose();
    super.dispose();
  }
}

class _PathProgressPainter extends _ProgressBarPainter {
  final TextDirection textDirection;
  final double lengthValue;
  final BorderRadius borderRadius;
  _PathProgressPainter(
    ProgressBarData? data,
    double value,
    this.textDirection,
    this.lengthValue,
    this.borderRadius,
  ) : super(data, value);

  Path? path;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    path = Path()
      ..addRRect(
        RRect.fromLTRBAndCorners(
          0,
          0,
          size.width,
          size.height,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
        ).deflate(strokeWidth! / 2.0),
      );

    final backgroundPaint = Paint()
      ..color = backgroundColor!
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth!
      ..strokeCap = round! ? StrokeCap.round : StrokeCap.butt;

    drawPath(path, backgroundPaint);

    if (progress != null) {
      drawBar(0.0, progress);
    } else {
      final x = value;
      final xe = value + lengthValue;

      drawBar(x, xe);

      if (xe > 1.0) {
        drawBar(0.0, xe - 1.0);
      }
    }
  }

  void drawBar(double x, double? xe) {
    final paint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth!
      ..strokeCap = round! ? StrokeCap.round : StrokeCap.butt;

    final path = this.path!.trim(x, xe);

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

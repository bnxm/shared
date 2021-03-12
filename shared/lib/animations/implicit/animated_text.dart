import 'package:flutter/material.dart';

import 'package:shared/animations/animations.dart';

/// A Text widget that animates changes in its
/// TextStyle.
class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final InlineSpan? textSpan;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final Duration duration;
  final Curve curve;
  const AnimatedText(
    this.text, {
    Key? key,
    required this.style,
    this.textSpan,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow = TextOverflow.ellipsis,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    required this.duration,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImplicitAnimationBuilder<TextStyle?>(
      lerp: TextStyle.lerp,
      value: style,
      curve: curve,
      duration: duration,
      builder: (context, value, _) {
        return Text(
          text,
          style: value,
          locale: locale,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          strutStyle: strutStyle,
          semanticsLabel: semanticsLabel,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
        );
      },
    );
  }
}

/// A Text widget that animates changes in its
/// TextStyle and text.
class AnimatedSwitcherText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final InlineSpan? textSpan;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final Duration duration;
  final Curve curve;
  final AnimatedTextTransition transitionType;
  const AnimatedSwitcherText(
    this.text, {
    Key? key,
    required this.style,
    this.textSpan,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    required this.duration,
    this.curve = Curves.linear,
    this.transitionType = const FadeTextTransition(),
  }) : super(key: key);

  @override
  _AnimatedSwitcherText createState() => _AnimatedSwitcherText();
}

class _AnimatedSwitcherText extends State<AnimatedSwitcherText>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late Animation<double> animation = const HillTween().animate(
    controller,
  );

  late String text;
  late String oldText;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    oldText = widget.text;
  }

  @override
  void didUpdateWidget(AnimatedSwitcherText oldWidget) {
    super.didUpdateWidget(oldWidget);

    controller.duration = widget.duration;

    if (widget.text != oldWidget.text) {
      text = widget.text;
      oldText = oldWidget.text;

      controller
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = 1.0 - animation.value;

        final animatedText = AnimatedText(
          controller.value > 0.5 ? text : oldText,
          style: widget.style,
          duration: widget.duration,
          locale: widget.locale,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          softWrap: widget.softWrap,
          strutStyle: widget.strutStyle,
          semanticsLabel: widget.semanticsLabel,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          textScaleFactor: widget.textScaleFactor,
        );

        Alignment? alignment;
        switch (widget.textAlign ?? TextAlign.start) {
          case TextAlign.left:
          case TextAlign.start:
            alignment = Alignment.centerLeft;
            break;
          case TextAlign.right:
          case TextAlign.end:
            alignment = Alignment.centerRight;
            break;
          case TextAlign.center:
          case TextAlign.justify:
            alignment = Alignment.center;
            break;
        }

        return AnimatedSizeChanges(
          duration: widget.duration * 0.5,
          alignment: alignment,
          child: buildTransition(
            value,
            animatedText,
          ),
        );
      },
    );
  }

  Widget buildTransition(double t, Widget text) {
    final result = Opacity(
      opacity: t,
      child: text,
    );

    final type = widget.transitionType;
    if (type is TranslateFadeTextTransition) {
      final translation = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: type.up ? -1.0 : 1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: type.up ? 1.0 : -1.0, end: 0.0), weight: 1),
      ]).transform(controller.value);

      return FractionalTranslation(
        translation: Offset(0.0, translation),
        child: result,
      );
    }

    return result;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

abstract class AnimatedTextTransition {
  const AnimatedTextTransition();

  static const fade = FadeTextTransition();
  static const translateFadeUp = TranslateFadeTextTransition(up: true);
  static const translateFadeDown = TranslateFadeTextTransition(up: false);
}

class FadeTextTransition extends AnimatedTextTransition {
  const FadeTextTransition();
}

class TranslateFadeTextTransition extends AnimatedTextTransition {
  final bool up;
  const TranslateFadeTextTransition({
    this.up = false,
  });
}

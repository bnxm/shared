import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import 'scale_data.dart';

export 'scale_data.dart';

class Scale extends ImplicitAnimation {
  final List<ScaleEntry> data;
  final double thickness;
  final double spacing;
  final double labelSpacing;
  final TextStyle? labelStyle;
  final bool labelAbove;
  final bool indicatorOnTop;
  final bool spaceEvenly;
  final bool placeEdgeLabelsBetweenEntries;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Widget? indicator;
  final num indicatorValue;
  const Scale({
    Key? key,
    required Duration duration,
    Curve curve = Curves.ease,
    required this.data,
    this.thickness = 3.0,
    this.spacing = 0.0,
    this.labelSpacing = 4.0,
    this.labelStyle,
    this.labelAbove = false,
    this.indicatorOnTop = true,
    this.spaceEvenly = false,
    this.placeEdgeLabelsBetweenEntries = false,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.indicator,
    this.indicatorValue = 0,
  })  : assert(data != null),
        assert(thickness != null && thickness >= 0.0),
        assert(spacing != null && spacing >= 0.0),
        assert(labelSpacing != null && labelSpacing >= 0.0),
        super(key, duration, curve);

  @override
  ScaleState createState() => ScaleState();
}

class ScaleState extends ImplicitAnimationState<ScaleData, Scale> {
  @override
  ScaleData get newValue {
    return ScaleData(
      data: List.from(widget.data),
      spacing: widget.spacing,
      padding: widget.padding,
      thickness: widget.thickness,
      labelStyle: widget.labelStyle,
      labelSpacing: widget.labelSpacing,
      borderRadius: widget.borderRadius,
      indicatorValue: widget.indicatorValue,
    );
  }

  @override
  ScaleData lerp(ScaleData? a, ScaleData b, double t) => a!.scaleTo(b, t);

  ScaleData? get data => value;

  List<ScaleEntry> get entries => value.data;
  List<ScaleEntry> get activeEntries => entries.filter((item) => !item.isOutgoing);

  @override
  Widget builder(BuildContext context, ScaleData? data) {
    final prevEntries = entries.filter((item) => !item.isIncoming);
    final length = lerpDouble(prevEntries.length, activeEntries.length, v);

    final prevTotal = prevEntries.sumBy((entry) => entry.value);
    final newTotal = activeEntries.sumBy((entry) => entry.value);
    final total = lerpDouble(prevTotal, newTotal, v);

    return SizeBuilder(
      builder: (context, width, height) {
        final indicator = buildIndicator(width, total, length);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.indicatorOnTop) indicator,
            buildScale(width, total, length),
            if (!widget.indicatorOnTop) indicator,
          ],
        );
      },
    );
  }

  Widget buildScale(double width, double total, double length) {
    Widget buildEntry(int index) {
      final entry = entries[index];
      final f = entry.f(v);

      final hasSpacing = data!.spacing > 0.0;
      final isFirst = index == 0;
      final isLast = index == (activeEntries.length - 1);

      final bar = Container(
        height: data!.thickness,
        decoration: BoxDecoration(
          color: entry.color.scaleOpacity(f),
          borderRadius: BorderRadius.only(
            topLeft: isFirst || hasSpacing ? data!.borderRadius!.topLeft : Radius.zero,
            bottomLeft:
                isFirst || hasSpacing ? data!.borderRadius!.bottomLeft : Radius.zero,
            topRight: isLast || hasSpacing ? data!.borderRadius!.topRight : Radius.zero,
            bottomRight:
                isLast || hasSpacing ? data!.borderRadius!.bottomRight : Radius.zero,
          ),
        ),
      );

      Widget buildLabel(
        AlignmentGeometry alignment,
        String? label, {
        double offset = 0.0,
      }) {
        return Align(
          alignment: alignment,
          child: FractionalTranslation(
            translation: Offset(offset, 0.0),
            child: Text(
              label ?? '',
              style: entry.labelStyle,
            ),
          ),
        );
      }

      final labels = Stack(
        overflow: Overflow.visible,
        children: [
          buildLabel(
            AlignmentDirectional.centerStart,
            entry.startLabel,
            offset: widget.placeEdgeLabelsBetweenEntries && !isFirst ? -0.5 : 0.0,
          ),
          buildLabel(
            AlignmentDirectional.center,
            entry.label,
          ),
          buildLabel(
            AlignmentDirectional.centerEnd,
            entry.endLabel,
            offset: widget.placeEdgeLabelsBetweenEntries && !isLast ? 0.5 : 0.0,
          ),
        ],
      );

      final hasLabel = entries.any(
        (entry) => entry.hasLabel || entry.hasStartLabel || entry.hasEndLabel,
      );

      final labelAbove = widget.labelAbove && hasLabel;
      final labelBelow = !widget.labelAbove && hasLabel;

      final widthFactor = (widget.spaceEvenly ? 1 / length : entry.value / total) * f;
      final spacing = hasSpacing ? (data!.spacing / 2.0) * f : 0.0;

      return Container(
        width: width * widthFactor,
        padding: EdgeInsetsDirectional.only(
          start: !isFirst ? spacing : 0.0,
          end: !isLast ? spacing : 0.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelAbove) labels,
            if (labelAbove) SizedBox(height: value.labelSpacing),
            bar,
            if (labelBelow) SizedBox(height: value.labelSpacing),
            if (labelBelow) labels,
          ],
        ),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) buildEntry(i),
      ],
    );
  }

  Widget buildIndicator(double width, double total, double length) {
    final value = widget.indicatorValue;
    final totalFractionalSpacing = (data!.spacing * (length - 1)) / width;

    final translation = () {
          if (widget.indicator == null) return 0.0;

          if (widget.spaceEvenly) {
            final length = entries.length;
            for (var i = 0; i < length; i++) {
              final entry = entries[i];
              final prevEntry = entries.getOrElse(i - 1, entry);
              final prevValue = prevEntry.value;

              final t = (i + 1) / length;
              if (i == 0 && entry.value >= value) {
                return lerpDouble(0.0, t, value / entry.value);
              } else if (t == 1.0 && entry.value < value) {
                return 1.0;
              } else if (entry.value >= value && prevValue < value) {
                final t = i / length;
                final f = (value - prevValue) / (entry.value - prevValue);
                return t + (f * (1 / length));
              }
            }

            return 0.0;
          } else {
            return value / total;
          }
        }() *
        (1.0 - totalFractionalSpacing);

    final spacingToSkip = entries.let((it) {
      int i = 0;
      double amount = 0.0;

      for (final entry in it) {
        amount += entry.value;
        if (amount < value) {
          i++;
        }
      }

      return (data!.spacing * i) / width;
    });

    final num t = (translation + spacingToSkip).clamp(0.0, 1.0);

    return Visibility(
      visible: widget.indicator != null,
      child: AnimatedAlign(
        duration: duration,
        alignment: AlignmentDirectional(lerpDouble(-1.0, 1.0, t as double), 0.0),
        child: AnimatedTranslation(
          duration: duration,
          isFractional: true,
          translation: Offset(lerpDouble(-0.5, 0.5, t), 0.0),
          child: widget.indicator,
        ),
      ),
    );
  }
}

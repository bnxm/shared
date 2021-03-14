import 'package:flutter/material.dart';

import 'package:shared/shared.dart';
import 'package:shared/widgets/chart/base/chart.dart';

import 'scale_data.dart';

export 'scale_data.dart';

class Scale extends StatelessWidget {
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
  final Duration duration;
  final Curve curve;
  const Scale({
    Key? key,
    required this.data,
    this.duration = const Millis(500),
    this.curve = Curves.ease,
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
  })  : assert(thickness >= 0.0),
        assert(spacing >= 0.0),
        assert(labelSpacing >= 0.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartAnimationBuilder<ScaleData, ScaleEntry>(
      duration: duration,
      curve: Curves.ease,
      series: data,
      data: ScaleData(
        spacing: spacing,
        padding: padding,
        thickness: thickness,
        labelStyle: labelStyle,
        labelSpacing: labelSpacing,
        borderRadius: borderRadius,
        indicatorValue: indicatorValue,
      ),
      builder: (entries, data, f) {
        final length = entries.sumBy((item) => item.f);
        final total = entries.sumBy((item) => item.value * item.f);

        return SizeBuilder(
          builder: (context, width, height) {
            final indicator = buildIndicator(entries, data.spacing, width, total, length);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (indicatorOnTop) indicator,
                buildScale(data, entries, width, total, length),
                if (!indicatorOnTop) indicator,
              ],
            );
          },
        );
      },
    );
  }

  Widget buildScale(
    ScaleData data,
    List<ScaleEntry> entries,
    double width,
    double total,
    double length,
  ) {
    Widget buildEntry(int index) {
      final entry = entries[index];
      final f = entry.f;

      final hasSpacing = data.spacing > 0.0;
      final isFirst = entry == entries.find((item) => item.f == 1.0);
      final isLast = entry == entries.reversed.find((item) => item.f == 1.0);

      final bar = Container(
        height: data.thickness,
        decoration: BoxDecoration(
          color: entry.color.scaleOpacity(f),
          borderRadius: BorderRadius.only(
            topLeft: isFirst || hasSpacing ? data.borderRadius!.topLeft : Radius.zero,
            bottomLeft:
                isFirst || hasSpacing ? data.borderRadius!.bottomLeft : Radius.zero,
            topRight: isLast || hasSpacing ? data.borderRadius!.topRight : Radius.zero,
            bottomRight:
                isLast || hasSpacing ? data.borderRadius!.bottomRight : Radius.zero,
          ),
        ),
      );

      Widget buildLabel(
        AlignmentGeometry alignment,
        String? label, {
        double offset = 0.0,
      }) {
        return Expanded(
          flex: label != null ? 1 : 0,
          child: Align(
            alignment: alignment,
            child: FractionalTranslation(
              translation: Offset(offset, 0.0),
              child: Text(
                label ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: entry.labelStyle,
              ),
            ),
          ),
        );
      }

      final labels = Row(
        children: [
          buildLabel(
            AlignmentDirectional.centerStart,
            entry.startLabel,
            offset: placeEdgeLabelsBetweenEntries && !isFirst ? -0.5 : 0.0,
          ),
          buildLabel(
            AlignmentDirectional.center,
            entry.label,
          ),
          buildLabel(
            AlignmentDirectional.centerEnd,
            entry.endLabel,
            offset: placeEdgeLabelsBetweenEntries && !isLast ? 0.5 : 0.0,
          ),
        ],
      );

      final hasLabel = entries.any(
        (entry) => entry.hasLabel || entry.hasStartLabel || entry.hasEndLabel,
      );

      final labelAbove = this.labelAbove && hasLabel;
      final labelBelow = !labelAbove && hasLabel;

      final widthFactor = (spaceEvenly ? 1 / length : entry.value / total) * f;
      final spacing = hasSpacing ? (data.spacing / 2.0) * f : 0.0;

      return Opacity(
        opacity: 1.0,
        child: Container(
          width: width * widthFactor,
          padding: EdgeInsetsDirectional.only(
            start: !isFirst ? spacing : 0.0,
            end: !isLast ? spacing : 0.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (labelAbove) labels,
              if (labelAbove) SizedBox(height: data.labelSpacing),
              bar,
              if (labelBelow) SizedBox(height: data.labelSpacing),
              if (labelBelow) labels,
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) buildEntry(i),
      ],
    );
  }

  Widget buildIndicator(
    List<ScaleEntry> entries,
    double spacing,
    double width,
    double total,
    double length,
  ) {
    final value = indicatorValue;

    var translation = () {
      if (indicator == null) return 0.0;

      if (spaceEvenly) {
        final length = entries.length;
        for (var i = 0; i < length; i++) {
          final entry = entries[i];
          final prevEntry = entries.getOrElse(i - 1, entry);
          final prevValue = prevEntry.value;

          final t = (i + 1) / length;
          if (i == 0 && entry.value >= value) {
            return lerpDouble(0.0, t, value / entry.value)!;
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
    }();

    final totalFractionalSpacing = (spacing * (length - 1)) / width;
    translation *= 1.0 - totalFractionalSpacing;

    final spacingToSkip = entries.let((it) {
      var amount = 0.0, i = 0;

      for (final entry in it) {
        amount += entry.value;
        if (amount < value) i++;
      }

      return (spacing * i) / width;
    });

    final t = (translation + spacingToSkip).clamp(0.0, 1.0);

    return Visibility(
      visible: indicator != null,
      child: AnimatedAlign(
        duration: duration,
        alignment: AlignmentDirectional(lerpDouble(-1.0, 1.0, t)!, 0.0),
        child: AnimatedTranslation(
          duration: duration,
          curve: curve,
          isFractional: true,
          translation: Offset(lerpDouble(-0.5, 0.5, t)!, 0.0),
          child: indicator,
        ),
      ),
    );
  }
}

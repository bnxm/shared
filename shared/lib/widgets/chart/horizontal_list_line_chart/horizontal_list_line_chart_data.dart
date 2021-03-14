import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Gradient;

import 'package:shared/shared.dart';
import 'package:shared/widgets/chart/base/base.dart';

typedef ListLabelBuilder<T> = String Function(T value, int index);

typedef YAxisBuilder<T> = double Function(T value, int index);

class ListLineSeries<T> extends Series {
  final List<T> data;

  final List<Gradient>? stroke;

  /// A fill to be drawn below the stroke of this series.
  final List<Gradient>? fill;

  final List<Gradient>? divider;

  /// A shadow to be drawn below the stroke of this series.
  final List<Gradient>? shadow;

  final EdgeInsets? padding;

  final double? dividerThickness;

  /// The stroke width of the line.
  final double? thickness;

  /// The elevation or gaussian blur of the line.
  final double? elevation;

  final double? labelSpacing;

  final TextStyle? labelStyle;

  /// How the ends of the curve are rendered.
  final StrokeCap? strokeCap;

  /// How the joints are rendered.
  final StrokeJoin? strokeJoin;

  /// The factor between 0 and 1 by which to smooth the stroke using cubic beziers.
  final double? smoothFactor;

  /// The direction of the gradient of this series.
  final bool? verticalGradient;

  final bool? verticalFill;

  List<String>? labels;
  ListLineSeries({
    required this.data,
    required YAxisBuilder<T>? y,
    ListLabelBuilder<T>? labelBuilder,
    dynamic stroke,
    dynamic fill,
    dynamic divider,
    dynamic shadow,
    this.padding,
    this.dividerThickness,
    this.thickness,
    this.elevation,
    this.labelSpacing,
    this.labelStyle,
    this.strokeCap,
    this.strokeJoin,
    this.smoothFactor,
    this.verticalGradient,
    this.verticalFill,
  })  : stroke = stroke != null ? Gradients.from(stroke, data) : null,
        fill = fill != null ? Gradients.from(fill, data) : null,
        divider = divider != null ? Gradients.from(divider, data) : null,
        shadow = shadow != null ? Gradients.from(shadow, data) : null,
        values = y != null ? data.imap((i, d) => y(d, i)) : [],
        labels = labelBuilder != null ? data.imap((i, d) => labelBuilder(d, i)) : [];

  bool get hasStroke => stroke?.isOpaque == true;
  bool get hasFill => fill?.isOpaque == true;
  bool get hasDivider => divider?.isOpaque == true;
  bool get hasShadow => shadow?.isOpaque == true;

  List<double> values;

  ListLineSeries<T> scaleTo(ListLineSeries<T> b, double t) {
    return ListLineSeries<T>(
      data: b.data,
      y: null,
      stroke: stroke?.scaleTo(b.stroke!, t),
      fill: fill?.scaleTo(b.fill!, t),
      divider: divider?.scaleTo(b.divider!, t),
      shadow: shadow?.scaleTo(b.shadow!, t),
      padding: EdgeInsets.lerp(padding, b.padding, t),
      dividerThickness: lerpDouble(dividerThickness, b.dividerThickness, t),
      thickness: lerpDouble(thickness, b.thickness, t),
      elevation: lerpDouble(elevation, b.elevation, t),
      labelSpacing: lerpDouble(labelSpacing, b.labelSpacing, t),
      labelStyle: TextStyle.lerp(labelStyle, b.labelStyle, t),
      strokeCap: t < 0.5 ? strokeCap : b.strokeCap,
      strokeJoin: t < 0.5 ? strokeJoin : b.strokeJoin,
      smoothFactor: lerpDouble(smoothFactor, b.smoothFactor, t),
      verticalGradient: t < 0.5 ? verticalGradient : b.verticalGradient,
      verticalFill: t < 0.5 ? verticalFill : b.verticalFill,
    )
      ..values = lerpDoubles(values, b.values, t)
      ..labels = b.labels;
  }

  ListLineSeries<T> apply({
    required dynamic stroke,
    required dynamic fill,
    required dynamic divider,
    required dynamic shadow,
    required EdgeInsets? padding,
    required double? dividerThickness,
    required double? thickness,
    required double? elevation,
    required double? labelSpacing,
    required TextStyle? labelStyle,
    required StrokeCap? strokeCap,
    required StrokeJoin? strokeJoin,
    required double? smoothFactor,
    required bool? verticalGradient,
    required bool? verticalFill,
  }) {
    return ListLineSeries<T>(
      y: null,
      data: data,
      stroke: this.stroke ?? stroke,
      fill: this.fill ?? fill,
      divider: this.divider ?? divider,
      shadow: this.shadow ?? shadow,
      padding: this.padding ?? padding,
      dividerThickness: this.dividerThickness ?? dividerThickness,
      thickness: this.thickness ?? thickness,
      elevation: this.elevation ?? elevation,
      labelSpacing: this.labelSpacing ?? labelSpacing,
      labelStyle: this.labelStyle ?? labelStyle,
      strokeCap: this.strokeCap ?? strokeCap,
      strokeJoin: this.strokeJoin ?? strokeJoin,
      smoothFactor: this.smoothFactor ?? smoothFactor,
      verticalGradient: this.verticalGradient ?? verticalGradient,
      verticalFill: this.verticalFill ?? verticalFill,
    )
      ..values = values
      ..labels = labels;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListLineSeries<T> &&
        listEquals(other.stroke, stroke) &&
        listEquals(other.fill, fill) &&
        listEquals(other.divider, divider) &&
        listEquals(other.shadow, shadow) &&
        other.padding == padding &&
        other.dividerThickness == dividerThickness &&
        other.thickness == thickness &&
        other.elevation == elevation &&
        other.labelSpacing == labelSpacing &&
        other.labelStyle == labelStyle &&
        other.strokeCap == strokeCap &&
        other.strokeJoin == strokeJoin &&
        other.smoothFactor == smoothFactor &&
        other.verticalGradient == verticalGradient &&
        other.verticalFill == verticalFill &&
        other.labels == labels;
  }

  @override
  int get hashCode {
    return stroke.hashCode ^
        fill.hashCode ^
        divider.hashCode ^
        shadow.hashCode ^
        padding.hashCode ^
        dividerThickness.hashCode ^
        thickness.hashCode ^
        elevation.hashCode ^
        labelSpacing.hashCode ^
        labelStyle.hashCode ^
        strokeCap.hashCode ^
        strokeJoin.hashCode ^
        smoothFactor.hashCode ^
        verticalGradient.hashCode ^
        verticalFill.hashCode ^
        labels.hashCode;
  }
}

class ListLineChartData {
  final EdgeInsets innerPadding;
  final double minDelta;
  final double? min, max;
  final double itemExtent;
  ListLineChartData({
    required this.innerPadding,
    required this.minDelta,
    required this.min,
    required this.max,
    required this.itemExtent,
  });

  ListLineChartData scaleTo(ListLineChartData b, double t) {
    return ListLineChartData(
      innerPadding: EdgeInsets.lerp(innerPadding, b.innerPadding, t)!,
      minDelta: lerpDouble(minDelta, b.minDelta, t)!,
      max: lerpDouble(max, b.max, t),
      min: lerpDouble(min, b.min, t),
      itemExtent: lerpDouble(itemExtent, b.itemExtent, t)!,
    );
  }

  @override
  String toString() {
    return 'ListLineChartData(innerPadding: $innerPadding, minDelta: $minDelta, max: $max, itemExtent: $itemExtent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListLineChartData &&
        other.innerPadding == innerPadding &&
        other.minDelta == minDelta &&
        other.max == max &&
        other.min == min &&
        other.itemExtent == itemExtent;
  }

  @override
  int get hashCode =>
      innerPadding.hashCode ^
      minDelta.hashCode ^
      max.hashCode ^
      min.hashCode ^
      itemExtent.hashCode;
}

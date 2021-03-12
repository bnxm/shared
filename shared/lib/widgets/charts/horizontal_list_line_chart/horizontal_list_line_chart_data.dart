import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import '../lerp.dart';

typedef ListLabelBuilder<T> = String Function(T value, int index);

/// A data series for a [LineChart].
class ListLineSeries<T> extends CartesianSeries<T> {
  final List<List<Color>?>? color;

  /// A fill to be drawn below the stroke of this series.
  final List<List<Color>?>? fill;

  final List<List<Color>?>? divider;

  /// A shadow to be drawn below the stroke of this series.
  final List<List<Color>?>? shadow;

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

  final ListLabelBuilder<T>? labelBuilder;

  ListLineSeries({
    required List<T> data,

    /// A unique id representing this [ListLineSeries].
    /// Needed to be able to detect changes and animate between them.
    dynamic id,

    /// The label used for example in legends, etc.
    String? label,

    /// The color of this series.
    /// Must be either a [Color] meaning a solid fill, or a [List<Color>]
    /// meaning a gradient in the direction specified by [gradientDireciton].
    dynamic color,
    dynamic divider,

    /// A fill to be drawn below the stroke of this series.
    /// Must be either a [Color] meaning a solid fill, or a [List<Color>]
    /// meaning a gradient in the direction specified by [fillDirection].
    dynamic fill,

    /// A shadow to be drawn below the stroke of this series.
    /// Must be either a [Color] meaning a solid fill, or a [List<Color>]
    /// meaning a gradient in the direction specified by [gradientDirection].
    dynamic shadow,
    this.labelSpacing,
    this.labelStyle,
    this.padding,
    this.dividerThickness,
    this.thickness,
    this.elevation,
    this.strokeCap,
    this.strokeJoin,
    this.smoothFactor,
    this.verticalGradient,
    this.verticalFill,
    this.labelBuilder,
  })  : color = fillInColors(data, color),
        fill = fillInColors(data, fill),
        divider = fillInColors(data, divider),
        shadow = fillInColors(data, shadow),
        super(
          data: data,
          id: id,
          label: label,
        );

  bool get hasShadow => elevation! > 0 && shadow != null;
  bool get hasDivider => divider != null && dividerThickness! > 0.0;
  bool get hasFill => fill != null;

  List<Color>? getFill(int index) => fill!.getOrNull(index);
  List<Color>? getColor(int index) => color!.getOrNull(index);
  List<Color>? getShadow(int index) => shadow!.getOrNull(index);
  List<Color>? getDivider(int index) => divider!.getOrNull(index);

  static List<List<Color>?>? fillInColors<T>(List<T> data, dynamic color) {
    if (data.isEmpty || color == null) return null;

    if (color is List<List<Color>>) {
      return color;
    }

    List<Color>? _getColor(int index) {
      if (color is SeriesColorBuilder) {
        return dynamicToColors(
          color(data.getOrElse(index, data.lastOrNull!), index),
        );
      }

      return dynamicToColors(color);
    }

    final List<List<Color>?> result = [];

    for (var i = 0; i < data.length; i++) {
      result.add(_getColor(i));
    }

    return result;
  }

  static List<ListLineSeries<T>> lerp<T>(List<ListLineSeries<T>> a, List<ListLineSeries<T>> b, double v) {
    assert(v != null);

    List<List<Color?>?>? lerpColorMatrix(List<List<Color>?>? a, List<List<Color>?>? b, double v) {
      if (a == null || b == null) return b;

      final List<List<Color?>> result = [];

      for (var i = 0; i < max(a.length, b.length); i++) {
        final old = a.getOrElse(i, b.getOrNull(i))!;
        final current = b.getOrElse(i, a.getOrNull(i))!;
        result.add(lerpColors(old, current, v));
      }

      return result;
    }

    return lerpSeries<ListLineSeries<T>>(
      a,
      b,
      v,
      copyWith: (series) => series.copyWith(),
      staying: (old, current) {
        return current.copyWith(
          fill: lerpColorMatrix(old!.fill, current.fill, v),
          color: lerpColorMatrix(old.color, current.color, v),
          shadow: lerpColorMatrix(old.shadow, current.shadow, v),
          divider: lerpColorMatrix(old.divider, current.divider, v),
          padding: EdgeInsets.lerp(old.padding, current.padding, v),
          elevation: lerpDouble(old.elevation!, current.elevation!, v),
          thickness: lerpDouble(old.thickness!, current.thickness!, v),
          dividerThickness: lerpDouble(old.dividerThickness!, current.dividerThickness!, v),
          labelSpacing: lerpDouble(old.labelSpacing!, current.labelSpacing!, v),
          labelStyle: TextStyle.lerp(old.labelStyle, current.labelStyle, v),
          smoothFactor: lerpDouble(old.smoothFactor!, current.smoothFactor!, v),
        )..values = ChartValue.lerpAll(old.values, current.values, v);
      },
    );
  }

  void applyOnPaint(Paint paint) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness ?? thickness!
      ..strokeCap = strokeCap ?? strokeCap!
      ..strokeJoin = strokeJoin ?? strokeJoin!;
  }

  ListLineSeries<T> setDefaults({
    dynamic color,
    dynamic fill,
    dynamic shadow,
    dynamic divider,
    double? thickness,
    double? elevation,
    double? smoothFactor,
    double? labelSpacing,
    double? dividerThickness,
    EdgeInsets? padding,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    TextStyle? labelStyle,
    bool? verticalGradient,
    bool? verticalFill,
  }) {
    return copyWith(
      color: this.color ?? color,
      fill: this.fill ?? fill,
      shadow: this.shadow ?? shadow,
      divider: this.divider ?? divider,
      padding: this.padding ?? padding,
      elevation: this.elevation ?? elevation,
      thickness: this.thickness ?? thickness,
      labelStyle: this.labelStyle ?? labelStyle,
      strokeJoin: this.strokeJoin ?? strokeJoin,
      smoothFactor: this.smoothFactor ?? smoothFactor,
      labelSpacing: this.labelSpacing ?? labelSpacing,
      verticalFill: this.verticalFill ?? verticalFill,
      verticalGradient: this.verticalGradient ?? verticalGradient,
      dividerThickness: this.dividerThickness ?? dividerThickness,
    );
  }

  ListLineSeries<T> copyWith({
    List<T>? data,
    dynamic id,
    dynamic color,
    dynamic fill,
    dynamic shadow,
    dynamic divider,
    String? label,
    double? thickness,
    double? elevation,
    double? smoothFactor,
    double? labelSpacing,
    double? dividerThickness,
    EdgeInsets? padding,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    TextStyle? labelStyle,
    bool? verticalGradient,
    bool? verticalFill,
    ListLabelBuilder<T>? labelBuilder,
  }) {
    return ListLineSeries<T>(
      data: data ?? this.data,
      fill: fill ?? this.fill,
      color: color ?? this.color,
      divider: divider ?? this.divider,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      thickness: thickness ?? this.thickness,
      elevation: elevation ?? this.elevation,
      shadow: shadow ?? this.shadow,
      padding: padding ?? this.padding,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      smoothFactor: smoothFactor ?? this.smoothFactor,
      label: label ?? this.label,
      labelStyle: labelStyle ?? this.labelStyle,
      labelSpacing: labelSpacing ?? this.labelSpacing,
      verticalFill: verticalFill ?? this.verticalFill,
      verticalGradient: verticalGradient ?? this.verticalGradient,
      labelBuilder: labelBuilder ?? this.labelBuilder,
      id: id ?? this.id,
    )
      ..values = values
      ..state = state;
  }

  @override
  bool operator ==(dynamic o) {
    if (identical(this, o)) return true;
    if (id == null || o.id == null) return false;

    return o is ListLineSeries && o.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class ListLineChartData<T> extends ChartData<T> {
  final List<ListLineSeries<T>> series;
  final EdgeInsets? innerPadding;
  final num? minDelta;
  ListLineChartData({
    required this.series,
    required this.innerPadding,
    required this.minDelta,
  });

  @override
  ChartData<T> scaleTo(ChartData<T>? b, double v) {
    if (b is ListLineChartData<T>) {
      return ListLineChartData(
        series: ListLineSeries.lerp<T>(series, b.series, v),
        innerPadding: EdgeInsets.lerp(innerPadding, b.innerPadding, v),
        minDelta: lerpDouble(minDelta!, b.minDelta!, v),
      );
    } else {
      throw 'Illegal state';
    }
  }

  ListLineChartData<T> copyWith({
    List<ListLineSeries<T>>? series,
    EdgeInsets? innerPadding,
    num? minDelta,
  }) {
    return ListLineChartData<T>(
      series: series ?? this.series,
      innerPadding: innerPadding ?? this.innerPadding,
      minDelta: minDelta,
    );
  }

  @override
  String toString() => 'ListLineChartData(series: $series, innerPadding: $innerPadding, minDelta: $minDelta)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListLineChartData<T> && o.series == series && o.innerPadding == innerPadding && o.minDelta == minDelta;
  }

  @override
  int get hashCode => series.hashCode ^ innerPadding.hashCode ^ minDelta.hashCode;
}

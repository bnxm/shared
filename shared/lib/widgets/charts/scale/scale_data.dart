import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ScaleEntry {
  final num value;
  final Color color;
  final Color shadow;
  final String? label;
  final String? endLabel;
  final String? startLabel;
  final double elevation;
  final TextStyle? labelStyle;
  ScaleEntry({
    Color? shadow,
    required this.value,
    required this.color,
    dynamic label,
    dynamic startLabel,
    dynamic endLabel,
    this.elevation = 0.0,
    this.labelStyle,
  })  : shadow = shadow ?? color,
        label = label?.toString(),
        startLabel = startLabel?.toString(),
        endLabel = endLabel?.toString(),
        assert(value != null),
        assert(color != null),
        assert(elevation != null);

  bool isIncoming = false;
  bool isOutgoing = false;

  double f(double t) => isIncoming ? t : isOutgoing ? 1.0 - t : 1.0;

  bool get hasShadow => elevation > 0.0;
  bool get hasStartLabel => startLabel != null;
  bool get hasCenterLabel => label != null;
  bool get hasEndLabel => endLabel != null;
  bool get hasLabel => hasStartLabel || hasCenterLabel || hasEndLabel;

  static List<ScaleEntry> lerp(List<ScaleEntry> a, List<ScaleEntry> b, double t) {
    final List<ScaleEntry> result = [];

    a.removeWhere((element) => element.isOutgoing);

    for (var i = 0; i < math.max(a.length, b.length); i++) {
      ScaleEntry begin;
      if (i < a.length) {
        begin = a[i]
          ..isOutgoing = false
          ..isIncoming = false;
      } else {
        begin = b[i].copyWith(value: 0)
          ..isOutgoing = false
          ..isIncoming = true;
      }

      ScaleEntry end;
      if (i < b.length) {
        end = b[i]
          ..isOutgoing = false
          ..isIncoming = false;
      } else {
        end = a[i].copyWith(value: 0)
          ..isIncoming = false
          ..isOutgoing = true;
      }

      if (end != null) {
        result.add(
          begin.scaleTo(end, t),
        );
      }
    }

    return result;
  }

  ScaleEntry scaleTo(ScaleEntry b, double t) {
    return ScaleEntry(
      value: lerpDouble(value, b.value, t),
      color: Color.lerp(color, b.color, t)!,
      shadow: Color.lerp(shadow, b.shadow, t),
      elevation: lerpDouble(elevation, b.elevation, t),
      label: t <= 0.5 ? label : b.label,
      startLabel: t <= 0.5 ? startLabel : b.startLabel,
      endLabel: t <= 0.5 ? endLabel : b.endLabel,
      labelStyle: TextStyle.lerp(labelStyle, b.labelStyle, t),
    )
      ..isIncoming = b.isIncoming
      ..isOutgoing = b.isOutgoing;
  }

  ScaleEntry copyWith({
    num? value,
    Color? color,
    Color? shadow,
    String? label,
    String? endLabel,
    String? startLabel,
    double? elevation,
    TextStyle? labelStyle,
  }) {
    return ScaleEntry(
      value: value ?? this.value,
      color: color ?? this.color,
      shadow: shadow ?? this.shadow,
      label: label ?? this.label,
      endLabel: endLabel ?? this.endLabel,
      startLabel: startLabel ?? this.startLabel,
      elevation: elevation ?? this.elevation,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  String toString() {
    return 'ScaleEntry(value: $value, color: $color, shadow: $shadow, label: $label, endLabel: $endLabel, startLabel: $startLabel, elevation: $elevation, labelStyle: $labelStyle)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ScaleEntry &&
        o.value == value &&
        o.color == color &&
        o.shadow == shadow &&
        o.label == label &&
        o.endLabel == endLabel &&
        o.startLabel == startLabel &&
        o.elevation == elevation &&
        o.labelStyle == labelStyle;
  }

  @override
  int get hashCode {
    return value.hashCode ^
        color.hashCode ^
        shadow.hashCode ^
        label.hashCode ^
        endLabel.hashCode ^
        startLabel.hashCode ^
        elevation.hashCode ^
        labelStyle.hashCode;
  }
}

class ScaleData {
  final List<ScaleEntry> data;
  final double spacing;
  final double thickness;
  final double labelSpacing;
  final num indicatorValue;
  final EdgeInsets? padding;
  final TextStyle? labelStyle;
  final BorderRadius? borderRadius;
  ScaleData({
    required this.data,
    required this.spacing,
    required this.thickness,
    required this.labelSpacing,
    required this.indicatorValue,
    required this.padding,
    required this.labelStyle,
    required this.borderRadius,
  });

  ScaleData scaleTo(ScaleData b, double t) {
    return ScaleData(
      data: ScaleEntry.lerp(data, b.data, t),
      spacing: lerpDouble(spacing, b.spacing, t),
      padding: EdgeInsets.lerp(padding, b.padding, t),
      thickness: lerpDouble(thickness, b.thickness, t),
      labelStyle: TextStyle.lerp(labelStyle, b.labelStyle, t),
      labelSpacing: lerpDouble(labelSpacing, b.labelSpacing, t),
      borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t),
      indicatorValue: lerpDouble(indicatorValue, b.indicatorValue, t),
    );
  }

  ScaleData copyWith({
    List<ScaleEntry>? data,
    double? spacing,
    double? thickness,
    double? labelSpacing,
    num? indicatorValue,
    EdgeInsets? padding,
    TextStyle? labelStyle,
    BorderRadius? borderRadius,
  }) {
    return ScaleData(
      data: data ?? this.data,
      spacing: spacing ?? this.spacing,
      thickness: thickness ?? this.thickness,
      labelSpacing: labelSpacing ?? this.labelSpacing,
      indicatorValue: indicatorValue ?? this.indicatorValue,
      padding: padding ?? this.padding,
      labelStyle: labelStyle ?? this.labelStyle,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  String toString() {
    return 'ScaleData(data: $data, spacing: $spacing, thickness: $thickness, labelSpacing: $labelSpacing, indicatorValue: $indicatorValue, padding: $padding, labelStyle: $labelStyle, borderRadius: $borderRadius)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ScaleData &&
        listEquals(o.data, data) &&
        o.spacing == spacing &&
        o.thickness == thickness &&
        o.labelSpacing == labelSpacing &&
        o.indicatorValue == indicatorValue &&
        o.padding == padding &&
        o.labelStyle == labelStyle &&
        o.borderRadius == borderRadius;
  }

  @override
  int get hashCode {
    return data.hashCode ^
        spacing.hashCode ^
        thickness.hashCode ^
        labelSpacing.hashCode ^
        indicatorValue.hashCode ^
        padding.hashCode ^
        labelStyle.hashCode ^
        borderRadius.hashCode;
  }
}

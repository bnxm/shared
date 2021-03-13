import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:shared/widgets/chart/base/base.dart';

class ScaleEntry extends Series {
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
        endLabel = endLabel?.toString();

  bool get hasShadow => elevation > 0.0;
  bool get hasStartLabel => startLabel != null;
  bool get hasCenterLabel => label != null;
  bool get hasEndLabel => endLabel != null;
  bool get hasLabel => hasStartLabel || hasCenterLabel || hasEndLabel;

  ScaleEntry scaleTo(ScaleEntry b, double t) {
    return ScaleEntry(
      value: lerpDouble(value, b.value, t)!,
      color: Color.lerp(color, b.color, t)!,
      shadow: Color.lerp(shadow, b.shadow, t),
      elevation: lerpDouble(elevation, b.elevation, t)!,
      label: t <= 0.5 ? label : b.label,
      startLabel: t <= 0.5 ? startLabel : b.startLabel,
      endLabel: t <= 0.5 ? endLabel : b.endLabel,
      labelStyle: TextStyle.lerp(labelStyle, b.labelStyle, t),
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
  final double spacing;
  final double thickness;
  final double labelSpacing;
  final num indicatorValue;
  final EdgeInsets? padding;
  final TextStyle? labelStyle;
  final BorderRadius? borderRadius;
  ScaleData({
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
      spacing: lerpDouble(spacing, b.spacing, t)!,
      padding: EdgeInsets.lerp(padding, b.padding, t),
      thickness: lerpDouble(thickness, b.thickness, t)!,
      labelStyle: TextStyle.lerp(labelStyle, b.labelStyle, t),
      labelSpacing: lerpDouble(labelSpacing, b.labelSpacing, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t),
      indicatorValue: lerpDouble(indicatorValue, b.indicatorValue, t)!,
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
    return 'ScaleData(spacing: $spacing, thickness: $thickness, labelSpacing: $labelSpacing, indicatorValue: $indicatorValue, padding: $padding, labelStyle: $labelStyle, borderRadius: $borderRadius)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ScaleData &&
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
    return spacing.hashCode ^
        thickness.hashCode ^
        labelSpacing.hashCode ^
        indicatorValue.hashCode ^
        padding.hashCode ^
        labelStyle.hashCode ^
        borderRadius.hashCode;
  }
}

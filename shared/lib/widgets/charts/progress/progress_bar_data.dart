import 'dart:convert';
import 'dart:ui';

class ProgressBarData {
  final double? progress;
  final double? strokeWidth;
  final double? size;
  final double? backgroundStrokeWidth;
  final double? elevation;
  final Color? color;
  final Color? backgroundColor;
  final Color? shadowColor;
  final bool? round;
  const ProgressBarData({
    this.progress,
    this.strokeWidth,
    this.size,
    this.backgroundStrokeWidth,
    this.elevation,
    this.color,
    this.backgroundColor,
    this.shadowColor,
    this.round,
  });

  ProgressBarData scaleTo(ProgressBarData b, double t) {
    return ProgressBarData(
      size: lerpDouble(size, b.size, t),
      color: Color.lerp(color, b.color, t),
      round: t < 0.5 ? round : b.round,
      progress: b.progress == null ? null : lerpDouble(progress, b.progress, t),
      elevation: lerpDouble(elevation, b.elevation, t),
      strokeWidth: lerpDouble(strokeWidth, b.strokeWidth, t),
      shadowColor: Color.lerp(shadowColor, b.shadowColor, t),
      backgroundColor: Color.lerp(backgroundColor, b.backgroundColor, t),
      backgroundStrokeWidth: lerpDouble(backgroundStrokeWidth, b.backgroundStrokeWidth, t),
    );
  }

  ProgressBarData copyWith({
    double? progress,
    double? strokeWidth,
    double? size,
    double? backgroundStrokeWidth,
    double? elevation,
    Color? color,
    Color? backgroundColor,
    Color? shadowColor,
    bool? round,
  }) {
    return ProgressBarData(
      progress: progress ?? this.progress,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      size: size ?? this.size,
      backgroundStrokeWidth: backgroundStrokeWidth ?? this.backgroundStrokeWidth,
      elevation: elevation ?? this.elevation,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      round: round ?? this.round,
    );
  }

  @override
  String toString() {
    return 'ProgressBarData(progress: $progress, strokeWidth: $strokeWidth, size: $size, backgroundStrokeWidth: $backgroundStrokeWidth, elevation: $elevation, color: $color, backgroundColor: $backgroundColor, shadowColor: $shadowColor, round: $round)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ProgressBarData &&
        o.progress == progress &&
        o.strokeWidth == strokeWidth &&
        o.size == size &&
        o.backgroundStrokeWidth == backgroundStrokeWidth &&
        o.elevation == elevation &&
        o.color == color &&
        o.backgroundColor == backgroundColor &&
        o.shadowColor == shadowColor &&
        o.round == round;
  }

  @override
  int get hashCode {
    return progress.hashCode ^
        strokeWidth.hashCode ^
        size.hashCode ^
        backgroundStrokeWidth.hashCode ^
        elevation.hashCode ^
        color.hashCode ^
        backgroundColor.hashCode ^
        shadowColor.hashCode ^
        round.hashCode;
  }
}

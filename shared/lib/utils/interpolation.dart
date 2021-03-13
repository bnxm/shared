import 'package:shared/shared.dart';

double interval(num begin, num end, num value) {
  return ((value - begin) / (end - begin)).clamp(0.0, 1.0);
}

List<T> lerpAll<T>(List<T> a, List<T> b, T Function(T a, T b) lerp) {
  return [
    for (var i = 0; i < b.length; i++) lerp(a.getOrElse(i, a.last), b[i]),
  ];
}

List<double> lerpDoubles(List<double> a, List<double> b, double t) {
  return lerpAll(a, b, (a, b) => lerpDouble(a, b, t)!);
}

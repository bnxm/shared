import 'dart:math';

export 'di.dart';
export 'handler.dart';
export 'logger.dart';
export 'lorem_ipsum.dart';
export 'pair.dart';
export 'time.dart';

void unawaited(Future future) {}

Future<void> delayed(Duration delay) => Future.delayed(delay);

double random({double min = 0.0, double max = 1.0}) {
  final r = Random().nextDouble();
  return ((max - min) * r) + min;
}

int randomInt({int min = 0, int max = 100}) {
  final r = Random().nextInt(max);
  return min + (r - 1);
}

double lerpDouble(num a, num b, double t) => a + (b - a) * t;
int lerpInt(num a, num b, double t) => lerpDouble(a, b, t).round();

T lerp<T>(T a, T b, double t) {
  if (T is double) {
    return lerpDouble(a as double, b as double, t) as T;
  } else if (T is int) {
    return lerpInt(a as int, b as int, t) as T;
  } else {
    throw ArgumentError('$T is not cannot be interpolated!');
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  test('Should interpolate between two double lists', () async {
    // arrange
    final a = [1.0, 2.0, 3.0];
    final b = [2.0, 1.0];
    // act
    final c = lerpDoubles(a, b, 0.5);
    // assert
    expect(c, [1.5, 1.5]);
  });
}

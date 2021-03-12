import 'package:unit_convert/unit_convert.dart';

import '../lat_long.dart';
import 'haversine.dart';
import 'vincenty.dart';

export 'haversine.dart';
export 'vincenty.dart';

/// Equator radius in meter (WGS84 ellipsoid)
const double equatorRadius = 6378137.0;

/// Earth radius in meter
const double earthRadius = equatorRadius;

/// Polar radius in meter (WGS84 ellipsoid)
const double polarRadius = 6356752.314245;

/// WGS84
const double flattening = 1 / 298.257223563;

abstract class DistanceCalculator {
  double distance(final LatLng p1, final LatLng p2);
  LatLng offset(final LatLng from, final double distanceInMeter, final double bearing);
}

class Distance implements DistanceCalculator {
  final double _radius;
  final DistanceCalculator _calculator;

  const Distance({
    final DistanceCalculator calculator = const Vincenty(),
  })  : _radius = earthRadius,
        _calculator = calculator;

  Distance.withRadius(
    final double radius, {
    final DistanceCalculator calculator = const Vincenty(),
  })  : _radius = radius,
        _calculator = calculator,
        assert(radius > 0, "Radius must be greater than 0 but was $radius");

  double get radius => _radius;

  /// Returns either [Haversine] oder [Vincenty] calculator
  ///
  ///     final Distance distance = const DistanceHaversine();
  ///     final Circle circle = new Circle(base, 1000.0,calculator: distance.calculator);
  ///
  DistanceCalculator get calculator => _calculator;

  /// Converts the distance to the given [LengthUnit]
  ///
  ///     final int km = distance.as(LengthUnit.Kilometer,
  ///         new LatLng(52.518611,13.408056),new LatLng(51.519475,7.46694444));
  ///
  double as(LengthConverter unit, LatLng p1, LatLng p2) {
    final double dist = _calculator.distance(p1, p2);
    return LengthUnit.meter.to(unit, dist);
  }

  /// Computes the distance between two points.
  ///
  /// The function uses the [DistanceAlgorithm] specified in the CTOR
  @override
  double distance(final LatLng p1, final LatLng p2) => _calculator.distance(p1, p2);

  /// Returns a destination point based on the given [distance] and [bearing]
  ///
  /// Given a [from] (start) point, initial [bearing], and [distance],
  /// this will calculate the destination point and
  /// final bearing travelling along a (shortest distance) great circle arc.
  ///
  ///     final Distance distance = const Distance();
  ///
  ///     final num distanceInMeter = (EARTH_RADIUS * math.PI / 4).round();
  ///
  ///     final p1 = new LatLng(0.0, 0.0);
  ///     final p2 = distance.offset(p1, distanceInMeter, 180);
  ///
  /// Bearing: Left - 270°, right - 90°, up - 0°, down - 180°
  @override
  LatLng offset(final LatLng from, final num distanceInMeter, final num bearing) =>
      _calculator.offset(from, distanceInMeter.toDouble(), bearing.toDouble());
}

enum DistanceAlgorithm {
  vincenty,
  haversine,
}

class DistanceVincenty extends Distance {
  const DistanceVincenty()
      : super(
          calculator: const Vincenty(),
        );

  DistanceVincenty.withRadius(final double radius)
      : assert(radius > 0, 'Radius must be greater than 0 but was $radius'),
        super.withRadius(
          radius,
          calculator: const Vincenty(),
        );
}

class DistanceHaversine extends Distance {
  const DistanceHaversine()
      : super(
          calculator: const Haversine(),
        );

  DistanceHaversine.withRadius(
    final double radius,
  )   : assert(radius > 0, 'Radius must be greater than 0 but was $radius'),
        super.withRadius(
          radius,
          calculator: const Haversine(),
        );
}

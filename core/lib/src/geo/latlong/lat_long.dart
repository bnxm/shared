import 'dart:convert';
import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:intl/intl.dart';

import 'distance/distance.dart';

export 'distance/distance.dart';

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(
    this.latitude,
    this.longitude,
  )   : assert(
          latitude >= -90.0 && latitude <= 90.0,
          'Latitude must be between -90 and 90 degrees but was $latitude',
        ),
        assert(
          longitude >= -180.0 && longitude <= 180.0,
          'Longitude must be between -180 and 180 degrees but was $longitude',
        );

  factory LatLng.tryParse(String src) {
    final coordinates = src.split(',').map((e) => double.tryParse(e.trim())).toList();

    final isValid = coordinates.length == 2 || !coordinates.contains(null);
    if (!isValid) return null;

    final isLatitudeValid = coordinates[0] >= -90.0 && coordinates[0] <= 90.0;
    final isLongitudeValid = coordinates[1] >= -180.0 && coordinates[1] <= 180.0;
    if (!(isLatitudeValid && isLongitudeValid)) return null;

    return LatLng(coordinates[0], coordinates[1]);
  }

  static const LatLng primeMeridian = LatLng(0.0, 0.0);

  LatLng scaleTo(LatLng b, double t) {
    return LatLng(
      lerpDouble(latitude, b.latitude, t),
      lerpDouble(longitude, b.longitude, t),
    );
  }

  double get latitudeInRad => latitude.radians;
  double get longitudeInRad => longitude.radians;

  double bearingTo(LatLng latLng) {
    final diffLongitude = latLng.longitudeInRad - longitudeInRad;

    final y = math.sin(diffLongitude);
    final x = math.cos(latitudeInRad) * math.tan(latLng.latitudeInRad) -
        math.sin(latitudeInRad) * math.cos(diffLongitude);

    return (math.atan2(y, x) % 360.0).degrees;
  }

  double distanceTo(
    LatLng latLng, {
    LengthUnit unit = LengthUnit.meter,
    DistanceAlgorithm algorithm = DistanceAlgorithm.vincenty,
  }) {
    final Distance distance = algorithm == DistanceAlgorithm.vincenty
        ? const DistanceVincenty()
        : DistanceHaversine;
    return distance.as(unit, this, latLng);
  }

  @override
  String toString() => 'LatLng(latitude: $latitude, longitude: $longitude)';

  /// Converts lat/long values into sexagesimal
  ///
  /// LatLng(51.519475, -19.37555556);
  /// Shows: 51° 31' 10.11" N, 19° 22' 32.00" W
  String toSexagesimal() {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lonDirection = longitude >= 0 ? 'E' : 'W';
    return '${decimal2sexagesimal(latitude)} $latDirection, ${decimal2sexagesimal(longitude)} $lonDirection';
  }

  LatLng round({final int decimals = 6}) => LatLng(
        _round(latitude, decimals: decimals),
        _round(longitude, decimals: decimals),
      );

  double _round(final double value, {final int decimals = 6}) {
    return (value * math.pow(10, decimals)).round() / math.pow(10, decimals);
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static LatLng fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return LatLng(
      (map['latitude'] ?? map['lat'])?.toDouble() ?? 0.0,
      (map['longitude'] ?? map['lng'] ?? map['long'])?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  static LatLng fromJson(String source) => fromMap(json.decode(source));

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is LatLng && o.latitude == latitude && o.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

String decimal2sexagesimal(final double dec) {
  List<int> _split(final double value) {
    final tmp = value.toString().split('.');

    return <int>[
      int.parse(tmp[0]).abs(),
      int.parse(tmp[1]),
    ];
  }

  final parts = _split(dec);
  final integerPart = parts[0];
  final fractionalPart = parts[1];

  final deg = integerPart;
  final min = double.parse('0.$fractionalPart') * 60;

  final minParts = _split(min);
  final minFractionalPart = minParts[1];

  final sec = double.parse('0.$minFractionalPart') * 60;

  return "$deg° ${min.floor()}' ${sec.toStringAsFixed(2)}\"";
}

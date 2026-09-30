import 'package:geohash_bounds/geohash_bounds.dart';

class ParkingGeohash {
  const ParkingGeohash._();

  static const int precision = 10;

  static String encode({
    required double latitude,
    required double longitude,
  }) {
    return GeohashUtil.encode(
      latitude,
      longitude,
      precision: precision,
    );
  }
}

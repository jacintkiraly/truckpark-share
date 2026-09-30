import 'package:equatable/equatable.dart';

class ParkingViewport extends Equatable {
  const ParkingViewport({
    required this.southWestLatitude,
    required this.southWestLongitude,
    required this.northEastLatitude,
    required this.northEastLongitude,
  });

  final double southWestLatitude;
  final double southWestLongitude;
  final double northEastLatitude;
  final double northEastLongitude;

  bool contains({
    required double latitude,
    required double longitude,
  }) {
    final latInside =
        latitude >= southWestLatitude &&
        latitude <= northEastLatitude;

    if (!latInside) {
      return false;
    }

    final swLng = _wrapLongitude(southWestLongitude);
    final neLng = _wrapLongitude(northEastLongitude);
    final pointLng = _wrapLongitude(longitude);

    // Normal viewport.
    if (swLng <= neLng) {
      return pointLng >= swLng && pointLng <= neLng;
    }

    // Antimeridian-crossing viewport.
    return pointLng >= swLng || pointLng <= neLng;
  }

  double _wrapLongitude(double longitude) {
    var result = longitude % 360;

    if (result > 180) {
      result -= 360;
    }

    if (result < -180) {
      result += 360;
    }

    return result;
  }

  @override
  List<Object?> get props => [
        southWestLatitude,
        southWestLongitude,
        northEastLatitude,
        northEastLongitude,
      ];
}

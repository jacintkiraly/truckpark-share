import 'dart:math';

import '../models/driver_location.dart';

class DriverLocationFilter {
  const DriverLocationFilter({
    this.maxAccuracyMeters = 100,
    this.maxSpeedKmh = 180,
  });

  static const double _earthRadiusMeters = 6371000;

  final double maxAccuracyMeters;
  final double maxSpeedKmh;

  bool shouldAccept({
    required DriverLocation? previous,
    required DriverLocation candidate,
  }) {
    if (!_isValidAccuracy(candidate.accuracy)) {
      return false;
    }

    if (candidate.accuracy > maxAccuracyMeters) {
      return false;
    }

    if (previous == null) {
      return true;
    }

    final elapsedSeconds =
        candidate.timestamp
            .difference(previous.timestamp)
            .inMicroseconds /
        Duration.microsecondsPerSecond;

    if (elapsedSeconds <= 0) {
      return false;
    }

    final distanceMeters = _distanceMeters(
      previous.latitude,
      previous.longitude,
      candidate.latitude,
      candidate.longitude,
    );

    final speedKmh =
        distanceMeters / elapsedSeconds * 3.6;

    return speedKmh <= maxSpeedKmh;
  }

  bool _isValidAccuracy(double accuracy) {
    return accuracy.isFinite && accuracy >= 0;
  }

  double _distanceMeters(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    final lat1 = _toRadians(latitude1);
    final lat2 = _toRadians(latitude2);

    final deltaLat =
        _toRadians(latitude2 - latitude1);

    final deltaLongitude =
        _toRadians(longitude2 - longitude1);

    final sinLat =
        sin(deltaLat / 2);
    final sinLongitude =
        sin(deltaLongitude / 2);

    final a =
        sinLat * sinLat +
        cos(lat1) *
            cos(lat2) *
            sinLongitude *
            sinLongitude;

    final c =
        2 * atan2(
          sqrt(a),
          sqrt(1 - a),
        );

    return _earthRadiusMeters * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}

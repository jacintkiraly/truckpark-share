import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driver_location.dart';
import '../models/location_result.dart';

class LocationService {
  static const LocationSettings _locationSettings =
      LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return const LocationResult.serviceDisabled();
      }

      var permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult.permissionDenied();
      }

      if (permission ==
          LocationPermission.deniedForever) {
        return const LocationResult.permissionDeniedForever();
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );

      return LocationResult.available(
        _toDriverLocation(position),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to get current location: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return const LocationResult.error();
    }
  }

  Stream<DriverLocation> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).map(_toDriverLocation);
  }

  DriverLocation _toDriverLocation(
    Position position,
  ) {
    final headingIsValid =
        position.heading.isFinite &&
        position.heading >= 0 &&
        position.heading < 360 &&
        position.headingAccuracy.isFinite &&
        position.headingAccuracy >= 0;

    return DriverLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      heading:
          headingIsValid ? position.heading : null,
      headingAccuracy:
          headingIsValid
              ? position.headingAccuracy
              : null,
    );
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }
}

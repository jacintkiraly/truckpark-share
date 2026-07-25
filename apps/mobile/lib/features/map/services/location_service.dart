import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driver_location.dart';
import '../models/location_result.dart';

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return const LocationResult.serviceDisabled();
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult.permissionDenied();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.permissionDeniedForever();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return LocationResult.available(
        DriverLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        ),
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

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }
}
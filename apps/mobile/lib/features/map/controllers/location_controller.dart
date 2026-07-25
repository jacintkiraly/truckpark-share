import 'package:flutter/foundation.dart';

import '../models/driver_location.dart';
import '../models/location_status.dart';
import '../services/location_service.dart';

class LocationController extends ChangeNotifier {
  LocationController({
    LocationService? locationService,
  }) : _locationService =
            locationService ?? LocationService();

  final LocationService _locationService;

  LocationStatus _status = LocationStatus.initial;
  DriverLocation? _location;

  LocationStatus get status => _status;

  DriverLocation? get location => _location;

  bool get isLoading =>
      _status == LocationStatus.loading;

  bool get hasLocation =>
      _status == LocationStatus.available &&
      _location != null;

  Future<void> loadCurrentLocation() async {
    if (isLoading) return;

    _setStatus(LocationStatus.loading);

    final result =
        await _locationService.getCurrentLocation();

    _location = result.location;
    _setStatus(result.status);
  }

  Future<void> retry() {
    return loadCurrentLocation();
  }

  Future<bool> openLocationSettings() {
    return _locationService.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return _locationService.openAppSettings();
  }

  void _setStatus(LocationStatus value) {
    if (_status == value) return;

    _status = value;
    notifyListeners();
  }
}
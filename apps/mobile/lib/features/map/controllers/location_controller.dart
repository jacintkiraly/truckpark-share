import 'dart:async';

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

  LocationStatus _status =
      LocationStatus.initial;

  DriverLocation? _location;

  StreamSubscription<DriverLocation>?
      _locationSubscription;

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

    if (result.hasLocation) {
      await _startWatchingLocation();
    } else {
      await _stopWatchingLocation();
    }
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

  Future<void> _startWatchingLocation() async {
    await _locationSubscription?.cancel();

    _locationSubscription =
        _locationService.watchLocation().listen(
      (location) {
        _location = location;

        if (_status != LocationStatus.available) {
          _status = LocationStatus.available;
        }

        debugPrint(
          'LOCATION: updated '
          'lat=${location.latitude} '
          'lon=${location.longitude} '
          'accuracy=${location.accuracy}',
        );

        notifyListeners();
      },
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        debugPrint(
          'Failed to watch location: $error',
        );
        debugPrintStack(
          stackTrace: stackTrace,
        );

        _setStatus(LocationStatus.error);
      },
    );
  }

  Future<void> _stopWatchingLocation() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void _setStatus(LocationStatus value) {
    if (_status == value) return;

    _status = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationSubscription = null;

    super.dispose();
  }
}

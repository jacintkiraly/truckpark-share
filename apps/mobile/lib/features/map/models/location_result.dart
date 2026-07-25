import 'driver_location.dart';
import 'location_status.dart';

class LocationResult {
  const LocationResult._({
    required this.status,
    this.location,
  });

  const LocationResult.available(
    DriverLocation location,
  ) : this._(
          status: LocationStatus.available,
          location: location,
        );

  const LocationResult.serviceDisabled()
      : this._(
          status: LocationStatus.serviceDisabled,
        );

  const LocationResult.permissionDenied()
      : this._(
          status: LocationStatus.permissionDenied,
        );

  const LocationResult.permissionDeniedForever()
      : this._(
          status: LocationStatus.permissionDeniedForever,
        );

  const LocationResult.error()
      : this._(
          status: LocationStatus.error,
        );

  final LocationStatus status;
  final DriverLocation? location;

  bool get hasLocation =>
      status == LocationStatus.available &&
      location != null;
}
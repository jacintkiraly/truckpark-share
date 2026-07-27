import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/driver_location.dart';

class ParkingGoogleMap extends StatelessWidget {
  const ParkingGoogleMap({
    super.key,
    required this.location,
  });

  final DriverLocation location;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          location.latitude,
          location.longitude,
        ),
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: true,
    );
  }
}
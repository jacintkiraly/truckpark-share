import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/entities/parking_spot.dart';

class ParkingMap extends StatelessWidget {
  const ParkingMap({
    super.key,
    required this.parkingSpots,
  });

  final List<ParkingSpot> parkingSpots;

  static const LatLng _defaultCenter = LatLng(
    36.963,
    -5.268,
  );

  Set<Marker> _buildMarkers() {
    return parkingSpots.map((parkingSpot) {
      return Marker(
        markerId: MarkerId(parkingSpot.id),
        position: LatLng(
          parkingSpot.location.latitude,
          parkingSpot.location.longitude,
        ),
        infoWindow: InfoWindow(
          title: parkingSpot.name,
        ),
      );
    }).toSet();
  }

  LatLng _initialPosition() {
    if (parkingSpots.isEmpty) {
      return _defaultCenter;
    }

    final firstSpot = parkingSpots.first;

    return LatLng(
      firstSpot.location.latitude,
      firstSpot.location.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition(),
        zoom: 11,
      ),
      markers: _buildMarkers(),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
    );
  }
}
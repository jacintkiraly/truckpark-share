import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../parking/domain/entities/parking_spot.dart';
import '../../parking/presentation/widgets/parking_card.dart';
import '../models/driver_location.dart';

class ParkingGoogleMap extends StatefulWidget {
  const ParkingGoogleMap({
    super.key,
    required this.location,
    required this.parkingSpots,
  });

  final DriverLocation location;
  final List<ParkingSpot> parkingSpots;

  @override
  State<ParkingGoogleMap> createState() =>
      _ParkingGoogleMapState();
}

class _ParkingGoogleMapState extends State<ParkingGoogleMap> {
  ParkingSpot? _selectedParkingSpot;

  Set<Marker> _buildMarkers() {
    return widget.parkingSpots.map((parkingSpot) {
      return Marker(
        markerId: MarkerId(parkingSpot.id),
        position: LatLng(
          parkingSpot.location.latitude,
          parkingSpot.location.longitude,
        ),
        infoWindow: InfoWindow(
          title: parkingSpot.name,
        ),
        onTap: () {
          setState(() {
            _selectedParkingSpot = parkingSpot;
          });
        },
      );
    }).toSet();
  }

  void _closeParkingCard() {
    setState(() {
      _selectedParkingSpot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.location.latitude,
              widget.location.longitude,
            ),
            zoom: 15,
          ),
          markers: _buildMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          onTap: (_) {
            if (_selectedParkingSpot != null) {
              _closeParkingCard();
            }
          },
        ),

        if (_selectedParkingSpot != null)
          Positioned(
            left: 24,
            right: 24,
            bottom: 16,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                  ),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 36,
                          ),
                          child: ParkingCard(
                            parkingSpot: _selectedParkingSpot!,
                            driverLocation: widget.location,
                          ),
                        ),

                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            tooltip: 'Bezárás',
                            icon: const Icon(
                              Icons.close,
                            ),
                            onPressed: _closeParkingCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
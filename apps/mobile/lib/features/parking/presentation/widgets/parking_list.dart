import 'package:flutter/material.dart';

import '../../domain/entities/parking_spot.dart';
import '../screens/edit_parking_screen.dart';
import 'parking_card.dart';

class ParkingList extends StatelessWidget {
  const ParkingList({
    super.key,
    required this.parkingSpots,
  });

  final List<ParkingSpot> parkingSpots;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: parkingSpots.length,
      itemBuilder: (context, index) {
       final parkingSpot = parkingSpots[index];

return ParkingCard(
  parkingSpot: parkingSpot,
  onEdit: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditParkingScreen(
          parkingSpot: parkingSpot,
        ),
      ),
    );
  },
);
      },
    );
  }
}
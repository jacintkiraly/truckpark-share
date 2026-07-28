import 'package:flutter/material.dart';

import '../../domain/entities/parking_spot.dart';

class ParkingCard extends StatelessWidget {
  const ParkingCard({
    super.key,
    required this.parkingSpot,
  });

  final ParkingSpot parkingSpot;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        leading: const Icon(Icons.local_parking),
        title: Text(parkingSpot.name),
        subtitle: Text(
          '${parkingSpot.freeSpaces} free spaces',
        ),
      ),
    );
  }
}
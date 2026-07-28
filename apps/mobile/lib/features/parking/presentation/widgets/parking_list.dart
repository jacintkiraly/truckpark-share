import 'package:flutter/material.dart';

import '../../domain/entities/parking_spot.dart';
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
        return ParkingCard(
          parkingSpot: parkingSpots[index],
        );
      },
    );
  }
}
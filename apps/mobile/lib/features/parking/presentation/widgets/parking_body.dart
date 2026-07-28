import 'package:flutter/material.dart';

import '../state/parking_state.dart';
import 'parking_error.dart';
import 'parking_loading.dart';

class ParkingBody extends StatelessWidget {
  const ParkingBody({
    super.key,
    required this.state,
  });

  final ParkingState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const ParkingLoading();
    }

    if (state.errorMessage != null) {
      return ParkingError(
        message: state.errorMessage!,
      );
    }

    if (state.parkingSpots.isEmpty) {
      return const Center(
        child: Text('No parking spots available'),
      );
    }

    return ListView.builder(
      itemCount: state.parkingSpots.length,
      itemBuilder: (context, index) {
        final spot = state.parkingSpots[index];

        return ListTile(
          leading: const Icon(Icons.local_parking),
          title: Text(spot.name),
          subtitle: Text(
            '${spot.freeSpaces} free spaces',
          ),
        );
      },
    );
  }
}
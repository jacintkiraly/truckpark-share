import 'package:flutter/material.dart';

import '../state/parking_state.dart';
import 'parking_error.dart';
import 'parking_loading.dart';
import 'parking_list.dart';

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
      child: Text(
        'No parking spots available',
      ),
    );
  }

  return ParkingList(
    parkingSpots: state.parkingSpots,
  );
}
}
import 'package:flutter/material.dart';

import '../enums/parking_view_mode.dart';
import '../state/parking_state.dart';
import 'map/parking_map.dart';
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
        child: Text('No parking spots available'),
      );
    }

    switch (state.viewMode) {
      case ParkingViewMode.map:
        return ParkingMap(
          parkingSpots: state.parkingSpots,
        );

      case ParkingViewMode.list:
        return ParkingList(
          parkingSpots: state.parkingSpots,
        );
    }
  }
}
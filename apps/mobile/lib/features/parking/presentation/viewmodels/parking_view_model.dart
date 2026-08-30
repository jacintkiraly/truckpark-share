import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/watch_parking_spots_use_case.dart';
import '../enums/parking_view_mode.dart';
import '../state/parking_state.dart';

class ParkingViewModel extends StateNotifier<ParkingState> {
  ParkingViewModel(
    this._watchParkingSpotsUseCase,
  ) : super(const ParkingState());

  final WatchParkingSpotsUseCase _watchParkingSpotsUseCase;

  StreamSubscription? _subscription;

  void watchParkingSpots() {
    debugPrint('PARKING: watchParkingSpots() START');
    
    state = state.copyWith(isLoading: true);

    _subscription?.cancel();

    _subscription = _watchParkingSpotsUseCase().listen(
  (spots) {
    debugPrint('PARKING: received ${spots.length} parking spots');

    for (final spot in spots) {
      debugPrint(
        'PARKING: ${spot.id} | '
        '${spot.name} | '
        '${spot.location.latitude}, '
        '${spot.location.longitude}',
      );
    }

    state = state.copyWith(
      isLoading: false,
      parkingSpots: spots,
      errorMessage: null,
    );
  },
      onError: (error) {
        debugPrint('PARKING ERROR: $error');

        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void setViewMode(ParkingViewMode viewMode) {
  state = state.copyWith(
    viewMode: viewMode,
  );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/watch_parking_spots_use_case.dart';
import '../state/parking_state.dart';

class ParkingViewModel extends StateNotifier<ParkingState> {
  ParkingViewModel(
    this._watchParkingSpotsUseCase,
  ) : super(const ParkingState());

  final WatchParkingSpotsUseCase _watchParkingSpotsUseCase;

  StreamSubscription? _subscription;

  void watchParkingSpots() {
    state = state.copyWith(isLoading: true);

    _subscription?.cancel();

    _subscription = _watchParkingSpotsUseCase().listen(
      (spots) {
        state = state.copyWith(
          isLoading: false,
          parkingSpots: spots,
          errorMessage: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
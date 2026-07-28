import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/watch_parking_spots_use_case.dart';
import '../viewmodels/parking_view_model.dart';
import '../state/parking_state.dart';

final parkingViewModelProvider =
    StateNotifierProvider<ParkingViewModel, ParkingState>(
  (ref) {
    return ParkingViewModel(
      sl<WatchParkingSpotsUseCase>(),
    );
  },
);
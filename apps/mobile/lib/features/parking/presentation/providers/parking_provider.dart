import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/services/auth_service.dart';
import '../../domain/usecases/add_parking_spot_use_case.dart';
import '../../domain/usecases/update_parking_spot_use_case.dart';
import '../../domain/usecases/watch_parking_spots_use_case.dart';
import '../state/parking_state.dart';
import '../viewmodels/parking_view_model.dart';

final parkingViewModelProvider =
    StateNotifierProvider<ParkingViewModel, ParkingState>(
  (ref) {
    return ParkingViewModel(
      sl<WatchParkingSpotsUseCase>(),
      sl<AddParkingSpotUseCase>(),
      sl<UpdateParkingSpotUseCase>(),
      sl<AuthService>(),
      sl(),
    );
  },
);
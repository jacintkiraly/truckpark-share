import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/services/auth_service.dart';
import '../../domain/services/parking_session_state_machine.dart';
import '../../domain/usecases/create_parking_session_use_case.dart';
import '../../domain/usecases/update_parking_session_use_case.dart';
import '../../domain/usecases/watch_parking_session_use_case.dart';
import '../state/parking_session_state.dart';
import '../viewmodels/parking_session_view_model.dart';

final parkingSessionViewModelProvider =
    StateNotifierProvider<ParkingSessionViewModel, ParkingSessionState>((ref) {
      final authService = sl<AuthService>();
      final firestore = sl<FirebaseFirestore>();

      return ParkingSessionViewModel(
        sl<CreateParkingSessionUseCase>(),
        sl<WatchParkingSessionUseCase>(),
        sl<UpdateParkingSessionUseCase>(),
        sl<ParkingSessionStateMachine>(),
        () => authService.currentUser?.uid,
        () => firestore.collection('parking_sessions').doc().id,
      );
    });

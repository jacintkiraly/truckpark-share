import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/services/auth_service.dart';
import '../../domain/entities/parking_spot.dart';
import '../../domain/usecases/add_parking_spot_use_case.dart';
import '../../domain/usecases/watch_parking_spots_use_case.dart';
import '../enums/parking_view_mode.dart';
import '../state/parking_state.dart';

class ParkingViewModel extends StateNotifier<ParkingState> {
  ParkingViewModel(
    this._watchParkingSpotsUseCase,
    this._addParkingSpotUseCase,
    this._authService,
    this._firestore,
  ) : super(const ParkingState());

  final WatchParkingSpotsUseCase _watchParkingSpotsUseCase;
  final AddParkingSpotUseCase _addParkingSpotUseCase;
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  StreamSubscription? _subscription;

  void watchParkingSpots() {
    debugPrint('PARKING: watchParkingSpots() START');

    state = state.copyWith(isLoading: true);

    _subscription?.cancel();

    _subscription = _watchParkingSpotsUseCase().listen(
      (spots) {
        debugPrint(
          'PARKING: received ${spots.length} parking spots',
        );

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

  Future<void> addParkingSpot(
    ParkingSpot parkingSpot,
  ) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw StateError(
        'A bejelentkezett felhasználó szükséges '
        'parkoló hozzáadásához.',
      );
    }

    final parkingSpotWithMetadata = ParkingSpot(
      id: _firestore.collection('parking_spots').doc().id,
      name: parkingSpot.name,
      location: parkingSpot.location,
      type: parkingSpot.type,
      status: parkingSpot.status,
      totalSpaces: parkingSpot.totalSpaces,
      freeSpaces: parkingSpot.freeSpaces,
      services: parkingSpot.services,
      lastUpdated: DateTime.now(),
      updatedBy: user.uid,
      verified: false,
    );

    try {
      await _addParkingSpotUseCase(
        parkingSpotWithMetadata,
      );

      debugPrint(
        'PARKING: added ${parkingSpotWithMetadata.id} '
        'by ${user.uid}',
      );
    } catch (error) {
      debugPrint(
        'PARKING ADD ERROR: $error',
      );

      state = state.copyWith(
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
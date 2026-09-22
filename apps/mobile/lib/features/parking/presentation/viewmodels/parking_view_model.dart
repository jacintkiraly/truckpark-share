import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/services/auth_service.dart';
import '../../domain/entities/parking_live_status.dart';
import '../../domain/entities/parking_spot.dart';
import '../../domain/usecases/add_parking_spot_use_case.dart';
import '../../domain/usecases/delete_parking_spot_use_case.dart';
import '../../domain/usecases/update_parking_spot_use_case.dart';
import '../../domain/usecases/watch_parking_live_status_use_case.dart';
import '../../domain/usecases/watch_parking_spots_use_case.dart';
import '../enums/parking_view_mode.dart';
import '../state/parking_state.dart';

class ParkingViewModel extends StateNotifier<ParkingState> {
  ParkingViewModel(
    this._watchParkingSpotsUseCase,
    this._watchParkingLiveStatusUseCase,
    this._addParkingSpotUseCase,
    this._updateParkingSpotUseCase,
    this._deleteParkingSpotUseCase,
    this._authService,
    this._firestore,
  ) : super(const ParkingState());

  final WatchParkingSpotsUseCase _watchParkingSpotsUseCase;
  final WatchParkingLiveStatusUseCase _watchParkingLiveStatusUseCase;
  final AddParkingSpotUseCase _addParkingSpotUseCase;
  final AuthService _authService;
  final FirebaseFirestore _firestore;
  final UpdateParkingSpotUseCase _updateParkingSpotUseCase;
  final DeleteParkingSpotUseCase _deleteParkingSpotUseCase;

  StreamSubscription? _subscription;

  final Map<String, StreamSubscription> _liveSubscriptions = {};

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

        _updateLiveSubscriptions(spots);
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

  void _updateLiveSubscriptions(List<ParkingSpot> parkingSpots) {
    final parkingIds = parkingSpots.map((spot) => spot.id).toSet();

    final removedIds = _liveSubscriptions.keys
        .where((parkingId) => !parkingIds.contains(parkingId))
        .toList();

    for (final parkingId in removedIds) {
      _liveSubscriptions.remove(parkingId)?.cancel();
    }

    for (final parkingSpot in parkingSpots) {
      final parkingId = parkingSpot.id;

      if (_liveSubscriptions.containsKey(parkingId)) {
        continue;
      }

      final subscription = _watchParkingLiveStatusUseCase(parkingId).listen(
        (liveStatus) {
          final updatedStatuses = Map<String, ParkingLiveStatus>.from(
            state.liveStatuses,
          );

          if (liveStatus == null) {
            updatedStatuses.remove(parkingId);
          } else {
            updatedStatuses[parkingId] = liveStatus;
          }

          state = state.copyWith(liveStatuses: updatedStatuses);

          if (liveStatus == null) {
            debugPrint('PARKING LIVE: $parkingId -> no current status');
          } else {
            debugPrint(
              'PARKING LIVE: $parkingId -> '
              '${liveStatus.status.name}, '
              'freeSpaces=${liveStatus.freeSpaces}, '
              'updatedBy=${liveStatus.updatedBy}, '
              'lastUpdated=${liveStatus.lastUpdated}',
            );
          }
        },
        onError: (error) {
          debugPrint('PARKING LIVE ERROR [$parkingId]: $error');
        },
      );

      _liveSubscriptions[parkingId] = subscription;
    }
  }

  void setViewMode(ParkingViewMode viewMode) {
    state = state.copyWith(viewMode: viewMode);
  }

  Future<void> addParkingSpot(ParkingSpot parkingSpot) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw StateError('Authenticated user is required to add a parking spot.');
    }

    final parkingSpotWithId = ParkingSpot(
      id: _firestore.collection('parking_spots').doc().id,
      name: parkingSpot.name,
      location: parkingSpot.location,
      countryCode: parkingSpot.countryCode,
      facilityType: parkingSpot.facilityType,
      totalAreaM2: parkingSpot.totalAreaM2,
      services: parkingSpot.services,
      infrastructure: parkingSpot.infrastructure,
      context: parkingSpot.context,
      networkContext: parkingSpot.networkContext,
      truckContext: parkingSpot.truckContext,
      source: parkingSpot.source,
      verification: parkingSpot.verification,
      safeAndSecureTruckParkingArea: parkingSpot.safeAndSecureTruckParkingArea,
      sourceConfidence: parkingSpot.sourceConfidence,
    );

    try {
      await _addParkingSpotUseCase(parkingSpotWithId);

      debugPrint(
        'PARKING: added ${parkingSpotWithId.id} '
        'by ${user.uid}',
      );
    } catch (error) {
      debugPrint('PARKING ADD ERROR: $error');

      state = state.copyWith(errorMessage: error.toString());

      rethrow;
    }
  }

  Future<void> updateParkingSpot(ParkingSpot parkingSpot) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw StateError(
        'Authenticated user is required to update a parking spot.',
      );
    }

    try {
      await _updateParkingSpotUseCase(parkingSpot);

      debugPrint(
        'PARKING: updated ${parkingSpot.id} '
        'by ${user.uid}',
      );
    } catch (error) {
      debugPrint('PARKING UPDATE ERROR: $error');

      state = state.copyWith(errorMessage: error.toString());

      rethrow;
    }
  }

  Future<void> deleteParkingSpot(String parkingSpotId) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw StateError(
        'Authenticated user is required to delete a parking spot.',
      );
    }

    try {
      await _deleteParkingSpotUseCase(parkingSpotId);

      debugPrint(
        'PARKING: deleted $parkingSpotId '
        'by ${user.uid}',
      );
    } catch (error) {
      debugPrint('PARKING DELETE ERROR: $error');

      state = state.copyWith(errorMessage: error.toString());

      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();

    for (final subscription in _liveSubscriptions.values) {
      subscription.cancel();
    }

    _liveSubscriptions.clear();

    super.dispose();
  }
}

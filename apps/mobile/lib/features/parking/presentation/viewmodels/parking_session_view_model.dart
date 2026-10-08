import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parking_session.dart';
import '../../domain/enums/parking_session_status.dart';
import '../../domain/services/parking_session_state_machine.dart';
import '../../domain/usecases/create_parking_session_use_case.dart';
import '../../domain/usecases/update_parking_session_use_case.dart';
import '../../domain/usecases/watch_parking_session_use_case.dart';
import '../state/parking_session_state.dart';

class ParkingSessionViewModel extends StateNotifier<ParkingSessionState> {
  ParkingSessionViewModel(
    this._createParkingSessionUseCase,
    this._watchParkingSessionUseCase,
    this._updateParkingSessionUseCase,
    this._stateMachine,
    this._currentDriverIdProvider,
    this._sessionIdGenerator, {
    DateTime Function()? nowProvider,
  }) : _now = nowProvider ?? DateTime.now,
       super(const ParkingSessionState());

  final CreateParkingSessionUseCase _createParkingSessionUseCase;
  final WatchParkingSessionUseCase _watchParkingSessionUseCase;
  final UpdateParkingSessionUseCase _updateParkingSessionUseCase;
  final ParkingSessionStateMachine _stateMachine;

  final String? Function() _currentDriverIdProvider;
  final String Function() _sessionIdGenerator;
  final DateTime Function() _now;

  StreamSubscription<ParkingSession?>? _subscription;

  void watchCurrentSession() {
    final driverId = _currentDriverIdProvider();

    if (driverId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Authenticated user is required to watch a parking session.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    _subscription?.cancel();

    _subscription = _watchParkingSessionUseCase(driverId).listen(
      (session) {
        state = state.copyWith(
          isLoading: false,
          session: session,
          errorMessage: null,
          clearSession: session == null,
        );
      },
      onError: (error) {
        debugPrint('PARKING SESSION WATCH ERROR: $error');

        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> startSession(String parkingId) async {
    final driverId = _currentDriverIdProvider();

    if (driverId == null) {
      throw StateError(
        'Authenticated user is required to start a parking session.',
      );
    }

    final currentSession = state.session;

    if (currentSession != null &&
        currentSession.status != ParkingSessionStatus.closed) {
      throw StateError(
        'An open parking session already exists for this driver.',
      );
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final now = _now();
      final sessionId = _sessionIdGenerator();

      final createdSession = ParkingSession.create(
        id: sessionId,
        parkingId: parkingId,
        driverId: driverId,
        startedAt: now,
      );

      final activeSession = _stateMachine.transition(
        createdSession,
        ParkingSessionStatus.active,
        now,
      );

      await _createParkingSessionUseCase(activeSession);

      state = state.copyWith(
        isSaving: false,
        session: activeSession,
        errorMessage: null,
      );

      debugPrint(
        'PARKING SESSION: started ${activeSession.id} '
        'for ${activeSession.parkingId} by $driverId',
      );
    } catch (error) {
      debugPrint('PARKING SESSION START ERROR: $error');

      state = state.copyWith(isSaving: false, errorMessage: error.toString());

      rethrow;
    }
  }

  Future<void> markLeavingSoon() async {
    await _transitionCurrentSession(ParkingSessionStatus.leavingSoon);
  }

  Future<void> closeSession() async {
    await _transitionCurrentSession(ParkingSessionStatus.closed);
  }

  Future<void> _transitionCurrentSession(
    ParkingSessionStatus nextStatus,
  ) async {
    final session = state.session;

    if (session == null) {
      throw StateError('An open parking session is required.');
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final updatedSession = _stateMachine.transition(
        session,
        nextStatus,
        _now(),
      );

      await _updateParkingSessionUseCase(updatedSession);

      state = state.copyWith(
        isSaving: false,
        session: updatedSession,
        errorMessage: null,
      );

      debugPrint('PARKING SESSION: ${session.id} -> ${nextStatus.name}');
    } catch (error) {
      debugPrint('PARKING SESSION TRANSITION ERROR: $error');

      state = state.copyWith(isSaving: false, errorMessage: error.toString());

      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

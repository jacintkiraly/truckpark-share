import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parking_session.dart';
import '../../domain/enums/parking_session_status.dart';
import '../../domain/services/parking_session_expiration_policy.dart';
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
    this._expirationPolicy = const ParkingSessionExpirationPolicy(),
  }) : _now = nowProvider ?? DateTime.now,
       super(const ParkingSessionState());

  final CreateParkingSessionUseCase _createParkingSessionUseCase;
  final WatchParkingSessionUseCase _watchParkingSessionUseCase;
  final UpdateParkingSessionUseCase _updateParkingSessionUseCase;
  final ParkingSessionStateMachine _stateMachine;
  final ParkingSessionExpirationPolicy _expirationPolicy;

  final String? Function() _currentDriverIdProvider;
  final String Function() _sessionIdGenerator;
  final DateTime Function() _now;

  StreamSubscription<ParkingSession?>? _subscription;
  Timer? _sessionExpiryTimer;

  void watchCurrentSession() {
    final driverId = _currentDriverIdProvider();

    if (driverId == null) {
      _cancelSessionExpiryTimer();

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
        if (session == null || _isExpiredOpenSession(session, _now())) {
          _cancelSessionExpiryTimer();

          state = state.copyWith(
            isLoading: false,
            clearSession: true,
            errorMessage: null,
          );
          return;
        }

        state = state.copyWith(
          isLoading: false,
          session: session,
          errorMessage: null,
        );

        _scheduleSessionExpiry(session);
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

  Future<void> startSession(String parkingId, {DateTime? plannedEndAt}) async {
    final driverId = _currentDriverIdProvider();

    if (driverId == null) {
      throw StateError(
        'Authenticated user is required to start a parking session.',
      );
    }

    final currentSession = state.session;

    if (currentSession != null &&
        currentSession.status != ParkingSessionStatus.closed &&
        !_expirationPolicy.isOpenSessionExpired(currentSession, _now())) {
      throw StateError(
        'An open parking session already exists for this driver.',
      );
    }

    if (currentSession != null &&
        _isExpiredOpenSession(currentSession, _now())) {
      _cancelSessionExpiryTimer();

      state = state.copyWith(clearSession: true, errorMessage: null);
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
        plannedEndAt: plannedEndAt,
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

      _scheduleSessionExpiry(activeSession);

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

      _scheduleSessionExpiry(updatedSession);

      debugPrint('PARKING SESSION: ${session.id} -> ${nextStatus.name}');
    } catch (error) {
      debugPrint('PARKING SESSION TRANSITION ERROR: $error');

      state = state.copyWith(isSaving: false, errorMessage: error.toString());

      rethrow;
    }
  }

  bool _isExpiredOpenSession(ParkingSession session, DateTime now) {
    return session.status != ParkingSessionStatus.closed &&
        _expirationPolicy.isOpenSessionExpired(session, now);
  }

  void _scheduleSessionExpiry(ParkingSession session) {
    _cancelSessionExpiryTimer();

    if (session.status == ParkingSessionStatus.closed) {
      return;
    }

    final expiresAt =
        session.plannedEndAt ??
        session.updatedAt.add(_expirationPolicy.openSessionDuration);
    final delay = expiresAt.difference(_now());

    _sessionExpiryTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () async {
        if (!mounted) {
          return;
        }

        final currentSession = state.session;

        if (currentSession == null || currentSession.id != session.id) {
          return;
        }

        if (_isExpiredOpenSession(currentSession, _now())) {
          _sessionExpiryTimer = null;

          try {
            await _transitionCurrentSession(ParkingSessionStatus.closed);

            if (!mounted) {
              return;
            }

            final closedSession = state.session;

            if (closedSession != null &&
                closedSession.id == currentSession.id &&
                closedSession.status == ParkingSessionStatus.closed) {
              state = state.copyWith(clearSession: true, errorMessage: null);
            }

            debugPrint(
              'PARKING SESSION: expired and closed ${currentSession.id}',
            );
          } catch (error) {
            debugPrint('PARKING SESSION AUTO-CLOSE ERROR: $error');
          }

          return;
        }

        // Recheck if the timer fired slightly before the expiration boundary.
        _scheduleSessionExpiry(currentSession);
      },
    );
  }

  void _cancelSessionExpiryTimer() {
    _sessionExpiryTimer?.cancel();
    _sessionExpiryTimer = null;
  }

  @override
  void dispose() {
    _cancelSessionExpiryTimer();
    _subscription?.cancel();
    super.dispose();
  }
}

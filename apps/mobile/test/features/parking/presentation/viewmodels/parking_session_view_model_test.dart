import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';
import 'package:truckpark_share/features/parking/domain/repositories/parking_session_repository.dart';
import 'package:truckpark_share/features/parking/domain/services/parking_session_state_machine.dart';
import 'package:truckpark_share/features/parking/domain/usecases/create_parking_session_use_case.dart';
import 'package:truckpark_share/features/parking/domain/usecases/update_parking_session_use_case.dart';
import 'package:truckpark_share/features/parking/domain/usecases/watch_parking_session_use_case.dart';
import 'package:truckpark_share/features/parking/presentation/viewmodels/parking_session_view_model.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 10, 8, 7, 30);

  late FakeParkingSessionRepository repository;
  late ParkingSessionViewModel viewModel;

  ParkingSessionViewModel createViewModel({String? driverId = 'driver-1'}) {
    return ParkingSessionViewModel(
      CreateParkingSessionUseCase(repository),
      WatchParkingSessionUseCase(repository),
      UpdateParkingSessionUseCase(repository),
      const ParkingSessionStateMachine(),
      () => driverId,
      () => 'session-1',
      nowProvider: () => fixedNow,
    );
  }

  setUp(() {
    repository = FakeParkingSessionRepository();
    viewModel = createViewModel();
  });

  tearDown(() {
    viewModel.dispose();
    repository.dispose();
  });

  test('startSession creates an active session', () async {
    await viewModel.startSession('parking-1');

    expect(viewModel.state.session, isNotNull);
    expect(viewModel.state.session!.status, ParkingSessionStatus.active);
    expect(viewModel.state.session!.id, 'session-1');
    expect(viewModel.state.session!.parkingId, 'parking-1');
    expect(viewModel.state.session!.driverId, 'driver-1');
    expect(viewModel.state.session!.startedAt, fixedNow);
    expect(repository.createdSessions, hasLength(1));
    expect(
      repository.createdSessions.single.status,
      ParkingSessionStatus.active,
    );
    expect(viewModel.state.isSaving, isFalse);
  });

  test('markLeavingSoon updates the session status', () async {
    await viewModel.startSession('parking-1');

    await viewModel.markLeavingSoon();

    expect(viewModel.state.session!.status, ParkingSessionStatus.leavingSoon);
    expect(repository.updatedSessions, hasLength(1));
    expect(
      repository.updatedSessions.single.status,
      ParkingSessionStatus.leavingSoon,
    );
    expect(viewModel.state.session!.leavingSoonAt, fixedNow);
  });

  test('closeSession closes the current session', () async {
    await viewModel.startSession('parking-1');

    await viewModel.closeSession();

    expect(viewModel.state.session!.status, ParkingSessionStatus.closed);
    expect(repository.updatedSessions, hasLength(1));
    expect(
      repository.updatedSessions.single.status,
      ParkingSessionStatus.closed,
    );
    expect(viewModel.state.session!.closedAt, fixedNow);
  });

  test('startSession rejects an existing open session', () async {
    await viewModel.startSession('parking-1');

    await expectLater(
      viewModel.startSession('parking-2'),
      throwsA(isA<StateError>()),
    );

    expect(repository.createdSessions, hasLength(1));
  });

  test('startSession rejects missing authentication', () async {
    viewModel.dispose();
    repository.dispose();

    repository = FakeParkingSessionRepository();
    viewModel = createViewModel(driverId: null);

    await expectLater(
      viewModel.startSession('parking-1'),
      throwsA(isA<StateError>()),
    );

    expect(repository.createdSessions, isEmpty);
    expect(viewModel.state.isSaving, isFalse);
  });

  test('watchCurrentSession updates state from repository stream', () async {
    final controller = StreamController<ParkingSession?>.broadcast();
    repository.watchController = controller;

    viewModel.watchCurrentSession();

    final session = ParkingSession(
      id: 'session-1',
      parkingId: 'parking-1',
      driverId: 'driver-1',
      status: ParkingSessionStatus.active,
      startedAt: fixedNow,
      updatedAt: fixedNow,
    );

    controller.add(session);

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.isLoading, isFalse);
    expect(viewModel.state.session, session);
    expect(viewModel.state.errorMessage, isNull);
  });
}

class FakeParkingSessionRepository implements ParkingSessionRepository {
  final List<ParkingSession> createdSessions = [];
  final List<ParkingSession> updatedSessions = [];

  StreamController<ParkingSession?>? watchController;

  @override
  Future<void> createSession(ParkingSession session) async {
    createdSessions.add(session);
  }

  @override
  Stream<ParkingSession?> watchOpenSession(String driverId) {
    watchController ??= StreamController<ParkingSession?>.broadcast();
    return watchController!.stream;
  }

  @override
  Future<void> updateSession(ParkingSession session) async {
    updatedSessions.add(session);
  }

  void dispose() {
    watchController?.close();
  }
}

import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';
import 'package:truckpark_share/features/parking/domain/repositories/parking_session_repository.dart';
import 'package:truckpark_share/features/parking/domain/usecases/create_parking_session_use_case.dart';

class FakeParkingSessionRepository
    implements ParkingSessionRepository {
  ParkingSession? createdSession;
  String? watchedDriverId;
  ParkingSession? updatedSession;

  @override
  Future<void> createSession(
    ParkingSession session,
  ) async {
    createdSession = session;
  }

  @override
  Stream<ParkingSession?> watchOpenSession(
    String driverId,
  ) {
    watchedDriverId = driverId;
    return const Stream.empty();
  }

  @override
  Future<void> updateSession(
    ParkingSession session,
  ) async {
    updatedSession = session;
  }
}

void main() {
  group('CreateParkingSessionUseCase', () {
    test('creates the session through the repository', () async {
      final repository = FakeParkingSessionRepository();
      final useCase = CreateParkingSessionUseCase(
        repository,
      );

      final session = ParkingSession(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: ParkingSessionStatus.created,
        startedAt: DateTime(2026, 10, 7, 10),
        updatedAt: DateTime(2026, 10, 7, 10),
      );

      await useCase(session);

      expect(repository.createdSession, same(session));
    });
  });
}

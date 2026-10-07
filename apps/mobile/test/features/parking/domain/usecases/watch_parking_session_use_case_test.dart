import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';
import 'package:truckpark_share/features/parking/domain/repositories/parking_session_repository.dart';
import 'package:truckpark_share/features/parking/domain/usecases/watch_parking_session_use_case.dart';

class FakeParkingSessionRepository
    implements ParkingSessionRepository {
  String? watchedDriverId;
  ParkingSession? sessionToEmit;

  @override
  Future<void> createSession(
    ParkingSession session,
  ) async {}

  @override
  Stream<ParkingSession?> watchOpenSession(
    String driverId,
  ) {
    watchedDriverId = driverId;
    return Stream.value(sessionToEmit);
  }

  @override
  Future<void> updateSession(
    ParkingSession session,
  ) async {}
}

void main() {
  group('WatchParkingSessionUseCase', () {
    test('watches the open session for the driver', () async {
      final repository = FakeParkingSessionRepository();

      final session = ParkingSession(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: ParkingSessionStatus.active,
        startedAt: DateTime(2026, 10, 7, 10),
        updatedAt: DateTime(2026, 10, 7, 11),
      );

      repository.sessionToEmit = session;

      final useCase = WatchParkingSessionUseCase(
        repository,
      );

      final result = await useCase('driver-1').first;

      expect(repository.watchedDriverId, 'driver-1');
      expect(result, same(session));
    });

    test('returns null when there is no open session', () async {
      final repository = FakeParkingSessionRepository();
      final useCase = WatchParkingSessionUseCase(
        repository,
      );

      final result = await useCase('driver-1').first;

      expect(result, isNull);
      expect(repository.watchedDriverId, 'driver-1');
    });
  });
}

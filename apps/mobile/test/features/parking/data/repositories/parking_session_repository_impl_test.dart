import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/data/datasource/parking_session_datasource.dart';
import 'package:truckpark_share/features/parking/data/dto/parking_session_dto.dart';
import 'package:truckpark_share/features/parking/data/repositories/parking_session_repository_impl.dart';
import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';

class FakeParkingSessionDataSource implements ParkingSessionDataSource {
  ParkingSessionDto? createdSession;
  ParkingSessionDto? updatedSession;
  String? watchedDriverId;
  ParkingSessionDto? sessionToEmit;

  @override
  Future<void> createSession(ParkingSessionDto session) async {
    createdSession = session;
  }

  @override
  Stream<ParkingSessionDto?> watchOpenSession(String driverId) {
    watchedDriverId = driverId;
    return Stream.value(sessionToEmit);
  }

  @override
  Future<void> updateSession(ParkingSessionDto session) async {
    updatedSession = session;
  }
}

void main() {
  final startedAt = DateTime(2026, 10, 7, 10);
  final updatedAt = DateTime(2026, 10, 7, 11);

  ParkingSession createSession({
    ParkingSessionStatus status = ParkingSessionStatus.active,
  }) {
    return ParkingSession(
      id: 'session-1',
      parkingId: 'parking-1',
      driverId: 'driver-1',
      status: status,
      startedAt: startedAt,
      updatedAt: updatedAt,
    );
  }

  group('ParkingSessionRepositoryImpl', () {
    test('creates a session through the datasource', () async {
      final dataSource = FakeParkingSessionDataSource();
      final repository = ParkingSessionRepositoryImpl(dataSource);

      final session = createSession(status: ParkingSessionStatus.created);

      await repository.createSession(session);

      expect(dataSource.createdSession, isNotNull);
      expect(dataSource.createdSession!.id, 'session-1');
      expect(dataSource.createdSession!.parkingId, 'parking-1');
      expect(dataSource.createdSession!.driverId, 'driver-1');
      expect(dataSource.createdSession!.status, 'created');
      expect(dataSource.createdSession!.startedAt, startedAt);
      expect(dataSource.createdSession!.updatedAt, updatedAt);
    });

    test('maps the open session from the datasource to domain', () async {
      final dataSource = FakeParkingSessionDataSource();

      dataSource.sessionToEmit = ParkingSessionDto(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: 'leavingSoon',
        startedAt: startedAt,
        updatedAt: updatedAt,
      );

      final repository = ParkingSessionRepositoryImpl(dataSource);

      final result = await repository.watchOpenSession('driver-1').first;

      expect(dataSource.watchedDriverId, 'driver-1');
      expect(result, isNotNull);
      expect(result!.id, 'session-1');
      expect(result.parkingId, 'parking-1');
      expect(result.driverId, 'driver-1');
      expect(result.status, ParkingSessionStatus.leavingSoon);
      expect(result.startedAt, startedAt);
      expect(result.updatedAt, updatedAt);
    });

    test('returns null when datasource has no open session', () async {
      final dataSource = FakeParkingSessionDataSource();
      final repository = ParkingSessionRepositoryImpl(dataSource);

      final result = await repository.watchOpenSession('driver-1').first;

      expect(dataSource.watchedDriverId, 'driver-1');
      expect(result, isNull);
    });

    test('updates a session through the datasource', () async {
      final dataSource = FakeParkingSessionDataSource();
      final repository = ParkingSessionRepositoryImpl(dataSource);

      final session = createSession(status: ParkingSessionStatus.leavingSoon);

      await repository.updateSession(session);

      expect(dataSource.updatedSession, isNotNull);
      expect(dataSource.updatedSession!.id, 'session-1');
      expect(dataSource.updatedSession!.status, 'leavingSoon');
    });
  });
}

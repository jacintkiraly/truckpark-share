import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/data/dto/parking_session_dto.dart';
import 'package:truckpark_share/features/parking/data/mappers/parking_session_mapper.dart';
import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';

void main() {
  group('ParkingSessionMapper', () {
    final startedAt = DateTime(2026, 10, 7, 10);
    final updatedAt = DateTime(2026, 10, 7, 11);
    final leavingSoonAt = DateTime(2026, 10, 7, 17);
    final closedAt = DateTime(2026, 10, 7, 18);

    test('maps domain session to DTO', () {
      final session = ParkingSession(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: ParkingSessionStatus.leavingSoon,
        startedAt: startedAt,
        updatedAt: updatedAt,
        leavingSoonAt: leavingSoonAt,
      );

      final dto = ParkingSessionMapper.toDto(session);

      expect(dto.id, 'session-1');
      expect(dto.parkingId, 'parking-1');
      expect(dto.driverId, 'driver-1');
      expect(dto.status, 'leavingSoon');
      expect(dto.startedAt, startedAt);
      expect(dto.updatedAt, updatedAt);
      expect(dto.leavingSoonAt, leavingSoonAt);
      expect(dto.closedAt, isNull);
    });

    test('maps DTO to domain session', () {
      final dto = ParkingSessionDto(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: 'active',
        startedAt: startedAt,
        updatedAt: updatedAt,
      );

      final session = ParkingSessionMapper.toDomain(dto);

      expect(session.id, 'session-1');
      expect(session.parkingId, 'parking-1');
      expect(session.driverId, 'driver-1');
      expect(session.status, ParkingSessionStatus.active);
      expect(session.startedAt, startedAt);
      expect(session.updatedAt, updatedAt);
      expect(session.leavingSoonAt, isNull);
      expect(session.closedAt, isNull);
    });

    test('maps Firestore data to DTO', () {
      final data = {
        'parkingId': 'parking-1',
        'driverId': 'driver-1',
        'status': 'closed',
        'startedAt': Timestamp.fromDate(startedAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'leavingSoonAt': Timestamp.fromDate(leavingSoonAt),
        'closedAt': Timestamp.fromDate(closedAt),
      };

      final dto = ParkingSessionDto.fromFirestore('session-1', data);

      expect(dto.id, 'session-1');
      expect(dto.parkingId, 'parking-1');
      expect(dto.driverId, 'driver-1');
      expect(dto.status, 'closed');
      expect(dto.startedAt, startedAt);
      expect(dto.updatedAt, updatedAt);
      expect(dto.leavingSoonAt, leavingSoonAt);
      expect(dto.closedAt, closedAt);
    });

    test('writes nullable Firestore timestamps as null', () {
      final dto = ParkingSessionDto(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: 'active',
        startedAt: startedAt,
        updatedAt: updatedAt,
      );

      final data = dto.toFirestore();

      expect(data['parkingId'], 'parking-1');
      expect(data['driverId'], 'driver-1');
      expect(data['status'], 'active');
      expect(data['startedAt'], Timestamp.fromDate(startedAt));
      expect(data['updatedAt'], Timestamp.fromDate(updatedAt));
      expect(data['leavingSoonAt'], isNull);
      expect(data['closedAt'], isNull);
    });

    test('round-trips a closed session through Firestore data', () {
      final session = ParkingSession(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: ParkingSessionStatus.closed,
        startedAt: startedAt,
        updatedAt: closedAt,
        leavingSoonAt: leavingSoonAt,
        closedAt: closedAt,
      );

      final dto = ParkingSessionMapper.toDto(session);
      final firestoreData = dto.toFirestore();
      final restoredDto = ParkingSessionDto.fromFirestore(
        dto.id,
        firestoreData,
      );
      final restoredSession = ParkingSessionMapper.toDomain(restoredDto);

      expect(restoredSession, session);
    });

    test('throws for an unknown session status', () {
      final dto = ParkingSessionDto(
        id: 'session-1',
        parkingId: 'parking-1',
        driverId: 'driver-1',
        status: 'unknown',
        startedAt: startedAt,
        updatedAt: updatedAt,
      );

      expect(() => ParkingSessionMapper.toDomain(dto), throwsStateError);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';
import 'package:truckpark_share/features/parking/domain/services/parking_session_state_machine.dart';

void main() {
  const stateMachine = ParkingSessionStateMachine();

  final startedAt = DateTime(2026, 10, 7, 10);
  final updatedAt = DateTime(2026, 10, 7, 11);
  final leavingSoonAt = DateTime(2026, 10, 7, 17);
  final closedAt = DateTime(2026, 10, 7, 18);

  ParkingSession createSession() {
    return ParkingSession.create(
      id: 'session-1',
      parkingId: 'parking-1',
      driverId: 'driver-1',
      startedAt: startedAt,
    );
  }

  group('ParkingSessionStateMachine', () {
    test('creates a session in created state', () {
      final session = createSession();

      expect(session.status, ParkingSessionStatus.created);
      expect(session.startedAt, startedAt);
      expect(session.updatedAt, startedAt);
      expect(session.leavingSoonAt, isNull);
      expect(session.closedAt, isNull);
    });

    test('allows created to active', () {
      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.created,
          ParkingSessionStatus.active,
        ),
        isTrue,
      );
    });

    test('allows active to updated', () {
      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.active,
          ParkingSessionStatus.updated,
        ),
        isTrue,
      );
    });

    test('allows updated to updated', () {
      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.updated,
          ParkingSessionStatus.updated,
        ),
        isTrue,
      );
    });

    test('allows active or updated to leaving soon', () {
      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.active,
          ParkingSessionStatus.leavingSoon,
        ),
        isTrue,
      );

      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.updated,
          ParkingSessionStatus.leavingSoon,
        ),
        isTrue,
      );
    });

    test('allows active, updated, or leaving soon to closed', () {
      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.active,
          ParkingSessionStatus.closed,
        ),
        isTrue,
      );

      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.updated,
          ParkingSessionStatus.closed,
        ),
        isTrue,
      );

      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.leavingSoon,
          ParkingSessionStatus.closed,
        ),
        isTrue,
      );
    });

    test('rejects invalid transitions', () {
      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.created,
          ParkingSessionStatus.closed,
        ),
        isFalse,
      );

      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.leavingSoon,
          ParkingSessionStatus.active,
        ),
        isFalse,
      );

      expect(
        stateMachine.canTransition(
          ParkingSessionStatus.closed,
          ParkingSessionStatus.active,
        ),
        isFalse,
      );
    });

    test('updates status and updatedAt during transition', () {
      final session = createSession();

      final result = stateMachine.transition(
        session,
        ParkingSessionStatus.active,
        updatedAt,
      );

      expect(result.status, ParkingSessionStatus.active);
      expect(result.updatedAt, updatedAt);
      expect(result.startedAt, startedAt);
      expect(result.id, 'session-1');
      expect(result.parkingId, 'parking-1');
      expect(result.driverId, 'driver-1');
    });

    test('sets leavingSoonAt when entering leaving soon', () {
      final session = stateMachine.transition(
        createSession(),
        ParkingSessionStatus.active,
        updatedAt,
      );

      final result = stateMachine.transition(
        session,
        ParkingSessionStatus.leavingSoon,
        leavingSoonAt,
      );

      expect(result.status, ParkingSessionStatus.leavingSoon);
      expect(result.updatedAt, leavingSoonAt);
      expect(result.leavingSoonAt, leavingSoonAt);
      expect(result.closedAt, isNull);
    });

    test('sets closedAt when entering closed', () {
      final session = stateMachine.transition(
        createSession(),
        ParkingSessionStatus.active,
        updatedAt,
      );

      final result = stateMachine.transition(
        session,
        ParkingSessionStatus.closed,
        closedAt,
      );

      expect(result.status, ParkingSessionStatus.closed);
      expect(result.updatedAt, closedAt);
      expect(result.closedAt, closedAt);
      expect(result.leavingSoonAt, isNull);
    });

    test('preserves leavingSoonAt when closing a session', () {
      final active = stateMachine.transition(
        createSession(),
        ParkingSessionStatus.active,
        updatedAt,
      );

      final leavingSoon = stateMachine.transition(
        active,
        ParkingSessionStatus.leavingSoon,
        leavingSoonAt,
      );

      final result = stateMachine.transition(
        leavingSoon,
        ParkingSessionStatus.closed,
        closedAt,
      );

      expect(result.status, ParkingSessionStatus.closed);
      expect(result.leavingSoonAt, leavingSoonAt);
      expect(result.closedAt, closedAt);
    });

    test('throws StateError for an invalid transition', () {
      final session = createSession();

      expect(
        () => stateMachine.transition(
          session,
          ParkingSessionStatus.closed,
          closedAt,
        ),
        throwsStateError,
      );
    });
  });
}

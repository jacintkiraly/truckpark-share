import 'package:flutter_test/flutter_test.dart';
import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';
import 'package:truckpark_share/features/parking/domain/services/parking_session_expiration_policy.dart';

void main() {
  final now = DateTime.utc(2026, 10, 20, 12);
  const policy = ParkingSessionExpirationPolicy();

  ParkingSession createSession({
    ParkingSessionStatus status = ParkingSessionStatus.active,
    DateTime? startedAt,
    DateTime? updatedAt,
    DateTime? leavingSoonAt,
    DateTime? closedAt,
  }) {
    return ParkingSession(
      id: 'session-1',
      parkingId: 'parking-1',
      driverId: 'driver-1',
      status: status,
      startedAt: startedAt ?? now.subtract(const Duration(hours: 1)),
      updatedAt: updatedAt ?? now.subtract(const Duration(hours: 1)),
      leavingSoonAt: leavingSoonAt,
      closedAt: closedAt,
    );
  }

  group('isLeavingSoonSignalFresh', () {
    test('keeps the signal fresh before 15 minutes have elapsed', () {
      final signalAt = now.subtract(const Duration(minutes: 14, seconds: 59));

      final session = createSession(
        status: ParkingSessionStatus.leavingSoon,
        updatedAt: signalAt,
        leavingSoonAt: signalAt,
      );

      expect(policy.isLeavingSoonSignalFresh(session, now), isTrue);
    });

    test('expires the signal at exactly 15 minutes', () {
      final signalAt = now.subtract(const Duration(minutes: 15));

      final session = createSession(
        status: ParkingSessionStatus.leavingSoon,
        updatedAt: signalAt,
        leavingSoonAt: signalAt,
      );

      expect(policy.isLeavingSoonSignalFresh(session, now), isFalse);
    });

    test('uses updatedAt when leavingSoonAt is missing', () {
      final updatedAt = now.subtract(const Duration(minutes: 10));

      final session = createSession(
        status: ParkingSessionStatus.leavingSoon,
        updatedAt: updatedAt,
      );

      expect(policy.isLeavingSoonSignalFresh(session, now), isTrue);
    });

    test('does not consider other statuses to have a leaving-soon signal', () {
      final session = createSession(
        status: ParkingSessionStatus.active,
        updatedAt: now,
      );

      expect(policy.isLeavingSoonSignalFresh(session, now), isFalse);
    });
  });

  group('isOpenSessionExpired', () {
    test('does not expire an open session before 24 hours', () {
      final updatedAt = now.subtract(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      );

      final session = createSession(
        status: ParkingSessionStatus.active,
        updatedAt: updatedAt,
      );

      expect(policy.isOpenSessionExpired(session, now), isFalse);
    });

    test('expires an open session at exactly 24 hours', () {
      final updatedAt = now.subtract(const Duration(hours: 24));

      final session = createSession(
        status: ParkingSessionStatus.active,
        updatedAt: updatedAt,
      );

      expect(policy.isOpenSessionExpired(session, now), isTrue);
    });

    test('also expires an old updated session', () {
      final updatedAt = now.subtract(const Duration(hours: 25));

      final session = createSession(
        status: ParkingSessionStatus.updated,
        updatedAt: updatedAt,
      );

      expect(policy.isOpenSessionExpired(session, now), isTrue);
    });

    test('does not classify a closed session as an expired open session', () {
      final updatedAt = now.subtract(const Duration(days: 3));

      final session = createSession(
        status: ParkingSessionStatus.closed,
        updatedAt: updatedAt,
        closedAt: updatedAt,
      );

      expect(policy.isOpenSessionExpired(session, now), isFalse);
    });
  });
}

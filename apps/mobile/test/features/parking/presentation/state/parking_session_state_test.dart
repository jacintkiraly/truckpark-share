import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_session.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_session_status.dart';
import 'package:truckpark_share/features/parking/presentation/state/parking_session_state.dart';

void main() {
  group('ParkingSessionState', () {
    final startedAt = DateTime(2026, 10, 8, 8);

    final session = ParkingSession(
      id: 'session-1',
      parkingId: 'parking-1',
      driverId: 'driver-1',
      status: ParkingSessionStatus.active,
      startedAt: startedAt,
      updatedAt: startedAt,
    );

    test('starts empty', () {
      const state = ParkingSessionState();

      expect(state.isLoading, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.session, isNull);
      expect(state.errorMessage, isNull);
    });

    test('stores a session', () {
      const state = ParkingSessionState();

      final result = state.copyWith(session: session);

      expect(result.session, same(session));
    });

    test('can clear the current session', () {
      final state = ParkingSessionState(session: session);

      final result = state.copyWith(clearSession: true);

      expect(result.session, isNull);
    });

    test('replaces the error message', () {
      const state = ParkingSessionState();

      final result = state.copyWith(errorMessage: 'Test error');

      expect(result.errorMessage, 'Test error');
    });
  });
}

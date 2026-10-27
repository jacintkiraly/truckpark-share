import '../entities/parking_session.dart';
import '../enums/parking_session_status.dart';

/// Defines when a parking session or its leaving-soon signal is stale.
///
/// This policy only evaluates timestamps. It does not update or delete
/// Firestore documents.
class ParkingSessionExpirationPolicy {
  const ParkingSessionExpirationPolicy({
    this.leavingSoonDuration = const Duration(minutes: 15),
    this.openSessionDuration = const Duration(hours: 24),
  });

  /// Maximum time a leaving-soon signal remains valid without a refresh.
  final Duration leavingSoonDuration;

  /// Maximum time an open session can remain unchanged before being stale.
  final Duration openSessionDuration;

  /// Returns whether the session's leaving-soon signal is still valid.
  ///
  /// Uses [ParkingSession.leavingSoonAt] when available and falls back to
  /// [ParkingSession.updatedAt] for older session records.
  bool isLeavingSoonSignalFresh(ParkingSession session, DateTime now) {
    if (session.status != ParkingSessionStatus.leavingSoon) {
      return false;
    }

    final signalAt = session.leavingSoonAt ?? session.updatedAt;
    final expiresAt = signalAt.add(leavingSoonDuration);

    return now.isBefore(expiresAt);
  }

  /// Returns whether a non-closed session has exceeded its allowed age.
  ///
  /// A session becomes stale at the exact expiration boundary.
  /// Closed sessions are never classified as stale open sessions.
  bool isOpenSessionExpired(ParkingSession session, DateTime now) {
    if (session.status == ParkingSessionStatus.closed) {
      return false;
    }

    final expiresAt =
        session.plannedEndAt ?? session.updatedAt.add(openSessionDuration);

    return !now.isBefore(expiresAt);
  }
}

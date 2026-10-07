import '../entities/parking_session.dart';
import '../enums/parking_session_status.dart';

class ParkingSessionStateMachine {
  const ParkingSessionStateMachine();

  bool canTransition(ParkingSessionStatus from, ParkingSessionStatus to) {
    const transitions = {
      ParkingSessionStatus.created: {ParkingSessionStatus.active},
      ParkingSessionStatus.active: {
        ParkingSessionStatus.updated,
        ParkingSessionStatus.leavingSoon,
        ParkingSessionStatus.closed,
      },
      ParkingSessionStatus.updated: {
        ParkingSessionStatus.updated,
        ParkingSessionStatus.leavingSoon,
        ParkingSessionStatus.closed,
      },
      ParkingSessionStatus.leavingSoon: {ParkingSessionStatus.closed},
      ParkingSessionStatus.closed: <ParkingSessionStatus>{},
    };

    return transitions[from]?.contains(to) ?? false;
  }

  ParkingSession transition(
    ParkingSession session,
    ParkingSessionStatus nextStatus,
    DateTime at,
  ) {
    if (!canTransition(session.status, nextStatus)) {
      throw StateError(
        'Invalid parking session transition: '
        '${session.status.name} -> ${nextStatus.name}',
      );
    }

    return session.copyWith(
      status: nextStatus,
      updatedAt: at,
      leavingSoonAt: nextStatus == ParkingSessionStatus.leavingSoon
          ? at
          : session.leavingSoonAt,
      closedAt: nextStatus == ParkingSessionStatus.closed
          ? at
          : session.closedAt,
    );
  }
}

import '../entities/parking_session.dart';

abstract class ParkingSessionRepository {
  Future<void> createSession(
    ParkingSession session,
  );

  Stream<ParkingSession?> watchOpenSession(
    String driverId,
  );

  Future<void> updateSession(
    ParkingSession session,
  );
}

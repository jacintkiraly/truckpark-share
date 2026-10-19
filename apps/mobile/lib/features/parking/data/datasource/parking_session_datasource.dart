import '../dto/parking_session_dto.dart';

abstract class ParkingSessionDataSource {
  Future<void> createSession(ParkingSessionDto session);

  Stream<ParkingSessionDto?> watchOpenSession(String driverId);

  Stream<List<ParkingSessionDto>> watchLeavingSoonSessions(
    List<String> parkingIds,
  );

  Future<void> updateSession(ParkingSessionDto session);
}

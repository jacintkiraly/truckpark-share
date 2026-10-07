import '../dto/parking_session_dto.dart';

abstract class ParkingSessionDataSource {
  Future<void> createSession(ParkingSessionDto session);

  Stream<ParkingSessionDto?> watchOpenSession(String driverId);

  Future<void> updateSession(ParkingSessionDto session);
}

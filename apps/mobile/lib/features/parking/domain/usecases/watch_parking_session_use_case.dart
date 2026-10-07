import '../entities/parking_session.dart';
import '../repositories/parking_session_repository.dart';

class WatchParkingSessionUseCase {
  WatchParkingSessionUseCase(
    this._repository,
  );

  final ParkingSessionRepository _repository;

  Stream<ParkingSession?> call(
    String driverId,
  ) {
    return _repository.watchOpenSession(driverId);
  }
}

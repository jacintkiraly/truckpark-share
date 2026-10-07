import '../entities/parking_session.dart';
import '../repositories/parking_session_repository.dart';

class UpdateParkingSessionUseCase {
  UpdateParkingSessionUseCase(
    this._repository,
  );

  final ParkingSessionRepository _repository;

  Future<void> call(
    ParkingSession session,
  ) {
    return _repository.updateSession(session);
  }
}

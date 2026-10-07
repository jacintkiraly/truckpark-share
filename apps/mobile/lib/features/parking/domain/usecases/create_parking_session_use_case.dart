import '../entities/parking_session.dart';
import '../repositories/parking_session_repository.dart';

class CreateParkingSessionUseCase {
  CreateParkingSessionUseCase(
    this._repository,
  );

  final ParkingSessionRepository _repository;

  Future<void> call(
    ParkingSession session,
  ) {
    return _repository.createSession(session);
  }
}

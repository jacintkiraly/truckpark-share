import '../entities/parking_session.dart';
import '../repositories/parking_session_repository.dart';

class WatchLeavingSoonParkingSessionsUseCase {
  WatchLeavingSoonParkingSessionsUseCase(this._repository);

  final ParkingSessionRepository _repository;

  Stream<List<ParkingSession>> call(List<String> parkingIds) {
    if (parkingIds.isEmpty) {
      return Stream<List<ParkingSession>>.value(const <ParkingSession>[]);
    }

    return _repository.watchLeavingSoonSessions(parkingIds);
  }
}

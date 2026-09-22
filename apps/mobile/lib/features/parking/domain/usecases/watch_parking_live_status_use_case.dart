import '../entities/parking_live_status.dart';
import '../repositories/parking_live_status_repository.dart';

class WatchParkingLiveStatusUseCase {
  WatchParkingLiveStatusUseCase(
    this._repository,
  );

  final ParkingLiveStatusRepository _repository;

  Stream<ParkingLiveStatus?> call(
    String parkingId,
  ) {
    return _repository.watchLiveStatus(
      parkingId,
    );
  }
}
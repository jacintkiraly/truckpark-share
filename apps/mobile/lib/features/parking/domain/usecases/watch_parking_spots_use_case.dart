import '../entities/parking_spot.dart';
import '../repositories/parking_repository.dart';

class WatchParkingSpotsUseCase {
  const WatchParkingSpotsUseCase(this._repository);

  final ParkingRepository _repository;

  Stream<List<ParkingSpot>> call() {
    return _repository.watchParkingSpots();
  }
}
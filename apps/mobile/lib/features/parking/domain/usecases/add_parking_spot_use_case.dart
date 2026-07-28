import '../entities/parking_spot.dart';
import '../repositories/parking_repository.dart';

class AddParkingSpotUseCase {
  const AddParkingSpotUseCase(this._repository);

  final ParkingRepository _repository;

  Future<void> call(ParkingSpot parkingSpot) {
    return _repository.addParkingSpot(parkingSpot);
  }
}
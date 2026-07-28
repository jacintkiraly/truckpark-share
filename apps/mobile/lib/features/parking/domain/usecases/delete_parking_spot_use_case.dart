import '../repositories/parking_repository.dart';

class DeleteParkingSpotUseCase {
  const DeleteParkingSpotUseCase(this._repository);

  final ParkingRepository _repository;

  Future<void> call(String parkingSpotId) {
    return _repository.deleteParkingSpot(parkingSpotId);
  }
}
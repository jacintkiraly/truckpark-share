import '../entities/parking_spot.dart';
import '../repositories/parking_repository.dart';
import '../value_objects/parking_viewport.dart';

class QueryParkingSpotsInViewportUseCase {
  const QueryParkingSpotsInViewportUseCase(this._repository);

  final ParkingRepository _repository;

  Future<List<ParkingSpot>> call(
    ParkingViewport viewport,
  ) {
    return _repository.queryParkingSpotsInViewport(viewport);
  }
}

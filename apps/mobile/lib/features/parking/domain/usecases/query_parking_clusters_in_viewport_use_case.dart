import '../value_objects/parking_map_cluster.dart';
import '../value_objects/parking_viewport.dart';
import '../repositories/parking_repository.dart';

class QueryParkingClustersInViewportUseCase {
  const QueryParkingClustersInViewportUseCase(
    this._repository,
  );

  static const int maxCells = 30;

  final ParkingRepository _repository;

  Future<List<ParkingMapCluster>> call(
    ParkingViewport viewport,
  ) {
    return _repository.countParkingSpotsInViewport(
      viewport,
      maxCells: maxCells,
    );
  }
}

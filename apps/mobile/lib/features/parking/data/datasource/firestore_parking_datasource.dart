import '../dto/parking_spot_dto.dart';
import '../../domain/value_objects/parking_map_cluster.dart';
import '../../domain/value_objects/parking_viewport.dart';

abstract interface class FirestoreParkingDataSource {
  Stream<List<ParkingSpotDto>> watchParkingSpots();

  Future<List<ParkingSpotDto>> queryParkingSpotsInViewport(
    ParkingViewport viewport,
  );

  Future<List<ParkingMapCluster>> countParkingSpotsInViewport(
    ParkingViewport viewport, {
    required int maxCells,
  });

  Future<void> addParkingSpot(
    ParkingSpotDto parkingSpot,
  );

  Future<void> updateParkingSpot(
    ParkingSpotDto parkingSpot,
  );

  Future<void> deleteParkingSpot(
    String parkingSpotId,
  );
}

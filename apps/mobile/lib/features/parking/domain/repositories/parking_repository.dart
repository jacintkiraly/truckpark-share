import '../entities/parking_spot.dart';
import '../value_objects/parking_map_cluster.dart';
import '../value_objects/parking_viewport.dart';

abstract class ParkingRepository {
  Stream<List<ParkingSpot>> watchParkingSpots();

  Future<List<ParkingSpot>> queryParkingSpotsInViewport(
    ParkingViewport viewport,
  );

  Future<List<ParkingMapCluster>> countParkingSpotsInViewport(
    ParkingViewport viewport, {
    required int maxCells,
  });

  Future<void> addParkingSpot(ParkingSpot parkingSpot);

  Future<void> updateParkingSpot(ParkingSpot parkingSpot);

  Future<void> deleteParkingSpot(String parkingSpotId);
}

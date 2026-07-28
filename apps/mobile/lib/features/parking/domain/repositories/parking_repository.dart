import '../entities/parking_spot.dart';

abstract class ParkingRepository {
  Stream<List<ParkingSpot>> watchParkingSpots();

  Future<void> addParkingSpot(ParkingSpot parkingSpot);

  Future<void> updateParkingSpot(ParkingSpot parkingSpot);

  Future<void> deleteParkingSpot(String parkingSpotId);
}
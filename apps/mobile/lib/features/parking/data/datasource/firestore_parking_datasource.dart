import '../dto/parking_spot_dto.dart';

abstract interface class FirestoreParkingDataSource {
  Stream<List<ParkingSpotDto>> watchParkingSpots();

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
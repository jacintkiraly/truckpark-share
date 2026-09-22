import '../entities/parking_live_status.dart';

abstract class ParkingLiveStatusRepository {
  Stream<ParkingLiveStatus?> watchLiveStatus(
    String parkingId,
  );
}

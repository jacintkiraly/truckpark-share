import '../entities/parking_report.dart';

abstract class ParkingLiveRepository {
  Future<void> addReport(ParkingReport report);

  Stream<List<ParkingReport>> watchReports(
    String parkingId,
  );
}
import '../dto/parking_report_dto.dart';

abstract class ParkingLiveDataSource {
  Future<void> addReport(ParkingReportDto report);

  Stream<List<ParkingReportDto>> watchReports(
    String parkingId,
  );
}
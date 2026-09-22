import '../entities/parking_report.dart';
import '../repositories/parking_live_repository.dart';

class CreateParkingReportUseCase {
  CreateParkingReportUseCase(
    this._repository,
  );

  final ParkingLiveRepository _repository;

  Future<void> call(
    ParkingReport report,
  ) {
    return _repository.addReport(report);
  }
}
import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_report.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_status.dart';
import 'package:truckpark_share/features/parking/domain/repositories/parking_live_repository.dart';
import 'package:truckpark_share/features/parking/domain/usecases/create_parking_report_use_case.dart';

class FakeParkingLiveRepository
    implements ParkingLiveRepository {
  ParkingReport? addedReport;

  @override
  Future<void> addReport(
    ParkingReport report,
  ) async {
    addedReport = report;
  }

  @override
  Stream<List<ParkingReport>> watchReports(
    String parkingId,
  ) {
    return const Stream.empty();
  }
}

void main() {
  group('CreateParkingReportUseCase', () {
    test('adds the report through the repository', () async {
      final repository = FakeParkingLiveRepository();
      final useCase = CreateParkingReportUseCase(
        repository,
      );

      final report = ParkingReport(
        id: 'report-1',
        parkingId: 'parking-1',
        status: ParkingStatus.nearlyFull,
        freeSpaces: 5,
        reportedBy: 'driver-1',
        reportedAt: DateTime(2026, 9, 22, 18),
      );

      await useCase(report);

      expect(repository.addedReport, same(report));
    });
  });
}

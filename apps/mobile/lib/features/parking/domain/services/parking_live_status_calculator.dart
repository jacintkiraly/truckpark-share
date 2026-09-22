import '../entities/parking_live_status.dart';
import '../entities/parking_report.dart';

class ParkingLiveStatusCalculator {
  const ParkingLiveStatusCalculator();

  ParkingLiveStatus? calculate(
    List<ParkingReport> reports,
    DateTime now,
  ) {
    final validReports = reports
        .where(
          (report) =>
              !report.reportedAt.isAfter(now) &&
              now.difference(report.reportedAt) <=
                  const Duration(hours: 2),
        )
        .toList();

    if (validReports.isEmpty) {
      return null;
    }

    validReports.sort(
      (a, b) => b.reportedAt.compareTo(a.reportedAt),
    );

    final latest = validReports.first;

    return ParkingLiveStatus(
      parkingId: latest.parkingId,
      status: latest.status,
      freeSpaces: latest.freeSpaces,
      lastUpdated: latest.reportedAt,
      updatedBy: latest.reportedBy,
    );
  }
}

import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_report.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_status.dart';
import 'package:truckpark_share/features/parking/domain/services/parking_live_status_calculator.dart';

void main() {
  const calculator = ParkingLiveStatusCalculator();

  final now = DateTime(2026, 9, 22, 12);

  ParkingReport report({
    required String id,
    required ParkingStatus status,
    required DateTime reportedAt,
    int? freeSpaces,
    String reportedBy = 'driver-1',
  }) {
    return ParkingReport(
      id: id,
      parkingId: 'parking-1',
      status: status,
      freeSpaces: freeSpaces,
      reportedBy: reportedBy,
      reportedAt: reportedAt,
    );
  }

  group('ParkingLiveStatusCalculator', () {
    test('returns null when there are no reports', () {
      final result = calculator.calculate(
        const [],
        now,
      );

      expect(result, isNull);
    });

    test('returns null when all reports are older than two hours', () {
      final reports = [
        report(
          id: 'report-1',
          status: ParkingStatus.available,
          freeSpaces: 12,
          reportedAt: now.subtract(
            const Duration(hours: 2, minutes: 1),
          ),
        ),
      ];

      final result = calculator.calculate(
        reports,
        now,
      );

      expect(result, isNull);
    });

    test('uses a fresh report to create live status', () {
      final reportedAt = now.subtract(
        const Duration(minutes: 20),
      );

      final reports = [
        report(
          id: 'report-1',
          status: ParkingStatus.nearlyFull,
          freeSpaces: 5,
          reportedAt: reportedAt,
        ),
      ];

      final result = calculator.calculate(
        reports,
        now,
      );

      expect(result, isNotNull);
      expect(result!.parkingId, 'parking-1');
      expect(result.status, ParkingStatus.nearlyFull);
      expect(result.freeSpaces, 5);
      expect(result.lastUpdated, reportedAt);
      expect(result.updatedBy, 'driver-1');
      expect(result.confidence, isNull);
    });

    test('uses the most recent fresh report', () {
      final olderReport = report(
        id: 'report-1',
        status: ParkingStatus.available,
        freeSpaces: 15,
        reportedAt: now.subtract(
          const Duration(minutes: 30),
        ),
      );

      final latestReportedAt = now.subtract(
        const Duration(minutes: 5),
      );

      final latestReport = report(
        id: 'report-2',
        status: ParkingStatus.full,
        freeSpaces: 0,
        reportedAt: latestReportedAt,
        reportedBy: 'driver-2',
      );

      final result = calculator.calculate(
        [
          olderReport,
          latestReport,
        ],
        now,
      );

      expect(result, isNotNull);
      expect(result!.status, ParkingStatus.full);
      expect(result.freeSpaces, 0);
      expect(result.lastUpdated, latestReportedAt);
      expect(result.updatedBy, 'driver-2');
    });

    test('keeps freeSpaces null when the latest report has no value', () {
      final reports = [
        report(
          id: 'report-1',
          status: ParkingStatus.available,
          reportedAt: now.subtract(
            const Duration(minutes: 10),
          ),
        ),
      ];

      final result = calculator.calculate(
        reports,
        now,
      );

      expect(result, isNotNull);
      expect(result!.freeSpaces, isNull);
    });

    test('ignores future reports', () {
      final reports = [
        report(
          id: 'future-report',
          status: ParkingStatus.full,
          freeSpaces: 0,
          reportedAt: now.add(
            const Duration(minutes: 5),
          ),
        ),
        report(
          id: 'current-report',
          status: ParkingStatus.available,
          freeSpaces: 10,
          reportedAt: now.subtract(
            const Duration(minutes: 5),
          ),
        ),
      ];

      final result = calculator.calculate(
        reports,
        now,
      );

      expect(result, isNotNull);
      expect(result!.status, ParkingStatus.available);
      expect(result.freeSpaces, 10);
    });

    test('accepts a report exactly two hours old', () {
      final reports = [
        report(
          id: 'report-1',
          status: ParkingStatus.available,
          freeSpaces: 8,
          reportedAt: now.subtract(
            const Duration(hours: 2),
          ),
        ),
      ];

      final result = calculator.calculate(
        reports,
        now,
      );

      expect(result, isNotNull);
      expect(result!.status, ParkingStatus.available);
      expect(result.freeSpaces, 8);
    });
  });
}

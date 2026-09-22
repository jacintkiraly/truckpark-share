import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingReportDto {
  const ParkingReportDto({
    required this.id,
    required this.parkingId,
    required this.status,
    required this.reportedBy,
    required this.reportedAt,
    this.freeSpaces,
  });

  final String id;
  final String parkingId;
  final String status;
  final int? freeSpaces;
  final String reportedBy;
  final DateTime reportedAt;

  factory ParkingReportDto.fromFirestore(
    String id,
    String parkingId,
    Map<String, dynamic> data,
  ) {
    final reportedAtValue = data['reportedAt'];

    if (reportedAtValue is! Timestamp) {
      throw StateError(
        'Parking report "$id" has an invalid reportedAt value.',
      );
    }

    return ParkingReportDto(
      id: id,
      parkingId: parkingId,
      status: data['status'] as String,
      freeSpaces: data['freeSpaces'] as int?,
      reportedBy: data['reportedBy'] as String,
      reportedAt: reportedAtValue.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'freeSpaces': freeSpaces,
      'reportedBy': reportedBy,
      'reportedAt': Timestamp.fromDate(reportedAt),
    };
  }
}
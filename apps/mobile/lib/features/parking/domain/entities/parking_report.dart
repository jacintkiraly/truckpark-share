import 'package:equatable/equatable.dart';

import '../enums/parking_status.dart';

class ParkingReport extends Equatable {
  const ParkingReport({
    required this.id,
    required this.parkingId,
    required this.status,
    required this.reportedBy,
    required this.reportedAt,
    this.freeSpaces,
  });

  final String id;
  final String parkingId;
  final ParkingStatus status;
  final int? freeSpaces;
  final String reportedBy;
  final DateTime reportedAt;

  @override
  List<Object?> get props => [
        id,
        parkingId,
        status,
        freeSpaces,
        reportedBy,
        reportedAt,
      ];
}
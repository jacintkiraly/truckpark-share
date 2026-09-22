import 'package:equatable/equatable.dart';

import '../enums/parking_status.dart';

class ParkingLiveStatus extends Equatable {
  const ParkingLiveStatus({
    required this.parkingId,
    required this.status,
    required this.lastUpdated,
    this.freeSpaces,
    this.updatedBy,
    this.confidence,
  });

  final String parkingId;
  final ParkingStatus status;
  final int? freeSpaces;
  final DateTime lastUpdated;
  final String? updatedBy;
  final double? confidence;

  @override
  List<Object?> get props => [
        parkingId,
        status,
        freeSpaces,
        lastUpdated,
        updatedBy,
        confidence,
      ];
}
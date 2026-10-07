import 'package:equatable/equatable.dart';

import '../enums/parking_session_status.dart';

class ParkingSession extends Equatable {
  const ParkingSession({
    required this.id,
    required this.parkingId,
    required this.driverId,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
    this.leavingSoonAt,
    this.closedAt,
  });

  factory ParkingSession.create({
    required String id,
    required String parkingId,
    required String driverId,
    required DateTime startedAt,
  }) {
    return ParkingSession(
      id: id,
      parkingId: parkingId,
      driverId: driverId,
      status: ParkingSessionStatus.created,
      startedAt: startedAt,
      updatedAt: startedAt,
    );
  }

  final String id;
  final String parkingId;
  final String driverId;
  final ParkingSessionStatus status;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? leavingSoonAt;
  final DateTime? closedAt;

  ParkingSession copyWith({
    String? id,
    String? parkingId,
    String? driverId,
    ParkingSessionStatus? status,
    DateTime? startedAt,
    DateTime? updatedAt,
    DateTime? leavingSoonAt,
    DateTime? closedAt,
  }) {
    return ParkingSession(
      id: id ?? this.id,
      parkingId: parkingId ?? this.parkingId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      leavingSoonAt: leavingSoonAt ?? this.leavingSoonAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    parkingId,
    driverId,
    status,
    startedAt,
    updatedAt,
    leavingSoonAt,
    closedAt,
  ];
}

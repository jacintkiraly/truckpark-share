import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSessionDto {
  const ParkingSessionDto({
    required this.id,
    required this.parkingId,
    required this.driverId,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
    this.leavingSoonAt,
    this.closedAt,
  });

  final String id;
  final String parkingId;
  final String driverId;
  final String status;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? leavingSoonAt;
  final DateTime? closedAt;

  factory ParkingSessionDto.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final startedAtValue = data['startedAt'];
    final updatedAtValue = data['updatedAt'];

    if (startedAtValue is! Timestamp) {
      throw StateError('Parking session "$id" has an invalid startedAt value.');
    }

    if (updatedAtValue is! Timestamp) {
      throw StateError('Parking session "$id" has an invalid updatedAt value.');
    }

    final leavingSoonAtValue = data['leavingSoonAt'];
    final closedAtValue = data['closedAt'];

    if (leavingSoonAtValue != null && leavingSoonAtValue is! Timestamp) {
      throw StateError(
        'Parking session "$id" has an invalid leavingSoonAt value.',
      );
    }

    if (closedAtValue != null && closedAtValue is! Timestamp) {
      throw StateError('Parking session "$id" has an invalid closedAt value.');
    }

    return ParkingSessionDto(
      id: id,
      parkingId: data['parkingId'] as String,
      driverId: data['driverId'] as String,
      status: data['status'] as String,
      startedAt: startedAtValue.toDate(),
      updatedAt: updatedAtValue.toDate(),
      leavingSoonAt: leavingSoonAtValue == null
          ? null
          : (leavingSoonAtValue as Timestamp).toDate(),
      closedAt: closedAtValue == null
          ? null
          : (closedAtValue as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'parkingId': parkingId,
      'driverId': driverId,
      'status': status,
      'startedAt': Timestamp.fromDate(startedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'leavingSoonAt': leavingSoonAt == null
          ? null
          : Timestamp.fromDate(leavingSoonAt!),
      'closedAt': closedAt == null ? null : Timestamp.fromDate(closedAt!),
    };
  }
}

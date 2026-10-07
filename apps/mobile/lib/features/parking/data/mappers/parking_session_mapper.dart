import '../../domain/entities/parking_session.dart';
import '../../domain/enums/parking_session_status.dart';
import '../dto/parking_session_dto.dart';

class ParkingSessionMapper {
  const ParkingSessionMapper._();

  static ParkingSession toDomain(ParkingSessionDto dto) {
    return ParkingSession(
      id: dto.id,
      parkingId: dto.parkingId,
      driverId: dto.driverId,
      status: _statusFromString(dto.status),
      startedAt: dto.startedAt,
      updatedAt: dto.updatedAt,
      leavingSoonAt: dto.leavingSoonAt,
      closedAt: dto.closedAt,
    );
  }

  static ParkingSessionDto toDto(ParkingSession session) {
    return ParkingSessionDto(
      id: session.id,
      parkingId: session.parkingId,
      driverId: session.driverId,
      status: session.status.name,
      startedAt: session.startedAt,
      updatedAt: session.updatedAt,
      leavingSoonAt: session.leavingSoonAt,
      closedAt: session.closedAt,
    );
  }

  static ParkingSessionStatus _statusFromString(String value) {
    return ParkingSessionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () {
        throw StateError('Unknown parking session status: $value');
      },
    );
  }
}

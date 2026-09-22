import '../../domain/entities/parking_report.dart';
import '../../domain/enums/parking_status.dart';
import '../dto/parking_report_dto.dart';

class ParkingReportMapper {
  const ParkingReportMapper._();

  static ParkingReport toDomain(
    ParkingReportDto dto,
  ) {
    return ParkingReport(
      id: dto.id,
      parkingId: dto.parkingId,
      status: _statusFromString(dto.status),
      freeSpaces: dto.freeSpaces,
      reportedBy: dto.reportedBy,
      reportedAt: dto.reportedAt,
    );
  }

  static ParkingReportDto toDto(
    ParkingReport report,
  ) {
    return ParkingReportDto(
      id: report.id,
      parkingId: report.parkingId,
      status: report.status.name,
      freeSpaces: report.freeSpaces,
      reportedBy: report.reportedBy,
      reportedAt: report.reportedAt,
    );
  }

  static ParkingStatus _statusFromString(
    String value,
  ) {
    return ParkingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () {
        throw StateError(
          'Unknown parking status: $value',
        );
      },
    );
  }
}
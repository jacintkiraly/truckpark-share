import '../../domain/entities/parking_report.dart';
import '../../domain/repositories/parking_live_repository.dart';
import '../datasource/parking_live_datasource.dart';
import '../mappers/parking_report_mapper.dart';

class ParkingLiveRepositoryImpl
    implements ParkingLiveRepository {
  ParkingLiveRepositoryImpl(
    this._dataSource,
  );

  final ParkingLiveDataSource _dataSource;

  @override
  Future<void> addReport(
    ParkingReport report,
  ) async {
    final dto = ParkingReportMapper.toDto(
      report,
    );

    await _dataSource.addReport(
      dto,
    );
  }

  @override
  Stream<List<ParkingReport>> watchReports(
    String parkingId,
  ) {
    return _dataSource
        .watchReports(parkingId)
        .map(
          (dtos) => dtos
              .map(
                ParkingReportMapper.toDomain,
              )
              .toList(),
        );
  }
}
import '../../domain/entities/parking_session.dart';
import '../../domain/repositories/parking_session_repository.dart';
import '../datasource/parking_session_datasource.dart';
import '../mappers/parking_session_mapper.dart';

class ParkingSessionRepositoryImpl implements ParkingSessionRepository {
  ParkingSessionRepositoryImpl(this._dataSource);

  final ParkingSessionDataSource _dataSource;

  @override
  Future<void> createSession(ParkingSession session) async {
    final dto = ParkingSessionMapper.toDto(session);

    await _dataSource.createSession(dto);
  }

  @override
  Stream<ParkingSession?> watchOpenSession(String driverId) {
    return _dataSource
        .watchOpenSession(driverId)
        .map((dto) => dto == null ? null : ParkingSessionMapper.toDomain(dto));
  }

  @override
  Future<void> updateSession(ParkingSession session) async {
    final dto = ParkingSessionMapper.toDto(session);

    await _dataSource.updateSession(dto);
  }
}

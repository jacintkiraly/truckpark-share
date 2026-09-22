import '../../domain/entities/parking_live_status.dart';
import '../../domain/repositories/parking_live_repository.dart';
import '../../domain/repositories/parking_live_status_repository.dart';
import '../../domain/services/parking_live_status_calculator.dart';

class ParkingLiveStatusRepositoryImpl
    implements ParkingLiveStatusRepository {
  ParkingLiveStatusRepositoryImpl(
    this._liveRepository,
    this._calculator,
  );

  final ParkingLiveRepository _liveRepository;
  final ParkingLiveStatusCalculator _calculator;

  @override
  Stream<ParkingLiveStatus?> watchLiveStatus(
    String parkingId,
  ) {
    return _liveRepository.watchReports(
      parkingId,
    ).map(
      (reports) => _calculator.calculate(
        reports,
        DateTime.now(),
      ),
    );
  }
}

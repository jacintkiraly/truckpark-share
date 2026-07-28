import 'package:truckpark_share/features/parking/data/datasource/firestore_parking_datasource.dart';
import 'package:truckpark_share/features/parking/data/mappers/parking_spot_mapper.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_spot.dart';
import 'package:truckpark_share/features/parking/domain/repositories/parking_repository.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  ParkingRepositoryImpl({
    required FirestoreParkingDataSource dataSource,
    required ParkingSpotMapper mapper,
  })  : _dataSource = dataSource,
        _mapper = mapper;

  @override
  Stream<List<ParkingSpot>> watchParkingSpots() {
    return _dataSource.watchParkingSpots().map(
          (dtos) => dtos
              .map(_mapper.fromDto)
              .toList(),
        );
  }

  @override
  Future<void> addParkingSpot(
    ParkingSpot parkingSpot,
  ) {
    return _dataSource.addParkingSpot(
      _mapper.toDto(parkingSpot),
    );
  }

  @override
  Future<void> updateParkingSpot(
    ParkingSpot parkingSpot,
  ) {
    return _dataSource.updateParkingSpot(
      _mapper.toDto(parkingSpot),
    );
  }

  @override
  Future<void> deleteParkingSpot(
    String parkingSpotId,
  ) {
    return _dataSource.deleteParkingSpot(
      parkingSpotId,
    );
  }

  final FirestoreParkingDataSource _dataSource;
  final ParkingSpotMapper _mapper;
}
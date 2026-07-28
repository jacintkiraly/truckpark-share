import 'package:get_it/get_it.dart';

import '../../features/parking/data/datasource/firestore_parking_datasource.dart';
import '../../features/parking/data/datasource/firestore_parking_datasource_impl.dart';
import '../../features/parking/data/mappers/parking_spot_mapper.dart';
import '../../features/parking/data/repositories/parking_repository_impl.dart';
import '../../features/parking/domain/repositories/parking_repository.dart';

void registerParkingModule(GetIt sl) {
  if (!sl.isRegistered<ParkingSpotMapper>()) {
    sl.registerLazySingleton(
      () => const ParkingSpotMapper(),
    );
  }

  if (!sl.isRegistered<FirestoreParkingDataSource>()) {
    sl.registerLazySingleton<FirestoreParkingDataSource>(
      () => FirestoreParkingDataSourceImpl(
        firestore: sl(),
      ),
    );
  }

  if (!sl.isRegistered<ParkingRepository>()) {
    sl.registerLazySingleton<ParkingRepository>(
      () => ParkingRepositoryImpl(
        dataSource: sl(),
        mapper: sl(),
      ),
    );
  }
}
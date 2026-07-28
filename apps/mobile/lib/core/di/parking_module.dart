import 'package:get_it/get_it.dart';

import '../../features/parking/data/datasource/firestore_parking_datasource.dart';
import '../../features/parking/data/datasource/firestore_parking_datasource_impl.dart';
import '../../features/parking/data/mappers/parking_spot_mapper.dart';
import '../../features/parking/data/repositories/parking_repository_impl.dart';
import '../../features/parking/domain/repositories/parking_repository.dart';

import '../../features/parking/domain/usecases/watch_parking_spots_use_case.dart';
import '../../features/parking/domain/usecases/add_parking_spot_use_case.dart';
import '../../features/parking/domain/usecases/update_parking_spot_use_case.dart';
import '../../features/parking/domain/usecases/delete_parking_spot_use_case.dart';
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

sl.registerLazySingleton(
  () => WatchParkingSpotsUseCase(sl()),
);

sl.registerLazySingleton(
  () => AddParkingSpotUseCase(sl()),
);

sl.registerLazySingleton(
  () => UpdateParkingSpotUseCase(sl()),
);

sl.registerLazySingleton(
  () => DeleteParkingSpotUseCase(sl()),
);
}
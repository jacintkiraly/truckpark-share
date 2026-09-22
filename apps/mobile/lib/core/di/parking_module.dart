import 'package:get_it/get_it.dart';

import '../../features/parking/data/datasource/firestore_parking_datasource.dart';
import '../../features/parking/data/datasource/firestore_parking_datasource_impl.dart';
import '../../features/parking/data/datasource/firestore_parking_live_datasource.dart';
import '../../features/parking/data/datasource/parking_live_datasource.dart';
import '../../features/parking/data/mappers/parking_spot_mapper.dart';
import '../../features/parking/data/repositories/parking_live_repository_impl.dart';
import '../../features/parking/data/repositories/parking_live_status_repository_impl.dart';
import '../../features/parking/data/repositories/parking_repository_impl.dart';
import '../../features/parking/domain/repositories/parking_live_repository.dart';
import '../../features/parking/domain/repositories/parking_live_status_repository.dart';
import '../../features/parking/domain/repositories/parking_repository.dart';
import '../../features/parking/domain/services/parking_live_status_calculator.dart';
import '../../features/parking/domain/usecases/add_parking_spot_use_case.dart';
import '../../features/parking/domain/usecases/create_parking_report_use_case.dart';
import '../../features/parking/domain/usecases/delete_parking_spot_use_case.dart';
import '../../features/parking/domain/usecases/update_parking_spot_use_case.dart';
import '../../features/parking/domain/usecases/watch_parking_live_status_use_case.dart';
import '../../features/parking/domain/usecases/watch_parking_spots_use_case.dart';

void registerParkingModule(GetIt sl) {
  if (!sl.isRegistered<ParkingSpotMapper>()) {
    sl.registerLazySingleton(() => const ParkingSpotMapper());
  }

  // Static parking data source.
  if (!sl.isRegistered<FirestoreParkingDataSource>()) {
    sl.registerLazySingleton<FirestoreParkingDataSource>(
      () => FirestoreParkingDataSourceImpl(firestore: sl()),
    );
  }

  // Static parking repository.
  if (!sl.isRegistered<ParkingRepository>()) {
    sl.registerLazySingleton<ParkingRepository>(
      () => ParkingRepositoryImpl(dataSource: sl(), mapper: sl()),
    );
  }

  // Live parking report data source.
  if (!sl.isRegistered<ParkingLiveDataSource>()) {
    sl.registerLazySingleton<ParkingLiveDataSource>(
      () => FirestoreParkingLiveDataSource(sl()),
    );
  }

  // Live parking report repository.
  if (!sl.isRegistered<ParkingLiveRepository>()) {
    sl.registerLazySingleton<ParkingLiveRepository>(
      () => ParkingLiveRepositoryImpl(sl()),
    );
  }

  // Live status calculation.
  if (!sl.isRegistered<ParkingLiveStatusCalculator>()) {
    sl.registerLazySingleton(() => const ParkingLiveStatusCalculator());
  }

  // Derived live status repository.
  if (!sl.isRegistered<ParkingLiveStatusRepository>()) {
    sl.registerLazySingleton<ParkingLiveStatusRepository>(
      () => ParkingLiveStatusRepositoryImpl(sl(), sl()),
    );
  }

  // Static parking use cases.
  if (!sl.isRegistered<WatchParkingSpotsUseCase>()) {
    sl.registerLazySingleton(() => WatchParkingSpotsUseCase(sl()));
  }

  if (!sl.isRegistered<AddParkingSpotUseCase>()) {
    sl.registerLazySingleton(() => AddParkingSpotUseCase(sl()));
  }

  if (!sl.isRegistered<UpdateParkingSpotUseCase>()) {
    sl.registerLazySingleton(() => UpdateParkingSpotUseCase(sl()));
  }

  if (!sl.isRegistered<DeleteParkingSpotUseCase>()) {
    sl.registerLazySingleton(() => DeleteParkingSpotUseCase(sl()));
  }

  // Live report use case.
  if (!sl.isRegistered<CreateParkingReportUseCase>()) {
    sl.registerLazySingleton(() => CreateParkingReportUseCase(sl()));
  }

  // Derived live status use case.
  if (!sl.isRegistered<WatchParkingLiveStatusUseCase>()) {
    sl.registerLazySingleton(() => WatchParkingLiveStatusUseCase(sl()));
  }
}

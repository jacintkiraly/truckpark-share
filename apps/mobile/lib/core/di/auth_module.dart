import 'package:get_it/get_it.dart';

import '../../features/auth/services/auth_service.dart';

void registerAuthModule(GetIt sl) {
  if (!sl.isRegistered<AuthService>()) {
    sl.registerLazySingleton<AuthService>(
      () => AuthService(),
    );
  }
}
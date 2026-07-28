import 'package:get_it/get_it.dart';

import 'firebase_module.dart';
import 'parking_module.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  registerFirebaseModule(sl);
  registerParkingModule(sl);
}
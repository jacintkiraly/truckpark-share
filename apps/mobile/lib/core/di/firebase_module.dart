import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

void registerFirebaseModule(GetIt sl) {
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:truckpark_share/core/di/service_locator.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  await setupServiceLocator();

  runApp(
  const ProviderScope(
    child: TruckParkShareApp(),
  ),
);
}
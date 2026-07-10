import 'package:flutter/material.dart';

import '../features/welcome/welcome_screen.dart';

class TruckParkShareApp extends StatelessWidget {
  const TruckParkShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckPark Share',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
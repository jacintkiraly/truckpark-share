import 'package:flutter/material.dart';

class ParkingLoading extends StatelessWidget {
  const ParkingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
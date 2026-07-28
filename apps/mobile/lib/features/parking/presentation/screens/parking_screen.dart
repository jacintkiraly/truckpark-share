import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/parking_provider.dart';
import '../widgets/parking_body.dart';

class ParkingScreen extends ConsumerStatefulWidget {
  const ParkingScreen({super.key});

  @override
  ConsumerState<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends ConsumerState<ParkingScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(parkingViewModelProvider.notifier).watchParkingSpots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parkingViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
      ),
      body: ParkingBody(state: state),
    );
  }
}
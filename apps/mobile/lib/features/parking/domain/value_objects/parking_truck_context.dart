import 'package:equatable/equatable.dart';

import '../enums/parking_intensity.dart';

class ParkingTruckContext extends Equatable {
  const ParkingTruckContext({
    this.nearbyIntensity,
    this.serviceAreaIntensity,
  });

  final ParkingIntensity? nearbyIntensity;
  final ParkingIntensity? serviceAreaIntensity;

  @override
  List<Object?> get props => [
        nearbyIntensity,
        serviceAreaIntensity,
      ];
}

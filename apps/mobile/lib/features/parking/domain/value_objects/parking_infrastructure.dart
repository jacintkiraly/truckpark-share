import 'package:equatable/equatable.dart';

class ParkingInfrastructure extends Equatable {
  const ParkingInfrastructure({
    this.evFastChargingWithin1Km = false,
    this.gridSubstationWithin1Km = false,
  });

  final bool evFastChargingWithin1Km;
  final bool gridSubstationWithin1Km;

  @override
  List<Object> get props => [
        evFastChargingWithin1Km,
        gridSubstationWithin1Km,
      ];
}

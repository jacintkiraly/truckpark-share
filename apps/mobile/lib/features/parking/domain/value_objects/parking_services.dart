import 'package:equatable/equatable.dart';

class ParkingServices extends Equatable {
  const ParkingServices({
    this.toilets = false,
    this.showers = false,
    this.restaurant = false,
    this.fuel = false,
    this.security = false,
    this.wifi = false,
    this.electricity = false,
    this.water = false,
  });

  final bool toilets;
  final bool showers;
  final bool restaurant;
  final bool fuel;
  final bool security;
  final bool wifi;
  final bool electricity;
  final bool water;

  @override
List<Object> get props => [
      toilets,
      showers,
      restaurant,
      fuel,
      security,
      wifi,
      electricity,
      water,
    ];
}
import 'package:equatable/equatable.dart';

class ParkingLocation extends Equatable {
  const ParkingLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
List<Object> get props => [
      latitude,
      longitude,
    ];
}
import 'package:equatable/equatable.dart';

class ParkingMapCluster extends Equatable {
  const ParkingMapCluster({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.count,
  });

  final String id;
  final double latitude;
  final double longitude;
  final int count;

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        count,
      ];
}

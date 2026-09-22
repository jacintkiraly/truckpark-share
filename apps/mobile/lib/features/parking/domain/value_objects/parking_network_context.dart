import 'package:equatable/equatable.dart';

class ParkingNetworkContext extends Equatable {
  const ParkingNetworkContext({
    this.tenTCoreWithin2Km = false,
    this.tenTCoreDistanceKm,
    this.tenTCoreRoadName,
    this.tenTComprehensiveWithin2Km = false,
    this.tenTComprehensiveDistanceKm,
    this.tenTComprehensiveRoadName,
    this.tenTTotalDistanceKm,
  });

  final bool tenTCoreWithin2Km;
  final double? tenTCoreDistanceKm;
  final String? tenTCoreRoadName;

  final bool tenTComprehensiveWithin2Km;
  final double? tenTComprehensiveDistanceKm;
  final String? tenTComprehensiveRoadName;

  final double? tenTTotalDistanceKm;

  @override
  List<Object?> get props => [
        tenTCoreWithin2Km,
        tenTCoreDistanceKm,
        tenTCoreRoadName,
        tenTComprehensiveWithin2Km,
        tenTComprehensiveDistanceKm,
        tenTComprehensiveRoadName,
        tenTTotalDistanceKm,
      ];
}

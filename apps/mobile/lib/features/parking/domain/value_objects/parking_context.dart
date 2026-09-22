import 'package:equatable/equatable.dart';

class ParkingContext extends Equatable {
  const ParkingContext({
    this.landCover,
    this.freightHub = false,
    this.freightHubWithin1Km = false,
    this.urbanisation,
    this.urbanNodeWithin5Km = false,
    this.nearestUrbanNodeName,
  });

  final String? landCover;
  final bool freightHub;
  final bool freightHubWithin1Km;
  final String? urbanisation;
  final bool urbanNodeWithin5Km;
  final String? nearestUrbanNodeName;

  @override
  List<Object?> get props => [
        landCover,
        freightHub,
        freightHubWithin1Km,
        urbanisation,
        urbanNodeWithin5Km,
        nearestUrbanNodeName,
      ];
}

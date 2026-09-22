import 'package:equatable/equatable.dart';

import '../enums/parking_facility_type.dart';
import '../enums/parking_source_confidence.dart';
import '../value_objects/parking_context.dart';
import '../value_objects/parking_infrastructure.dart';
import '../value_objects/parking_location.dart';
import '../value_objects/parking_network_context.dart';
import '../value_objects/parking_services.dart';
import '../value_objects/parking_source.dart';
import '../value_objects/parking_truck_context.dart';
import '../value_objects/parking_verification.dart';

class ParkingSpot extends Equatable {
  const ParkingSpot({
    required this.id,
    required this.name,
    required this.location,
    required this.countryCode,
    required this.facilityType,
    this.totalAreaM2,
    this.services = const ParkingServices(),
    this.infrastructure,
    this.context,
    this.networkContext,
    this.truckContext,
    required this.source,
    required this.verification,
    this.safeAndSecureTruckParkingArea,
    this.sourceConfidence,
  });

  final String id;
  final String name;
  final ParkingLocation location;
  final String countryCode;
  final ParkingFacilityType facilityType;

  final double? totalAreaM2;

  final ParkingServices services;
  final ParkingInfrastructure? infrastructure;
  final ParkingContext? context;
  final ParkingNetworkContext? networkContext;
  final ParkingTruckContext? truckContext;

  final ParkingSource source;
  final ParkingVerification verification;

  final bool? safeAndSecureTruckParkingArea;
  final ParkingSourceConfidence? sourceConfidence;

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        countryCode,
        facilityType,
        totalAreaM2,
        services,
        infrastructure,
        context,
        networkContext,
        truckContext,
        source,
        verification,
        safeAndSecureTruckParkingArea,
        sourceConfidence,
      ];
}

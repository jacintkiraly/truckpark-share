import 'package:truckpark_share/features/parking/data/dto/parking_spot_dto.dart';
import 'package:truckpark_share/features/parking/domain/entities/parking_spot.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_facility_type.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_intensity.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_truck_confidence.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_context.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_infrastructure.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_location.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_network_context.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_services.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_source.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_truck_context.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_verification.dart';

class ParkingSpotMapper {
  const ParkingSpotMapper();

  ParkingSpot fromDto(ParkingSpotDto dto) {
    return ParkingSpot(
      id: dto.id,
      name: dto.name,
      location: ParkingLocation(
        latitude: dto.latitude,
        longitude: dto.longitude,
      ),
      countryCode: dto.countryCode,
      facilityType: _facilityTypeFromFirestore(
        dto.facilityType,
      ),
      totalAreaM2: dto.totalAreaM2,
      services: ParkingServices(
        toilets: dto.toilets,
        showers: dto.showers,
        restaurant: dto.restaurant,
        fuel: dto.fuel,
        security: dto.security,
        wifi: dto.wifi,
        electricity: dto.electricity,
        water: dto.water,
      ),
      infrastructure: ParkingInfrastructure(
        evFastChargingWithin1Km:
            dto.evFastChargingWithin1Km,
        gridSubstationWithin1Km:
            dto.gridSubstationWithin1Km,
      ),
      context: ParkingContext(
        landCover: dto.landCover,
        freightHub: dto.freightHub,
        freightHubWithin1Km:
            dto.freightHubWithin1Km,
        urbanisation: dto.urbanisation,
        urbanNodeWithin5Km:
            dto.urbanNodeWithin5Km,
        nearestUrbanNodeName:
            dto.nearestUrbanNodeName,
      ),
      networkContext: ParkingNetworkContext(
        tenTCoreWithin2Km:
            dto.tenTCoreWithin2Km,
        tenTCoreDistanceKm:
            dto.tenTCoreDistanceKm,
        tenTCoreRoadName:
            dto.tenTCoreRoadName,
        tenTComprehensiveWithin2Km:
            dto.tenTComprehensiveWithin2Km,
        tenTComprehensiveDistanceKm:
            dto.tenTComprehensiveDistanceKm,
        tenTComprehensiveRoadName:
            dto.tenTComprehensiveRoadName,
        tenTTotalDistanceKm:
            dto.tenTTotalDistanceKm,
      ),
      truckContext: ParkingTruckContext(
        nearbyIntensity:
            _intensityFromFirestore(
              dto.trucksNearbyIntensity,
            ),
        serviceAreaIntensity:
            _intensityFromFirestore(
              dto.trucksTotalIntensity,
            ),
      ),
      source: ParkingSource(
        provider: dto.sourceProvider,
        sourceId: dto.sourceId,
        dataset: dto.sourceDataset,
        datasetVersion: dto.sourceDatasetVersion,
        sourceType: dto.sourceType,
      ),
      verification: ParkingVerification(
        verified: dto.verified,
        verifiedAt: dto.verifiedAt,
        verifiedBy: dto.verifiedBy,
      ),
      safeAndSecureTruckParkingArea:
          dto.safeAndSecureTruckParkingArea,
      truckParkingConfidence:
          _truckParkingConfidenceFromFirestore(
            dto.truckParkingConfidence,
          ),
    );
  }

  ParkingSpotDto toDto(ParkingSpot parkingSpot) {
    return ParkingSpotDto(
      id: parkingSpot.id,
      name: parkingSpot.name,
      latitude: parkingSpot.location.latitude,
      longitude: parkingSpot.location.longitude,
      countryCode: parkingSpot.countryCode,
      facilityType: _facilityTypeToFirestore(
        parkingSpot.facilityType,
      ),
      totalAreaM2: parkingSpot.totalAreaM2,

      toilets: parkingSpot.services.toilets,
      showers: parkingSpot.services.showers,
      restaurant: parkingSpot.services.restaurant,
      fuel: parkingSpot.services.fuel,
      security: parkingSpot.services.security,
      wifi: parkingSpot.services.wifi,
      electricity: parkingSpot.services.electricity,
      water: parkingSpot.services.water,

      evFastChargingWithin1Km:
          parkingSpot.infrastructure
              ?.evFastChargingWithin1Km ??
          false,
      gridSubstationWithin1Km:
          parkingSpot.infrastructure
              ?.gridSubstationWithin1Km ??
          false,

      landCover:
          parkingSpot.context?.landCover,
      freightHub:
          parkingSpot.context?.freightHub ?? false,
      freightHubWithin1Km:
          parkingSpot.context?.freightHubWithin1Km ?? false,
      urbanisation:
          parkingSpot.context?.urbanisation,
      urbanNodeWithin5Km:
          parkingSpot.context?.urbanNodeWithin5Km ?? false,
      nearestUrbanNodeName:
          parkingSpot.context?.nearestUrbanNodeName,

      tenTCoreWithin2Km:
          parkingSpot.networkContext
              ?.tenTCoreWithin2Km ??
          false,
      tenTCoreDistanceKm:
          parkingSpot.networkContext
              ?.tenTCoreDistanceKm,
      tenTCoreRoadName:
          parkingSpot.networkContext
              ?.tenTCoreRoadName,

      tenTComprehensiveWithin2Km:
          parkingSpot.networkContext
              ?.tenTComprehensiveWithin2Km ??
          false,
      tenTComprehensiveDistanceKm:
          parkingSpot.networkContext
              ?.tenTComprehensiveDistanceKm,
      tenTComprehensiveRoadName:
          parkingSpot.networkContext
              ?.tenTComprehensiveRoadName,

      tenTTotalDistanceKm:
          parkingSpot.networkContext
              ?.tenTTotalDistanceKm,

      trucksNearbyIntensity:
          parkingSpot.truckContext
              ?.nearbyIntensity
              ?.name,
      trucksTotalIntensity:
          parkingSpot.truckContext
              ?.serviceAreaIntensity
              ?.name,

      safeAndSecureTruckParkingArea:
          parkingSpot.safeAndSecureTruckParkingArea,
      truckParkingConfidence:
          parkingSpot.truckParkingConfidence?.name,

      sourceProvider:
          parkingSpot.source.provider,
      sourceId:
          parkingSpot.source.sourceId,
      sourceDataset:
          parkingSpot.source.dataset,
      sourceDatasetVersion:
          parkingSpot.source.datasetVersion,
      sourceType:
          parkingSpot.source.sourceType,

      verified:
          parkingSpot.verification.verified,
      verifiedAt:
          parkingSpot.verification.verifiedAt,
      verifiedBy:
          parkingSpot.verification.verifiedBy,
    );
  }

  ParkingFacilityType _facilityTypeFromFirestore(
    String value,
  ) {
    switch (value) {
      case 'parking':
        return ParkingFacilityType.parking;
      case 'fueling':
        return ParkingFacilityType.fueling;
      case 'restArea':
        return ParkingFacilityType.restArea;
      case 'truckStopAndRestArea':
        return ParkingFacilityType.truckStopAndRestArea;
      case 'fuelingAndTruckStop':
        return ParkingFacilityType.fuelingAndTruckStop;
      case 'parkingAndRestArea':
        return ParkingFacilityType.parkingAndRestArea;
      default:
        return ParkingFacilityType.parking;
    }
  }

  String _facilityTypeToFirestore(
    ParkingFacilityType type,
  ) {
    return type.name;
  }

  ParkingIntensity? _intensityFromFirestore(
    String? value,
  ) {
    switch (value) {
      case 'low':
        return ParkingIntensity.low;
      case 'medium':
        return ParkingIntensity.medium;
      case 'high':
        return ParkingIntensity.high;
      default:
        return null;
    }
  }

  ParkingTruckConfidence? _truckParkingConfidenceFromFirestore(
    String? value,
  ) {
    switch (value) {
      case 'low':
        return ParkingTruckConfidence.low;
      case 'medium':
        return ParkingTruckConfidence.medium;
      case 'high':
        return ParkingTruckConfidence.high;
      default:
        return null;
    }
  }
}

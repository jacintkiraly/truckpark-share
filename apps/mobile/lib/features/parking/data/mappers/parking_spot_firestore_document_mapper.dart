import 'package:truckpark_share/features/parking/domain/entities/parking_spot.dart';

class ParkingSpotFirestoreDocumentMapper {
  const ParkingSpotFirestoreDocumentMapper();

  Map<String, dynamic> toDocument(
    ParkingSpot parkingSpot,
  ) {
    return {
      'name': parkingSpot.name,
      'latitude': parkingSpot.location.latitude,
      'longitude': parkingSpot.location.longitude,
      'countryCode': parkingSpot.countryCode,
      'facilityType': parkingSpot.facilityType.name,
      'totalAreaM2': parkingSpot.totalAreaM2,

      'services': {
        'toilets': parkingSpot.services.toilets,
        'showers': parkingSpot.services.showers,
        'restaurant': parkingSpot.services.restaurant,
        'fuel': parkingSpot.services.fuel,
        'security': parkingSpot.services.security,
        'wifi': parkingSpot.services.wifi,
        'electricity': parkingSpot.services.electricity,
        'water': parkingSpot.services.water,
      },

      'infrastructure': {
        'evFastChargingWithin1Km':
            parkingSpot.infrastructure
                ?.evFastChargingWithin1Km ??
            false,
        'gridSubstationWithin1Km':
            parkingSpot.infrastructure
                ?.gridSubstationWithin1Km ??
            false,
      },

      'context': {
        'landCover':
            parkingSpot.context?.landCover,
        'freightHub':
            parkingSpot.context?.freightHub ??
            false,
        'freightHubWithin1Km':
            parkingSpot.context
                    ?.freightHubWithin1Km ??
                false,
        'urbanisation':
            parkingSpot.context?.urbanisation,
        'urbanNodeWithin5Km':
            parkingSpot.context
                    ?.urbanNodeWithin5Km ??
                false,
        'nearestUrbanNodeName':
            parkingSpot.context
                ?.nearestUrbanNodeName,
      },

      'networkContext': {
        'tenTCoreWithin2Km':
            parkingSpot.networkContext
                    ?.tenTCoreWithin2Km ??
                false,
        'tenTCoreDistanceKm':
            parkingSpot.networkContext
                ?.tenTCoreDistanceKm,
        'tenTCoreRoadName':
            parkingSpot.networkContext
                ?.tenTCoreRoadName,
        'tenTComprehensiveWithin2Km':
            parkingSpot.networkContext
                    ?.tenTComprehensiveWithin2Km ??
                false,
        'tenTComprehensiveDistanceKm':
            parkingSpot.networkContext
                ?.tenTComprehensiveDistanceKm,
        'tenTComprehensiveRoadName':
            parkingSpot.networkContext
                ?.tenTComprehensiveRoadName,
        'tenTTotalDistanceKm':
            parkingSpot.networkContext
                ?.tenTTotalDistanceKm,
      },

      'truckContext': {
        'nearbyIntensity':
            parkingSpot.truckContext
                ?.nearbyIntensity
                ?.name,
        'serviceAreaIntensity':
            parkingSpot.truckContext
                ?.serviceAreaIntensity
                ?.name,
      },

      'safeAndSecureTruckParkingArea':
          parkingSpot.safeAndSecureTruckParkingArea,

      'truckParkingConfidence':
          parkingSpot.truckParkingConfidence
              ?.name,

      'source': {
        'provider':
            parkingSpot.source.provider,
        'sourceId':
            parkingSpot.source.sourceId,
        'dataset':
            parkingSpot.source.dataset,
        'datasetVersion':
            parkingSpot.source.datasetVersion,
        'sourceType':
            parkingSpot.source.sourceType,
      },

      'verification': {
        'verified':
            parkingSpot.verification.verified,
        'verifiedAt':
            parkingSpot.verification.verifiedAt,
        'verifiedBy':
            parkingSpot.verification.verifiedBy,
      },
    };
  }
}

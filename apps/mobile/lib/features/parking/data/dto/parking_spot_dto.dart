import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpotDto {
  const ParkingSpotDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
    required this.facilityType,
    this.totalAreaM2,
    required this.toilets,
    required this.showers,
    required this.restaurant,
    required this.fuel,
    required this.security,
    required this.wifi,
    required this.electricity,
    required this.water,
    this.evFastChargingWithin1Km = false,
    this.gridSubstationWithin1Km = false,
    this.landCover,
    this.freightHub = false,
    this.freightHubWithin1Km = false,
    this.urbanisation,
    this.urbanNodeWithin5Km = false,
    this.nearestUrbanNodeName,
    this.tenTCoreWithin2Km = false,
    this.tenTCoreDistanceKm,
    this.tenTCoreRoadName,
    this.tenTComprehensiveWithin2Km = false,
    this.tenTComprehensiveDistanceKm,
    this.tenTComprehensiveRoadName,
    this.tenTTotalDistanceKm,
    this.trucksNearbyIntensity,
    this.trucksTotalIntensity,
    this.safeAndSecureTruckParkingArea,
    this.sourceConfidence,
    required this.sourceProvider,
    this.sourceId,
    this.sourceDataset,
    this.sourceDatasetVersion,
    this.sourceType,
    this.verified = false,
    this.verifiedAt,
    this.verifiedBy,
  });

  final String id;
  final String name;

  final double latitude;
  final double longitude;

  final String countryCode;
  final String facilityType;

  final double? totalAreaM2;

  final bool toilets;
  final bool showers;
  final bool restaurant;
  final bool fuel;
  final bool security;
  final bool wifi;
  final bool electricity;
  final bool water;

  final bool evFastChargingWithin1Km;
  final bool gridSubstationWithin1Km;

  final String? landCover;
  final bool freightHub;
  final bool freightHubWithin1Km;
  final String? urbanisation;
  final bool urbanNodeWithin5Km;
  final String? nearestUrbanNodeName;

  final bool tenTCoreWithin2Km;
  final double? tenTCoreDistanceKm;
  final String? tenTCoreRoadName;

  final bool tenTComprehensiveWithin2Km;
  final double? tenTComprehensiveDistanceKm;
  final String? tenTComprehensiveRoadName;

  final double? tenTTotalDistanceKm;

  final String? trucksNearbyIntensity;
  final String? trucksTotalIntensity;

  final bool? safeAndSecureTruckParkingArea;
  final String? sourceConfidence;

  final String sourceProvider;
  final String? sourceId;
  final String? sourceDataset;
  final String? sourceDatasetVersion;
  final String? sourceType;

  final bool verified;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  factory ParkingSpotDto.fromFirestore(
    String id,
    Map<String, dynamic> json,
  ) {
    final services =
        (json['services'] as Map<String, dynamic>?) ?? {};

    final infrastructure =
        (json['infrastructure'] as Map<String, dynamic>?) ?? {};

    final context =
        (json['context'] as Map<String, dynamic>?) ?? {};

    final network =
        (json['networkContext'] as Map<String, dynamic>?) ?? {};

    final truckContext =
        (json['truckContext'] as Map<String, dynamic>?) ?? {};

    final source =
        (json['source'] as Map<String, dynamic>?) ?? {};

    final verification =
        (json['verification'] as Map<String, dynamic>?) ?? {};

    return ParkingSpotDto(
      id: id,
      name: json['name'] as String? ?? 'Unknown parking',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      countryCode: json['countryCode'] as String? ?? 'XX',
      facilityType: json['facilityType'] as String? ?? 'parking',
      totalAreaM2: (json['totalAreaM2'] as num?)?.toDouble(),

      toilets: services['toilets'] as bool? ?? false,
      showers: services['showers'] as bool? ?? false,
      restaurant: services['restaurant'] as bool? ?? false,
      fuel: services['fuel'] as bool? ?? false,
      security: services['security'] as bool? ?? false,
      wifi: services['wifi'] as bool? ?? false,
      electricity: services['electricity'] as bool? ?? false,
      water: services['water'] as bool? ?? false,

      evFastChargingWithin1Km:
          infrastructure['evFastChargingWithin1Km'] as bool? ?? false,
      gridSubstationWithin1Km:
          infrastructure['gridSubstationWithin1Km'] as bool? ?? false,

      landCover: context['landCover'] as String?,
      freightHub: context['freightHub'] as bool? ?? false,
      freightHubWithin1Km:
          context['freightHubWithin1Km'] as bool? ?? false,
      urbanisation: context['urbanisation'] as String?,
      urbanNodeWithin5Km:
          context['urbanNodeWithin5Km'] as bool? ?? false,
      nearestUrbanNodeName:
          context['nearestUrbanNodeName'] as String?,

      tenTCoreWithin2Km:
          network['tenTCoreWithin2Km'] as bool? ?? false,
      tenTCoreDistanceKm:
          (network['tenTCoreDistanceKm'] as num?)?.toDouble(),
      tenTCoreRoadName:
          network['tenTCoreRoadName'] as String?,

      tenTComprehensiveWithin2Km:
          network['tenTComprehensiveWithin2Km'] as bool? ?? false,
      tenTComprehensiveDistanceKm:
          (network['tenTComprehensiveDistanceKm'] as num?)?.toDouble(),
      tenTComprehensiveRoadName:
          network['tenTComprehensiveRoadName'] as String?,

      tenTTotalDistanceKm:
          (network['tenTTotalDistanceKm'] as num?)?.toDouble(),

      trucksNearbyIntensity:
          truckContext['nearbyIntensity'] as String?,
      trucksTotalIntensity:
          truckContext['serviceAreaIntensity'] as String?,

      safeAndSecureTruckParkingArea:
          json['safeAndSecureTruckParkingArea'] as bool?,
      sourceConfidence:
          json['sourceConfidence'] as String?,

      sourceProvider:
          source['provider'] as String? ?? 'unknown',
      sourceId: source['sourceId'] as String?,
      sourceDataset: source['dataset'] as String?,
      sourceDatasetVersion:
          source['datasetVersion'] as String?,
      sourceType: source['sourceType'] as String?,

      verified:
          verification['verified'] as bool? ?? false,
      verifiedAt:
          (verification['verifiedAt'] as Timestamp?)?.toDate(),
      verifiedBy:
          verification['verifiedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'countryCode': countryCode,
      'facilityType': facilityType,
      'totalAreaM2': totalAreaM2,

      'services': {
        'toilets': toilets,
        'showers': showers,
        'restaurant': restaurant,
        'fuel': fuel,
        'security': security,
        'wifi': wifi,
        'electricity': electricity,
        'water': water,
      },

      'infrastructure': {
        'evFastChargingWithin1Km':
            evFastChargingWithin1Km,
        'gridSubstationWithin1Km':
            gridSubstationWithin1Km,
      },

      'context': {
        'landCover': landCover,
        'freightHub': freightHub,
        'freightHubWithin1Km': freightHubWithin1Km,
        'urbanisation': urbanisation,
        'urbanNodeWithin5Km': urbanNodeWithin5Km,
        'nearestUrbanNodeName': nearestUrbanNodeName,
      },

      'networkContext': {
        'tenTCoreWithin2Km': tenTCoreWithin2Km,
        'tenTCoreDistanceKm': tenTCoreDistanceKm,
        'tenTCoreRoadName': tenTCoreRoadName,
        'tenTComprehensiveWithin2Km':
            tenTComprehensiveWithin2Km,
        'tenTComprehensiveDistanceKm':
            tenTComprehensiveDistanceKm,
        'tenTComprehensiveRoadName':
            tenTComprehensiveRoadName,
        'tenTTotalDistanceKm': tenTTotalDistanceKm,
      },

      'truckContext': {
        'nearbyIntensity': trucksNearbyIntensity,
        'serviceAreaIntensity': trucksTotalIntensity,
      },

      'safeAndSecureTruckParkingArea':
          safeAndSecureTruckParkingArea,
      'sourceConfidence': sourceConfidence,

      'source': {
        'provider': sourceProvider,
        'sourceId': sourceId,
        'dataset': sourceDataset,
        'datasetVersion': sourceDatasetVersion,
        'sourceType': sourceType,
      },

      'verification': {
        'verified': verified,
        'verifiedAt': verifiedAt == null
            ? null
            : Timestamp.fromDate(verifiedAt!),
        'verifiedBy': verifiedBy,
      },
    };
  }
}

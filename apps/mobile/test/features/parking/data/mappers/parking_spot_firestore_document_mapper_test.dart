import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truckpark_share/features/parking/data/dto/parking_spot_dto.dart';
import 'package:truckpark_share/features/parking/data/mappers/parking_spot_firestore_document_mapper.dart';
import 'package:truckpark_share/features/parking/data/mappers/parking_spot_mapper.dart';
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

void main() {
  const documentMapper =
      ParkingSpotFirestoreDocumentMapper();
  const parkingSpotMapper = ParkingSpotMapper();

  final verificationDate =
      DateTime.utc(2026, 9, 25, 12, 30);

  ParkingSpot createCompleteParkingSpot() {
    return ParkingSpot(
      id: 'tps_round_trip_test',
      name: '',
      location: const ParkingLocation(
        latitude: 52.2604,
        longitude: 4.687,
      ),
      countryCode: 'NL',
      facilityType:
          ParkingFacilityType.truckStopAndRestArea,
      totalAreaM2: 22982,
      services: const ParkingServices(
        toilets: true,
        showers: true,
        restaurant: true,
        fuel: false,
        security: false,
        wifi: true,
        electricity: false,
        water: true,
      ),
      infrastructure: const ParkingInfrastructure(
        evFastChargingWithin1Km: true,
        gridSubstationWithin1Km: false,
      ),
      context: const ParkingContext(
        landCover: 'Agricultural areas',
        freightHub: false,
        freightHubWithin1Km: false,
        urbanisation: 'city',
        urbanNodeWithin5Km: true,
        nearestUrbanNodeName: 'Hoofddorp',
      ),
      networkContext: const ParkingNetworkContext(
        tenTCoreWithin2Km: false,
        tenTCoreDistanceKm: 0.0179283647259635,
        tenTCoreRoadName: 'E019',
        tenTComprehensiveWithin2Km: false,
        tenTComprehensiveDistanceKm: 11.421419043939396,
        tenTComprehensiveRoadName: 'E999',
        tenTTotalDistanceKm: 0,
      ),
      truckContext: const ParkingTruckContext(
        nearbyIntensity: ParkingIntensity.high,
        serviceAreaIntensity: ParkingIntensity.medium,
      ),
      source: const ParkingSource(
        provider: 'Fraunhofer',
        sourceId: null,
        dataset: 'European Truck Parking Locations',
        datasetVersion: 'v04',
        sourceType: 'Mixed',
      ),
      verification: ParkingVerification(
        verified: false,
        verifiedAt: verificationDate,
        verifiedBy: null,
      ),
      safeAndSecureTruckParkingArea: true,
      truckParkingConfidence:
          ParkingTruckConfidence.high,
    );
  }

  test(
    'maps a complete ParkingSpot to the expected Firestore document',
    () {
      final parkingSpot = createCompleteParkingSpot();

      final document =
          documentMapper.toDocument(parkingSpot);

      expect(
        document['name'],
        parkingSpot.name,
      );
      expect(
        document['latitude'],
        parkingSpot.location.latitude,
      );
      expect(
        document['longitude'],
        parkingSpot.location.longitude,
      );
      expect(
        document['countryCode'],
        'NL',
      );
      expect(
        document['facilityType'],
        'truckStopAndRestArea',
      );
      expect(
        document['totalAreaM2'],
        22982,
      );

      expect(
        document['services'],
        {
          'toilets': true,
          'showers': true,
          'restaurant': true,
          'fuel': false,
          'security': false,
          'wifi': true,
          'electricity': false,
          'water': true,
        },
      );

      expect(
        document['infrastructure'],
        {
          'evFastChargingWithin1Km': true,
          'gridSubstationWithin1Km': false,
        },
      );

      expect(
        document['context'],
        {
          'landCover': 'Agricultural areas',
          'freightHub': false,
          'freightHubWithin1Km': false,
          'urbanisation': 'city',
          'urbanNodeWithin5Km': true,
          'nearestUrbanNodeName': 'Hoofddorp',
        },
      );

      expect(
        document['networkContext'],
        {
          'tenTCoreWithin2Km': false,
          'tenTCoreDistanceKm': 0.0179283647259635,
          'tenTCoreRoadName': 'E019',
          'tenTComprehensiveWithin2Km': false,
          'tenTComprehensiveDistanceKm':
              11.421419043939396,
          'tenTComprehensiveRoadName': 'E999',
          'tenTTotalDistanceKm': 0,
        },
      );

      expect(
        document['truckContext'],
        {
          'nearbyIntensity': 'high',
          'serviceAreaIntensity': 'medium',
        },
      );

      expect(
        document['safeAndSecureTruckParkingArea'],
        true,
      );
      expect(
        document['truckParkingConfidence'],
        'high',
      );

      expect(
        document['source'],
        {
          'provider': 'Fraunhofer',
          'sourceId': null,
          'dataset': 'European Truck Parking Locations',
          'datasetVersion': 'v04',
          'sourceType': 'Mixed',
        },
      );

      expect(
        document['verification'],
        {
          'verified': false,
          'verifiedAt': verificationDate,
          'verifiedBy': null,
        },
      );
    },
  );

  test(
    'does not write live parking status fields',
    () {
      final parkingSpot = createCompleteParkingSpot();

      final document =
          documentMapper.toDocument(parkingSpot);

      expect(document.containsKey('status'), isFalse);
      expect(
        document.containsKey('freeSpaces'),
        isFalse,
      );
      expect(
        document.containsKey('lastUpdated'),
        isFalse,
      );
      expect(
        document.containsKey('updatedBy'),
        isFalse,
      );
      expect(
        document.containsKey('confidence'),
        isFalse,
      );
    },
  );

  test(
    'Firestore document can be read back into the same ParkingSpot data',
    () {
      final original = createCompleteParkingSpot();

      final document =
          documentMapper.toDocument(original);

      final firestoreDocument =
          Map<String, dynamic>.from(document);

      final verification =
          Map<String, dynamic>.from(
        firestoreDocument['verification']
            as Map<String, dynamic>,
      );

      verification['verifiedAt'] =
          Timestamp.fromDate(
        original.verification.verifiedAt!,
      );

      firestoreDocument['verification'] =
          verification;

      final dto = ParkingSpotDto.fromFirestore(
        original.id,
        firestoreDocument,
      );

      final restored =
          parkingSpotMapper.fromDto(dto);

      expect(restored.id, original.id);
      expect(restored.name, original.name);

      expect(
        restored.location.latitude,
        original.location.latitude,
      );
      expect(
        restored.location.longitude,
        original.location.longitude,
      );

      expect(
        restored.countryCode,
        original.countryCode,
      );
      expect(
        restored.facilityType,
        original.facilityType,
      );
      expect(
        restored.totalAreaM2,
        original.totalAreaM2,
      );

      expect(
        restored.services,
        original.services,
      );
      expect(
        restored.infrastructure,
        original.infrastructure,
      );
      expect(
        restored.context,
        original.context,
      );
      expect(
        restored.networkContext,
        original.networkContext,
      );
      expect(
        restored.truckContext,
        original.truckContext,
      );

      expect(
        restored.source,
        original.source,
      );
      expect(
        restored.verification.verified,
        original.verification.verified,
      );
      expect(
        restored.verification.verifiedAt?.toUtc(),
        original.verification.verifiedAt?.toUtc(),
      );
      expect(
        restored.verification.verifiedBy,
        original.verification.verifiedBy,
      );

      expect(
        restored.safeAndSecureTruckParkingArea,
        original.safeAndSecureTruckParkingArea,
      );
      expect(
        restored.truckParkingConfidence,
        original.truckParkingConfidence,
      );
    },
  );

  test(
    'Fraunhofer v04 facility and confidence values survive round-trip',
    () {
      const originalFacility =
          ParkingFacilityType.fuelingAndTruckStop;
      const originalConfidence =
          ParkingTruckConfidence.medium;

      final original = ParkingSpot(
        id: 'tps_round_trip_enum_test',
        name: '',
        location: const ParkingLocation(
          latitude: 48.123456,
          longitude: 11.654321,
        ),
        countryCode: 'DE',
        facilityType: originalFacility,
        source: const ParkingSource(
          provider: 'Fraunhofer',
          dataset: 'European Truck Parking Locations',
          datasetVersion: 'v04',
          sourceType: 'OSM',
        ),
        verification:
            const ParkingVerification(
          verified: false,
        ),
        truckParkingConfidence:
            originalConfidence,
      );

      final document =
          documentMapper.toDocument(original);

      final dto = ParkingSpotDto.fromFirestore(
        original.id,
        document,
      );

      final restored =
          parkingSpotMapper.fromDto(dto);

      expect(
        restored.facilityType,
        originalFacility,
      );
      expect(
        restored.truckParkingConfidence,
        originalConfidence,
      );
      expect(
        restored.countryCode,
        'DE',
      );
    },
  );
}

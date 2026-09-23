import 'package:flutter_test/flutter_test.dart';
import 'package:truckpark_share/features/parking/data/import/fraunhofer_parking_mapper.dart';
import 'package:truckpark_share/features/parking/data/mappers/parking_spot_firestore_document_mapper.dart';

void main() {
  const fraunhoferMapper = FraunhoferParkingMapper();
  const documentMapper =
      ParkingSpotFirestoreDocumentMapper();

  test(
    'converts a Fraunhofer ParkingSpot to the expected Firestore document structure',
    () {
      final parkingSpot = fraunhoferMapper.map({
        'name': 'Parking',
        'lat': '52.2604',
        'lon': '4.687',
        'totalArea_m2': '22982',
        'country': 'NL',
        'source': 'Mixed',
        'infra_EVFC_bool': 'True',
        'infra_Grid_bool': 'False',
        'lc_LandCoverInfo': 'Agricultural areas',
        'lc_FreightHub_bool': 'False',
        'lc_FreightHub_w1km_bool': 'False',
        'lc_Urbanisation': 'city',
        'label_TPC': 'High',
        'label_SSTPA': 'True',
        'tenT_CoreN_w2km_bool': 'True',
        'tenT_CoreN_minDist_km':
            '0.0179283647259635',
        'tenT_CoreN_roadName': 'E019',
        'tenT_CompN_w2km_bool': 'False',
        'tenT_CompN_minDist_km':
            '11.421419043939396',
        'tenT_CompN_roadName': 'E999',
        'tenT_TotalN_minDist_km': '0.0',
        'tenT_UrbanNode_w5km_bool': 'True',
        'tenT_UrbanNode_w5km_name': 'Hoofddorp',
        'score_TrucksNearby': 'High',
        'score_TrucksTotal': 'High',
      });

      final document =
          documentMapper.toDocument(parkingSpot);

      expect(document['name'], isEmpty);
      expect(document['latitude'], 52.2604);
      expect(document['longitude'], 4.687);
      expect(document['countryCode'], 'NL');
      expect(document['facilityType'], 'parking');
      expect(document['totalAreaM2'], 22982.0);

      final services =
          document['services'] as Map<String, dynamic>;

      expect(services['toilets'], false);
      expect(services['showers'], false);
      expect(services['restaurant'], false);
      expect(services['fuel'], false);
      expect(services['security'], false);
      expect(services['wifi'], false);
      expect(services['electricity'], false);
      expect(services['water'], false);

      final infrastructure =
          document['infrastructure']
              as Map<String, dynamic>;

      expect(
        infrastructure['evFastChargingWithin1Km'],
        true,
      );

      expect(
        infrastructure['gridSubstationWithin1Km'],
        false,
      );

      final context =
          document['context'] as Map<String, dynamic>;

      expect(
        context['landCover'],
        'Agricultural areas',
      );
      expect(context['freightHub'], false);
      expect(context['freightHubWithin1Km'], false);
      expect(context['urbanisation'], 'city');
      expect(context['urbanNodeWithin5Km'], true);
      expect(
        context['nearestUrbanNodeName'],
        'Hoofddorp',
      );

      final network =
          document['networkContext']
              as Map<String, dynamic>;

      expect(
        network['tenTCoreWithin2Km'],
        true,
      );
      expect(
        network['tenTCoreDistanceKm'],
        closeTo(
          0.0179283647259635,
          0.000000001,
        ),
      );
      expect(
        network['tenTCoreRoadName'],
        'E019',
      );
      expect(
        network['tenTComprehensiveWithin2Km'],
        false,
      );
      expect(
        network['tenTComprehensiveDistanceKm'],
        closeTo(
          11.421419043939396,
          0.000000001,
        ),
      );
      expect(
        network['tenTComprehensiveRoadName'],
        'E999',
      );
      expect(
        network['tenTTotalDistanceKm'],
        0.0,
      );

      final truckContext =
          document['truckContext']
              as Map<String, dynamic>;

      expect(
        truckContext['nearbyIntensity'],
        'high',
      );
      expect(
        truckContext['serviceAreaIntensity'],
        'high',
      );

      expect(
        document['safeAndSecureTruckParkingArea'],
        true,
      );

      expect(
        document['truckParkingConfidence'],
        'high',
      );

      final source =
          document['source'] as Map<String, dynamic>;

      expect(source['provider'], 'Fraunhofer');
      expect(
        source['dataset'],
        'European Truck Parking Locations',
      );
      expect(source['datasetVersion'], 'v04');
      expect(source['sourceType'], 'Mixed');
      expect(source['sourceId'], isNull);

      final verification =
          document['verification']
              as Map<String, dynamic>;

      expect(verification['verified'], false);
      expect(verification['verifiedAt'], isNull);
      expect(verification['verifiedBy'], isNull);
    },
  );

  test(
    'does not contain live parking status fields',
    () {
      final parkingSpot = fraunhoferMapper.map({
        'name': 'Parking',
        'lat': '52.2604',
        'lon': '4.687',
        'country': 'NL',
      });

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
}


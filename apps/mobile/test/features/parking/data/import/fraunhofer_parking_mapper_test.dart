import 'package:flutter_test/flutter_test.dart';
import 'package:truckpark_share/features/parking/data/import/fraunhofer_parking_mapper.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_facility_type.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_intensity.dart';
import 'package:truckpark_share/features/parking/domain/enums/parking_truck_confidence.dart';

void main() {
  const mapper = FraunhoferParkingMapper();

  group('FraunhoferParkingMapper', () {
    test('maps a complete Fraunhofer parking record', () {
      final spot = mapper.map({
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
        'tenT_CoreN_minDist_km': '0.0179283647259635',
        'tenT_CoreN_roadName': 'E019',
        'tenT_CompN_w2km_bool': 'False',
        'tenT_CompN_minDist_km': '11.421419043939396',
        'tenT_CompN_roadName': 'E999',
        'tenT_TotalN_minDist_km': '0.0',
        'tenT_UrbanNode_w5km_bool': 'True',
        'tenT_UrbanNode_w5km_name': 'Hoofddorp',
        'score_TrucksNearby': 'High',
        'score_TrucksTotal': 'High',
      });

      expect(spot.id, startsWith('tps_'));
      expect(spot.id.length, 68);

      expect(spot.name, isEmpty);

      expect(
        spot.facilityType,
        ParkingFacilityType.parking,
      );

      expect(spot.countryCode, 'NL');

      expect(spot.location.latitude, 52.2604);
      expect(spot.location.longitude, 4.687);

      expect(spot.totalAreaM2, 22982);

      expect(
        spot.infrastructure?.evFastChargingWithin1Km,
        isTrue,
      );
      expect(
        spot.infrastructure?.gridSubstationWithin1Km,
        isFalse,
      );

      expect(
        spot.context?.landCover,
        'Agricultural areas',
      );
      expect(spot.context?.freightHub, isFalse);
      expect(spot.context?.freightHubWithin1Km, isFalse);
      expect(spot.context?.urbanisation, 'city');
      expect(spot.context?.urbanNodeWithin5Km, isTrue);
      expect(
        spot.context?.nearestUrbanNodeName,
        'Hoofddorp',
      );

      expect(
        spot.networkContext?.tenTCoreWithin2Km,
        isTrue,
      );
      expect(
        spot.networkContext?.tenTCoreDistanceKm,
        closeTo(0.0179283647259635, 0.000000001),
      );
      expect(
        spot.networkContext?.tenTCoreRoadName,
        'E019',
      );

      expect(
        spot.networkContext?.tenTComprehensiveWithin2Km,
        isFalse,
      );
      expect(
        spot.networkContext?.tenTComprehensiveDistanceKm,
        closeTo(11.421419043939396, 0.000000001),
      );
      expect(
        spot.networkContext?.tenTComprehensiveRoadName,
        'E999',
      );

      expect(
        spot.networkContext?.tenTTotalDistanceKm,
        0.0,
      );

      expect(
        spot.truckContext?.nearbyIntensity,
        ParkingIntensity.high,
      );
      expect(
        spot.truckContext?.serviceAreaIntensity,
        ParkingIntensity.high,
      );

      expect(
        spot.source.provider,
        'Fraunhofer',
      );
      expect(
        spot.source.dataset,
        'European Truck Parking Locations',
      );
      expect(
        spot.source.datasetVersion,
        'v04',
      );
      expect(
        spot.source.sourceType,
        'Mixed',
      );
      expect(spot.source.sourceId, isNull);

      expect(
        spot.verification.verified,
        isFalse,
      );

      expect(
        spot.safeAndSecureTruckParkingArea,
        isTrue,
      );

      expect(
        spot.truckParkingConfidence,
        ParkingTruckConfidence.high,
      );
    });

    test('maps all Fraunhofer facility types', () {
      final expectedTypes = {
        'Parking': ParkingFacilityType.parking,
        'Fueling': ParkingFacilityType.fueling,
        'Rest Area': ParkingFacilityType.restArea,
        'Truck Stop / Rest Area':
            ParkingFacilityType.truckStopAndRestArea,
        'Fueling / Truck Stop':
            ParkingFacilityType.fuelingAndTruckStop,
        'Parking / Rest Area':
            ParkingFacilityType.parkingAndRestArea,
      };

      for (final entry in expectedTypes.entries) {
        final spot = mapper.map({
          'name': entry.key,
          'lat': '52.2604',
          'lon': '4.687',
          'country': 'NL',
        });

        expect(
          spot.facilityType,
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('uses a deterministic id for the same source record', () {
      final row = {
        'name': 'Parking',
        'lat': '52.2604',
        'lon': '4.687',
        'country': 'NL',
      };

      final first = mapper.map(row);
      final second = mapper.map(row);

      expect(first.id, second.id);
    });

    test('does not use the anonymous CSV index as sourceId', () {
      final spot = mapper.map({
        '': '12345',
        'name': 'Parking',
        'lat': '52.2604',
        'lon': '4.687',
        'country': 'NL',
      });

      expect(spot.source.sourceId, isNull);
    });

    test('does not infer TruckPark Share verification from Fraunhofer data', () {
      final spot = mapper.map({
        'name': 'Parking',
        'lat': '52.2604',
        'lon': '4.687',
        'country': 'NL',
        'label_SSTPA': 'True',
        'label_TPC': 'High',
      });

      expect(spot.verification.verified, isFalse);
    });

    test('rejects an unknown facility type', () {
      expect(
        () => mapper.map({
          'name': 'Unknown Facility',
          'lat': '52.2604',
          'lon': '4.687',
          'country': 'NL',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a missing required country', () {
      expect(
        () => mapper.map({
          'name': 'Parking',
          'lat': '52.2604',
          'lon': '4.687',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an invalid required latitude', () {
      expect(
        () => mapper.map({
          'name': 'Parking',
          'lat': 'not-a-number',
          'lon': '4.687',
          'country': 'NL',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

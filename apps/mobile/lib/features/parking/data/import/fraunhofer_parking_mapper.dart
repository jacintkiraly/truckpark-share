import '../../domain/entities/parking_spot.dart';
import '../../domain/enums/parking_facility_type.dart';
import '../../domain/enums/parking_intensity.dart';
import '../../domain/enums/parking_truck_confidence.dart';
import '../../domain/value_objects/parking_context.dart';
import '../../domain/value_objects/parking_infrastructure.dart';
import '../../domain/value_objects/parking_location.dart';
import '../../domain/value_objects/parking_network_context.dart';
import '../../domain/value_objects/parking_source.dart';
import '../../domain/value_objects/parking_truck_context.dart';
import '../../domain/value_objects/parking_verification.dart';
import 'fraunhofer_parking_id_generator.dart';

class FraunhoferParkingMapper {
  const FraunhoferParkingMapper({
    this.idGenerator = const FraunhoferParkingIdGenerator(),
  });

  final FraunhoferParkingIdGenerator idGenerator;

  ParkingSpot map(Map<String, dynamic> row) {
    final countryCode = _requiredString(row, 'country');
    final latitude = _requiredDouble(row, 'lat');
    final longitude = _requiredDouble(row, 'lon');
    final sourceName = _requiredString(row, 'name');

    final facilityType = _mapFacilityType(sourceName);

    final id = idGenerator.generate(
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
      facilityType: _facilityTypeCanonicalValue(facilityType),
    );

    return ParkingSpot(
      id: id,
      name: '',
      location: ParkingLocation(
        latitude: latitude,
        longitude: longitude,
      ),
      countryCode: countryCode,
      facilityType: facilityType,
      totalAreaM2: _optionalDouble(row, 'totalArea_m2'),
      infrastructure: ParkingInfrastructure(
        evFastChargingWithin1Km:
            _boolean(row, 'infra_EVFC_bool'),
        gridSubstationWithin1Km:
            _boolean(row, 'infra_Grid_bool'),
      ),
      context: ParkingContext(
        landCover: _optionalString(row, 'lc_LandCoverInfo'),
        freightHub: _boolean(row, 'lc_FreightHub_bool'),
        freightHubWithin1Km:
            _boolean(row, 'lc_FreightHub_w1km_bool'),
        urbanisation: _optionalString(row, 'lc_Urbanisation'),
        urbanNodeWithin5Km:
            _boolean(row, 'tenT_UrbanNode_w5km_bool'),
        nearestUrbanNodeName:
            _optionalString(row, 'tenT_UrbanNode_w5km_name'),
      ),
      networkContext: ParkingNetworkContext(
        tenTCoreWithin2Km:
            _boolean(row, 'tenT_CoreN_w2km_bool'),
        tenTCoreDistanceKm:
            _optionalDouble(row, 'tenT_CoreN_minDist_km'),
        tenTCoreRoadName:
            _optionalString(row, 'tenT_CoreN_roadName'),
        tenTComprehensiveWithin2Km:
            _boolean(row, 'tenT_CompN_w2km_bool'),
        tenTComprehensiveDistanceKm:
            _optionalDouble(row, 'tenT_CompN_minDist_km'),
        tenTComprehensiveRoadName:
            _optionalString(row, 'tenT_CompN_roadName'),
        tenTTotalDistanceKm:
            _optionalDouble(row, 'tenT_TotalN_minDist_km'),
      ),
      truckContext: ParkingTruckContext(
        nearbyIntensity:
            _optionalIntensity(row, 'score_TrucksNearby'),
        serviceAreaIntensity:
            _optionalIntensity(row, 'score_TrucksTotal'),
      ),
      source: ParkingSource(
        provider: 'Fraunhofer',
        dataset: 'European Truck Parking Locations',
        datasetVersion: 'v04',
        sourceType: _optionalString(row, 'source'),
      ),
      verification: const ParkingVerification(
        verified: false,
      ),
      safeAndSecureTruckParkingArea:
          _optionalBool(row, 'label_SSTPA'),
      truckParkingConfidence:
          _optionalTruckConfidence(row, 'label_TPC'),
    );
  }

  ParkingFacilityType _mapFacilityType(String value) {
    switch (value.trim()) {
      case 'Parking':
        return ParkingFacilityType.parking;
      case 'Fueling':
        return ParkingFacilityType.fueling;
      case 'Rest Area':
        return ParkingFacilityType.restArea;
      case 'Truck Stop / Rest Area':
        return ParkingFacilityType.truckStopAndRestArea;
      case 'Fueling / Truck Stop':
        return ParkingFacilityType.fuelingAndTruckStop;
      case 'Parking / Rest Area':
        return ParkingFacilityType.parkingAndRestArea;
      default:
        throw FormatException(
          'Unknown Fraunhofer facility type: "$value".',
        );
    }
  }

  String _facilityTypeCanonicalValue(
    ParkingFacilityType type,
  ) {
    switch (type) {
      case ParkingFacilityType.parking:
        return 'parking';
      case ParkingFacilityType.fueling:
        return 'fueling';
      case ParkingFacilityType.restArea:
        return 'restarea';
      case ParkingFacilityType.truckStopAndRestArea:
        return 'truckstopandrestarea';
      case ParkingFacilityType.fuelingAndTruckStop:
        return 'fuelingandtruckstop';
      case ParkingFacilityType.parkingAndRestArea:
        return 'parkingandrestarea';
    }
  }

  String _requiredString(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = row[field];

    if (value == null || value.toString().trim().isEmpty) {
      throw FormatException(
        'Fraunhofer field "$field" is required.',
      );
    }

    return value.toString().trim();
  }

  String? _optionalString(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = row[field];

    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }

    return value.toString().trim();
  }

  double _requiredDouble(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = row[field];

    if (value is num) {
      return value.toDouble();
    }

    if (value is String && value.trim().isNotEmpty) {
      final parsed = double.tryParse(value.trim());

      if (parsed != null) {
        return parsed;
      }
    }

    throw FormatException(
      'Fraunhofer field "$field" must contain a valid number.',
    );
  }

  double? _optionalDouble(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = row[field];

    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value.trim());
    }

    return null;
  }

  bool _boolean(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = row[field];

    if (value is bool) {
      return value;
    }

    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
          return true;
        case 'false':
          return false;
      }
    }

    return false;
  }

  bool? _optionalBool(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = row[field];

    if (value is bool) {
      return value;
    }

    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
          return true;
        case 'false':
          return false;
      }
    }

    return null;
  }

  ParkingIntensity? _optionalIntensity(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = _optionalString(row, field);

    if (value == null) {
      return null;
    }

    switch (value.toLowerCase()) {
      case 'low':
        return ParkingIntensity.low;
      case 'medium':
        return ParkingIntensity.medium;
      case 'high':
        return ParkingIntensity.high;
      default:
        throw FormatException(
          'Unknown Fraunhofer intensity "$value" in "$field".',
        );
    }
  }

  ParkingTruckConfidence? _optionalTruckConfidence(
    Map<String, dynamic> row,
    String field,
  ) {
    final value = _optionalString(row, field);

    if (value == null) {
      return null;
    }

    switch (value.toLowerCase()) {
      case 'low':
        return ParkingTruckConfidence.low;
      case 'medium':
        return ParkingTruckConfidence.medium;
      case 'high':
        return ParkingTruckConfidence.high;
      default:
        throw FormatException(
          'Unknown Fraunhofer truck parking confidence "$value".',
        );
    }
  }
}

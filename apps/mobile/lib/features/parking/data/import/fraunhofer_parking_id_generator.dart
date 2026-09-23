import 'dart:convert';

import 'package:crypto/crypto.dart';

class FraunhoferParkingIdGenerator {
  const FraunhoferParkingIdGenerator();

  String generate({
    required String countryCode,
    required double latitude,
    required double longitude,
    required String facilityType,
  }) {
    final canonicalKey = _canonicalKey(
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
      facilityType: facilityType,
    );

    final digest = sha256.convert(
      utf8.encode(canonicalKey),
    );

    return 'tps_${digest.toString()}';
  }

  String canonicalKey({
    required String countryCode,
    required double latitude,
    required double longitude,
    required String facilityType,
  }) {
    return _canonicalKey(
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
      facilityType: facilityType,
    );
  }

  String _canonicalKey({
    required String countryCode,
    required double latitude,
    required double longitude,
    required String facilityType,
  }) {
    return [
      'fraunhofer',
      countryCode.trim().toLowerCase(),
      latitude.toStringAsFixed(6),
      longitude.toStringAsFixed(6),
      facilityType.trim().toLowerCase(),
    ].join('|');
  }
}

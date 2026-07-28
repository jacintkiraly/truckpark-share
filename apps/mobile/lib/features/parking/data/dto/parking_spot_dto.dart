import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpotDto {
  const ParkingSpotDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.status,
    required this.totalSpaces,
    required this.freeSpaces,
    required this.toilets,
    required this.showers,
    required this.restaurant,
    required this.fuel,
    required this.security,
    required this.wifi,
    required this.electricity,
    required this.water,
    required this.lastUpdated,
    required this.updatedBy,
    required this.verified,
  });

  final String id;
  final String name;

  final double latitude;
  final double longitude;

  final String type;
  final String status;

  final int totalSpaces;
  final int freeSpaces;

  final bool toilets;
  final bool showers;
  final bool restaurant;
  final bool fuel;
  final bool security;
  final bool wifi;
  final bool electricity;
  final bool water;

  final DateTime lastUpdated;
  final String updatedBy;
  final bool verified;

    factory ParkingSpotDto.fromFirestore(
    String id,
    Map<String, dynamic> json,
  ) {
    final services =
        (json['services'] as Map<String, dynamic>?) ?? {};

    return ParkingSpotDto(
      id: id,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),

      type: json['type'] as String,
      status: json['status'] as String,

      totalSpaces: json['totalSpaces'] as int,
      freeSpaces: json['freeSpaces'] as int,

      toilets: services['toilets'] as bool? ?? false,
      showers: services['showers'] as bool? ?? false,
      restaurant: services['restaurant'] as bool? ?? false,
      fuel: services['fuel'] as bool? ?? false,
      security: services['security'] as bool? ?? false,
      wifi: services['wifi'] as bool? ?? false,
      electricity: services['electricity'] as bool? ?? false,
      water: services['water'] as bool? ?? false,

      lastUpdated:
          (json['lastUpdated'] as Timestamp).toDate(),

      updatedBy: json['updatedBy'] as String,
      verified: json['verified'] as bool,
    );
  }

    Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,

      'type': type,
      'status': status,

      'totalSpaces': totalSpaces,
      'freeSpaces': freeSpaces,

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

      'lastUpdated': Timestamp.fromDate(lastUpdated),

      'updatedBy': updatedBy,
      'verified': verified,
    };
  }
}
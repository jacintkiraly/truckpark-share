import '../enums/parking_status.dart';
import '../enums/parking_type.dart';
import '../value_objects/parking_location.dart';
import '../value_objects/parking_services.dart';
import 'package:equatable/equatable.dart';

class ParkingSpot extends Equatable {
  const ParkingSpot({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
    required this.totalSpaces,
    required this.freeSpaces,
    required this.services,
    required this.lastUpdated,
    required this.updatedBy,
    required this.verified,
  });

  final String id;
  final String name;

  final ParkingLocation location;

  final ParkingType type;
  final ParkingStatus status;

  final int totalSpaces;
  final int freeSpaces;

  final ParkingServices services;

  final DateTime lastUpdated;
  final String updatedBy;

  final bool verified;

  @override
List<Object?> get props => [
  id,
  name,
  location,
  type,
  status,
  totalSpaces,
  freeSpaces,
  services,
  lastUpdated,
  updatedBy,
  verified,
];
}
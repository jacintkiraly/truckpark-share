import 'package:truckpark_share/features/parking/data/dto/parking_spot_dto.dart';

import 'package:truckpark_share/features/parking/domain/entities/parking_spot.dart';
import 'package:truckpark_share/features/parking/domain/extensions/parking_status_extension.dart';
import 'package:truckpark_share/features/parking/domain/extensions/parking_type_extension.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_location.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_services.dart';

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
      type: ParkingTypeFirestore.fromFirestore(dto.type),
      status: ParkingStatusFirestore.fromFirestore(dto.status),
      totalSpaces: dto.totalSpaces,
      freeSpaces: dto.freeSpaces,
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
      lastUpdated: dto.lastUpdated,
      updatedBy: dto.updatedBy,
      verified: dto.verified,
    );
  }

  ParkingSpotDto toDto(ParkingSpot parkingSpot) {
    return ParkingSpotDto(
      id: parkingSpot.id,
      name: parkingSpot.name,
      latitude: parkingSpot.location.latitude,
      longitude: parkingSpot.location.longitude,
      type: parkingSpot.type.firestoreValue,
      status: parkingSpot.status.firestoreValue,
      totalSpaces: parkingSpot.totalSpaces,
      freeSpaces: parkingSpot.freeSpaces,
      toilets: parkingSpot.services.toilets,
      showers: parkingSpot.services.showers,
      restaurant: parkingSpot.services.restaurant,
      fuel: parkingSpot.services.fuel,
      security: parkingSpot.services.security,
      wifi: parkingSpot.services.wifi,
      electricity: parkingSpot.services.electricity,
      water: parkingSpot.services.water,
      lastUpdated: parkingSpot.lastUpdated,
      updatedBy: parkingSpot.updatedBy,
      verified: parkingSpot.verified,
    );
  }
}
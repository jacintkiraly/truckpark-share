import 'package:truckpark_share/features/parking/domain/enums/parking_type.dart';

extension ParkingTypeFirestore on ParkingType {
  static ParkingType fromFirestore(String value) {
    return ParkingType.values.firstWhere(
      (type) => type.firestoreValue == value,
      orElse: () => ParkingType.publicParking,
    );
  }
}
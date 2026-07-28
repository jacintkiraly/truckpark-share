import 'package:truckpark_share/features/parking/domain/enums/parking_status.dart';

extension ParkingStatusFirestore on ParkingStatus {
  static ParkingStatus fromFirestore(String value) {
    return ParkingStatus.values.firstWhere(
      (status) => status.firestoreValue == value,
      orElse: () => ParkingStatus.available,
    );
  }
}
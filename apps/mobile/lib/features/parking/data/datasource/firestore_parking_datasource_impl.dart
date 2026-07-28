import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:truckpark_share/features/parking/data/datasource/firestore_parking_datasource.dart';
import 'package:truckpark_share/features/parking/data/dto/parking_spot_dto.dart';

class FirestoreParkingDataSourceImpl
    implements FirestoreParkingDataSource {
  FirestoreParkingDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _parkingSpots =>
      _firestore.collection('parking_spots');

  @override
Stream<List<ParkingSpotDto>> watchParkingSpots() {
  return _parkingSpots.snapshots().map(
    (snapshot) => snapshot.docs
        .map(
          (doc) => ParkingSpotDto.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList(),
  );
}

  @override
Future<void> addParkingSpot(
  ParkingSpotDto parkingSpot,
) async {
  await _parkingSpots
      .doc(parkingSpot.id)
      .set(parkingSpot.toFirestore());
}

  @override
Future<void> updateParkingSpot(
  ParkingSpotDto parkingSpot,
) async {
  await _parkingSpots
      .doc(parkingSpot.id)
      .update(parkingSpot.toFirestore());
}

  @override
Future<void> deleteParkingSpot(
  String parkingSpotId,
) async {
  await _parkingSpots
      .doc(parkingSpotId)
      .delete();
}
}
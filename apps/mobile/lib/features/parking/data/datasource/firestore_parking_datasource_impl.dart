import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geohash_bounds/geohash_bounds.dart';

import 'package:truckpark_share/features/parking/data/datasource/firestore_parking_datasource.dart';
import 'package:truckpark_share/features/parking/data/dto/parking_spot_dto.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_map_cluster.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_viewport.dart';

class FirestoreParkingDataSourceImpl
    implements FirestoreParkingDataSource {
  FirestoreParkingDataSourceImpl({
    required this._firestore,
  });

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
  Future<List<ParkingSpotDto>> queryParkingSpotsInViewport(
    ParkingViewport viewport,
  ) async {
    final circle = GeohashUtil.viewportToCircle(
      neLat: viewport.northEastLatitude,
      neLng: viewport.northEastLongitude,
      swLat: viewport.southWestLatitude,
      swLng: viewport.southWestLongitude,
    );

    final queryBounds = GeohashUtil.queryBounds(
      centerLat: circle.centerLat,
      centerLng: circle.centerLng,
      radiusInMeters: circle.radiusMeters,
    );

    final snapshots = await Future.wait(
      queryBounds.map(
        (bound) => _parkingSpots
            .orderBy('geohash')
            .startAt([bound[0]])
            .endAt([bound[1]])
            .get(),
      ),
    );

    final uniqueDocuments =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final snapshot in snapshots) {
      for (final document in snapshot.docs) {
        uniqueDocuments[document.id] = document;
      }
    }

    final parkingSpots = <ParkingSpotDto>[];

    for (final document in uniqueDocuments.values) {
      final dto = ParkingSpotDto.fromFirestore(
        document.id,
        document.data(),
      );

      if (!viewport.contains(
        latitude: dto.latitude,
        longitude: dto.longitude,
      )) {
        continue;
      }

      parkingSpots.add(dto);
    }

    return parkingSpots;
  }

  @override
  Future<List<ParkingMapCluster>> countParkingSpotsInViewport(
    ParkingViewport viewport, {
    required int maxCells,
  }) async {
    final cells = GeohashUtil.cellsForViewport(
      neLat: viewport.northEastLatitude,
      neLng: viewport.northEastLongitude,
      swLat: viewport.southWestLatitude,
      swLng: viewport.southWestLongitude,
      maxCells: maxCells,
    );

    final clusters = await Future.wait(
      cells.map(
        (cell) async {
          final snapshot = await _parkingSpots
              .where(
                'geohash',
                isGreaterThanOrEqualTo: cell.prefix,
              )
              .where(
                'geohash',
                isLessThanOrEqualTo: '${cell.prefix}~',
              )
              .count()
              .get();

          return ParkingMapCluster(
            id: cell.prefix,
            latitude: cell.centerLat,
            longitude: cell.centerLng,
            count: snapshot.count ?? 0,
          );
        },
      ),
    );

    return clusters
        .where((cluster) => cluster.count > 0)
        .toList();
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

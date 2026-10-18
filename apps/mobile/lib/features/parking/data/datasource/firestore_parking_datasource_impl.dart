import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geohash_bounds/geohash_bounds.dart';

import 'package:truckpark_share/features/parking/data/datasource/firestore_parking_datasource.dart';
import 'package:truckpark_share/features/parking/data/dto/parking_spot_dto.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_map_cluster.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_viewport.dart';

class FirestoreParkingDataSourceImpl implements FirestoreParkingDataSource {
  FirestoreParkingDataSourceImpl({required this._firestore});

  final FirebaseFirestore _firestore;

  static const Duration _geohashRangeCacheTtl = Duration(seconds: 20);
  static const int _maxCachedGeohashRanges = 128;

  final Map<String, _CachedGeohashRange> _geohashRangeCache = {};

  final Map<String, Future<QuerySnapshot<Map<String, dynamic>>>>
  _inFlightGeohashQueries = {};

  int _geohashCacheGeneration = 0;

  void _invalidateGeohashRangeCache() {
    _geohashCacheGeneration++;
    _geohashRangeCache.clear();
  }

  CollectionReference<Map<String, dynamic>> get _parkingSpots =>
      _firestore.collection('parking_spots');

  Future<QuerySnapshot<Map<String, dynamic>>> _queryGeohashRange(
    String start,
    String end,
  ) async {
    final key = '$start|$end';
    final generationAtStart = _geohashCacheGeneration;
    final requestKey = '$generationAtStart|$key';
    final now = DateTime.now();
    final cached = _geohashRangeCache[key];

    if (cached != null &&
        now.difference(cached.fetchedAt) < _geohashRangeCacheTtl) {
      debugPrint(
        'PARKING PERF: geohash cache HIT '
        '$start..$end; documents=${cached.snapshot.docs.length}',
      );
      return cached.snapshot;
    }

    final inFlight = _inFlightGeohashQueries[requestKey];

    if (inFlight != null) {
      debugPrint('PARKING PERF: geohash request JOIN $start..$end');
      return inFlight;
    }

    final stopwatch = Stopwatch()..start();

    final request = _parkingSpots.orderBy('geohash').startAt([start]).endAt([
      end,
    ]).get();

    _inFlightGeohashQueries[requestKey] = request;

    try {
      final snapshot = await request;
      stopwatch.stop();

      debugPrint(
        'PARKING PERF: geohash range '
        '$start..$end ${stopwatch.elapsedMilliseconds} ms; '
        'documents=${snapshot.docs.length}; '
        'fromCache=${snapshot.metadata.isFromCache}',
      );

      // Ne tároljuk el egy időközben érvénytelenített kérés eredményét.
      if (_geohashCacheGeneration == generationAtStart) {
        if (_geohashRangeCache.length >= _maxCachedGeohashRanges &&
            !_geohashRangeCache.containsKey(key)) {
          _geohashRangeCache.remove(_geohashRangeCache.keys.first);
        }

        _geohashRangeCache[key] = _CachedGeohashRange(
          snapshot: snapshot,
          fetchedAt: DateTime.now(),
        );
      }

      return snapshot;
    } catch (error) {
      stopwatch.stop();

      debugPrint(
        'PARKING PERF: geohash range '
        '$start..$end failed after '
        '${stopwatch.elapsedMilliseconds} ms: $error',
      );

      rethrow;
    } finally {
      // Egy régi kérés ne törölhesse az azonos kulcshoz tartozó
      // későbbi kérés bejegyzését.
      if (identical(_inFlightGeohashQueries[requestKey], request)) {
        _inFlightGeohashQueries.remove(requestKey);
      }
    }
  }

  @override
  Stream<List<ParkingSpotDto>> watchParkingSpots() {
    return _parkingSpots.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ParkingSpotDto.fromFirestore(doc.id, doc.data()))
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

    debugPrint('PARKING PERF: viewport geohash ranges=${queryBounds.length}');

    final snapshots = await Future.wait(
      queryBounds.map((bound) => _queryGeohashRange(bound[0], bound[1])),
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
      final dto = ParkingSpotDto.fromFirestore(document.id, document.data());

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
      cells.map((cell) async {
        final snapshot = await _parkingSpots
            .where('geohash', isGreaterThanOrEqualTo: cell.prefix)
            .where('geohash', isLessThanOrEqualTo: '${cell.prefix}~')
            .count()
            .get();

        return ParkingMapCluster(
          id: cell.prefix,
          latitude: cell.centerLat,
          longitude: cell.centerLng,
          count: snapshot.count ?? 0,
        );
      }),
    );

    return clusters.where((cluster) => cluster.count > 0).toList();
  }

  @override
  Future<void> addParkingSpot(ParkingSpotDto parkingSpot) async {
    await _parkingSpots.doc(parkingSpot.id).set(parkingSpot.toFirestore());
    _invalidateGeohashRangeCache();
  }

  @override
  Future<void> updateParkingSpot(ParkingSpotDto parkingSpot) async {
    await _parkingSpots.doc(parkingSpot.id).update(parkingSpot.toFirestore());
    _invalidateGeohashRangeCache();
  }

  @override
  Future<void> deleteParkingSpot(String parkingSpotId) async {
    await _parkingSpots.doc(parkingSpotId).delete();
    _invalidateGeohashRangeCache();
  }
}

class _CachedGeohashRange {
  const _CachedGeohashRange({required this.snapshot, required this.fetchedAt});

  final QuerySnapshot<Map<String, dynamic>> snapshot;
  final DateTime fetchedAt;
}

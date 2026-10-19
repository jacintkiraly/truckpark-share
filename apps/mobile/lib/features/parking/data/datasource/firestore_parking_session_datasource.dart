import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../dto/parking_session_dto.dart';
import 'parking_session_datasource.dart';

class FirestoreParkingSessionDataSource implements ParkingSessionDataSource {
  FirestoreParkingSessionDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const int _parkingIdsPerQuery = 30;

  CollectionReference<Map<String, dynamic>> get _sessionsCollection {
    return _firestore.collection('parking_sessions');
  }

  List<String> get _openStatuses {
    return const ['created', 'active', 'updated', 'leavingSoon'];
  }

  @override
  Future<void> createSession(ParkingSessionDto session) async {
    await _sessionsCollection.doc(session.id).set(session.toFirestore());
  }

  @override
  Stream<ParkingSessionDto?> watchOpenSession(String driverId) {
    return _sessionsCollection
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: _openStatuses)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          final sessions =
              snapshot.docs
                  .map(
                    (doc) =>
                        ParkingSessionDto.fromFirestore(doc.id, doc.data()),
                  )
                  .toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return sessions.first;
        });
  }

  @override
  Stream<List<ParkingSessionDto>> watchLeavingSoonSessions(
    List<String> parkingIds,
  ) {
    final uniqueParkingIds = parkingIds.toSet().toList();

    if (uniqueParkingIds.isEmpty) {
      return Stream<List<ParkingSessionDto>>.value(const <ParkingSessionDto>[]);
    }

    final parkingIdGroups = <List<String>>[];

    for (
      var start = 0;
      start < uniqueParkingIds.length;
      start += _parkingIdsPerQuery
    ) {
      final end = (start + _parkingIdsPerQuery < uniqueParkingIds.length)
          ? start + _parkingIdsPerQuery
          : uniqueParkingIds.length;

      parkingIdGroups.add(uniqueParkingIds.sublist(start, end));
    }

    late final StreamController<List<ParkingSessionDto>> controller;

    final subscriptions =
        <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

    final latestSessionsByGroup = <int, Map<String, ParkingSessionDto>>{};

    controller = StreamController<List<ParkingSessionDto>>(
      onListen: () {
        for (var i = 0; i < parkingIdGroups.length; i++) {
          final groupIndex = i;
          final parkingIdGroup = parkingIdGroups[groupIndex];

          final subscription = _sessionsCollection
              .where('parkingId', whereIn: parkingIdGroup)
              .where('status', isEqualTo: 'leavingSoon')
              .snapshots()
              .listen(
                (snapshot) {
                  final sessionsById = <String, ParkingSessionDto>{};

                  for (final doc in snapshot.docs) {
                    final session = ParkingSessionDto.fromFirestore(
                      doc.id,
                      doc.data(),
                    );
                    sessionsById[session.id] = session;
                  }

                  latestSessionsByGroup[groupIndex] = sessionsById;

                  final combinedSessions = <String, ParkingSessionDto>{};

                  for (final groupSessions in latestSessionsByGroup.values) {
                    combinedSessions.addAll(groupSessions);
                  }

                  final result = combinedSessions.values.toList()
                    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                  if (!controller.isClosed) {
                    controller.add(result);
                  }
                },
                onError: (Object error, StackTrace stackTrace) {
                  if (!controller.isClosed) {
                    controller.addError(error, stackTrace);
                  }
                },
              );

          subscriptions.add(subscription);
        }
      },
      onCancel: () async {
        await Future.wait(
          subscriptions.map((subscription) => subscription.cancel()),
        );
      },
    );

    return controller.stream;
  }

  @override
  Future<void> updateSession(ParkingSessionDto session) async {
    await _sessionsCollection.doc(session.id).set(session.toFirestore());
  }
}

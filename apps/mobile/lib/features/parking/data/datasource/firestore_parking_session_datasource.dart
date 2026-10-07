import 'package:cloud_firestore/cloud_firestore.dart';

import '../dto/parking_session_dto.dart';
import 'parking_session_datasource.dart';

class FirestoreParkingSessionDataSource implements ParkingSessionDataSource {
  FirestoreParkingSessionDataSource(this._firestore);

  final FirebaseFirestore _firestore;

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
  Future<void> updateSession(ParkingSessionDto session) async {
    await _sessionsCollection.doc(session.id).set(session.toFirestore());
  }
}

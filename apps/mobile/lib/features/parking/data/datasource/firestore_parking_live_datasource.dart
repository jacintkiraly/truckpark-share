import 'package:cloud_firestore/cloud_firestore.dart';

import '../dto/parking_report_dto.dart';
import 'parking_live_datasource.dart';

class FirestoreParkingLiveDataSource
    implements ParkingLiveDataSource {
  FirestoreParkingLiveDataSource(
    this._firestore,
  );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _reportsCollection(
    String parkingId,
  ) {
    return _firestore
        .collection('parking_spots')
        .doc(parkingId)
        .collection('live_reports');
  }

  @override
  Future<void> addReport(
    ParkingReportDto report,
  ) async {
    final reports = _reportsCollection(
      report.parkingId,
    );

    final document = report.id.isEmpty
        ? reports.doc()
        : reports.doc(report.id);

    await document.set(
      report.toFirestore(),
    );
  }

  @override
  Stream<List<ParkingReportDto>> watchReports(
    String parkingId,
  ) {
    return _reportsCollection(
      parkingId,
    )
        .orderBy(
          'reportedAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map(
              (doc) {
                return ParkingReportDto.fromFirestore(
                  doc.id,
                  parkingId,
                  doc.data(),
                );
              },
            ).toList();
          },
        );
  }
}
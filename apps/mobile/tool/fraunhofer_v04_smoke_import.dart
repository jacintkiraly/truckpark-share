import 'dart:convert';
import 'dart:io';

import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

const _inputFile =
    '../../tool/output/fraunhofer_v04_dry_run.jsonl';

const _smokeCollection =
    'parking_spots_import_smoke_test';

const _smokeRecordCount = 5;

Future<void> main() async {
  print('==============================================');
  print('TruckPark Share - Fraunhofer v04 Smoke Import');
  print('==============================================');

  print('');
  print('Input: $_inputFile');
  print('Collection: $_smokeCollection');
  print('Records: $_smokeRecordCount');

  final inputFile = File(_inputFile);

  if (!inputFile.existsSync()) {
    throw StateError(
      'Input file not found: $_inputFile',
    );
  }

  final lines = inputFile
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty)
      .take(_smokeRecordCount)
      .toList();

  if (lines.length != _smokeRecordCount) {
    throw StateError(
      'Expected $_smokeRecordCount records, '
      'but found ${lines.length}.',
    );
  }

  final records = <Map<String, dynamic>>[];

  for (var index = 0; index < lines.length; index++) {
    final decoded = jsonDecode(lines[index]);

    if (decoded is! Map<String, dynamic>) {
      throw StateError(
        'Record ${index + 1} is not a JSON object.',
      );
    }

    final documentId = decoded['documentId'];
    final data = decoded['data'];

    if (documentId is! String || documentId.isEmpty) {
      throw StateError(
        'Record ${index + 1} has an invalid documentId.',
      );
    }

    if (!documentId.startsWith('tps_')) {
      throw StateError(
        'Record ${index + 1} has an invalid document ID: '
        '$documentId',
      );
    }

    if (data is! Map<String, dynamic>) {
      throw StateError(
        'Record ${index + 1} has invalid data.',
      );
    }

    records.add({
      'documentId': documentId,
      'data': data,
    });
  }

  print('');
  print('Input validation: OK');
  print('Records prepared: ${records.length}');

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();
  final firestore = app.firestore();

  print('Firebase Admin SDK initialized.');

  final writtenDocumentIds = <String>[];

  try {
    print('');
    print('Writing smoke-test documents...');

    for (final record in records) {
      final documentId = record['documentId'] as String;
      final data = record['data'] as Map<String, dynamic>;

      await firestore
          .collection(_smokeCollection)
          .doc(documentId)
          .set(data);

      writtenDocumentIds.add(documentId);

      print('  WRITE OK: $documentId');
    }

    print('');
    print(
      'Firestore writes performed: '
      '${writtenDocumentIds.length}',
    );

    print('');
    print('Reading smoke-test documents...');

    for (final documentId in writtenDocumentIds) {
      final snapshot = await firestore
          .collection(_smokeCollection)
          .doc(documentId)
          .get();

      if (!snapshot.exists) {
        throw StateError(
          'Document was not found after write: $documentId',
        );
      }

      final data = snapshot.data();

      if (data == null) {
        throw StateError(
          'Document has no data after read: $documentId',
        );
      }

      print('  READ OK: $documentId');
    }

    print('');
    print('Firestore read-back: OK');

    print('');
    print('Deleting smoke-test documents...');

    for (final documentId in writtenDocumentIds) {
      await firestore
          .collection(_smokeCollection)
          .doc(documentId)
          .delete();

      print('  DELETE OK: $documentId');
    }

    print('');
    print('Firestore deletes performed: '
        '${writtenDocumentIds.length}');

    print('');
    print('==============================================');
    print('RESULT: PASS');
    print('==============================================');
  } catch (error) {
    print('');
    print('ERROR: $error');

    print('');
    print('Cleaning up already-written smoke-test documents...');

    for (final documentId in writtenDocumentIds) {
      try {
        await firestore
            .collection(_smokeCollection)
            .doc(documentId)
            .delete();

        print('  CLEANUP OK: $documentId');
      } catch (cleanupError) {
        print(
          '  CLEANUP FAILED: $documentId '
          '($cleanupError)',
        );
      }
    }

    rethrow;
  }
}

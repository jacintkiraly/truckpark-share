import 'dart:convert';
import 'dart:io';

import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

const _inputFile =
    '../../tool/output/fraunhofer_v04_dry_run.jsonl';

const _collection =
    'parking_spots';

const _expectedRecordCount =
    13323;

Future<void> main() async {
  print('==================================================');
  print('TruckPark Share - Fraunhofer Firestore Diagnostic');
  print('==================================================');

  print('');
  print('Reading expected IDs from JSONL...');

  final inputFile = File(_inputFile);

  if (!inputFile.existsSync()) {
    throw StateError(
      'Input file not found: $_inputFile',
    );
  }

  final expectedIds = <String>{};

  for (final line in inputFile.readAsLinesSync()) {
    if (line.trim().isEmpty) {
      continue;
    }

    final decoded = jsonDecode(line);

    if (decoded is! Map<String, dynamic>) {
      throw StateError(
        'Invalid JSONL record.',
      );
    }

    final documentId = decoded['documentId'];

    if (documentId is! String ||
        documentId.isEmpty) {
      throw StateError(
        'Invalid documentId in JSONL.',
      );
    }

    expectedIds.add(documentId);
  }

  print(
    'Expected IDs in JSONL: ${expectedIds.length}',
  );

  if (expectedIds.length != _expectedRecordCount) {
    throw StateError(
      'Expected $_expectedRecordCount unique IDs, '
      'but found ${expectedIds.length}.',
    );
  }

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();
  final firestore = app.firestore();

  print('Firebase Admin SDK initialized.');

  print('');
  print('Reading Firestore collection...');

  final snapshot =
      await firestore.collection(_collection).get();

  final firestoreIds = <String>{};

  for (final document in snapshot.docs) {
    firestoreIds.add(document.id);
  }

  print(
    'Firestore document count: ${firestoreIds.length}',
  );

  final missingIds =
      expectedIds.difference(firestoreIds);

  final unexpectedIds =
      firestoreIds.difference(expectedIds);

  print('');
  print('==================================================');
  print('COMPARISON');
  print('==================================================');

  print(
    'Expected Fraunhofer documents: ${expectedIds.length}',
  );

  print(
    'Firestore documents:           ${firestoreIds.length}',
  );

  print(
    'Missing expected documents:    ${missingIds.length}',
  );

  print(
    'Unexpected documents:          ${unexpectedIds.length}',
  );

  print('');

  if (missingIds.isNotEmpty) {
    print('First missing document IDs:');

    for (final id in missingIds.take(20)) {
      print('  $id');
    }
  }

  print('');

  if (unexpectedIds.isNotEmpty) {
    print('First unexpected document IDs:');

    for (final id in unexpectedIds.take(20)) {
      print('  $id');
    }
  }

  print('');

  if (missingIds.isEmpty &&
      unexpectedIds.isEmpty) {
    print('RESULT: FIRESTORE MATCHES JSONL');
  } else {
    print('RESULT: FIRESTORE DIFF DETECTED');
  }
}

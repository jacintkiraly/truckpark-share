import 'dart:convert';
import 'dart:io';

import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

const _inputFile =
    '../../tool/output/fraunhofer_v04_dry_run.jsonl';

const _collection =
    'parking_spots';

const _expectedRecordCount =
    13323;

const _chunkSize =
    250;

Future<void> main() async {
  print('==================================================');
  print('TruckPark Share - Fraunhofer getAll Diagnostic');
  print('==================================================');

  final inputFile = File(_inputFile);

  if (!inputFile.existsSync()) {
    throw StateError(
      'Input file not found: $_inputFile',
    );
  }

  print('');
  print('Reading Fraunhofer document IDs...');

  final ids = <String>[];

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

    ids.add(documentId);
  }

  print(
    'Fraunhofer IDs in JSONL: ${ids.length}',
  );

  if (ids.length != _expectedRecordCount) {
    throw StateError(
      'Expected $_expectedRecordCount IDs, '
      'but found ${ids.length}.',
    );
  }

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();
  final firestore = app.firestore();

  print('Firebase Admin SDK initialized.');

  var existingCount = 0;
  var missingCount = 0;
  var totalFetched = 0;

  print('');
  print('Reading documents with Firestore.getAll()...');
  print('');

  for (
    var start = 0;
    start < ids.length;
    start += _chunkSize
  ) {
    final end = (start + _chunkSize)
        .clamp(0, ids.length);

    final chunkIds =
        ids.sublist(start, end);

    final references = chunkIds
        .map(
          (id) => firestore
              .collection(_collection)
              .doc(id),
        )
        .toList();

    final snapshots =
        await firestore.getAll(references);

    totalFetched += snapshots.length;

    for (final snapshot in snapshots) {
      if (snapshot.exists) {
        existingCount++;
      } else {
        missingCount++;
      }
    }

    print(
      'Chunk: '
      '$end/${ids.length} '
      '| fetched=${snapshots.length} '
      '| existing=$existingCount '
      '| missing=$missingCount',
    );
  }

  print('');
  print('==================================================');
  print('RESULT');
  print('==================================================');

  print(
    'Expected Fraunhofer IDs: '
    '${ids.length}',
  );

  print(
    'getAll() snapshots: '
    '$totalFetched',
  );

  print(
    'Existing documents: '
    '$existingCount',
  );

  print(
    'Missing documents: '
    '$missingCount',
  );

  if (existingCount == ids.length &&
      missingCount == 0 &&
      totalFetched == ids.length) {
    print('');
    print('RESULT: ALL FRAUNHOFER DOCUMENTS VERIFIED');
  } else {
    print('');
    print('RESULT: FRAUNHOFER DOCUMENT DIFF DETECTED');
  }

  print('');
  print('No writes were performed.');
}

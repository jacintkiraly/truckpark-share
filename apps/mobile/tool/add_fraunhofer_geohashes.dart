import 'dart:convert';
import 'dart:io';

import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:geohash_bounds/geohash_bounds.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';

const _inputFile =
    '../../tool/output/fraunhofer_v04_dry_run.jsonl';

const _collection =
    'parking_spots';

const _expectedRecordCount =
    13323;

const _batchSize =
    400;

const _readChunkSize =
    250;

const _geohashPrecision =
    10;

Future<void> main(List<String> args) async {
  final writeEnabled = args.contains('--write');
  final limit = _parseLimit(args);

  print('==================================================');
  print('TruckPark Share - Fraunhofer Geohash Migration');
  print('==================================================');

  print('');
  print('Input:      $_inputFile');
  print('Collection: $_collection');
  print('Mode:       ${writeEnabled ? 'WRITE' : 'DRY-RUN'}');
  print('Batch size: $_batchSize');
  print('Read chunk: $_readChunkSize');
  print('Precision:  $_geohashPrecision');

  if (limit != null) {
    print('Limit:      $limit');
  } else {
    print('Limit:      none');
  }

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

    if (!documentId.startsWith('tps_')) {
      throw StateError(
        'Unexpected Fraunhofer document ID: '
        '$documentId',
      );
    }

    ids.add(documentId);
  }

  if (ids.length != _expectedRecordCount) {
    throw StateError(
      'Expected $_expectedRecordCount Fraunhofer IDs, '
      'but found ${ids.length}.',
    );
  }

  print(
    'Fraunhofer IDs in JSONL: ${ids.length}',
  );

  final idsToProcess = limit == null
      ? ids
      : ids.take(limit).toList();

  if (limit != null && limit > ids.length) {
    throw ArgumentError(
      '--limit cannot exceed ${ids.length}.',
    );
  }

  print('');
  print(
    'Fraunhofer IDs selected: '
    '${idsToProcess.length}',
  );

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();
  final firestore = app.firestore();

  print('Firebase Admin SDK initialized.');

  final updates = <_GeoHashUpdate>[];

  var existingCorrect = 0;
  var needsUpdate = 0;
  var missingDocuments = 0;

  print('');
  print('Reading Fraunhofer documents with getAll()...');
  print('');

  for (
    var start = 0;
    start < idsToProcess.length;
    start += _readChunkSize
  ) {
    final end = (start + _readChunkSize)
        .clamp(0, idsToProcess.length);

    final chunkIds =
        idsToProcess.sublist(start, end);

    final references = chunkIds
        .map(
          (id) => firestore
              .collection(_collection)
              .doc(id),
        )
        .toList();

    final snapshots =
        await firestore.getAll(references);

    if (snapshots.length != chunkIds.length) {
      throw StateError(
        'getAll() returned ${snapshots.length} snapshots '
        'for ${chunkIds.length} references.',
      );
    }

    for (final snapshot in snapshots) {
      if (!snapshot.exists) {
        missingDocuments++;
        continue;
      }

      final data = snapshot.data();

      if (data == null) {
        throw StateError(
          'Document ${snapshot.id} exists '
          'but has no readable data.',
        );
      }

      final latitude = data['latitude'];
      final longitude = data['longitude'];

      if (latitude is! num ||
          longitude is! num) {
        throw StateError(
          'Document ${snapshot.id} has invalid '
          'latitude/longitude.',
        );
      }

      final latitudeValue = latitude.toDouble();
      final longitudeValue = longitude.toDouble();

      if (latitudeValue < -90 ||
          latitudeValue > 90 ||
          longitudeValue < -180 ||
          longitudeValue > 180) {
        throw StateError(
          'Document ${snapshot.id} has invalid '
          'coordinates: '
          '$latitudeValue, $longitudeValue',
        );
      }

      final geohash = GeohashUtil.encode(
        latitudeValue,
        longitudeValue,
        precision: _geohashPrecision,
      );

      if (data['geohash'] == geohash) {
        existingCorrect++;
        continue;
      }

      needsUpdate++;

      updates.add(
        _GeoHashUpdate(
          documentId: snapshot.id,
          geohash: geohash,
        ),
      );
    }

    print(
      'Read: $end/${idsToProcess.length}'
      ' | correct=$existingCorrect'
      ' | needsUpdate=$needsUpdate'
      ' | missing=$missingDocuments',
    );
  }

  if (missingDocuments > 0) {
    throw StateError(
      'Fraunhofer documents missing during getAll(): '
      '$missingDocuments',
    );
  }

  print('');
  print('==================================================');
  print('PREPARED MIGRATION');
  print('==================================================');

  print(
    'Fraunhofer documents selected: '
    '${idsToProcess.length}',
  );

  print(
    'Fraunhofer geohashes already correct: '
    '$existingCorrect',
  );

  print(
    'Documents requiring geohash update: '
    '$needsUpdate',
  );

  print(
    'Total Firestore operations: '
    '${updates.length}',
  );

  if (!writeEnabled) {
    print('');
    print('==================================================');
    print('RESULT: GEOHASH DRY-RUN PASS');
    print('==================================================');

    print(
      'Firestore writes performed: 0',
    );

    return;
  }

  print('');
  print('Starting Firestore WriteBatch migration...');
  print('');

  var committedWrites = 0;

  for (
    var start = 0;
    start < updates.length;
    start += _batchSize
  ) {
    final end = (start + _batchSize)
        .clamp(0, updates.length);

    final batchUpdates =
        updates.sublist(start, end);

    final batch = firestore.batch();

    for (final update in batchUpdates) {
      final documentReference = firestore
          .collection(_collection)
          .doc(update.documentId);

      batch.update(
        documentReference,
        {
          FieldPath(
            const ['geohash'],
          ): update.geohash,
        },
      );
    }

    await batch.commit();

    committedWrites += batchUpdates.length;

    print(
      'Batch committed: '
      '$committedWrites/${updates.length}',
    );
  }

  print('');
  print('==================================================');
  print('RESULT: GEOHASH MIGRATION PASS');
  print('==================================================');

  print(
    'Firestore geohash updates: '
    '$committedWrites',
  );
}

int? _parseLimit(List<String> args) {
  for (final arg in args) {
    if (!arg.startsWith('--limit=')) {
      continue;
    }

    final value =
        arg.substring('--limit='.length);

    final limit = int.tryParse(value);

    if (limit == null || limit <= 0) {
      throw ArgumentError(
        'Invalid --limit value: $value',
      );
    }

    return limit;
  }

  return null;
}

class _GeoHashUpdate {
  const _GeoHashUpdate({
    required this.documentId,
    required this.geohash,
  });

  final String documentId;
  final String geohash;
}

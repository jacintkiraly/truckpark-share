import 'dart:convert';
import 'dart:io';

import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

const _inputFile =
    '../../tool/output/fraunhofer_v04_dry_run.jsonl';

const _collection =
    'parking_spots';

const _expectedRecordCount =
    13323;

const _batchSize =
    400;

const _forbiddenLiveFields = {
  'status',
  'freeSpaces',
  'lastUpdated',
  'updatedBy',
  'confidence',
};

Future<void> main(List<String> args) async {
  final writeEnabled = args.contains('--write');
  final limit = _parseLimit(args);

  print('==============================================');
  print('TruckPark Share - Fraunhofer v04 Import');
  print('==============================================');

  print('');
  print('Input:      $_inputFile');
  print('Collection: $_collection');
  print('Mode:       ${writeEnabled ? 'WRITE' : 'DRY-RUN'}');
  print('Batch size: $_batchSize');

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
  print('Reading JSONL...');

  final lines = inputFile
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty)
      .toList();

  print('JSONL records found: ${lines.length}');

  if (lines.length != _expectedRecordCount) {
    throw StateError(
      'Expected $_expectedRecordCount records, '
      'but found ${lines.length}.',
    );
  }

  final records = <_ImportRecord>[];
  final seenDocumentIds = <String>{};

  print('');
  print('Validating records...');

  for (var index = 0; index < lines.length; index++) {
    final decoded = jsonDecode(lines[index]);

    if (decoded is! Map<String, dynamic>) {
      throw StateError(
        'Record ${index + 1} is not a JSON object.',
      );
    }

    final documentId = decoded['documentId'];
    final data = decoded['data'];

    if (documentId is! String ||
        documentId.isEmpty) {
      throw StateError(
        'Record ${index + 1} has an invalid documentId.',
      );
    }

    if (!documentId.startsWith('tps_')) {
      throw StateError(
        'Record ${index + 1} has invalid document ID: '
        '$documentId',
      );
    }

    if (documentId.length != 68) {
      throw StateError(
        'Record ${index + 1} has invalid document ID length: '
        '${documentId.length}',
      );
    }

    if (!seenDocumentIds.add(documentId)) {
      throw StateError(
        'Duplicate document ID detected: $documentId',
      );
    }

    if (data is! Map<String, dynamic>) {
      throw StateError(
        'Record ${index + 1} has invalid data.',
      );
    }

    for (final forbiddenField in _forbiddenLiveFields) {
      if (data.containsKey(forbiddenField)) {
        throw StateError(
          'Record ${index + 1} contains forbidden '
          'live-status field: $forbiddenField',
        );
      }
    }

    final source = data['source'];

    if (source is! Map<String, dynamic>) {
      throw StateError(
        'Record ${index + 1} has no valid source object.',
      );
    }

    if (source['provider'] != 'Fraunhofer') {
      throw StateError(
        'Record ${index + 1} has unexpected source provider: '
        '${source['provider']}',
      );
    }

    if (source['dataset'] !=
        'European Truck Parking Locations') {
      throw StateError(
        'Record ${index + 1} has unexpected source dataset: '
        '${source['dataset']}',
      );
    }

    if (source['datasetVersion'] != 'v04') {
      throw StateError(
        'Record ${index + 1} has unexpected source version: '
        '${source['datasetVersion']}',
      );
    }

    final latitude = data['latitude'];
    final longitude = data['longitude'];

    if (latitude is! num ||
        latitude < -90 ||
        latitude > 90) {
      throw StateError(
        'Record ${index + 1} has invalid latitude: '
        '$latitude',
      );
    }

    if (longitude is! num ||
        longitude < -180 ||
        longitude > 180) {
      throw StateError(
        'Record ${index + 1} has invalid longitude: '
        '$longitude',
      );
    }

    records.add(
      _ImportRecord(
        documentId: documentId,
        data: data,
      ),
    );
  }

  print('Input validation: OK');
  print('Validated records: ${records.length}');
  print('Unique document IDs: ${seenDocumentIds.length}');

  final recordsToWrite = limit == null
      ? records
      : records.take(limit).toList();

  if (limit != null &&
      limit > records.length) {
    throw ArgumentError(
      '--limit cannot exceed ${records.length}.',
    );
  }

  print('');
  print(
    'Records selected for import: '
    '${recordsToWrite.length}',
  );

  if (!writeEnabled) {
    print('');
    print('==============================================');
    print('RESULT: DRY-RUN PASS');
    print('==============================================');
    print('Firestore writes performed: 0');

    return;
  }

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();
  final firestore = app.firestore();

  print('Firebase Admin SDK initialized.');

  var committedWrites = 0;

  print('');
  print('Starting Firestore WriteBatch import...');
  print('');

  for (
    var start = 0;
    start < recordsToWrite.length;
    start += _batchSize
  ) {
    final end = (start + _batchSize)
        .clamp(0, recordsToWrite.length);

    final batchRecords =
        recordsToWrite.sublist(start, end);

    final batch = firestore.batch();

    for (final record in batchRecords) {
      final documentReference = firestore
          .collection(_collection)
          .doc(record.documentId);

      batch.set(
        documentReference,
        record.data,
      );
    }

    try {
      await batch.commit();
    } catch (error) {
      print('');
      print('==============================================');
      print('RESULT: IMPORT FAILED');
      print('==============================================');
      print(
        'Failed batch range: '
        '${start + 1}-$end',
      );
      print('Error: $error');

      rethrow;
    }

    committedWrites += batchRecords.length;

    print(
      'Batch committed: '
      '$committedWrites/${recordsToWrite.length}',
    );
  }

  print('');
  print('==============================================');
  print('RESULT: IMPORT PASS');
  print('==============================================');
  print(
    'Firestore writes performed: '
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

class _ImportRecord {
  const _ImportRecord({
    required this.documentId,
    required this.data,
  });

  final String documentId;
  final Map<String, dynamic> data;
}

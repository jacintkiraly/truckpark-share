import 'dart:convert';
import 'dart:io';

import 'package:truckpark_share/features/parking/data/import/fraunhofer_parking_mapper.dart';
import 'package:truckpark_share/features/parking/data/mappers/parking_spot_firestore_document_mapper.dart';

Future<void> main() async {
  final csvFile = File(
    '../../tool/data/truckParkingLocationsEurope_N13323_v04.csv',
  );

  final outputDirectory = Directory(
    '../../tool/output',
  );

  final outputFile = File(
    '../../tool/output/fraunhofer_v04_dry_run.jsonl',
  );

  if (!csvFile.existsSync()) {
    stderr.writeln(
      'ERROR: Fraunhofer CSV not found: ${csvFile.path}',
    );
    exitCode = 1;
    return;
  }

  outputDirectory.createSync(recursive: true);

  final csvText = csvFile.readAsStringSync();

  final records = _parseCsv(
    csvText,
    separator: ';',
  );

  if (records.isEmpty) {
    stderr.writeln('ERROR: CSV is empty.');
    exitCode = 1;
    return;
  }

  final header = records.first;

  final mapper = const FraunhoferParkingMapper();
  const documentMapper =
      ParkingSpotFirestoreDocumentMapper();

  final ids = <String>{};

  final facilityTypes = <String, int>{};
  final countries = <String, int>{};

  var successful = 0;
  var failed = 0;

  final writer = outputFile.openWrite();

  try {
    for (var i = 1; i < records.length; i++) {
      final values = records[i];

      if (values.length != header.length) {
        failed++;

        stderr.writeln(
          'ERROR: Row ${i + 1} has ${values.length} columns; '
          'expected ${header.length}.',
        );

        continue;
      }

      final row = <String, dynamic>{};

      for (var j = 0; j < header.length; j++) {
        row[header[j]] = values[j];
      }

      try {
        final parkingSpot = mapper.map(row);

        if (!ids.add(parkingSpot.id)) {
          failed++;

          stderr.writeln(
            'ERROR: Duplicate ParkingSpot ID at row ${i + 1}: '
            '${parkingSpot.id}',
          );

          continue;
        }

        final document =
            documentMapper.toDocument(parkingSpot);

        _validateFirestoreDocument(
          parkingSpotId: parkingSpot.id,
          document: document,
          rowNumber: i + 1,
        );

        writer.writeln(
          jsonEncode({
            'documentId': parkingSpot.id,
            'data': document,
          }),
        );

        successful++;

        facilityTypes.update(
          parkingSpot.facilityType.name,
          (count) => count + 1,
          ifAbsent: () => 1,
        );

        countries.update(
          parkingSpot.countryCode,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      } on Object catch (error) {
        failed++;

        stderr.writeln(
          'ERROR: Row ${i + 1} failed: $error',
        );
      }
    }
  } finally {
    await writer.flush();
    await writer.close();
  }

  stdout.writeln('');
  stdout.writeln(
    '==============================================',
  );
  stdout.writeln(
    'Fraunhofer v04 Firestore Import Dry-Run',
  );
  stdout.writeln(
    '==============================================',
  );
  stdout.writeln(
    'CSV records:              ${records.length - 1}',
  );
  stdout.writeln(
    'Successfully prepared:    $successful',
  );
  stdout.writeln(
    'Errors:                   $failed',
  );
  stdout.writeln(
    'Unique document IDs:      ${ids.length}',
  );
  stdout.writeln(
    'Output file:              ${outputFile.path}',
  );
  stdout.writeln('');
  stdout.writeln('Facility types:');

  final sortedFacilities =
      facilityTypes.entries.toList()
        ..sort(
          (a, b) => a.key.compareTo(b.key),
        );

  for (final entry in sortedFacilities) {
    stdout.writeln(
      '  ${entry.key}: ${entry.value}',
    );
  }

  stdout.writeln('');
  stdout.writeln('Countries:');

  final sortedCountries =
      countries.entries.toList()
        ..sort(
          (a, b) => a.key.compareTo(b.key),
        );

  for (final entry in sortedCountries) {
    stdout.writeln(
      '  ${entry.key}: ${entry.value}',
    );
  }

  stdout.writeln('');

  const expectedRecords = 13323;

  final valid =
      records.length - 1 == expectedRecords &&
      successful == expectedRecords &&
      failed == 0 &&
      ids.length == expectedRecords;

  if (valid) {
    stdout.writeln('RESULT: PASS');
    stdout.writeln(
      'Firestore writes performed: 0',
    );
    exitCode = 0;
  } else {
    stdout.writeln('RESULT: FAIL');
    stdout.writeln(
      'Firestore writes performed: 0',
    );
    exitCode = 1;
  }
}

void _validateFirestoreDocument({
  required String parkingSpotId,
  required Map<String, dynamic> document,
  required int rowNumber,
}) {
  const requiredTopLevelFields = [
    'name',
    'latitude',
    'longitude',
    'countryCode',
    'facilityType',
    'totalAreaM2',
    'services',
    'infrastructure',
    'context',
    'networkContext',
    'truckContext',
    'safeAndSecureTruckParkingArea',
    'truckParkingConfidence',
    'source',
    'verification',
  ];

  for (final field in requiredTopLevelFields) {
    if (!document.containsKey(field)) {
      throw FormatException(
        'Row $rowNumber, document $parkingSpotId: '
        'missing Firestore field "$field".',
      );
    }
  }

  const forbiddenLiveFields = [
    'status',
    'freeSpaces',
    'lastUpdated',
    'updatedBy',
    'confidence',
  ];

  for (final field in forbiddenLiveFields) {
    if (document.containsKey(field)) {
      throw FormatException(
        'Row $rowNumber, document $parkingSpotId: '
        'live field "$field" must not be present.',
      );
    }
  }

  final source = document['source'];

  if (source is! Map<String, dynamic>) {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      '"source" must be a map.',
    );
  }

  if (source['provider'] != 'Fraunhofer') {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      'unexpected source provider "${source['provider']}".',
    );
  }

  if (source['dataset'] !=
      'European Truck Parking Locations') {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      'unexpected source dataset "${source['dataset']}".',
    );
  }

  if (source['datasetVersion'] != 'v04') {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      'unexpected dataset version "${source['datasetVersion']}".',
    );
  }

  final verification = document['verification'];

  if (verification is! Map<String, dynamic>) {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      '"verification" must be a map.',
    );
  }

  if (verification['verified'] != false) {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      'Fraunhofer import must not mark the spot as verified.',
    );
  }

  final latitude = document['latitude'];
  final longitude = document['longitude'];

  if (latitude is! num ||
      latitude.toDouble() < -90 ||
      latitude.toDouble() > 90) {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      'invalid latitude "$latitude".',
    );
  }

  if (longitude is! num ||
      longitude.toDouble() < -180 ||
      longitude.toDouble() > 180) {
    throw FormatException(
      'Row $rowNumber, document $parkingSpotId: '
      'invalid longitude "$longitude".',
    );
  }
}

List<List<String>> _parseCsv(
  String input, {
  required String separator,
}) {
  final records = <List<String>>[];

  var record = <String>[];
  var field = StringBuffer();
  var inQuotes = false;

  var index = 0;

  while (index < input.length) {
    final char = input[index];

    if (char == '"') {
      if (inQuotes) {
        if (index + 1 < input.length &&
            input[index + 1] == '"') {
          field.write('"');
          index += 2;
          continue;
        }

        inQuotes = false;
        index++;
        continue;
      }

      inQuotes = true;
      index++;
      continue;
    }

    if (!inQuotes &&
        input.startsWith(separator, index)) {
      record.add(field.toString());
      field = StringBuffer();
      index += separator.length;
      continue;
    }

    if (!inQuotes &&
        (char == '\n' || char == '\r')) {
      record.add(field.toString());
      field = StringBuffer();

      records.add(record);
      record = <String>[];

      if (char == '\r' &&
          index + 1 < input.length &&
          input[index + 1] == '\n') {
        index += 2;
      } else {
        index++;
      }

      continue;
    }

    field.write(char);
    index++;
  }

  record.add(field.toString());

  if (record.length > 1 ||
      record.first.isNotEmpty) {
    records.add(record);
  }

  return records;
}

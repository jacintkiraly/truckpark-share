import 'dart:io';

import '../lib/features/parking/data/import/fraunhofer_parking_mapper.dart';

void main() {
  final csvFile = File(
    '../../tool/data/truckParkingLocationsEurope_N13323_v04.csv',
  );

  if (!csvFile.existsSync()) {
    stderr.writeln(
      'ERROR: Fraunhofer CSV not found: ${csvFile.path}',
    );
    exitCode = 1;
    return;
  }

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

  final rows = <Map<String, dynamic>>[];

  for (var i = 1; i < records.length; i++) {
    final values = records[i];

    if (values.length != header.length) {
      stderr.writeln(
        'ERROR: Row ${i + 1} has ${values.length} columns; '
        'expected ${header.length}.',
      );

      stderr.writeln(
        '       Values: $values',
      );

      exitCode = 1;
      return;
    }

    final row = <String, dynamic>{};

    for (var j = 0; j < header.length; j++) {
      row[header[j]] = values[j];
    }

    rows.add(row);
  }

  final mapper = const FraunhoferParkingMapper();

  final ids = <String>{};
  final facilityTypes = <String, int>{};
  final countries = <String, int>{};

  var successful = 0;
  var failed = 0;

  for (var i = 0; i < rows.length; i++) {
    try {
      final spot = mapper.map(rows[i]);

      successful++;

      if (!ids.add(spot.id)) {
        stderr.writeln(
          'ERROR: Duplicate generated ID at CSV row ${i + 2}: '
          '${spot.id}',
        );
        failed++;
      }

      if (!spot.id.startsWith('tps_')) {
        stderr.writeln(
          'ERROR: Invalid ID prefix at CSV row ${i + 2}: '
          '${spot.id}',
        );
        failed++;
      }

      if (spot.id.length != 68) {
        stderr.writeln(
          'ERROR: Invalid ID length at CSV row ${i + 2}: '
          '${spot.id.length}',
        );
        failed++;
      }

      if (spot.countryCode.isEmpty) {
        stderr.writeln(
          'ERROR: Empty country code at CSV row ${i + 2}.',
        );
        failed++;
      }

      if (spot.location.latitude < -90 ||
          spot.location.latitude > 90) {
        stderr.writeln(
          'ERROR: Invalid latitude at CSV row ${i + 2}: '
          '${spot.location.latitude}',
        );
        failed++;
      }

      if (spot.location.longitude < -180 ||
          spot.location.longitude > 180) {
        stderr.writeln(
          'ERROR: Invalid longitude at CSV row ${i + 2}: '
          '${spot.location.longitude}',
        );
        failed++;
      }

      final facilityName = spot.facilityType.name;

      facilityTypes.update(
        facilityName,
        (count) => count + 1,
        ifAbsent: () => 1,
      );

      countries.update(
        spot.countryCode,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    } on Object catch (error) {
      failed++;

      stderr.writeln(
        'ERROR: CSV row ${i + 2} failed: $error',
      );
    }
  }

  print('');
  print('========================================');
  print('Fraunhofer v04 Dataset Validation');
  print('========================================');
  print('Records read:          ${rows.length}');
  print('Successfully mapped:   $successful');
  print('Validation errors:     $failed');
  print('Unique generated IDs:  ${ids.length}');
  print('');

  print('Facility types:');

  final sortedFacilities = facilityTypes.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in sortedFacilities) {
    print('  ${entry.key}: ${entry.value}');
  }

  print('');
  print('Countries:');

  final sortedCountries = countries.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in sortedCountries) {
    print('  ${entry.key}: ${entry.value}');
  }

  print('');

  final valid =
      rows.length == 13323 &&
      successful == 13323 &&
      failed == 0 &&
      ids.length == 13323;

  if (valid) {
    print('RESULT: PASS');
    exitCode = 0;
  } else {
    print('RESULT: FAIL');
    exitCode = 1;
  }
}

/// Parses a delimiter-separated CSV while respecting quoted fields.
///
/// Supports:
/// - semicolon separators
/// - quoted fields
/// - separators inside quoted fields
/// - escaped quotes represented as ""
/// - LF and CRLF line endings
/// - empty fields
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
        if (index + 1 < input.length && input[index + 1] == '"') {
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

    if (!inQuotes && input.startsWith(separator, index)) {
      record.add(field.toString());
      field = StringBuffer();
      index += separator.length;
      continue;
    }

    if (!inQuotes && (char == '\n' || char == '\r')) {
      record.add(field.toString());
      field = StringBuffer();

      if (record.isNotEmpty) {
        records.add(record);
      }

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

  if (record.length > 1 || record.first.isNotEmpty) {
    records.add(record);
  }

  return records;
}

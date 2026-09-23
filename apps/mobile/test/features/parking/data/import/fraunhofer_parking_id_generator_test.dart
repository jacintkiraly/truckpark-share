import 'package:flutter_test/flutter_test.dart';
import 'package:truckpark_share/features/parking/data/import/fraunhofer_parking_id_generator.dart';

void main() {
  const generator = FraunhoferParkingIdGenerator();

  group('FraunhoferParkingIdGenerator', () {
    test('generates the same ID for the same input', () {
      final first = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      final second = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      expect(first, equals(second));
    });

    test('does not include the dataset version in the identity', () {
      final id = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      expect(id, startsWith('tps_'));
      expect(id.length, 68);
    });

    test('normalizes country code and facility type casing and whitespace', () {
      final first = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      final second = generator.generate(
        countryCode: ' nl ',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: '  truck stop / rest area  ',
      );

      expect(first, equals(second));
    });

    test('normalizes coordinates to six decimal places', () {
      final first = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604001,
        longitude: 4.6870001,
        facilityType: 'Truck Stop / Rest Area',
      );

      final second = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604004,
        longitude: 4.6870004,
        facilityType: 'Truck Stop / Rest Area',
      );

      expect(first, equals(second));
    });

    test('different coordinates generate different IDs', () {
      final first = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      final second = generator.generate(
        countryCode: 'NL',
        latitude: 52.2605,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      expect(first, isNot(equals(second)));
    });

    test('different countries generate different IDs', () {
      final first = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      final second = generator.generate(
        countryCode: 'BE',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      expect(first, isNot(equals(second)));
    });

    test('different facility types generate different IDs', () {
      final first = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      final second = generator.generate(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Parking',
      );

      expect(first, isNot(equals(second)));
    });

    test('canonical key has the expected structure', () {
      final key = generator.canonicalKey(
        countryCode: 'NL',
        latitude: 52.2604,
        longitude: 4.687,
        facilityType: 'Truck Stop / Rest Area',
      );

      expect(
        key,
        equals(
          'fraunhofer|nl|52.260400|4.687000|truck stop / rest area',
        ),
      );
    });
  });
}
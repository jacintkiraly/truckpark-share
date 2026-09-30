import 'package:flutter_test/flutter_test.dart';
import 'package:truckpark_share/features/parking/domain/value_objects/parking_viewport.dart';

void main() {
  group('ParkingViewport.contains', () {
    test('accepts coordinates inside a normal viewport', () {
      const viewport = ParkingViewport(
        southWestLatitude: 40,
        southWestLongitude: -5,
        northEastLatitude: 42,
        northEastLongitude: -3,
      );

      expect(
        viewport.contains(
          latitude: 41,
          longitude: -4,
        ),
        isTrue,
      );
    });

    test('rejects coordinates outside a normal viewport', () {
      const viewport = ParkingViewport(
        southWestLatitude: 40,
        southWestLongitude: -5,
        northEastLatitude: 42,
        northEastLongitude: -3,
      );

      expect(
        viewport.contains(
          latitude: 41,
          longitude: -2,
        ),
        isFalse,
      );
    });

    test('supports an antimeridian-crossing viewport', () {
      const viewport = ParkingViewport(
        southWestLatitude: -10,
        southWestLongitude: 170,
        northEastLatitude: 10,
        northEastLongitude: -170,
      );

      expect(
        viewport.contains(
          latitude: 0,
          longitude: 175,
        ),
        isTrue,
      );

      expect(
        viewport.contains(
          latitude: 0,
          longitude: -175,
        ),
        isTrue,
      );

      expect(
        viewport.contains(
          latitude: 0,
          longitude: 0,
        ),
        isFalse,
      );
    });
  });
}

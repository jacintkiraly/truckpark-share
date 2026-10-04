import 'package:flutter_test/flutter_test.dart';

import 'package:truckpark_share/features/map/controllers/driver_location_filter.dart';
import 'package:truckpark_share/features/map/models/driver_location.dart';

void main() {
  const filter = DriverLocationFilter();

  DriverLocation location({
    required double latitude,
    required double longitude,
    required double accuracy,
    required DateTime timestamp,
  }) {
    return DriverLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );
  }

  test(
    'accepts the first location when accuracy is good',
    () {
      final candidate = location(
        latitude: 36.935,
        longitude: -5.260,
        accuracy: 20,
        timestamp: DateTime.utc(2026, 10, 4, 12),
      );

      expect(
        filter.shouldAccept(
          previous: null,
          candidate: candidate,
        ),
        isTrue,
      );
    },
  );

  test(
    'rejects location with poor accuracy',
    () {
      final previous = location(
        latitude: 36.935,
        longitude: -5.260,
        accuracy: 10,
        timestamp: DateTime.utc(2026, 10, 4, 12),
      );

      final candidate = location(
        latitude: 36.9351,
        longitude: -5.2601,
        accuracy: 150,
        timestamp: DateTime.utc(2026, 10, 4, 12, 0, 10),
      );

      expect(
        filter.shouldAccept(
          previous: previous,
          candidate: candidate,
        ),
        isFalse,
      );
    },
  );

  test(
    'accepts realistic movement',
    () {
      final previous = location(
        latitude: 36.935,
        longitude: -5.260,
        accuracy: 10,
        timestamp: DateTime.utc(2026, 10, 4, 12),
      );

      final candidate = location(
        latitude: 36.945,
        longitude: -5.260,
        accuracy: 10,
        timestamp: DateTime.utc(2026, 10, 4, 12, 0, 45),
      );

      expect(
        filter.shouldAccept(
          previous: previous,
          candidate: candidate,
        ),
        isTrue,
      );
    },
  );

  test(
    'rejects impossible GPS jump',
    () {
      final previous = location(
        latitude: 36.935,
        longitude: -5.260,
        accuracy: 10,
        timestamp: DateTime.utc(2026, 10, 4, 12),
      );

      final candidate = location(
        latitude: 37.935,
        longitude: -5.260,
        accuracy: 10,
        timestamp: DateTime.utc(2026, 10, 4, 12, 0, 30),
      );

      expect(
        filter.shouldAccept(
          previous: previous,
          candidate: candidate,
        ),
        isFalse,
      );
    },
  );

  test(
    'rejects non-increasing timestamp',
    () {
      final previous = location(
        latitude: 36.935,
        longitude: -5.260,
        accuracy: 10,
        timestamp: DateTime.utc(2026, 10, 4, 12),
      );

      final candidate = location(
        latitude: 36.9351,
        longitude: -5.2601,
        accuracy: 10,
        timestamp: DateTime.utc(2026, 10, 4, 12),
      );

      expect(
        filter.shouldAccept(
          previous: previous,
          candidate: candidate,
        ),
        isFalse,
      );
    },
  );
}


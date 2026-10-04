class DriverLocation {
  const DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.heading,
    this.headingAccuracy,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  /// Course over ground in degrees.
  ///
  /// Null means that the platform did not provide a reliable heading.
  final double? heading;

  /// Estimated heading accuracy in degrees.
  final double? headingAccuracy;

  bool get hasReliableHeading {
    final currentHeading = heading;
    final currentHeadingAccuracy = headingAccuracy;

    return currentHeading != null &&
        currentHeading.isFinite &&
        currentHeading >= 0 &&
        currentHeading < 360 &&
        currentHeadingAccuracy != null &&
        currentHeadingAccuracy.isFinite &&
        currentHeadingAccuracy >= 0;
  }

  @override
  String toString() {
    return 'DriverLocation('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'accuracy: $accuracy, '
        'timestamp: $timestamp, '
        'heading: $heading, '
        'headingAccuracy: $headingAccuracy'
        ')';
  }
}

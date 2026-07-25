class DriverLocation {
  const DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  @override
  String toString() {
    return 'DriverLocation('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'accuracy: $accuracy, '
        'timestamp: $timestamp'
        ')';
  }
}
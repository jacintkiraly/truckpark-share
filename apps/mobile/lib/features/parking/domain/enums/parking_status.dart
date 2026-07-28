enum ParkingStatus {
  available('available'),
  nearlyFull('nearlyFull'),
  full('full'),
  closed('closed');

  const ParkingStatus(this.firestoreValue);

  final String firestoreValue;
}
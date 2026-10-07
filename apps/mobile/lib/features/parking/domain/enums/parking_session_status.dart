enum ParkingSessionStatus {
  created('created'),
  active('active'),
  updated('updated'),
  leavingSoon('leavingSoon'),
  closed('closed');

  const ParkingSessionStatus(this.firestoreValue);

  final String firestoreValue;
}

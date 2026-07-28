enum ParkingType {
  motorway('motorway'),
  serviceArea('serviceArea'),
  fuelStation('fuelStation'),
  logisticsCenter('logisticsCenter'),
  industrial('industrial'),
  publicParking('publicParking'),
  privateParking('privateParking');

  const ParkingType(this.firestoreValue);

  final String firestoreValue;
}
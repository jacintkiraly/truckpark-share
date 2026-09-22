import 'package:equatable/equatable.dart';

class ParkingVerification extends Equatable {
  const ParkingVerification({
    this.verified = false,
    this.verifiedAt,
    this.verifiedBy,
  });

  final bool verified;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  @override
  List<Object?> get props => [
        verified,
        verifiedAt,
        verifiedBy,
      ];
}

import '../../domain/entities/parking_spot.dart';

class ParkingState {
  const ParkingState({
    this.isLoading = false,
    this.parkingSpots = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<ParkingSpot> parkingSpots;
  final String? errorMessage;

  ParkingState copyWith({
    bool? isLoading,
    List<ParkingSpot>? parkingSpots,
    String? errorMessage,
  }) {
    return ParkingState(
      isLoading: isLoading ?? this.isLoading,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      errorMessage: errorMessage,
    );
  }
}
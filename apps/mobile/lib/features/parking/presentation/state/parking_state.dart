import '../../domain/entities/parking_spot.dart';
import '../enums/parking_view_mode.dart';

class ParkingState {
  const ParkingState({
    this.isLoading = false,
    this.parkingSpots = const [],
    this.errorMessage,
    this.viewMode = ParkingViewMode.map,
  });

  final bool isLoading;
  final List<ParkingSpot> parkingSpots;
  final String? errorMessage;
  final ParkingViewMode viewMode;

  ParkingState copyWith({
    bool? isLoading,
    List<ParkingSpot>? parkingSpots,
    String? errorMessage,
    ParkingViewMode? viewMode,
  }) {
    return ParkingState(
      isLoading: isLoading ?? this.isLoading,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      errorMessage: errorMessage,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}
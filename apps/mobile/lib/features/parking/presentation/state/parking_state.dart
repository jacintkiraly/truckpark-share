import '../../domain/entities/parking_live_status.dart';
import '../../domain/entities/parking_spot.dart';
import '../enums/parking_view_mode.dart';

class ParkingState {
  const ParkingState({
    this.isLoading = false,
    this.parkingSpots = const [],
    this.liveStatuses = const {},
    this.errorMessage,
    this.viewMode = ParkingViewMode.map,
  });

  final bool isLoading;
  final List<ParkingSpot> parkingSpots;
  final Map<String, ParkingLiveStatus> liveStatuses;
  final String? errorMessage;
  final ParkingViewMode viewMode;

  ParkingState copyWith({
    bool? isLoading,
    List<ParkingSpot>? parkingSpots,
    Map<String, ParkingLiveStatus>? liveStatuses,
    String? errorMessage,
    ParkingViewMode? viewMode,
  }) {
    return ParkingState(
      isLoading: isLoading ?? this.isLoading,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      liveStatuses: liveStatuses ?? this.liveStatuses,
      errorMessage: errorMessage,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

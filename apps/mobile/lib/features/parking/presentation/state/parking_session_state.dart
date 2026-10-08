import '../../domain/entities/parking_session.dart';

class ParkingSessionState {
  const ParkingSessionState({
    this.isLoading = false,
    this.isSaving = false,
    this.session,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final ParkingSession? session;
  final String? errorMessage;

  ParkingSessionState copyWith({
    bool? isLoading,
    bool? isSaving,
    ParkingSession? session,
    String? errorMessage,
    bool clearSession = false,
  }) {
    return ParkingSessionState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      session: clearSession ? null : session ?? this.session,
      errorMessage: errorMessage,
    );
  }
}

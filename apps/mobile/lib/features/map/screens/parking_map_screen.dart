import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/service_locator.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../parking/domain/entities/parking_session.dart';
import '../../parking/domain/enums/parking_session_status.dart';
import '../../parking/domain/services/parking_session_expiration_policy.dart';
import '../../parking/domain/entities/parking_spot.dart';
import '../../../shared/widgets/primary_button.dart';

import '../../parking/domain/value_objects/parking_map_cluster.dart';
import '../../parking/domain/value_objects/parking_viewport.dart';
import '../../parking/domain/usecases/watch_leaving_soon_parking_sessions_use_case.dart';
import '../../parking/presentation/enums/parking_view_mode.dart';
import '../../parking/presentation/providers/parking_provider.dart';
import '../../parking/presentation/providers/parking_session_provider.dart';
import '../../parking/presentation/state/parking_session_state.dart';
import '../../parking/presentation/state/parking_state.dart';
import '../../parking/presentation/widgets/parking_list.dart';
import '../../parking/presentation/screens/add_parking_screen.dart';

import '../controllers/location_controller.dart';
import '../models/driver_location.dart';
import '../models/location_status.dart';
import '../widgets/parking_google_map.dart';

class ParkingMapScreen extends ConsumerStatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  ConsumerState<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends ConsumerState<ParkingMapScreen>
    with WidgetsBindingObserver {
  final LocationController _locationController = LocationController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationController.loadCurrentLocation();
      ref.read(parkingSessionViewModelProvider.notifier).watchCurrentSession();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationController.loadCurrentLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parkingState = ref.watch(parkingViewModelProvider);
    final parkingSessionState = ref.watch(parkingSessionViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parkingMapTitle),
        actions: [
          IconButton(
            tooltip: l10n.addParking,
            icon: const Icon(Icons.add_location_alt),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddParkingScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SegmentedButton<ParkingViewMode>(
              segments: [
                ButtonSegment<ParkingViewMode>(
                  value: ParkingViewMode.map,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(l10n.mapView),
                ),
                ButtonSegment<ParkingViewMode>(
                  value: ParkingViewMode.list,
                  icon: const Icon(Icons.list),
                  label: Text(l10n.listView),
                ),
              ],
              selected: {parkingState.viewMode},
              onSelectionChanged: (selection) {
                ref
                    .read(parkingViewModelProvider.notifier)
                    .setViewMode(selection.first);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildParkingContent(
          context,
          l10n,
          parkingState,
          parkingSessionState,
        ),
      ),
    );
  }

  Widget _buildParkingContent(
    BuildContext context,
    AppLocalizations l10n,
    ParkingState parkingState,
    ParkingSessionState parkingSessionState,
  ) {
    if (parkingState.isLoading) {
      return _LoadingState(message: l10n.parkingLoading);
    }

    if (parkingState.errorMessage != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: l10n.parkingLoadError,
        message: parkingState.errorMessage!,
        actionText: l10n.retry,
        onPressed: () {
          ref.read(parkingViewModelProvider.notifier).watchParkingSpots();
        },
      );
    }

    if (parkingState.viewMode == ParkingViewMode.list) {
      if (parkingState.parkingSpots.isEmpty) {
        return Center(child: Text(l10n.parkingNoSpots));
      }

      return ParkingList(parkingSpots: parkingState.parkingSpots);
    }

    return AnimatedBuilder(
      animation: _locationController,
      builder: (context, child) {
        return _buildMapContent(context, l10n, parkingSessionState);
      },
    );
  }

  Widget _buildMapContent(
    BuildContext context,
    AppLocalizations l10n,
    ParkingSessionState parkingSessionState,
  ) {
    switch (_locationController.status) {
      case LocationStatus.initial:
      case LocationStatus.loading:
        return _LoadingState(message: l10n.locationLoading);

      case LocationStatus.serviceDisabled:
        return _MessageState(
          icon: Icons.location_off_outlined,
          title: l10n.locationServiceDisabledTitle,
          message: l10n.locationServiceDisabledMessage,
          actionText: l10n.locationOpenSettings,
          onPressed: _openLocationSettings,
        );

      case LocationStatus.permissionDenied:
        return _MessageState(
          icon: Icons.location_disabled_outlined,
          title: l10n.locationPermissionDeniedTitle,
          message: l10n.locationPermissionDeniedMessage,
          actionText: l10n.locationRetry,
          onPressed: _locationController.retry,
        );

      case LocationStatus.permissionDeniedForever:
        return _MessageState(
          icon: Icons.settings_outlined,
          title: l10n.locationPermissionPermanentlyDeniedTitle,
          message: l10n.locationPermissionPermanentlyDeniedMessage,
          actionText: l10n.locationOpenAppSettings,
          onPressed: _openAppSettings,
        );

      case LocationStatus.error:
        return _MessageState(
          icon: Icons.error_outline,
          title: l10n.locationErrorTitle,
          message: l10n.locationErrorMessage,
          actionText: l10n.locationRetry,
          onPressed: _locationController.retry,
        );

      case LocationStatus.available:
        final location = _locationController.location;

        if (location == null) {
          return _MessageState(
            icon: Icons.error_outline,
            title: l10n.locationErrorTitle,
            message: l10n.locationErrorMessage,
            actionText: l10n.locationRetry,
            onPressed: _locationController.retry,
          );
        }

        return _LocationAvailableState(
          location: location,
          sessionState: parkingSessionState,
          onStartParkingSession: _startParkingSession,
          onMarkLeavingSoon: _markParkingSessionLeavingSoon,
          onCloseParkingSession: _closeParkingSession,
          watchLeavingSoonSessions:
              sl<WatchLeavingSoonParkingSessionsUseCase>().call,
          onViewportChanged: (viewport) {
            return ref
                .read(parkingViewModelProvider.notifier)
                .queryParkingSpotsInViewport(viewport);
          },
          onClusterViewportChanged: (viewport) {
            return ref
                .read(parkingViewModelProvider.notifier)
                .queryParkingClustersInViewport(viewport);
          },
        );
    }
  }

  Future<Duration?> _requestParkingSessionDuration() async {
    final l10n = AppLocalizations.of(context)!;

    var hoursText = '0';
    var minutesText = '0';
    String? validationError;

    return showDialog<Duration>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.parkingSessionDurationTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: hoursText,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => hoursText = value,
                          decoration: InputDecoration(
                            labelText: l10n.parkingSessionDurationHours,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: minutesText,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => minutesText = value,
                          decoration: InputDecoration(
                            labelText: l10n.parkingSessionDurationMinutes,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      validationError!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final hours = int.tryParse(hoursText.trim());
                    final minutes = int.tryParse(minutesText.trim());

                    if (hours == null ||
                        minutes == null ||
                        hours < 0 ||
                        minutes < 0 ||
                        minutes > 59 ||
                        (hours == 0 && minutes == 0)) {
                      setDialogState(() {
                        validationError = l10n.parkingSessionDurationInvalid;
                      });
                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(Duration(hours: hours, minutes: minutes));
                  },
                  child: Text(l10n.parkingSessionDurationConfirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _startParkingSession(String parkingId) async {
    try {
      final duration = await _requestParkingSessionDuration();

      if (duration == null || !mounted) {
        return;
      }

      final sessionViewModel = ref.read(
        parkingSessionViewModelProvider.notifier,
      );
      final currentSession = ref.read(parkingSessionViewModelProvider).session;
      const expirationPolicy = ParkingSessionExpirationPolicy();

      if (currentSession != null &&
          currentSession.status != ParkingSessionStatus.closed &&
          !expirationPolicy.isOpenSessionExpired(
            currentSession,
            DateTime.now(),
          ) &&
          currentSession.parkingId != parkingId) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            final dialogL10n = AppLocalizations.of(dialogContext)!;

            return AlertDialog(
              title: Text(dialogL10n.parkingSessionSwitchTitle),
              content: Text(dialogL10n.parkingSessionSwitchMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(dialogL10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(dialogL10n.parkingSessionSwitchConfirm),
                ),
              ],
            );
          },
        );

        if (confirmed != true || !mounted) {
          return;
        }

        final latestSession = ref.read(parkingSessionViewModelProvider).session;

        if (latestSession == null || latestSession.id != currentSession.id) {
          throw StateError(
            'The current parking session changed. Please try again.',
          );
        }

        await sessionViewModel.closeSession();
      }

      await sessionViewModel.startSession(
        parkingId,
        plannedEndAt: DateTime.now().add(duration),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _markParkingSessionLeavingSoon() async {
    try {
      await ref
          .read(parkingSessionViewModelProvider.notifier)
          .markLeavingSoon();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _closeParkingSession() async {
    try {
      await ref.read(parkingSessionViewModelProvider.notifier).closeSession();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _openLocationSettings() async {
    await _locationController.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await _locationController.openAppSettings();
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(text: actionText, onPressed: onPressed),
          ],
        ),
      ),
    );
  }
}

class _LocationAvailableState extends StatelessWidget {
  const _LocationAvailableState({
    required this.location,
    required this.sessionState,
    required this.onStartParkingSession,
    required this.onMarkLeavingSoon,
    required this.onCloseParkingSession,
    required this.watchLeavingSoonSessions,
    required this.onViewportChanged,
    required this.onClusterViewportChanged,
  });

  final DriverLocation location;
  final ParkingSessionState sessionState;
  final Future<void> Function(String parkingId) onStartParkingSession;
  final Future<void> Function() onMarkLeavingSoon;
  final Future<void> Function() onCloseParkingSession;
  final Stream<List<ParkingSession>> Function(List<String> parkingIds)
  watchLeavingSoonSessions;
  final Future<List<ParkingSpot>> Function(ParkingViewport viewport)
  onViewportChanged;
  final Future<List<ParkingMapCluster>> Function(ParkingViewport viewport)
  onClusterViewportChanged;

  @override
  Widget build(BuildContext context) {
    return ParkingGoogleMap(
      location: location,
      sessionState: sessionState,
      onStartParkingSession: onStartParkingSession,
      onMarkLeavingSoon: onMarkLeavingSoon,
      onCloseParkingSession: onCloseParkingSession,
      watchLeavingSoonSessions: watchLeavingSoonSessions,
      onViewportChanged: onViewportChanged,
      onClusterViewportChanged: onClusterViewportChanged,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/location_controller.dart';
import '../models/driver_location.dart';
import '../models/location_status.dart';
import '../widgets/parking_google_map.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  State<ParkingMapScreen> createState() =>
      _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen>
    with WidgetsBindingObserver {
  final LocationController _locationController =
      LocationController();

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addObserver(this);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _locationController.loadCurrentLocation();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parkingMapTitle),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _locationController,
          builder: (context, child) {
            return _buildContent(
              context,
              l10n,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (_locationController.status) {
      case LocationStatus.initial:
      case LocationStatus.loading:
        return _LoadingState(
          message: l10n.locationLoading,
        );

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
          message:
              l10n.locationPermissionPermanentlyDeniedMessage,
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
          l10n: l10n,
        );
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
  const _LoadingState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: actionText,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationAvailableState extends StatelessWidget {
  const _LocationAvailableState({
    required this.location,
    required this.l10n,
  });

  final DriverLocation location;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ParkingGoogleMap(
      location: location,
    );
  }
}
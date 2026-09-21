import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/parking_spot.dart';
import '../../domain/enums/parking_status.dart';
import '../../domain/enums/parking_type.dart';
import '../../../map/models/driver_location.dart';
import '../../../../localization/generated/app_localizations.dart';

class ParkingCard extends StatelessWidget {
  const ParkingCard({
    super.key,
    required this.parkingSpot,
    this.driverLocation,
    this.onEdit,
  });

  final ParkingSpot parkingSpot;
  final DriverLocation? driverLocation;
  final VoidCallback? onEdit;

  String _statusLabel(
    ParkingStatus status,
    AppLocalizations l10n,
  ) {
    switch (status) {
      case ParkingStatus.available:
        return l10n.parkingAvailable;
      case ParkingStatus.nearlyFull:
        return l10n.parkingNearlyFull;
      case ParkingStatus.full:
        return l10n.parkingFull;
      case ParkingStatus.closed:
        return l10n.parkingClosed;
    }
  }

  String _typeLabel(
    ParkingType type,
    AppLocalizations l10n,
  ) {
    switch (type) {
      case ParkingType.motorway:
        return l10n.parkingTypeMotorway;
      case ParkingType.serviceArea:
        return l10n.parkingTypeServiceArea;
      case ParkingType.fuelStation:
        return l10n.parkingTypeFuelStation;
      case ParkingType.logisticsCenter:
        return l10n.parkingTypeLogisticsCenter;
      case ParkingType.industrial:
        return l10n.parkingTypeIndustrial;
      case ParkingType.publicParking:
        return l10n.parkingTypePublicParking;
      case ParkingType.privateParking:
        return l10n.parkingTypePrivateParking;
    }
  }

  IconData _statusIcon(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return Icons.check_circle_outline;
      case ParkingStatus.nearlyFull:
        return Icons.warning_amber_rounded;
      case ParkingStatus.full:
        return Icons.do_not_disturb_on_outlined;
      case ParkingStatus.closed:
        return Icons.block_outlined;
    }
  }

  Widget _serviceChip({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(
          icon,
          size: 16,
        ),
        label: Text(label),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Future<void> _openNavigation() async {
    final destinationLatitude =
        parkingSpot.location.latitude;
    final destinationLongitude =
        parkingSpot.location.longitude;

    final destination =
        '$destinationLatitude,$destinationLongitude';

    final String url;

    if (driverLocation != null) {
      final origin =
          '${driverLocation!.latitude},'
          '${driverLocation!.longitude}';

      url = 'https://www.google.com/maps/dir/'
          '?api=1'
          '&origin=$origin'
          '&destination=$destination'
          '&travelmode=driving';
    } else {
      url = 'https://www.google.com/maps/dir/'
          '?api=1'
          '&destination=$destination'
          '&travelmode=driving';
    }

    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      webOnlyWindowName: '_blank',
    )) {
      throw Exception(
        'Could not open Google Maps.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final services = parkingSpot.services;
    final status = parkingSpot.status;
    final type = parkingSpot.type;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          12,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_parking,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    parkingSpot.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
                if (parkingSpot.verified)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: l10n.parkingVerified,
                      child: const Icon(
                        Icons.verified,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  _statusIcon(status),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  _statusLabel(status, l10n),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.parkingFreeSpaces(
                    parkingSpot.freeSpaces,
                    parkingSpot.totalSpaces,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _typeLabel(type, l10n),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
            if (services.toilets ||
                services.showers ||
                services.restaurant ||
                services.fuel ||
                services.security ||
                services.wifi ||
                services.electricity ||
                services.water) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  if (services.toilets)
                    _serviceChip(
                      icon: Icons.wc,
                      label: l10n.parkingServiceToilets,
                    ),
                  if (services.showers)
                    _serviceChip(
                      icon: Icons.shower,
                      label: l10n.parkingServiceShowers,
                    ),
                  if (services.restaurant)
                    _serviceChip(
                      icon: Icons.restaurant,
                      label: l10n.parkingServiceRestaurant,
                    ),
                  if (services.fuel)
                    _serviceChip(
                      icon: Icons.local_gas_station,
                      label: l10n.parkingServiceFuel,
                    ),
                  if (services.security)
                    _serviceChip(
                      icon: Icons.security,
                      label: l10n.parkingServiceSecurity,
                    ),
                  if (services.wifi)
                    _serviceChip(
                      icon: Icons.wifi,
                      label: l10n.parkingServiceWifi,
                    ),
                  if (services.electricity)
                    _serviceChip(
                      icon: Icons.ev_station,
                      label: l10n.parkingServiceElectricity,
                    ),
                  if (services.water)
                    _serviceChip(
                      icon: Icons.water_drop,
                      label: l10n.parkingServiceWater,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (onEdit != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: Text(l10n.edit),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openNavigation,
                    icon: const Icon(
                      Icons.navigation,
                    ),
                    label: Text(
                      l10n.parkingNavigate,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
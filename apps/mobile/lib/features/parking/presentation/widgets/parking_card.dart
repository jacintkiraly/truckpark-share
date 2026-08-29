import 'package:flutter/material.dart';

import '../../domain/entities/parking_spot.dart';
import '../../domain/enums/parking_status.dart';
import '../../domain/enums/parking_type.dart';

class ParkingCard extends StatelessWidget {
  const ParkingCard({
    super.key,
    required this.parkingSpot,
  });

  final ParkingSpot parkingSpot;

  String _statusLabel(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return 'Available';
      case ParkingStatus.nearlyFull:
        return 'Nearly full';
      case ParkingStatus.full:
        return 'Full';
      case ParkingStatus.closed:
        return 'Closed';
    }
  }

  String _typeLabel(ParkingType type) {
    switch (type) {
      case ParkingType.motorway:
        return 'Motorway parking';
      case ParkingType.serviceArea:
        return 'Service area';
      case ParkingType.fuelStation:
        return 'Fuel station';
      case ParkingType.logisticsCenter:
        return 'Logistics center';
      case ParkingType.industrial:
        return 'Industrial area';
      case ParkingType.publicParking:
        return 'Public parking';
      case ParkingType.privateParking:
        return 'Private parking';
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

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (parkingSpot.verified)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: 'Verified parking',
                      child: Icon(
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
                  _statusLabel(status),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${parkingSpot.freeSpaces} / '
                  '${parkingSpot.totalSpaces} free',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              _typeLabel(type),
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
                      label: 'WC',
                    ),
                  if (services.showers)
                    _serviceChip(
                      icon: Icons.shower,
                      label: 'Shower',
                    ),
                  if (services.restaurant)
                    _serviceChip(
                      icon: Icons.restaurant,
                      label: 'Restaurant',
                    ),
                  if (services.fuel)
                    _serviceChip(
                      icon: Icons.local_gas_station,
                      label: 'Fuel',
                    ),
                  if (services.security)
                    _serviceChip(
                      icon: Icons.security,
                      label: 'Security',
                    ),
                  if (services.wifi)
                    _serviceChip(
                      icon: Icons.wifi,
                      label: 'Wi-Fi',
                    ),
                  if (services.electricity)
                    _serviceChip(
                      icon: Icons.ev_station,
                      label: 'Electricity',
                    ),
                  if (services.water)
                    _serviceChip(
                      icon: Icons.water_drop,
                      label: 'Water',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/generated/app_localizations.dart';
import '../../../map/controllers/location_controller.dart';
import '../../../map/models/location_status.dart';
import '../../domain/entities/parking_spot.dart';
import '../../domain/enums/parking_facility_type.dart';
import '../../domain/value_objects/parking_location.dart';
import '../../domain/value_objects/parking_services.dart';
import '../../domain/value_objects/parking_source.dart';
import '../../domain/value_objects/parking_verification.dart';
import '../providers/parking_provider.dart';

class AddParkingScreen extends ConsumerStatefulWidget {
  const AddParkingScreen({super.key});

  @override
  ConsumerState<AddParkingScreen> createState() => _AddParkingScreenState();
}

class _AddParkingScreenState extends ConsumerState<AddParkingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final LocationController _locationController = LocationController();

  ParkingFacilityType _selectedFacilityType =
    ParkingFacilityType.parking;

  bool _toilets = false;
  bool _showers = false;
  bool _restaurant = false;
  bool _fuel = false;
  bool _security = false;
  bool _wifi = false;
  bool _electricity = false;
  bool _water = false;

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final location = _locationController.location;

    if (_locationController.status != LocationStatus.available ||
        location == null) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parkingLocationRequired),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final parkingSpot = ParkingSpot(
        id: '',
        name: _nameController.text.trim(),
        location: ParkingLocation(
          latitude: location.latitude,
          longitude: location.longitude,
        ),

        // Temporary value until country detection/geocoding is implemented.
        countryCode: 'XX',

        facilityType: _selectedFacilityType,

        services: ParkingServices(
          toilets: _toilets,
          showers: _showers,
          restaurant: _restaurant,
          fuel: _fuel,
          security: _security,
          wifi: _wifi,
          electricity: _electricity,
          water: _water,
        ),

        source: const ParkingSource(
          provider: 'TruckPark Share',
          dataset: 'community',
          datasetVersion: '1',
          sourceType: 'community',
        ),

        verification: const ParkingVerification(),
      );

      await ref
          .read(parkingViewModelProvider.notifier)
          .addParkingSpot(parkingSpot);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parkingSaveSuccess),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parkingSaveFailed),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _facilityTypeLabel(
  ParkingFacilityType type,
) {
  switch (type) {
    case ParkingFacilityType.parking:
      return 'Parking';

    case ParkingFacilityType.fueling:
      return 'Fueling';

    case ParkingFacilityType.restArea:
      return 'Rest Area';

    case ParkingFacilityType.truckStopAndRestArea:
      return 'Truck Stop / Rest Area';

    case ParkingFacilityType.fuelingAndTruckStop:
      return 'Fueling / Truck Stop';

    case ParkingFacilityType.parkingAndRestArea:
      return 'Parking / Rest Area';
  }
}

  Widget _buildServiceSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: _isSaving ? null : onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final locationStatus = _locationController.status;
    final location = _locationController.location;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addParking),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isSaving,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.parkingName,
                hintText: l10n.parkingNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.parkingName;
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<ParkingFacilityType>(
              initialValue: _selectedFacilityType,
              decoration: InputDecoration(
                labelText: l10n.parkingType,
                border: const OutlineInputBorder(),
              ),
              items: ParkingFacilityType.values.map((type) {
                return DropdownMenuItem<ParkingFacilityType>(
                  value: type,
                  child: Text(
                    _facilityTypeLabel(type)
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedFacilityType = value;
                      });
                    },
            ),

            const SizedBox(height: 24),

            Text(
              l10n.parkingLocation,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationStatusText(
                        l10n,
                        locationStatus,
                      ),
                    ),

                    if (location != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${location.latitude}, ${location.longitude}',
                      ),
                    ],

                    const SizedBox(height: 12),

                    FilledButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              await _locationController
                                  .loadCurrentLocation();

                              if (mounted) {
                                setState(() {});
                              }
                            },
                      icon: const Icon(Icons.my_location),
                      label: Text(l10n.locationRetry),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.parkingServices,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            _buildServiceSwitch(
              title: l10n.parkingServiceToilets,
              value: _toilets,
              onChanged: (value) {
                setState(() {
                  _toilets = value;
                });
              },
            ),

            _buildServiceSwitch(
              title: l10n.parkingServiceShowers,
              value: _showers,
              onChanged: (value) {
                setState(() {
                  _showers = value;
                });
              },
            ),

            _buildServiceSwitch(
              title: l10n.parkingServiceRestaurant,
              value: _restaurant,
              onChanged: (value) {
                setState(() {
                  _restaurant = value;
                });
              },
            ),

            _buildServiceSwitch(
              title: l10n.parkingServiceFuel,
              value: _fuel,
              onChanged: (value) {
                setState(() {
                  _fuel = value;
                });
              },
            ),

            _buildServiceSwitch(
              title: l10n.parkingServiceSecurity,
              value: _security,
              onChanged: (value) {
                setState(() {
                  _security = value;
                });
              },
            ),

            _buildServiceSwitch(
              title: l10n.parkingServiceWifi,
              value: _wifi,
              onChanged: (value) {
                setState(() {
                  _wifi = value;
                });
              },
            ),

            _buildServiceSwitch(
              title: l10n.parkingServiceElectricity,
              value: _electricity,
              onChanged: (value) {
                setState(() {
                  _electricity = value;
                });
              },
            ),

            _buildServiceSwitch(
              title: l10n.parkingServiceWater,
              value: _water,
              onChanged: (value) {
                setState(() {
                  _water = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _isSaving ? l10n.parkingSaving : l10n.addParking,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _locationStatusText(
    AppLocalizations l10n,
    LocationStatus status,
  ) {
    switch (status) {
      case LocationStatus.initial:
        return l10n.locationLoading;

      case LocationStatus.loading:
        return l10n.locationLoading;

      case LocationStatus.serviceDisabled:
        return l10n.locationServiceDisabledTitle;

      case LocationStatus.permissionDenied:
        return l10n.locationPermissionDeniedTitle;

      case LocationStatus.permissionDeniedForever:
        return l10n.locationPermissionPermanentlyDeniedTitle;

      case LocationStatus.error:
        return l10n.locationErrorTitle;

      case LocationStatus.available:
        return l10n.locationAvailableTitle;
    }
  }
}
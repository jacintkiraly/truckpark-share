import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/generated/app_localizations.dart';
import '../../domain/entities/parking_spot.dart';
import '../../domain/enums/parking_facility_type.dart';
import '../../domain/value_objects/parking_services.dart';
import '../providers/parking_provider.dart';

class EditParkingScreen extends ConsumerStatefulWidget {
  const EditParkingScreen({
    super.key,
    required this.parkingSpot,
  });

  final ParkingSpot parkingSpot;

  @override
  ConsumerState<EditParkingScreen> createState() =>
      _EditParkingScreenState();
}

class _EditParkingScreenState
    extends ConsumerState<EditParkingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late ParkingServices _services;
  late ParkingFacilityType _facilityType;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final parkingSpot = widget.parkingSpot;

    _nameController = TextEditingController(
      text: parkingSpot.name,
    );

    _services = parkingSpot.services;
    _facilityType = parkingSpot.facilityType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedParkingSpot = ParkingSpot(
      id: widget.parkingSpot.id,
      name: _nameController.text.trim(),
      location: widget.parkingSpot.location,
      countryCode: widget.parkingSpot.countryCode,
      facilityType: _facilityType,
      totalAreaM2: widget.parkingSpot.totalAreaM2,
      services: _services,
      infrastructure: widget.parkingSpot.infrastructure,
      context: widget.parkingSpot.context,
      networkContext: widget.parkingSpot.networkContext,
      truckContext: widget.parkingSpot.truckContext,
      source: widget.parkingSpot.source,
      verification: widget.parkingSpot.verification,
      safeAndSecureTruckParkingArea:
          widget.parkingSpot.safeAndSecureTruckParkingArea,
      truckParkingConfidence: widget.parkingSpot.truckParkingConfidence,
    );

    setState(() {
      _isSaving = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      await ref
          .read(parkingViewModelProvider.notifier)
          .updateParkingSpot(updatedParkingSpot);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.parkingUpdateSuccess,
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        '${l10n.parkingUpdateFailed}\n$error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildServiceSwitch({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: _isSaving ? null : onChanged,
    );
  }

  void _updateServices({
    bool? toilets,
    bool? showers,
    bool? restaurant,
    bool? fuel,
    bool? security,
    bool? wifi,
    bool? electricity,
    bool? water,
  }) {
    setState(() {
      _services = ParkingServices(
        toilets: toilets ?? _services.toilets,
        showers: showers ?? _services.showers,
        restaurant: restaurant ?? _services.restaurant,
        fuel: fuel ?? _services.fuel,
        security: security ?? _services.security,
        wifi: wifi ?? _services.wifi,
        electricity: electricity ?? _services.electricity,
        water: water ?? _services.water,
      );
    });
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.parkingDeleteTitle,
          ),
          content: Text(
            l10n.parkingDeleteConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                l10n.cancel,
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                l10n.delete,
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(parkingViewModelProvider.notifier)
          .deleteParkingSpot(widget.parkingSpot.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        '${l10n.parkingDeleteFailed}: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.editParkingTitle,
        ),
      ),
      body: SafeArea(
        child: Form(
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
                  prefixIcon: const Icon(
                    Icons.local_parking,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return l10n.enterName;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<ParkingFacilityType>(
                initialValue: _facilityType,
                decoration: InputDecoration(
                  labelText: l10n.parkingType,
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: ParkingFacilityType.values.map(
                  (type) {
                    return DropdownMenuItem<ParkingFacilityType>(
                      value: type,
                      child: Text(
                        _facilityTypeLabel(type),
                      ),
                    );
                  },
                ).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _facilityType = value;
                        });
                      },
              ),

              const SizedBox(height: 24),

              Text(
                l10n.parkingLocation,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),

              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.location_on,
                ),
                title: Text(
                  l10n.parkingLocation,
                ),
                subtitle: Text(
                  '${widget.parkingSpot.location.latitude.toStringAsFixed(5)}, '
                  '${widget.parkingSpot.location.longitude.toStringAsFixed(5)}',
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.parkingServices,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),

              const SizedBox(height: 8),

              _buildServiceSwitch(
                title: l10n.parkingServiceToilets,
                value: _services.toilets,
                icon: Icons.wc,
                onChanged: (value) {
                  _updateServices(
                    toilets: value,
                  );
                },
              ),

              _buildServiceSwitch(
                title: l10n.parkingServiceShowers,
                value: _services.showers,
                icon: Icons.shower,
                onChanged: (value) {
                  _updateServices(
                    showers: value,
                  );
                },
              ),

              _buildServiceSwitch(
                title: l10n.parkingServiceRestaurant,
                value: _services.restaurant,
                icon: Icons.restaurant,
                onChanged: (value) {
                  _updateServices(
                    restaurant: value,
                  );
                },
              ),

              _buildServiceSwitch(
                title: l10n.parkingServiceFuel,
                value: _services.fuel,
                icon: Icons.local_gas_station,
                onChanged: (value) {
                  _updateServices(
                    fuel: value,
                  );
                },
              ),

              _buildServiceSwitch(
                title: l10n.parkingServiceSecurity,
                value: _services.security,
                icon: Icons.security,
                onChanged: (value) {
                  _updateServices(
                    security: value,
                  );
                },
              ),

              _buildServiceSwitch(
                title: l10n.parkingServiceWifi,
                value: _services.wifi,
                icon: Icons.wifi,
                onChanged: (value) {
                  _updateServices(
                    wifi: value,
                  );
                },
              ),

              _buildServiceSwitch(
                title: l10n.parkingServiceElectricity,
                value: _services.electricity,
                icon: Icons.electrical_services,
                onChanged: (value) {
                  _updateServices(
                    electricity: value,
                  );
                },
              ),

              _buildServiceSwitch(
                title: l10n.parkingServiceWater,
                value: _services.water,
                icon: Icons.water_drop,
                onChanged: (value) {
                  _updateServices(
                    water: value,
                  );
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving
                      ? null
                      : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),
                  label: Text(
                    _isSaving
                        ? l10n.parkingSaving
                        : l10n.parkingSaveChanges,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : _confirmDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: Text(
                    l10n.parkingDelete,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

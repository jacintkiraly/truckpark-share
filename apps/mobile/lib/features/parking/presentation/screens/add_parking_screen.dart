import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/generated/app_localizations.dart';
import '../../../map/controllers/location_controller.dart';
import '../../../map/models/location_status.dart';
import '../../domain/entities/parking_spot.dart';
import '../../domain/enums/parking_status.dart';
import '../../domain/enums/parking_type.dart';
import '../../domain/value_objects/parking_location.dart';
import '../../domain/value_objects/parking_services.dart';
import '../providers/parking_provider.dart';

class AddParkingScreen extends ConsumerStatefulWidget {
  const AddParkingScreen({super.key});

  @override
  ConsumerState<AddParkingScreen> createState() =>
      _AddParkingScreenState();
}

class _AddParkingScreenState
    extends ConsumerState<AddParkingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _totalSpacesController = TextEditingController();
  final _freeSpacesController = TextEditingController();

  final LocationController _locationController =
      LocationController();

  ParkingType _selectedType =
      ParkingType.publicParking;

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationController.loadCurrentLocation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalSpacesController.dispose();
    _freeSpacesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final location = _locationController.location;

    if (_locationController.status !=
            LocationStatus.available ||
        location == null) {
      final l10n = AppLocalizations.of(context)!;

      _showMessage(
        l10n.parkingLocationRequired,
      );
      return;
    }

    final totalSpaces =
        int.tryParse(_totalSpacesController.text.trim());

    final freeSpaces =
        int.tryParse(_freeSpacesController.text.trim());

    if (totalSpaces == null || freeSpaces == null) {
      return;
    }

    if (freeSpaces > totalSpaces) {
      final l10n = AppLocalizations.of(context)!;

      _showMessage(
        l10n.parkingFreeSpacesInvalid,
      );
      return;
    }

    final parkingSpot = ParkingSpot(
      id: '',
      name: _nameController.text.trim(),
      location: ParkingLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      type: _selectedType,
      status: ParkingStatus.available,
      totalSpaces: totalSpaces,
      freeSpaces: freeSpaces,
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
      lastUpdated: DateTime.now(),
      updatedBy: '',
      verified: false,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(parkingViewModelProvider.notifier)
          .addParkingSpot(parkingSpot);

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.parkingSaveSuccess,
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      _showMessage(
        '${l10n.parkingSaveFailed}\n$error',
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

  String _parkingTypeLabel(
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

  Widget _buildServiceSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: _isSaving ? null : onChanged,
    );
  }

  Widget _buildLocationStatus(
    AppLocalizations l10n,
  ) {
    final status = _locationController.status;

    if (status == LocationStatus.loading ||
        status == LocationStatus.initial) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        title: Text(
          l10n.locationLoading,
        ),
      );
    }

    if (status == LocationStatus.available &&
        _locationController.location != null) {
      final location =
          _locationController.location!;

      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.location_on,
        ),
        title: Text(
          l10n.locationAvailableTitle,
        ),
        subtitle: Text(
          '${location.latitude.toStringAsFixed(5)}, '
          '${location.longitude.toStringAsFixed(5)}',
        ),
        trailing: IconButton(
          tooltip: l10n.locationRetry,
          onPressed: _isSaving
              ? null
              : _locationController.retry,
          icon: const Icon(Icons.refresh),
        ),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.location_off,
      ),
      title: Text(
        l10n.locationErrorTitle,
      ),
      subtitle: Text(
        l10n.locationErrorMessage,
      ),
      trailing: IconButton(
        tooltip: l10n.locationRetry,
        onPressed: _isSaving
            ? null
            : _locationController.retry,
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.addParking,
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _locationController,
          builder: (context, child) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isSaving,
                    textInputAction:
                        TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.parkingName,
                      hintText: l10n.parkingNameHint,
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
                  DropdownButtonFormField<ParkingType>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: l10n.parkingType,
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    items: ParkingType.values.map((type) {
                      return DropdownMenuItem<ParkingType>(
                        value: type,
                        child: Text(
                          _parkingTypeLabel(
                            type,
                            l10n,
                          ),
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
                              _selectedType = value;
                            });
                          },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              _totalSpacesController,
                          enabled: !_isSaving,
                          keyboardType:
                              TextInputType.number,
                          textInputAction:
                              TextInputAction.next,
                          decoration: InputDecoration(
                            labelText:
                                l10n.parkingTotalSpaces,
                            prefixIcon: const Icon(
                              Icons.local_parking,
                            ),
                            border:
                                const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final spaces =
                                int.tryParse(
                              value ?? '',
                            );

                            if (spaces == null ||
                                spaces <= 0) {
                              return l10n
                                  .parkingTotalSpacesInvalid;
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller:
                              _freeSpacesController,
                          enabled: !_isSaving,
                          keyboardType:
                              TextInputType.number,
                          textInputAction:
                              TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: l10n.parkingFreeSpacesLabel,
                            prefixIcon: const Icon(
                              Icons.event_available,
                            ),
                            border:
                                const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final freeSpaces =
                                int.tryParse(
                              value ?? '',
                            );

                            if (freeSpaces == null ||
                                freeSpaces < 0) {
                              return l10n
                                  .parkingFreeSpacesInvalid;
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.parkingLocation,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildLocationStatus(l10n),
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
                    value: _toilets,
                    icon: Icons.wc,
                    onChanged: (value) {
                      setState(() {
                        _toilets = value;
                      });
                    },
                  ),
                  _buildServiceSwitch(
                    title: l10n.parkingServiceShowers,
                    value: _showers,
                    icon: Icons.shower,
                    onChanged: (value) {
                      setState(() {
                        _showers = value;
                      });
                    },
                  ),
                  _buildServiceSwitch(
                    title:
                        l10n.parkingServiceRestaurant,
                    value: _restaurant,
                    icon: Icons.restaurant,
                    onChanged: (value) {
                      setState(() {
                        _restaurant = value;
                      });
                    },
                  ),
                  _buildServiceSwitch(
                    title: l10n.parkingServiceFuel,
                    value: _fuel,
                    icon: Icons.local_gas_station,
                    onChanged: (value) {
                      setState(() {
                        _fuel = value;
                      });
                    },
                  ),
                  _buildServiceSwitch(
                    title:
                        l10n.parkingServiceSecurity,
                    value: _security,
                    icon: Icons.security,
                    onChanged: (value) {
                      setState(() {
                        _security = value;
                      });
                    },
                  ),
                  _buildServiceSwitch(
                    title: l10n.parkingServiceWifi,
                    value: _wifi,
                    icon: Icons.wifi,
                    onChanged: (value) {
                      setState(() {
                        _wifi = value;
                      });
                    },
                  ),
                  _buildServiceSwitch(
                    title:
                        l10n.parkingServiceElectricity,
                    value: _electricity,
                    icon: Icons.electrical_services,
                    onChanged: (value) {
                      setState(() {
                        _electricity = value;
                      });
                    },
                  ),
                  _buildServiceSwitch(
                    title: l10n.parkingServiceWater,
                    value: _water,
                    icon: Icons.water_drop,
                    onChanged: (value) {
                      setState(() {
                        _water = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed:
                          _isSaving ? null : _submit,
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
                              Icons.add_location_alt,
                            ),
                      label: Text(
                        _isSaving
                            ? l10n.parkingSaving
                            : l10n.addParking,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
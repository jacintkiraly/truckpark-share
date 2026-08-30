import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parking_spot.dart';
import '../../domain/value_objects/parking_services.dart';
import '../../domain/enums/parking_type.dart';
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
  late final TextEditingController _totalSpacesController;
  late final TextEditingController _freeSpacesController;

  late ParkingServices _services;
  late ParkingType _type;

  bool _isSaving = false;

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

  @override
  void initState() {
    super.initState();

    final parkingSpot = widget.parkingSpot;

    _nameController = TextEditingController(
      text: parkingSpot.name,
    );

    _totalSpacesController = TextEditingController(
      text: parkingSpot.totalSpaces.toString(),
    );

    _freeSpacesController = TextEditingController(
      text: parkingSpot.freeSpaces.toString(),
    );

    _services = parkingSpot.services;
    _type = parkingSpot.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalSpacesController.dispose();
    _freeSpacesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
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
      _showMessage(
        'A szabad helyek száma nem lehet nagyobb '
        'az összes férőhelynél.',
      );
      return;
    }

    final updatedParkingSpot = ParkingSpot(
      id: widget.parkingSpot.id,
      name: _nameController.text.trim(),
      location: widget.parkingSpot.location,
      type: _type,
      status: widget.parkingSpot.status,
      totalSpaces: totalSpaces,
      freeSpaces: freeSpaces,
      services: _services,
      lastUpdated: widget.parkingSpot.lastUpdated,
      updatedBy: widget.parkingSpot.updatedBy,
      verified: widget.parkingSpot.verified,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(parkingViewModelProvider.notifier)
          .updateParkingSpot(updatedParkingSpot);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Parkoló sikeresen módosítva.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'A parkoló módosítása sikertelen.\n$error',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkoló szerkesztése'),
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
                decoration: const InputDecoration(
                  labelText: 'Parkoló neve',
                  prefixIcon: Icon(
                    Icons.local_parking,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Add meg a parkoló nevét.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<ParkingType>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Parkolótípus',
                    prefixIcon: Icon(
                      Icons.category_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: ParkingType.values.map(
                    (type) {
                      return DropdownMenuItem<ParkingType>(
                        value: type,
                        child: Text(
                          _typeLabel(type),
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
                            _type = value;
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
                      decoration:
                          const InputDecoration(
                        labelText: 'Összes férőhely',
                        prefixIcon: Icon(
                          Icons.local_parking,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final spaces =
                            int.tryParse(value ?? '');

                        if (spaces == null ||
                            spaces <= 0) {
                          return 'Érvénytelen';
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
                      decoration:
                          const InputDecoration(
                        labelText: 'Szabad hely',
                        prefixIcon: Icon(
                          Icons.event_available,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final spaces =
                            int.tryParse(value ?? '');

                        if (spaces == null ||
                            spaces < 0) {
                          return 'Érvénytelen';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Helyszín',
                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge,
              ),

              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.location_on,
                ),
                title: const Text(
                  'Parkoló helye',
                ),
                subtitle: Text(
                  '${widget.parkingSpot.location.latitude.toStringAsFixed(5)}, '
                  '${widget.parkingSpot.location.longitude.toStringAsFixed(5)}',
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Szolgáltatások',
                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge,
              ),

              const SizedBox(height: 8),

              _buildServiceSwitch(
                title: 'WC',
                value: _services.toilets,
                icon: Icons.wc,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: value,
                      showers: _services.showers,
                      restaurant: _services.restaurant,
                      fuel: _services.fuel,
                      security: _services.security,
                      wifi: _services.wifi,
                      electricity:
                          _services.electricity,
                      water: _services.water,
                    );
                  });
                },
              ),

              _buildServiceSwitch(
                title: 'Zuhanyzó',
                value: _services.showers,
                icon: Icons.shower,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: _services.toilets,
                      showers: value,
                      restaurant: _services.restaurant,
                      fuel: _services.fuel,
                      security: _services.security,
                      wifi: _services.wifi,
                      electricity:
                          _services.electricity,
                      water: _services.water,
                    );
                  });
                },
              ),

              _buildServiceSwitch(
                title: 'Étterem',
                value: _services.restaurant,
                icon: Icons.restaurant,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: _services.toilets,
                      showers: _services.showers,
                      restaurant: value,
                      fuel: _services.fuel,
                      security: _services.security,
                      wifi: _services.wifi,
                      electricity:
                          _services.electricity,
                      water: _services.water,
                    );
                  });
                },
              ),

              _buildServiceSwitch(
                title: 'Üzemanyag',
                value: _services.fuel,
                icon: Icons.local_gas_station,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: _services.toilets,
                      showers: _services.showers,
                      restaurant: _services.restaurant,
                      fuel: value,
                      security: _services.security,
                      wifi: _services.wifi,
                      electricity:
                          _services.electricity,
                      water: _services.water,
                    );
                  });
                },
              ),

              _buildServiceSwitch(
                title: 'Biztonság',
                value: _services.security,
                icon: Icons.security,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: _services.toilets,
                      showers: _services.showers,
                      restaurant: _services.restaurant,
                      fuel: _services.fuel,
                      security: value,
                      wifi: _services.wifi,
                      electricity:
                          _services.electricity,
                      water: _services.water,
                    );
                  });
                },
              ),

              _buildServiceSwitch(
                title: 'Wi-Fi',
                value: _services.wifi,
                icon: Icons.wifi,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: _services.toilets,
                      showers: _services.showers,
                      restaurant: _services.restaurant,
                      fuel: _services.fuel,
                      security: _services.security,
                      wifi: value,
                      electricity:
                          _services.electricity,
                      water: _services.water,
                    );
                  });
                },
              ),

              _buildServiceSwitch(
                title: 'Elektromosság',
                value: _services.electricity,
                icon: Icons.electrical_services,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: _services.toilets,
                      showers: _services.showers,
                      restaurant: _services.restaurant,
                      fuel: _services.fuel,
                      security: _services.security,
                      wifi: _services.wifi,
                      electricity: value,
                      water: _services.water,
                    );
                  });
                },
              ),

              _buildServiceSwitch(
                title: 'Víz',
                value: _services.water,
                icon: Icons.water_drop,
                onChanged: (value) {
                  setState(() {
                    _services = ParkingServices(
                      toilets: _services.toilets,
                      showers: _services.showers,
                      restaurant: _services.restaurant,
                      fuel: _services.fuel,
                      security: _services.security,
                      wifi: _services.wifi,
                      electricity:
                          _services.electricity,
                      water: value,
                    );
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
                          Icons.save,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Mentés...'
                        : 'Módosítások mentése',
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
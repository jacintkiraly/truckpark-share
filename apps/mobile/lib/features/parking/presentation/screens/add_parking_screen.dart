import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  ParkingType _selectedType = ParkingType.publicParking;

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

    if (_locationController.status != LocationStatus.available ||
        location == null) {
      _showMessage(
        'A parkoló hozzáadásához szükség van '
        'a jelenlegi tartózkodási helyedre.',
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
      _showMessage(
        'A szabad helyek száma nem lehet nagyobb '
        'az összes férőhelynél.',
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parkoló sikeresen hozzáadva.'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'A parkoló mentése sikertelen.\n$error',
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

  String _parkingTypeLabel(ParkingType type) {
    switch (type) {
      case ParkingType.motorway:
        return 'Autópálya';
      case ParkingType.serviceArea:
        return 'Pihenőhely';
      case ParkingType.fuelStation:
        return 'Benzinkút';
      case ParkingType.logisticsCenter:
        return 'Logisztikai központ';
      case ParkingType.industrial:
        return 'Ipari terület';
      case ParkingType.publicParking:
        return 'Nyilvános parkoló';
      case ParkingType.privateParking:
        return 'Privát parkoló';
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

  Widget _buildLocationStatus() {
    final status = _locationController.status;

    if (status == LocationStatus.loading ||
        status == LocationStatus.initial) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        title: Text('Tartózkodási hely lekérése...'),
      );
    }

    if (status == LocationStatus.available &&
        _locationController.location != null) {
      final location = _locationController.location!;

      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.location_on,
        ),
        title: const Text(
          'Tartózkodási hely',
        ),
        subtitle: Text(
          '${location.latitude.toStringAsFixed(5)}, '
          '${location.longitude.toStringAsFixed(5)}',
        ),
        trailing: IconButton(
          tooltip: 'Hely frissítése',
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
      title: const Text(
        'Tartózkodási hely nem érhető el',
      ),
      subtitle: const Text(
        'Ellenőrizd a helymeghatározási engedélyeket.',
      ),
      trailing: IconButton(
        tooltip: 'Újrapróbálás',
        onPressed: _isSaving
            ? null
            : _locationController.retry,
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkoló hozzáadása'),
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
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Parkoló neve',
                      hintText: 'Pl. Test Truck Parking',
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
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Parkolótípus',
                      prefixIcon: Icon(
                        Icons.category_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: ParkingType.values.map((type) {
                      return DropdownMenuItem<ParkingType>(
                        value: type,
                        child: Text(
                          _parkingTypeLabel(type),
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
                                int.tryParse(
                              value ?? '',
                            );

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
                          textInputAction:
                              TextInputAction.done,
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
                            final freeSpaces =
                                int.tryParse(
                              value ?? '',
                            );

                            if (freeSpaces == null ||
                                freeSpaces < 0) {
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 8),

                  _buildLocationStatus(),

                  const SizedBox(height: 24),

                  Text(
                    'Szolgáltatások',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 8),

                  _buildServiceSwitch(
                    title: 'WC',
                    value: _toilets,
                    icon: Icons.wc,
                    onChanged: (value) {
                      setState(() {
                        _toilets = value;
                      });
                    },
                  ),

                  _buildServiceSwitch(
                    title: 'Zuhanyzó',
                    value: _showers,
                    icon: Icons.shower,
                    onChanged: (value) {
                      setState(() {
                        _showers = value;
                      });
                    },
                  ),

                  _buildServiceSwitch(
                    title: 'Étterem',
                    value: _restaurant,
                    icon: Icons.restaurant,
                    onChanged: (value) {
                      setState(() {
                        _restaurant = value;
                      });
                    },
                  ),

                  _buildServiceSwitch(
                    title: 'Üzemanyag',
                    value: _fuel,
                    icon: Icons.local_gas_station,
                    onChanged: (value) {
                      setState(() {
                        _fuel = value;
                      });
                    },
                  ),

                  _buildServiceSwitch(
                    title: 'Biztonság',
                    value: _security,
                    icon: Icons.security,
                    onChanged: (value) {
                      setState(() {
                        _security = value;
                      });
                    },
                  ),

                  _buildServiceSwitch(
                    title: 'Wi-Fi',
                    value: _wifi,
                    icon: Icons.wifi,
                    onChanged: (value) {
                      setState(() {
                        _wifi = value;
                      });
                    },
                  ),

                  _buildServiceSwitch(
                    title: 'Elektromosság',
                    value: _electricity,
                    icon: Icons.electrical_services,
                    onChanged: (value) {
                      setState(() {
                        _electricity = value;
                      });
                    },
                  ),

                  _buildServiceSwitch(
                    title: 'Víz',
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
                            ? 'Mentés...'
                            : 'Parkoló hozzáadása',
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
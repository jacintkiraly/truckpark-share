import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';

class ParkingMapScreen extends StatelessWidget {
  const ParkingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parkingMapTitle),
      ),
      body: Center(
        child: Text(
          l10n.parkingMapPlaceholder,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
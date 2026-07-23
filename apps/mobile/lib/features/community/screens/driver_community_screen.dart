import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';

class DriverCommunityScreen extends StatelessWidget {
  const DriverCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driverCommunityTitle),
      ),
      body: Center(
        child: Text(
          l10n.driverCommunityPlaceholder,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../shared/widgets/primary_button.dart';
import 'community_screen.dart';
import '../../localization/supported_languages.dart';
import '../../localization/generated/app_localizations.dart';
import '../../app/app.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.chooseLanguage,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🌍',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 64),
              ),

              const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context)!.chooseLanguage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                AppLocalizations.of(context)!.languageDescription,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = supportedLanguages[index];

                    return RadioListTile<String>(
                      value: language.languageCode,
                      groupValue: _selectedLanguage,
                      title: Text(language.nativeName),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                        }
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: AppLocalizations.of(context)!.continueButton,
                onPressed: () {
                  TruckParkShareApp.languageController.setLanguage(
                    _selectedLanguage,
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CommunityScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../shared/widgets/primary_button.dart';
import 'community_screen.dart';
import '../../localization/supported_languages.dart';
import '../../localization/generated/app_localizations.dart';

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
        title: const Text('Choose your language'),
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

              const Text(
                'TruckPark Share is available\nin multiple languages.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
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
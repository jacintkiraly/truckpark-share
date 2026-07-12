class AppLanguage {
  const AppLanguage({
    required this.languageCode,
    required this.nativeName,
    required this.englishName,
    this.countryCode,
  });

  final String languageCode;
  final String nativeName;
  final String englishName;

  /// Optional country code (GB, ES, HU...)
  final String? countryCode;
}
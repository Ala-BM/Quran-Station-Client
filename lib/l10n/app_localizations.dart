import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, dynamic> _localizedStrings;

  Future<bool> load() async {
    String jsonString =
    await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
Map<String, dynamic> jsonMap = json.decode(jsonString);

// Preserve lists while converting everything else to strings
_localizedStrings = jsonMap.map((key, value) {
  return MapEntry(key, value); // Keep lists as they are, and convert only necessary values
});

    return true;
  }
List<String> translateList(String key) {
   if (!_localizedStrings.containsKey(key)) {
    debugPrint("Key '$key' not found. Available keys: ${_localizedStrings.keys}");
    return [];
  }

  dynamic value = _localizedStrings[key];

  if (value is List<dynamic>) {
    return value.map((item) => item.toString()).toList(); // Convert each item to String
  } else {
    debugPrint("Value for key '$key' is not a list. Found: ${value.runtimeType}");
    return [];
  }
}
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    notifyListeners();  // Notify listeners to rebuild the app with the new locale
  }
}

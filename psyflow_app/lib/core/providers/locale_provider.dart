import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('pt', 'BR');
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'pt';
    final countryCode = prefs.getString('${_localeKey}_country') ?? 'BR';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    if (locale.countryCode != null) {
      await prefs.setString('${_localeKey}_country', locale.countryCode!);
    }
  }

  void setLanguage(String languageCode, {String? countryCode}) {
    final locale = Locale(languageCode, countryCode);
    setLocale(locale);
  }
}
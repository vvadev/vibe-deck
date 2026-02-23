import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _localeKey = 'ui_locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    final locale = saved == 'ru' ? const Locale('ru') : const Locale('en');
    Intl.defaultLocale = locale.languageCode;
    _locale = locale;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    Intl.defaultLocale = locale.languageCode;
    _locale = locale;
    notifyListeners();
  }
}

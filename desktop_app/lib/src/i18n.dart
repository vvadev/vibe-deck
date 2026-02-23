import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppI18n {
  const AppI18n(this.locale);

  final Locale locale;

  static AppI18n of(BuildContext context) {
    return AppI18n(Localizations.localeOf(context));
  }

  String text(String en, String ru) {
    final language = Intl.canonicalizedLocale(locale.languageCode);
    return Intl.select(language, <String, String>{
      'ru': ru,
      'en': en,
      'other': en,
    });
  }
}

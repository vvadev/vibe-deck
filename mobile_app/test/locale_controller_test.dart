import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_deck_mobile/src/app/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loadLocale restores saved ru locale', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'ui_locale': 'ru'});
    final controller = LocaleController();

    await controller.loadLocale();

    expect(controller.locale.languageCode, 'ru');
  });

  test('setLocale persists locale value', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = LocaleController();

    await controller.setLocale(const Locale('ru'));
    final prefs = await SharedPreferences.getInstance();

    expect(controller.locale.languageCode, 'ru');
    expect(prefs.getString('ui_locale'), 'ru');
  });
}

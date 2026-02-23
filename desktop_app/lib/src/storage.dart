import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'deck_models.dart';
import 'models.dart';

class DesktopStorage {
  static const String settingsKey = 'desktop_settings_v1';
  static const String actionsKey = 'desktop_actions_v1';
  static const String deckProfileKey = 'desktop_deck_profile_v2';

  Future<DesktopSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(settingsKey);
    if (raw == null || raw.isEmpty) {
      return DesktopSettings.defaults();
    }
    try {
      return DesktopSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return DesktopSettings.defaults();
    }
  }

  Future<void> saveSettings(DesktopSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(settingsKey, jsonEncode(settings.toJson()));
  }

  Future<List<DesktopAction>> loadActions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(actionsKey);
    if (raw == null || raw.isEmpty) {
      return <DesktopAction>[
        DesktopAction(
          id: 'sample-echo',
          name: 'Sample Echo',
          command: 'echo',
          args: <String>['Vibe Deck action'],
          enabled: true,
          runInShell: false,
        ),
      ];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => DesktopAction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <DesktopAction>[];
    }
  }

  Future<void> saveActions(List<DesktopAction> actions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      actionsKey,
      jsonEncode(actions.map((e) => e.toJson()).toList()),
    );
  }

  Future<DeckProfile> loadDeckProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(deckProfileKey);
    if (raw == null || raw.isEmpty) {
      return DeckProfile.defaultProfile();
    }
    try {
      return DeckProfile.decode(raw).normalized();
    } catch (_) {
      return DeckProfile.defaultProfile();
    }
  }

  Future<void> saveDeckProfile(DeckProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(deckProfileKey, profile.normalized().encode());
  }
}

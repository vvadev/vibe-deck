import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck_models.dart';

class ProfileStorage {
  static const String _profileKey = 'deck_profile_v1';
  static const String _deckTipDismissedKey = 'deck_tip_dismissed_v1';

  Future<DeckProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return DeckProfile.defaultProfile();
    }
    try {
      return DeckProfile.decode(raw);
    } catch (_) {
      return DeckProfile.defaultProfile();
    }
  }

  Future<void> saveProfile(DeckProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.encode());
  }

  Future<bool> loadDeckTipDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deckTipDismissedKey) ?? false;
  }

  Future<void> saveDeckTipDismissed(bool dismissed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deckTipDismissedKey, dismissed);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class LocalPartyStorage {
  static const String _keyPartyOpen = 'party_open';
  static const String _keyPlaceId = 'party_place_id';
  static const String _keyUserId = 'party_user_id';
  static const String _keyWelcomeSeen = 'welcome_seen_once';

  static Future<void> setPartySession({
    required bool isOpen,
    required String userId,
    required int placeId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPartyOpen, isOpen);
    await prefs.setString(_keyUserId, userId);
    await prefs.setInt(_keyPlaceId, placeId);
  }

  static Future<void> setPartyOpen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPartyOpen, value);
  }

  static Future<bool> isPartyOpenForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString(_keyUserId);
    if (storedUser == null || storedUser != userId) return false;
    return prefs.getBool(_keyPartyOpen) ?? false;
  }

  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWelcomeSeen) ?? false;
  }

  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWelcomeSeen, true);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPartyOpen);
    await prefs.remove(_keyPlaceId);
    await prefs.remove(_keyUserId);
  }

  static Future<void> clear() async {
    await clearSession();
  }
}

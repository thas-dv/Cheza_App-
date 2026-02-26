import 'package:shared_preferences/shared_preferences.dart';

class LocalPartyStorage {
  static const String _keyPartyOpen = "party_open";

  static Future<void> setPartyOpen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPartyOpen, value);
  }

  static Future<bool> isPartyOpen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPartyOpen) ?? false;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPartyOpen);
  }
}
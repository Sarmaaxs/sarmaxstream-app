import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Small JSON cache on top of SharedPreferences.
/// Only non-sensitive data (search results, resolved track ids) is stored here.
class LocalStore {
  LocalStore(this._prefs);
  final SharedPreferences _prefs;
  static Future<LocalStore> load() async =>
      LocalStore(await SharedPreferences.getInstance());

  Future<void> putJson(String key, Object value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? json(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Iterable<String> keys(String prefix) =>
      _prefs.getKeys().where((k) => k.startsWith(prefix)).toList();

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

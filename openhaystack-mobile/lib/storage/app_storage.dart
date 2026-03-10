import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const FlutterSecureStorage _legacyStorage = FlutterSecureStorage();

  static Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value != null) {
      return value;
    }

    // Migrate legacy metadata that was previously stored in secure storage.
    final legacyValue = await _legacyStorage.read(key: key);
    if (legacyValue != null) {
      await prefs.setString(key, legacyValue);
      await _legacyStorage.delete(key: key);
    }
    return legacyValue;
  }

  static Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

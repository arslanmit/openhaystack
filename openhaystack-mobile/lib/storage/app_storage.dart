import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<String?> read(String key) async {
    if (Platform.isMacOS) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }

    return _secureStorage.read(key: key);
  }

  static Future<void> write(String key, String value) async {
    if (Platform.isMacOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }

    await _secureStorage.write(key: key, value: value);
  }

  static Future<void> deleteAll() async {
    if (Platform.isMacOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return;
    }

    await _secureStorage.deleteAll();
  }
}

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureKeyStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const bool _allowInsecureMacOSFallback = bool.fromEnvironment(
    'OPENHAYSTACK_ALLOW_INSECURE_MACOS_KEYS',
  );
  static const String _fallbackPrefix = 'secure_key_storage.';

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<String?> read(String key) async {
    if (Platform.isMacOS && _allowInsecureMacOSFallback) {
      final prefs = await _prefs();
      return prefs.getString('$_fallbackPrefix$key');
    }
    return _storage.read(key: key);
  }

  static Future<void> write(String key, String value) async {
    if (Platform.isMacOS && _allowInsecureMacOSFallback) {
      final prefs = await _prefs();
      await prefs.setString('$_fallbackPrefix$key', value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  static Future<void> deleteAll() async {
    if (Platform.isMacOS && _allowInsecureMacOSFallback) {
      final prefs = await _prefs();
      final keysToRemove = prefs
          .getKeys()
          .where((key) => key.startsWith(_fallbackPrefix))
          .toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      return;
    }
    await _storage.deleteAll();
  }
}

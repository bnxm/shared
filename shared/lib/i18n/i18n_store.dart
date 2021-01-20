import 'package:shared_preferences/shared_preferences.dart';

abstract class I18nStore {
  Future<void> setLanguageCode(String code);
  Future<String> getLanguageCode();
}

class I18nSharedPreferencesStore implements I18nStore {
  static Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  static const String key = 'LANGUAGE';

  @override
  Future<String> getLanguageCode() async => (await _preferences).getString(key);

  @override
  Future<void> setLanguageCode(String code) async => (await _preferences)?.setString(key, code);
}

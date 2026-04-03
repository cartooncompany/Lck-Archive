import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage.dart';

class SharedPreferencesLocalStorage implements LocalStorage {
  SharedPreferencesLocalStorage(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesLocalStorage> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesLocalStorage(preferences);
  }

  @override
  Future<void> delete(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<String?> readString(String key) async {
    return _preferences.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    await _preferences.setString(key, value);
  }
}

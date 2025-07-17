import 'package:flutter_vaden/flutter_vaden.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAdapter implements ILocalStorage {
  final Future<SharedPreferences> _sharedPreferences;

  SharedPreferencesAdapter(this._sharedPreferences);

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _sharedPreferences;
    return prefs.getBool(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    final prefs = await _sharedPreferences;
    return prefs.getDouble(key);
  }

  @override
  Future<int?> getInt(String key) async {
    final prefs = await _sharedPreferences;
    return prefs.getInt(key);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _sharedPreferences;
    return prefs.getString(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _sharedPreferences;
    return prefs.setBool(key, value);
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    final prefs = await _sharedPreferences;
    return prefs.setDouble(key, value);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    final prefs = await _sharedPreferences;
    return prefs.setInt(key, value);
  }

  @override
  Future<bool> setString(String key, String value) async {
    final prefs = await _sharedPreferences;
    return prefs.setString(key, value);
  }
}

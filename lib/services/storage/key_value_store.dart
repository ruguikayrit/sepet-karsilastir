import 'package:shared_preferences/shared_preferences.dart';

/// Basit anahtar-değer deposu sözleşmesi.
///
/// Testlerde [InMemoryStore], uygulamada [PreferencesStore] kullanılır.
abstract class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class PreferencesStore implements KeyValueStore {
  PreferencesStore(this._prefs);

  static Future<PreferencesStore> open() async {
    return PreferencesStore(await SharedPreferences.getInstance());
  }

  final SharedPreferences _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

class InMemoryStore implements KeyValueStore {
  InMemoryStore([Map<String, String>? seed])
      : _data = {...?seed};

  final Map<String, String> _data;

  @override
  String? read(String key) => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}

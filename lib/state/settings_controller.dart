import 'package:flutter/material.dart';

import '../services/storage/key_value_store.dart';

/// Kullanıcı tercihleri (şimdilik tema).
class SettingsController extends ChangeNotifier {
  SettingsController(this._store) {
    _themeMode = _parseThemeMode(_store.read(_themeKey));
  }

  static const _themeKey = 'settings.themeMode.v1';

  final KeyValueStore _store;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _store.write(_themeKey, mode.name);
    notifyListeners();
  }

  static ThemeMode _parseThemeMode(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

extension ThemeModeLabel on ThemeMode {
  String get label => switch (this) {
        ThemeMode.light => 'Açık',
        ThemeMode.dark => 'Koyu',
        ThemeMode.system => 'Sistem',
      };

  IconData get icon => switch (this) {
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.system => Icons.brightness_auto_rounded,
      };
}

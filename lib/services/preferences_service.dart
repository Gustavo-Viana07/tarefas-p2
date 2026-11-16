import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._preferences);

  static const _themeKey = 'theme_mode';
  final SharedPreferences _preferences;

  Future<ThemeMode> loadThemeMode() async {
    return switch (_preferences.getString(_themeKey)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    final saved = await _preferences.setString(_themeKey, value);
    if (!saved) {
      throw StateError('Não foi possível salvar a preferência de tema.');
    }
  }
}

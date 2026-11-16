import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas_p2/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('salva e recupera a preferência de tema', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService(
      await SharedPreferences.getInstance(),
    );

    expect(await preferences.loadThemeMode(), ThemeMode.system);
    await preferences.saveThemeMode(ThemeMode.dark);
    expect(await preferences.loadThemeMode(), ThemeMode.dark);
  });
}

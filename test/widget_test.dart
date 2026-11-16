import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas_p2/main.dart';
import 'package:tarefas_p2/services/preferences_service.dart';

void main() {
  testWidgets('orienta a configurar o Firebase antes de usar o app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService(
      await SharedPreferences.getInstance(),
    );

    await tester.pumpWidget(
      TarefasApp(
        preferences: preferences,
        initialThemeMode: ThemeMode.light,
        firebaseReady: false,
      ),
    );

    expect(find.text('Configure o Firebase'), findsOneWidget);
    expect(
      find.textContaining('configure um projeto Firebase'),
      findsOneWidget,
    );
  });
}

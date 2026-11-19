import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas_p2/main.dart';
import 'package:tarefas_p2/models/tarefa.dart';
import 'package:tarefas_p2/screens/home_screen.dart';
import 'package:tarefas_p2/screens/cadastro_usuario_screen.dart';
import 'package:tarefas_p2/services/auth_service.dart';
import 'package:tarefas_p2/services/firebase_service.dart';
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

  testWidgets('navega os campos de cadastro pelo teclado', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroUsuarioScreen()));

    final nameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);
    final passwordField = find.byType(TextFormField).at(2);
    final confirmationField = find.byType(TextFormField).at(3);
    bool hasFocus(Finder field) {
      return tester
          .widget<EditableText>(
            find.descendant(of: field, matching: find.byType(EditableText)),
          )
          .focusNode
          .hasFocus;
    }

    await tester.tap(nameField);
    await tester.pump();
    expect(hasFocus(nameField), isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(hasFocus(emailField), isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(hasFocus(passwordField), isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(hasFocus(confirmationField), isTrue);
  });

  testWidgets('atualiza o nome quando o perfil do Firebase muda', (
    tester,
  ) async {
    final authService = _FakeAuthService();
    final firebaseService = _FakeFirebaseService();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          user: _FakeUser(displayName: null),
          authService: authService,
          firebaseService: firebaseService,
          onThemeChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Olá, aluno@example.com!'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          user: _FakeUser(displayName: 'Maria Silva'),
          authService: authService,
          firebaseService: firebaseService,
          onThemeChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Olá, Maria!'), findsOneWidget);
  });
}

class _FakeUser extends Fake implements User {
  _FakeUser({required this.displayName});

  @override
  final String? displayName;

  @override
  String get uid => 'user-1';

  @override
  String? get email => 'aluno@example.com';
}

class _FakeAuthService extends Fake implements AuthService {}

class _FakeFirebaseService extends Fake implements FirebaseService {
  @override
  Stream<List<Tarefa>> watchTasks(String uid) => Stream.value(const []);
}

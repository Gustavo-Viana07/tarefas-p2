import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/firebase_setup_screen.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesService(await SharedPreferences.getInstance());
  final themeMode = await preferences.loadThemeMode();
  final options = DefaultFirebaseOptions.currentPlatform;
  final firebaseReady = options != null;

  if (options != null) {
    await Firebase.initializeApp(options: options);
  }

  runApp(
    TarefasApp(
      preferences: preferences,
      initialThemeMode: themeMode,
      firebaseReady: firebaseReady,
    ),
  );
}

class TarefasApp extends StatefulWidget {
  const TarefasApp({
    super.key,
    required this.preferences,
    required this.initialThemeMode,
    required this.firebaseReady,
  });

  final PreferencesService preferences;
  final ThemeMode initialThemeMode;
  final bool firebaseReady;

  @override
  State<TarefasApp> createState() => _TarefasAppState();
}

class _TarefasAppState extends State<TarefasApp> {
  late ThemeMode _themeMode = widget.initialThemeMode;

  Future<void> _changeTheme(ThemeMode mode) async {
    await widget.preferences.saveThemeMode(mode);
    if (mounted) {
      setState(() => _themeMode = mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: widget.firebaseReady
          ? AuthGate(onThemeChanged: _changeTheme)
          : const FirebaseSetupScreen(),
    );
  }
}

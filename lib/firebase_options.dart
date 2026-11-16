import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _databaseUrl = String.fromEnvironment('FIREBASE_DATABASE_URL');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');

  static FirebaseOptions? get currentPlatform {
    final appId = kIsWeb ? _webAppId : _androidAppId;
    if (_apiKey.isEmpty ||
        _projectId.isEmpty ||
        _databaseUrl.isEmpty ||
        _messagingSenderId.isEmpty ||
        appId.isEmpty ||
        (kIsWeb && _authDomain.isEmpty)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _apiKey,
      appId: appId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      databaseURL: _databaseUrl,
      authDomain: kIsWeb ? _authDomain : null,
    );
  }
}
